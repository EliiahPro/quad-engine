{//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//
// For license see COPYING
//=============================================================================}

unit QuadEngine.Render;

interface

{$INCLUDE QUADENGINE.INC}

uses
  Winapi.Windows, Winapi.Direct3D9, Winapi.DXTypes, VCL.Graphics, VCL.Imaging.pngimage,
  QuadEngine.Utils, QuadEngine.Log, Vec2f, QuadEngine, IniFiles,
  System.SysUtils {$IFDEF DEBUG}, QuadEngine.Profiler{$ENDIF};

const
  // Vertex struct declaration
  decl: array[0..6] of D3DVERTEXELEMENT9 = (
    (Stream: 0;   Offset: 0;  _Type: D3DDECLTYPE_FLOAT3;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_POSITION; UsageIndex: 0),
    (Stream: 0;   Offset: 12; _Type: D3DDECLTYPE_FLOAT3;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_NORMAL;   UsageIndex: 0),
    (Stream: 0;   Offset: 24; _Type: D3DDECLTYPE_D3DCOLOR; Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_COLOR;    UsageIndex: 0),
    (Stream: 0;   Offset: 28; _Type: D3DDECLTYPE_FLOAT2;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_TEXCOORD; UsageIndex: 0),
    (Stream: 0;   Offset: 36; _Type: D3DDECLTYPE_FLOAT3;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_TANGENT;  UsageIndex: 0),
    (Stream: 0;   Offset: 48; _Type: D3DDECLTYPE_FLOAT3;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_BINORMAL; UsageIndex: 0),
    (Stream: $FF; Offset: 0;  _Type: D3DDECLTYPE_UNUSED;   Method: D3DDECLMETHOD_DEFAULT; Usage: D3DDECLUSAGE_POSITION; UsageIndex: 0)
    );

  MaxBufferCount = 60000;

type
  TQuadRender = class(TInterfacedObject, IQuadRender)
  private
    FActiveTexture: array of IDirect3DTexture9;
    FBackBuffer: IDirect3DSurface9;
    FCount: Cardinal;
    FD3DDM: TD3DDisplayMode;
    FD3DAI: TD3DAdapterIdentifier9;
    FD3DCaps: TD3DCaps9;
    FD3DDevice: IDirect3DDevice9;
    FD3DPP: TD3DPresentParameters;
    FD3DVB: IDirect3DVertexBuffer9;
    FD3DVD: IDirect3DVertexDeclaration9;
    FHandle: THandle;
    FHeight: Integer;
    FIsAutoCalculateTBN : Boolean;
    FIsDeviceLost: Boolean;
    FIsEnabledBlending: Boolean;
    FIsInitialized: Boolean;
    FIsRenderIntoTexture: Boolean;
    Fqbm: TQuadBlendMode;
    FVertexBuffer: array [0..MaxBufferCount - 1] of TVertex;
    FTextureAdressing: TQuadTextureAdressing;
    FTextureFiltering: TQuadTextureFiltering;
    FTextureMirroring: TQuadTextureMirroring;
    FViewMatrix: TD3DMatrix;
    FViewport: TRect;
    FWidth: Integer;
    FRenderMode: TD3DPrimitiveType;
    FShaderModel: TQuadShaderModel;
    FOldScreenWidth: Integer;
    FOldScreenHeight: Integer;
    FCircleRadius: Single;
    {$IFDEF DEBUG}
    FProfiler: IQuadProfiler;
    FProfilerTags: record
      Invalid: IQuadProfilerTag;
      BeginScene: IQuadProfilerTag;
      EndScene: IQuadProfilerTag;
      Clear: IQuadProfilerTag;
      Draw: IQuadProfilerTag;
      DrawCall: IQuadProfilerTag;
      SetBlendMode: IQuadProfilerTag;
      CalculateTBN: IQuadProfilerTag;
      SwitchRenderTarget: IQuadProfilerTag;
      SwitchTexture: IQuadProfilerTag;
    end;
    {$ENDIF}
    FQuad: array[0..5] of TVertex;
    procedure AddQuadToBuffer;
    function GetProjectionMatrix: TD3DMatrix;
    procedure SetRenderMode(const Value: TD3DPrimitiveType);
    procedure InitializeVolatileResources;
    procedure ReleaseVolatileResources;
    procedure CreateOrthoMatrix;
    procedure SetViewMatrix(const AViewMatrix: TD3DMatrix);
    function GetIsSupportedNonPow2: Boolean;
    function GetNumSimultaneousRTs: Cardinal;
    function GetIsSeparateAlphaBlend: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GetClipRect(out ARect: TRect); stdcall;
    function GetAvailableTextureMemory: Cardinal; stdcall;
    function GetMaxAnisotropy: Cardinal; stdcall;
    function GetMaxTextureHeight: Cardinal; stdcall;
    function GetMaxTextureStages: Cardinal; stdcall;
    function GetMaxTextureWidth: Cardinal; stdcall;
    function GetPixelShaderVersionString: PWideChar; stdcall;
    function GetPSVersionMajor: Byte; stdcall;
    function GetPSVersionMinor: Byte; stdcall;
    function GetVertexShaderVersionString: PWideChar; stdcall;
    function GetVSVersionMajor: Byte; stdcall;
    function GetVSVersionMinor: Byte; stdcall;
    function GetRenderDeviceName: PWideChar; stdcall;
    procedure AddTrianglesToBuffer(const AVertexes: array of TVertex; ACount: Cardinal); stdcall;
    procedure BeginRender; stdcall;
    procedure ChangeResolution(AWidth, AHeight: Word; isVirtual: Boolean = True); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    procedure DrawCircle(const Center: TVec2f; Radius, InnerRadius: Single; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawLine(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawPoint(const Point: TVec2f; Color: Cardinal); stdcall;
    procedure DrawQuadLine(const PointA, PointB: TVec2f; Width1, Width2: Single; Color1, Color2: Cardinal); stdcall;
    procedure EndRender; stdcall;
    procedure Finalize; stdcall;
    procedure FlushBuffer; stdcall;
    procedure Initialize(AHandle: THandle; AWidth, AHeight: Integer;
      AIsFullscreen: Boolean; AShaderModel: TQuadShaderModel = qsm20); stdcall;
    procedure InitializeEx(const ARenderInit: TRenderInit); stdcall;
    procedure InitializeFromIni(AHandle: THandle; AFilename: PWideChar); stdcall;
    procedure Polygon(const PointA, PointB, PointC, PointD: TVec2f; Color: Cardinal); stdcall;
    procedure Rectangle(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure RectangleEx(const PointA, PointB: TVec2f; Color1, Color2, Color3, Color4: Cardinal); stdcall;
    procedure RenderToGBuffer(AIsRenderToGBuffer: Boolean; AQuadGBuffer: IQuadGBuffer = nil; AIsCropScreen: Boolean = False); stdcall;
    procedure RenderToTexture(AIsRenderToTexture: Boolean; AQuadTexture: IQuadTexture = nil;
      ATextureRegister: Byte = 0; ARenderTargetRegister: Byte = 0; AIsCropScreen: Boolean = False); stdcall;
    procedure SetAutoCalculateTBN(Value: Boolean); stdcall;
    procedure SetBlendMode(qbm: TQuadBlendMode); stdcall;
    procedure SetClipRect(X, Y, X2, Y2: Cardinal); stdcall;
    procedure SetTexture(ARegister: Byte; const ATexture: IDirect3DTexture9); stdcall;
    procedure SetTextureAdressing(ATextureAdressing: TQuadTextureAdressing); stdcall;
    procedure SetTextureFiltering(ATextureFiltering: TQuadTextureFiltering); stdcall;
    procedure SetTextureMirroring(ATextureMirroring: TQuadTextureMirroring); stdcall;
    procedure SetPointSize(ASize: Cardinal); stdcall;
    procedure SkipClipRect; stdcall;
    procedure TakeScreenshot(AFileName: PWideChar); stdcall;
    procedure ResetDevice; stdcall;
    function GetD3DDevice: IDirect3DDevice9; stdcall;

    procedure DrawRect(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal);
    procedure DrawRectRot(const PointA, PointB: TVec2f; Angle, Scale: Double; const UVA, UVB: TVec2f; Color: Cardinal);
    procedure DrawRectRotAxis(const PointA, PointB: TVec2f; Angle, Scale: Double; const Axis, UVA, UVB: TVec2f; Color: Cardinal);

    property AvailableTextureMemory: Cardinal read GetAvailableTextureMemory;
    property BlendMode: TQuadBlendMode read Fqbm;
    property D3DDevice: IDirect3DDevice9 read FD3DDevice;
    property D3DDM: TD3DDisplayMode read FD3DDM write FD3DDM;
    property D3DAI: TD3DAdapterIdentifier9 read FD3DAI write FD3DAI;
    property Height: Integer read FHeight;
    property IsRenderIntoTexture : Boolean read FIsRenderIntoTexture;
    property MaxTextureWidth: Cardinal read GetMaxTextureWidth;
    property MaxTextureHeight: Cardinal read GetMaxTextureHeight;
    property MaxTextureStages: Cardinal read GetMaxTextureStages;
    property MaxAnisotropy: Cardinal read GetMaxAnisotropy;
    property PixelShaderVersionString: PWideChar read GetPixelShaderVersionString;
    property ProjectionMatrix: TD3DMatrix read GetProjectionMatrix;
    property PSVersionMajor: Byte read GetPSVersionMajor;
    property PSVersionMinor: Byte read GetPSVersionMinor;
    property RenderMode: TD3DPrimitiveType read FRenderMode write SetRenderMode;
    property VertexShaderVersionString : PWideChar read GetVertexShaderVersionString;
    property VSVersionMajor: Byte read GetVSVersionMajor;
    property VSVersionMinor: Byte read GetVSVersionMinor;
    property Width: Integer read FWidth;
    property IsInitialized: Boolean read FIsInitialized;
    property ShaderModel: TQuadShaderModel read FShaderModel;
    property ViewMatrix: TD3DMatrix read FViewMatrix write SetViewMatrix;
    property IsSupportedNonPow2: Boolean read GetIsSupportedNonPow2;
    property IsSeparateAlphaBlend: Boolean read GetIsSeparateAlphaBlend;
    property NumSimultaneousRTs: Cardinal read GetNumSimultaneousRTs;
  end;

implementation

uses
  QuadEngine.Texture, QuadEngine.Shader, QuadEngine.Font, QuadEngine.Timer,
  QuadEngine.Device, QuadEngine.GBuffer, QuadEngine.Camera;

{ TQuadRender }

//=============================================================================
// Calculate vector cross
//=============================================================================
procedure Cross(const v1, v2 : TVector; var r : TVector);
begin
  r.x := v1.y * v2.z - v1.z * v2.y;
  r.y := v1.z * v2.x - v1.x * v2.z;
  r.z := v1.x * v2.y - v1.y * v2.x;
end;

//=============================================================================
// Normalize vector
//=============================================================================
procedure normalize(var a: TVector);
var
  s: Single;
begin
  s := Sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
  a.x := a.x / s;
  a.y := a.y / s;
  a.z := a.z / s;
end;

//=============================================================================
// Calculate Tangent, Binormal, Normal
//=============================================================================
procedure CalcTBN(var t, b, n: TVector; const p1, p2, p3: TVertex);
var
  s1, s2, crs, tangent, binormal: TVector;
begin
  s1.x := p2.x - p1.x;
  s1.y := p2.u - p1.u;
  s1.z := p2.v - p1.v;

  s2.x := p3.x - p1.x;
  s2.y := p3.u - p1.u;
  s2.z := p3.v - p1.v;

  Cross(s2, s1, crs);

  tangent.x := -crs.y / crs.x;
  binormal.x := -crs.z / crs.x;

  s1.x := p2.y - p1.y;
  s2.x := p3.y - p1.y;

  Cross(s2, s1, crs);

  tangent.y := -crs.y / crs.x;
  binormal.y := -crs.z / crs.x;

  s1.x := p2.z - p1.z;
  s2.x := p3.z - p1.z;

  Cross(s2, s1, crs);

  tangent.z := -crs.y / crs.x;
  binormal.z := -crs.z / crs.x;

  t := tangent;
  b := binormal;

  Cross(t, b, n);

  normalize(t);
  normalize(b);
  normalize(n);
end;

procedure TQuadRender.GetClipRect(out ARect: TRect); stdcall;
begin
  ARect := FViewport;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.AddQuadToBuffer;
begin
  if FIsAutoCalculateTBN then
  begin
    {$IFDEF DEBUG}
    if Assigned(FProfilerTags.CalculateTBN) then
      FProfilerTags.CalculateTBN.BeginCount;
    {$ENDIF}
    CalcTBN(FQuad[0].tangent, FQuad[0].binormal, FQuad[0].normal, FQuad[0], FQuad[1], FQuad[2]);
    CalcTBN(FQuad[1].tangent, FQuad[1].binormal, FQuad[1].normal, FQuad[0], FQuad[1], FQuad[2]);
    CalcTBN(FQuad[2].tangent, FQuad[2].binormal, FQuad[2].normal, FQuad[0], FQuad[1], FQuad[2]);
    CalcTBN(FQuad[5].tangent, FQuad[5].binormal, FQuad[5].normal, FQuad[0], FQuad[1], FQuad[2]);
    {$IFDEF DEBUG}
    if Assigned(FProfilerTags.CalculateTBN) then
      FProfilerTags.CalculateTBN.EndCount;
    {$ENDIF}
  end;

  FQuad[3] := FQuad[2];
  FQuad[4] := FQuad[1];

  Move(FQuad, FVertexBuffer[FCount], 6 * SizeOf(TVertex));
  Inc(FCount, 6);

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.AddTrianglesToBuffer(const AVertexes: array of TVertex; ACount: Cardinal);
begin
  Move(AVertexes, FVertexBuffer[FCount], ACount * SizeOf(TVertex));
  Inc(FCount, ACount);

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.BeginRender;
begin
  {$IFDEF DEBUG}
  if Assigned(FProfiler) then
    FProfiler.BeginTick;
  if Assigned(FProfilerTags.BeginScene) then
    FProfilerTags.BeginScene.BeginCount;
  {$ENDIF}

  Device.LastResultCode := FD3DDevice.BeginScene;

  FIsDeviceLost := (Device.LastResultCode = D3DERR_DEVICELOST);

  if not FIsDeviceLost then
    Device.LastResultCode := FD3DDevice.BeginScene;

  FCount := 0;
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.BeginScene) then
    FProfilerTags.BeginScene.EndCount;
  {$ENDIF}
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.ChangeResolution(AWidth, AHeight: Word; isVirtual: Boolean = True);
begin
  FWidth := aWidth;
  FHeight := aHeight;

  if not isVirtual then
  begin
    FD3DPP.BackBufferWidth := FWidth;
    FD3DPP.BackBufferHeight := FHeight;
    GetD3DDevice.Reset(FD3DPP);

    ResetDevice;
  end
  else
    FlushBuffer;

  CreateOrthoMatrix;
  Device.LastResultCode := FD3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
end;

//=============================================================================
// Clears render target with color
//=============================================================================
procedure TQuadRender.Clear(AColor: Cardinal);
begin
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Clear) then
    FProfilerTags.Clear.BeginCount;
  {$ENDIF}
  Device.LastResultCode := FD3DDevice.Clear(0, nil, D3DCLEAR_TARGET, AColor, 1.0, 0);
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Clear) then
    FProfilerTags.Clear.EndCount;
  {$ENDIF}
end;

//=============================================================================
//
//=============================================================================
constructor TQuadRender.Create;
begin
  FWidth := 0;
  FHeight := 0;
  FHandle := 0;
  FCount := 0;
  FOldScreenWidth := -1;
  FOldScreenHeight := -1;
  FIsRenderIntoTexture := False;

  FRenderMode := D3DPT_TRIANGLELIST;

  FIsDeviceLost := False;
  FIsAutoCalculateTBN := True;
  FIsInitialized := False;

  FTextureMirroring := qtmNone;

  {$IFDEF DEBUG}
  Device.CreateProfiler('Quad Render', FProfiler);
  FProfiler.SetGUID(StringToGUID('{66D6B378-3AD8-476F-AB5E-B77B04D664A3}'));
  FProfiler.CreateTag('Invalid', FProfilerTags.Invalid);
  FProfiler.CreateTag('BeginScene', FProfilerTags.BeginScene);
  FProfiler.CreateTag('EndScene', FProfilerTags.EndScene);
  FProfiler.CreateTag('Clear', FProfilerTags.Clear);
  FProfiler.CreateTag('Draw', FProfilerTags.Draw);
  FProfiler.CreateTag('DrawCall', FProfilerTags.DrawCall);
  FProfiler.CreateTag('SetBlendMode', FProfilerTags.SetBlendMode);
  FProfiler.CreateTag('CalculateTBN', FProfilerTags.CalculateTBN);
  FProfiler.CreateTag('SwitchRenderTarget', FProfilerTags.SwitchRenderTarget);
  FProfiler.CreateTag('SwitchTexture', FProfilerTags.SwitchTexture);
  {$ENDIF}
end;

destructor TQuadRender.Destroy;
begin
  {$IFDEF DEBUG}
  FProfilerTags.Invalid := nil;
  FProfilerTags.BeginScene := nil;
  FProfilerTags.EndScene := nil;
  FProfilerTags.Clear := nil;
  FProfilerTags.Draw := nil;
  FProfilerTags.DrawCall := nil;
  FProfilerTags.SetBlendMode := nil;
  FProfilerTags.CalculateTBN := nil;
  FProfilerTags.SwitchRenderTarget := nil;
  FProfilerTags.SwitchTexture := nil;
  FProfiler := nil;
  {$ENDIF}

  TQuadShader.DistanceField := nil;
  TQuadShader.CircleShader := nil;
  TQuadShader.mrtShader := nil;
  TQuadShader.DeferredShading := nil;
  inherited;
end;

//=============================================================================
// Set ortho matrix for 2d rendering
//=============================================================================
procedure TQuadRender.CreateOrthoMatrix;
begin
  FViewMatrix._11 := 2 / FWidth;
  FViewMatrix._12 := 0;
  FViewMatrix._13 := 0;
  FViewMatrix._14 := 0;

  FViewMatrix._21 := 0;
  FViewMatrix._22 := -2 / FHeight;
  FViewMatrix._23 := 0;
  FViewMatrix._24 := 0;

  FViewMatrix._31 := 0;
  FViewMatrix._32 := 0;
  FViewMatrix._33 := 1;
  FViewMatrix._34 := 0;

  FViewMatrix._41 := -1;
  FViewMatrix._42 := 1;
  FViewMatrix._43 := 0;
  FViewMatrix._44 := 1;
end;

//=============================================================================
// Draws textured rotated rectangle along center
//=============================================================================
procedure TQuadRender.DrawrectRot(const PointA, PointB: TVec2f; Angle, Scale: Double;
  const UVA, UVB: TVec2f; Color: Cardinal);
var
  Origin: TVec2f;
  Alpha: Single;
  SinA, CosA: Single;
  realUVA, realUVB: TVec2f;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}
  RenderMode := D3DPT_TRIANGLELIST;

  realUVA := UVA;
  realUVB := UVB;

  if FTextureMirroring in [qtmHorizontal, qtmBoth] then
  begin
    realUVA.X := UVB.X;
    realUVB.X := UVA.X;
  end;
  if FTextureMirroring in [qtmVertical, qtmBoth] then
  begin
    realUVA.Y := UVB.Y;
    realUVB.Y := UVA.Y;
  end;


  Origin := (PointB - PointA) / 2 + PointA;

  Alpha := Angle * (pi / 180);

  FastSinCos(Alpha, SinA, CosA);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}

  FQuad[0].x := ((PointA.X - Origin.X) * cosA - (PointA.Y - Origin.Y) * sinA) * Scale + Origin.X - (PointB.X - PointA.X) / 2;
  FQuad[0].y := ((PointA.X - Origin.X) * sinA + (PointA.Y - Origin.Y) * cosA) * Scale + Origin.Y - (PointB.Y - PointA.Y) / 2;

  FQuad[1].x := ((PointB.X - Origin.X) * cosA - (PointA.Y - Origin.Y) * sinA) * Scale + Origin.X - (PointB.X - PointA.X) / 2;
  FQuad[1].y := ((PointB.X - Origin.X) * sinA + (PointA.Y - Origin.Y) * cosA) * Scale + Origin.Y - (PointB.Y - PointA.Y) / 2;

  FQuad[2].x := ((PointA.X - Origin.X) * cosA - (PointB.Y - Origin.Y) * sinA) * Scale + Origin.X - (PointB.X - PointA.X) / 2;
  FQuad[2].y := ((PointA.X - Origin.X) * sinA + (PointB.Y - Origin.Y) * cosA) * Scale + Origin.Y - (PointB.Y - PointA.Y) / 2;

  FQuad[5].x := ((PointB.X - Origin.X) * cosA - (PointB.Y - Origin.Y) * sinA) * Scale + Origin.X - (PointB.X - PointA.X) / 2;
  FQuad[5].y := ((PointB.X - Origin.X) * sinA + (PointB.Y - Origin.Y) * cosA) * Scale + Origin.Y - (PointB.Y - PointA.Y) / 2;

  FQuad[0].color := Color;
  FQuad[1].color := Color;
  FQuad[2].color := Color;
  FQuad[5].color := Color;

  FQuad[0].u := realUVA.U;   FQuad[0].v := realUVA.V;
  FQuad[1].u := realUVB.U;   FQuad[1].v := realUVA.V;
  FQuad[2].u := realUVA.U;   FQuad[2].v := realUVB.V;
  FQuad[5].u := realUVB.U;   FQuad[5].v := realUVB.V;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
