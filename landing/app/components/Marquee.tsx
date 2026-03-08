"use client";

/**
 * ReactBits-style infinite scrolling marquee strip.
 */
const items = [
    "Bounty Hunting",
    "Crypto Rewards",
    "Real-World Tasks",
    "Algorand Powered",
    "XP & Ranks",
    "Community Driven",
    "Earn IRL",
    "Post & Earn",
    "Zero Fees",
    "Gamified",
];

export default function Marquee() {
    const doubled = [...items, ...items];

    return (
        <div className="marquee-wrapper">
            <div className="marquee-track">
                {doubled.map((item, i) => (
                    <span key={i} className="marquee-item">
                        {item}
                        <span className="sep" />
                    </span>
                ))}
            </div>
        </div>
    );
}
