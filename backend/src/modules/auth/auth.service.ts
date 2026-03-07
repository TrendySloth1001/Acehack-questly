import bcrypt from "bcryptjs";
import { prisma } from "../../config/database";
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from "../../shared/utils/jwt";
import {
  UnauthorizedError,
  ConflictError,
  NotFoundError,
} from "../../shared/errors";
import {
  AUTH,
  ERROR_MESSAGES,
} from "../../shared/constants";

// ── DTOs ────────────────────────────────────────────────────

export interface RegisterDTO {
  email: string;
  password: string;
  name?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

// ── Service ─────────────────────────────────────────────────

export class AuthService {
  /**
   * Register a new local user.
   * Single query to check + create avoids race conditions via unique constraint.
   */
  async register(dto: RegisterDTO): Promise<AuthTokens & { userId: string }> {
    const existing = await prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictError(ERROR_MESSAGES.EMAIL_ALREADY_EXISTS);
    }

    const hashedPassword = await bcrypt.hash(dto.password, AUTH.SALT_ROUNDS);

    const user = await prisma.user.create({
      data: {
        email: dto.email,
        name: dto.name,
        password: hashedPassword,
        emailVerified: false,
      },
      select: { id: true, email: true, role: true },
    });

    const tokens = this.generateTokens(user.id, user.email, user.role);
    await this.persistRefreshToken(user.id, tokens.refreshToken);

    return { ...tokens, userId: user.id };
  }

  /**
   * Login with email + password.
   */
  async login(dto: LoginDTO): Promise<AuthTokens & { userId: string }> {
    const user = await prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true, email: true, role: true, password: true, isActive: true },
    });

    if (!user || !user.password) {
      throw new UnauthorizedError(ERROR_MESSAGES.INVALID_CREDENTIALS);
    }

    if (!user.isActive) {
      throw new UnauthorizedError("Account is deactivated");
    }

    const valid = await bcrypt.compare(dto.password, user.password);
    if (!valid) {
      throw new UnauthorizedError(ERROR_MESSAGES.INVALID_CREDENTIALS);
    }

    const tokens = this.generateTokens(user.id, user.email, user.role);
    await this.persistRefreshToken(user.id, tokens.refreshToken);

    return { ...tokens, userId: user.id };
  }

  /**
   * Generate tokens for an OAuth user (called after passport callback).
   */
  async loginOAuth(userId: string): Promise<AuthTokens> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, role: true },
    });

    if (!user) throw new NotFoundError("User not found");

    const tokens = this.generateTokens(user.id, user.email, user.role);
    await this.persistRefreshToken(user.id, tokens.refreshToken);
    return tokens;
  }

  /**
   * Refresh access token.
   * Rotates the refresh token (one-time use).
   */
  async refreshToken(oldRefreshToken: string): Promise<AuthTokens> {
    const payload = verifyRefreshToken(oldRefreshToken);

    // Atomic delete – if it doesn't exist, the token was already used (replay)
    const deleted = await prisma.refreshToken.deleteMany({
      where: { token: oldRefreshToken },
    });

    if (deleted.count === 0) {
      // Possible token reuse → revoke ALL tokens for this user
      await prisma.refreshToken.deleteMany({
        where: { userId: payload.userId },
      });
      throw new UnauthorizedError(ERROR_MESSAGES.TOKEN_INVALID);
    }

    const tokens = this.generateTokens(
      payload.userId,
      payload.email,
      payload.role
    );
    await this.persistRefreshToken(payload.userId, tokens.refreshToken);
    return tokens;
  }

  /**
   * Logout – revoke specific refresh token.
   */
  async logout(refreshToken: string): Promise<void> {
    await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
  }

  /**
   * Get current user profile with minimal fields.
   */
  async me(userId: string) {
    return prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        avatarUrl: true,
        role: true,
        createdAt: true,
      },
    });
  }

  // ── Private helpers ──────────────────────────────────────

  private generateTokens(
    userId: string,
    email: string,
    role: string
  ): AuthTokens {
    return {
      accessToken: signAccessToken({ userId, email, role }),
      refreshToken: signRefreshToken({ userId, email, role }),
    };
  }

  private async persistRefreshToken(
    userId: string,
    token: string
  ): Promise<void> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await prisma.refreshToken.create({
      data: { token, userId, expiresAt },
    });
  }
}

export const authService = new AuthService();
