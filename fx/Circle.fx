float4x4 VPM    : register(c0);

struct appdata {
       float4 Position : POSITION;
       float2 UV       : TEXCOORD0;
       float3 Normal   : NORMAL;
       float3 Tangent  : TANGENT;
       float3 Binormal : BINORMAL; 
       float4 Color    : COLOR0;
};

struct vertexOutput {            
       float4 Position : POSITION;
       float2 TexCoord : TEXCOORD0;
       float3 LightVec : TEXCOORD1;
       float3 ViewVec  : TEXCOORD2;
       float4 Color    : COLOR0;
};

vertexOutput std_VS(appdata Input) {
        vertexOutput Output = (vertexOutput)0;

        Output.Position = mul(VPM, Input.Position);
        Output.TexCoord = Input.UV;
        Output.Color = Input.Color;
        
        return Output;
}                                   

float Radius: register(c0); 

float4 std_PS(vertexOutput Input) : COLOR0 {  

    float4 Output;

    float2 uv = Input.TexCoord;
    
    float d = distance(float2(0.5, 0.5), uv);

    if ((d > 1.0) || (d < Radius))
    {
	Output = Input.Color;
    }
    else
    {
        Output = 0.0;
    }
            
    return Output;
}


technique main
{
    pass Pass0 
 {
        VertexShader = compile vs_2_0 std_VS();
        PixelShader = compile ps_2_0 std_PS();
 }
}
