/*
  Warnings:

  - You are about to drop the column `imageUrl` on the `bounties` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "bounties" DROP COLUMN "imageUrl",
ADD COLUMN     "imageUrls" TEXT[] DEFAULT ARRAY[]::TEXT[];
