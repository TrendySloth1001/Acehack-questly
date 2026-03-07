import { Request, Response } from "express";
import { bountyService } from "./bounty.service";
import { uploadService } from "../upload/upload.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS } from "../../shared/constants";
import { BadRequestError } from "../../shared/errors";

export class BountyController {
  async uploadImages(req: Request, res: Response) {
    const files = req.files as Express.Multer.File[] | undefined;
    if (!files || files.length === 0) {
      throw new BadRequestError("At least one image file is required");
    }

    const results = await Promise.all(
      files.map((file) =>
        uploadService.uploadFile({
          buffer: file.buffer,
          originalName: file.originalname,
          mimeType: file.mimetype,
          size: file.size,
          userId: req.currentUser!.userId,
        })
      )
    );

    sendSuccess({
      res,
      data: results.map((r) => ({ url: r.url, uploadId: r.id })),
      message: `${results.length} image(s) uploaded`,
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async create(req: Request, res: Response) {
    const bounty = await bountyService.create(req.currentUser!.userId, req.body);
    sendSuccess({
      res,
      data: bounty,
      message: "Bounty created",
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async list(req: Request, res: Response) {
    const q = req.query;
    const result = await bountyService.list({
      status: typeof q.status === "string" ? q.status : undefined,
      category: typeof q.category === "string" ? q.category : undefined,
      creatorId: typeof q.creatorId === "string" ? q.creatorId : undefined,
      page: typeof q.page === "string" ? Number(q.page) : undefined,
      limit: typeof q.limit === "string" ? Number(q.limit) : undefined,
    });
    sendSuccess({ res, data: result });
  }

  async getById(req: Request, res: Response) {
    const bounty = await bountyService.getById(req.params.id as string);
    sendSuccess({ res, data: bounty });
  }

  async update(req: Request, res: Response) {
    const bounty = await bountyService.update(
      req.params.id as string,
      req.currentUser!.userId,
      req.body
    );
    sendSuccess({ res, data: bounty, message: "Bounty updated" });
  }

  async delete(req: Request, res: Response) {
    await bountyService.delete(req.params.id as string, req.currentUser!.userId);
    sendSuccess({ res, message: "Bounty deleted" });
  }

  async claim(req: Request, res: Response) {
    const claim = await bountyService.claim(
      req.params.id as string,
      req.currentUser!.userId
    );
    sendSuccess({
      res,
      data: claim,
      message: "Bounty claimed",
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async submitProof(req: Request, res: Response) {
    const { proofUrls, note } = req.body;
    const claim = await bountyService.submitProof(
      req.params.claimId as string,
      req.currentUser!.userId,
      proofUrls,
      note
    );
    sendSuccess({ res, data: claim, message: "Proof submitted" });
  }

  async declaim(req: Request, res: Response) {
    await bountyService.declaim(
      req.params.claimId as string,
      req.currentUser!.userId
    );
    sendSuccess({ res, message: "Left the bounty" });
  }

  async resolveClaim(req: Request, res: Response) {
    const { action } = req.body as { action: "APPROVED" | "REJECTED" };
    const claim = await bountyService.resolveClaim(
      req.params.claimId as string,
      req.currentUser!.userId,
      action
    );
    sendSuccess({ res, data: claim, message: `Claim ${action.toLowerCase()}` });
  }

  async myClaims(req: Request, res: Response) {
    const claims = await bountyService.myClaims(req.currentUser!.userId);
    sendSuccess({ res, data: claims });
  }
}

export const bountyController = new BountyController();
