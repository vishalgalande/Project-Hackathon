"use client";

import { motion } from "framer-motion";

const statusItems = [
    { location: "JAIPUR", status: "SECURE", type: "safe" },
    { location: "SECTOR 4", status: "ANOMALY DETECTED", type: "danger" },
    { location: "AI MODEL", status: "ONLINE", type: "info" },
    { location: "DELHI", status: "MONITORING", type: "safe" },
    { location: "ZONE 7B", status: "PERIMETER BREACH", type: "danger" },
    { location: "NEURAL NET", status: "ACTIVE", type: "info" },
    { location: "MUMBAI", status: "ALL CLEAR", type: "safe" },
    { location: "BLOCKCHAIN", status: "SYNCED", type: "info" },
];

export default function LiveDataStrip() {
    const content = statusItems.map((item, index) => (
        <span key={index} className="inline-flex items-center gap-2 mx-8">
            <span className={`
        w-2 h-2 rounded-full animate-pulse
        ${item.type === "safe" ? "bg-cyber-cyan" :
                    item.type === "danger" ? "bg-signal-red" : "bg-white/50"}
      `} />
            <span className="text-white/60 uppercase">{item.location}</span>
            <span className={`
        font-bold uppercase
        ${item.type === "safe" ? "text-cyber-cyan" :
                    item.type === "danger" ? "text-signal-red" : "text-white"}
      `}>
                [{item.status}]
            </span>
            <span className="text-white/30">//</span>
        </span>
    ));

    return (
        <div className="w-full overflow-hidden bg-void-dark/80 backdrop-blur-sm border-y border-glass-border py-4">
            <div className="relative flex">
                {/* First set */}
                <motion.div
                    className="flex whitespace-nowrap text-mono"
                    animate={{ x: [0, "-50%"] }}
                    transition={{
                        x: {
                            repeat: Infinity,
                            repeatType: "loop",
                            duration: 30,
                            ease: "linear",
                        },
                    }}
                >
                    {content}
                    {content}
                </motion.div>
            </div>

            {/* Fade edges */}
            <div className="absolute left-0 top-0 bottom-0 w-20 bg-gradient-to-r from-void-dark to-transparent pointer-events-none" />
            <div className="absolute right-0 top-0 bottom-0 w-20 bg-gradient-to-l from-void-dark to-transparent pointer-events-none" />
        </div>
    );
}
