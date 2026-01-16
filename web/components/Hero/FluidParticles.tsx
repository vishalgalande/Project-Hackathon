"use client";

import { useRef, useMemo, useEffect } from "react";
import { useFrame, useThree } from "@react-three/fiber";
import * as THREE from "three";

const particleCount = 2000; // Optimized count for mobile/desktop balance
const connectionDistance = 2; // Distance to connect particles

export default function FluidParticles() {
    const meshRef = useRef<THREE.InstancedMesh>(null);
    const { viewport, size } = useThree();

    // Mouse position ref (normalized -1 to 1)
    const mouse = useRef(new THREE.Vector2(0, 0));

    // Initialize particles
    const particles = useMemo(() => {
        const temp = [];
        for (let i = 0; i < particleCount; i++) {
            const x = (Math.random() - 0.5) * 50; // Wide spread
            const y = (Math.random() - 0.5) * 50;
            const z = (Math.random() - 0.5) * 10;
            const speed = Math.random() * 0.05 + 0.01;
            const factor = Math.random() + 0.5; // Size factor
            temp.push({
                position: new THREE.Vector3(x, y, z),
                velocity: new THREE.Vector3(0, 0, 0),
                originalPos: new THREE.Vector3(x, y, z),
                speed,
                factor
            });
        }
        return temp;
    }, []);

    // Dummy object for instanced mesh matrix updates
    const dummy = useMemo(() => new THREE.Object3D(), []);

    // Handle mouse movement
    useEffect(() => {
        const handleMouseMove = (event: MouseEvent) => {
            // Normalize mouse to -1 to 1 based on canvas size
            mouse.current.x = (event.clientX / size.width) * 2 - 1;
            mouse.current.y = -(event.clientY / size.height) * 2 + 1;
        };
        window.addEventListener("mousemove", handleMouseMove);
        return () => window.removeEventListener("mousemove", handleMouseMove);
    }, [size]);

    useFrame((state) => {
        if (!meshRef.current) return;

        const time = state.clock.getElapsedTime();

        particles.forEach((particle, i) => {
            // 1. Flow Field Logic (Simulated)
            // Wavy motion based on time and position
            particle.position.y += Math.sin(time * 0.5 + particle.position.x * 0.2) * 0.02;
            particle.position.x += Math.cos(time * 0.3 + particle.position.y * 0.2) * 0.02;

            // 2. Mouse Interaction (Repulsion/Attraction)
            // Convert mouse screen pos to world pos loosely
            const mouseX = mouse.current.x * (viewport.width / 2);
            const mouseY = mouse.current.y * (viewport.height / 2);

            const dx = mouseX - particle.position.x;
            const dy = mouseY - particle.position.y;
            const dist = Math.sqrt(dx * dx + dy * dy);

            if (dist < 5) {
                // Repel
                const force = (5 - dist) * 0.02;
                particle.velocity.x -= dx * force;
                particle.velocity.y -= dy * force;
            }

            // Apply velocity and friction
            particle.position.add(particle.velocity);
            particle.velocity.multiplyScalar(0.95); // Friction

            // Return to original flow (Elasticity)
            // particle.position.lerp(particle.originalPos, 0.01); // Too rigid, let them float

            // Reset if out of bounds (Looping)
            if (Math.abs(particle.position.x) > 25) particle.position.x *= -1;
            if (Math.abs(particle.position.y) > 25) particle.position.y *= -1;

            // Update Matrix
            dummy.position.copy(particle.position);

            // Dynamic Scale based on velocity or position
            const scale = particle.factor * (1 + Math.sin(time * 2 + i) * 0.2);
            dummy.scale.set(scale, scale, scale);

            dummy.updateMatrix();
            meshRef.current!.setMatrixAt(i, dummy.matrix);

            // Dynamic Color (Instance Color) - Optional, heavier on GPU
            // Could use setColorAt if needed
        });

        meshRef.current.instanceMatrix.needsUpdate = true;
    });

    return (
        <instancedMesh ref={meshRef} args={[undefined, undefined, particleCount]}>
            <dodecahedronGeometry args={[0.05, 0]} />
            {/* Premium Material: Glowing Points */}
            <meshStandardMaterial
                color="#8B5CF6" // Neon Purple Base
                emissive="#00F0FF" // Cyber Blue Glow
                emissiveIntensity={2}
                toneMapped={false}
                roughness={0}
                metalness={1}
            />
        </instancedMesh>
    );
}
