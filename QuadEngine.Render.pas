{//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================}

unit QuadEngine.Render;

interface

uses
  Winapi.Windows, Winapi.direct3d9, Winapi.DXTypes, graphics, VCL.Imaging.pngimage,
  QuadEngine.Utils, QuadEngine.Log, Vec2f, QuadEngine, IniFiles, System.SysUtils;

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
    FIsRenderIntoTexture: Boolean;
    Fqbm: TQuadBlendMode;
    FVertexBuffer: array [0..MaxBufferCount - 1] of TVertex;
    FTextureAdressing: TQuadTextureAdressing;
    FTextureFiltering: TQuadTextureFiltering;
    FViewMatrix: TD3DMatrix;
    FWidth: Integer;
    FTimer: IQuadTimer;
    FRenderMode: TD3DPrimitiveType;
    procedure AddQuadToBuffer(Vertexes: array of TVertex);
    function GetProjectionMatrix: TD3DMatrix;
    procedure SetRenderMode(const Value: TD3DPrimitiveType);
    procedure DoInitialize(AHandle : THandle; AWidth, AHeight, ABackBufferCount, ARefreshRate : Integer;
      AIsFullscreen, AIsCreateLog, AIsSoftwareVertexProcessing, AIsMultiThreaded, AIsVerticalSync : Boolean);
  public
    constructor Create;
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
    procedure AddTrianglesToBuffer(const AVertexes: array of TVertex; ACount: Cardinal); stdcall;
    procedure BeginRender; stdcall;
    procedure ChangeResolution(AWidth, AHeight: Word); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    procedure CreateOrthoMatrix; stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRect(x, y, x2, y2: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRectRot(x, y, x2, y2, ang, Scale: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRectRotAxis(x, y, x2, y2, ang, Scale, xA, yA : Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawLine(x, y, x2, y2 : Single; Color: Cardinal); stdcall;
    procedure DrawPoint(x, y: Single; Color: Cardinal); stdcall;
    procedure DrawQuadLine(x1, x2, y1, y2, width1, width2: Single; Color1, Color2: Cardinal); stdcall;
    procedure EndRender; stdcall;
    procedure Finalize; stdcall;
    procedure FlushBuffer; stdcall;
    procedure Initialize(AHandle: THandle; AWidth, AHeight: Integer;
      AIsFullscreen: Boolean; AIsCreateLog: Boolean = True); stdcall;
    procedure InitializeFromIni(AHandle: THandle; AFilename: PWideChar); stdcall;
    procedure Polygon(x1, y1, x2, y2, x3, y3, x4, y4: Double; Color: Cardinal); stdcall;
    procedure Rectangle(x, y, x2, y2: Double; Color: Cardinal); stdcall;
    procedure RectangleEx(x, y, x2, y2: Double; Color1, Color2, Color3, Color4: Cardinal); stdcall;
    procedure RenderToTexture(AIsRenderToTexture: Boolean; AQuadTexture: IQuadTexture = nil;
      ATextureRegister: Byte = 0; ARenderTargetRegister: Byte = 0; AIsCropScreen: Boolean = False); stdcall;
    procedure SetAutoCalculateTBN(Value: Boolean); stdcall;
    procedure SetBlendMode(qbm: TQuadBlendMode); stdcall;
    procedure SetClipRect(X, Y, X2, Y2: Cardinal); stdcall;
    procedure SetTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure SetTextureAdressing(ATextureAdressing: TQuadTextureAdressing); stdcall;
    procedure SetTextureFiltering(ATextureFiltering: TQuadTextureFiltering); stdcall;
    procedure SetPointSize(ASize: Cardinal); stdcall;
    procedure SkipClipRect; stdcall;
    procedure TakeScreenshot(AFileName: PWideChar); stdcall;
    procedure ResetDevice; stdcall;
    function GetD3DDevice: IDirect3DDevice9; stdcall;

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
  end;

implementation

uses
  QuadEngine.Texture, QuadEngine.Shader, QuadEngine.Font, QuadEngine.Timer,
  Math, QuadEngine.Device;

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

//=============================================================================
//
//=============================================================================
procedure TQuadRender.AddQuadToBuffer(Vertexes: array of TVertex);
begin
  if FIsAutoCalculateTBN then
  begin
    CalcTBN(Vertexes[0].tangent, Vertexes[0].binormal, Vertexes[0].normal, Vertexes[0], Vertexes[1], Vertexes[2]);
    CalcTBN(Vertexes[1].tangent, Vertexes[1].binormal, Vertexes[1].normal, Vertexes[0], Vertexes[1], Vertexes[2]);
    CalcTBN(Vertexes[2].tangent, Vertexes[2].binormal, Vertexes[2].normal, Vertexes[0], Vertexes[1], Vertexes[2]);
    CalcTBN(Vertexes[5].tangent, Vertexes[5].binormal, Vertexes[5].normal, Vertexes[0], Vertexes[1], Vertexes[2]);
  end;

  Vertexes[3] := Vertexes[2];
  Vertexes[4] := Vertexes[1];

  move(Vertexes, FVertexBuffer[FCount], 6 * SizeOf(TVertex));
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
  Device.LastResultCode := FD3DDevice.BeginScene;

  ResetDevice;

  if FIsDeviceLost then
    Exit;

//  Device.LastResultCode := FD3DDevice.BeginScene;

  FCount := 0;
end;

//=============================================================================
// Clears render target with color
//=============================================================================
procedure TQuadRender.ChangeResolution(AWidth, AHeight: Word);
begin
  FWidth := aWidth;
  FHeight := aHeight;

  FD3DPP.BackBufferWidth := FWidth;
  FD3DPP.BackBufferHeight := FHeight;

//  ResetDevice;

  CreateOrthoMatrix;
  Device.LastResultCode := FD3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.Clear(AColor: Cardinal);
begin
  Device.LastResultCode := FD3DDevice.Clear(0, nil, D3DCLEAR_TARGET, AColor, 1.0, 0);
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
  FIsRenderIntoTexture := False;

  FRenderMode := D3DPT_TRIANGLELIST;

  FIsDeviceLost := False;
  FIsAutoCalculateTBN := True;
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
procedure TQuadRender.DrawrectRot(x, y, x2, y2, ang, Scale: Double;
  u1, v1, u2, v2 : Double; Color : Cardinal);
var
  ver: array [0..5] of TVertex;
  xo, yo: Single;
  Alpha: Single;
  SinA, CosA: Extended;
begin
  RenderMode := D3DPT_TRIANGLELIST;

  xo := (x2 - x) / 2 + x;
  yo := (y2 - y) / 2 + y;
  Alpha := ang * (pi / 180);

  SinCos(Alpha, SinA, CosA);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].u := u1;   ver[0].v := v1;
  ver[1].u := u2;   ver[1].v := v1;
  ver[2].u := u1;   ver[2].v := v2;
  ver[5].u := u2;   ver[5].v := v2;

  ver[0].x := ((x - xo) * cosA - (y - yo) * sinA) * Scale + xo - (x2 - x) / 2;
  ver[0].y := ((x - xo) * sinA + (y - yo) * cosA) * Scale + yo - (y2 - y) / 2;
  ver[0].z := 0;

  ver[1].x := ((x2 - xo) * cosA - (y - yo) * sinA) * Scale + xo - (x2 - x) / 2;
  ver[1].y := ((x2 - xo) * sinA + (y - yo) * cosA) * Scale + yo - (y2 - y) / 2;
  ver[1].z := 0;

  ver[2].x := ((x - xo) * cosA - (y2 - yo) * sinA) * Scale + xo - (x2 - x) / 2;
  ver[2].y := ((x - xo) * sinA + (y2 - yo) * cosA) * Scale + yo - (y2 - y) / 2;
  ver[2].z := 0;

  ver[5].x := ((x2 - xo) * cosA - (y2 - yo) * sinA) * Scale + xo - (x2 - x) / 2;
  ver[5].y := ((x2 - xo) * sinA + (y2 - yo) * cosA) * Scale + yo - (y2 - y) / 2;
  ver[5].z := 0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Draws textured rotated rectangle along free axis
//=============================================================================
procedure TQuadRender.DrawRectRotAxis(x, y, x2, y2, ang, Scale, xA, yA, u1, v1,
  u2, v2: Double; Color: Cardinal);
var
  ver: array [0..5] of TVertex;
  xo, yo: Single;
  Alpha: Single;
  SinA, CosA: Extended;
begin
  RenderMode := D3DPT_TRIANGLELIST;

  xo := xA;
  yo := yA;
  Alpha := ang * (pi / 180);

  SinCos(Alpha, SinA, CosA);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].u := u1;   ver[0].v := v1;
  ver[1].u := u2;   ver[1].v := v1;
  ver[2].u := u1;   ver[2].v := v2;
  ver[5].u := u2;   ver[5].v := v2;

  ver[0].x := ((x - xo) * cosA - (y - yo) * sinA) * Scale + xo;// - (x2 - x) / 2;
  ver[0].y := ((x - xo) * sinA + (y - yo) * cosA) * Scale + yo;// - (y2 - y) / 2;
  ver[0].z := 0;

  ver[1].x := ((x2 - xo) * cosA - (y - yo) * sinA) * Scale + xo;// - (x2 - x) / 2;
  ver[1].y := ((x2 - xo) * sinA + (y - yo) * cosA) * Scale + yo;// - (y2 - y) / 2;
  ver[1].z := 0;

  ver[2].x := ((x - xo) * cosA - (y2 - yo) * sinA) * Scale + xo;// - (x2 - x) / 2;
  ver[2].y := ((x - xo) * sinA + (y2 - yo) * cosA) * Scale + yo;// - (y2 - y) / 2;
  ver[2].z := 0;

  ver[5].x := ((x2 - xo) * cosA - (y2 - yo) * sinA) * Scale + xo;// - (x2 - x) / 2;
  ver[5].y := ((x2 - xo) * sinA + (y2 - yo) * cosA) * Scale + yo;// - (y2 - y) / 2;
  ver[5].z := 0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Draws textured polygon
//=============================================================================
procedure TQuadRender.DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double;
  u1, v1, u2, v2 : Double; Color: Cardinal);
var
  ver : array [0..11] of TVertex;
  cx, cy : Single;
  vec1, vec2, vec3, vec4 : TVec2f;
//  res : TVec2f;
  zn, ch1, ch2 : Single;
  ua, ub : Single;
  i : Integer;
begin
  RenderMode := D3DPT_TRIANGLELIST;
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}

  vec1.Create(x1, y1);   //1.A
  vec3.Create(x3, y3);   //1.B

  vec2.Create(x2, y2);   //2.A
  vec4.Create(x4, y4);   //2.B

