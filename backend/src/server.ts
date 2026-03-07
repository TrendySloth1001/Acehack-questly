import app from "./app";
import { env, prisma, ensureBucket } from "./config";

async function bootstrap() {
  try {
    // Verify DB connection
    await prisma.$connect();
    console.log("✅ Database connected");

    // Ensure MinIO bucket
    try {
      await ensureBucket();
      console.log("✅ MinIO bucket ready");
    } catch {
      console.warn("⚠️  MinIO not available – file uploads disabled until connected");
    }

    app.listen(env.PORT, () => {
      console.log(`
╔══════════════════════════════════════════╗
║  🚀  Questly API                        ║
║  Environment : ${env.NODE_ENV.padEnd(24)}║
║  Port        : ${String(env.PORT).padEnd(24)}║
║  API         : ${env.API_PREFIX.padEnd(24)}║
╚══════════════════════════════════════════╝
      `);
    });
  } catch (err) {
    console.error("❌ Failed to start server:", err);
    process.exit(1);
  }
}

// Graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM received – shutting down...");
  await prisma.$disconnect();
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("SIGINT received – shutting down...");
  await prisma.$disconnect();
  process.exit(0);
});

bootstrap();
