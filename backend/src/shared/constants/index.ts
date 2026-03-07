// ─── Questly Shared Constants ───
// Single source of truth for all magic values

export const APP = {
  NAME: "Questly",
  VERSION: "1.0.0",
  PACKAGE_NAME: "com.questly.app",
} as const;

export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_ERROR: 500,
} as const;

export const AUTH = {
  SALT_ROUNDS: 12,
  ACCESS_TOKEN_COOKIE: "questly_access_token",
  REFRESH_TOKEN_COOKIE: "questly_refresh_token",
  OAUTH_STATE_COOKIE: "questly_oauth_state",
  TOKEN_TYPE: "Bearer",
} as const;

export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
} as const;

export const UPLOAD = {
  MAX_FILE_SIZE: 10 * 1024 * 1024, // 10 MB
  ALLOWED_MIME_TYPES: [
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/gif",
    "application/pdf",
  ],
} as const;

export const ERROR_MESSAGES = {
  // Auth
  INVALID_CREDENTIALS: "Invalid email or password",
  EMAIL_ALREADY_EXISTS: "An account with this email already exists",
  TOKEN_EXPIRED: "Token has expired",
  TOKEN_INVALID: "Invalid token",
  UNAUTHORIZED: "You must be logged in to access this resource",
  FORBIDDEN: "You do not have permission to perform this action",
  OAUTH_FAILURE: "OAuth authentication failed",

  // General
  NOT_FOUND: "Resource not found",
  VALIDATION_ERROR: "Validation failed",
  INTERNAL_ERROR: "An unexpected error occurred",
  RATE_LIMIT: "Too many requests, please try again later",

  // Quest
  QUEST_NOT_FOUND: "Quest not found",
  TASK_NOT_FOUND: "Task not found",

  // Upload
  FILE_TOO_LARGE: "File exceeds maximum allowed size",
  INVALID_FILE_TYPE: "File type is not allowed",
  UPLOAD_FAILED: "File upload failed",
} as const;

export const SUCCESS_MESSAGES = {
  LOGIN: "Logged in successfully",
  LOGOUT: "Logged out successfully",
  REGISTER: "Account created successfully",
  TOKEN_REFRESHED: "Token refreshed successfully",
  QUEST_CREATED: "Quest created successfully",
  QUEST_UPDATED: "Quest updated successfully",
  QUEST_DELETED: "Quest deleted successfully",
  TASK_CREATED: "Task created successfully",
  TASK_UPDATED: "Task updated successfully",
  TASK_DELETED: "Task deleted successfully",
  UPLOAD_SUCCESS: "File uploaded successfully",
  UPLOAD_DELETED: "File deleted successfully",
} as const;
