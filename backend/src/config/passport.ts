import passport from "passport";
import {
  Strategy as GoogleStrategy,
  Profile as GoogleProfile,
} from "passport-google-oauth20";
import {
  Strategy as GitHubStrategy,
  Profile as GitHubProfile,
} from "passport-github2";
import { env } from "./env";
import { prisma } from "./database";
import { AuthProvider } from "@prisma/client";

// ── Serialization ──────────────────────────────────────────

passport.serializeUser((user: any, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const user = await prisma.user.findUnique({ where: { id } });
    done(null, user);
  } catch (err) {
    done(err, null);
  }
});

// ── Helper: Upsert OAuth user (single optimised query) ────

async function upsertOAuthUser(
  provider: AuthProvider,
  providerAccountId: string,
  email: string,
  name: string | null,
  avatarUrl: string | null,
  accessToken?: string,
  refreshToken?: string
) {
  // Single transaction: find-or-create user + link account
  return prisma.$transaction(async (tx) => {
    let user = await tx.user.findUnique({ where: { email } });

    if (!user) {
      user = await tx.user.create({
        data: {
          email,
          name,
          avatarUrl,
          emailVerified: true,
        },
      });
    }

    await tx.account.upsert({
      where: {
        provider_providerAccountId: { provider, providerAccountId },
      },
      update: { accessToken, refreshToken },
      create: {
        userId: user.id,
        provider,
        providerAccountId,
        accessToken,
        refreshToken,
      },
    });

    return user;
  });
}

// ── Google Strategy ────────────────────────────────────────

if (env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_SECRET) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: env.GOOGLE_CLIENT_ID,
        clientSecret: env.GOOGLE_CLIENT_SECRET,
        callbackURL: env.GOOGLE_CALLBACK_URL,
        scope: ["profile", "email"],
      },
      async (_accessToken, _refreshToken, profile: GoogleProfile, done) => {
        try {
          const email = profile.emails?.[0]?.value;
          if (!email) return done(new Error("No email from Google"), false);

          const user = await upsertOAuthUser(
            AuthProvider.GOOGLE,
            profile.id,
            email,
            profile.displayName,
            profile.photos?.[0]?.value ?? null,
            _accessToken,
            _refreshToken
          );

          done(null, user);
        } catch (err) {
          done(err as Error, false);
        }
      }
    )
  );
}

// ── GitHub Strategy ────────────────────────────────────────

if (env.GITHUB_CLIENT_ID && env.GITHUB_CLIENT_SECRET) {
  passport.use(
    new GitHubStrategy(
      {
        clientID: env.GITHUB_CLIENT_ID,
        clientSecret: env.GITHUB_CLIENT_SECRET,
        callbackURL: env.GITHUB_CALLBACK_URL,
        scope: ["user:email"],
      },
      async (
        _accessToken: string,
        _refreshToken: string,
        profile: GitHubProfile,
        done: (err: Error | null, user?: any) => void
      ) => {
        try {
          const email =
            profile.emails?.[0]?.value ?? `${profile.id}@github.questly.app`;

          const user = await upsertOAuthUser(
            AuthProvider.GITHUB,
            profile.id,
            email,
            profile.displayName ?? profile.username ?? null,
            profile.photos?.[0]?.value ?? null,
            _accessToken,
            _refreshToken
          );

          done(null, user);
        } catch (err) {
          done(err as Error);
        }
      }
    )
  );
}

export default passport;