// Draws textured rotated rectangle along free axis
//=============================================================================
procedure TQuadRender.DrawRectRotAxis(const PointA, PointB: TVec2f; Angle, Scale: Double;
  const Axis, UVA, UVB: TVec2f; Color: Cardinal);
var
  Alpha: Single;
  SinA, CosA: Single;
  realUVA, realUVB: TVec2f;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  RenderMode := D3DPT_TRIANGLELIST;

  realUVA := UVA;
  realUVB := UVB;

  if FTextureMirroring in [qtmHorizontal, qtmBoth] then
  begin
    realUVA.X := UVB.X;
    realUVB.X := UVA.X;
  end;
  if FTextureMirroring in [qtmVertical, qtmBoth] then
  begin
    realUVA.Y := UVB.Y;
    realUVB.Y := UVA.Y;
  end;


  Alpha := Angle * (pi / 180);

  FastSinCos(Alpha, SinA, CosA);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}

  FQuad[0].x := ((PointA.X - Axis.X) * cosA - (PointA.Y - Axis.Y) * sinA) * Scale + Axis.X;
  FQuad[0].y := ((PointA.X - Axis.X) * sinA + (PointA.Y - Axis.Y) * cosA) * Scale + Axis.Y;

  FQuad[1].x := ((PointB.X - Axis.X) * cosA - (PointA.Y - Axis.Y) * sinA) * Scale + Axis.X;
  FQuad[1].y := ((PointB.X - Axis.X) * sinA + (PointA.Y - Axis.Y) * cosA) * Scale + Axis.Y;

  FQuad[2].x := ((PointA.X - Axis.X) * cosA - (PointB.Y - Axis.Y) * sinA) * Scale + Axis.X;
  FQuad[2].y := ((PointA.X - Axis.X) * sinA + (PointB.Y - Axis.Y) * cosA) * Scale + Axis.Y;

  FQuad[5].x := ((PointB.X - Axis.X) * cosA - (PointB.Y - Axis.Y) * sinA) * Scale + Axis.X;
  FQuad[5].y := ((PointB.X - Axis.X) * sinA + (PointB.Y - Axis.Y) * cosA) * Scale + Axis.Y;

  FQuad[0].color := Color;
  FQuad[1].color := Color;
  FQuad[2].color := Color;
  FQuad[5].color := Color;

  FQuad[0].u := realUVA.U;   FQuad[0].v := realUVA.V;
  FQuad[1].u := realUVB.U;   FQuad[1].v := realUVA.V;
  FQuad[2].u := realUVA.U;   FQuad[2].v := realUVB.V;
  FQuad[5].u := realUVB.U;   FQuad[5].v := realUVB.V;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
