import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import cookieParser from "cookie-parser";
import rateLimit from "express-rate-limit";
import { env, passport } from "./config";
import { errorHandler } from "./shared/middleware";
import { apiRouter } from "./routes";

const app = express();

// ── Security ────────────────────────────────────────────────
app.use(helmet());
app.use(
  cors({
    origin: env.CLIENT_URL,
    credentials: true,
  })
);

// ── Rate limiting ───────────────────────────────────────────
app.use(
  rateLimit({
    windowMs: env.RATE_LIMIT_WINDOW_MS,
    max: env.RATE_LIMIT_MAX,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

// ── Parsing ─────────────────────────────────────────────────
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(compression());

// ── Logging ─────────────────────────────────────────────────
if (!env.IS_PRODUCTION) {
  app.use(morgan("dev"));
}

// ── Passport ────────────────────────────────────────────────
app.use(passport.initialize());

// ── Health check ────────────────────────────────────────────
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// ── API Routes ──────────────────────────────────────────────
app.use(env.API_PREFIX, apiRouter);

// ── Error handling (must be last) ───────────────────────────
app.use(errorHandler);

export default app;
