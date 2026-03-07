import { PrismaClient, Role } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database...");

  const hashedPassword = await bcrypt.hash("admin123456", 12);

  const admin = await prisma.user.upsert({
    where: { email: "admin@questly.app" },
    update: {},
    create: {
      email: "admin@questly.app",
      name: "Admin",
      password: hashedPassword,
      role: Role.ADMIN,
      emailVerified: true,
    },
  });

  console.log(`✅ Admin user created: ${admin.email}`);

  const quest = await prisma.quest.upsert({
    where: { id: "seed-quest-1" },
    update: {},
    create: {
      id: "seed-quest-1",
      title: "Welcome to Questly",
      description: "Complete these tasks to get started!",
      status: "ACTIVE",
      userId: admin.id,
      tasks: {
        create: [
          { title: "Set up your profile", order: 0 },
          { title: "Create your first quest", order: 1 },
          { title: "Invite a friend", order: 2 },
        ],
      },
    },
  });

  console.log(`✅ Seed quest created: ${quest.title}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
