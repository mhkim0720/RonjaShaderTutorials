﻿Shader "Tutorial/041_HSV/Adjust"{
	//show values to edit in inspector
	Properties{
		_HueShift("Hue Shift", Range(-1, 1)) = 0
        [PowerSlider(10.0)]_SaturationPower("Saturation Adjustment", Range(10.0, 0.1)) = 1
        [PowerSlider(10.0)]_ValuePower("Value Adjustment", Range(10.0, 0.1)) = 1
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		Pass{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"
            #include "HSVLibrary.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

            //HSV modification variables
			float _HueShift;
            float _SaturationPower;
            float _ValuePower;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//the object data that's put into the vertex shader
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader
			v2f vert(appdata v){
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
				float3 col = tex2D(_MainTex, i.uv);
				float3 hsv = rgb2hsv(col);
				hsv.x = hsv.x + _HueShift;
                hsv.y = pow(hsv.y, _SaturationPower);
                hsv.z = pow(hsv.z, _ValuePower);
				col = hsv2rgb(hsv);
				return float4(col, 1);
			}

			ENDCG
		}
	}
}