{==============================================================================

  Quad engine 0.8.2 Diamond header file for Embarcadero™ Delphi® and FreePascal

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

  For license see COPYING

===============================================================================}

unit QuadEngine;

interface

{$INCLUDE QuadEngine.inc}

uses
  Windows, {$IFDEF USED3D} Direct3D9,{$ENDIF} Vec2f;

const
  LibraryName: PChar = 'qei.dll';
  CreateQuadDeviceProcName: PChar = 'CreateQuadDevice';
  SecretMagicFunctionProcName: PChar = 'SecretMagicFunction';
  QuadEngineMinorVersion: Byte = 0;
  QuadEngineMajorVersion: Byte = 8;
  QuadEngineReleaseVersion: Byte = 2;

type
  ///<summary>Blending mode types.</summary>
  ///<param name="qbmNone">Without blending</param>
  ///<param name="qbmAdd">Add source to destination</param>
  ///<param name="qbmSrcAlpha">Blend destination with alpha to source</param>
  ///<param name="qbmSrcAlphaAdd">Add source with alpha to destination</param>
  ///<param name="qbmSrcAlphaMul">Multiply source alpha with destination</param>
  ///<param name="qbmMul">Multiply Source with destination</param>
  ///<param name="qbmSrcColor">Blend source with color weight to destination</param>
  ///<param name="qbmSrcColorAdd">Blend source with color weight and alpha to destination</param>
  ///<param name="qbmInvertSrcColor">Blend inverted source color</param>
  ///<param name="qbmDstAlpha">Copy destination alpha to source</param>
  TQuadBlendMode = (qbmInvalid        = 0,
                    qbmNone           = 1,
                    qbmAdd            = 2,
                    qbmSrcAlpha       = 3,
                    qbmSrcAlphaAdd    = 4,
                    qbmSrcAlphaMul    = 5,
                    qbmMul            = 6,
                    qbmSrcColor       = 7,
                    qbmSrcColorAdd    = 8,
                    qbmInvertSrcColor = 9,
                    qbmDstAlpha       = 10);

  ///<summary>Texture adressing mode</summary>
  ///<param name="qtaWrap">Repeat UV</param>
  ///<param name="qtaMirror">Repeat UV with mirroring</param>
  ///<param name="qtaClamp">Do not repeat UV</param>
  ///<param name="qtaBorder">Fill outranged UV with border</param>
  ///<param name="qtaMirrorOnce">Mirror UV once</param>
  TQuadTextureAdressing = (qtaInvalid    = 0,
                           qtaWrap       = 1,
                           qtaMirror     = 2,
                           qtaClamp      = 3,
                           qtaBorder     = 4,
                           qtaMirrorOnce = 5);

  // Texture filtering mode
  TQuadTextureFiltering = (qtfInvalid         = 0,
                           qtfNone            = 1,    { Filtering disabled (valid for mip filter only) }
                           qtfPoint           = 2,    { Nearest }
                           qtfLinear          = 3,    { Linear interpolation }
                           qtfAnisotropic     = 4,    { Anisotropic }
                           qtfPyramidalQuad   = 5,    { 4-sample tent }
                           qtfGaussianQuad    = 6,    { 4-sample gaussian }
                           qtfConvolutionMono = 7);   { Convolution filter for monochrome textures }

  // Texture Mirroring mode
  TQuadTextureMirroring = (qtmInvalid    = 0,
                           qtmNone       = 1,   { No mirroring }
                           qtmHorizontal = 2,   { Horizontal mirroring }
                           qtmVertical   = 3,   { Vertical mirroring }
                           qtmBoth       = 4);  { Horizontal and vertical mirroring }

  // Vector record declaration
  TVector = packed record
    x: Single;
    y: Single;
    z: Single;
  end;


  TMatrix4x4 = packed record
    _11, _12, _13, _14: Single;
    _21, _22, _23, _24: Single;
    _31, _32, _33, _34: Single;
    _41, _42, _43, _44: Single;
  end;

  // vertex record declaration
  TVertex = packed record
    x, y, z : Single;         { X, Y of vertex. Z is not used }
    Normal  : TVector;        { Normal vector }
    Color   : Cardinal;       { Color }
    u, v    : Single;         { Texture UV coord }
    Tangent : TVector;        { Tangent vector }
    Binormal: TVector;        { Binormal vector }
    {$IFNDEF FPC}
    {$IF CompilerVersion > 17}
    class operator Implicit(const A: TVec2f): TVertex;
    {$IFEND}
    {$ENDIF}
  end;

  // Shader model
  TQuadShaderModel = (qsmInvalid = 0,
                      qsmNone    = 1,   // do not use shaders
                      qsm20      = 2,   // shader model 2.0
                      qsm30      = 3);  // shader model 3.0

  // Initialization record
  TRenderInit = packed record
    Handle                    : THandle;
    Width                     : Integer;
    Height                    : Integer;
    BackBufferCount           : Integer;
    RefreshRate               : Integer;
    Fullscreen                : Boolean;
    SoftwareVertexProcessing  : Boolean;
    MultiThreaded             : Boolean;
    VerticalSync              : Boolean;
    ShaderModel               : TQuadShaderModel;
  end;

  /// <summary>OnTimer Callback function prototype</summary>
  TTimerProcedure = procedure(out delta: Double; Id: Cardinal); stdcall;
  { template:
    procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
    begin

    end;
  }

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
  IQuadGBuffer = interface;
  IQuadProfiler = interface;

  { Quad Render }

  // OnError routine. Calls whenever error occurs
  TOnErrorFunction = procedure(Errorstring: PWideChar); stdcall;

  ///<summary>This is main quad-engine interface. Use it methods to create resources, change states and draw primitives.</summary>
  IQuadDevice = interface(IUnknown)
    ['{E28626FF-738F-43B0-924C-1AFC7DEC26C7}']
    /// <summary>Load font data from file and return a QuadFont object.</summary>
    /// <param name="ATextureFilename">Filename of texture file.</param>
    /// <param name="AUVFilename">Filename of additional font data file.</param>
    /// <param name="pQuadFont">IQuadFont variable to recieve object.</param>
    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar; out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateAndLoadTexture(ARegister: Byte; AFilename: PWideChar; out pQuadTexture: IQuadTexture;
      APatternWidth: Integer = 0; APatternHeight: Integer = 0; AColorKey : Integer = -1): HResult; stdcall;
    /// <summary>Return a QuadCamera object.</summary>
    /// <param name="pQuadCamera">IQuadCamera variable to recieve object.</param>
    function CreateCamera(out pQuadCamera: IQuadCamera): HResult; stdcall;
    /// <summary>Return a QuadFont object.</summary>
    /// <param name="pQuadFont">IQuadFont variable to recieve object.</param>
    function CreateFont(out pQuadFont: IQuadFont): HResult; stdcall;
    /// <summary>Return a QuadGBuffer object.</summary>
    /// <param name="pQuadGBuffer">IQuadGBuffer variable to recieve object.</param>
    function CreateGBuffer(out pQuadGBuffer: IQuadGBuffer): HResult; stdcall;
    /// <summary>Return a QuadLog object.</summary>
    /// <param name="pQuadLog">IQuadLog variable to recieve object.</param>
    function CreateLog(out pQuadLog: IQuadLog): HResult; stdcall;
    /// <summary>Return a QuadShader object.</summary>
    /// <param name="pQuadShader">IQuadShader variable to recieve object.</param>
    function CreateShader(out pQuadShader: IQuadShader): HResult; stdcall;
    /// <summary>Return a QuadTexture object.</summary>
    /// <param name="pQuadTexure">IQuadTexture variable to recieve object.</param>
    function CreateTexture(out pQuadTexture: IQuadTexture): HResult; stdcall;
    /// <summary>Return a QuadTimer object.</summary>
    /// <param name="pQuadTimer">IQuadTimer variable to recieve object.</param>
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    /// <summary>Return a QuadTimer object with full initialization.</summary>
    /// <param name="pQuadTimer">IQuadTimer variable to recieve object.</param>
    /// <param name="AProc">Callback to onTimer procedure. <see cref="TTimerProcedure"/>
    ///   <code>procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;</code>
    /// </param>
    /// <param name="AInterval">Timer interval in ms.</param>
    /// <param name="IsEnabled">False if need to create in suspended state.</param>
    function CreateTimerEx(out pQuadTimer: IQuadTimer; AProc: TTimerProcedure; AInterval: Word; IsEnabled: Boolean): HResult;
    /// <summary>Return a QuadRender object.</summary>
    /// <param name="pQuadRender">IQuadRender variable to recieve object.</param>
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    /// <summary>Creates a rendertarget within specified <see cref="QuadEngine.IQuadTexture"/>.</summary>
    /// <param name="AWidth">Width of rendertarget.</param>
    /// <param name="AHeight">Height of rendertarget.</param>
    /// <param name="AQuadTexture">Pointer to declared <see cref="QuadEngine.IQuadTexture"/>. If it not created this function will create one. Otherwise it will use existing one.</param>
    /// <param name="ARegister">Texture's register in which rendertarget must be assigned.</param>
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function CreateWindow(out pQuadWindow: IQuadWindow): HResult; stdcall;
    function CreateProfiler(AName: PWideChar; out pQuadProfiler: IQuadProfiler): HResult; stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PWideChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;
    procedure ShowCursor(Show: Boolean); stdcall;
    procedure SetCursorPosition(x, y: Integer); stdcall;
    /// <summary>The dimensions Image must be a power of two in each direction, although not necessarily the same power of two. The alpha channel must be either 0.0 or 1.0. </summary>
    procedure SetCursorProperties(XHotSpot, YHotSpot: Cardinal; const Image: IQuadTexture); stdcall;
  end;

  /// <summary>Main Quad-engine interface used for drawing. This object is singleton and cannot be created more than once.</summary>
  IQuadRender = interface(IUnknown)
    ['{D9E9C42B-E737-4CF9-A92F-F0AE483BA39B}']
    procedure GetClipRect(out ARect: TRect); stdcall;
    /// <summary>Retrieves the available texture memory.
    /// This will return all available texture memory including AGP aperture.</summary>
    /// <returns>Available memory size in bytes</returns>
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
    /// <summary>Begin of render. Call this routine before frame render begins.</summary>
    procedure BeginRender; stdcall;
    /// <summary>Change virtual or real resolution of the render.</summary>
    /// <param name="AWidth">New render width</param>
    /// <param name="AHeight">New render height</param>
    /// <param name="isVirtual">Virtual or real physical resolution</param>
    /// <remarks>Method must be called only from main thread if isVirtual param it set to False.</remarks>
    procedure ChangeResolution(AWidth, AHeight: Word; isVirtual: Boolean = True); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    procedure DrawCircle(const Center: TVec2f; Radius, InnerRadius: Single; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawLine(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawPoint(const Point: TVec2f; Color: Cardinal); stdcall;
    procedure DrawQuadLine(const PointA, PointB: TVec2f; Width1, Width2: Single; Color1, Color2: Cardinal); stdcall;
    /// <summary>End of render. Call this routine at the end of frame render.</summary>
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
    procedure SetTexture(ARegister: Byte; const ATexture: {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}); stdcall;
    procedure SetTextureAdressing(ATextureAdressing: TQuadTextureAdressing); stdcall;
    procedure SetTextureFiltering(ATextureFiltering: TQuadTextureFiltering); stdcall;
    procedure SetTextureMirroring(ATextureMirroring: TQuadTextureMirroring); stdcall;
    procedure SetPointSize(ASize: Cardinal); stdcall;
    procedure SkipClipRect; stdcall;
    /// <summary>Take and save to disk .png screenshot</summary>
    /// <param name="AFileName">Name and path of saved screenshot</param>
    procedure TakeScreenshot(AFileName: PWideChar); stdcall;
    procedure ResetDevice; stdcall;
    function GetD3DDevice: {$IFDEF USED3D}IDirect3DDevice9{$ELSE}Pointer{$ENDIF} stdcall;
  end;

  { Quad Texture }

  // RAW data format
  TRAWDataFormat = (rdfInvalid = 0,
                    rdfARGB8   = 1,
                    rdfRGBA8   = 2,
                    rdfABGR8   = 3);

  IQuadTexture = interface(IUnknown)
    ['{9A617F86-2CEC-4701-BF33-7F4989031BBA}']
    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetPixelColor(x, y: Integer; ARegister: Byte = 0): Cardinal; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure AddTexture(ARegister: Byte; ATexture: {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}); stdcall;
    procedure AssignTexture(AQuadTexture: IQuadTexture; ASourceRegister, ATargetRegister: Byte); stdcall;    
    procedure Draw(const Position: Tvec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f; Angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPart(const Position: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPartRot(const Center: TVec2f; angle, Scale: Double; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPartRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRot(const Center: TVec2f; angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure LoadFromFile(ARegister: Byte; AFilename: PWideChar; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromStream(ARegister: Byte; AStream: Pointer; AStreamSize: Integer; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer; ASourceFormat: TRAWDataFormat = rdfARGB8); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;
  end;

  { Quad Shader }
  /// <summary>This is quad-engine shader interface.
  /// Use it methods to load shader into GPU, bind variables to shader, execute shader programs.</summary>
  IQuadShader = interface(IUnknown)
    ['{7B7F4B1C-7F05-4BC2-8C11-A99696946073}']
    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader(out Shader: {$IFDEF USED3D}IDirect3DVertexShader9{$ELSE}Pointer{$ENDIF}): HResult; stdcall;
    function GetPixelShader(out Shader: {$IFDEF USED3D}IDirect3DPixelShader9{$ELSE}Pointer{$ENDIF}): HResult; stdcall;
    procedure LoadVertexShader(AVertexShaderFilename: PWideChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PWideChar); stdcall;
    procedure LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PWideChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
    procedure SetAutoCalculateTBN(Value: Boolean); stdcall;
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

  // distance field options
  TDistanceFieldParams = packed record
    Edge1X, Edge1Y: Single;
    Edge2X, Edge2Y: Single;
    OuterColor: Cardinal;
    FirstEdge, SecondEdge: Boolean;
  end;

  ///<summary>This is quad-engine textured fonts interface. Use it methods to render text.</summary>
  IQuadFont = interface(IUnknown)
    ['{A47417BA-27C2-4DE0-97A9-CAE546FABFBA}']
    /// <summary>Check is QuadFont's loading of data from file.</summary>
    /// <returns>True if data is loaded.</returns>
    /// <remarks>This will be very helpfull for multithread applications.</remarks>
    function GetIsLoaded: Boolean; stdcall;
    function GetKerning: Single; stdcall;
    /// <summary>Set kerning for this font.</summary>
    /// <param name="AValue">Value to be set. 0.0f is default</param>
    procedure SetKerning(AValue: Single); stdcall;
    function GetSpacing: Single; stdcall;
    procedure SetSpacing(AValue: Single); stdcall;
    /// <summary>Load font data from file.</summary>
    /// <param name="ATextureFilename">Filename of texture file.</param>
    /// <param name="AUVFilename">Filename of additional font data file.</param>
    procedure LoadFromFile(ATextureFilename, AUVFilename : PWideChar); stdcall;
    procedure LoadFromStream(AStream: Pointer; AStreamSize: Integer; ATexture: IQuadTexture); stdcall;
    procedure SetSmartColor(AColorChar: WideChar; AColor: Cardinal); stdcall;
    procedure SetDistanceFieldParams(const ADistanceFieldParams: TDistanceFieldParams); stdcall;
    procedure SetIsSmartColoring(Value: Boolean); stdcall;
    /// <summary>Get current font height.</summary>
    /// <param name="AText">Text to be measured.</param>
    /// <param name="AScale">Scale of the measured text.</param>
    /// <returns>Height in texels.</returns>
    function TextHeight(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    /// <summary>Get current font width.</summary>
    /// <param name="AText">Text to be measured.</param>
    /// <param name="AScale">Scale of the measured text.</param>
    /// <returns>Width in texels.</returns>
    function TextWidth(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    /// <summary>Draw text.</summary>
    /// <param name="Position">Position of text to be drawn.</param>
    /// <param name="AScale">Scale of rendered text. Default is 1.0</param>
    /// <param name="AText">Text to be drawn. #13 char is allowed.</param>
    /// <param name="Color">Color of text to be drawn.</param>
    /// <param name="AAlign">Text alignment.</param>
    /// <remarks>Note that distancefield fonts will render with Y as baseline of the font instead top pixel in common fonts.</remarks>
    procedure TextOut(const Position: TVec2f; AScale: Single; AText: PWideChar; AColor: Cardinal = $FFFFFFFF;
      AAlign : TqfAlign = qfaLeft); stdcall;
  end;

  {Quad Log}

  ///<summary>This interface will help to write any debug information to .log file.</summary>
  IQuadLog = interface(IUnknown)
    ['{7A4CE319-C7AF-4BF3-9218-C2A744F915E6}']
    procedure Write(aString: PWideChar); stdcall;
  end;

  {Quad Timer}

  /// <summary>QuadTimer uses it's own thread. Be care of using multiple timers at once.
  /// If do you must use synchronization methods or critical sections.</summary>
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

  TMouseButtons = (mbLeft = 0,
                   mbRight = 1,
                   mbMiddle = 2,
                   mbX1 = 3,
                   mbX2 = 4);

  TPressedMouseButtons = packed record
    case Integer of
      0: (Left, Right, Middle, X1, X2: Boolean);
      1: (a: array[TMouseButtons] of Boolean);
  end;

  TKeyButtons = (kbNone = 0,
                 kbShift = 1,
                 kbLShift = 2,
                 kbRShift = 3,
                 kbCtrl = 4,
                 kbLCtrl = 5,
                 kbRCtrl = 6,
                 kbAlt = 7,
                 kbLAlt = 8,
                 kbRAlt = 9);

  TPressedKeyButtons = packed record
    case Integer of
      0: (None, Shift, LShift, RShift, Ctrl, LCtrl, RCtrl, Alt, LAlt, RAlt: Boolean);
      1: (a: array[TKeyButtons] of Boolean);
  end;

  TOnKeyPress = procedure(const AKey: Word; const APressedButtons: TPressedKeyButtons); stdcall;
  TOnKeyChar = procedure(const ACharCode: LongInt; const APressedButtons: TPressedKeyButtons); stdcall;
  TOnMouseMoveEvent = procedure(const APosition: TVec2i; const APressedButtons: TPressedMouseButtons); stdcall;
  TOnMouseEvent = procedure(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
  TOnMouseWheelEvent = procedure(const APosition: TVec2i; const AVector: TVec2i; const APressedButtons: TPressedMouseButtons); stdcall;
  TOnEvent = procedure; stdcall;
  TOnWindowMove = procedure(const Xpos, Ypos: Integer); stdcall;

  {Quad Input}

  IQuadInput = interface(IUnknown)
  ['{AA8C8463-89EC-4A2B-BF84-47C3DCA6CB98}']
    function IsKeyDown(AKey: Byte): Boolean; stdcall;
    function IsKeyPress(AKey: Byte): Boolean; stdcall;
    function IsMouseDown(const AButton: TMouseButtons): Boolean; stdcall;
    function IsMouseClick(const AButton: TMouseButtons): Boolean; stdcall;
    procedure GetMousePosition(out AMousePosition: TVec2f); stdcall;
    procedure GetMouseVector(out AMouseVector: TVec2f); stdcall;
    procedure GetMouseWheel(out AMouseWheel: TVec2f); stdcall;
    procedure Update; stdcall;
  end;

  {Quad Window}

  IQuadWindow = interface(IUnknown)
  ['{8EB98692-67B1-4E64-9090-B6A0F47054BA}']
    function CreateInput(out pQuadInput: IQuadInput): HResult; stdcall;
    procedure Start; stdcall;
    procedure SetCaption(ACaption: PChar); stdcall;
    procedure SetSize(AWidth, AHeight: Integer); stdcall;
    procedure SetPosition(AXpos, AYPos: Integer); stdcall;
    function GetHandle: THandle; stdcall;

    procedure SetOnKeyDown(OnKeyDown: TOnKeyPress); stdcall;
    procedure SetOnKeyUp(OnKeyUp: TOnKeyPress); stdcall;
    procedure SetOnKeyChar(OnKeyChar: TOnKeyChar); stdcall;
    procedure SetOnCreate(OnCreate: TOnEvent); stdcall;
    procedure SetOnClose(OnClose: TOnEvent); stdcall;
    procedure SetOnActivate(OnActivate: TOnEvent); stdcall;
    procedure SetOnDeactivate(OnDeactivate: TOnEvent); stdcall;
    procedure SetOnMouseMove(OnMouseMove: TOnMouseMoveEvent); stdcall;
    procedure SetOnMouseDown(OnMouseDown: TOnMouseEvent); stdcall;
    procedure SetOnMouseUp(OnMouseUp: TOnMouseEvent); stdcall;
    procedure SetOnMouseDblClick(OnMouseDblClick: TOnMouseEvent); stdcall;
    procedure SetOnMouseWheel(OnMouseWheel: TOnMouseWheelEvent); stdcall;
    procedure SetOnWindowMove(OnWindowMove: TOnWindowMove); stdcall;
    procedure SetOnDeviceRestored(OnDeviceRestored: TOnEvent); stdcall;
  end;

  {Quad Camera}

  IQuadCamera = interface(IUnknown)
  ['{BBC0BBF2-7602-489A-BE2A-37D681B7A242}']
    procedure SetScale(AScale: Single); stdcall;
    procedure Rotate(AAngle: Single); stdcall;
    procedure Translate(const ADistance: TVec2f); stdcall;
    procedure Reset; stdcall;
    procedure Enable; stdcall;
    procedure Disable; stdcall;
    procedure GetPosition(out APosition: TVec2f); stdcall;
    function GetAngle: Single; stdcall;
    procedure GetMatrix(out AMatrix: TMatrix4x4); stdcall;
    function GetScale: Single; stdcall;
    procedure SetAngle(AAngle: Single); stdcall;
    procedure SetPosition(const APosition: TVec2f); stdcall;
    procedure Project(const AVec: TVec2f; out AProjectedVec: TVec2f);  stdcall;
  end;

  {Quad GBuffer}
  IQuadGBuffer = interface(IUnknown)
  ['{FD99AF6B-1A7A-4981-8A1D-F70D427EA2E9}']
    procedure GetDiffuseMap(out ADiffuseMap: IQuadTexture); stdcall;
    procedure GetNormalMap(out ANormalMap: IQuadTexture); stdcall;
    procedure GetSpecularMap(out ASpecularMap: IQuadTexture); stdcall;
    procedure GetHeightMap(out AHeightMap: IQuadTexture); stdcall;
    procedure GetBuffer(out ABuffer: IQuadTexture); stdcall;
    /// <summary>Draw light using GBuffer data</summary>
    /// <param name="APos">Position in world space</param>
    /// <param name="AHeight">Height of light. Lower is closer to plain.</param>
    /// <param name="ARadius">Radius of light</param>
    /// <param name="AColor">Light Color</param>
    /// <remarks>DrawLight must be used without using camera. GBuffer stores camera used to create it.</remarks>
    procedure DrawLight(const APos: TVec2f; AHeight: Single; ARadius: Single; AColor: Cardinal); stdcall;
  end;

  { Quad Profiler }

  TQuadProfilerMessageType = (
    pmtMessage = 0,
    pmtWarning = 1,
    pmtError = 2
  );

  IQuadProfilerTag = interface(IUnknown)
  ['{0CBAA03E-B54B-4351-B9EF-EEC46D99FCFB}']
    procedure BeginCount; stdcall;
    procedure EndCount; stdcall;
    function GetName: PWideChar; stdcall;
    procedure SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage); stdcall;
  end;

  IQuadProfiler = interface(IUnknown)
  ['{06063E8F-A230-4920-BC28-A672F1B31529}']
    function CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult; stdcall;
    procedure BeginTick; stdcall;
    procedure EndTick; stdcall;
    procedure SetAddress(AAddress: PAnsiChar; APort: Word = 17788); stdcall;
    procedure SetGUID(const AGUID: TGUID); stdcall;
    procedure SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage); stdcall;
  end;

  TCreateQuadDevice    = function(out QuadDevice: IQuadDevice): HResult; stdcall;
  TSecretMagicFunction = function: PWideChar;
  TCheckLibraryVersion = function(ARelease, AMajor, AMinor: Byte): Boolean; stdcall;

  function CreateQuadDevice: IQuadDevice;

implementation

// Creating of main Quad interface object
function CreateQuadDevice: IQuadDevice;
var
  h: THandle;
  Creator: TCreateQuadDevice;
  CheckLibrary: TCheckLibraryVersion;
begin
  h := LoadLibrary(LibraryName);
  if h <> 0 then
  begin
    CheckLibrary := TCheckLibraryVersion(GetProcAddress(h, 'IsSameVersion'));
    if CheckLibrary(QuadEngineReleaseVersion, QuadEngineMajorVersion, QuadEngineMinorVersion) then
    begin
      Creator := TCreateQuadDevice(GetProcAddress(h, CreateQuadDeviceProcName));
      if Assigned(Creator) then
        Creator(Result);
    end;
  end;
end;

{ TVertex }

{$IFNDEF FPC}
{$IF CompilerVersion > 17}
class operator TVertex.Implicit(const A: TVec2f): TVertex;
begin
  Result.x := A.X;
  Result.y := A.Y;
  Result.z := 0.0;
end;
{$IFEND}
{$ENDIF}

end.