{  zn :=(vec1.x - vec3.x) * (vec4.y - vec2.y) - (vec1.y - vec3.y) * (vec4.x - vec2.x);
  ch1 :=(vec1.x - vec2.x) * (vec4.y - vec2.y) - (vec1.y - vec2.y) * (vec4.x - vec2.x);
  ch2 :=(vec1.x - vec3.x) * (vec1.y - vec2.y) - (vec1.y - vec3.y) * (vec1.x - vec2.x);

  ua := ch1 / Zn;
  ub := ch2 / Zn;

  cx := vec1.x + (vec3.x - vec1.x) * Ub;
  cy := vec1.y + (vec3.y - vec1.y) * Ub;
 }


 { ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].u := u1;  ver[0].v := v1;
  ver[1].u := u2;  ver[1].v := v1;
  ver[2].u := u1;  ver[2].v := v2;
  ver[5].u := u2;  ver[5].v := v2;

  ver[0].x := x1;    ver[0].y := y1;     ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y2;     ver[1].z := 0;
  ver[2].x := x4;    ver[2].y := y4;     ver[2].z := 0;
  ver[5].x := x3;    ver[5].y := y3;     ver[5].z := 0;       }

  for i := 0 to 11 do
  ver[i].color := Color;

  cx := 256;
  cy := 256;       {todo : подумать. дисторт искажает спрайт сильно :(}


  ver[0].u := u1;  ver[0].v := v1;
  ver[1].u := u2;  ver[1].v := v1;
  ver[2].u := 0.5; ver[2].v := 0.5;

  ver[3].u := u2;  ver[3].v := v1;
  ver[4].u := u2;  ver[4].v := v2;
  ver[5].u := 0.5; ver[5].v := 0.5;

  ver[6].u := u2;   ver[6].v := v2;
  ver[7].u := u1;   ver[7].v := v2;
  ver[8].u := 0.5;  ver[8].v := 0.5;

  ver[9].u := u1;   ver[9].v := v2;
  ver[10].u := u1;  ver[10].v := v1;
  ver[11].u := 0.5; ver[11].v := 0.5;



  ver[0].x := x1;    ver[0].y := y1;     ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y2;     ver[1].z := 0;
  ver[2].x := cx;    ver[2].y := cy;     ver[2].z := 0;

  ver[3].x := x2;    ver[3].y := y2;     ver[3].z := 0;
  ver[4].x := x3;    ver[4].y := y3;     ver[4].z := 0;
  ver[5].x := cx;    ver[5].y := cy;     ver[5].z := 0;

  ver[6].x := x3;    ver[6].y := y3;     ver[6].z := 0;
  ver[7].x := x4;    ver[7].y := y4;     ver[7].z := 0;
  ver[8].x := cx;    ver[8].y := cy;     ver[8].z := 0;

  ver[9].x := x4;    ver[9].y := y4;     ver[9].z := 0;
  ver[10].x := x1;   ver[10].y := y1;    ver[10].z := 0;
  ver[11].x := cx;   ver[11].y := cy;    ver[11].z := 0;

  AddTrianglesToBuffer(ver, 12);
end;

//=============================================================================
// Draws Line
//=============================================================================
procedure TQuadRender.DrawLine(x, y, x2, y2: Single; Color: Cardinal);
var
  ver: array [0..1] of TVertex;
begin
  RenderMode := D3DPT_LINELIST;

  ver[0].color := Color;
  ver[1].color := Color;

  ver[0].x := x;     ver[0].y := y;     ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y2;    ver[1].z := 0;

  Move(ver, FVertexBuffer[FCount], 2 * SizeOf(TVertex));
  inc(FCount, 2);

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
// Draws Point
//=============================================================================
procedure TQuadRender.DrawPoint(x, y: Single; Color: Cardinal);
var
  ver: array [0..0] of TVertex;
begin
  RenderMode := D3DPT_POINTLIST;

  ver[0].color := Color;

  ver[0].x := x;     ver[0].y := y;     ver[0].z := 0;

  Move(ver, FVertexBuffer[FCount], SizeOf(TVertex));
  inc(FCount, 1);

  if FCount >= MaxBufferCount then
    FlushBuffer;
end;

//=============================================================================
// Draws line using triangles
//=============================================================================
procedure TQuadRender.DrawQuadLine(x1, y1, x2, y2, width1, width2: Single; Color1, Color2: Cardinal);
var
  point1, point2: TVec2f;
  line: TVec2f;
  A, B, C, D: TVec2f;
  perpendicular: TVec2f;
  ver : array [0..5] of TVertex;
begin
  point1.Create(x1, y1);
  point2.Create(x2, y2);

  line := point2 - point1;

  perpendicular := line.Normal.Normalize;

  A := point1 + perpendicular * (width1 / 2);
  B := point1 - perpendicular * (width1 / 2);

  C := point2 + perpendicular * (width2 / 2);
  D := point2 - perpendicular * (width2 / 2);

  RenderMode := D3DPT_TRIANGLELIST;

  ver[0].color := Color1;
  ver[1].color := Color1;
  ver[2].color := Color2;
  ver[5].color := Color2;

  ver[0].x := B.X;     ver[0].y := B.Y;     ver[0].z := 0.0;
  ver[1].x := A.X;     ver[1].y := A.Y;     ver[1].z := 0.0;
  ver[2].x := D.X;     ver[2].y := D.Y;     ver[2].z := 0.0;
  ver[5].x := C.X;     ver[5].y := C.Y;     ver[5].z := 0.0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Draws textured rectangle
//=============================================================================
procedure TQuadRender.Drawrect(x, y, x2, y2: Double; u1, v1, u2, v2 : Double; Color : Cardinal);
var
  ver : array [0..5] of TVertex;
begin
  RenderMode := D3DPT_TRIANGLELIST;
                                        { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].u := u1;  ver[0].v := v1;
  ver[1].u := u2;  ver[1].v := v1;
  ver[2].u := u1;  ver[2].v := v2;
  ver[5].u := u2;  ver[5].v := v2;

  ver[0].x := x;     ver[0].y := y;     ver[0].z := 0.0;
  ver[1].x := x2;    ver[1].y := y;     ver[1].z := 0.0;
  ver[2].x := x;     ver[2].y := y2;    ver[2].z := 0.0;
  ver[5].x := x2;    ver[5].y := y2;    ver[5].z := 0.0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.EndRender;
begin
  if FIsDeviceLost then
    Exit;

  FlushBuffer;

  Device.LastResultCode := FD3DDevice.EndScene;
  if not FIsRenderIntoTexture then
    Device.LastResultCode := FD3DDevice.Present(nil, nil, 0, nil);
end;

//=============================================================================
// Finalization routine
//=============================================================================
procedure TQuadRender.Finalize;
begin
  FD3DVD := nil;
  FD3DVB := nil
  //FD3DDevice := nil

  //FD3D :=  := nil;
end;

//=============================================================================
// Flush buffer into backbuffer and clear it
//=============================================================================
procedure TQuadRender.FlushBuffer;
var
  pver : Pointer;
  PrimitiveCount : Cardinal;
begin
  PrimitiveCount := 0;

  case FRenderMode of
    D3DPT_POINTLIST :
    begin
      // if vertex count less then six — exit
      // else we cannot draw quad (2 triangles)
      if FCount = 0 then
        Exit;

      PrimitiveCount := FCount;
    end;
    D3DPT_LINELIST :
    begin
      // if vertex count less then six — exit
      // else we cannot draw quad (2 triangles)
      if FCount < 2 then
        Exit;

      PrimitiveCount := FCount div 2;
    end;
    D3DPT_TRIANGLELIST :
    begin
      // if vertex count less then six — exit
      // else we cannot draw quad (2 triangles)
      if FCount < 6 then
        Exit;

      PrimitiveCount := FCount div 3;
    end;
  end;

  Device.LastResultCode := FD3DVB.Lock(0, 0, pver, 0);
  Move(FVertexBuffer, Pver^, FCount * SizeOf(TVertex));
  Device.LastResultCode := FD3DVB.Unlock;
  Device.LastResultCode := FD3DDevice.DrawPrimitive(FRenderMode, 0, PrimitiveCount);
  FCount := 0;
end;

//=============================================================================
// Returns available free video memory in bytes
//=============================================================================
function TQuadRender.GetAvailableTextureMemory: Cardinal;
begin
  Result := FD3DDevice.GetAvailableTextureMem;
  Device.LastResultCode := FD3DDevice.TestCooperativeLevel;
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
  AIsFullscreen : Boolean; AIsCreateLog : Boolean = True);