// Draws circle
//=============================================================================
procedure TQuadRender.DrawCircle(const Center: TVec2f; Radius,
  InnerRadius: Single; Color: Cardinal);
begin
  if FIsDeviceLost then
    Exit;

  TQuadShader.CircleShader.BindVariableToPS(0, @FCircleRadius, 1);
  FCircleRadius := InnerRadius / Radius;
  TQuadShader.CircleShader.SetShaderState(True);
  DrawRect(Center - Radius, Center + Radius, TVec2f.Zero, TVec2f.Create(1.0, 1.0), Color);
  TQuadShader.CircleShader.SetShaderState(False);
end;

//=============================================================================
// Draws Line
//=============================================================================
procedure TQuadRender.DrawLine(const PointA, PointB: TVec2f; Color: Cardinal);
var
  ver: array [0..1] of TVertex;
  i: Integer;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  RenderMode := D3DPT_LINELIST;

  ver[0] := PointA;
  ver[1] := PointB;

  ver[0].Color := Color;
  ver[1].Color := Color;

  Move(ver, FVertexBuffer[FCount], 2 * SizeOf(TVertex));
  Inc(FCount, 2);

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
// Draws Point
//=============================================================================
procedure TQuadRender.DrawPoint(const Point: TVec2f; Color: Cardinal);
var
  ver: array [0..0] of TVertex;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  RenderMode := D3DPT_POINTLIST;

  ver[0] := Point;
  ver[0].color := Color;

  Move(ver, FVertexBuffer[FCount], SizeOf(TVertex));
  inc(FCount, 1);

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
// Draws line using triangles
//=============================================================================
procedure TQuadRender.DrawQuadLine(const PointA, PointB: TVec2f; width1, width2: Single; Color1, Color2: Cardinal);
var
  line: TVec2f;
  perpendicular: TVec2f;
  i: Integer;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  line := pointB - pointA;

  perpendicular := line.Normal.Normalize;

  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
    SetTexture(i, nil);

  FQuad[1] := pointA + perpendicular * (width1 / 2);
  FQuad[0] := pointA - perpendicular * (width1 / 2);
  FQuad[2] := pointB - perpendicular * (width2 / 2);
  FQuad[5] := pointB + perpendicular * (width2 / 2);

  FQuad[0].color := Color1;
  FQuad[1].color := Color1;
  FQuad[2].color := Color2;
  FQuad[5].color := Color2;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
