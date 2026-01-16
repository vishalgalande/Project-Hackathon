"use client";

import { useEffect, useRef, useState } from "react";
import dynamic from "next/dynamic";
import gsap from "gsap";
import RadarPulse from "./RadarPulse";

// Dynamic import for Three.js component
const LoadingGlobe = dynamic(() => import("./LoadingGlobe"), { ssr: false });

interface LoadingScreenProps {
    onLoadingComplete?: () => void;
    minDuration?: number;
}

export default function LoadingScreen({
    onLoadingComplete,
    minDuration = 3000
}: LoadingScreenProps) {
    const containerRef = useRef<HTMLDivElement>(null);
    const progressBarRef = useRef<HTMLDivElement>(null);
    const textRef = useRef<HTMLDivElement>(null);
    const statusTextRef = useRef<HTMLSpanElement>(null);
    const [progress, setProgress] = useState(0);

    useEffect(() => {
        const ctx = gsap.context(() => {
            // Main timeline
            const tl = gsap.timeline();

            // Entrance animation
            tl.fromTo(containerRef.current,
                { opacity: 0 },
                { opacity: 1, duration: 0.5, ease: "power2.out" }
            );

            // Text reveal animation
            tl.fromTo(textRef.current,
                { opacity: 0, y: 20 },
                { opacity: 1, y: 0, duration: 0.8, ease: "power2.out" },
                "-=0.2"
            );

            // Progress bar animation
            const progressTl = gsap.timeline();
            progressTl.to(progressBarRef.current, {
                width: "100%",
                duration: minDuration / 1000,
                ease: "power1.inOut",
                onUpdate: function () {
                    setProgress(Math.round(this.progress() * 100));
                },
                onComplete: () => {
                    // Fade out animation
                    gsap.to(containerRef.current, {
                        opacity: 0,
                        scale: 1.05,
                        duration: 0.6,
                        ease: "power2.inOut",
                        onComplete: () => {
                            onLoadingComplete?.();
                        }
                    });
                }
            });

            // Typewriter effect for status text
            const statusMessages = [
                "INITIALIZING SYSTEM",
                "CONNECTING TO NETWORK",
                "LOADING GEOFENCE DATA",
                "ACTIVATING GUARDIAN MODE",
                "SYSTEM READY"
            ];

            let messageIndex = 0;
            const messageInterval = setInterval(() => {
                if (statusTextRef.current && messageIndex < statusMessages.length) {
                    gsap.to(statusTextRef.current, {
                        opacity: 0,
                        duration: 0.2,
                        onComplete: () => {
                            if (statusTextRef.current) {
                                statusTextRef.current.textContent = statusMessages[messageIndex];
                                gsap.to(statusTextRef.current, { opacity: 1, duration: 0.2 });
                            }
                            messageIndex++;
                        }
                    });
                }
            }, minDuration / statusMessages.length);

            return () => clearInterval(messageInterval);
        }, containerRef);

        return () => ctx.revert();
    }, [minDuration, onLoadingComplete]);

    return (
        <div
            ref={containerRef}
            className="fixed inset-0 z-[9999] bg-void-black flex flex-col items-center justify-center overflow-hidden"
        >
            {/* Grid background */}
            <div className="absolute inset-0 grid-bg opacity-30" />

            {/* Radar pulse effect */}
            <RadarPulse />

            {/* 3D Globe */}
            <div className="relative z-10">
                <LoadingGlobe />
            </div>

            {/* Text content */}
            <div ref={textRef} className="relative z-10 text-center mt-8">
                {/* Logo */}
                <h1 className="text-3xl md:text-4xl font-bold mb-4">
                    Safe<span className="text-primary text-glow-primary">Travel</span>
                </h1>

                {/* Status text */}
                <div className="text-mono text-xs tracking-[0.3em] text-primary mb-8 h-4">
                    <span ref={statusTextRef}>INITIALIZING SYSTEM</span>
                </div>

                {/* Progress bar container */}
                <div className="w-64 md:w-80 h-[2px] bg-white/10 rounded-full overflow-hidden mx-auto">
                    <div
                        ref={progressBarRef}
                        className="h-full bg-gradient-to-r from-primary to-accent"
                        style={{
                            width: "0%",
                            boxShadow: "0 0 10px rgba(99, 102, 241, 0.5)"
                        }}
                    />
                </div>

                {/* Progress percentage */}
                <div className="text-mono text-xs text-white/50 mt-3">
                    {progress}%
                </div>
            </div>

            {/* Corner decorations */}
            <div className="absolute top-6 left-6 w-12 h-12 border-t border-l border-primary/30" />
            <div className="absolute top-6 right-6 w-12 h-12 border-t border-r border-primary/30" />
            <div className="absolute bottom-6 left-6 w-12 h-12 border-b border-l border-primary/30" />
            <div className="absolute bottom-6 right-6 w-12 h-12 border-b border-r border-primary/30" />

            {/* Scanlines overlay */}
            <div className="absolute inset-0 pointer-events-none scanlines opacity-20" />
        </div>
    );
}