begin
  DoInitialize(AHandle, AWidth, AHeight, 1, 0, AIsFullscreen, AIsCreateLog, True, True, False);
end;

//=============================================================================
// Main initialization routine
//=============================================================================
procedure TQuadRender.InitializeFromIni(AHandle: THandle; AFilename: PWideChar);
const
  ASection: string = 'Quadengine';
var
  AIniFile: TIniFile;
  AWidth, AHeight: Integer;
  AIsFullscreen: Boolean;
  ABackBufferCount: Byte;
  ARefreshRate: Byte;
  AIsSoftwareVertexProcessing: Boolean;
  AIsMultiThreaded: Boolean;
  AIsVerticalSync: Boolean;
begin
  AIniFile := TIniFile.Create(AFilename);

  try
    AWidth := AIniFile.ReadInteger(ASection, 'Width', 800);
    AHeight := AIniFile.ReadInteger(ASection, 'Height', 600);
    AIsFullscreen := AIniFile.ReadBool(ASection, 'Fullscreen', False);
    ABackBufferCount := AIniFile.ReadInteger(ASection, 'BackBufferCount', 1);
    ARefreshRate := AIniFile.ReadInteger(ASection, 'RefreshRate', 60);
    AIsSoftwareVertexProcessing := AIniFile.ReadBool(ASection, 'SoftwareVertexProcessing', True);
    AIsMultiThreaded := AIniFile.ReadBool(ASection, 'MultiThreaded', True);
    AIsVerticalSync := AIniFile.ReadBool(ASection, 'VerticalSync', False);
  finally
    AIniFile.Free;
  end;
  
  DoInitialize(AHandle, AWidth, AHeight, ABackBufferCount, ARefreshRate, AIsFullscreen,
    True, AIsSoftwareVertexProcessing, AIsMultiThreaded, AIsVerticalSync);
