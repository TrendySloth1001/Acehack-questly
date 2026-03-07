import { Request, Response } from "express";
import { questService } from "./quest.service";
import { sendSuccess } from "../../shared/utils/api-response";
import { HTTP_STATUS, SUCCESS_MESSAGES } from "../../shared/constants";
import { QuestStatus } from "@prisma/client";

export class QuestController {
  async create(req: Request, res: Response) {
    const quest = await questService.create(req.currentUser!.userId, req.body);
    sendSuccess({
      res,
      data: quest,
      message: SUCCESS_MESSAGES.QUEST_CREATED,
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async findAll(req: Request, res: Response) {
    const { quests, meta } = await questService.findAll(
      req.currentUser!.userId,
      {
        status: req.query.status as QuestStatus | undefined,
        search: req.query.search as string | undefined,
        page: req.query.page as string,
        limit: req.query.limit as string,
      }
    );
    sendSuccess({ res, data: quests, meta });
  }

  async findById(req: Request, res: Response) {
    const quest = await questService.findById(
      req.currentUser!.userId,
      req.params.questId as string
    );
    sendSuccess({ res, data: quest });
  }

  async update(req: Request, res: Response) {
    const quest = await questService.update(
      req.currentUser!.userId,
      req.params.questId as string,
      req.body
    );
    sendSuccess({ res, data: quest, message: SUCCESS_MESSAGES.QUEST_UPDATED });
  }

  async delete(req: Request, res: Response) {
    await questService.delete(req.currentUser!.userId, req.params.questId as string);
    sendSuccess({
      res,
      message: SUCCESS_MESSAGES.QUEST_DELETED,
      statusCode: HTTP_STATUS.OK,
    });
  }

  // ── Tasks ────────────────────────────────────────────────

  async addTask(req: Request, res: Response) {
    const task = await questService.addTask(
      req.currentUser!.userId,
      req.params.questId as string,
      req.body.title,
      req.body.description
    );
    sendSuccess({
      res,
      data: task,
      message: SUCCESS_MESSAGES.TASK_CREATED,
      statusCode: HTTP_STATUS.CREATED,
    });
  }

  async updateTask(req: Request, res: Response) {
    const task = await questService.updateTask(
      req.currentUser!.userId,
      req.params.questId as string,
      req.params.taskId as string,
      req.body
    );
    sendSuccess({ res, data: task, message: SUCCESS_MESSAGES.TASK_UPDATED });
  }

  async deleteTask(req: Request, res: Response) {
    await questService.deleteTask(
      req.currentUser!.userId,
      req.params.questId as string,
      req.params.taskId as string
    );
    sendSuccess({ res, message: SUCCESS_MESSAGES.TASK_DELETED });
  }
}

export const questController = new QuestController();
