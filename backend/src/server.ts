import app from "./app";
import { env, prisma, ensureBucket, getEscrowAddress } from "./config";
import { algorandService } from "./modules/algorand/algorand.service";

async function ensureEscrowFunded() {
  try {
    const escrowAddr = getEscrowAddress();
    const balance = await algorandService.getBalance(escrowAddr);
    if (balance.balanceAlgo < 1) {
      console.log(`⏳ Escrow balance low (${balance.balanceAlgo} ALGO), dispensing 100 ALGO from genesis...`);
      const result = await algorandService.dispense(escrowAddr, 100);
      console.log(`✅ Escrow funded: 100 ALGO → txId ${result.txId}`);
    } else {
      console.log(`✅ Escrow ready: ${balance.balanceAlgo} ALGO (${escrowAddr.slice(0, 8)}…)`);
    }
  } catch (err: any) {
    console.warn("⚠️  Could not fund escrow:", err.message ?? err);
  }
}

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

    // Ensure escrow wallet is funded (devmode only)
    if (env.ALGORAND_NETWORK === "devmode") {
      await ensureEscrowFunded();
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