end;

//=============================================================================
// Draws Polygon
//=============================================================================
procedure TQuadRender.Polygon(x1, y1, x2, y2, x3, y3, x4, y4: Double;
  Color: Cardinal);
var
  ver : array [0..5] of TVertex;
  i : Integer;
begin
  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
  SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].x := x1;    ver[0].y := y1;    ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y2;    ver[1].z := 0;
  ver[2].x := x3;    ver[2].y := y3;    ver[2].z := 0;
  ver[5].x := x4;    ver[5].y := y4;    ver[5].z := 0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Draws rectangle
//=============================================================================
procedure TQuadRender.Rectangle(x, y, x2, y2: Double; Color: Cardinal);
var
  ver: array [0..5] of TVertex;
  i: Integer;
begin
  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
    SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color;
  ver[1].color := Color;
  ver[2].color := Color;
  ver[5].color := Color;

  ver[0].x := x;     ver[0].y := y;     ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y;     ver[1].z := 0;
  ver[2].x := x;     ver[2].y := y2;    ver[2].z := 0;
  ver[5].x := x2;    ver[5].y := y2;    ver[5].z := 0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Draws rectangle
//=============================================================================
procedure TQuadRender.RectangleEx(x, y, x2, y2: Double; Color1, Color2, Color3,
  Color4: Cardinal);
