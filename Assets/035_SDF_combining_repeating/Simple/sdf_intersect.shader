﻿Shader "Tutorial/035_2D_SDF_Combinations/Intersection"{
    Properties{
        _InsideColor("Inside Color", Color) = (.5, 0, 0, 1)
        _OutsideColor("Outside Color", Color) = (0, .5, 0, 1)

        _LineDistance("Mayor Line Distance", Range(0, 2)) = 1
        _LineThickness("Mayor Line Thickness", Range(0, 0.1)) = 0.05

        [IntRange]_SubLines("Lines between major lines", Range(1, 10)) = 4
        _SubLineThickness("Thickness of inbetween lines", Range(0, 0.05)) = 0.01
    }

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		Pass{
			CGPROGRAM

			#include "UnityCG.cginc"
            #include "2D_SDF.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct appdata{
				float4 vertex : POSITION;
			};

			struct v2f{
				float4 position : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				//calculate the position in clip space to render the object
				o.position = UnityObjectToClipPos(v.vertex);
				//calculate world position of vertex
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

            float scene(float2 position) {
                const float PI = 3.14159;

                float2 squarePosition = position;
                squarePosition = translate(squarePosition, float2(1, 0));
                squarePosition = rotate(squarePosition, .125);
                float squareShape = rectangle(squarePosition, float2(2, 2));

                float2 circlePosition = position;
                circlePosition = translate(circlePosition, float2(-1.5, 0));
                float circleShape = circle(circlePosition, 2.5);

                return intersect(squareShape, circleShape);
            }

            float4 _InsideColor;
            float4 _OutsideColor;

            float _LineDistance;
            float _LineThickness;

            float _SubLines;
            float _SubLineThickness;

			fixed4 frag(v2f i) : SV_TARGET{
				float dist = scene(i.worldPos.xz);
                fixed4 col = lerp(_InsideColor, _OutsideColor, step(0, dist));

                float distanceChange = fwidth(dist) * 0.5;
                float majorLineDistance = abs(frac(dist / _LineDistance + 0.5) - 0.5) * _LineDistance;
                float majorLines = smoothstep(_LineThickness - distanceChange, _LineThickness + distanceChange, majorLineDistance);

                float distanceBetweenSubLines = _LineDistance / _SubLines;
                float subLineDistance = abs(frac(dist / distanceBetweenSubLines + 0.5) - 0.5) * distanceBetweenSubLines;
                float subLines = smoothstep(_SubLineThickness - distanceChange, _SubLineThickness + distanceChange, subLineDistance);

				return col * majorLines * subLines;
			}

			ENDCG
		}
	}
	FallBack "Standard" //fallback adds a shadow pass so we get shadows on other objects
}