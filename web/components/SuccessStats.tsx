"use client";

import { motion } from "framer-motion";

export default function SuccessStats() {
    const stats = [
        { value: "99.9%", label: "Uptime", suffix: "" },
        { value: "50", label: "Response Time", suffix: "ms" },
        { value: "10K", label: "Active Users", suffix: "+" },
        { value: "24", label: "Protected Zones", suffix: "" },
    ];

    return (
        <div className="max-w-7xl mx-auto px-6">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
                className="grid grid-cols-2 md:grid-cols-4 gap-8"
            >
                {stats.map((stat, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.6, delay: i * 0.1 }}
                        className="text-center"
                    >
                        <div className="text-4xl md:text-5xl font-black text-[#00F0FF] drop-shadow-[0_0_10px_rgba(0,240,255,0.5)]">
                            {stat.value}
                            <span className="text-xl ml-1 text-white/50">{stat.suffix}</span>
                        </div>
                        <div className="text-xs font-mono text-white/40 uppercase tracking-widest mt-2">
                            {stat.label}
                        </div>
                    </motion.div>
                ))}
            </motion.div>
        </div>
    );
}