var
  ver : array [0..5] of TVertex;
  i : Integer;
begin
  RenderMode := D3DPT_TRIANGLELIST;

  for i := 0 to MaxTextureStages - 1 do
  SetTexture(i, nil);
                                      { NOTE : use only 0, 1, 2, 5 vertex.
                                               Vertex 3, 4 autocalculated}
  ver[0].color := Color1;
  ver[1].color := Color2;
  ver[2].color := Color3;
  ver[5].color := Color4;

  ver[0].x := x;     ver[0].y := y;     ver[0].z := 0;
  ver[1].x := x2;    ver[1].y := y;     ver[1].z := 0;
  ver[2].x := x;     ver[2].y := y2;    ver[2].z := 0;
  ver[5].x := x2;    ver[5].y := y2;    ver[5].z := 0;

  AddQuadToBuffer(ver);
end;

//=============================================================================
// Enable/disable rendering into texture with index "Count"
//=============================================================================
procedure TQuadRender.RenderToTexture(AIsRenderToTexture: Boolean; AQuadTexture: IQuadTexture = nil;
  ATextureRegister: Byte = 0; ARenderTargetRegister: Byte = 0; AIsCropScreen: Boolean = False); stdcall;
var
  ARenderSurface: IDirect3DSurface9;
  ADesc : D3DSURFACE_DESC;
  i: Integer;
