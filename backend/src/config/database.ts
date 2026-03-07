import { PrismaClient } from "@prisma/client";
import { env } from "./env";

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    datasourceUrl: env.DATABASE_URL,
    log: env.IS_PRODUCTION ? ["error"] : ["query", "error", "warn"],
  } as any);

if (!env.IS_PRODUCTION) {
  globalForPrisma.prisma = prisma;
}
