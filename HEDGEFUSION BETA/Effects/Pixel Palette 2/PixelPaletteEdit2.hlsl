// Pixel shader input structure
struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
  float4 Position : SV_POSITION;
};

Texture2D<float4> img : register(t0);
sampler imgSampler : register(s0);

Texture2D<float4> bg : register(t1);
sampler bgSampler : register(s1);

Texture2D<float4> Palettes : register(t2);
sampler PalettesSampler : register(s2);

cbuffer PS_VARIABLES:register(b0)
{
	float lerpVal;
}


float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

float4 ps_main(float4 color : COLOR0, in PS_INPUT In ) : SV_TARGET
{
	float mask =  img.Sample(imgSampler, In.texCoord).a;
	float4 output =  bg.Sample(bgSampler, In.texCoord);
	float colorIndex = -1;

	[unroll]for(int i=0;i<256 && mask > 0.0;i++)
	{
		float4 OriginalPalette = Palettes.Sample(PalettesSampler, float2(i/256.0,0.0));
		if(OriginalPalette.a = 0.0)
		{
			break;
		}
		else
		{
			if( distance(output.rgb, OriginalPalette.rgb) == 0 )
				{
					colorIndex = i/256.0;
					break;
				}
		}
	}

	if(colorIndex > -1)
	{
		float4 colorA = Palettes.Sample(PalettesSampler, float2(colorIndex, 0.0));
		float4 colorB = Palettes.Sample(PalettesSampler, float2(colorIndex, 0.5));
		output.rgb = lerp(colorA.rgb, colorB.rgb, lerpVal);
	}
	
	output *= In.Tint;
	
	return output;
}


float4 ps_main_pm(float4 color : COLOR0, in PS_INPUT In ) : SV_TARGET
{
	float mask =  img.Sample(imgSampler, In.texCoord).a;
	float4 output =  bg.Sample(bgSampler, In.texCoord);
	float colorIndex = -1;

	[unroll]for(int i=0;i<256 && mask > 0.0;i++)
	{
		float4 OriginalPalette = Palettes.Sample(PalettesSampler, float2(i/256.0,0.0));
		if(OriginalPalette.a = 0.0)
		{
			break;
		}
		else
		{
			if( distance(output.rgb, OriginalPalette.rgb) == 0 )
				{
					colorIndex = i/256.0;
					break;
				}
		}
	}

	if(colorIndex > -1)
	{
		float4 colorA = Palettes.Sample(PalettesSampler, float2(colorIndex, 0.0));
		float4 colorB = Palettes.Sample(PalettesSampler, float2(colorIndex, 0.5));
		output.rgb = lerp(colorA.rgb, colorB.rgb, lerpVal);
	}
	
	output.rgb *= output.a;
	output *= In.Tint;

	return output;
}