// Draws textured rectangle
//=============================================================================
procedure TQuadRender.Drawrect(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal);
var
  realUVA, realUVB: TVec2f;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  realUVA := UVA;
  realUVB := UVB;

  if FTextureMirroring in [qtmHorizontal, qtmBoth] then
  begin
    realUVA.X := UVB.X;
    realUVB.X := UVA.X;
  end;
  if FTextureMirroring in [qtmVertical, qtmBoth] then
  begin
    realUVA.Y := UVB.Y;
    realUVB.Y := UVA.Y;
  end;


  RenderMode := D3DPT_TRIANGLELIST;
                                        { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  FQuad[0] := PointA;
  FQuad[1].x := PointB.X;    FQuad[1].y := PointA.Y;
  FQuad[2].x := PointA.X;    FQuad[2].y := PointB.Y;
  FQuad[5] := PointB;

  FQuad[0].color := Color;
  FQuad[1].color := Color;
  FQuad[2].color := Color;
  FQuad[5].color := Color;

  FQuad[0].u := realUVA.X;  FQuad[0].v := realUVA.Y;
  FQuad[1].u := realUVB.X;  FQuad[1].v := realUVA.Y;
  FQuad[2].u := realUVA.X;  FQuad[2].v := realUVB.Y;
  FQuad[5].u := realUVB.X;  FQuad[5].v := realUVB.Y;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.EndRender;
begin
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.EndScene) then
    FProfilerTags.EndScene.BeginCount;
  {$ENDIF}
  if FIsDeviceLost then
    Exit;

  FlushBuffer;

  Device.LastResultCode := FD3DDevice.EndScene;
  if not FIsRenderIntoTexture then
    Device.LastResultCode := FD3DDevice.Present(nil, nil, 0, nil);

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.EndScene) then
    FProfilerTags.EndScene.BeginCount;
  if Assigned(FProfiler) then
    FProfiler.EndTick;
  {$ENDIF}
end;

//=============================================================================
// Finalization routine
//=============================================================================
procedure TQuadRender.Finalize;
begin
  ReleaseVolatileResources;
