"use client";

import { motion } from "framer-motion";

export default function StaggeredText({ text, className = "" }: { text: string, className?: string }) {
    const letters = text.split("");

    return (
        <motion.div
            initial="hidden"
            animate="visible"
            variants={{
                hidden: { opacity: 0 },
                visible: { opacity: 1, transition: { staggerChildren: 0.05 } },
            }}
            className={`inline-block ${className}`}
        >
            {letters.map((char, i) => (
                <motion.span
                    key={i}
                    variants={{
                        hidden: { opacity: 0, y: 50 },
                        visible: { opacity: 1, y: 0, transition: { type: "spring", damping: 12, stiffness: 200 } },
                    }}
                    className="inline-block"
                >
                    {char === " " ? "\u00A0" : char}
                </motion.span>
            ))}
        </motion.div>
    );
}
