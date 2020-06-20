Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD1;
                    float3 normal   : TEXCOORD2;
                    float3 vertex   : TEXCOORD3;
                    float3 tangent   : TEXCOORD4;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    float c = perlin3d(float3((0.5 * uv.x), (0.5 * uv.y) , (0.5 * t)));
                    float c1 = perlin3d(float3(uv,t));
                    float c2 = perlin3d(float3((2 * uv.x), (2 * uv.y), (3 * t)));
                    return c + (0.5 * c1) + (0.2 * c2);
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    float f_du = (waterNoise((i.uv + i.du), t) - waterNoise(i.uv, t)) / i.du;
                    float f_dv = (waterNoise((i.uv+i.dv), t) - waterNoise(i.uv, t)) / i.dv;
                   
                    float3 n_h = normalize(float3(-i.bumpScale * f_du, -i.bumpScale * f_dv, 1));
                    
                    float3 n_world = mul(unity_ObjectToWorld, i.normal);
                    float3 t_world = mul(unity_ObjectToWorld, i.tangent);
                    float3 b = cross(t_world, n_world);
                    
                    float3 world_nh = n_h.x*t_world + n_h.y*b + n_h.z*n_world;
                    return normalize(world_nh);
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.uv = input.uv;
                    output.vertex = input.vertex;
                    output.normal = input.normal;
                    output.tangent = input.tangent;
                    float2 uv = _NoiseScale * input.uv;
                    float c = waterNoise(uv, (_Time.y * _TimeScale)) * _BumpScale;
                    float y = input.vertex.y + c;
                    output.pos = UnityObjectToClipPos(float3(input.vertex.x , y, input.vertex.z));
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float2 uv = (input.uv * _NoiseScale);
                    bumpMapData bumpData;
                    bumpData.normal = normalize(input.normal);
                    bumpData.tangent = input.tangent;
                    bumpData.uv = uv;
                    bumpData.du = DELTA;
                    bumpData.dv = DELTA;
                    bumpData.bumpScale = _BumpScale;
                    float3 n = getWaterBumpMappedNormal(bumpData, (_Time.y * _TimeScale));
                    float4 worldPosCamera = mul(unity_ObjectToWorld, input.vertex);
                    float3 v = normalize(_WorldSpaceCameraPos - worldPosCamera);
                    
                    float3 reflection = ((2 * dot(v, n)) * n) - v;
                    fixed4 r = texCUBE( _CubeMap, reflection);
                    
                    fixed4 color = (1- max(0, dot(n,v))+ 0.2) *  r;
                    return color;
                }

            ENDCG
        }
    }
}