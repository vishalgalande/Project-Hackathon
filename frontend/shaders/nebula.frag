#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec2 uMouse;

out vec4 fragColor;

// Simplex 2D noise
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Deep Void Base
    vec3 color = vec3(0.02, 0.02, 0.02); // #050505 approximation
    
    // Nebula Smoke
    float scale = 3.0;
    float time = uTime * 0.2;
    
    // Layer 1: Purple Mist
    float n1 = snoise(uv * scale + vec2(time, time * 0.5));
    float mask1 = smoothstep(0.2, 0.8, n1);
    color = mix(color, vec3(0.54, 0.36, 0.96), mask1 * 0.15); // Purple #8B5CF6
    
    // Layer 2: Cyan Flow
    float n2 = snoise(uv * scale * 1.5 - vec2(time * 0.8, time));
    float mask2 = smoothstep(0.3, 0.9, n2);
    color = mix(color, vec3(0.0, 0.94, 1.0), mask2 * 0.15); // Cyan #00F0FF

    // Mouse Interaction (Subtle Repulsion/Glow)
    // Normalize mouse
    vec2 mouseUV = uMouse / uSize;
    float dist = distance(uv, mouseUV);
    float mouseGlow = 1.0 - smoothstep(0.0, 0.3, dist);
    color += vec3(0.54, 0.36, 0.96) * mouseGlow * 0.1;

    fragColor = vec4(color, 1.0);
}
