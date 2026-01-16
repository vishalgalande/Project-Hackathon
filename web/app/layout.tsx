"use client";

import "@/app/globals.css";
import { useEffect } from "react";
import Lenis from "lenis";
import CursorTrail from "@/components/CursorTrail";

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    useEffect(() => {
        const lenis = new Lenis({
            duration: 1.2,
            easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
            orientation: "vertical",
            gestureOrientation: "vertical",
            smoothWheel: true,
        });

        function raf(time: number) {
            lenis.raf(time);
            requestAnimationFrame(raf);
        }

        requestAnimationFrame(raf);

        return () => {
            lenis.destroy();
        };
    }, []);

    return (
        <html lang="en">
            <head>
                <title>SafeZone | Digital Guardian - Smart Tourist Safety System</title>
                <meta name="description" content="SafeZone: Your invisible shield. AI-powered tourist safety with predictive threat analysis, dynamic geofencing, and immutable incident logs." />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="preconnect" href="https://fonts.googleapis.com" />
                <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
            </head>
            <body className="antialiased">
                {/* Cursor Trail Effect */}
                <CursorTrail />
                {children}
            </body>
        </html>
    );
}
