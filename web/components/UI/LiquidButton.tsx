"use client";

import { motion } from "framer-motion";

interface LiquidButtonProps {
    children: React.ReactNode;
    onClick?: () => void;
    className?: string;
}

export default function LiquidButton({ children, onClick, className = "" }: LiquidButtonProps) {
    return (
        <motion.button
            onClick={onClick}
            className={`relative px-8 py-4 font-bold text-white rounded-lg overflow-hidden group ${className}`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
        >
            {/* Background/Border Base */}
            <div className="absolute inset-0 border border-primary/50 rounded-lg" />

            {/* Liquid Fill Element */}
            <div className="absolute inset-0 bg-primary translate-y-full transition-transform duration-500 ease-out group-hover:translate-y-0" />

            {/* Glow Effect */}
            <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500 shadow-[0_0_40px_rgba(139,92,246,0.6)]" />

            {/* Text Content (ensures visibility over fill) */}
            <span className="relative z-10 flex items-center justify-center gap-2 group-hover:text-white transition-colors">
                {children}
            </span>
        </motion.button>
    );
}
