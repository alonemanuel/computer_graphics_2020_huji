Shader "CG/BlinnPhong"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (0.14, 0.43, 0.84, 1)
        _SpecularColor ("Specular Color", Color) = (0.7, 0.7, 0.7, 1)
        _AmbientColor ("Ambient Color", Color) = (0.05, 0.13, 0.25, 1)
        _Shininess ("Shininess", Range(0.1, 50)) = 10
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

                // From UnityCG
                uniform fixed4 _LightColor0; 

                // Declare used properties
                uniform fixed4 _DiffuseColor;
                uniform fixed4 _SpecularColor;
                uniform fixed4 _AmbientColor;
                uniform float _Shininess;

                struct appdata
                { 
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 normal : TEXCOORD0;
                    float4 vertex : TEXCORD1;
                };


                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.normal = input.normal;
                    output.vertex = input.vertex;
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    float4 worldPosNormal = normalize(mul(unity_ObjectToWorld, float4(input.normal, 0)));
                    float4 normalizedLightDir = normalize(_WorldSpaceLightPos0);
                    float4 worldPosCamera = mul(unity_ObjectToWorld, input.vertex);
                    float4 normelizedWorldPosCamera = normalize(float4(_WorldSpaceCameraPos, 0) - worldPosCamera);
                    
                    float4 deffuse = max(dot(normalizedLightDir ,worldPosNormal), 0) *_DiffuseColor * _LightColor0;
                    float4 h = normalize(((normelizedWorldPosCamera + normalizedLightDir) / 2));
                    float4 specular = pow(max(dot(h, worldPosNormal) , 0), _Shininess) *_SpecularColor * _LightColor0;
                    float4 ambient = _AmbientColor * _LightColor0;
                   
                    return (deffuse + ambient + specular);
                }

            ENDCG
        }
    }
}
