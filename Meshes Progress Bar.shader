//  Copyright 2019 Arthur Anisimov. https://github.com/ArchieQQ

Shader "Meshes Progress Bar"
{
	Properties
	{		
		_ColorFill("FILL COLOR", Color) = (0.008, 0.67, 0.3, 1)
		_ColorBg("BACKGROUND COLOR", Color) = (0.25, 0.24, 0.3, 1)
		_PlayerPos("PLAYER POSITION", float) = 0.0

		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{

		Tags 
		{ 
		"RenderType" = "Opaque"
		"LightMode" = "ForwardBase" 
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

			#include "AutoLight.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;

				float2 uv : TEXCOORD0;
				float4 worldPos : TEXCOORD1;

				fixed4 diff : COLOR0;
				fixed3 ambient : COLOR1;

				SHADOW_COORDS(2)
			};

			
			v2f vert(appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				/* Diffuse */
				float diffuseIntensivity = 0.9;				
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(1 - diffuseIntensivity, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diff = nl * _LightColor0;
				o.ambient = ShadeSH9(half4(worldNormal, 1));

				/* Shadows */
				TRANSFER_SHADOW(o)
					
				return o;
			}

			float _PlayerPos;
			float4 _ColorFill;
			float4 _ColorBg;
			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				/* Diffuse */
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.diff;

				/* Shadows */
				fixed shadow = SHADOW_ATTENUATION(i);
				fixed3 lighting = i.diff * shadow  + i.ambient;
				col.rgb *= lighting;				

				/* Mesh Bar Color */
				if (_PlayerPos < i.worldPos.x)
					return col * _ColorBg;
				else
					return col * _ColorFill;
			}

			ENDCG
		}
			UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
