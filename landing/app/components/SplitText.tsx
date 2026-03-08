"use client";
import { useEffect, useRef } from "react";

/**
 * ReactBits-style split text animation.
 * Each letter/word reveals with a staggered upward motion.
 */
export default function SplitText({
    text,
    className = "",
    delayMs = 40,
}: {
    text: string;
    className?: string;
    delayMs?: number;
}) {
    const containerRef = useRef<HTMLSpanElement>(null);

    useEffect(() => {
        const el = containerRef.current;
        if (!el) return;
        el.innerHTML = "";

        const words = text.split(" ");
        words.forEach((word, wi) => {
            const wordSpan = document.createElement("span");
            wordSpan.style.display = "inline-block";
            wordSpan.style.whiteSpace = "nowrap";

            [...word].forEach((char, ci) => {
                const span = document.createElement("span");
                span.className = "split-char";
                span.textContent = char;
                span.style.display = "inline-block";
                span.style.opacity = "0";
                span.style.transform = "translateY(24px)";
                span.style.transition = `opacity 0.4s ease, transform 0.4s ease`;
                span.style.transitionDelay = `${(wi * word.length + ci) * delayMs}ms`;
                wordSpan.appendChild(span);
            });

            el.appendChild(wordSpan);

            // Space between words
            if (wi < words.length - 1) {
                const space = document.createElement("span");
                space.innerHTML = "&nbsp;";
                el.appendChild(space);
            }
        });

        // Trigger animation on next frame
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                el.querySelectorAll(".split-char").forEach((span) => {
                    (span as HTMLElement).style.opacity = "1";
                    (span as HTMLElement).style.transform = "translateY(0)";
                });
            });
        });
    }, [text, delayMs]);

    return <span ref={containerRef} className={`split-text ${className}`} />;
}
