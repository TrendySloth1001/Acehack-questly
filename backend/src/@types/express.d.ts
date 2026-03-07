import "express";

declare global {
  namespace Express {
    interface Request {
      currentUser?: import("../shared/utils/jwt").TokenPayload;
      file?: import("multer").File;
    }
  }
}
