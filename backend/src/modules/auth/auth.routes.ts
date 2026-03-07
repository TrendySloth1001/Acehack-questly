import { Router } from "express";
import passport from "passport";
import { authController } from "./auth.controller";
import {
  registerValidation,
  loginValidation,
  refreshValidation,
} from "./auth.validation";
import { validate, authenticate, asyncHandler } from "../../shared/middleware";

const router = Router();

// ── Local auth ──────────────────────────────────────────────
router.post(
  "/register",
  registerValidation,
  validate,
  asyncHandler(authController.register)
);

router.post(
  "/login",
  loginValidation,
  validate,
  asyncHandler(authController.login)
);

router.post(
  "/refresh",
  refreshValidation,
  validate,
  asyncHandler(authController.refresh)
);

router.post("/logout", asyncHandler(authController.logout));

// ── Current user ────────────────────────────────────────────
router.get("/me", authenticate, asyncHandler(authController.me));

// ── Google OAuth ────────────────────────────────────────────
router.get(
  "/google",
  passport.authenticate("google", { scope: ["profile", "email"], session: false })
);

router.get(
  "/google/callback",
  passport.authenticate("google", { session: false, failureRedirect: "/auth/fail" }),
  asyncHandler(authController.oauthCallback)
);

// ── GitHub OAuth ────────────────────────────────────────────
router.get(
  "/github",
  passport.authenticate("github", { scope: ["user:email"], session: false })
);

router.get(
  "/github/callback",
  passport.authenticate("github", { session: false, failureRedirect: "/auth/fail" }),
  asyncHandler(authController.oauthCallback)
);

export default router;
