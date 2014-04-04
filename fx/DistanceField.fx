float4x4 VPM    : register(c0);

struct appdata {
       float4 Position : POSITION;
       float2 UV       : TEXCOORD0;
       float3 Normal   : NORMAL;
       float3 Tangent  : TANGENT;
       float3 Binormal : BINORMAL;
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
        float3 CamPos = (0.0, 0.0, 1.0);

        Input.Tangent.y = Input.Tangent.y;
        Input.Binormal.y = -Input.Binormal.y;

        float3x3 RM;
        RM[0] = Input.Tangent;
        RM[1] = Input.Binormal;
        RM[2] = Input.Normal;

        Output.Position = mul(VPM, Input.Position);
        Output.TexCoord = Input.UV;

        Output.LightVec = mul(RM, normalize(mul(VPM, CamPos) - Output.Position));
        Output.ViewVec = mul(RM, normalize(mul(VPM, CamPos) - Output.Position));

 return Output;
}                                   


sampler2D DiffuseMap    : register(s0);
float4 Params           : register(c0); // edge1 min/max, edge2 min/max
float4 OutlineColor     : register(c1);
float4 Options          : register(c2);

float4 std_PS(vertexOutput Input) : COLOR {  
    float4 Output;

    float2 uv = Input.TexCoord;

    float a = tex2D(DiffuseMap, uv).a;

    Output = Input.Color;

    if ((Options[1] > 0) && (a <= Params[3])) { 
        Output = lerp(OutlineColor, Input.Color, smoothstep(Params[2], Params[3], a));
    }

    if (Options[0] > 0){
        Output.a *= smoothstep(Params[0], Params[1], a);
    } else {
        Output.a = (a >= 0.5);
    }

    return Output;
}


technique main
{
    pass Pass0 
 {
        VertexShader = null;
        PixelShader = compile ps_2_0 std_PS();
 }
}
