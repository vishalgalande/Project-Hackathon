"use client";

import { motion } from "framer-motion";
import { Brain, Radar, Link } from "lucide-react";

interface BentoCardProps {
    title: string;
    description: string;
    icon: React.ReactNode;
    animation: React.ReactNode;
    className?: string;
    delay?: number;
}

function BentoCard({ title, description, icon, animation, className = "", delay = 0 }: BentoCardProps) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6, delay, ease: [0.16, 1, 0.3, 1] }}
            whileHover={{ scale: 1.02, y: -5 }}
            className={`
        relative overflow-hidden rounded-2xl
        glass-strong p-6 md:p-8
        group cursor-pointer
        transition-all duration-500
        hover:glow-cyan
        ${className}
      `}
        >
            {/* Background pattern */}
            <div className="absolute inset-0 opacity-5 grid-bg" />

            {/* Animation container */}
            <div className="relative z-10 mb-6 h-32 md:h-40 flex items-center justify-center">
                {animation}
            </div>

            {/* Icon */}
            <div className="flex items-center gap-3 mb-3">
                <div className="p-2 rounded-lg bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
                    {icon}
                </div>
                <span className="text-mono text-xs text-primary/60 uppercase tracking-widest">
                    Module Active
                </span>
            </div>

            {/* Content */}
            <h3 className="text-xl md:text-2xl font-bold mb-2 group-hover:text-primary transition-colors">
                {title}
            </h3>
            <p className="text-white/50 text-sm leading-relaxed">
                {description}
            </p>

            {/* Hover glow effect */}
            <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
                <div className="absolute inset-0 bg-gradient-to-t from-primary/10 to-transparent" />
            </div>

            {/* Corner accent */}
            <div className="absolute top-4 right-4 w-8 h-8 border-t border-r border-primary/30 group-hover:border-primary transition-colors" />
        </motion.div>
    );
}

