import Particles from "./components/Particles";
import SplitText from "./components/SplitText";
import Marquee from "./components/Marquee";
import Image from "next/image";

export default function Home() {
  return (
    <>
      {/* ── Background Particles ────────────────────────────── */}
      <Particles count={50} />

      {/* ── Navbar ──────────────────────────────────────────── */}
      <nav className="navbar">
        <div className="nav-logo">
          <Image
            src="/questly_logo.svg"
            alt="Questly"
            width={36}
            height={36}
          />
          <span>questly</span>
        </div>
        <div className="nav-links">
          <a href="#features">Features</a>
          <a href="#how">How it Works</a>
          <a href="#cta">Get Started</a>
        </div>
        <button className="nav-cta">Download App</button>
      </nav>

      {/* ── Hero ────────────────────────────────────────────── */}
      <section className="hero">
        <div className="hero-glow" />

        <div className="hero-badge">
          <span className="dot" />
          now live on algorand testnet
        </div>

        <h1>
          <SplitText text="complete quests." /> <br />
          <span className="gold">
            <SplitText text="earn real rewards." delayMs={30} />
          </span>
        </h1>

        <p className="hero-sub">
          The Gen-Z bounty platform where you post real-world tasks, claim
          bounties, and earn crypto — all powered by Algorand.
        </p>

        <div className="hero-actions">
          <button className="btn-primary">
            🚀 Start Questing
          </button>
          <button className="btn-ghost">
            Learn More ↓
          </button>
        </div>

        <div className="hero-stats">
          <div className="stat">
            <div className="stat-value">0</div>
            <div className="stat-label">Bounties Posted</div>
          </div>
          <div className="stat">
            <div className="stat-value">0</div>
            <div className="stat-label">ALGO Rewarded</div>
          </div>
          <div className="stat">
            <div className="stat-value">∞</div>
            <div className="stat-label">Possibilities</div>
          </div>
        </div>

        <div className="scroll-indicator">
          <span>scroll</span>
          <div className="scroll-line" />
        </div>
      </section>

      {/* ── Marquee Strip ───────────────────────────────────── */}
      <Marquee />

      {/* ── Features ────────────────────────────────────────── */}
      <section className="section" id="features">
        <div className="section-label">Features</div>
        <h2>
          everything you need to <br />
          <span className="shiny-text">quest & earn</span>
        </h2>
        <p className="section-desc">
          Post bounties for tasks you need done. Claim bounties to earn crypto.
          It&apos;s that simple.
        </p>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon">📍</div>
            <h3>Location-Based Tasks</h3>
            <p>
              Post bounties tied to real-world locations. Questers nearby can
              discover and claim tasks on the interactive map.
            </p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">💰</div>
            <h3>Crypto Rewards</h3>
            <p>
              Rewards are held in smart contract escrow. Once the bounty owner
              approves your work, payment is instant and trustless.
            </p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">⚡</div>
            <h3>XP & Rank System</h3>
            <p>
              Earn XP for every completed quest. Level up through Minecraft-style
              ranks from Wood to Obsidian and climb the leaderboard.
            </p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">🔒</div>
            <h3>Escrow Security</h3>
            <p>
              Funds are locked in Algorand smart contracts until work is
              verified. No trust required — code is law.
            </p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">📸</div>
            <h3>Proof of Work</h3>
            <p>
              Submit photos, documents, and notes as proof. Bounty owners review
              and approve right from the app.
            </p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">🎮</div>
            <h3>Gamified Experience</h3>
            <p>
              Streaks, achievements, star ratings, and a competitive leaderboard
              make every quest feel like a game.
            </p>
          </div>
        </div>
      </section>

      {/* ── How It Works ────────────────────────────────────── */}
      <section className="section" id="how">
        <div className="section-label">How It Works</div>
        <h2>
          three steps to <br />
          <span className="shiny-text">start earning</span>
        </h2>
        <p className="section-desc">
          Whether you&apos;re posting a task or completing one, Questly makes it
          dead simple.
        </p>

        <div className="steps">
          <div className="step-card">
            <div className="step-number">01</div>
            <h3>Post or Discover</h3>
            <p>
              Create a bounty with a description, reward amount, deadline, and
              location. Or explore the map to find tasks near you.
            </p>
          </div>

          <div className="step-card">
            <div className="step-number">02</div>
            <h3>Claim & Complete</h3>
            <p>
              Join a bounty, complete the task in the real world, and submit
              your proof — photos, documents, whatever it takes.
            </p>
          </div>

          <div className="step-card">
            <div className="step-number">03</div>
            <h3>Get Paid</h3>
            <p>
              Once the bounty owner approves your submission, the escrowed ALGO
              is released directly to your wallet. Done.
            </p>
          </div>
        </div>
      </section>

      {/* ── CTA ─────────────────────────────────────────────── */}
      <section className="cta-section" id="cta">
        <div className="cta-card">
          <h2>
            ready to start <span className="shiny-text">questing?</span>
          </h2>
          <p>
            Download Questly, fund your wallet, and start earning real crypto
            for real-world tasks. The future of gig economy is here.
          </p>
          <button className="btn-primary">
            🚀 Get Questly Now
          </button>
        </div>
      </section>

      {/* ── Footer ──────────────────────────────────────────── */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-logo">
            <Image
              src="/questly_logo.svg"
              alt="Questly"
              width={24}
              height={24}
            />
            <span>questly</span>
          </div>
          <p>© 2026 Questly. Built for the culture.</p>
          <div className="footer-links">
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
            <a href="#">GitHub</a>
          </div>
        </div>
      </footer>
    </>
  );
}
