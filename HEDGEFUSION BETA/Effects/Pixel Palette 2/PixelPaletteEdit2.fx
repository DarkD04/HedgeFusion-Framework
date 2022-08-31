sampler2D img : register(s0);
sampler2D bg : register(s1);
sampler2D Palettes = sampler_state {
	MinFilter = Point;
	MagFilter = Point;
};

float lerpVal;
float alpha;

float4 PixelPalette(float2 texCoord : TEXCOORD ) : COLOR
{
	float4 mask = tex2D(img, texCoord);
	float4 output = tex2D(bg, texCoord);
	float colorIndex = -1;

	for(int i=0;i<32 && mask.a > 0.0;i++)
	{
		float4 OriginalPalette = tex2D(Palettes, float2(i/256.0,0.0));
		// i = OriginalPalette.a > 0.0 ? 16 : i;
		if( distance(output.rgb, OriginalPalette.rgb) == 0 )
		{
			colorIndex = i/256.0;
		}
	}

	if(colorIndex > -1)
	{
		float4 colorA = tex2D(Palettes, float2(colorIndex, 0.0));
		float4 colorB = tex2D(Palettes, float2(colorIndex, 0.5));
		output.rgb = lerp(colorA, colorB, lerpVal);
	}
	output.a = lerp(0.0, output.a, alpha);

	return output;
}

technique tech_main
{
	pass p0
	{
		VertexShader = null;
		PixelShader = compile ps_2_a PixelPalette();
	}
}