begin
  FlushBuffer;
  FIsRenderIntoTexture := AIsRenderToTexture;

  if AQuadTexture = nil then
    Exit;

  if AIsRenderToTexture then
  begin
    if AIsCropScreen then
      ChangeResolution(AQuadTexture.GetTextureWidth, AQuadTexture.GetTextureHeight);

    AQuadTexture.GetTexture(ATextureRegister).GetSurfaceLevel(0, ARenderSurface);
    Device.LastResultCode := FD3DDevice.SetRenderTarget(ARenderTargetRegister, ARenderSurface);
  end
  else
  begin
    Device.LastResultCode := FBackBuffer.GetDesc(ADesc);
    ChangeResolution(ADesc.Width, ADesc.Height);
    Device.LastResultCode := FD3DDevice.SetRenderTarget(0, FBackBuffer);

    for i := 1 to FD3DCaps.NumSimultaneousRTs - 1 do
      Device.LastResultCode := FD3DDevice.SetRenderTarget(0, nil);
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.ResetDevice;
var
  R: HRESULT;
begin
  R := FD3DDevice.TestCooperativeLevel;

  FIsDeviceLost := (R = D3DERR_DEVICELOST) or (R = D3DERR_DEVICENOTRESET);
 { if Failed(R) then
    FIsDeviceLost := True;

  if R = D3DERR_DEVICELOST then
    Exit;

  if (R = D3DERR_DEVICENOTRESET) and (GetForegroundWindow = FHandle) then
  begin
    R := FD3DDevice.Reset(FD3DPP);

    if Failed(R) then
      Exit;

    FIsDeviceLost := False;
  end;
  }
  {TODO : ???}

  if FIsDeviceLost then
  begin
    while (R <> D3DERR_DEVICENOTRESET) do
    begin
      WaitForSingleObject(Self.FHandle, 50);
      R := FD3DDevice.TestCooperativeLevel;
    end;

    if R = D3DERR_DEVICENOTRESET then
    begin
      R := FD3DDevice.Reset(FD3DPP);
      FIsDeviceLost := False;
    end;
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
  if qbm = Fqbm then
    Exit;

  FlushBuffer;

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
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
      FIsEnabledBlending := True;
    end;
    qbmSrcAlpha:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
      FIsEnabledBlending := True;
    end;
    qbmSrcAlphaAdd:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
      FIsEnabledBlending := True;
    end;
    qbmSrcAlphaMul:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ZERO);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
      FIsEnabledBlending := True;
    end;
    qbmMul:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ZERO);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR);
      FIsEnabledBlending := True;
    end;
    qbmSrcColor:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
      FIsEnabledBlending := True;
    end;
    qbmSrcColorAdd:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
      FIsEnabledBlending := True;
    end;
    qbmInvertSrcColor:
    begin
      if not FIsEnabledBlending then
        Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);

      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_INVSRCCOLOR);
      Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR);
      FIsEnabledBlending := True;
    end;
  end;
