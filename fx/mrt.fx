float4x4 VPM : register(c0);

struct appdata {
  float4 Position : POSITION;
  float2 UV       : TEXCOORD0;
  float3 Normal   : NORMAL;
  float3 Tangent  : TANGENT;
  float3 Binormal : BINORMAL;
};

struct vertexOutput 
{
  float4 Position : POSITION;
  float2 TexCoord : TEXCOORD0;
  float3 N        : TEXCOORD1;
  float3 T        : TEXCOORD2;
  float3 B        : TEXCOORD3;
};

vertexOutput std_VS(appdata Input)
{
    vertexOutput Output = (vertexOutput)0;

    Output.Position = mul(VPM, Input.Position);
    Output.TexCoord = Input.UV;

    Output.T = normalize(mul(VPM, Input.Tangent));
    Output.B = normalize(mul(VPM, Input.Binormal));
    Output.N = normalize(mul(VPM, Input.Normal));
    
    return Output;
}

struct PixelOutput
{
    float4 Diffuse  : SV_TARGET0;
    float4 Normal   : SV_TARGET1;
    float4 Specular : SV_TARGET2;
    float4 Height   : SV_TARGET3;
};
                                    
sampler2D DiffuseMap  : register(s0);   
sampler2D NormalMap   : register(s1);
sampler2D SpecularMap : register(s2);
sampler2D HeightMap   : register(s3);

PixelOutput std_PS(vertexOutput Input) 
{         
    PixelOutput Output;   

    Output.Diffuse = tex2D(DiffuseMap, Input.TexCoord);  

    float4 nn = tex2D(NormalMap, Input.TexCoord) * 2.0 - 1.0; 
    Output.Normal = (float4(normalize(nn.x * Input.T + nn.y * Input.B + nn.z * Input.N), nn.a) + 1.0) / 2.0;    

    Output.Specular = tex2D(SpecularMap, Input.TexCoord); 
    Output.Height = tex2D(HeightMap, Input.TexCoord);   

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
