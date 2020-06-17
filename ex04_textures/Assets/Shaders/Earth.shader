Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 worldPos: TEXCOORD0;
                    float4 objectPos: TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.worldPos = mul(unity_ObjectToWorld, input.vertex);
                    output.objectPos = input.vertex;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 normal = normalize(float3(input.objectPos.xyz));
                    float2 uv = getSphericalUV(input.objectPos);
                    bumpMapData bumpData;
                    bumpData.normal = normal;
                    bumpData.tangent = cross(normal, float3(0,1,0));
                    bumpData.uv = uv;
                    bumpData.heightMap = _HeightMap;
                    bumpData.du = _HeightMap_TexelSize.x;
                    bumpData.dv = _HeightMap_TexelSize.y;
                    bumpData.bumpScale = _BumpScale / 10000;
                    float3 n = getBumpMappedNormal(bumpData);
                    float4 worldPosCamera = mul(unity_ObjectToWorld, input.objectPos);
                    float3 v = normalize(_WorldSpaceCameraPos - worldPosCamera);
                    float3 l = normalize(_WorldSpaceLightPos0);
                  
                   
                    fixed4 albedo = tex2D(_AlbedoMap, uv);  
                    fixed4 specularity = tex2D(_SpecularMap, uv);
                
                    n = (1 - specularity) * n + (specularity * normal);
                    float lambert = max(0, dot(normal, l));
                    fixed3 atmosphere = (1- max(0, dot(n, v))) * sqrt(lambert) * _AtmosphereColor;
                    fixed3 clouds = tex2D(_CloudMap,uv) * (sqrt(lambert)+_Ambient);
                    return fixed4(blinnPhong(n, v, l, _Shininess, albedo, specularity, _Ambient) + atmosphere + clouds ,1);   
                }

            ENDCG
        }
    }
}