// AI Brain Animation
function AIBrainAnimation() {
    return (
        <div className="relative w-24 h-24">
            {/* Pulsing circles */}
            <motion.div
                className="absolute inset-0 rounded-full border-2 border-primary/30"
                animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeOut" }}
            />
            <motion.div
                className="absolute inset-0 rounded-full border-2 border-primary/30"
                animate={{ scale: [1, 1.3, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeOut", delay: 0.5 }}
            />

            {/* Brain icon */}
            <motion.div
                className="absolute inset-0 flex items-center justify-center"
                animate={{
                    filter: [
                        "drop-shadow(0 0 10px rgba(99, 102, 241, 0.5))",
                        "drop-shadow(0 0 30px rgba(99, 102, 241, 0.8))",
                        "drop-shadow(0 0 10px rgba(99, 102, 241, 0.5))"
                    ]
                }}
                transition={{ duration: 2, repeat: Infinity }}
            >
                <Brain className="w-12 h-12 text-primary" />
            </motion.div>

            {/* Neural connections */}
            {[...Array(6)].map((_, i) => (
                <motion.div
                    key={i}
                    className="absolute w-1 h-1 bg-primary rounded-full"
                    style={{
                        top: `${20 + Math.sin(i * 60 * Math.PI / 180) * 40}%`,
                        left: `${50 + Math.cos(i * 60 * Math.PI / 180) * 45}%`,
                    }}
                    animate={{
                        opacity: [0.3, 1, 0.3],
                        scale: [0.8, 1.2, 0.8],
                    }}
                    transition={{
                        duration: 1.5,
                        repeat: Infinity,
                        delay: i * 0.2,
                    }}
                />
            ))}
        </div>
    );
}

// Radar Animation
function RadarAnimation() {
    return (
        <div className="relative w-28 h-28">
            {/* Radar circles */}
            <div className="absolute inset-0 rounded-full border border-primary/20" />
            <div className="absolute inset-[15%] rounded-full border border-primary/30" />
            <div className="absolute inset-[30%] rounded-full border border-primary/40" />
            <div className="absolute inset-[45%] rounded-full bg-primary/20" />

            {/* Sweep */}
            <motion.div
                className="absolute inset-0 origin-center"
                animate={{ rotate: 360 }}
                transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
            >
                <div
                    className="absolute top-1/2 left-1/2 w-1/2 h-0.5 origin-left"
                    style={{
                        background: "linear-gradient(90deg, rgba(99, 102, 241, 0.8), transparent)"
                    }}
                />
                <div
                    className="absolute top-1/2 left-1/2 w-14 h-14 -ml-7 -mt-7 origin-center"
                    style={{
                        background: "conic-gradient(from 0deg, rgba(99, 102, 241, 0.3), transparent 60deg)"
                    }}
                />
            </motion.div>

            {/* Blips */}
            <motion.div
                className="absolute w-2 h-2 bg-signal-red rounded-full"
                style={{ top: "30%", left: "60%" }}
                animate={{ opacity: [0, 1, 0], scale: [0.5, 1, 0.5] }}
                transition={{ duration: 2, repeat: Infinity }}
            />
            <motion.div
                className="absolute w-1.5 h-1.5 bg-primary rounded-full"
                style={{ top: "60%", left: "35%" }}
                animate={{ opacity: [0, 1, 0], scale: [0.5, 1, 0.5] }}
                transition={{ duration: 2, repeat: Infinity, delay: 1 }}
            />
        </div>
    );
}

// Blockchain Animation
function BlockchainAnimation() {
    return (
        <div className="relative w-32 h-24 flex items-center justify-center gap-3">
            {[0, 1, 2].map((i) => (
                <motion.div
                    key={i}
                    className="relative"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: i * 0.2 }}
                >
                    {/* Block */}
                    <motion.div
                        className="w-10 h-10 rounded-lg border-2 border-primary/50 bg-primary/10 flex items-center justify-center"
                        animate={{
                            borderColor: ["rgba(99, 102, 241, 0.5)", "rgba(99, 102, 241, 1)", "rgba(99, 102, 241, 0.5)"],
                        }}
                        transition={{ duration: 2, repeat: Infinity, delay: i * 0.3 }}
                    >
                        <Link className="w-4 h-4 text-primary" />
                    </motion.div>

                    {/* Connection line */}
                    {i < 2 && (
                        <motion.div
                            className="absolute top-1/2 -right-3 w-3 h-0.5 bg-cyber-cyan/50"
                            animate={{
                                opacity: [0.3, 1, 0.3],
                                backgroundColor: ["rgba(99, 102, 241, 0.3)", "rgba(99, 102, 241, 1)", "rgba(99, 102, 241, 0.3)"],
                            }}
                            transition={{ duration: 1, repeat: Infinity, delay: i * 0.3 + 0.5 }}
                        />
                    )}
                </motion.div>
            ))}
        </div>
    );
}

export default function BentoGrid() {
    return (
        <section className="py-20 px-4 md:px-8 lg:px-16">
            <div className="max-w-7xl mx-auto">
                {/* Section header */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6 }}
                    className="text-center mb-16"
                >
                    <span className="text-mono text-primary text-sm tracking-widest uppercase">
                        Core Systems
                    </span>
                    <h2 className="heading-section mt-4">
                        <span className="text-white">Defense </span>
                        <span className="text-primary text-glow-primary">Matrix</span>
                    </h2>
                </motion.div>

                {/* Bento Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
                    <BentoCard
                        title="Predictive Threat Analysis"
                        description="Neural networks analyze patterns in real-time, predicting potential safety concerns before they materialize."
                        icon={<Brain className="w-5 h-5" />}
                        animation={<AIBrainAnimation />}
                        delay={0}
                    />
                    <BentoCard
                        title="Dynamic Perimeters"
                        description="Adaptive geofencing creates intelligent boundaries that respond to changing environmental conditions."
                        icon={<Radar className="w-5 h-5" />}
                        animation={<RadarAnimation />}
                        delay={0.1}
                    />
                    <BentoCard
                        title="Immutable Incident Logs"
                        description="Blockchain-secured records ensure complete transparency and tamper-proof documentation."
                        icon={<Link className="w-5 h-5" />}
                        animation={<BlockchainAnimation />}
                        delay={0.2}
                    />
                </div>
            </div>
        </section>
    );
}
