"use client";

import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import { ChevronDown, MapPin, Zap, Lock, Globe } from "lucide-react";
import GlitchButton from "@/components/Hero/GlitchButton";
import MagneticWrapper from "@/components/Hero/MagneticWrapper";
import LiveDataStrip from "@/components/LiveDataStrip";
import BentoGrid from "@/components/BentoGrid/BentoGrid";
import GuardianToggle from "@/components/GuardianMode/GuardianToggle";

// Dynamic import for 3D component to avoid SSR issues
const WireframeGlobe = dynamic(
  () => import("@/components/Hero/WireframeGlobe"),
  { ssr: false }
);

export default function Home() {
  return (
    <main className="min-h-screen bg-void-black relative overflow-hidden">
      {/* Grid background overlay */}
      <div className="fixed inset-0 grid-bg pointer-events-none opacity-50" />

      {/* Hero Section */}
      <section className="relative min-h-screen flex flex-col items-center justify-center px-4">
        {/* 3D Globe */}
        <WireframeGlobe />

        {/* Hero Content */}
        <div className="relative z-10 text-center max-w-6xl mx-auto">
          {/* Tag line */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="flex items-center justify-center gap-2 mb-6"
          >
            <span className="w-8 h-[1px] bg-cyber-cyan" />
            <span className="text-mono text-cyber-cyan text-xs tracking-[0.3em] uppercase">
              Smart Tourist Safety System
            </span>
            <span className="w-8 h-[1px] bg-cyber-cyan" />
          </motion.div>

          {/* Main headline */}
          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="heading-hero text-white mb-4"
          >
            <span className="block">Invisible</span>
            <span className="block text-cyber-cyan text-glow-cyan">Shield.</span>
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
            className="text-white/60 text-lg md:text-xl max-w-2xl mx-auto mb-10"
          >
            AI-powered protection that travels with you. Real-time threat detection,
            dynamic geofencing, and blockchain-secured incident logs.
          </motion.p>

          {/* CTA Button */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
          >
            <MagneticWrapper strength={0.2}>
              <GlitchButton onClick={() => document.getElementById("features")?.scrollIntoView({ behavior: "smooth" })}>
                Initialize Tracking
              </GlitchButton>
            </MagneticWrapper>
          </motion.div>

          {/* Scroll indicator */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1.5 }}
            className="absolute bottom-10 left-1/2 -translate-x-1/2"
          >
            <motion.div
              animate={{ y: [0, 10, 0] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
              className="text-white/30"
            >
              <ChevronDown className="w-6 h-6" />
            </motion.div>
          </motion.div>
        </div>

        {/* Corner decorations */}
        <div className="absolute top-8 left-8 w-16 h-16 border-t border-l border-cyber-cyan/30" />
        <div className="absolute top-8 right-8 w-16 h-16 border-t border-r border-cyber-cyan/30" />
        <div className="absolute bottom-8 left-8 w-16 h-16 border-b border-l border-cyber-cyan/30" />
        <div className="absolute bottom-8 right-8 w-16 h-16 border-b border-r border-cyber-cyan/30" />

        {/* Status indicators */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 1 }}
          className="absolute left-8 top-1/2 -translate-y-1/2 hidden lg:flex flex-col gap-6"
        >
          {[
            { icon: <MapPin className="w-4 h-4" />, label: "GPS", status: "LOCKED" },
            { icon: <Zap className="w-4 h-4" />, label: "AI", status: "ONLINE" },
            { icon: <Lock className="w-4 h-4" />, label: "SEC", status: "MAX" },
          ].map((item, i) => (
            <div key={i} className="flex items-center gap-3 text-mono text-xs">
              <div className="text-cyber-cyan">{item.icon}</div>
              <div>
                <div className="text-white/40">{item.label}</div>
                <div className="text-cyber-cyan">{item.status}</div>
              </div>
            </div>
          ))}
        </motion.div>

        {/* Coordinates display */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 1 }}
          className="absolute right-8 top-1/2 -translate-y-1/2 hidden lg:block text-mono text-xs text-right"
        >
          <div className="text-white/40 mb-1">COORDINATES</div>
          <div className="text-cyber-cyan">26.9124° N</div>
          <div className="text-cyber-cyan">75.7873° E</div>
          <div className="text-white/20 mt-2 text-[10px]">JAIPUR, INDIA</div>
        </motion.div>
      </section>

      {/* Live Data Strip */}
      <LiveDataStrip />

      {/* Features Section */}
      <div id="features">
        <BentoGrid />
      </div>

      {/* Guardian Mode Section */}
      <GuardianToggle />

      {/* Stats Section */}
      <section className="py-20 px-4 md:px-8 lg:px-16 border-t border-glass-border">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="grid grid-cols-2 md:grid-cols-4 gap-8"
          >
            {[
              { value: "99.9%", label: "Uptime", suffix: "" },
              { value: "50", label: "Response Time", suffix: "ms" },
              { value: "10K", label: "Active Users", suffix: "+" },
              { value: "24", label: "Protected Zones", suffix: "" },
            ].map((stat, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: i * 0.1 }}
                className="text-center"
              >
                <div className="text-4xl md:text-5xl font-bold text-cyber-cyan text-glow-cyan">
                  {stat.value}
                  <span className="text-xl">{stat.suffix}</span>
                </div>
                <div className="text-mono text-xs text-white/50 uppercase tracking-widest mt-2">
                  {stat.label}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-4 md:px-8 lg:px-16 border-t border-glass-border">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-3">
            <Globe className="w-6 h-6 text-cyber-cyan" />
            <span className="text-xl font-bold">
              Safe<span className="text-cyber-cyan">Zone</span>
            </span>
          </div>

          <div className="text-mono text-xs text-white/40 text-center">
            © 2026 SafeZone Systems. All rights reserved.
            <br />
            <span className="text-cyber-cyan/50">HACKATHON PROJECT</span>
          </div>

          <div className="flex items-center gap-2 text-mono text-xs">
            <span className="w-2 h-2 bg-cyber-cyan rounded-full animate-pulse" />
            <span className="text-white/50">SYSTEM ONLINE</span>
          </div>
        </div>
      </footer>

      {/* Scanlines overlay */}
      <div className="fixed inset-0 pointer-events-none scanlines opacity-30" />
    </main>
  );
}
