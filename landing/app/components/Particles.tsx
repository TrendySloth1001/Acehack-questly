"use client";
import { useEffect, useRef } from "react";

/**
 * ReactBits-style floating particles background.
 * Gold/amber dots drifting upward with slight horizontal sway.
 */
export default function Particles({ count = 40 }: { count?: number }) {
    const containerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const container = containerRef.current;
        if (!container) return;

        // Clear existing
        container.innerHTML = "";

        for (let i = 0; i < count; i++) {
            const particle = document.createElement("div");
            particle.className = "particle";
            particle.style.left = `${Math.random() * 100}%`;
            particle.style.animationDelay = `${Math.random() * 8}s`;
            particle.style.animationDuration = `${6 + Math.random() * 6}s`;
            const size = 1 + Math.random() * 2;
            particle.style.width = `${size}px`;
            particle.style.height = `${size}px`;
            particle.style.opacity = `${0.2 + Math.random() * 0.4}`;
            container.appendChild(particle);
        }
    }, [count]);

    return <div ref={containerRef} className="particles-container" />;
}
