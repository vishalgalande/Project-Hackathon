"use client";

import React, { useState } from 'react';
import { MapPin, Shield, AlertTriangle } from 'lucide-react';
import LoadingScreen from '@/components/Loading/LoadingScreen';

export default function GeofencingPage() {
    const [isLoading, setIsLoading] = useState(true);

    return (
        <main className="min-h-screen bg-void-black text-white relative overflow-hidden">
            {/* Grid background overlay */}
            <div className="fixed inset-0 grid-bg pointer-events-none opacity-50" />

            {/* Loading Screen Integration */}
            {isLoading && (
                <LoadingScreen
                    onLoadingComplete={() => setIsLoading(false)}
                    minDuration={3000}
                />
            )}

            {/* Main Content (Visible after loading) */}
            <div className={`transition-opacity duration-1000 ${isLoading ? 'opacity-0' : 'opacity-100'}`}>

                {/* Header */}
                <header className="p-6 md:p-8 flex justify-between items-center bg-void-black/80 backdrop-blur-md border-b border-white/10 relative z-10">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-primary/20 flex items-center justify-center border border-primary/50">
                            <MapPin className="text-primary w-6 h-6" />
                        </div>
                        <div>
                            <h1 className="text-xl font-bold font-display uppercase tracking-wider">
                                Geofence <span className="text-primary text-glow-primary">Matrix</span>
                            </h1>
                            <div className="flex items-center gap-2 text-xs text-mono text-white/50">
                                <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
                                LIVE TRACKING ACTIVE
                            </div>
                        </div>
                    </div>
                    <button
                        onClick={() => window.location.href = '/'}
                        className="px-4 py-2 border border-white/20 rounded hover:bg-white/10 transition-colors text-mono text-xs"
                    >
                        RETURN TO HUB
                    </button>
                </header>

                {/* Dashboard Content */}
                <div className="p-6 md:p-8 max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-6 relative z-10">

                    {/* Map View Placeholder */}
                    <div className="lg:col-span-2 h-[60vh] bg-void-gray/50 rounded-2xl border border-white/10 relative overflow-hidden group">
                        <div className="absolute inset-0 flex items-center justify-center">
                            <div className="text-center">
                                <div className="w-24 h-24 mx-auto mb-4 border-2 border-primary/30 rounded-full flex items-center justify-center animate-pulse">
                                    <MapPin className="w-12 h-12 text-primary" />
                                </div>
                                <h3 className="text-lg font-bold text-white/80">SAFEZONE MAP</h3>
                                <p className="text-mono text-xs text-primary mt-2">INITIALIZING SATELLITE FEED...</p>
                            </div>
                        </div>

                        {/* HUD Elements */}
                        <div className="absolute top-4 left-4 p-2 bg-black/60 rounded border border-primary/30 text-mono text-xs">
                            DIV: RAJASTHAN
                            <br />
                            SEC: JAIPUR-01
                        </div>

                        <div className="absolute bottom-4 right-4 flex gap-2">
                            <div className="px-3 py-1 bg-primary/20 border border-primary text-primary text-mono text-xs rounded">
                                ZONES: 24
                            </div>
                            <div className="px-3 py-1 bg-red-500/20 border border-red-500 text-red-500 text-mono text-xs rounded flex items-center gap-1">
                                <AlertTriangle className="w-3 h-3" /> THREATS: 0
                            </div>
                        </div>

                        {/* Scanline */}
                        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-primary/5 to-transparent h-[20%] w-full animate-[scan_4s_linear_infinite] pointer-events-none" />
                    </div>

                    {/* Sidebar Info */}
                    <div className="space-y-6">
                        {/* Status Card */}
                        <div className="p-6 bg-void-gray/30 rounded-2xl border border-white/10">
                            <h3 className="text-mono text-xs text-white/40 uppercase tracking-widest mb-4">System Status</h3>
                            <div className="space-y-4">
                                <div className="flex justify-between items-center">
                                    <span className="text-sm">Geofence Enforcement</span>
                                    <span className="text-primary text-xs font-bold bg-primary/10 px-2 py-1 rounded border border-primary/30">ACTIVE</span>
                                </div>
                                <div className="flex justify-between items-center">
                                    <span className="text-sm">Threat Detection</span>
                                    <span className="text-primary text-xs font-bold bg-primary/10 px-2 py-1 rounded border border-primary/30">ONLINE</span>
                                </div>
                                <div className="flex justify-between items-center">
                                    <span className="text-sm">User Location</span>
                                    <span className="text-white/60 text-xs font-mono">26.9124° N, 75.7873° E</span>
                                </div>
                            </div>
                        </div>

                        {/* Recent Alerts */}
                        <div className="p-6 bg-void-gray/30 rounded-2xl border border-white/10 flex-1">
                            <h3 className="text-mono text-xs text-white/40 uppercase tracking-widest mb-4">Live Feed</h3>
                            <div className="space-y-3">
                                {[1, 2, 3].map((i) => (
                                    <div key={i} className="flex items-start gap-3 p-3 bg-black/40 rounded border border-white/5">
                                        <Shield className="w-4 h-4 text-primary mt-1" />
                                        <div>
                                            <div className="text-xs text-white/80">Zone Entry: Hotel Clarks Amer</div>
                                            <div className="text-[10px] text-white/40 font-mono mt-1">LOG_ID: 8X92_{i} • 2s ago</div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    );
}
