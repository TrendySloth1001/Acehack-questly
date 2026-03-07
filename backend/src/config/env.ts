import dotenv from "dotenv";
dotenv.config();

function required(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

function optional(key: string, fallback: string): string {
  return process.env[key] ?? fallback;
}

export const env = {
  // App
  NODE_ENV: optional("NODE_ENV", "development"),
  PORT: parseInt(optional("PORT", "4000"), 10),
  API_PREFIX: optional("API_PREFIX", "/api/v1"),
  IS_PRODUCTION: process.env.NODE_ENV === "production",

  // Database
  DATABASE_URL: required("DATABASE_URL"),

  // JWT
  JWT_SECRET: required("JWT_SECRET"),
  JWT_EXPIRES_IN: optional("JWT_EXPIRES_IN", "7d"),
  JWT_REFRESH_SECRET: required("JWT_REFRESH_SECRET"),
  JWT_REFRESH_EXPIRES_IN: optional("JWT_REFRESH_EXPIRES_IN", "30d"),

  // OAuth – Google
  GOOGLE_CLIENT_ID: optional("GOOGLE_CLIENT_ID", ""),
  GOOGLE_CLIENT_SECRET: optional("GOOGLE_CLIENT_SECRET", ""),
  GOOGLE_CALLBACK_URL: optional(
    "GOOGLE_CALLBACK_URL",
    "http://localhost:3000/api/v1/auth/google/callback"
  ),

  // OAuth – GitHub
  GITHUB_CLIENT_ID: optional("GITHUB_CLIENT_ID", ""),
  GITHUB_CLIENT_SECRET: optional("GITHUB_CLIENT_SECRET", ""),
  GITHUB_CALLBACK_URL: optional(
    "GITHUB_CALLBACK_URL",
    "http://localhost:4000/api/v1/auth/github/callback"
  ),

  // MinIO
  MINIO_ENDPOINT: optional("MINIO_ENDPOINT", "localhost"),
  MINIO_PORT: parseInt(optional("MINIO_PORT", "9000"), 10),
  MINIO_ACCESS_KEY: optional("MINIO_ACCESS_KEY", "minioadmin"),
  MINIO_SECRET_KEY: optional("MINIO_SECRET_KEY", "minioadmin"),
  MINIO_USE_SSL: optional("MINIO_USE_SSL", "false") === "true",
  MINIO_BUCKET: optional("MINIO_BUCKET", "questly-uploads"),

  // Client
  CLIENT_URL: optional("CLIENT_URL", "http://localhost:3000"),

  // Public URL (tunnel / production base URL for file proxy)
  PUBLIC_URL: optional("PUBLIC_URL", ""),

  // Rate limit
  RATE_LIMIT_WINDOW_MS: parseInt(optional("RATE_LIMIT_WINDOW_MS", "900000"), 10),
  RATE_LIMIT_MAX: parseInt(optional("RATE_LIMIT_MAX", "100"), 10),

  // Algorand
  ALGORAND_NETWORK: optional("ALGORAND_NETWORK", "devmode"),
  ALGORAND_API_URL: optional(
    "ALGORAND_API_URL",
    "http://localhost:4001"
  ),
  ALGORAND_API_TOKEN: optional(
    "ALGORAND_API_TOKEN",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ),
  ALGORAND_KMD_URL: optional("ALGORAND_KMD_URL", "http://localhost:4002"),
  ALGORAND_KMD_TOKEN: optional(
    "ALGORAND_KMD_TOKEN",
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ),
  ALGORAND_INDEXER_URL: optional(
    "ALGORAND_INDEXER_URL",
    "https://testnet-idx.algonode.cloud"
  ),
  ALGORAND_ESCROW_MNEMONIC: optional("ALGORAND_ESCROW_MNEMONIC", ""),
} as const;
