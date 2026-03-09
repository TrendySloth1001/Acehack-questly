"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function DownloadPage() {
  const [downloading, setDownloading] = useState(false);

  const GITHUB_APK_URL = "https://github.com/TrendySloth1001/Acehack-questly/releases/download/v1.0.0/questly-v1.0.0.apk";
  const GITHUB_RELEASE_URL = "https://github.com/TrendySloth1001/Acehack-questly/releases/tag/v1.0.0";

  function handleDownload() {
    setDownloading(true);
    setTimeout(() => setDownloading(false), 3000);
    window.open(GITHUB_APK_URL, "_blank");
  }

  return (
    <>
      {/* ── Navbar ──────────────────────────────────────────── */}
      <nav className="navbar">
        <div className="nav-logo">
          <Image src="/questly_logo.svg" alt="Questly" width={36} height={36} />
          <span>questly</span>
        </div>
        <div className="nav-links">
          <Link href="/">Home</Link>
          <Link href="/docs">Docs</Link>
          <a
            href="https://github.com/TrendySloth1001/Acehack-questly"
            target="_blank"
            rel="noopener noreferrer"
          >
            GitHub
          </a>
        </div>
        <Link href="/" className="nav-cta">
          Back to Home
        </Link>
      </nav>

      <div className="dl-page">
        <div className="dl-glow" />

          <div className="dl-content">
            <div className="dl-success-icon">
              <svg
                width="48"
                height="48"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                <polyline points="22 4 12 14.01 9 11.01" />
              </svg>
            </div>

            <h1>Download Questly</h1>
            <p className="dl-desc">
              Get the latest version of the Questly mobile app. Install the APK
              on your Android device to start earning ALGO for real-world tasks.
            </p>

            {/* App Info Card */}
            <div className="dl-app-card">
              <div className="dl-app-header">
                <Image
                  src="/questly_logo.svg"
                  alt="Questly"
                  width={56}
                  height={56}
                  className="dl-app-icon"
                />
                <div className="dl-app-meta">
                  <h2>Questly</h2>
                  <p>Real-World Bounties, Real Rewards</p>
                </div>
              </div>

              <div className="dl-app-details">
                <div className="dl-detail">
                  <span className="dl-detail-label">Platform</span>
                  <span className="dl-detail-value">Android</span>
                </div>
                <div className="dl-detail">
                  <span className="dl-detail-label">Version</span>
                  <span className="dl-detail-value">1.0.0</span>
                </div>
                <div className="dl-detail">
                  <span className="dl-detail-label">Size</span>
                  <span className="dl-detail-value">~56 MB</span>
                </div>
                <div className="dl-detail">
                  <span className="dl-detail-label">Blockchain</span>
                  <span className="dl-detail-value">Algorand</span>
                </div>
              </div>

              <button
                onClick={handleDownload}
                className={`dl-download-btn ${downloading ? "dl-downloading" : ""}`}
                disabled={downloading}
              >
                {downloading ? (
                  <>
                    <svg
                      className="dl-spinner"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
                    </svg>
                    Preparing Download...
                  </>
                ) : (
                  <>
                    <svg
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                      <polyline points="7 10 12 15 17 10" />
                      <line x1="12" y1="15" x2="12" y2="3" />
                    </svg>
                    Download APK
                  </>
                )}
              </button>
            </div>

            {/* Install Instructions */}
            <div className="dl-instructions">
              <h3>Installation Guide</h3>
              <div className="dl-steps">
                <div className="dl-step">
                  <div className="dl-step-num">1</div>
                  <div>
                    <strong>Download the APK</strong>
                    <p>Click the button above to download the file</p>
                  </div>
                </div>
                <div className="dl-step">
                  <div className="dl-step-num">2</div>
                  <div>
                    <strong>Enable Unknown Sources</strong>
                    <p>
                      Go to Settings &rarr; Security &rarr; Install Unknown Apps
                    </p>
                  </div>
                </div>
                <div className="dl-step">
                  <div className="dl-step-num">3</div>
                  <div>
                    <strong>Install &amp; Launch</strong>
                    <p>Open the downloaded file and tap Install</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Links */}
            <div className="dl-links">
              <a
                href="https://github.com/TrendySloth1001/Acehack-questly/releases"
                target="_blank"
                rel="noopener noreferrer"
                className="dl-link-card"
              >
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                <span>View on GitHub / All Releases</span>
              </a>
              <Link href="/docs" className="dl-link-card">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
                  <line x1="16" y1="13" x2="8" y2="13" />
                  <line x1="16" y1="17" x2="8" y2="17" />
                  <polyline points="10 9 9 9 8 9" />
                </svg>
                <span>Read Documentation</span>
              </Link>
            </div>

            {/* Team Credit */}
            <div className="dl-team">
              <p>
                Built by <strong>Abhinand Ajaya</strong> and{" "}
                <strong>Nikhil Kumawat</strong>
              </p>
              <p className="dl-team-name">Team Diamonds</p>
            </div>
          </div>
      </div>

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
          <p>&copy; 2026 Questly. Built on Algorand.</p>
          <div className="footer-links">
            <Link href="/">Home</Link>
            <Link href="/docs">Docs</Link>
            <a
              href="https://github.com/TrendySloth1001/Acehack-questly"
              target="_blank"
              rel="noopener noreferrer"
            >
              GitHub
            </a>
          </div>
        </div>
      </footer>
    </>
  );
}