end;

//=============================================================================
// Flush buffer into backbuffer and clear it
//=============================================================================
procedure TQuadRender.FlushBuffer;
var
  pver: Pointer;
  PrimitiveCount: Cardinal;
begin
  if FIsDeviceLost then
    Exit;

  PrimitiveCount := 0;

  case FRenderMode of
    D3DPT_POINTLIST:
    begin
      // if vertex count less then one — exit
      // else we cannot draw point (1 vertex)
      if FCount = 0 then
        Exit;

      PrimitiveCount := FCount;
    end;
    D3DPT_LINELIST:
    begin
      // if vertex count less then two — exit
      // else we cannot draw line (2 triangles)
      if FCount < 2 then
        Exit;

      PrimitiveCount := FCount div 2;
    end;
    D3DPT_TRIANGLELIST:
    begin
      // if vertex count less then six — exit
      // else we cannot draw quad (2 triangles)
      if FCount < 6 then
        Exit;

      PrimitiveCount := FCount div 3;
    end;
  else
    Exit;
  end;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.DrawCall) then
    FProfilerTags.DrawCall.BeginCount;
  {$ENDIF}
  Device.LastResultCode := FD3DVB.Lock(0, 0, pver, D3DLOCK_DISCARD);
  Move(FVertexBuffer, Pver^, FCount * SizeOf(TVertex));
  Device.LastResultCode := FD3DVB.Unlock;
  Device.LastResultCode := FD3DDevice.DrawPrimitive(FRenderMode, 0, PrimitiveCount);
  FCount := 0;
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.DrawCall) then
    FProfilerTags.DrawCall.EndCount;
  {$ENDIF}
end;

//=============================================================================
// Returns available free video memory in bytes
//=============================================================================
function TQuadRender.GetAvailableTextureMemory: Cardinal;
begin
  Result := FD3DDevice.GetAvailableTextureMem;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetD3DDevice: IDirect3DDevice9;
begin
  Result := FD3DDevice;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetIsSeparateAlphaBlend: Boolean;
begin
  Result := (FD3DCaps.PrimitiveMiscCaps and D3DPMISCCAPS_SEPARATEALPHABLEND) = D3DPMISCCAPS_SEPARATEALPHABLEND;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetIsSupportedNonPow2: Boolean;
begin
  Result := ((FD3DCaps.TextureCaps and D3DPTEXTURECAPS_POW2) = D3DPTEXTURECAPS_POW2) and
            ((FD3DCaps.TextureCaps and D3DPTEXTURECAPS_NONPOW2CONDITIONAL) <>D3DPTEXTURECAPS_NONPOW2CONDITIONAL);
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetNumSimultaneousRTs: Cardinal;
begin
  Result := FD3DCaps.NumSimultaneousRTs;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetMaxAnisotropy: Cardinal;
begin
  Result := FD3DCaps.MaxAnisotropy;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetMaxTextureHeight: Cardinal;
begin
  Result := FD3DCaps.MaxTextureHeight;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetMaxTextureStages: Cardinal;
begin
  Result := FD3DCaps.MaxTextureBlendStages;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetMaxTextureWidth: Cardinal;
begin
  Result := FD3DCaps.MaxTextureWidth;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetPixelShaderVersionString: PWideChar;
begin
  Result := PWideChar(IntToStr(PSVersionMajor) + '.' + IntToStr(PSVersionMinor));
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetProjectionMatrix: TD3DMatrix;
begin
  Device.LastResultCode :=  FD3DDevice.GetTransform(D3DTS_PROJECTION, Result);
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetPSVersionMajor: Byte;
begin
  Result := (FD3DCaps.PixelShaderVersion and $FFFF) shr 8;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetPSVersionMinor: Byte;
begin
  Result := (FD3DCaps.PixelShaderVersion and $FF);
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetRenderDeviceName: PWideChar;
begin
  Result := PWideChar(string(FD3DAI.DeviceName));
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetVertexShaderVersionString: PWideChar;
begin
  Result := PWideChar(IntToStr(VSVersionMajor) + '.' + IntToStr(VSVersionMinor));
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetVSVersionMajor: Byte;
begin
  Result := (FD3DCaps.VertexShaderVersion and $FFFF) shr 8;
end;

//=============================================================================
//
//=============================================================================
function TQuadRender.GetVSVersionMinor: Byte;
begin
  Result := (FD3DCaps.VertexShaderVersion and $FF);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.Initialize(AHandle: THandle; AWidth, AHeight: Integer;
  AIsFullscreen : Boolean; AShaderModel: TQuadShaderModel = qsm20);
var
  RenderInit: TRenderInit;
begin
  RenderInit.Handle := AHandle;
  RenderInit.Width := AWidth;
  RenderInit.Height := AHeight;
  RenderInit.BackBufferCount := 1;
  RenderInit.RefreshRate := -1;
  RenderInit.Fullscreen := AIsFullscreen;
  RenderInit.SoftwareVertexProcessing := True;
  RenderInit.MultiThreaded := True;
  RenderInit.VerticalSync := False;
  RenderInit.ShaderModel := AShaderModel;

  InitializeEx(RenderInit);
end;

//=============================================================================
// Main initialization routine
//=============================================================================
procedure TQuadRender.InitializeFromIni(AHandle: THandle; AFilename: PWideChar);
const
  ASection: string = 'Quadengine';
var
  AIniFile: TIniFile;
  ARenderInit: TRenderInit;
begin
  AIniFile := TIniFile.Create(AFilename);

  try
    ARenderInit.Width := AIniFile.ReadInteger(ASection, 'Width', 800);
    ARenderInit.Height := AIniFile.ReadInteger(ASection, 'Height', 600);
    ARenderInit.Fullscreen := AIniFile.ReadBool(ASection, 'Fullscreen', False);
    ARenderInit.BackBufferCount := AIniFile.ReadInteger(ASection, 'BackBufferCount', 1);
    ARenderInit.RefreshRate := AIniFile.ReadInteger(ASection, 'RefreshRate', -1);
    ARenderInit.SoftwareVertexProcessing := AIniFile.ReadBool(ASection, 'SoftwareVertexProcessing', True);
    ARenderInit.MultiThreaded := AIniFile.ReadBool(ASection, 'MultiThreaded', True);
    ARenderInit.VerticalSync := AIniFile.ReadBool(ASection, 'VerticalSync', False);
    ARenderInit.ShaderModel := TQuadShaderModel(AIniFile.ReadInteger(ASection, 'ShaderModel', Integer(qsm20)));
  finally
    AIniFile.Free;
  end;

  InitializeEx(ARenderInit);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.InitializeVolatileResources;
var
  i: Integer;
  qbm: TQuadBlendMode;
