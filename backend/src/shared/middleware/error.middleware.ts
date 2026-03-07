import { Request, Response, NextFunction } from "express";
import { Prisma } from "@prisma/client";
import { AppError } from "../errors";
import { sendError } from "../utils/api-response";
import { HTTP_STATUS, ERROR_MESSAGES } from "../constants";
import { env } from "../../config/env";

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    sendError(res, err.message, err.statusCode);
    return;
  }

  // Prisma "record not found" → 404 or 401 depending on context
  if (
    err instanceof Prisma.PrismaClientKnownRequestError &&
    err.code === "P2025"
  ) {
    sendError(res, "Resource not found", HTTP_STATUS.NOT_FOUND);
    return;
  }

  // Log unexpected errors
  console.error("Unhandled Error:", err);

  sendError(
    res,
    env.IS_PRODUCTION ? ERROR_MESSAGES.INTERNAL_ERROR : err.message,
    HTTP_STATUS.INTERNAL_ERROR
  );
}
