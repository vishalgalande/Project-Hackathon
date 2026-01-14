"use client";

import { useState, useRef, useEffect } from "react";
import { motion } from "framer-motion";

interface GlitchButtonProps {
    children: React.ReactNode;
    onClick?: () => void;
    className?: string;
}

export default function GlitchButton({ children, onClick, className = "" }: GlitchButtonProps) {
    const [isHovered, setIsHovered] = useState(false);
    const buttonRef = useRef<HTMLButtonElement>(null);

    return (
        <motion.button
            ref={buttonRef}
            onClick={onClick}
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
            className={`
        relative px-8 py-4 overflow-hidden
        bg-transparent border-2 border-cyber-cyan
        text-cyber-cyan font-bold uppercase tracking-widest
        transition-all duration-300 cursor-pointer
        group ${className}
      `}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
        >
            {/* Background fill on hover */}
            <motion.div
                className="absolute inset-0 bg-cyber-cyan"
                initial={{ scaleX: 0 }}
                animate={{ scaleX: isHovered ? 1 : 0 }}
                transition={{ duration: 0.3, ease: "easeInOut" }}
                style={{ originX: 0 }}
            />

            {/* Main text */}
            <span className={`
        relative z-10 text-sm transition-colors duration-300
        ${isHovered ? "text-void-black" : "text-cyber-cyan"}
      `}>
                {children}
            </span>

            {/* Glitch layers */}
            {isHovered && (
                <>
                    <span
                        className="absolute inset-0 flex items-center justify-center text-sm font-bold uppercase tracking-widest text-signal-red opacity-70 z-20"
                        style={{
                            clipPath: "inset(40% 0 30% 0)",
                            transform: "translate(-2px, 1px)",
                            animation: "glitch 0.3s ease-in-out infinite",
                        }}
                    >
                        {children}
                    </span>
                    <span
                        className="absolute inset-0 flex items-center justify-center text-sm font-bold uppercase tracking-widest text-cyber-cyan opacity-70 z-20"
                        style={{
                            clipPath: "inset(60% 0 10% 0)",
                            transform: "translate(2px, -1px)",
                            animation: "glitch 0.3s ease-in-out infinite reverse",
                        }}
                    >
                        {children}
                    </span>
                </>
            )}

            {/* Corner accents */}
            <div className="absolute top-0 left-0 w-3 h-3 border-t-2 border-l-2 border-cyber-cyan" />
            <div className="absolute top-0 right-0 w-3 h-3 border-t-2 border-r-2 border-cyber-cyan" />
            <div className="absolute bottom-0 left-0 w-3 h-3 border-b-2 border-l-2 border-cyber-cyan" />
            <div className="absolute bottom-0 right-0 w-3 h-3 border-b-2 border-r-2 border-cyber-cyan" />

            {/* Scan line effect */}
            {isHovered && (
                <motion.div
                    className="absolute inset-0 bg-gradient-to-b from-transparent via-white/10 to-transparent z-30 pointer-events-none"
                    initial={{ y: "-100%" }}
                    animate={{ y: "100%" }}
                    transition={{ duration: 0.5, repeat: Infinity, ease: "linear" }}
                />
            )}
        </motion.button>
    );
}