begin
  CreateOrthoMatrix;
  Device.LastResultCode := FD3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);

  Device.LastResultCode := FD3DDevice.CreateVertexBuffer(MaxBufferCount * SizeOf(TVertex),
                                                         D3DUSAGE_WRITEONLY,
                                                         0,
                                                         D3DPOOL_DEFAULT,
                                                         FD3DVB,
                                                         nil);

  Device.LastResultCode := FD3DDevice.SetStreamSource(0, FD3DVB, 0, sizeof(Tvertex));
  FCount := 0;

  Device.LastResultCode := FD3DDevice.CreateVertexDeclaration(@decl, FD3DVD);
  Device.LastResultCode := FD3DDevice.SetVertexDeclaration(FD3DVD);

  // enable diffuse blending and set filtering for all texture stages
  for i := 0 to MaxTextureStages - 1 do
  begin
    Device.LastResultCode := FD3DDevice.SetTextureStageState(i, D3DTSS_COLOROP, D3DTOP_MODULATE);
    Device.LastResultCode := FD3DDevice.SetTextureStageState(i, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    Device.LastResultCode := FD3DDevice.SetTextureStageState(i, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    Device.LastResultCode := FD3DDevice.SetTextureStageState(i, D3DTSS_ALPHAOP, D3DTOP_MODULATE);

    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
  end;

  // disable culling
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_GOURAUD);

  // restore blending
  qbm := Fqbm;
  Fqbm := qbmInvalid;
  SetBlendMode(qbm);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_COLORVERTEX, iFalse);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ZWRITEENABLE, iTrue);
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SCISSORTESTENABLE, iFalse);   

  FD3DDevice.GetRenderTarget(0, FBackBuffer);
  Device.ReInitializeRenderTargets;
end;

//=============================================================================
// Draws Polygon
//=============================================================================
procedure TQuadRender.Polygon(const PointA, PointB, PointC, PointD: TVec2f; Color: Cardinal);
var
  i : Integer;
begin
  if FIsDeviceLost then
    Exit;
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
    SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  FQuad[0] := PointA;
  FQuad[1] := PointB;
  FQuad[2] := PointC;
  FQuad[5] := PointD;

  FQuad[0].color := Color;
  FQuad[1].color := Color;
  FQuad[2].color := Color;
  FQuad[5].color := Color;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
// Draws rectangle
//=============================================================================
procedure TQuadRender.Rectangle(const PointA, PointB: TVec2f; Color: Cardinal);
var
  i: Integer;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}
  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
    SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  FQuad[0] := PointA;
  FQuad[1].x := PointB.X;     FQuad[1].y := PointA.Y;
  FQuad[2].x := PointA.X;     FQuad[2].y := PointB.Y;
  FQuad[5] := PointB;

  FQuad[0].color := Color;
  FQuad[1].color := Color;
  FQuad[2].color := Color;
  FQuad[5].color := Color;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
// Draws rectangle
//=============================================================================
procedure TQuadRender.RectangleEx(const PointA, PointB: TVec2f; Color1, Color2,
  Color3, Color4: Cardinal);
var
  i : Integer;
begin
  if FIsDeviceLost then
    Exit;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.BeginCount;
  {$ENDIF}

  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
    SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  FQuad[0] := PointA;
  FQuad[1].x := PointB.X;     FQuad[1].y := PointA.Y;
  FQuad[2].x := PointA.X;     FQuad[2].y := PointB.Y;
  FQuad[5] := PointB;

  FQuad[0].color := Color1;
  FQuad[1].color := Color2;
  FQuad[2].color := Color3;
  FQuad[5].color := Color4;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.Draw) then
    FProfilerTags.Draw.EndCount;
  {$ENDIF}

  AddQuadToBuffer;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.ReleaseVolatileResources;
begin
  Device.FreeRenderTargets;
  FBackBuffer := nil;
  FD3DVB := nil;
  FD3DVD := nil;
end;

//=============================================================================
// Enable/disable rendering into GBuffer
//=============================================================================
procedure TQuadRender.RenderToGBuffer(AIsRenderToGBuffer: Boolean; AQuadGBuffer: IQuadGBuffer = nil; AIsCropScreen: Boolean = False);
var
  Obj: TQuadGBuffer;
  TexBuffer: IQuadTexture;
begin
  if FIsDeviceLost then
    Exit;

  if AIsRenderToGBuffer then
  begin
    AQuadGBuffer.GetBuffer(TexBuffer);
    RenderToTexture(True, TexBuffer, 0, 0, AIsCropScreen);
    RenderToTexture(True, TexBuffer, 1, 1, AIsCropScreen);
    RenderToTexture(True, TexBuffer, 2, 2, AIsCropScreen);
    RenderToTexture(True, TexBuffer, 3, 3, AIsCropScreen);

    Obj := AQuadGBuffer as TQuadGBuffer;
    Obj.Camera := TQuadCamera.CurrentCamera;

    TQuadShader.MRTShader.SetShaderState(True);
  end
  else
  begin
    TQuadShader.MRTShader.SetShaderState(False);
    RenderToTexture(False);
  end;

  FIsRenderIntoTexture := AIsRenderToGBuffer;
end;

//=============================================================================
// Enable/disable rendering into texture with index "Count"
//=============================================================================
procedure TQuadRender.RenderToTexture(AIsRenderToTexture: Boolean; AQuadTexture: IQuadTexture = nil;
  ATextureRegister: Byte = 0; ARenderTargetRegister: Byte = 0; AIsCropScreen: Boolean = False);
var
  ARenderSurface: IDirect3DSurface9;
  i: Integer;
begin
  if FIsDeviceLost then
    Exit;

  FlushBuffer;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SwitchRenderTarget) then
    FProfilerTags.SwitchRenderTarget.BeginCount;
  {$ENDIF}

  if (AQuadTexture = nil) and AIsRenderToTexture then
    Exit;

  FIsRenderIntoTexture := AIsRenderToTexture;

  if AIsRenderToTexture then
  begin
    FOldScreenWidth := FWidth;
    FOldScreenHeight := FHeight;

    if AIsCropScreen then
      ChangeResolution(AQuadTexture.GetTextureWidth, AQuadTexture.GetTextureHeight);

    AQuadTexture.GetTexture(ATextureRegister).GetSurfaceLevel(0, ARenderSurface);
    Device.LastResultCode := FD3DDevice.SetRenderTarget(ARenderTargetRegister, ARenderSurface);
  end
  else
  begin
    if (FOldScreenWidth <> FWidth) or (FOldScreenHeight <> FHeight) then
      ChangeResolution(FOldScreenWidth, FOldScreenHeight);

    for i := 1 to FD3DCaps.NumSimultaneousRTs - 1 do
      Device.LastResultCode := FD3DDevice.SetRenderTarget(i, nil);

    Device.LastResultCode := FD3DDevice.SetRenderTarget(0, FBackBuffer);
  end;
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SwitchRenderTarget) then
    FProfilerTags.SwitchRenderTarget.EndCount;
  {$ENDIF}
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.ResetDevice;
var
  R: HRESULT;
begin
  R := FD3DDevice.TestCooperativeLevel;

  FIsDeviceLost := Failed(R);

  if FIsDeviceLost then
  begin
    ReleaseVolatileResources;
    repeat
      Sleep(50);
      R := D3DDevice.TestCooperativeLevel;
      if R = D3DERR_DEVICELOST then
        Continue;

      if R = D3DERR_DEVICENOTRESET then
        Device.LastResultCode := FD3DDevice.Reset(FD3DPP);

    until Succeeded(R);

    InitializeVolatileResources;

    FIsDeviceLost := False;
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetAutoCalculateTBN(Value: Boolean);
begin
  FIsAutoCalculateTBN := Value;
end;

