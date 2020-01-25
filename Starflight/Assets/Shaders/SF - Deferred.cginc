
#ifndef SF_SHADER_DEFERRED
#define SF_SHADER_DEFERRED

#include "SF - Core.cginc"
#include "SF - FractalNoise.cginc"

SF_VertexShaderOutput vertDeferred_SF( SF_VertexShaderInput v )
{
	return ComputeVertexShaderOutput( v );
}

void fragDeferred_SF( SF_VertexShaderOutput i, out half4 outGBuffer0 : SV_Target0, out half4 outGBuffer1 : SV_Target1, out half4 outGBuffer2 : SV_Target2, out half4 outGBuffer3 : SV_Target3 )
{
	float4 albedo = ComputeAlbedo( i, SF_AlbedoColor );
	float occlusion = ComputeOcclusion( i );
	float4 specular = ComputeSpecular( i );
	float3 normal = ComputeNormal( i );
	float3 emissive = ComputeEmissive( i );
	float3 reflection = ComputeReflection( i, normal );

	#if SF_FRACTALDETAILS_ON

		float noise = GetFractalNoise( i );

		float albedoModifier = noise * 0.4 + 0.6;
		float specularModifier = saturate( noise * 0.5 + 0.5 );

		#if SF_WATER_ON && SF_WATERMASKMAP_ON

			float waterMaskMap = tex2D( SF_WaterMaskMap, TRANSFORM_TEX( i.texCoord0, SF_WaterMaskMap ) );

			waterMaskMap *= 0.75;

			albedoModifier = lerp( albedoModifier, 1, waterMaskMap );
			specularModifier = lerp( specularModifier, 1, waterMaskMap );

		#endif

		albedo.rgb *= albedoModifier;
		specular.rgb *= specularModifier;

	#endif // SF_FRACTALDETAILS_ON

	#if SF_EMISSIVEPROJECTION_ON

		emissive *= pow( saturate( dot( normal, float3( 0, 0, -1 ) ) ), 10 ) * 0.25;

	#endif // SF_EMISSIVEPROJECTION_ON

	#if SF_ALPHATEST_ON

		clip( albedo.a - SF_AlphaTestValue );

	#endif // SF_ALPHATTEST_ON

	#if SF_ALBEDOOCCLUSION_ON

		albedo.rgb *= occlusion;

	#endif

	outGBuffer0 = float4( albedo.rgb, occlusion );
	outGBuffer1 = specular;
	outGBuffer2 = float4( normal * 0.5 + 0.5, 1 );

	#if !defined( UNITY_HDR_ON )

		outGBuffer3 = float4( exp2( -( emissive + reflection ) ), 1 );

	#else

		outGBuffer3 = float4( emissive + reflection, 1 );

	#endif
}

#endif
