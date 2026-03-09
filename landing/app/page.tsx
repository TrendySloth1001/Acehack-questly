import Particles from "./components/Particles";
import SplitText from "./components/SplitText";
import Marquee from "./components/Marquee";
import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <>
      <Particles count={20} />

      {/* ── Navbar ──────────────────────────────────────────── */}
      <nav className="navbar">
        <div className="nav-logo">
          <Image src="/questly_logo.svg" alt="Questly" width={36} height={36} />
          <span>questly</span>
        </div>
        <div className="nav-links">
          <a href="#features">Features</a>
          <a href="#how">How it Works</a>
          <a href="#xp">XP System</a>
          <a href="#tech">Tech Stack</a>
          <Link href="/docs">Docs</Link>
        </div>
        <div style={{display: 'flex', gap: '10px', alignItems: 'center'}}>
          <Link href="/download" className="nav-cta">Download</Link>
        </div>
      </nav>

      {/* ── Hero ────────────────────────────────────────────── */}
      <section className="hero">
        <div className="hero-glow" />
        <div className="hero-glow-secondary" />

        <div className="hero-badge">
          <span className="dot" />
          built on algorand blockchain
        </div>

        <h1>
          <SplitText text="complete quests." /> <br />
          <span className="accent-text">
            <SplitText text="earn real crypto." delayMs={30} />
          </span>
        </h1>

        <p className="hero-sub">
          The Web3 bounty platform where real-world tasks meet blockchain rewards. 
          Post bounties, claim quests, submit proof, and get paid in ALGO — 
          secured by escrow, powered by Algorand.
        </p>

        <div className="hero-actions">
          <Link href="/download" className="btn-primary" style={{textDecoration: 'none'}}>Download App</Link>
          <a href="#how" className="btn-ghost">See How It Works</a>
        </div>

        <div className="hero-stats">
          <div className="stat">
            <div className="stat-value">6</div>
            <div className="stat-label">Rank Tiers</div>
          </div>
          <div className="stat">
            <div className="stat-value">10+</div>
            <div className="stat-label">XP Actions</div>
          </div>
          <div className="stat">
            <div className="stat-value">&lt;4s</div>
            <div className="stat-label">Block Finality</div>
          </div>
        </div>

        <div className="scroll-indicator">
          <span>scroll</span>
          <div className="scroll-line" />
        </div>
      </section>

      <Marquee />

      {/* ── Features ────────────────────────────────────────── */}
      <section className="section" id="features">
        <div className="section-label">Features</div>
        <h2>
          everything you need to <br />
          <span className="shiny-text">quest &amp; earn</span>
        </h2>
        <p className="section-desc">
          A complete bounty ecosystem — from posting tasks to earning crypto, 
          with gamification, reviews, and on-chain verification baked in.
        </p>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
            </div>
            <h3>Location-Based Bounties</h3>
            <p>Post bounties tied to real-world locations. Questers nearby discover tasks on an interactive map with live geolocation.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10" /><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8" /><path d="M12 18V6" /></svg>
            </div>
            <h3>Algorand Escrow</h3>
            <p>ALGO rewards are locked in escrow on the Algorand blockchain. Funds release only when the bounty creator approves your submission.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></svg>
            </div>
            <h3>XP &amp; Rank System</h3>
            <p>Earn XP for completing quests, posting bounties, and receiving reviews. Climb from Wood to Netherite across 6 rank tiers using a sqrt progression curve.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>
            </div>
            <h3>Custodial Wallets</h3>
            <p>Auto-generated wallets for every user. No seed phrases to manage — your keys are secured server-side with seamless on-chain transactions.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" /><circle cx="12" cy="13" r="4" /></svg>
            </div>
            <h3>Photo Proof Submission</h3>
            <p>Upload photos, documents, and notes as proof of completion. MinIO object storage with secure URL proxying keeps files safe and accessible.</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" /></svg>
            </div>
            <h3>Reviews &amp; Reputation</h3>
            <p>Star ratings after every bounty. Your average rating is public — high stars earn bonus XP, low stars deduct. Reputation matters.</p>
          </div>
        </div>
      </section>

      <div className="section-divider" />

      {/* ── How It Works ────────────────────────────────────── */}
      <section className="section" id="how">
        <div className="section-label">How It Works</div>
        <h2>
          three steps to <br />
          <span className="shiny-text">start earning</span>
        </h2>
        <p className="section-desc">
          Whether you&apos;re posting a task or completing one, Questly makes it dead simple.
        </p>

        <div className="steps">
          <div className="step-card">
            <div className="step-number">01</div>
            <h3>Post or Discover</h3>
            <p>Create a bounty with a description, reward amount in ALGO, deadline, images, and optional location. Or explore the map and feed to find tasks that match your skills.</p>
          </div>

          <div className="step-card">
            <div className="step-number">02</div>
            <h3>Claim &amp; Complete</h3>
            <p>Join a bounty, complete the task in the real world, and submit your proof — photos, documents, notes. The creator reviews your submission and approves or requests changes.</p>
          </div>

          <div className="step-card">
            <div className="step-number">03</div>
            <h3>Get Paid in ALGO</h3>
            <p>Once approved, ALGO is released from the on-chain escrow directly to your wallet. You earn XP, your rating updates, and you climb the leaderboard. Done.</p>
          </div>
        </div>
      </section>

      <div className="section-divider" />

      {/* ── XP & Gamification ───────────────────────────────── */}
      <section className="section" id="xp">
        <div className="section-label">Gamification</div>
        <h2>
          level up with <br />
          <span className="shiny-text">XP &amp; ranks</span>
        </h2>
        <p className="section-desc">
          Every action earns or costs XP. Your level is calculated with a square-root 
          curve, and your rank reflects your standing in the community.
        </p>

        <div className="xp-grid">
          <div className="xp-card">
            <h4><svg className="inline-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></svg> Earn XP</h4>
            <table className="xp-table">
              <tbody>
                <tr><td>Complete a bounty</td><td className="xp-positive">+100 XP</td></tr>
                <tr><td>Post a bounty</td><td className="xp-positive">+20 XP</td></tr>
                <tr><td>Submit proof</td><td className="xp-positive">+10 XP</td></tr>
                <tr><td>Receive 5-star review</td><td className="xp-positive">+50 XP</td></tr>
                <tr><td>Receive 4-star review</td><td className="xp-positive">+25 XP</td></tr>
                <tr><td>Daily streak bonus</td><td className="xp-positive">+5 XP</td></tr>
              </tbody>
            </table>
          </div>

          <div className="xp-card">
            <h4><svg className="inline-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ff5c5c" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg> Lose XP</h4>
            <table className="xp-table">
              <tbody>
                <tr><td>Receive 1-star review</td><td className="xp-negative">-30 XP</td></tr>
                <tr><td>Receive 2-star review</td><td className="xp-negative">-15 XP</td></tr>
                <tr><td>Cancel after claim</td><td className="xp-negative">-20 XP</td></tr>
                <tr><td>Inactivity (3+ days)</td><td className="xp-negative">-10 XP/day</td></tr>
                <tr><td>3-star review</td><td style={{color: 'var(--text-muted)'}}>0 XP</td></tr>
                <tr><td>XP floor</td><td style={{color: 'var(--text-muted)'}}>min 0</td></tr>
              </tbody>
            </table>
          </div>
        </div>

        <h3 style={{marginTop: '40px', marginBottom: '16px', fontSize: '18px', fontWeight: 700, letterSpacing: '-0.3px'}}>
          Rank Tiers
        </h3>
        <div className="rank-grid">
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 19V5h2l4 5 4-5h2v14"/></svg></span>
            <div className="rank-name">Wood</div>
            <div className="rank-xp">0 XP</div>
          </div>
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="8" width="18" height="12" rx="2"/><path d="M7 8V6a5 5 0 0 1 10 0v2"/></svg></span>
            <div className="rank-name">Stone</div>
            <div className="rank-xp">500 XP</div>
          </div>
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></span>
            <div className="rank-name">Iron</div>
            <div className="rank-xp">1,500 XP</div>
          </div>
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg></span>
            <div className="rank-name">Gold</div>
            <div className="rank-xp">4,000 XP</div>
          </div>
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
            <div className="rank-name">Diamond</div>
            <div className="rank-xp">10,000 XP</div>
          </div>
          <div className="rank-item">
            <span className="rank-icon"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg></span>
            <div className="rank-name">Netherite</div>
            <div className="rank-xp">25,000 XP</div>
          </div>
        </div>
      </section>

      <div className="section-divider" />

      {/* ── Tech Stack ──────────────────────────────────────── */}
      <section className="section" id="tech">
        <div className="section-label">Tech Stack</div>
        <h2>
          built with <br />
          <span className="shiny-text">modern tools</span>
        </h2>
        <p className="section-desc">
          A full-stack mobile-first architecture with blockchain integration.
        </p>

        <div className="tech-grid">
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg></span>
            <h4>Flutter 3+</h4>
            <p>Cross-platform mobile app with Riverpod state management</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
            <h4>Node.js + Express</h4>
            <p>TypeScript REST API with modular service architecture</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg></span>
            <h4>PostgreSQL + Prisma</h4>
            <p>Type-safe ORM with migrations and composite indexes</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg></span>
            <h4>Algorand SDK</h4>
            <p>On-chain escrow, wallets, and payment verification</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
            <h4>Google OAuth 2.0</h4>
            <p>Firebase Auth + Passport.js with JWT sessions</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg></span>
            <h4>MinIO</h4>
            <p>S3-compatible object storage for image uploads</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 12H2"/><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"/><line x1="6" y1="16" x2="6.01" y2="16"/><line x1="10" y1="16" x2="10.01" y2="16"/></svg></span>
            <h4>Docker Compose</h4>
            <p>Full dev environment with algod, KMD, PostgreSQL, MinIO</p>
          </div>
          <div className="tech-card">
            <span className="tech-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg></span>
            <h4>Next.js 16</h4>
            <p>Landing page & docs with React Compiler</p>
          </div>
        </div>
      </section>

      <div className="section-divider" />

      {/* ── Architecture ────────────────────────────────────── */}
      <section className="section" id="arch">
        <div className="section-label">Architecture</div>
        <h2>
          system <br />
          <span className="shiny-text">architecture</span>
        </h2>
        <p className="section-desc">
          Clean layered architecture from mobile client to blockchain.
        </p>

        <div className="arch-diagram">
          <div className="arch-layers">
            <div className="arch-layer">
              <div className="arch-layer-label">Client</div>
              <div className="arch-layer-items">
                <span className="arch-chip">Flutter Mobile App</span>
                <span className="arch-chip">Riverpod State</span>
                <span className="arch-chip">Dio HTTP Client</span>
                <span className="arch-chip">GoRouter</span>
              </div>
            </div>
            <div className="arch-arrow">↕</div>
            <div className="arch-layer">
              <div className="arch-layer-label">API Layer</div>
              <div className="arch-layer-items">
                <span className="arch-chip">Express.js REST</span>
                <span className="arch-chip">JWT Auth</span>
                <span className="arch-chip">Validation</span>
                <span className="arch-chip">Error Handling</span>
              </div>
            </div>
            <div className="arch-arrow">↕</div>
            <div className="arch-layer">
              <div className="arch-layer-label">Services</div>
              <div className="arch-layer-items">
                <span className="arch-chip">Bounty Service</span>
                <span className="arch-chip">Algorand Service</span>
                <span className="arch-chip">Gamification</span>
                <span className="arch-chip">Review Service</span>
                <span className="arch-chip">Upload Service</span>
              </div>
            </div>
            <div className="arch-arrow">↕</div>
            <div className="arch-layer">
              <div className="arch-layer-label">Data</div>
              <div className="arch-layer-items">
                <span className="arch-chip">PostgreSQL</span>
                <span className="arch-chip">Prisma ORM</span>
                <span className="arch-chip">MinIO Storage</span>
              </div>
            </div>
            <div className="arch-arrow">↕</div>
            <div className="arch-layer">
              <div className="arch-layer-label">Blockchain</div>
              <div className="arch-layer-items">
                <span className="arch-chip">Algorand Devnet</span>
                <span className="arch-chip">algosdk v3</span>
                <span className="arch-chip">KMD (Key Mgmt)</span>
                <span className="arch-chip">Escrow Account</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── CTA ─────────────────────────────────────────────── */}
      <section className="cta-section" id="cta">
        <div className="cta-card">
          <div className="cta-logo">
            <Image src="/questly_logo.svg" alt="Questly" width={64} height={64} />
          </div>
          <h2>
            ready to start <span className="shiny-text">questing?</span>
          </h2>
          <p>
            Download Questly, fund your wallet, and start earning real 
            ALGO for real-world tasks. The future of gig economy is decentralized.
          </p>
          <div style={{display: 'flex', gap: '12px', justifyContent: 'center', flexWrap: 'wrap'}}>
            <Link href="/download" className="btn-primary" style={{textDecoration: 'none'}}>Download APK</Link>
            <Link href="/docs" className="btn-ghost">Read the Docs</Link>
            <a href="https://github.com/TrendySloth1001/Acehack-questly" target="_blank" rel="noopener noreferrer" className="btn-ghost">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
              GitHub
            </a>
          </div>
        </div>
      </section>

      {/* ── Team Credit ─────────────────────────────────────── */}
      <section className="team-credit">
        <p>Built by <strong>Abhinand Ajaya</strong> and <strong>Nikhil Kumawat</strong></p>
        <p className="team-name">Team Diamonds</p>
      </section>

      {/* ── Footer ──────────────────────────────────────────── */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-logo">
            <Image src="/questly_logo.svg" alt="Questly" width={24} height={24} />
            <span>questly</span>
          </div>
          <p>© 2026 Questly. Built on Algorand.</p>
          <div className="footer-links">
            <Link href="/docs">Documentation</Link>
            <Link href="/download">Download</Link>
            <a href="https://github.com/TrendySloth1001/Acehack-questly" target="_blank" rel="noopener noreferrer">GitHub</a>
          </div>
        </div>
      </footer>
    </>
  );
}
