'use client';

import { motion } from 'framer-motion';
import { Github, Linkedin, Shield, Terminal, Zap, Code, FlaskConical, Cpu, Users, Mail, ExternalLink } from 'lucide-react';
import { useState } from 'react';
import Link from 'next/link';

// Team Data
const TEAM_MEMBERS = [
  {
    name: 'Shubham Poddar',
    role: 'B.Tech Mechatronics',
    university: 'Manipal University',
    icon: <Cpu className="w-6 h-6 text-purple-400" />,
    description: 'Specializing in robotics and integrated systems.',
    socials: { linkedin: '#', github: '#' }
  },
  {
    name: 'Neel Pattel',
    role: 'B.Tech Chemical',
    university: 'Manipal University',
    icon: <FlaskConical className="w-6 h-6 text-emerald-400" />,
    description: 'Process optimization and material science expert.',
    socials: { linkedin: '#', github: '#' }
  },
  {
    name: 'Prajnadeep Sarma',
    role: 'B.Tech Computer Science',
    university: 'Manipal University',
    icon: <Terminal className="w-6 h-6 text-blue-400" />,
    description: 'Full-stack development and cloud architecture.',
    socials: { linkedin: '#', github: '#' }
  },
  {
    name: 'Vishal Galande',
    role: 'B.Tech Computer Science',
    university: 'Manipal University',
    icon: <Code className="w-6 h-6 text-pink-400" />,
    description: 'Frontend wizard and UI/UX enthusiast.',
    socials: { linkedin: '#', github: '#' }
  }
];

export default function Home() {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <main className="min-h-screen bg-[#050505] text-white selection:bg-purple-500 selection:text-white overflow-hidden relative">

      {/* Background Elements */}
      <div className="fixed inset-0 z-0 pointer-events-none">
        <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-purple-900/20 via-black to-black opacity-60"></div>
        <div className="absolute bottom-0 right-0 w-[500px] h-[500px] bg-blue-600/10 blur-[120px] rounded-full"></div>
      </div>

      {/* Hero Section */}
      <section className="relative z-10 min-h-screen flex flex-col items-center justify-center px-6 pt-20 pb-32 text-center">

        {/* Main Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.8 }}
          className="text-7xl md:text-9xl font-black tracking-tight mb-4 text-transparent bg-clip-text bg-gradient-to-b from-white to-white/40"
        >
          TEAM<br />STRAWHATS
        </motion.h1>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5, duration: 0.8 }}
          className="text-xl text-white/50 max-w-2xl mx-auto mb-8 font-light"
        >
          A decentralized collective of engineers from Manipal University.
        </motion.p>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.7 }}
          className="mb-16 flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-sm text-white/60 hover:text-white transition-colors"
        >
          <Mail className="w-4 h-4" />
          <a href="mailto:support@strawhats.live">support@strawhats.live</a>
        </motion.div>

        {/* Team Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 w-full max-w-7xl mx-auto px-4">
          {TEAM_MEMBERS.map((member, idx) => (
            <motion.div
              key={idx}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 + (idx * 0.1) }}
              onMouseEnter={() => setHoveredIndex(idx)}
              onMouseLeave={() => setHoveredIndex(null)}
              className="group relative h-[350px] rounded-2xl bg-white/5 border border-white/5 overflow-hidden transition-all duration-300 hover:border-white/20 hover:bg-white/10"
            >
              <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/80 z-0"></div>

              <div className="relative z-10 h-full p-6 flex flex-col justify-between">
                <div>
                  <div className="p-3 w-fit rounded-xl bg-white/5 border border-white/10 mb-4 group-hover:scale-110 transition-transform duration-300">
                    {member.icon}
                  </div>
                  <h3 className="text-xl font-bold text-white mb-1 leading-tight">{member.name}</h3>
                  <p className="text-sm font-semi-bold text-white/80">{member.role}</p>
                  <p className="text-xs font-mono text-white/40 mt-1">{member.university}</p>
                </div>

                <div>
                  <p className="text-sm text-white/60 mb-6 leading-relaxed line-clamp-3">
                    {member.description}
                  </p>

                  <div className="flex gap-4">
                    <a href={member.socials.linkedin} className="text-white/40 hover:text-[#0077b5] transition-colors">
                      <Linkedin className="w-5 h-5" />
                    </a>
                    <a href={member.socials.github} className="text-white/40 hover:text-white transition-colors">
                      <Github className="w-5 h-5" />
                    </a>
                  </div>
                </div>
              </div>

              {/* Hover Effect Light */}
              <div className={`absolute top-0 left-0 w-full h-full bg-gradient-to-b from-white/5 to-transparent pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-500`} />
            </motion.div>
          ))}
        </div>
      </section>

      {/* Project Section */}
      <section className="relative z-10 py-32 px-6 border-t border-white/5 bg-black/40 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

            <motion.div
              initial={{ opacity: 0, x: -50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
            >
              <div className="flex items-center gap-3 mb-6 text-[#00F0FF]">
                <Shield className="w-6 h-6 animate-pulse" />
                <span className="text-sm font-mono tracking-widest uppercase">Project Showcase</span>
              </div>
              <h2 className="text-5xl font-bold mb-6">SafeTravel &<br />Geofencing</h2>
              <p className="text-white/60 text-lg leading-relaxed mb-8">
                An advanced AI-powered safety navigation system designed to protect travelers in real-time.
                Featuring dynamic geofencing, crowd-sourced danger zones, and live transit tracking.
              </p>

              <div className="flex flex-wrap gap-4 mb-10">
                <a
                  href="https://safetravel.strawhats.live"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-6 py-3 rounded-lg bg-[#00F0FF]/10 border border-[#00F0FF]/20 text-[#00F0FF] hover:bg-[#00F0FF]/20 transition-all font-bold"
                >
                  safetravel.strawhats.live <ExternalLink className="w-4 h-4" />
                </a>
              </div>

              <div className="flex gap-4 text-sm font-mono text-white/40">
                <div className="px-4 py-2 rounded-full border border-white/10 bg-white/5">
                  #NextJS
                </div>
                <div className="px-4 py-2 rounded-full border border-white/10 bg-white/5">
                  #AI
                </div>
                <div className="px-4 py-2 rounded-full border border-white/10 bg-white/5">
                  #Safety
                </div>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              viewport={{ once: true }}
              className="relative"
            >
              {/* Abstract Visual Representation of Project */}
              <div className="aspect-video rounded-2xl border border-white/10 bg-white/5 overflow-hidden flex items-center justify-center relative group cursor-pointer" onClick={() => window.open('https://safetravel.strawhats.live', '_blank')}>
                <div className="absolute inset-0 bg-gradient-to-tr from-purple-500/20 to-blue-500/20 opacity-50 group-hover:opacity-100 transition-opacity duration-500"></div>

                <div className="relative z-10 text-center">
                  <Users className="w-16 h-16 text-white/20 mx-auto mb-4" />
                  <p className="text-white/40 font-mono group-hover:text-white transition-colors">VISIT PROJECT</p>
                </div>

                {/* Decorative Elements */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[120%] h-[120%] border border-white/5 rounded-full animate-[spin_10s_linear_infinite]"></div>
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[80%] h-[80%] border border-white/5 rounded-full animate-[spin_15s_linear_infinite_reverse]"></div>
              </div>
            </motion.div>

          </div>
        </div>
      </section>

      <footer className="py-8 text-center text-white/20 text-xs font-mono border-t border-white/5">
        &copy; 2026 TEAM STRAWHATS • MANIPAL UNIVERSITY
      </footer>
    </main>
  );
}
