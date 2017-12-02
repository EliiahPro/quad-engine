float4x4 VPM    : register(c0);
float3 LightPos : register(c4);

struct appdata {
       float4 Position : POSITION;
       float2 UV       : TEXCOORD0;
       float3 Normal   : NORMAL;
       float3 Tangent  : TANGENT;
       float3 Binormal : BINORMAL;
       float4 Color    : COLOR0;
};

struct vertexOutput {
       float4	Position : POSITION;
       float2	TexCoord : TEXCOORD0;
       float3	LightVec : TEXCOORD1;
       float3	ViewVec  : TEXCOORD2;
       float4   Color    : COLOR0;
};

vertexOutput std_VS(appdata Input) {
        vertexOutput Output = (vertexOutput)0;

        Output.Position = mul(VPM, Input.Position);
        Output.TexCoord = Input.UV;
        Output.Color = Input.Color;
        
        return Output;
}                                   


sampler2D DiffuseMap    : register(s0);

float4 std_PS(vertexOutput Input) : COLOR {  
	float4 tex = tex2D(DiffuseMap, Input.TexCoord);
	float4 res = float4((tex.rgb * Input.Color.rgb), tex.a* Input.Color.a);
	if (res.a == 0.0f){ 
		res.rgb = 0.0f;	
	}
	return res;
}


technique main
{
    pass Pass0 
	{
        VertexShader = compile vs_3_0 std_VS();
        PixelShader = compile ps_3_0 std_PS();
	}
}
