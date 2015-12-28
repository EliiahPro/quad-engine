object Form2: TForm2
  Left = 440
  Top = 230
  BorderStyle = bsDialog
  Caption = 'QuadShade - Color options'
  ClientHeight = 730
  ClientWidth = 943
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 943
    Height = 114
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    BevelOuter = bvNone
    Color = 3487029
    ParentBackground = False
    TabOrder = 0
    object Label1: TLabel
      Left = 199
      Top = 15
      Width = 98
      Height = 51
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Editor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 33023
      Font.Height = -38
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = Label1Click
    end
    object Label2: TLabel
      Left = 79
      Top = 15
      Width = 83
      Height = 51
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'HLSL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -38
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = Label2Click
    end
    object Label3: TLabel
      Left = 335
      Top = 15
      Width = 213
      Height = 51
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Environment'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -38
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = Label3Click
    end
    object Label4: TLabel
      Left = 81
      Top = 64
      Width = 292
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Syntax highlight colors can be changed here'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 581
      Top = 15
      Width = 104
      Height = 51
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'About'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -38
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = Label5Click
    end
    object QuadIcon1: TQuadIcon
      Left = 20
      Top = 25
      Width = 43
      Height = 43
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      NormalColor = clGray
      HoverColor = 33023
      ClickColor = clWhite
      Glyph.Data = {
        FA0E0000424DFA0E000000000000360000002800000023000000230000000100
        180000000000C40E0000000000000000000000000000000000000F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D1112
        0F3334325859577677758A8A898F8F8E8B8B8A7A7A795E5E5C3839361516130F
        100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0000000F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D292A277F807ED1D2D1F9F9F9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFDFDFDD9D9D98E8E8D3334320F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0000000F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D272825A0A1A0F1F1F1FFFFFFFFFFFFFFFFFFEBEBEBCA
        CAC9A2A3A29999989F9F9EC3C4C3E6E6E6FFFFFFFFFFFFFFFFFFF9F9F9B1B2B1
        3637340F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0000000F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D666765E7E7E7FFFFFFFFFFFFE4
        E4E48586844243411F1F1D0F100D0F100D0F100D0F100D0F100D1A1B183C3D3A
        787977D9D9D9FFFFFFFFFFFFF3F3F37E7E7D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0000000F100D0F100D0F100D0F100D0F100D0F100D979796FF
        FFFFFFFFFFE4E4E470716F1E1F1C0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D1516135F605ED3D3D3FFFFFFFFFFFFAEAE
        AD1B1C190F100D0F100D0F100D0F100D0F100D0000000F100D0F100D0F100D0F
        100D131411A4A5A3FFFFFFFFFFFFAAAAA9292A270F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D1B1C19939492FFFFFFFFFFFFBFC0BF20211F0F100D0F100D0F100D0F100D00
        00000F100D0F100D0F100D0F100D989897FFFFFFFFFFFF8989880F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D6E6E6CFDFDFDFFFFFFB8B8B712
        13100F100D0F100D0F100D0000000F100D0F100D0F100D6B6B6AFFFFFFFFFFFF
        8B8B8A0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F
        100D6D6D6BFDFDFDFFFFFF8F908F0F100D0F100D0F100D0000000F100D0F100D
        2C2D2AEDEDEDFFFFFFAFB0AF0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F
        100D0F100D0F100D0F100D0F100D0F100D8D8D8CFFFFFFFDFDFD4243410F100D
        0F100D0000000F100D0F100DACACABFFFFFFE0E1E01B1C190F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D16171441424041424041424041424049
        4A4720211F0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D10110E
        C3C4C3FFFFFFCFCFCE10110E0F100D0000000F100D2F2F2DF8F8F8FFFFFF6E6E
        6C0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D1F201EBFC0BFFF
        FFFFFFFFFFFFFFFFFFFFFFACACAB1D1E1B0F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D494A47FFFFFFFFFFFF4B4C490F100D0000000F10
        0D989897FFFFFFD3D3D31213100F100D0F100D0F100D0F100D0F100D0F100D0F
        100D30312FD6D6D6FFFFFFFFFFFFFFFFFFFFFFFF8E8E8D11120F0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100DB4B5B4FFFF
        FFB8B8B70F100D000000151613DFDFDEFFFFFF7E7E7D0F100D0F100D0F100D0F
        100D0F100D0F100D0F100D464745E5E5E5FFFFFFFFFFFFFFFFFFFFFFFF767775
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D575856FFFFFFF7F7F7292A27000000373835FEFEFEFFFFFF3E
        3E3C0F100D0F100D0F100D0F100D0F100D0F100D555654F4F4F4FFFFFFFFFFFF
        FFFFFFF8F8F86364620F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D20211FF0F1F0FFFFFF595A5700
        00005E5E5CFFFFFFE1E2E11819160F100D0F100D0F100D0F100D0F100D6C6C6A
        FBFBFBFFFFFFFFFFFFFFFFFFDDDDDC4748450F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F
        100DCACAC9FFFFFF8586840000007F7F7DFFFFFFB1B2B10F100D0F100D0F100D
        0F100D0F100D838482FFFFFFFFFFFFFFFFFFFFFFFFFCFCFC8E8E8D5657555F5F
        5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F5F5D5F
        5F5D5758561314110F100D0F100D939492FFFFFFA4A5A30000009E9E9DFFFFFF
        9C9C9B0F100D0F100D0F100D1314119F9F9EFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3F31E1F1C0F100D0F100D737472FFFFFF
        B7B7B6000000ABABAAFFFFFF9394920F100D0F100D0F100DA7A7A6FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9E9E91D1E1B
        0F100D0F100D6E6E6CFFFFFFBEBEBD0000009A9A99FFFFFF9D9D9C0F100D0F10
        0D0F100D444543E4E4E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFF4F4F41E1F1C0F100D0F100D747573FFFFFFB6B6B50000007C7C
        7BFFFFFFB4B5B40F100D0F100D0F100D0F100D2F2F2DCECECDFFFFFFFFFFFFFF
        FFFFFFFFFFF8F8F8AFB0AFACACABAFAFAEAFAFAEAFAFAEAFAFAEAFAFAEAFAFAE
        AFAFAEAFAFAEAFAFAEAFAFAEAFAFAEAFAFAEA0A1A01819160F100D0F100D9898
        97FFFFFFA2A3A20000005C5C5AFFFFFFE4E4E4191A170F100D0F100D0F100D0F
        100D222320BDBDBCFFFFFFFFFFFFFFFFFFFDFDFD9FA09F0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100DCDCDCCFFFFFF828381000000343532FCFCFCFFFFFF41
        42400F100D0F100D0F100D0F100D0F100D191A17A7A7A6FFFFFFFFFFFFFFFFFF
        FFFFFFBFC0BF21221F0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D242522F2F2F2FFFFFF55565400
        0000131411DBDBDAFFFFFF8485830F100D0F100D0F100D0F100D0F100D0F100D
        0F100D939492FFFFFFFFFFFFFFFFFFFFFFFFD3D3D330312F0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D5E
        5E5CFFFFFFF5F5F52526230000000F100D8F908FFFFFFFD9D9D91516130F100D
        0F100D0F100D0F100D0F100D0F100D0F100D7D7D7CFEFEFEFFFFFFFFFFFFFFFF
        FFE7E7E73F403E0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F
        100D0F100D0F100D0F100DBEBEBDFFFFFFB0B1B00F100D0000000F100D2A2B28
        F5F5F5FFFFFF7475730F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D6A6A69F5F5F5FFFFFFFFFFFFFFFFFFFBFBFB5E5E5C0F100D0F100D0F100D0F
        100D0F100D0F100D0F100D0F100D0F100D0F100D50514FFFFFFFFFFFFF474845
        0F100D0000000F100D0F100DA1A2A1FFFFFFE7E7E721221F0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D4F4F4DB7B7B6B8B8B7B8B8B7BCBCBBB4
        B5B43738350F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D151613
        CECECDFFFFFFC6C6C60F100D0F100D0000000F100D0F100D242522E5E5E5FFFF
        FFBDBDBC0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F
        100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D9B9B9AFFFFFFF8F8F83839360F100D0F100D0000000F10
        0D0F100D0F100D626361FFFFFFFFFFFF9697950F100D0F100D0F100D0F100D0F
        100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D787977FFFFFFFFFFFF8586840F10
        0D0F100D0F100D0000000F100D0F100D0F100D0F100D898988FFFFFFFFFFFF9A
        9A9910110E0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D7F7F7DFFFF
        FFFFFFFFAAAAA90F100D0F100D0F100D0F100D0000000F100D0F100D0F100D0F
        100D0F100D969795FFFFFFFFFFFFBABAB93536330F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D262724A4A5A3FFFFFFFFFFFFAFB0AF191A170F100D0F100D0F100D0F100D00
        00000F100D0F100D0F100D0F100D0F100D0F100D868785FFFFFFFFFFFFEFF0EF
        8182802324210F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D1A1B1870716FE1E2E1FFFFFFFFFFFF9FA09F1314110F100D0F
        100D0F100D0F100D0F100D0000000F100D0F100D0F100D0F100D0F100D0F100D
        0F100D5C5C5ADBDBDAFFFFFFFFFFFFE8E8E8959694535452292A271314110F10
        0D0F100D0F100D11120F2425224A4B488A8A89DDDDDCFFFFFFFFFFFFE9E9E971
        72700F100D0F100D0F100D0F100D0F100D0F100D0F100D0000000F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D1B1C198D8D8CE8E8E8FFFFFFFFFF
        FFFFFFFFF6F6F6DFDFDEC3C4C3AFB0AFBFC0BFDCDCDBF2F2F2FFFFFFFFFFFFFF
        FFFFEFF0EF9FA09F2627240F100D0F100D0F100D0F100D0F100D0F100D0F100D
        0F100D0000000F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F10
        0D0F100D1F1F1D686967C3C4C3EFEFEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFF3F3F3CBCBCA7778762728250F100D0F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0000000F100D0F100D0F100D0F100D0F10
        0D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D26272447484565
        66648788869797968C8C8B6B6B6A4D4D4B2B2C290F100D0F100D0F100D0F100D
        0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D0F100D000000}
      OnClick = QuadIcon1Click
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 114
    Width = 943
    Height = 616
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Color = 3487029
    TabOrder = 1
  end
  object Panel5: TPanel
    Left = 0
    Top = 114
    Width = 943
    Height = 616
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Color = 3487029
    TabOrder = 2
  end
  object ColoringPanel: TPanel
    Left = 0
    Top = 114
    Width = 943
    Height = 616
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Color = 3487029
    TabOrder = 3
    object QuadMemo2: TQuadMemo
      Left = 304
      Top = 0
      Width = 615
      Height = 592
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Lines.Strings = (
        'float4x4 VPM    : register(c0);'
        'float3 LightPos : register(c4);'
        ''
        'struct appdata {'
        '       float4 Position : POSITION;'
        '       float2 UV       : TEXCOORD0;'
        '       float3 Normal   : NORMAL;'
        '       float3 Tangent  : TANGENT;'
        '       float3 Binormal : BINORMAL;'
        '};'
        ''
        'struct vertexOutput {'
        '       float4  Position : POSITION;'
        '       float2  TexCoord : TEXCOORD0;'
        '       float3  LightVec : TEXCOORD1;'
        '       float3  ViewVec  : TEXCOORD2;'
        '};'
        ''
        'vertexOutput std_VS(appdata Input) {'
        '        vertexOutput Output = (vertexOutput)0;'
        '        float3 CamPos = (0.0, 0.0, 1.0);'
        ''
        '        Input.Tangent.y = Input.Tangent.y;'
        '        Input.Binormal.y = -Input.Binormal.y;'
        ''
        '        float3x3 RM;'
        '        RM[0] = Input.Tangent;'
        '        RM[1] = Input.Binormal;'
        '        RM[2] = Input.Normal;'
        ''
        '        Output.Position  = mul(VPM, Input.Position);'
        '        Output.TexCoord  = Input.UV;'
        ''
        
          '        Output.LightVec = mul(RM, normalize(mul(VPM, LightPos) -' +
          ' Output.Position));'
        
          '        Output.ViewVec  = mul(RM, normalize(mul(VPM, CamPos) - O' +
          'utput.Position));'
        ''
        '  return Output;'
        '}                                   '
        ''
        ''
        'sampler2D DiffuseMap    : register(s0);'
        'sampler2D NormalMap     : register(s1);'
        'sampler2D SpecularMap   : register(s2);'
        'float3 Params           : register(c5);'
        'float3 Params2          : register(c6);'
        ''
        'float4 std_PS(vertexOutput Input) : COLOR {  '
        ''
        ' float4 Output;'
        '                    '
        '    float NumSteps = 8.0;'
        '    float SpecExp = 80.0;'
        ''
        '    float Steph = 1.0 / NumSteps;'
        '    float2 dtex = -Input.ViewVec.xy / (NumSteps*4);'
        '    float Height = 1.0; '
        '    float2 tex = Input.TexCoord.xy;'
        '    float h = tex2D(NormalMap, Input.TexCoord).r;'
        '         '
        '    '
        '    for (float i=0; i<8; i++)'
        '    if (h < Height)'
        '    {'
        '       Height -= Steph;'
        '       tex += dtex;'
        '       h = tex2D(NormalMap, tex).r;'
        '    }       '
        ''
        '    float2 Prev = tex - dtex;'
        '    float hPrev = tex2D(NormalMap, Prev).r - (Height + Steph);'
        '    float hCur = h - Height;'
        '    float weight = hCur / (hCur - hPrev);'
        ''
        '    tex = weight * Prev + (1.0 - weight) * tex;'
        ''
        '    Output = tex2D(DiffuseMap, tex);'
        ''
        ''
        '        float4 tex_n = tex2D(SpecularMap, tex);'
        ''
        ''
        '        float3 nv = normalize(tex_n.xyz * 2.0 - 1.0);'
        '        float3 llv = normalize(Input.LightVec);'
        '        Output *= dot(nv, llv) + 0.15;'
        '        Output += pow(saturate(dot(nv, llv)), 32) * 0.15;'
        ''
        '        return Output;'
        '}'
        ''
        ''
        'technique main'
        '{'
        '    pass Pass0 '
        '  {'
        '        VertexShader = compile vs_2_0 std_VS();'
        '        PixelShader = compile ps_2_0 std_PS();'
        '  }'
        '}')
      ReadOnly = True
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 304
      Height = 592
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      BevelOuter = bvNone
      Color = 2434341
      TabOrder = 1
      object ListBox1: TListBox
        Left = 2
        Top = 0
        Width = 304
        Height = 617
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Style = lbOwnerDrawVariable
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Color = 3487029
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemHeight = 24
        Items.Strings = (
          'Background'
          'Selected line'
          'Error Line'
          'Selection'
          'Hint'
          'Service bar'
          'Scrollbars'
          'Active color'
          'Text changed'
          'Text saved'
          'Text highlight'
          'Right margin'
          'Text normal'
          'Text reserved'
          'Text comments'
          'Text function'
          'Text string'
          'Text constant'
          'Text devider'
          'Text define')
        ParentFont = False
        TabOrder = 0
        OnDblClick = ListBox1DblClick
        OnDrawItem = ListBox1DrawItem
      end
    end
  end
  object ColorDialog1: TColorDialog
    Options = [cdFullOpen]
    Left = 290
    Top = 270
  end
end
