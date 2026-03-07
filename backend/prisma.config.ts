import path from "node:path";
import { defineConfig } from "prisma/config";
import { config } from "dotenv";

// Load .env before Prisma reads any env vars
config({ path: path.join(__dirname, ".env") });

export default defineConfig({
  earlyAccess: true,
  schema: path.join(__dirname, "prisma", "schema.prisma"),
  datasource: {
    url: process.env.DATABASE_URL!,
  },
});