//=============================================================================
// Set blend mode and alpha blending
//=============================================================================
procedure TQuadRender.SetBlendMode(qbm: TQuadBlendMode);
begin
  if (qbm = Fqbm) or FIsDeviceLost then
    Exit;

  FlushBuffer;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SetBlendMode) then
    FProfilerTags.SetBlendMode.BeginCount;
  {$ENDIF}
  Fqbm := qbm;
  case qbm of
    qbmNone:
    begin
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
      FIsEnabledBlending := False;
    end;
    qbmAdd:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    end;
    qbmSrcAlpha:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    end;
    qbmSrcAlphaAdd:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    end;
    qbmSrcAlphaMul:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ZERO);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    end;
    qbmMul:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ZERO);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR);
    end;
    qbmSrcColor:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
    end;
    qbmSrcColorAdd:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    end;
    qbmInvertSrcColor:
    begin
      if not FIsEnabledBlending then
      begin
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
        FIsEnabledBlending := True;
      end;        

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_INVSRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
    end;
  end;

  if FIsRenderIntoTexture and GetIsSeparateAlphaBlend then
  begin
    FD3DDevice.SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, iTrue);
    FD3DDevice.SetRenderState(D3DRS_SRCBLENDALPHA, D3DBLEND_SRCALPHA);
    FD3DDevice.SetRenderState(D3DRS_DESTBLENDALPHA, D3DBLEND_ONE);
  end;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SetBlendMode) then
    FProfilerTags.SetBlendMode.EndCount;
  {$ENDIF}
end;

//=============================================================================
// Set clip rectangle for rendering
//=============================================================================
procedure TQuadRender.SetClipRect(X, Y, X2, Y2: Cardinal);
begin
  FViewport.Left   := X;
  FViewport.Top    := Y;
  FViewport.Right  := X2;
  FViewport.Bottom := Y2;

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SCISSORTESTENABLE, iTrue);
  Device.LastResultCode := FD3DDevice.SetScissorRect(@FViewport);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetPointSize(ASize: Cardinal);
begin
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_POINTSIZE, ASize);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetRenderMode(const Value: TD3DPrimitiveType);
begin
  if Value = FRenderMode then
    Exit;

  FlushBuffer;
  FRenderMode := Value;
end;

//=============================================================================
// Main initialization routine.
// Yes, it's long. Yes, I know it. And yes, I know it's not good at all!!!
//=============================================================================
procedure TQuadRender.InitializeEx(const ARenderInit: TRenderInit);

  function CompleteBooleanText(AText: PChar; AState: Boolean): PChar; inline;
  begin
    Result := PChar(AText + ': ');
    if AState then
      Result := PChar(Result + 'Off')
    else
      Result := PChar(Result + 'On');
  end;

var
  winrect: TRect;
  winstyle: Integer;
  BehaviorFlag: Cardinal;
  Shader: TQuadShader;
begin
  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write('QuadRender Initialization');
    Device.Log.Write(PChar('Resolution: ' + IntToStr(ARenderInit.Width) + 'x' + IntToStr(ARenderInit.Height)));
  end;
  {$ENDREGION}

  FWidth := ARenderInit.Width;
  FHeight := ARenderInit.Height;
  FHandle := ARenderInit.Handle;

  FShaderModel := ARenderInit.ShaderModel;

  if ARenderInit.Fullscreen then
  begin
    winstyle := GetWindowLong(FHandle, GWL_STYLE);
    winrect.Left := 0;
    winrect.Top := 0;
    winrect.Right := FWidth;
    winrect.Bottom := FHeight;
    AdjustWindowRect(winrect, winstyle, False);
    SetWindowPos(FHandle, HWND_TOP, 0, 0, winrect.Right, winrect.Bottom, SWP_NOMOVE or SWP_SHOWWINDOW);
  end;

  Device.LastResultCode := Device.D3D.GetAdapterDisplayMode(Device.ActiveMonitorIndex, FD3DDM);
  Device.LastResultCode := Device.D3D.GetAdapterIdentifier(Device.ActiveMonitorIndex, 0, FD3DAI);

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write(PChar('Driver: ' + FD3DAI.Driver));
    Device.Log.Write(PChar('Description: ' + FD3DAI.Description));
    Device.Log.Write(PChar('Device: ' + FD3DAI.DeviceName));
  end;
  {$ENDREGION}

  with FD3DPP do
  begin
    BackBufferWidth              := FWidth;
    BackBufferHeight             := FHeight;
    BackBufferFormat             := D3DDM.Format;
    BackBufferCount              := ARenderInit.BackBufferCount;
    MultiSampleType              := D3DMULTISAMPLE_NONE;
    MultiSampleQuality           := 0;
    SwapEffect                   := D3DSWAPEFFECT_DISCARD;
    hDeviceWindow                := FHandle;
    Windowed                     := not ARenderInit.Fullscreen;
    EnableAutoDepthStencil       := False;
    Flags                        := 0;
    if not ARenderInit.Fullscreen then
      FullScreen_RefreshRateInHz := 0
    else
      begin
        if ARenderInit.RefreshRate < 0 then
          FullScreen_RefreshRateInHz := FD3DDM.RefreshRate
        else
          FullScreen_RefreshRateInHz := ARenderInit.RefreshRate;
      end;
    if ARenderInit.VerticalSync then
      PresentationInterval := D3DPRESENT_INTERVAL_ONE
    else
      PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  end;

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write(CompleteBooleanText('Multisample', False));
    Device.Log.Write(CompleteBooleanText('Fullscreen', ARenderInit.Fullscreen));
    Device.Log.Write(CompleteBooleanText('Vsync', ARenderInit.VerticalSync));
  end;
  {$ENDREGION}

  if ARenderInit.SoftwareVertexProcessing then
    BehaviorFlag := D3DCREATE_SOFTWARE_VERTEXPROCESSING
  else
    BehaviorFlag := D3DCREATE_HARDWARE_VERTEXPROCESSING;

  if ARenderInit.MultiThreaded then
    BehaviorFlag := BehaviorFlag or D3DCREATE_MULTITHREADED;

  Device.LastResultCode := Device.D3D.CreateDevice(Device.ActiveMonitorIndex,
                                                   D3DDEVTYPE_HAL,
                                                   FHandle,
                                                   BehaviorFlag,
                                                   @FD3DPP,
                                                   FD3DDevice);

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write('Vertex processing: Software');
    Device.Log.Write('Thread model: Multithreaded');
  end;
  {$ENDREGION}

  Device.LastResultCode := Device.D3D.GetDeviceCaps(Device.ActiveMonitorIndex, D3DDEVTYPE_HAL, FD3DCaps);

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write(PChar('Max VB count: ' + IntToStr(MaxBufferCount)));
    Device.Log.Write(PChar('Max Texture size: ' + IntToStr(MaxTextureWidth) + 'x' + IntToStr(MaxTextureHeight)));
    Device.Log.Write(PChar('Max Texture stages: ' + IntToStr(MaxTextureStages)));
    Device.Log.Write(PChar('Max Anisotropy: ' + IntToStr(MaxAnisotropy)));
    Device.Log.Write(PChar('Vertex shaders: ' + PixelShaderVersionString));
    Device.Log.Write(PChar('Pixel shaders: ' + PixelShaderVersionString));
    if IsSeparateAlphaBlend then
      Device.Log.Write('Separate alpha blending');
    if IsSupportedNonPow2 then
      Device.Log.Write('Supported non power of 2 textures');
  end;
  {$ENDREGION}

  InitializeVolatileResources;

  // set length of possible texture stages
  SetLength(FActiveTexture, MaxTextureStages);

  // ps2_0
  case FShaderModel of
    qsm20: begin
      if Device.Log <> nil then
        Device.Log.Write('Shader model 2.0');

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('DistantFieldPS20');
      TQuadShader.DistanceField := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('CirclePS20');
      TQuadShader.CircleShader := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('mrtVS20', False);
      Shader.LoadFromResource('mrtPS20');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.mrtShader := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('deferredVS20', False);
      Shader.LoadFromResource('deferredPS20');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.DeferredShading := Shader;
    end;
    qsm30: begin
      if Device.Log <> nil then
        Device.Log.Write('Shader model 3.0');

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('DistantFieldVS30', False);
      Shader.LoadFromResource('DistantFieldPS30');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.DistanceField := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('CircleVS30', False);
      Shader.LoadFromResource('CirclePS30');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.CircleShader := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('mrtVS30', False);
      Shader.LoadFromResource('mrtPS30');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.mrtShader := Shader;

      Shader := TQuadShader.Create(Self);
      Shader.LoadFromResource('deferredVS30', False);
      Shader.LoadFromResource('deferredPS30');
      Shader.BindVariableToVS(0, @FViewMatrix, 4);
      TQuadShader.DeferredShading := Shader;
    end;
    qsmNone:
      if Device.Log <> nil then
        Device.Log.Write('Samder model not specified');
  end;

  FIsInitialized := True;
