import { Request, Response, NextFunction } from "express";
import { verifyAccessToken, TokenPayload } from "../utils/jwt";
import { UnauthorizedError, ForbiddenError } from "../errors";
import { AUTH, ERROR_MESSAGES } from "../constants";

// Extend Express Request
declare global {
  namespace Express {
    interface Request {
      currentUser?: TokenPayload;
    }
  }
}

/**
 * Authenticate via Bearer token or cookie.
 */
export function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction
): void {
  try {
    let token: string | undefined;

    // Check Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith(AUTH.TOKEN_TYPE)) {
      token = authHeader.split(" ")[1];
    }

    // Fallback to cookie
    if (!token && req.cookies?.[AUTH.ACCESS_TOKEN_COOKIE]) {
      token = req.cookies[AUTH.ACCESS_TOKEN_COOKIE];
    }

    if (!token) {
      throw new UnauthorizedError(ERROR_MESSAGES.UNAUTHORIZED);
    }

    const decoded = verifyAccessToken(token);
    req.currentUser = decoded;
    next();
  } catch {
    next(new UnauthorizedError(ERROR_MESSAGES.TOKEN_INVALID));
  }
}

/**
 * Restrict to specific roles.
 */
export function authorize(...allowedRoles: string[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.currentUser) {
      return next(new UnauthorizedError(ERROR_MESSAGES.UNAUTHORIZED));
    }
    if (!allowedRoles.includes(req.currentUser.role)) {
      return next(new ForbiddenError(ERROR_MESSAGES.FORBIDDEN));
    }
    next();
  };
}
