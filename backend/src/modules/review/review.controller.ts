import { Request, Response } from "express";
import { reviewService } from "./review.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS } from "../../shared/constants";

export class ReviewController {
  async create(req: Request, res: Response) {
    const review = await reviewService.create(req.currentUser!.userId, req.body);
    sendSuccess({
      res,
      data: review,
      message: "Review submitted",
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async getForUser(req: Request, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result = await reviewService.getForUser(req.params.userId as string, page, limit);
    sendSuccess({ res, data: result });
  }

  async getForBounty(req: Request, res: Response) {
    const reviews = await reviewService.getForBounty(req.params.bountyId as string);
    sendSuccess({ res, data: reviews });
  }
}

export const reviewController = new ReviewController();