end;

//=============================================================================
// Set clip rectangle for rendering
//=============================================================================
procedure TQuadRender.SetClipRect(X, Y, X2, Y2: Cardinal);
var
  Viewport: TRect;
begin
  Viewport.Left   := X;
  Viewport.Top    := Y;
  Viewport.Right  := X2;
  Viewport.Bottom := Y2;

  Device.LastResultCode := FD3DDevice.SetScissorRect(@Viewport);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetPointSize(ASize: Cardinal); stdcall;
begin
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_POINTSIZE, ASize);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadRender.SetRenderMode(const Value: TD3DPrimitiveType);
begin
  if Value <> FRenderMode then
  begin
    FlushBuffer;
    FRenderMode := Value;
  end;
end;

//=============================================================================
// Main initialization routine
//=============================================================================
procedure TQuadRender.DoInitialize(AHandle: THandle; AWidth, AHeight, ABackBufferCount, ARefreshRate: Integer;
  AIsFullscreen, AIsCreateLog, AIsSoftwareVertexProcessing, AIsMultiThreaded, AIsVerticalSync: Boolean);
var
  i: Integer;
  winrect : TRect;
  winstyle : Integer;
begin
  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write('QuadRender Initialization');
    Device.Log.Write(PChar('Resolution: ' + IntToStr(aWidth) + 'x' + IntToStr(aHeight)));
  end;
  {$ENDREGION}

  FWidth := AWidth;
  FHeight := AHeight;
  FHandle := AHandle;

  if AIsFullscreen then
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
    BackBufferCount              := ABackBufferCount;
    MultiSampleType              := D3DMULTISAMPLE_NONE;
    MultiSampleQuality           := 0;
    SwapEffect                   := D3DSWAPEFFECT_DISCARD;
    hDeviceWindow                := FHandle;
    Windowed                     := not AIsFullscreen;
    EnableAutoDepthStencil       := False;
    Flags                        := 0;
    if not AIsFullscreen then
      FullScreen_RefreshRateInHz := D3DPRESENT_RATE_DEFAULT
    else
      FullScreen_RefreshRateInHz := FD3DDM.RefreshRate;
    PresentationInterval         := D3DPRESENT_INTERVAL_IMMEDIATE;
  end;

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write('Multisample: Off');
    Device.Log.Write('Fullscreen: Off');
    Device.Log.Write('Vsync: Off');         {todo: switch}
  end;
  {$ENDREGION}

  Device.LastResultCode := Device.D3D.CreateDevice(Device.ActiveMonitorIndex,
                                                   D3DDEVTYPE_HAL,
                                                   FHandle,
                                                   D3DCREATE_SOFTWARE_VERTEXPROCESSING or D3DCREATE_MULTITHREADED, //AIsSoftwareVertexPprocessing
                                                   @FD3DPP,
                                                   FD3DDevice);

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write('Vertex processing: Software');   {todo: switch}
    Device.Log.Write('Thread model: Multithreaded');   {todo: switch}
  end;
  {$ENDREGION}

  Device.LastResultCode := Device.D3D.GetDeviceCaps(Device.ActiveMonitorIndex, D3DDEVTYPE_HAL, FD3DCaps);

  CreateOrthoMatrix;
  Device.LastResultCode := FD3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);

  // set VB source
  Device.LastResultCode := FD3DDevice.CreateVertexBuffer(MaxBufferCount * SizeOf(TVertex),
                                                         0,
                                                         0,
                                                         D3DPOOL_MANAGED,
                                                         FD3DVB,
                                                         nil);
  Device.LastResultCode := FD3DDevice.SetStreamSource(0, FD3DVB, 0, sizeof(Tvertex));
  FCount := 0;

  {$REGION 'logging'}
  if Device.Log <> nil then
  begin
    Device.Log.Write(PChar('Max VB count: ' + IntToStr(MaxBufferCount)));   {todo: switch}
    Device.Log.Write(PChar('Max Texture size: ' + IntToStr(MaxTextureWidth) + 'x' + IntToStr(MaxTextureHeight)));   {todo: switch}
    Device.Log.Write(PChar('Max Texture stages: ' + IntToStr(MaxTextureStages)));   {todo: switch}
    Device.Log.Write(PChar('Max Anisotropy: ' + IntToStr(MaxAnisotropy)));   {todo: switch}
    Device.Log.Write(PChar('Vertex shaders: ' + PixelShaderVersionString));
    Device.Log.Write(PChar('Pixel shaders: ' + PixelShaderVersionString));
  end;
  {$ENDREGION}

  Device.LastResultCode := FD3DDevice.SetFVF(D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX3 or D3DFVF_DIFFUSE);
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
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SHADEMODE, D3DSHADE_GOURAUD);
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
  FIsEnabledBlending := True;
  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_COLORVERTEX, iFalse);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_ZENABLE, iFalse);

  Device.LastResultCode := FD3DDevice.SetRenderState(D3DRS_SCISSORTESTENABLE, iTrue);

  // set length of possible texture stages
  SetLength(FActiveTexture, MaxTextureStages);

  FD3DDevice.GetRenderTarget(0, FBackBuffer);

  TQuadShader.DistantField := TQuadShader.Create(Self);
  TQuadShader.DistantField.LoadFromResource('DistantField');
