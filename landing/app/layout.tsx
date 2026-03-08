import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "Questly — Real-World Bounties, Real Rewards",
  description:
    "Questly is the Gen-Z bounty platform where you post tasks, earn crypto rewards, and build your reputation. Complete quests in your city and get paid.",
  keywords: [
    "bounty",
    "quests",
    "crypto",
    "rewards",
    "tasks",
    "gig economy",
    "algorand",
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={inter.variable}>
      <body>{children}</body>
    </html>
  );
}
