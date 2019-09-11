
#include <metal_stdlib>

using namespace metal;

float mod(float x, float y) {
    return x - y * floor(x / y);
}
float2 mod(float2 x, float2 y) {
    return x - y * floor(x / y);
}
float3 mod(float3 x, float3 y) {
    return x - y * floor(x / y);
}
float4 mod(float4 x, float4 y) {
    return x - y * floor(x / y);
}
float2 mirrored(float2 v) {
    float2 m = mod(v,2.);
    return mix(m,2.0 - m, step(1.0 ,m));
}

float4 permute(float4 x) {return mod(((x*34.0)+1.0)*x, 289.0);}
float4 taylorInvSqrt(float4 r) {return 1.79284291400159 - 0.85373472095314 * r;}
float3 fade(float3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}


float cnoise(float3 P) {
  float3 Pi0 = floor(P); // Integer part for indexing
  float3 Pi1 = Pi0 + float3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  float3 Pf0 = fract(P); // Fractional part for interpolation
  float3 Pf1 = Pf0 - float3(1.0); // Fractional part - 1.0
  float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  float4 iy = float4(Pi0.yy, Pi1.yy);
  float4 iz0 = Pi0.zzzz;
  float4 iz1 = Pi1.zzzz;

  float4 ixy = permute(permute(ix) + iy);
  float4 ixy0 = permute(ixy + iz0);
  float4 ixy1 = permute(ixy + iz1);

  float4 gx0 = ixy0 / 7.0;
  float4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  float4 gz0 = float4(0.5) - abs(gx0) - abs(gy0);
  float4 sz0 = step(gz0, float4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  float4 gx1 = ixy1 / 7.0;
  float4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  float4 gz1 = float4(0.5) - abs(gx1) - abs(gy1);
  float4 sz1 = step(gz1, float4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  float3 g000 = float3(gx0.x,gy0.x,gz0.x);
  float3 g100 = float3(gx0.y,gy0.y,gz0.y);
  float3 g010 = float3(gx0.z,gy0.z,gz0.z);
  float3 g110 = float3(gx0.w,gy0.w,gz0.w);
  float3 g001 = float3(gx1.x,gy1.x,gz1.x);
  float3 g101 = float3(gx1.y,gy1.y,gz1.y);
  float3 g011 = float3(gx1.z,gy1.z,gz1.z);
  float3 g111 = float3(gx1.w,gy1.w,gz1.w);

  float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  float3 fade_xyz = fade(Pf0);
  float4 n_z = mix(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
  float2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2 * n_xyz;
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::sample> fromInput [[texture(1)]],
                    texture2d<float, access::sample> toInput [[texture(2)]],
                    constant float &timer [[buffer(0)]],
                    constant float &progress [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]])
{
  int width = fromInput.get_width();
  int height = fromInput.get_height();
  float2 uv = float2(gid) / float2(width, height);
  constexpr sampler textureSampler(coord::normalized,
                                   min_filter::linear,
                                   mag_filter::linear,
                                   mip_filter::linear);

  float noise = uv.y + 0.5 * (cnoise(float3(uv.x * 3.0, uv.y * 3.0, timer * 0.25)));
  uv = mirrored(float2(uv.x, noise));
  float4 color1 = fromInput.sample(textureSampler, uv);
  float4 color2 = toInput.sample(textureSampler, uv);
  float4 color = mix(color1, color2, progress);
  output.write(color, gid);
}
