"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";

interface Point {
    x: number;
    y: number;
}

export default function CursorTrail() {
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const points = useRef<Point[]>([]);
    const mousePos = useRef<Point>({ x: 0, y: 0 });
    const animationFrameId = useRef<number>();

    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        const ctx = canvas.getContext("2d");
        if (!ctx) return;

        // Set canvas size
        const resizeCanvas = () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        };
        resizeCanvas();
        window.addEventListener("resize", resizeCanvas);

        // Track mouse position
        const handleMouseMove = (e: MouseEvent) => {
            mousePos.current = { x: e.clientX, y: e.clientY };
        };
        window.addEventListener("mousemove", handleMouseMove);

        // Animation loop
        const maxPoints = 50;
        const animate = () => {
            // Add current mouse position to points
            points.current.push({ ...mousePos.current });

            // Limit number of points
            if (points.current.length > maxPoints) {
                points.current.shift();
            }

            // Clear canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Draw trail
            if (points.current.length > 1) {
                ctx.beginPath();
                ctx.moveTo(points.current[0].x, points.current[0].y);

                for (let i = 1; i < points.current.length; i++) {
                    const point = points.current[i];
                    ctx.lineTo(point.x, point.y);
                }

                // Create gradient for the line
                const gradient = ctx.createLinearGradient(
                    points.current[0].x,
                    points.current[0].y,
                    points.current[points.current.length - 1].x,
                    points.current[points.current.length - 1].y
                );
                gradient.addColorStop(0, "rgba(99, 102, 241, 0)");
                gradient.addColorStop(0.5, "rgba(99, 102, 241, 0.5)");
                gradient.addColorStop(1, "rgba(168, 85, 247, 0.8)");

                ctx.strokeStyle = gradient;
                ctx.lineWidth = 2;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.stroke();

                // Draw glow effect
                ctx.shadowColor = "rgba(99, 102, 241, 0.5)";
                ctx.shadowBlur = 10;
                ctx.stroke();
                ctx.shadowBlur = 0;
            }

            animationFrameId.current = requestAnimationFrame(animate);
        };

        animate();

        return () => {
            window.removeEventListener("resize", resizeCanvas);
            window.removeEventListener("mousemove", handleMouseMove);
            if (animationFrameId.current) {
                cancelAnimationFrame(animationFrameId.current);
            }
        };
    }, []);

    return (
        <canvas
            ref={canvasRef}
            className="fixed inset-0 pointer-events-none z-[9998]"
            style={{ mixBlendMode: "screen" }}
        />
    );
}