end;

//=============================================================================
// Set active texures and flush buffer if texture changed
//=============================================================================
procedure TQuadRender.SetTexture(aRegister : Byte; aTexture: IDirect3DTexture9);
begin
  if aTexture = FActiveTexture[aRegister] then
    Exit;

  FlushBuffer;

  FActiveTexture[aRegister] := aTexture;
  Device.LastResultCode := FD3DDevice.SetTexture(aRegister, FActiveTexture[aRegister]);
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
  end;

  for i := 0 to MaxTextureStages - 1 do
  begin
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MIPFILTER, Value);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MAGFILTER, Value);
    Device.LastResultCode := FD3DDevice.SetSamplerState(i, D3DSAMP_MINFILTER, Value);
  end;
end;
                                                                               
//=============================================================================
// Set clip rectangle with fullscreen
//=============================================================================
procedure TQuadRender.SkipClipRect;
var
  R : TRect;
begin
  R.Left   := 0;
  R.Top    := 0;
  R.Right  := FWidth;
  R.Bottom := FHeight;

  Device.LastResultCode := FD3DDevice.SetScissorRect(@R);
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
begin
  Device.LastResultCode := FD3DDevice.CreateOffscreenPlainSurface(FD3DDM.Width, FD3DDM.Height, D3DFMT_A8R8G8B8, D3DPOOL_SCRATCH, Surface, nil);
  Device.LastResultCode := FD3DDevice.GetFrontBufferData(0, Surface);
  Device.LastResultCode := Surface.LockRect(LockedRect, nil, D3DLOCK_READONLY or D3DLOCK_NO_DIRTY_UPDATE or D3DLOCK_NOSYSLOCK);

  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := pf24bit;
  Bitmap.Width := FWidth;
  Bitmap.Height := FHeight;

  for i := 0 to FHeight - 1 do
  begin
    pbit := Bitmap.ScanLine[i];
    psur := Pointer(Cardinal(LockedRect.pBits) + i * FD3DDM.Width * 4);

    for j := 0 to FWidth - 1 do
    begin
      pbit[j * 3] := psur[j * 4 + 0];
      pbit[j * 3 + 1] := psur[j * 4 + 1];
      pbit[j * 3 + 2] := psur[j * 4 + 2];
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
