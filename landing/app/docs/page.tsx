import Image from "next/image";
import Link from "next/link";

export const metadata = {
  title: "Questly Documentation — Architecture, Formulas & Technical Docs",
  description:
    "Comprehensive technical documentation for Questly: architecture, XP formulas, Algorand integration, escrow flow, and implementation details.",
};

export default function DocsPage() {
  return (
    <>
      {/* ── Navbar ──────────────────────────────────────────── */}
      <nav className="navbar">
        <div className="nav-logo">
          <span>questly</span>
        </div>
        <div className="nav-links">
          <Link href="/">Home</Link>
          <a href="#overview">Overview</a>
          <a href="#architecture">Architecture</a>
          <a href="#algorand">Algorand</a>
          <a href="#xp">XP System</a>
        </div>
        <Link href="/" className="nav-cta">← Back to Home</Link>
      </nav>

      {/* ── Docs Hero ───────────────────────────────────────── */}
      <section className="docs-hero">
        <div className="hero-badge">
          <span className="dot" />
          technical documentation
        </div>
        <h1>
          questly <span className="shiny-text">documentation</span>
        </h1>
        <p>
          A comprehensive guide to Questly&apos;s architecture, algorithms, 
          blockchain integration, and the engineering decisions behind them.
        </p>
      </section>

      {/* ── Docs Navigation ─────────────────────────────────── */}
      <nav className="docs-nav">
        <a href="#overview">Overview</a>
        <a href="#architecture">Architecture</a>
        <a href="#tech-stack">Tech Stack</a>
        <a href="#algorand">Algorand Integration</a>
        <a href="#escrow">Escrow Flow</a>
        <a href="#problems">Problems &amp; Solutions</a>
        <a href="#xp">XP &amp; Gamification</a>
        <a href="#formulas">Formulas</a>
        <a href="#database">Database Schema</a>
        <a href="#api">API Design</a>
      </nav>

      <div className="docs-content">

        {/* ═══ 01 — Overview ═══════════════════════════════════ */}
        <section className="docs-section" id="overview">
          <h2>
            <span className="section-num">01</span>
            Overview
          </h2>
          <p>
            Questly is a Web3 bounty platform that connects real-world tasks with 
            cryptocurrency rewards on the Algorand blockchain. Users post bounties — 
            location-based micro-tasks with ALGO rewards — and questers discover, 
            claim, complete, and submit proof for on-chain payment. The platform 
            includes a full gamification engine with XP, levels, ranks, reviews, 
            and dispute resolution.
          </p>

          <div className="docs-grid-2">
            <div className="docs-card">
              <h4>For Bounty Creators</h4>
              <ul>
                <li>Post tasks with ALGO rewards, deadlines, and locations</li>
                <li>ALGO is locked in escrow until you approve the work</li>
                <li>Review claimers with star ratings</li>
                <li>Full refund if no one completes the task</li>
              </ul>
            </div>
            <div className="docs-card">
              <h4>For Questers</h4>
              <ul>
                <li>Discover bounties on a map or browse the feed</li>
                <li>Claim a bounty, complete the task, submit proof</li>
                <li>Get paid in ALGO upon approval</li>
                <li>Earn XP and climb the rank leaderboard</li>
              </ul>
            </div>
          </div>
        </section>

        {/* ═══ 02 — Architecture ═══════════════════════════════ */}
        <section className="docs-section" id="architecture">
          <h2>
            <span className="section-num">02</span>
            Architecture
          </h2>
          <p>
            Questly follows a clean layered architecture with strict separation of 
            concerns. The mobile client communicates exclusively through a REST API, 
            which delegates to modular service layers. The blockchain layer is 
            abstracted behind a service interface.
          </p>

          <div className="arch-diagram">
            <div className="arch-layers">
              <div className="arch-layer">
                <div className="arch-layer-label">Presentation</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Flutter 3+ Mobile App</span>
                  <span className="arch-chip">Riverpod State Management</span>
                  <span className="arch-chip">GoRouter Navigation</span>
                  <span className="arch-chip">Dio HTTP Client</span>
                </div>
              </div>
              <div className="arch-arrow">↕</div>
              <div className="arch-layer">
                <div className="arch-layer-label">API Gateway</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Express.js 4</span>
                  <span className="arch-chip">JWT Bearer Auth</span>
                  <span className="arch-chip">Request Validation</span>
                  <span className="arch-chip">Error Middleware</span>
                  <span className="arch-chip">Rate Limiting</span>
                </div>
              </div>
              <div className="arch-arrow">↕</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Services</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Auth Service</span>
                  <span className="arch-chip">Bounty Service</span>
                  <span className="arch-chip">Algorand Service</span>
                  <span className="arch-chip">Gamification Service</span>
                  <span className="arch-chip">Review Service</span>
                  <span className="arch-chip">Upload Service</span>
                </div>
              </div>
              <div className="arch-arrow">↕</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Persistence</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">PostgreSQL 15</span>
                  <span className="arch-chip">Prisma ORM</span>
                  <span className="arch-chip">MinIO (S3-compat)</span>
                </div>
              </div>
              <div className="arch-arrow">↕</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Blockchain</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Algorand DevNet</span>
                  <span className="arch-chip">algosdk v3</span>
                  <span className="arch-chip">KMD (Key Mgmt Daemon)</span>
                  <span className="arch-chip">Escrow Wallet</span>
                </div>
              </div>
            </div>
          </div>

          <h3>Module Structure</h3>
          <p>
            The backend follows a modular architecture where each domain feature 
            is isolated in its own module with dedicated controller, service, and 
            route files:
          </p>

          <div className="code-block">
{`backend/src/
├── modules/
│   ├── algorand/        `}<span className="comment"># Blockchain integration</span>{`
│   │   ├── algorand.controller.ts
│   │   ├── algorand.service.ts
│   │   └── algorand.routes.ts
│   ├── auth/            `}<span className="comment"># OAuth + JWT authentication</span>{`
│   ├── bounty/          `}<span className="comment"># Core bounty CRUD & lifecycle</span>{`
│   ├── gamification/    `}<span className="comment"># XP, levels, ranks, leaderboard</span>{`
│   ├── review/          `}<span className="comment"># Star ratings & reputation</span>{`
│   ├── quest/           `}<span className="comment"># Task management</span>{`
│   └── upload/          `}<span className="comment"># MinIO file handling</span>{`
├── shared/
│   ├── middleware/       `}<span className="comment"># Auth guards, error handler</span>{`
│   ├── errors/          `}<span className="comment"># Custom error classes</span>{`
│   └── utils/           `}<span className="comment"># Helpers, validators</span>{`
├── config/              `}<span className="comment"># Env, DB, Algorand, MinIO</span>{`
├── app.ts               `}<span className="comment"># Express app setup</span>{`
├── routes.ts            `}<span className="comment"># Route aggregation</span>{`
└── server.ts            `}<span className="comment"># HTTP server bootstrap</span>
          </div>
        </section>

        {/* ═══ 03 — Tech Stack ═════════════════════════════════ */}
        <section className="docs-section" id="tech-stack">
          <h2>
            <span className="section-num">03</span>
            Tech Stack Integration
          </h2>
          <p>
            The technology choices were made for developer velocity, type safety, 
            and seamless blockchain integration within a hackathon timeline.
          </p>

          <table className="docs-table">
            <thead>
              <tr>
                <th>Layer</th>
                <th>Technology</th>
                <th>Purpose</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Mobile App</td>
                <td>Flutter 3+ / Dart</td>
                <td>Cross-platform iOS + Android from single codebase</td>
              </tr>
              <tr>
                <td>State Management</td>
                <td>Riverpod</td>
                <td>Reactive state with dependency injection and providers</td>
              </tr>
              <tr>
                <td>Navigation</td>
                <td>GoRouter</td>
                <td>Declarative routing with deep link support</td>
              </tr>
              <tr>
                <td>HTTP Client</td>
                <td>Dio</td>
                <td>Interceptors for auth token injection and refresh</td>
              </tr>
              <tr>
                <td>Backend API</td>
                <td>Node.js + Express</td>
                <td>TypeScript REST API with modular controller/service pattern</td>
              </tr>
              <tr>
                <td>ORM</td>
                <td>Prisma</td>
                <td>Type-safe database access with migrations and raw SQL</td>
              </tr>
              <tr>
                <td>Database</td>
                <td>PostgreSQL 15</td>
                <td>Relational data with composite indexes for performance</td>
              </tr>
              <tr>
                <td>Authentication</td>
                <td>Google OAuth 2.0 + JWT</td>
                <td>Firebase Auth on mobile, Passport.js + JWT on backend</td>
              </tr>
              <tr>
                <td>Blockchain</td>
                <td>Algorand (algosdk v3)</td>
                <td>Wallet generation, escrow transactions, payment verification</td>
              </tr>
              <tr>
                <td>Key Management</td>
                <td>KMD (Algorand)</td>
                <td>Dev faucet funding via genesis account</td>
              </tr>
              <tr>
                <td>Object Storage</td>
                <td>MinIO</td>
                <td>S3-compatible image upload for bounty proofs</td>
              </tr>
              <tr>
                <td>DevOps</td>
                <td>Docker Compose</td>
                <td>Full local environment: DB, algod, KMD, MinIO</td>
              </tr>
              <tr>
                <td>Landing Page</td>
                <td>Next.js 16 + React 19</td>
                <td>SSR marketing site with React Compiler</td>
              </tr>
            </tbody>
          </table>
        </section>

        {/* ═══ 04 — Algorand Integration ═══════════════════════ */}
        <section className="docs-section" id="algorand">
          <h2>
            <span className="section-num">04</span>
            Algorand Integration
          </h2>
          <p>
            Questly uses a custodial wallet model where the server generates and 
            manages Algorand wallets for each user. This was a deliberate pivot 
            from a non-custodial WalletConnect approach to eliminate mobile SDK 
            friction during the hackathon.
          </p>

          <h3>Wallet Generation</h3>
          <p>
            When a user signs up, the backend generates an Algorand keypair and 
            stores the wallet address and mnemonic in the database:
          </p>

          <div className="code-block">
{`const account = algosdk.generateAccount();
const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
`}<span className="comment">{"// → { address: \"ALGO...\", mnemonic: \"word1 word2 ... word25\" }"}</span>
          </div>

          <h3>Key Constants</h3>
          <div className="code-block">
{`const MICROALGOS_PER_ALGO = 1_000_000;  `}<span className="comment">// 1 ALGO = 1,000,000 microAlgos</span>{`
const MIN_TXN_FEE = 1_000;              `}<span className="comment">// 0.001 ALGO minimum transaction fee</span>{`
const MIN_BALANCE = 100_000;             `}<span className="comment">// 0.1 ALGO minimum account balance</span>
          </div>

          <h3>Transaction Verification</h3>
          <p>
            After a transaction is submitted, <code>verifyFunding()</code> performs 
            three on-chain checks:
          </p>
          <div className="docs-card">
            <ul>
              <li><strong>Confirmation check:</strong> <code>confirmedRound &gt; 0</code> — transaction is actually on-chain</li>
              <li><strong>Receiver check:</strong> receiver matches the escrow wallet address</li>
              <li><strong>Amount check:</strong> actual payment ≥ expected amount (in microAlgos)</li>
            </ul>
            <p style={{marginTop: '12px', fontSize: '13px', color: 'var(--text-muted)'}}>
              All three conditions must be true for verification to pass. Failures 
              return <code>{"{ verified: false }"}</code> instead of throwing.
            </p>
          </div>
        </section>

        {/* ═══ 05 — Escrow Flow ════════════════════════════════ */}
        <section className="docs-section" id="escrow">
          <h2>
            <span className="section-num">05</span>
            Escrow Flow
          </h2>
          <p>
            The escrow system ensures trustless payments — creators lock ALGO 
            in escrow, and funds only move when work is approved or refunded.
          </p>

          <h3>Lifecycle</h3>
          <div className="arch-diagram" style={{marginBottom: '24px'}}>
            <div className="arch-layers">
              <div className="arch-layer">
                <div className="arch-layer-label">Step 1</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Creator posts bounty → ALGO locked in escrow wallet</span>
                </div>
              </div>
              <div className="arch-arrow">↓</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Step 2</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Quester claims → status: FUNDED | CLAIMED</span>
                </div>
              </div>
              <div className="arch-arrow">↓</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Step 3</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">Quester submits proof → status: IN_REVIEW</span>
                </div>
              </div>
              <div className="arch-arrow">↓</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Step 4a</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">[approved] Creator approves &rarr; ALGO released to quester &rarr; RELEASED</span>
                </div>
              </div>
              <div className="arch-arrow" style={{color: '#ff5c5c', opacity: 0.6}}>or</div>
              <div className="arch-layer">
                <div className="arch-layer-label">Step 4b</div>
                <div className="arch-layer-items">
                  <span className="arch-chip">[rejected] Creator rejects / cancels &rarr; ALGO refunded to creator &rarr; REFUNDED</span>
                </div>
              </div>
            </div>
          </div>

          <h3>Escrow Statuses</h3>
          <table className="docs-table">
            <thead>
              <tr>
                <th>Status</th>
                <th>Description</th>
                <th>Transition</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>UNFUNDED</td>
                <td>Bounty created, no ALGO deposited yet</td>
                <td>→ FUNDED</td>
              </tr>
              <tr>
                <td>FUNDED</td>
                <td>ALGO locked in escrow, awaiting claim + completion</td>
                <td>→ RELEASED or REFUNDED</td>
              </tr>
              <tr>
                <td>RELEASED</td>
                <td>ALGO sent to quester's wallet</td>
                <td>Terminal state</td>
              </tr>
              <tr>
                <td>REFUNDED</td>
                <td>ALGO returned to creator's wallet</td>
                <td>Terminal state</td>
              </tr>
            </tbody>
          </table>

          <h3>Fee Handling</h3>
          <p>
            Both release and refund operations subtract the Algorand minimum 
            transaction fee (0.001 ALGO) from the payout. A three-layer balance 
            check ensures sufficient spendable funds:
          </p>
          <div className="code-block">
{`spendable = totalBalance - minBalance  `}<span className="comment">// 0.1 ALGO reserve</span>{`
netPayout = amountAlgo - MIN_TXN_FEE   `}<span className="comment">// subtract 0.001 ALGO fee</span>{`

`}<span className="keyword">if</span>{` (netPayout <= 0) `}<span className="keyword">throw</span>{` "Amount too small after fees"
`}<span className="keyword">if</span>{` (spendable < amountAlgo) `}<span className="keyword">throw</span>{` "Insufficient escrow balance"`}
          </div>
        </section>

        {/* ═══ 06 — Problems & Solutions ═══════════════════════ */}
        <section className="docs-section" id="problems">
          <h2>
            <span className="section-num">06</span>
            Problems Faced &amp; Solutions
          </h2>
          <p>
            Throughout development, we encountered several critical challenges, 
            particularly around blockchain integration. Here&apos;s how each was 
            identified and resolved.
          </p>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Custodial vs Non-Custodial Wallet Pivot</h4>
            <p>
              The original design used WalletConnect and Pera Wallet for a 
              non-custodial experience. However, the Pera Wallet Flutter SDK had 
              broken deep-link callbacks and WalletConnect v2 lacked stable Algorand 
              mobile support. The mobile app couldn&apos;t reliably sign transactions.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Pivoted to a custodial model — the server generates and holds wallet 
              mnemonics. The trade-off: users don&apos;t control their own keys, but the 
              UX is seamless. The code was refactored in a single session (noted with 
              a &quot;root cause fix&quot; comment), replacing all WalletConnect flows 
              with server-side signing via <code>algosdk.mnemonicToSecretKey()</code>.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Algorand Minimum Balance Trap</h4>
            <p>
              Algorand requires every account to maintain a 0.1 ALGO minimum balance. 
              When the escrow wallet tried to release the full amount, algod would 
              reject the transaction with an opaque error — no clear &quot;insufficient 
              balance&quot; message, just a raw protocol rejection.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Implemented a 3-layer balance check: (1) fetch account info from algod, 
              (2) compute <code>spendable = total - minBalance</code>, (3) validate 
              amount after subtracting <code>MIN_TXN_FEE</code>. The service now 
              returns descriptive error messages like &quot;Escrow balance is X ALGO, 
              spendable is Y ALGO, but you requested Z ALGO.&quot;
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Transaction Fee Accounting</h4>
            <p>
              Initially, the release/refund logic sent the exact bounty amount. 
              But Algorand charges a 0.001 ALGO fee per transaction, causing the 
              escrow to hemorrhage microAlgos and eventually fail with insufficient 
              funds for subsequent operations.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Both <code>releasePayment()</code> and <code>refundCreator()</code> now 
              subtract <code>MIN_TXN_FEE</code> (1,000 microAlgos) from the payout 
              amount before signing. An additional guard rejects payouts where the 
              net amount would be ≤ 0.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>DevMode-Only Faucet (KMD Dependency)</h4>
            <p>
              The <code>dispense()</code> function uses KMD to access the genesis 
              account for funding test wallets. KMD is only available in Algorand 
              devmode — there is no mainnet/testnet faucet integration, making the 
              funding flow non-portable.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Accepted the limitation for hackathon scope. Added environment-gated 
              logic so the faucet endpoint is only registered in development. The 
              KMD wallet handle is always released in a <code>try/finally</code> 
              block to prevent handle leaks. Production would require integrating 
              the Algorand Dispenser API or on-ramp service.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Transaction Verification Complexity</h4>
            <p>
              algosdk v3 returns deeply nested typed structures for confirmed 
              transactions. Extracting the receiver address and amount required 
              navigating through <code>txn.txn.payment</code> objects with 
              non-obvious property names, and the TypeScript types didn&apos;t 
              always match runtime shapes.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              The <code>verifyFunding()</code> method wraps the entire verification 
              in a <code>try/catch</code> that returns <code>{"{ verified: false }"}</code> 
              on any error rather than throwing. This prevents partial verification 
              failures from crashing the payment flow.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Mnemonic Storage Security</h4>
            <p>
              The Prisma schema declares <code>walletMnemonic</code> with a comment 
              &quot;encrypted at rest,&quot; but no encryption layer was implemented. 
              Mnemonics are stored as plaintext strings in PostgreSQL.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Acknowledged as a known gap for hackathon scope. The recommended 
              production fix: add AES-256-GCM encryption using a KMS-derived key, 
              decrypt only at transaction-signing time, and purge decrypted material 
              from memory immediately.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Schema Evolution Under Pressure</h4>
            <p>
              Wallet fields (<code>walletAddress</code>, <code>walletMnemonic</code>), 
              multi-image support (<code>imageUrls[]</code>), and gamification tables 
              were added mid-hackathon across 9 sequential migrations. The 
              <code>algoAmount</code> field used <code>Float</code> for financial data 
              instead of <code>Decimal</code>.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Adopted an incremental migration strategy rather than squashing. Each 
              schema change is a separate atomic migration. The Float precision issue 
              is acceptable for the hackathon since ALGO amounts are small, but 
              production should use <code>Decimal</code> or integer microAlgos.
            </p>
          </div>

          <div className="problem-card">
            <span className="problem-label problem">Problem</span>
            <h4>Wallet Generation Timing</h4>
            <p>
              There&apos;s a chicken-and-egg problem: the user record is created 
              during OAuth callback, but the wallet generation is async and depends 
              on Algorand node availability. If algod is down, the user is created 
              without a wallet, causing downstream failures when they try to post 
              or claim bounties.
            </p>
            <span className="problem-label solution">Solution</span>
            <p>
              Wallet generation happens inline during user creation with error 
              handling that allows the user to exist without a wallet. The frontend 
              checks <code>walletAddress</code> before showing bounty-related 
              actions, and wallet creation can be retried via a dedicated endpoint.
            </p>
          </div>
        </section>

        {/* ═══ 07 — XP & Gamification ══════════════════════════ */}
        <section className="docs-section" id="xp">
          <h2>
            <span className="section-num">07</span>
            XP &amp; Gamification System
          </h2>
          <p>
            The gamification engine tracks experience points (XP), calculates 
            levels using a mathematical curve, and assigns Minecraft-themed 
            rank tiers. All XP operations are atomic SQL updates to prevent 
            race conditions.
          </p>

          <h3>XP Awards &amp; Penalties</h3>
          <table className="docs-table">
            <thead>
              <tr>
                <th>Action</th>
                <th>XP Change</th>
                <th>Constant Name</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Complete a bounty</td>
                <td className="mono positive">+100</td>
                <td className="mono">COMPLETE_BOUNTY</td>
              </tr>
              <tr>
                <td>Post a bounty</td>
                <td className="mono positive">+20</td>
                <td className="mono">POST_BOUNTY</td>
              </tr>
              <tr>
                <td>Submit proof</td>
                <td className="mono positive">+10</td>
                <td className="mono">SUBMIT_PROOF</td>
              </tr>
              <tr>
                <td>Receive 5-star review</td>
                <td className="mono positive">+50</td>
                <td className="mono">REVIEW_5_STAR</td>
              </tr>
              <tr>
                <td>Receive 4-star review</td>
                <td className="mono positive">+25</td>
                <td className="mono">REVIEW_4_STAR</td>
              </tr>
              <tr>
                <td>Daily streak bonus</td>
                <td className="mono positive">+5</td>
                <td className="mono">DAILY_STREAK</td>
              </tr>
              <tr>
                <td>Receive 3-star review</td>
                <td className="mono">0</td>
                <td className="mono">—</td>
              </tr>
              <tr>
                <td>Receive 2-star review</td>
                <td className="mono negative">-15</td>
                <td className="mono">REVIEW_2_STAR</td>
              </tr>
              <tr>
                <td>Receive 1-star review</td>
                <td className="mono negative">-30</td>
                <td className="mono">REVIEW_1_STAR</td>
              </tr>
              <tr>
                <td>Cancel after claim</td>
                <td className="mono negative">-20</td>
                <td className="mono">CANCEL_AFTER_CLAIM</td>
              </tr>
              <tr>
                <td>Inactivity (3+ days)</td>
                <td className="mono negative">-10/day</td>
                <td className="mono">INACTIVE_DECAY</td>
              </tr>
            </tbody>
          </table>

          <p>
            XP is clamped to a floor of 0 using <code>GREATEST(0, ...)</code> 
            in the raw SQL update. Negative XP is impossible.
          </p>

          <h3>Rank Tiers</h3>
          <p>
            Ranks use a Minecraft-inspired naming convention. The rank is 
            determined by iterating the table top-down — the first tier where 
            the user&apos;s XP meets the threshold wins.
          </p>

          <table className="docs-table">
            <thead>
              <tr>
                <th>Rank</th>
                <th>Min XP</th>
                <th>Min Level</th>
                <th>Badge</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Wood</td><td className="mono">0</td><td className="mono">0</td><td>I</td></tr>
              <tr><td>Stone</td><td className="mono">500</td><td className="mono">5</td><td>II</td></tr>
              <tr><td>Iron</td><td className="mono">1,500</td><td className="mono">10</td><td>III</td></tr>
              <tr><td>Gold</td><td className="mono">4,000</td><td className="mono">20</td><td>IV</td></tr>
              <tr><td>Diamond</td><td className="mono">10,000</td><td className="mono">35</td><td>V</td></tr>
              <tr><td>Netherite</td><td className="mono">25,000</td><td className="mono">50</td><td>VI</td></tr>
            </tbody>
          </table>

          <h3>Decay System</h3>
          <div className="docs-card">
            <p>
              Users with XP &gt; 0 and <code>lastActiveAt &lt; NOW() - 3 days</code> 
              are subject to inactive decay. The <code>processDecay()</code> method 
              runs a bulk SQL update that subtracts 10 XP per execution from all 
              qualifying users and recalculates their level atomically.
            </p>
          </div>

          <h3>Leaderboard</h3>
          <div className="docs-card">
            <p>
              The top-50 users by XP descending are cached in-memory using 
              a <code>Map&lt;string, CacheEntry&gt;</code> with a 60-second TTL. 
              This prevents excessive database reads on a frequently-polled 
              endpoint.
            </p>
          </div>
        </section>

        {/* ═══ 08 — Formulas ═══════════════════════════════════ */}
        <section className="docs-section" id="formulas">
          <h2>
            <span className="section-num">08</span>
            Mathematical Formulas
          </h2>
          <p>
            The core progression system uses a square-root curve to create 
            diminishing returns — early levels come quickly, but reaching 
            the highest ranks requires exponentially more XP.
          </p>

          <div className="formula-block">
            <div className="formula">level = ⌊√(xp / 25)⌋</div>
            <div className="formula-desc">XP to Level conversion — square root curve with divisor of 25</div>
          </div>

          <div className="formula-block">
            <div className="formula">xp_required = level² × 25</div>
            <div className="formula-desc">Level to XP — inverse formula to calculate XP needed for next level</div>
          </div>

          <h3>Progression Examples</h3>
          <table className="docs-table">
            <thead>
              <tr>
                <th>XP</th>
                <th>Level</th>
                <th>Rank</th>
                <th>Bounties to Reach*</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="mono">0</td>
                <td className="mono">0</td>
                <td>Wood</td>
                <td>—</td>
              </tr>
              <tr>
                <td className="mono">25</td>
                <td className="mono">1</td>
                <td>Wood</td>
                <td>~1 bounty</td>
              </tr>
              <tr>
                <td className="mono">100</td>
                <td className="mono">2</td>
                <td>Wood</td>
                <td>1 bounty</td>
              </tr>
              <tr>
                <td className="mono">500</td>
                <td className="mono">4</td>
                <td>Stone</td>
                <td>5 bounties</td>
              </tr>
              <tr>
                <td className="mono">1,500</td>
                <td className="mono">7</td>
                <td>Iron</td>
                <td>15 bounties</td>
              </tr>
              <tr>
                <td className="mono">4,000</td>
                <td className="mono">12</td>
                <td>Gold</td>
                <td>40 bounties</td>
              </tr>
              <tr>
                <td className="mono">10,000</td>
                <td className="mono">20</td>
                <td>Diamond</td>
                <td>100 bounties</td>
              </tr>
              <tr>
                <td className="mono">25,000</td>
                <td className="mono">31</td>
                <td>Netherite</td>
                <td>250 bounties</td>
              </tr>
            </tbody>
          </table>
          <p style={{fontSize: '12px', color: 'var(--text-muted)', marginTop: '8px'}}>
            * Approximate — assumes +100 XP per completed bounty with no reviews or penalties.
          </p>

          <h3>Implementation Detail</h3>
          <div className="code-block">
<span className="comment">// Atomic XP update — single SQL statement, no race conditions</span>{`
`}<span className="keyword">UPDATE</span>{` users
`}<span className="keyword">SET</span>{`
  xp = `}<span className="keyword">GREATEST</span>{`(0, xp + $amount),
  level = `}<span className="keyword">FLOOR</span>{`(`}<span className="keyword">SQRT</span>{`(`}<span className="keyword">GREATEST</span>{`(0, xp + $amount) / 25)),
  "lastActiveAt" = `}<span className="keyword">NOW</span>{`()
`}<span className="keyword">WHERE</span>{` id = $userId
`}<span className="keyword">RETURNING</span>{` xp, level;`}
          </div>
        </section>

        {/* ═══ 09 — Database Schema ════════════════════════════ */}
        <section className="docs-section" id="database">
          <h2>
            <span className="section-num">09</span>
            Database Schema
          </h2>
          <p>
            PostgreSQL with Prisma ORM. The schema evolved through 9 sequential 
            migrations, adding wallet fields, gamification tables, multi-image 
            support, and composite indexes for performance.
          </p>

          <h3>Core Models</h3>
          <table className="docs-table">
            <thead>
              <tr>
                <th>Model</th>
                <th>Table</th>
                <th>Key Fields</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>User</td>
                <td className="mono">users</td>
                <td>email, walletAddress, walletMnemonic, xp, level, avgRating</td>
              </tr>
              <tr>
                <td>Bounty</td>
                <td className="mono">bounties</td>
                <td>title, algoAmount, status, escrowStatus, lat/lng, imageUrls[]</td>
              </tr>
              <tr>
                <td>BountyClaim</td>
                <td className="mono">bounty_claims</td>
                <td>bountyId, claimerId, status, proofUrl, paymentTxId</td>
              </tr>
              <tr>
                <td>WalletTransaction</td>
                <td className="mono">wallet_transactions</td>
                <td>userId, type (DEBIT/CREDIT), amountAlgo, txId</td>
              </tr>
              <tr>
                <td>Review</td>
                <td className="mono">reviews</td>
                <td>reviewerId, revieweeId, bountyId, stars (1-5)</td>
              </tr>
              <tr>
                <td>Dispute</td>
                <td className="mono">disputes</td>
                <td>claimId, raisedById, reason, status, resolution</td>
              </tr>
              <tr>
                <td>Upload</td>
                <td className="mono">uploads</td>
                <td>fileName, mimeType, bucket, objectKey, url</td>
              </tr>
            </tbody>
          </table>

          <h3>Status Enums</h3>
          <div className="docs-grid-2">
            <div className="docs-card">
              <h4>BountyStatus</h4>
              <p><code>OPEN → CLAIMED → IN_REVIEW → COMPLETED | CANCELLED</code></p>
            </div>
            <div className="docs-card">
              <h4>ClaimStatus</h4>
              <p><code>PENDING → ACTIVE → SUBMITTED → APPROVED | REJECTED</code></p>
            </div>
            <div className="docs-card">
              <h4>EscrowStatus</h4>
              <p><code>UNFUNDED → FUNDED → RELEASED | REFUNDED</code></p>
            </div>
            <div className="docs-card">
              <h4>DisputeStatus</h4>
              <p><code>OPEN → RESOLVED | DISMISSED</code></p>
            </div>
          </div>

          <h3>Performance Indexes</h3>
          <div className="docs-card">
            <ul>
              <li><strong>bounties:</strong> <code>[status, createdAt DESC]</code>, <code>[creatorId, status]</code></li>
              <li><strong>bounty_claims:</strong> <code>[bountyId, status]</code>, <code>[claimerId, createdAt DESC]</code></li>
              <li><strong>wallet_transactions:</strong> <code>[userId, createdAt DESC]</code></li>
              <li><strong>users:</strong> <code>[xp DESC]</code> for leaderboard queries</li>
              <li><strong>Unique constraints:</strong> <code>[bountyId, claimerId]</code> on claims, <code>[reviewerId, bountyId]</code> on reviews</li>
            </ul>
          </div>
        </section>

        {/* ═══ 10 — API Design ═════════════════════════════════ */}
        <section className="docs-section" id="api">
          <h2>
            <span className="section-num">10</span>
            API Design Patterns
          </h2>
          <p>
            The REST API follows consistent patterns across all modules: 
            controller → service → repository, with shared middleware for 
            authentication, validation, and error handling.
          </p>

          <h3>Authentication Flow</h3>
          <div className="docs-card">
            <h4>Google OAuth 2.0 + JWT</h4>
            <ul>
              <li>Mobile app auth via Firebase Auth (Google Sign-In)</li>
              <li>Firebase ID token sent to backend for verification</li>
              <li>Backend issues JWT access token + refresh token pair</li>
              <li>Refresh token stored in <code>refresh_tokens</code> table with expiry</li>
              <li>Passport.js JWT strategy validates on every protected route</li>
            </ul>
          </div>

          <h3>Error Handling</h3>
          <div className="code-block">
<span className="comment">// Custom error classes extend a base AppError</span>{`
`}<span className="keyword">class</span>{` BadRequestError `}<span className="keyword">extends</span>{` AppError { statusCode = 400 }
`}<span className="keyword">class</span>{` UnauthorizedError `}<span className="keyword">extends</span>{` AppError { statusCode = 401 }
`}<span className="keyword">class</span>{` NotFoundError `}<span className="keyword">extends</span>{` AppError { statusCode = 404 }
`}<span className="keyword">class</span>{` ConflictError `}<span className="keyword">extends</span>{` AppError { statusCode = 409 }

`}<span className="comment">// Global error middleware catches all, returns consistent JSON</span>{`
{ "error": "Error message", "statusCode": 400 }`}
          </div>

          <h3>Key Endpoints</h3>
          <table className="docs-table">
            <thead>
              <tr>
                <th>Method</th>
                <th>Endpoint</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/auth/google</td>
                <td>Exchange Firebase token for JWT</td>
              </tr>
              <tr>
                <td className="mono">GET</td>
                <td className="mono">/bounties</td>
                <td>List bounties (filter by status, location)</td>
              </tr>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/bounties</td>
                <td>Create bounty + lock ALGO in escrow</td>
              </tr>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/bounties/:id/claim</td>
                <td>Claim a bounty as quester</td>
              </tr>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/bounties/:id/submit</td>
                <td>Submit proof for review</td>
              </tr>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/bounties/:id/approve</td>
                <td>Approve + release ALGO to quester</td>
              </tr>
              <tr>
                <td className="mono">GET</td>
                <td className="mono">/gamification/stats</td>
                <td>XP, level, rank, rating for current user</td>
              </tr>
              <tr>
                <td className="mono">GET</td>
                <td className="mono">/gamification/leaderboard</td>
                <td>Top 50 users by XP (cached 60s)</td>
              </tr>
              <tr>
                <td className="mono">POST</td>
                <td className="mono">/algorand/dispense</td>
                <td>Dev-only faucet funding</td>
              </tr>
            </tbody>
          </table>
        </section>

        {/* ── Back to Home CTA ──────────────────────────────── */}
        <div style={{textAlign: 'center', paddingTop: '40px', paddingBottom: '40px'}}>
          <Link href="/" className="btn-primary" style={{textDecoration: 'none'}}>
            ← Back to Home
          </Link>
        </div>
      </div>

      {/* ── Footer ──────────────────────────────────────────── */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-logo">
            <Image src="/questly_logo.svg" alt="Questly" width={24} height={24} />
            <span>questly</span>
          </div>
          <p>© 2026 Questly. Built on Algorand.</p>
          <div className="footer-links">
            <Link href="/">Home</Link>
            <a href="#overview">Overview</a>
            <a href="#architecture">Architecture</a>
          </div>
        </div>
      </footer>
    </>
  );
}
