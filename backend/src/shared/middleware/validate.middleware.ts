import { Request, Response, NextFunction } from "express";
import { validationResult } from "express-validator";
import { HTTP_STATUS } from "../constants";
import { sendError } from "../utils/api-response";

export function validate(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    sendError(
      res,
      "Validation failed",
      HTTP_STATUS.UNPROCESSABLE,
      errors.array()
    );
    return;
  }
  next();
}
