import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import cookieParser from "cookie-parser";
import rateLimit from "express-rate-limit";
import { env, passport, minioClient } from "./config";
import { errorHandler } from "./shared/middleware";
import { apiRouter } from "./routes";

const app = express();

// ── Security ────────────────────────────────────────────────
app.use(helmet());
app.use(
  cors({
    origin: true, // allow any origin (mobile apps, dev tunnels, etc.)
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

// ── Public file proxy (no auth – serves MinIO objects) ─────
app.get("/files/:bucket/*objectKey", async (req, res, next) => {
  try {
    const bucket = req.params.bucket;
    // path-to-regexp v8: *objectKey captures as an array of path segments
    const rawKey = req.params.objectKey;
    const objectKey = Array.isArray(rawKey) ? rawKey.join("/") : String(rawKey);
    const stream = await minioClient.getObject(bucket, objectKey);

    // Forward content-type from MinIO stat
    try {
      const stat = await minioClient.statObject(bucket, objectKey);
      if (stat.metaData?.["content-type"]) {
        res.setHeader("Content-Type", stat.metaData["content-type"]);
      }
      if (stat.size) {
        res.setHeader("Content-Length", stat.size);
      }
    } catch {
      // stat failed – still try to stream
    }

    res.setHeader("Cache-Control", "public, max-age=31536000, immutable");
    stream.pipe(res);
  } catch (err: any) {
    if (err?.code === "NoSuchKey" || err?.code === "NoSuchBucket") {
      res.status(404).json({ success: false, message: "File not found" });
    } else {
      next(err);
    }
  }
});

// ── API Routes ──────────────────────────────────────────────
app.use(env.API_PREFIX, apiRouter);

// ── 404 catch-all (must be after routes, before error handler) ──
app.use((_req, res) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${_req.method} ${_req.originalUrl}`,
  });
});

// ── Error handling (must be last) ───────────────────────────
app.use(errorHandler);

export default app;
