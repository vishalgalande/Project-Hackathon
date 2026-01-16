"use client";

import { useState, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Shield, ShieldCheck, Power } from "lucide-react";

export default function GuardianToggle() {
    const [isActive, setIsActive] = useState(false);
    const [showFlash, setShowFlash] = useState(false);

    const handleToggle = useCallback(() => {
        if (!isActive) {
            setShowFlash(true);
            setTimeout(() => setShowFlash(false), 300);
        }
        setIsActive(!isActive);
    }, [isActive]);

    return (
        <>
            {/* Flash overlay */}
            <AnimatePresence>
                {showFlash && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.15 }}
                        className="fixed inset-0 z-[100] bg-primary pointer-events-none"
                    />
                )}
            </AnimatePresence>

            <section className="py-20 px-4 md:px-8 lg:px-16 relative overflow-hidden">
                {/* Background glow when active */}
                <AnimatePresence>
                    {isActive && (
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="absolute inset-0 pointer-events-none"
                        >
                            <div className="absolute inset-0 bg-gradient-radial from-primary/10 via-transparent to-transparent" />
                        </motion.div>
                    )}
                </AnimatePresence>

                <div className="max-w-4xl mx-auto relative z-10">
                    {/* Header */}
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.6 }}
                        className="text-center mb-12"
                    >
                        <span className="text-mono text-signal-red text-sm tracking-widest uppercase">
                            {isActive ? "// System Online" : "// System Standby"}
                        </span>
                        <h2 className="heading-section mt-4">
                            <span className="text-white">Guardian </span>
                            <span className={`transition-colors duration-500 ${isActive ? "text-primary text-glow-primary" : "text-white/50"}`}>
                                Angel
                            </span>
                        </h2>
                        <p className="text-white/50 mt-4 max-w-xl mx-auto">
                            Activate real-time protection mode. All sensors, AI modules, and emergency protocols will be engaged.
                        </p>
                    </motion.div>

                    {/* Toggle Card */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.6, delay: 0.2 }}
                        className={`
              relative rounded-3xl p-8 md:p-12
              glass-strong
              transition-all duration-500
              ${isActive ? "glow-cyan" : ""}
            `}
                    >
                        <div className="flex flex-col md:flex-row items-center justify-between gap-8">
                            {/* Status */}
                            <div className="flex items-center gap-6">
                                <motion.div
                                    animate={{
                                        scale: isActive ? [1, 1.1, 1] : 1,
                                    }}
                                    transition={{ duration: 2, repeat: isActive ? Infinity : 0 }}
                                    className={`
                    p-6 rounded-2xl transition-all duration-500
                    ${isActive ? "bg-primary/20 text-primary" : "bg-white/5 text-white/30"}
                  `}
                                >
                                    {isActive ? (
                                        <ShieldCheck className="w-12 h-12" />
                                    ) : (
                                        <Shield className="w-12 h-12" />
                                    )}
                                </motion.div>

                                <div>
                                    <div className="text-mono text-xs text-white/50 uppercase tracking-widest mb-1">
                                        Protection Status
                                    </div>
                                    <div className={`text-2xl md:text-3xl font-bold transition-colors duration-500 ${isActive ? "text-primary" : "text-white/50"}`}>
                                        {isActive ? "ACTIVE" : "STANDBY"}
                                    </div>
                                </div>
                            </div>

                            {/* Toggle Switch */}
                            <button
                                onClick={handleToggle}
                                className="relative group cursor-pointer"
                                aria-label={isActive ? "Deactivate Guardian Mode" : "Activate Guardian Mode"}
                            >
                                <div className={`
                  w-32 h-16 rounded-full p-1 transition-all duration-500
                  ${isActive
                                        ? "bg-primary/20 border-2 border-primary"
                                        : "bg-white/5 border-2 border-white/20"
                                    }
                `}>
                                    <motion.div
                                        animate={{ x: isActive ? 64 : 0 }}
                                        transition={{ type: "spring", stiffness: 500, damping: 30 }}
                                        className={`
                      w-14 h-14 rounded-full flex items-center justify-center
                      transition-colors duration-500
                      ${isActive ? "bg-primary" : "bg-white/20"}
                    `}
                                    >
                                        <Power className={`w-6 h-6 ${isActive ? "text-void-black" : "text-white/50"}`} />
                                    </motion.div>
                                </div>

                                {/* Pulse ring when active */}
                                {isActive && (
                                    <motion.div
                                        className="absolute inset-0 rounded-full border-2 border-primary"
                                        initial={{ opacity: 1, scale: 1 }}
                                        animate={{ opacity: 0, scale: 1.5 }}
                                        transition={{ duration: 1.5, repeat: Infinity }}
                                    />
                                )}
                            </button>
                        </div>

                        {/* Status indicators */}
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: isActive ? 1 : 0.3 }}
                            transition={{ duration: 0.5 }}
                            className="mt-8 pt-8 border-t border-glass-border grid grid-cols-2 md:grid-cols-4 gap-4"
                        >
                            {[
                                { label: "Neural Net", status: isActive },
                                { label: "Geo-Fence", status: isActive },
                                { label: "Blockchain", status: isActive },
                                { label: "Emergency", status: isActive },
                            ].map((item, i) => (
                                <div key={i} className="text-center">
                                    <div className={`
                    w-2 h-2 rounded-full mx-auto mb-2 transition-all duration-500
                    ${item.status ? "bg-primary animate-pulse" : "bg-white/20"}
                  `} />
                                    <div className="text-mono text-xs text-white/50 uppercase">
                                        {item.label}
                                    </div>
                                </div>
                            ))}
                        </motion.div>
                    </motion.div>
                </div>
            </section>
        </>
    );
}
