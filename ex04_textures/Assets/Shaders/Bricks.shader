Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
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

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float3 normal: TEXCOORD1;
                    float4 vertex: TEXCOORD2;
                    float4 tangent: TEXCOORD3;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.tangent = input.tangent;
                    output.vertex = input.vertex;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    bumpMapData bumpData;
                    bumpData.normal = input.normal;
                    bumpData.tangent = input.tangent;
                    bumpData.uv = input.uv;
                    bumpData.heightMap = _HeightMap;
                    bumpData.du = _HeightMap_TexelSize.x;
                    bumpData.dv = _HeightMap_TexelSize.y;
                    bumpData.bumpScale = _BumpScale / 10000;
                    float3 n = getBumpMappedNormal(bumpData);
                    float4 worldPosCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos);
                    float3 v = normalize(worldPosCamera - input.vertex);
                    float3 l = normalize(mul(unity_WorldToObject, _WorldSpaceLightPos0));
                  
                   
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);  
                    fixed4 specularity = tex2D(_SpecularMap, input.uv);
                    return fixed4(blinnPhong(n, v, l, _Shininess, albedo, specularity, _Ambient),1);
                }

            ENDCG
        }
    }
}
