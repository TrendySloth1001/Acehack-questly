import { QuestStatus, Prisma } from "@prisma/client";
import { prisma } from "../../config/database";
import { NotFoundError } from "../../shared/errors";
import { ERROR_MESSAGES } from "../../shared/constants";
import {
  parsePagination,
  paginationMeta,
} from "../../shared/utils/pagination";

// ── DTOs ────────────────────────────────────────────────────

export interface CreateQuestDTO {
  title: string;
  description?: string;
  tasks?: { title: string; description?: string }[];
}

export interface UpdateQuestDTO {
  title?: string;
  description?: string;
  status?: QuestStatus;
}

export interface QuestFilters {
  status?: QuestStatus;
  search?: string;
  page?: string;
  limit?: string;
}

// ── Service ─────────────────────────────────────────────────

export class QuestService {
  /**
   * Create quest + nested tasks in ONE query (no N+1).
   */
  async create(userId: string, dto: CreateQuestDTO) {
    return prisma.quest.create({
      data: {
        title: dto.title,
        description: dto.description,
        userId,
        tasks: dto.tasks
          ? {
              create: dto.tasks.map((t, i) => ({
                title: t.title,
                description: t.description,
                order: i,
              })),
            }
          : undefined,
      },
      include: { tasks: { orderBy: { order: "asc" } } },
    });
  }

  /**
   * Paginated list with optional filters.
   * Uses a single parallel query for count + data.
   */
  async findAll(userId: string, filters: QuestFilters) {
    const { page, limit, skip } = parsePagination(filters.page, filters.limit);

    const where: Prisma.QuestWhereInput = { userId };

    if (filters.status) {
      where.status = filters.status;
    }
    if (filters.search) {
      where.OR = [
        { title: { contains: filters.search, mode: "insensitive" } },
        { description: { contains: filters.search, mode: "insensitive" } },
      ];
    }

    // Parallel count + find = 2 queries (not N+1)
    const [total, quests] = await prisma.$transaction([
      prisma.quest.count({ where }),
      prisma.quest.findMany({
        where,
        skip,
        take: limit,
        orderBy: { updatedAt: "desc" },
        include: {
          tasks: {
            orderBy: { order: "asc" },
            select: { id: true, title: true, isCompleted: true, order: true },
          },
          _count: { select: { tasks: true } },
        },
      }),
    ]);

    return { quests, meta: paginationMeta(total, page, limit) };
  }

  /**
   * Single quest with all tasks – 1 query with include.
   */
  async findById(userId: string, questId: string) {
    const quest = await prisma.quest.findFirst({
      where: { id: questId, userId },
      include: { tasks: { orderBy: { order: "asc" } } },
    });

    if (!quest) throw new NotFoundError(ERROR_MESSAGES.QUEST_NOT_FOUND);
    return quest;
  }

  /**
   * Update quest metadata.
   */
  async update(userId: string, questId: string, dto: UpdateQuestDTO) {
    await this.ensureOwnership(userId, questId);

    return prisma.quest.update({
      where: { id: questId },
      data: dto,
      include: { tasks: { orderBy: { order: "asc" } } },
    });
  }

  /**
   * Delete quest (cascades tasks via Prisma schema).
   */
  async delete(userId: string, questId: string) {
    await this.ensureOwnership(userId, questId);
    await prisma.quest.delete({ where: { id: questId } });
  }

  // ── Task operations ──────────────────────────────────────

  async addTask(userId: string, questId: string, title: string, description?: string) {
    await this.ensureOwnership(userId, questId);

    // Get max order in single query
    const maxOrder = await prisma.task.aggregate({
      where: { questId },
      _max: { order: true },
    });

    return prisma.task.create({
      data: {
        title,
        description,
        questId,
        order: (maxOrder._max.order ?? -1) + 1,
      },
    });
  }

  async updateTask(
    userId: string,
    questId: string,
    taskId: string,
    data: { title?: string; description?: string; isCompleted?: boolean; order?: number }
  ) {
    await this.ensureOwnership(userId, questId);

    const task = await prisma.task.findFirst({
      where: { id: taskId, questId },
      select: { id: true },
    });
    if (!task) throw new NotFoundError(ERROR_MESSAGES.TASK_NOT_FOUND);

    return prisma.task.update({ where: { id: taskId }, data });
  }

  async deleteTask(userId: string, questId: string, taskId: string) {
    await this.ensureOwnership(userId, questId);

    const task = await prisma.task.findFirst({
      where: { id: taskId, questId },
      select: { id: true },
    });
    if (!task) throw new NotFoundError(ERROR_MESSAGES.TASK_NOT_FOUND);

    await prisma.task.delete({ where: { id: taskId } });
  }

  // ── Private ──────────────────────────────────────────────

  private async ensureOwnership(userId: string, questId: string) {
    const quest = await prisma.quest.findFirst({
      where: { id: questId, userId },
      select: { id: true },
    });
    if (!quest) throw new NotFoundError(ERROR_MESSAGES.QUEST_NOT_FOUND);
  }
}

export const questService = new QuestService();
