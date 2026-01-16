"use client";

import { Suspense, useRef } from "react";
import dynamic from "next/dynamic";
import { useRouter } from "next/navigation";
import { motion, useScroll, useTransform } from "framer-motion";
import { Canvas } from "@react-three/fiber";
import { Map as MapIcon, Bus, ThumbsUp, AlertTriangle, ArrowRight, Activity, ChevronDown } from "lucide-react";

// Components
import SpotlightCard from "@/components/UI/SpotlightCard";
import LiquidButton from "@/components/UI/LiquidButton";
import LiveDataStrip from "@/components/LiveDataStrip";
import StaggeredText from "@/components/UI/StaggeredText";
import SuccessStats from "@/components/SuccessStats";
import GuardianToggle from "@/components/GuardianMode/GuardianToggle";

// Lazy Load Heavy 3D Background
const FluidParticles = dynamic(() => import("@/components/Hero/FluidParticles"), {
    ssr: false,
    loading: () => <div className="absolute inset-0 bg-black" />,
});

export default function Home() {
    const router = useRouter();
    const containerRef = useRef<HTMLElement>(null);
    const { scrollYProgress } = useScroll({ target: containerRef });

    const y = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]); // Parallax for Hero

    return (
        <main ref={containerRef} className="min-h-screen bg-[#050505] text-white selection:bg-purple-500 selection:text-white overflow-x-hidden">

            {/* 1. Immersive 3D Background */}
            <div className="fixed inset-0 z-0 pointer-events-none">
                <Canvas camera={{ position: [0, 0, 15], fov: 45 }} dpr={[1, 1.5]} performance={{ min: 0.5 }}>
                    <Suspense fallback={null}>
                        <FluidParticles />
                    </Suspense>
                    <ambientLight intensity={0.5} />
                </Canvas>
                {/* Vignette Overlay */}
                <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_0%,#050505_90%)]" />
            </div>

            {/* 2. Hero Section (Parallax) */}
            <motion.section style={{ y }} className="relative z-10 min-h-screen flex flex-col items-center justify-center px-6 text-center">

                {/* Dynamic Glowing Aura */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-purple-600/20 blur-[120px] rounded-full mix-blend-screen animate-pulse-slow" />

                {/* Badge */}
                <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.5 }}
                    className="mb-8 px-4 py-1.5 rounded-full border border-white/10 bg-white/5 backdrop-blur-md text-xs font-mono uppercase tracking-widest text-[#00F0FF] shadow-[0_0_20px_rgba(0,240,255,0.2)]"
                >
                    System Online • v2.4.0
                </motion.div>

                {/* Main Title (Staggered Reveal) */}
                <div className="relative mb-6">
                    <h1 className="text-6xl md:text-8xl font-black tracking-tight leading-tight">
                        <div className="overflow-hidden">
                            <StaggeredText text="Navigate India" className="text-white drop-shadow-2xl" />
                        </div>
                        <div className="overflow-hidden mt-2">
                            <motion.span
                                initial={{ opacity: 0, y: 100 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.8, duration: 0.8, ease: "circOut" }}
                                className="inline-block text-transparent bg-clip-text bg-gradient-to-r from-[#8B5CF6] to-[#00F0FF] pb-4"
                            >
                                Safely
                            </motion.span>
                        </div>
                    </h1>
                </div>

                {/* Subtitle */}
                <motion.p
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 1.2, duration: 1 }}
                    className="max-w-2xl text-lg md:text-xl text-white/60 mb-12 leading-relaxed"
                >
                    Real-time crowd-sourced safety zones and AI-powered transit tracking.
                    Explore the world with an invisible shield.
                </motion.p>

                {/* CTA Buttons */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 1.4 }}
                    className="flex flex-col sm:flex-row gap-6"
                >
                    <LiquidButton onClick={() => router.push('/geofencing')}>
                        Explore Safety Zones
                    </LiquidButton>

                    <button
                        onClick={() => document.getElementById("features")?.scrollIntoView({ behavior: "smooth" })}
                        className="group px-8 py-4 rounded-lg border border-white/10 hover:bg-white/5 transition-all flex items-center gap-2"
                    >
                        Learn More <ChevronDown className="w-4 h-4 group-hover:translate-y-1 transition-transform" />
                    </button>
                </motion.div>
            </motion.section>

            {/* 3. Live Status Strip */}
            <section className="relative z-20 border-y border-white/5 bg-black/50 backdrop-blur-lg">
                <LiveDataStrip />
            </section>

            {/* 4. Features Grid (Igloo Style) */}
            <section id="features" className="relative z-20 py-32 px-6 max-w-7xl mx-auto">
                <motion.div
                    initial={{ opacity: 0, y: 40 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true, margin: "-100px" }}
                    className="text-center mb-20"
                >
                    <h2 className="text-4xl md:text-5xl font-bold mb-6">Premium Utility</h2>
                    <p className="text-white/50 max-w-xl mx-auto">
                        Advanced tools engineered for the modern traveler.
                    </p>
                </motion.div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {/* Feature 1: Safety Zones */}
                    <SpotlightCard className="h-[400px]" spotlightColor="rgba(0, 240, 255, 0.2)">
                        <div className="h-full flex flex-col justify-between">
                            <div>
                                <div className="flex justify-between items-start mb-6">
                                    <div className="p-3 bg-white/5 rounded-lg border border-white/10">
                                        <MapIcon className="w-8 h-8 text-[#00F0FF]" />
                                    </div>
                                    <span className="px-3 py-1 bg-green-500/10 border border-green-500/20 text-green-400 text-xs font-mono rounded-full animate-pulse">
                                        LIVE
                                    </span>
                                </div>
                                <h3 className="text-2xl font-bold mb-3 group-hover:text-[#00F0FF] transition-colors">Safety Zones</h3>
                                <p className="text-white/60 leading-relaxed">
                                    View real-time safety ratings for areas across Delhi. Community-powered heatmaps show you where to go and what to avoid.
                                </p>
                            </div>
                            <div className="flex items-center text-sm font-mono text-white/40 group-hover:text-white transition-colors">
                                OPEN MAP <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                            </div>
                            <button
                                onClick={() => router.push('/geofencing')}
                                className="absolute inset-0 z-10 cursor-pointer"
                                aria-label="Open Safety Map"
                            />
                        </div>
                    </SpotlightCard>

                    {/* Feature 2: Transit Tracker */}
                    <SpotlightCard className="h-[400px]" spotlightColor="rgba(139, 92, 246, 0.2)">
                        <div className="h-full flex flex-col justify-between">
                            <div>
                                <div className="flex justify-between items-start mb-6">
                                    <div className="p-3 bg-white/5 rounded-lg border border-white/10">
                                        <Bus className="w-8 h-8 text-purple-500" />
                                    </div>
                                    <span className="px-3 py-1 bg-purple-500/10 border border-purple-500/20 text-purple-400 text-xs font-mono rounded-full">
                                        BETA
                                    </span>
                                </div>
                                <h3 className="text-2xl font-bold mb-3 group-hover:text-purple-400 transition-colors">Transit Tracker</h3>
                                <p className="text-white/60 leading-relaxed">
                                    Track public transportation in real-time. Find bus routes, train schedules, and live vehicle positions with AI prediction.
                                </p>
                            </div>
                            <div className="flex items-center text-sm font-mono text-white/40 group-hover:text-white transition-colors">
                                TRACK NOW <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                            </div>
                            <button className="absolute inset-0 z-10 cursor-pointer" />
                        </div>
                    </SpotlightCard>

                    {/* Feature 3: Community Voting */}
                    <SpotlightCard className="h-[300px]" spotlightColor="rgba(255, 255, 255, 0.1)">
                        <div className="h-full flex flex-col justify-between">
                            <div className="p-3 w-fit bg-white/5 rounded-lg border border-white/10 mb-6">
                                <ThumbsUp className="w-6 h-6 text-white" />
                            </div>
                            <div>
                                <h3 className="text-xl font-bold mb-2">Community Voting</h3>
                                <p className="text-sm text-white/50">
                                    Crowdsourced safety. Upvote safe zones and report incidents to warn others.
                                </p>
                            </div>
                        </div>
                    </SpotlightCard>

                    {/* Feature 4: SOS */}
                    <SpotlightCard className="h-[300px]" spotlightColor="rgba(239, 68, 68, 0.3)">
                        <div className="h-full flex flex-col justify-between">
                            <div className="flex justify-between items-start">
                                <div className="p-3 w-fit bg-red-500/10 rounded-lg border border-red-500/20 mb-6">
                                    <AlertTriangle className="w-6 h-6 text-red-500" />
                                </div>
                                <Activity className="w-4 h-4 text-red-500 animate-pulse" />
                            </div>
                            <div>
                                <h3 className="text-xl font-bold mb-2 text-red-100">Emergency SOS</h3>
                                <p className="text-sm text-white/50">
                                    One-tap emergency beacon. Instantly share your location with authorities and trusted contacts.
                                </p>
                            </div>
                            <button
                                onClick={() => router.push('/sos')}
                                className="absolute inset-0 z-10 cursor-pointer"
                            />
                        </div>
                    </SpotlightCard>
                </div>
            </section>

            {/* 5. Guardian Mode */}
            <section className="relative z-20 py-20 px-6 max-w-7xl mx-auto">
                <GuardianToggle />
            </section>

            {/* 6. Stats Section */}
            <section className="relative z-20 py-20 border-t border-white/5 bg-black/40 backdrop-blur-sm">
                <SuccessStats />
            </section>

            {/* Footer */}
            <footer className="py-10 border-t border-white/5 text-center text-white/20 text-sm font-mono relative z-20">
                <p>BUILT FOR HACKATHON 2026 • SAFETRAVEL INDIA</p>
            </footer>

        </main>
    );
}
