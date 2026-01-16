"use client";

import { useRef, useMemo } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import * as THREE from "three";

function LoadingSphere() {
    const meshRef = useRef<THREE.Mesh>(null);
    const pointsRef = useRef<THREE.Points>(null);
    const ringRef1 = useRef<THREE.Mesh>(null);
    const ringRef2 = useRef<THREE.Mesh>(null);

    // Create points geometry once
    const pointsGeometry = useMemo(() => new THREE.IcosahedronGeometry(1.5, 2), []);

    useFrame((state) => {
        const time = state.clock.getElapsedTime();

        if (meshRef.current) {
            meshRef.current.rotation.y = time * 0.5;
            meshRef.current.rotation.x = time * 0.2;
        }
        if (pointsRef.current) {
            pointsRef.current.rotation.y = time * 0.3;
            pointsRef.current.rotation.z = time * 0.1;
        }
        if (ringRef1.current) {
            ringRef1.current.rotation.z = time * 0.8;
        }
        if (ringRef2.current) {
            ringRef2.current.rotation.z = -time * 0.6;
        }
    });

    return (
        <group scale={0.8}>
            {/* Main wireframe sphere */}
            <mesh ref={meshRef}>
                <icosahedronGeometry args={[1.5, 3]} />
                <meshBasicMaterial
                    color="#6366f1"
                    wireframe
                    transparent
                    opacity={0.4}
                />
            </mesh>

            {/* Inner glow core */}
            <mesh>
                <sphereGeometry args={[0.5, 16, 16]} />
                <meshBasicMaterial
                    color="#6366f1"
                    transparent
                    opacity={0.3}
                />
            </mesh>

            {/* Outer ring 1 */}
            <mesh ref={ringRef1} rotation={[Math.PI / 2, 0, 0]}>
                <torusGeometry args={[2, 0.02, 16, 64]} />
                <meshBasicMaterial color="#6366f1" transparent opacity={0.6} />
            </mesh>

            {/* Outer ring 2 */}
            <mesh ref={ringRef2} rotation={[Math.PI / 3, Math.PI / 4, 0]}>
                <torusGeometry args={[1.8, 0.015, 16, 64]} />
                <meshBasicMaterial color="#a855f7" transparent opacity={0.4} />
            </mesh>

            {/* Dots on surface */}
            <points ref={pointsRef} geometry={pointsGeometry}>
                <pointsMaterial
                    color="#6366f1"
                    size={0.05}
                    transparent
                    opacity={0.8}
                    sizeAttenuation
                />
            </points>
        </group>
    );
}

export default function LoadingGlobe() {
    return (
        <div className="w-48 h-48 md:w-64 md:h-64">
            <Canvas
                camera={{ position: [0, 0, 5], fov: 45 }}
                style={{ background: "transparent" }}
                gl={{ antialias: true, alpha: true }}
            >
                <ambientLight intensity={0.5} />
                <pointLight position={[5, 5, 5]} intensity={1} color="#6366f1" />
                <pointLight position={[-5, -5, -5]} intensity={0.5} color="#a855f7" />
                <LoadingSphere />
            </Canvas>
        </div>
    );
}
