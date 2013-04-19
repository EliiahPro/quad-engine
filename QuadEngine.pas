{==============================================================================

  Quad engine 0.5.1 header file for CodeGear™ Delphi®

     ╔═══════════╦═╗
     ║           ║ ║
     ║           ║ ║
     ║ ╔╗ ║║ ╔╗ ╔╣ ║
     ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
     ║  ║ engine   ║
     ║  ║          ║
     ╚══╩══════════╝

  For further information please visit:
  http://quad-engine.com

==============================================================================}

unit QuadEngine;

interface

uses
  Windows, Direct3D9, Vec2f;

const
  LibraryName: PChar = 'qei.dll';
  CreateQuadDeviceProcName: PChar = 'CreateQuadDevice';
  CreateQuadWindowProcName: PChar = 'CreateQuadWindow';
  SecretMagicFunctionProcName: PChar = 'SecretMagicFunction';

type
  // Blending mode types
  TQuadBlendMode = (qbmInvalid        = 0,
                    qbmNone           = 1,     { Without blending }
                    qbmAdd            = 2,     { Add source to dest }
                    qbmSrcAlpha       = 3,     { Blend dest with alpha to source }
                    qbmSrcAlphaAdd    = 4,     { Add source with alpha to dest }
                    qbmSrcAlphaMul    = 5,     { Multiply source alpha with dest }
                    qbmMul            = 6,     { Multiply Source with dest }
                    qbmSrcColor       = 7,     { Blend source with color weight to dest }
                    qbmSrcColorAdd    = 8,     { Blend source with color weight and alpha to dest }
                    qbmInvertSrcColor = 9);    { Blend inverted source color }

  // Texture adressing mode
  TQuadTextureAdressing = (qtaInvalid    = 0,
                           qtaWrap       = 1,    {Repeat UV}
                           qtaMirror     = 2,    {Repeat UV with mirroring}
                           qtaClamp      = 3,    {Do not repeat UV}
                           qtaBorder     = 4,    {Fill outranged UV with border}
                           qtaMirrorOnce = 5);   {Mirror UV once}

  // Texture filtering mode
  TQuadTextureFiltering = (qtfInvalid         = 0,
                           qtfNone            = 1,    { Filtering disabled (valid for mip filter only) }
                           qtfPoint           = 2,    { Nearest }
                           qtfLinear          = 3,    { Linear interpolation }
                           qtfAnisotropic     = 4,    { Anisotropic }
                           qtfPyramidalQuad   = 5,    { 4-sample tent }
                           qtfGaussianQuad    = 6,    { 4-sample gaussian }
                           qtfConvolutionMono = 7);   { Convolution filter for monochrome textures }


  // Vector record declaration
  TVector = packed record
    x: Single;
    y: Single;
    z: Single;
  end;

  // vertex record declaration
  TVertex = packed record
    x, y, z : Single;         { X, Y of vertex. Z is not used }
    Normal  : TVector;        { Normal vector }
    Color   : Cardinal;       { Color }
    u, v    : Single;         { Texture UV coord }
    Tangent : TVector;        { Tangent vector }
    Binormal: TVector;        { Binormal vector }
    class operator Implicit(const A: TVec2f): TVertex;
  end;

  // forward interfaces declaration
  IQuadDevice  = interface;
  IQuadRender  = interface;
  IQuadTexture = interface;
  IQuadShader  = interface;
  IQuadFont    = interface;
  IQuadLog     = interface;
  IQuadTimer   = interface;
  IQuadWindow  = interface;
  IQuadCamera  = interface;

  { Quad Render }

  // OnError routine. Calls whenever error occurs
  TOnErrorFunction = procedure(Errorstring: PWideChar); stdcall;

  IQuadDevice = interface(IUnknown)
    ['{E28626FF-738F-43B0-924C-1AFC7DEC26C7}']
    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar; out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateAndLoadTexture(ARegister: Byte; AFilename: PWideChar; out pQuadTexture: IQuadTexture;
      APatternWidth: Integer = 0; APatternHeight: Integer = 0; AColorKey : Integer = -1): HResult; stdcall;
    function CreateCamera(out pQuadCamera: IQuadCamera): HResult; stdcall;
    function CreateFont(out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateLog(out pQuadLog: IQuadLog): HResult; stdcall;
    function CreateShader(out pQuadShader: IQuadShader): HResult; stdcall;
    function CreateTexture(out pQuadTexture: IQuadTexture): HResult; stdcall;
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    /// <summary>Creates a rendertarget within specified <see cref="QuadEngine.IQuadTexture"/>.</summary>
    /// <param name="AWidth">Width of rendertarget.</param>
    /// <param name="AHeight">Height of rendertarget.</param>
    /// <param name="AQuadTexture">Pointer to declared <see cref="QuadEngine.IQuadTexture"/>. If it not created this function will create, if not then it will use existing one.</param>
    /// <param name="ARegister">Texture's register in which rendertarget must be assigned.</param>
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PWideChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;
  end;

  IQuadRender = interface(IUnknown)
    ['{D9E9C42B-E737-4CF9-A92F-F0AE483BA39B}']
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
    procedure ChangeResolution(AWidth, AHeight : Word); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    procedure CreateOrthoMatrix; stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRect(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawRectRot(const PointA, PointB: TVec2f; Angle, Scale: Double; const UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawRectRotAxis(const PointA, PointB: TVec2f; Angle, Scale: Double; const Axis, UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawLine(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawPoint(const Point: TVec2f; Color: Cardinal); stdcall;
    procedure DrawQuadLine(const PointA, PointB: TVec2f; Width1, Width2: Single; Color1, Color2: Cardinal); stdcall;
    procedure EndRender; stdcall;
    procedure Finalize; stdcall;
    procedure FlushBuffer; stdcall;
    procedure Initialize(AHandle: THandle; AWidth, AHeight: Integer;
      AIsFullscreen: Boolean; AIsCreateLog: Boolean = True); stdcall;
    procedure InitializeFromIni(AHandle: THandle; AFilename: PWideChar); stdcall;
    procedure Polygon(const PointA, PointB, PointC, PointD: TVec2f; Color: Cardinal); stdcall;
    procedure Rectangle(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure RectangleEx(const PointA, PointB: TVec2f; Color1, Color2, Color3, Color4: Cardinal); stdcall;
    /// <summary>Enables render to texture. You can use multiple render targets within one render call.</summary>
    /// <param name="AIsRenderToTexture">Enable render to texture.</param>
    /// <param name="AQuadTexture">IQuadTexture. Instance must be created with IQuadDevice.CreateRenderTexture only.</param>
    /// <param name="ATextureRegister">Register of IQuadTexture to be used for rendering.</param>
    /// <param name="ARenderTargetRegister">When using multiple rendertargets this parameter tells what register this rendertarget will be in output.</param>
    /// <param name="AIsCropScreen">Scale or crop scene to match rendertarget's resolution</param>
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
  end;

  { Quad Texture }

  IQuadTexture = interface(IUnknown)
    ['{9A617F86-2CEC-4701-BF33-7F4989031BBA}']
    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): IDirect3DTexture9; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure Draw(const Position: Tvec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f; Angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRot(const Center: TVec2f; angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure LoadFromFile(ARegister: Byte; AFilename: PWideChar; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;
  end;

  { Quad Shader }

  IQuadShader = interface(IUnknown)
    ['{7B7F4B1C-7F05-4BC2-8C11-A99696946073}']
    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader(out Shader: IDirect3DVertexShader9): HResult; stdcall;
    function GetPixelShader(out Shader: IDirect3DPixelShader9): HResult; stdcall;
    procedure LoadVertexShader(AVertexShaderFilename: PWideChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PWideChar); stdcall;
    procedure LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PWideChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
  end;

  { Quad Font }


  { Predefined colors for SmartColoring:
      W - white
      Z - black (zero)
      R - red
      L - lime
      B - blue
      M - maroon
      G - green
      N - Navy
      Y - yellow
      F - fuchsia
      A - aqua
      O - olive
      P - purple
      T - teal
      D - gray (dark)
      S - silver

      ! - default DrawText color
    ** Do not override "!" char **  }

  // font alignments
  TqfAlign = (qfaInvalid = 0,
              qfaLeft    = 1,      { Align by left }
              qfaRight   = 2,      { Align by right }
              qfaCenter  = 3,      { Align by center }
              qfaJustify = 4);     { Align by both sides}

  IQuadFont = interface(IUnknown)
    ['{A47417BA-27C2-4DE0-97A9-CAE546FABFBA}']
    function GetIsLoaded: Boolean; stdcall;
    function GetKerning: Single; stdcall;
    procedure LoadFromFile(ATextureFilename, AUVFilename : PWideChar); stdcall;
    procedure SetSmartColor(AColorChar: WideChar; AColor: Cardinal); stdcall;
    procedure SetIsSmartColoring(Value: Boolean); stdcall;
    procedure SetKerning(AValue: Single); stdcall;
    function TextHeight(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    function TextWidth(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    procedure TextOut(const Position: TVec2f; AScale: Single; AText: PWideChar; AColor: Cardinal = $FFFFFFFF;
      AAlign : TqfAlign = qfaLeft); stdcall;
  end;

  {Quad Log}

  IQuadLog = interface(IUnknown)
    ['{7A4CE319-C7AF-4BF3-9218-C2A744F915E6}']
    procedure Write(const aString: PWideChar); stdcall;
  end;

  {Quad Timer}

  TTimerProcedure = procedure(out delta: Double; Id: Cardinal); stdcall;
  { template:
    procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
    begin

    end;
  }
  IQuadTimer = interface(IUnknown)
    ['{EA3BD116-01BF-4E12-B504-07D5E3F3AD35}']
    function GetCPUload: Single; stdcall;
    function GetDelta: Double; stdcall;
    function GetFPS: Single; stdcall;
    function GetWholeTime: Double; stdcall;
    function GetTimerID: Cardinal; stdcall;
    procedure ResetWholeTimeCounter; stdcall;
    procedure SetCallBack(AProc: TTimerProcedure); stdcall;
    procedure SetInterval(AInterval: Word); stdcall;
    procedure SetState(AIsEnabled: Boolean); stdcall;
  end;

  {Quad Sprite}     {not implemented yet. do not use}

  IQuadSprite = interface(IUnknown)
  ['{3E6AF547-AB0B-42ED-A40E-8DC10FC6C45F}']
    procedure Draw; stdcall;
    procedure SetPosition(X, Y: Double); stdcall;
    procedure SetVelocity(X, Y: Double); stdcall;
  end;

  {Quad Window}     {not implemented yet. do not use}
  IQuadWindow = interface(IUnknown)
  ['{E8691EB1-4C5D-4565-8B78-3FC7C620DFFB}']
    function GetHandle: Cardinal; stdcall;
    procedure SetPosition(ATop, ALeft: Integer); stdcall;
    procedure SetDimentions(AWidth, AHeight: Integer); stdcall;
    procedure CreateWindow; stdcall;
  end;

  {Quad Camera}
  IQuadCamera = interface(IUnknown)
  ['{BBC0BBF2-7602-489A-BE2A-37D681B7A242}']
    procedure Shift(AXShift, AYShift: Single); stdcall;
    procedure Shear(AXShear, AYShear: Single); stdcall;
    procedure Zoom(AScale: Single); stdcall;
    procedure Rotate(AAngle: Single); stdcall;
    procedure Translate(AXDistance, AYDistance: Single); stdcall;
    procedure Reset; stdcall;
    procedure ApplyTransform; stdcall;
  end;

  TCreateQuadDevice    = function(out QuadDevice: IQuadDevice): HResult; stdcall;
  TCreateQuadWindow    = function(out QuadWindow: IQuadWindow): HResult; stdcall;
  TSecretMagicFunction = function: PWideChar;

  function CreateQuadDevice: IQuadDevice;
  function CreateWindow: IQuadWindow;

implementation

// Creating of main Quad interface object
function CreateQuadDevice: IQuadDevice;
var
  h: THandle;
  Creator: TCreateQuadDevice;
begin
  h := LoadLibrary(LibraryName);
  Creator := GetProcAddress(h, CreateQuadDeviceProcName);
  if Assigned(Creator) then
    Creator(Result);
end;

// Creating of Quad window interface object
function CreateWindow: IQuadWindow;
var
  h: THandle;
  Creator: TCreateQuadWindow;
begin
  h := LoadLibrary(LibraryName);
  Creator := GetProcAddress(h, CreateQuadWindowProcName);
  if Assigned(Creator) then
    Creator(Result);
end;

{ TVertex }

class operator TVertex.Implicit(const A: TVec2f): TVertex;
begin
  Result.x := A.X;
  Result.y := A.Y;
  Result.z := 0.0;
end;

end.
