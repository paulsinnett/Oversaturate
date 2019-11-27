Shader "Unlit/Oversaturate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _Saturation ("Saturation", Color) = (1, 1, 1, 1)
        _Direction ("Direction", Vector) = (0, 1, 0, 0)
        _Base ("Base Position", Vector) = (0, 0, 0, 0)
        _Distance ("Projection Distance", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend One One
        Cull Back
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 saturation : SV_Target;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Tint;
            fixed4 _Saturation;
            float4 _Direction;
            float4 _Base;
            float _Distance;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex.xyz).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float attenuation = _Distance / (_Distance + length(worldPos.xyz - _Base.xyz));
                o.saturation = saturate(_Saturation * dot(_Direction, -normal)) * attenuation;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Tint * i.saturation.a;
                col.rgb = saturate(col.rgb + i.saturation);
                return col;
            }
            ENDCG
        }
    }
}
