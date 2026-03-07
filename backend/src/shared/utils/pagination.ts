import { PAGINATION } from "../constants";

export interface PaginationParams {
  page: number;
  limit: number;
  skip: number;
}

export function parsePagination(
  page?: string | number,
  limit?: string | number
): PaginationParams {
  const p = Math.max(1, Number(page) || PAGINATION.DEFAULT_PAGE);
  const l = Math.min(
    PAGINATION.MAX_LIMIT,
    Math.max(1, Number(limit) || PAGINATION.DEFAULT_LIMIT)
  );
  return { page: p, limit: l, skip: (p - 1) * l };
}

export function paginationMeta(total: number, page: number, limit: number) {
  return {
    page,
    limit,
    total,
    totalPages: Math.ceil(total / limit),
  };
}
