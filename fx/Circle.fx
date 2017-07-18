float4x4 VPM    : register(c0);

struct appdata {                
       float4 Color    : COLOR0;
       float4 Position : POSITION0;
       float2 UV       : TEXCOORD0;
       float3 Normal   : NORMAL0;
       float3 Tangent  : TANGENT0;
       float3 Binormal : BINORMAL0;
};

struct vertexOutput {           
       float4 Color    : COLOR0;
       float4 Position : POSITION0;
       float2 TexCoord : TEXCOORD0;
       float3 LightVec : TEXCOORD1;   
       float3 ViewVec  : TEXCOORD2;
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

 //   float4 Output;

 //   float2 uv = Input.TexCoord;
    
 //   float d = distance(float2(0.5, 0.5), uv) * 2.0;

//    if ((d > 1.0) || (d < Params.x))
  //  {
//	      Output = 0.0;
  //  }
 //   else
 //   {
 //       Output = Input.Color;
 //   }


    float distance = sqrt(dot(Input.TexCoord, Input.TexCoord)) / 2;
    float alpha = saturate((0.5 - distance) / fwidth(distance));
    float alpha2 = saturate((0.5 - distance*Radius) / fwidth(distance*Radius));
alpha -= alpha2;

    return float4(Input.Color.rgb, Input.Color.a * alpha);


            
   // return Output;
}


technique main
{
    pass Pass0 
 {
        VertexShader = compile vs_3_0 std_VS();
        PixelShader = compile ps_3_0 std_PS();
 }
}
