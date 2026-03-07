import { Response } from "express";
import { HTTP_STATUS } from "../constants";

interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

interface SuccessPayload<T> {
  res: Response;
  data?: T;
  message?: string;
  statusCode?: number;
  meta?: PaginationMeta;
}

export function sendSuccess<T>({
  res,
  data,
  message = "Success",
  statusCode = HTTP_STATUS.OK,
  meta,
}: SuccessPayload<T>): void {
  res.status(statusCode).json({
    success: true,
    message,
    data: data ?? null,
    ...(meta ? { meta } : {}),
  });
}

export function sendError(
  res: Response,
  message: string,
  statusCode: number = HTTP_STATUS.INTERNAL_ERROR,
  errors?: unknown
): void {
  res.status(statusCode).json({
    success: false,
    message,
    ...(errors ? { errors } : {}),
  });
}
