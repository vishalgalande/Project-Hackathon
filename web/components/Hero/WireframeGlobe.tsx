"use client";

import { useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { OrbitControls, Sphere, MeshDistortMaterial } from "@react-three/drei";
import * as THREE from "three";

function WireframeSphere() {
    const meshRef = useRef<THREE.Mesh>(null);
    const pointsRef = useRef<THREE.Points>(null);

    useFrame((state) => {
        if (meshRef.current) {
            meshRef.current.rotation.y += 0.002;
            meshRef.current.rotation.x += 0.001;
        }
        if (pointsRef.current) {
            pointsRef.current.rotation.y += 0.002;
            pointsRef.current.rotation.x += 0.001;
        }
    });

    // Create points for the globe
    const pointsGeometry = new THREE.SphereGeometry(2.2, 32, 32);

    return (
        <group>
            {/* Main wireframe sphere */}
            <mesh ref={meshRef}>
                <icosahedronGeometry args={[2, 8]} />
                <meshBasicMaterial
                    color="#00F0FF"
                    wireframe
                    transparent
                    opacity={0.3}
                />
            </mesh>

            {/* Inner solid glow */}
            <Sphere args={[1.8, 32, 32]}>
                <MeshDistortMaterial
                    color="#00F0FF"
                    transparent
                    opacity={0.08}
                    distort={0.3}
                    speed={1.5}
                />
            </Sphere>

            {/* Outer ring */}
            <mesh rotation={[Math.PI / 2, 0, 0]}>
                <torusGeometry args={[2.8, 0.02, 16, 100]} />
                <meshBasicMaterial color="#00F0FF" transparent opacity={0.5} />
            </mesh>

            {/* Secondary ring */}
            <mesh rotation={[Math.PI / 3, Math.PI / 4, 0]}>
                <torusGeometry args={[2.5, 0.015, 16, 100]} />
                <meshBasicMaterial color="#FF2E2E" transparent opacity={0.3} />
            </mesh>

            {/* Dots on surface */}
            <points ref={pointsRef} geometry={pointsGeometry}>
                <pointsMaterial
                    color="#00F0FF"
                    size={0.03}
                    transparent
                    opacity={0.6}
                    sizeAttenuation
                />
            </points>
        </group>
    );
}

export default function WireframeGlobe() {
    return (
        <div className="absolute inset-0 z-0">
            <Canvas
                camera={{ position: [0, 0, 6], fov: 50 }}
                style={{ background: "transparent" }}
            >
                <ambientLight intensity={0.5} />
                <pointLight position={[10, 10, 10]} intensity={1} color="#00F0FF" />
                <pointLight position={[-10, -10, -10]} intensity={0.5} color="#FF2E2E" />
                <WireframeSphere />
                <OrbitControls
                    enableZoom={false}
                    enablePan={false}
                    autoRotate
                    autoRotateSpeed={0.5}
                    maxPolarAngle={Math.PI / 2}
                    minPolarAngle={Math.PI / 2}
                />
            </Canvas>
        </div>
    );
}
