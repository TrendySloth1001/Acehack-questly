import { Request, Response } from "express";
import { authService } from "./auth.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS, SUCCESS_MESSAGES, AUTH } from "../../shared/constants";
import { env } from "../../config/env";

const COOKIE_OPTIONS = {
  httpOnly: true,
  secure: env.IS_PRODUCTION,
  sameSite: "lax" as const,
  path: "/",
};

function setTokenCookies(res: Response, accessToken: string, refreshToken: string) {
  res.cookie(AUTH.ACCESS_TOKEN_COOKIE, accessToken, {
    ...COOKIE_OPTIONS,
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  });
  res.cookie(AUTH.REFRESH_TOKEN_COOKIE, refreshToken, {
    ...COOKIE_OPTIONS,
    maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
  });
}

export class AuthController {
  async register(req: Request, res: Response) {
    const tokens = await authService.register(req.body);
    setTokenCookies(res, tokens.accessToken, tokens.refreshToken);

    sendSuccess({
      res,
      data: tokens,
      message: SUCCESS_MESSAGES.REGISTER,
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async login(req: Request, res: Response) {
    const tokens = await authService.login(req.body);
    setTokenCookies(res, tokens.accessToken, tokens.refreshToken);

    sendSuccess({
      res,
      data: tokens,
      message: SUCCESS_MESSAGES.LOGIN,
    });
  }

  async refresh(req: Request, res: Response) {
    const oldToken =
      req.body.refreshToken || req.cookies?.[AUTH.REFRESH_TOKEN_COOKIE];

    const tokens = await authService.refreshToken(oldToken);
    setTokenCookies(res, tokens.accessToken, tokens.refreshToken);

    sendSuccess({
      res,
      data: tokens,
      message: SUCCESS_MESSAGES.TOKEN_REFRESHED,
    });
  }

  async logout(req: Request, res: Response) {
    const token =
      req.body.refreshToken || req.cookies?.[AUTH.REFRESH_TOKEN_COOKIE];

    if (token) await authService.logout(token);

    res.clearCookie(AUTH.ACCESS_TOKEN_COOKIE);
    res.clearCookie(AUTH.REFRESH_TOKEN_COOKIE);

    sendSuccess({ res, message: SUCCESS_MESSAGES.LOGOUT });
  }

  async me(req: Request, res: Response) {
    const user = await authService.me(req.currentUser!.userId);
    sendSuccess({ res, data: user });
  }

  async updateProfile(req: Request, res: Response) {
    const user = await authService.updateProfile(req.currentUser!.userId, req.body);
    sendSuccess({ res, data: user, message: 'Profile updated' });
  }

  /**
   * POST /auth/google
   * Mobile clients (Flutter) send a Google idToken; we verify it and return JWTs.
   */
  async googleTokenLogin(req: Request, res: Response) {
    const { idToken } = req.body as { idToken?: string };
    if (!idToken) {
      res.status(400).json({ success: false, message: "idToken is required" });
      return;
    }

    const tokens = await authService.loginWithGoogleIdToken(idToken);
    setTokenCookies(res, tokens.accessToken, tokens.refreshToken);

    sendSuccess({
      res,
      data: tokens,
      message: "Google login successful",
    });
  }

  /**
   * Called after passport OAuth callback to issue JWT tokens.
   */
  async oauthCallback(req: Request, res: Response) {
    const user = req.user as any;
    const tokens = await authService.loginOAuth(user.id);
    setTokenCookies(res, tokens.accessToken, tokens.refreshToken);

    // Redirect to frontend with tokens as query params (deep link friendly)
    const redirectUrl = new URL("/auth/callback", env.CLIENT_URL);
    redirectUrl.searchParams.set("access_token", tokens.accessToken);
    redirectUrl.searchParams.set("refresh_token", tokens.refreshToken);
    res.redirect(redirectUrl.toString());
  }
}

export const authController = new AuthController();