end;

//=============================================================================
// Set active texures and flush buffer if texture changed
//=============================================================================
procedure TQuadRender.SetTexture(aRegister : Byte; const aTexture: IDirect3DTexture9);
begin
  if (ARegister >= MaxTextureStages) or (aTexture = FActiveTexture[aRegister]) then
    Exit;

  FlushBuffer;

  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SwitchTexture) then
    FProfilerTags.SwitchTexture.BeginCount;
  {$ENDIF}
  FActiveTexture[aRegister] := aTexture;
  Device.LastResultCode := FD3DDevice.SetTexture(aRegister, FActiveTexture[aRegister]);
  {$IFDEF DEBUG}
  if Assigned(FProfilerTags.SwitchTexture) then
    FProfilerTags.SwitchTexture.EndCount;
  {$ENDIF}
end;

//=============================================================================
// Defines constants that describe the supported texture-addressing modes.
//=============================================================================
procedure TQuadRender.SetTextureAdressing(ATextureAdressing: TQuadTextureAdressing);
var
  i: Integer;
  Value: Cardinal;
begin
  if ATextureAdressing = FTextureAdressing then
    Exit;

  FTextureAdressing := ATextureAdressing;

  case FTextureAdressing of
    qtaWrap:       Value := D3DTADDRESS_WRAP;
    qtaMirror:     Value := D3DTADDRESS_MIRROR ;
    qtaClamp:      Value := D3DTADDRESS_CLAMP ;
    qtaBorder:     Value := D3DTADDRESS_BORDER ;
    qtaMirrorOnce: Value := D3DTADDRESS_MIRRORONCE;
  else
    Value := D3DTADDRESS_CLAMP;
  end;

  for i := 0 to MaxTextureStages - 1 do
  begin
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_ADDRESSU, Value);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_ADDRESSV, Value);
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetTextureFiltering(ATextureFiltering: TQuadTextureFiltering);
var
  i: Integer;
  Value: Cardinal;
begin
  if ATextureFiltering = FTextureFiltering then
    Exit;

  FTextureFiltering := ATextureFiltering;

  case FTextureFiltering of
    qtfNone:            Value := D3DTEXF_NONE;
    qtfPoint:           Value := D3DTEXF_POINT;
    qtfLinear:          Value := D3DTEXF_LINEAR;
    qtfANisotropic:     Value := D3DTEXF_ANISOTROPIC;
    qtfPyramidalQuad:   Value := D3DTEXF_PYRAMIDALQUAD;
    qtfGaussianQuad:    Value := D3DTEXF_GAUSSIANQUAD;
    qtfConvolutionMono: Value := D3DTEXF_CONVOLUTIONMONO;
  else
    Value := D3DTEXF_LINEAR;
  end;

  for i := 0 to MaxTextureStages - 1 do
  begin
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MIPFILTER, Value);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MAGFILTER, Value);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MINFILTER, Value);
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetTextureMirroring(ATextureMirroring: TQuadTextureMirroring);
begin
  FlushBuffer;
  FTextureMirroring := ATextureMirroring;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetViewMatrix(const AViewMatrix: TD3DMatrix);
begin
  FViewMatrix := AViewMatrix;
end;

//=============================================================================
// Set clip rectangle with fullscreen
//=============================================================================
procedure TQuadRender.SkipClipRect;
begin
  FViewport.Left   := 0;
  FViewport.Top    := 0;
  FViewport.Right  := FWidth;
  FViewport.Bottom := FHeight;

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SCISSORTESTENABLE, iFalse);
  Device.LastResultCode := FD3DDevice.SetScissorRect(@FViewport);
end;

//=============================================================================
// Take Screenshot and save to file
//=============================================================================
procedure TQuadRender.TakeScreenshot(AFileName: PWideChar);
var
  Surface: IDirect3DSurface9;
  LockedRect: TD3DLockedRect;
  Bitmap: TBitmap;
  Png: TPngImage;
  pbit: PByteArray;
  psur: PByteArray;
  i, j: Integer;
  Point: TPoint;
begin
  Point.SetLocation(0, 0);
  ClientToScreen(FHandle, Point);

  Device.LastResultCode := FD3DDevice.CreateOffscreenPlainSurface(FD3DDM.Width, FD3DDM.Height, D3DFMT_A8R8G8B8, D3DPOOL_SCRATCH, Surface, nil);
  Device.LastResultCode := FD3DDevice.GetFrontBufferData(0, Surface);
  Device.LastResultCode := Surface.LockRect(LockedRect, nil, D3DLOCK_READONLY or D3DLOCK_NO_DIRTY_UPDATE or D3DLOCK_NOSYSLOCK);

  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := pf24bit;
  Bitmap.Width := FD3DPP.BackBufferWidth;
  Bitmap.Height := FD3DPP.BackBufferHeight;

  for i := 0 to FD3DPP.BackBufferHeight - 1 do
  begin
    pbit := Bitmap.ScanLine[i];
    psur := Pointer(Cardinal(LockedRect.pBits) + Cardinal(i + Point.Y) * FD3DDM.Width * 4);

    for j := 0 to FD3DPP.BackBufferWidth - 1 do
    begin
      pbit[j * 3] := psur[(j + Point.X) * 4 + 0];
      pbit[j * 3 + 1] := psur[(j + Point.X) * 4 + 1];
      pbit[j * 3 + 2] := psur[(j + Point.X) * 4 + 2];
    end;
  end;

  Png := TPngImage.Create;
  Png.Assign(Bitmap);
  png.SaveToFile(AFileName);
  png.Free;

  Bitmap.Free;

  Device.LastResultCode := Surface.UnlockRect;
  Surface := nil;
end;

end.
