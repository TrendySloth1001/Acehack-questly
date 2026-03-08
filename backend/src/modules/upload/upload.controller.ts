import { Request, Response } from "express";
import { uploadService } from "./upload.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS, SUCCESS_MESSAGES, ERROR_MESSAGES } from "../../shared/constants";
import { BadRequestError } from "../../shared/errors";

export class UploadController {
  async upload(req: Request, res: Response) {
    // Express doesn't bundle multipart – raw body approach (see middleware for multer-free solution)
    if (!req.file) {
      throw new BadRequestError(ERROR_MESSAGES.UPLOAD_FAILED);
    }

    const result = await uploadService.uploadFile({
      buffer: req.file.buffer,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      userId: req.currentUser!.userId,
    });

    sendSuccess({
      res,
      data: result,
      message: SUCCESS_MESSAGES.UPLOAD_SUCCESS,
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async getPresignedUrl(req: Request, res: Response) {
    const url = await uploadService.getPresignedUrl(
      req.currentUser!.userId,
      req.params.uploadId as string
    );
    sendSuccess({ res, data: { url } });
  }

  async list(req: Request, res: Response) {
    const { uploads, meta } = await uploadService.listUploads(
      req.currentUser!.userId,
      req.query.page as string,
      req.query.limit as string
    );
    sendSuccess({ res, data: uploads, meta });
  }

  async delete(req: Request, res: Response) {
    await uploadService.deleteFile(
      req.currentUser!.userId,
      req.params.uploadId as string
    );
    sendSuccess({ res, message: SUCCESS_MESSAGES.UPLOAD_DELETED });
  }

  async uploadApk(req: Request, res: Response) {
    if (!req.file) {
      throw new BadRequestError(ERROR_MESSAGES.UPLOAD_FAILED);
    }

    const result = await uploadService.uploadApk({
      buffer: req.file.buffer,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      userId: req.currentUser!.userId,
    });

    sendSuccess({
      res,
      data: result,
      message: "APK uploaded successfully",
      statusCode: HTTP_STATUS.CREATED,
    });
  }
}

export const uploadController = new UploadController();
