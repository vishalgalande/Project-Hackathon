"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";

export default function RadarPulse() {
    const containerRef = useRef<HTMLDivElement>(null);
    const sweepRef = useRef<HTMLDivElement>(null);
    const pulse1Ref = useRef<HTMLDivElement>(null);
    const pulse2Ref = useRef<HTMLDivElement>(null);
    const pulse3Ref = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const ctx = gsap.context(() => {
            // Radar sweep rotation
            gsap.to(sweepRef.current, {
                rotation: 360,
                duration: 2,
                repeat: -1,
                ease: "none",
            });

            // Pulse animations - staggered
            const pulseTimeline = gsap.timeline({ repeat: -1 });

            pulseTimeline
                .fromTo(pulse1Ref.current,
                    { scale: 0.3, opacity: 0.8 },
                    { scale: 1, opacity: 0, duration: 2, ease: "power2.out" }
                )
                .fromTo(pulse2Ref.current,
                    { scale: 0.3, opacity: 0.8 },
                    { scale: 1, opacity: 0, duration: 2, ease: "power2.out" },
                    "-=1.5"
                )
                .fromTo(pulse3Ref.current,
                    { scale: 0.3, opacity: 0.8 },
                    { scale: 1, opacity: 0, duration: 2, ease: "power2.out" },
                    "-=1.5"
                );
        }, containerRef);

        return () => ctx.revert();
    }, []);

    return (
        <div ref={containerRef} className="absolute inset-0 flex items-center justify-center pointer-events-none">
            {/* Pulse circles */}
            <div
                ref={pulse1Ref}
                className="absolute w-[300px] h-[300px] rounded-full border border-primary/40"
                style={{ boxShadow: "0 0 20px rgba(99, 102, 241, 0.2)" }}
            />
            <div
                ref={pulse2Ref}
                className="absolute w-[300px] h-[300px] rounded-full border border-primary/30"
                style={{ boxShadow: "0 0 20px rgba(99, 102, 241, 0.15)" }}
            />
            <div
                ref={pulse3Ref}
                className="absolute w-[300px] h-[300px] rounded-full border border-primary/20"
                style={{ boxShadow: "0 0 20px rgba(99, 102, 241, 0.1)" }}
            />

            {/* Radar sweep */}
            <div
                ref={sweepRef}
                className="absolute w-[200px] h-[200px]"
                style={{ transformOrigin: "center center" }}
            >
                <div
                    className="absolute top-1/2 left-1/2 w-1/2 h-[2px]"
                    style={{
                        background: "linear-gradient(90deg, rgba(99, 102, 241, 0.8) 0%, transparent 100%)",
                        transformOrigin: "left center",
                        boxShadow: "0 0 10px rgba(99, 102, 241, 0.5)",
                    }}
                />
            </div>

            {/* Center dot */}
            <div className="absolute w-3 h-3 bg-primary rounded-full animate-pulse"
                style={{ boxShadow: "0 0 15px rgba(99, 102, 241, 0.8)" }}
            />
        </div>
    );
}
