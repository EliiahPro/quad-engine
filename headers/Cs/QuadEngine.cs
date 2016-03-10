/*==============================================================================

  Quad engine 0.8.0 Diamond header file for Visual C#

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

==============================================================================*/

using System;
using System.Runtime.InteropServices;



namespace QuadEngine
{
    // Blending mode types
    ///<summary>Blending mode types.</summary>     
    public enum TQuadBlendMode{qbmInvalid = 0,
                               ///<summary>Without blending</summary>
                               qbmNone = 1,
                               ///<summary>Add source to destination</summary>
                               qbmAdd = 2,
                               ///<summary>Blend destination with alpha to source</summary>
                               qbmSrcAlpha = 3,
                               ///<summary>Add source with alpha to destination</summary>
                               qbmSrcAlphaAdd = 4,
                               ///<summary>Multiply source alpha with destination</summary>
                               qbmSrcAlphaMul = 5,
                               ///<summary>Multiply Source with destination</summary>
                               qbmMul = 6,
                               ///<summary>Blend source with color weight to destination</summary>
                               qbmSrcColor = 7,
                               ///<summary>Blend source with color weight and alpha to destination</summary>
                               qbmSrcColorAdd = 8,
                               ///<summary>Blend inverted source color</summary>
                               qbmInvertSrcColor = 9};

    ///<summary>Texture adressing mode</summary>
    public enum TQuadTextureAdressing{qtaInvalid    = 0,
                                      ///<summary>Repeat UV</summary>
                                      qtaWrap       = 1,
                                      ///<summary>Repeat UV with mirroring</summary>
                                      qtaMirror     = 2,
                                      ///<summary>Do not repeat UV</summary>
                                      qtaClamp      = 3,
                                      ///<summary>Fill outranged UV with border</summary>
                                      qtaBorder     = 4,    
                                      ///<summary>Mirror UV once</summary>
                                      qtaMirrorOnce = 5};   

    // Texture filtering mode
    public enum TQuadTextureFiltering{qtfInvalid         = 0,
                                      qtfNone            = 1,    /* Filtering disabled (valid for mip filter only) */
                                      qtfPoint           = 2,    /* Nearest */
                                      qtfLinear          = 3,    /* Linear interpolation */
                                      qtfAnisotropic     = 4,    /* Anisotropic */
                                      qtfPyramidalQuad   = 5,    /* 4-sample tent */
                                      qtfGaussianQuad    = 6,    /* 4-sample gaussian */
                                      qtfConvolutionMono = 7};   /* Convolution filter for monochrome textures */

  // Texture Mirroring mode
    public enum TQuadTextureMirroring{qtmInvalid    = 0,
                                      qtmNone       = 1,   /* No mirroring */
                                      qtmHorizontal = 2,   /* Horizontal mirroring */
                                      qtmVertical   = 3,   /* Vertical mirroring */
                                      qtmBoth       = 4};  /* Horizontal and vertical mirroring */

    // Vector record declaration
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TVector{
        public float x;
        public float y;
        public float z;
    }

     // vertex record declaration
     [StructLayout(LayoutKind.Sequential, Pack = 1)]
     public struct TVertex{
        public float x; public float y; public float z;  /* X, Y of vertex. Z not used */
        public TVector Normal;             /* Normal vector */
        public UInt32 color;               /* Color */
        public float u; float v;           /* Texture UV coord */
        public TVector tangent;            /* Tangent vector */
        public TVector binormal;           /* Binormal vector */
    }

    public struct TCoord {
        public ushort X;
        public ushort Y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TRect {
        public int Left;
        public int Top;
        public int Right;
        public int Bootom;
    }

    public struct TMatrix4x4 {
        public float _11; public float _12; public float _13; public float _14;
        public float _21; public float _22; public float _23; public float _24;
        public float _31; public float _32; public float _33; public float _34;
        public float _41; public float _42; public float _43; public float _44;
    }

    /* Quad Device */

    [ComImport]
    [Guid("E28626FF-738F-43B0-924C-1AFC7DEC26C7")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    ///<summary>This is main quad-engine interface. Use it methods to create resources, change states and draw primitives.</summary>
    public interface IQuadDevice
    {
        /// <summary>Load font data from file and return a QuadFont object.</summary>
        /// <param name="ATextureFilename">Filename of texture file.</param>
        /// <param name="AUVFilename">Filename of additional font data file.</param>
        /// <param name="pQuadFont">IQuadFont variable to recieve object.</param>
        uint CreateAndLoadFont(string AFontTextureFilename, string AUVFilename, out IQuadFont IQuadFont);
        uint CreateAndLoadTexture(byte ARegister, string AFilename, out IQuadTexture IQuadTexture,
                                  int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        /// <summary>Return a QuadCamera object.</summary>
        /// <param name="pQuadCamera">IQuadCamera variable to recieve object.</param>
        uint CreateCamera(out IQuadCamera IQuadCamera);
        /// <summary>Return a QuadFont object.</summary>
        /// <param name="IQuadFont">IQuadFont variable to recieve object.</param>
        uint CreateFont(out IQuadFont IQuadFont);
        /// <summary>Return a QuadGBuffer object.</summary>
        /// <param name="pQuadGBuffer">IQuadGBuffer variable to recieve object.</param>
        uint CreateGBuffer(out IQuadGBuffer IQuadGBuffer);
        /// <summary>Return a QuadLog object.</summary>
        /// <param name="IQuadLog">IQuadLog variable to recieve object.</param>
        uint CreateLog(out IQuadLog IQuadLog);
        /// <summary>Return a QuadShader object.</summary>
        /// <param name="IQuadShader">IQuadShader variable to recieve object.</param>
        uint CreateShader(out IQuadShader IQuadShader);
        /// <summary>Return a QuadTexture object.</summary>
        /// <param name="IQuadTexure">IQuadTexture variable to recieve object.</param>
        uint CreateTexture(out IQuadTexture IQuadTexture);
        /// <summary>Return a QuadTimer object.</summary>
        /// <param name="IQuadTimer">IQuadTimer variable to recieve object.</param>
        uint CreateTimer(out IQuadTimer IQuadTimer);
        /// <summary>Return a QuadTimer object with full initialization.</summary>
        /// <param name="pQuadTimer">IQuadTimer variable to recieve object.</param>
        /// <param name="AProc">Callback to onTimer procedure. <see cref="TTimerProcedure"/>
        ///   <code>private void OnTimer(ref double delta, UInt32 Id)</code>
        /// </param>
        /// <param name="AInterval">Timer interval in ms.</param>
        /// <param name="IsEnabled">False if need to create in suspended state.</param>
        uint CreateTimerEx(out IQuadTimer IQuadTimer, IntPtr AProc, ushort AInterval, bool IsEnabled);
        /// <summary>Return a QuadRender object.</summary>
        /// <param name="IQuadDevice">IQuadRender variable to recieve object.</param>
        uint CreateRender(out IQuadRender IQuadDevice);
        /// <summary>Creates a rendertarget within specified <see cref="QuadEngine.IQuadTexture"/>.</summary>
        /// <param name="AWidth">Width of rendertarget.</param>
        /// <param name="AHeight">Height of rendertarget.</param>
        /// <param name="IQuadTexture">Pointer to declared <see cref="QuadEngine.IQuadTexture"/>. If it not created this function will create one. Otherwise it will use existing one.</param>
        /// <param name="ARegister">Texture's register in which rendertarget must be assigned.</param>
        void CreateRenderTarget(UInt16 AWidth, UInt16 AHeight, ref IQuadTexture IQuadTexture, byte ARegister);
        uint CreateWindow(out IQuadWindow IQuadWindow);
        uint CreateProfiler(string AName, out IQuadProfiler quadProfiler);
        [PreserveSig] bool GetIsResolutionSupported(UInt16 AWidth, UInt16 AHeight);
        [PreserveSig] string GetLastError();
        [PreserveSig] byte GetMonitorsCount();
        void GetSupportedScreenResolution(int index, out TCoord Resolution); 
        void SetActiveMonitor(byte AMonitorIndex);
        void SetOnErrorCallBack(IntPtr TOnErrorFunction);   // todo: Delegate
        void ShowCursor(bool Show);
        void SetCursorPosition(int x, int y); 
        /// <summary>The dimensions Image must be a power of two in each direction, although not necessarily the same power of two. The alpha channel must be either 0.0 or 1.0. </summary>        
        void SetCursorProperties(UInt32 XHotSpot, UInt32 YHotSpot, IQuadTexture Image);
    }
 
    /* Quad Render */

    // Shader model
    public enum TQuadShaderModel{qsmInvalid = 0,
                                 qsmNone    = 1,   // do not use shaders
                                 qsm20      = 2,   // shader model 2.0
                                 qsm30      = 3};  // shader model 3.0

    // Initialization record
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TRenderInit {
        public UInt32 Handle;
        public int Width;
        public int Height;
        public int BackBufferCount;
        public int RefreshRate;
        public bool Fullscreen;
        public bool SoftwareVertexProcessing;
        public bool MultiThreaded;
        public bool VerticalSync;
        public TQuadShaderModel ShaderModel;
    }

    [ComImport]
    [Guid("D9E9C42B-E737-4CF9-A92F-F0AE483BA39B")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    /// <summary>Main Quad-engine interface used for drawing. This object is singleton and cannot be created more than once.</summary>
    public interface IQuadRender
    {
        /// <summary>Retrieves the available texture memory.
        /// This will return all available texture memory including AGP aperture.</summary>
        /// <returns>Available memory size in bytes</returns>
        [PreserveSig] void GetClipRect(out TRect rect);
        [PreserveSig] UInt32 GetAvailableTextureMemory();
        [PreserveSig] UInt32 GetMaxAnisotropy();
        [PreserveSig] UInt32 GetMaxTextureHeight();
        [PreserveSig] UInt32 GetMaxTextureStages();
        [PreserveSig] UInt32 GetMaxTextureWidth();
        [PreserveSig] string GetPixelShaderVersionString();
        [PreserveSig] Byte GetPSVersionMajor();
        [PreserveSig] Byte GetPSVersionMinor();
        [PreserveSig] string GetVertexShaderVersionString();
        [PreserveSig] Byte GetVSVersionMajor();
        [PreserveSig] Byte GetVSVersionMinor();
        [PreserveSig] string GetRenderDeviceName();
        void AddTrianglesToBuffer(IntPtr AVertexes, UInt32 ACount); // todo: Vertices
        /// <summary>Begin of render. Call this routine before frame render begins.</summary>
        void BeginRender();
        /// <summary>Change virtual or real resolution of the render.</summary>
        /// <param name="AWidth">New render width</param>
        /// <param name="AHeight">New render height</param>
        /// <param name="isVirtual">Virtual or real physical resolution</param>
        /// <remarks>Method must be called only from main thread if isVirtual param it set to False.</remarks>        
        void ChangeResolution(UInt16 AWidth, UInt16 AHeight, bool isVirtual = true);
        void Clear(UInt32 AColor);
        void DrawCircle(ref Vec2f Center, float Radius, float InnerRadius, UInt32 Color = 0xFFFFFFFF); 
        void DrawLine(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color);
        void DrawPoint(ref Vec2f Point, UInt32 Color);
        void DrawQuadLine(ref Vec2f PointA, ref Vec2f PointB, float Width1, float Width2, uint Color1, uint Color2);
        /// <summary>End of render. Call this routine at the end of frame render.</summary>
        void EndRender();
        void Finalize();
        void FlushBuffer();
        void Initialize(IntPtr AHandle, int AWidth, int AHeight, bool AIsFullscreen, TQuadShaderModel AShaderModel = TQuadShaderModel.qsm20);
        void InitializeEx(ref TRenderInit ARenderInit);
        void InitializeFromIni(IntPtr AHandle, string AFilename);
        void Polygon(ref Vec2f PointA, ref Vec2f PointB, ref Vec2f PointC, ref Vec2f PointD, UInt32 Color);
        void Rectangle(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color);
        void RectangleEx(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color1, UInt32 Color2, UInt32 Color3, UInt32 Color4);
        void RenderToGBuffer(bool AIsRenderToGBuffer, IQuadGBuffer AQuadGBuffer = null, bool AIsCropScreen = false);
        /// <summary>Enables render to texture. You can use multiple render targets within one render call.</summary>
        /// <param name="AIsRenderToTexture">Enable render to texture.</param>
        /// <param name="AQuadTexture">IQuadTexture. Instance must be created with IQuadDevice.CreateRenderTexture only.</param>
        /// <param name="ATextureRegister">Register of IQuadTexture to be used for rendering.</param>
        /// <param name="ARenderTargetRegister">When using multiple rendertargets this parameter tells what register this rendertarget will be in output.</param>
        /// <param name="AIsCropScreen">Scale or crop scene to match rendertarget's resolution</param>
        void RenderToTexture(bool AIsRenderToTexture, IQuadTexture AQuadTexture = null,
          byte ATextureRegister = 0, byte ARenderTargetRegister = 0, bool AIsCropScreen = false);
        void SetAutoCalculateTBN(bool Value);
        void SetBlendMode(TQuadBlendMode TQuadBlendMode);
        void SetClipRect(UInt32 X, UInt32 Y, UInt32 X2, UInt32 Y2);
        void SetTexture(byte ARegister, ref IntPtr ATexture);
        void SetTextureAdressing(TQuadTextureAdressing ATextureAdressing);
        void SetTextureFiltering(TQuadTextureFiltering ATextureAdressing);
        void SetTextureMirroring(TQuadTextureMirroring ATextureMirroring);
        void SetPointSize(UInt32 ASize);
        void SkipClipRect();
        /// <summary>Take and save to disk .png screenshot</summary>
        /// <param name="AFileName">Name and path of saved screenshot</param>
        void TakeScreenshot(string AFileName);
        void ResetDevice();
        [PreserveSig] IntPtr GetD3DDevice();
    }
 
    /* Quad Texture */

    // RAW data format
    public enum TRAWDataFormat{rdfInvalid   = 0,
                               rdfARGB8     = 1,
                               rdfRGBA8     = 2,
                               rdfABGR8     = 3};
 
    [ComImport]
    [Guid("9A617F86-2CEC-4701-BF33-7F4989031BBA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadTexture
    {
        [PreserveSig] bool GetIsLoaded();
        [PreserveSig] int GetPatternCount();
        [PreserveSig] UInt16 GetPatternHeight();
        [PreserveSig] UInt16 GetPatternWidth();
        [PreserveSig] UInt32 GetPixelColor(int x, int y, byte ARegister = 0);
        [PreserveSig] UInt16 GetSpriteHeight();
        [PreserveSig] UInt16 GetSpriteWidth();
        [PreserveSig] IntPtr GetTexture(byte i);
        [PreserveSig] UInt16 GetTextureHeight();
        [PreserveSig] UInt16 GetTextureWidth();
        void AddTexture(byte ARegister, IntPtr ATexture);  // ATexture: IDirect3DTexture9
        void AssignTexture(IQuadTexture AQuadTexture, byte ASourceRegister, byte ATargetRegister);
        void Draw(ref Vec2f position, UInt32 Color = 0xFFFFFFFF);
        void DrawFrame(ref Vec2f position, UInt16 pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawMap(ref Vec2f pointA, ref Vec2f pointB, ref Vec2f UVA, ref Vec2f UVB, UInt32 Color = 0xFFFFFFFF);
        void DrawMapRotAxis(ref Vec2f pointA, ref Vec2f pointB, ref Vec2f UVA, ref Vec2f UVB, ref Vec2f Axis, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawPart(ref Vec2f position, Vec2i LeftTop, Vec2i RightBottom, UInt32 Color = 0xFFFFFFFF);
        void DrawPartRot(ref Vec2f Center, double angle, double Scale, Vec2i LeftTop, Vec2i RightBottom, UInt32 Color = 0xFFFFFFFF);
        void DrawPartRotAxis(ref Vec2f position, double angle, double Scale, ref Vec2f Axis, Vec2i LeftTop, Vec2i RightBottom, UInt32 Color = 0xFFFFFFFF);
        void DrawRot(ref Vec2f Center, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawRotFrame(ref Vec2f Center, double angle, double Scale, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxis(ref Vec2f position, double angle, double Scale, ref Vec2f Axis, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxisFrame(ref Vec2f position, double angle, double Scale, ref Vec2f Axis, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void LoadFromFile(byte ARegister, string AFilename, int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        void LoadFromStream(byte ARegister, IntPtr AStream, int AStreamSize, int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        void LoadFromRAW(byte ARegister, IntPtr AData, int AWidth, int AHeight, TRAWDataFormat ASourceFormat = TRAWDataFormat.rdfARGB8);
        void SetIsLoaded(UInt16 AWidth, UInt16 AHeight);
    }

    /* Quad Shader */

    [ComImport]
    [Guid("7B7F4B1C-7F05-4BC2-8C11-A99696946073")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    /// <summary>This is quad-engine shader interface.
    /// Use it methods to load shader into GPU, bind variables to shader, execute shader programs.</summary>
    public interface IQuadShader
    {
        void BindVariableToVS(byte ARegister, UIntPtr AVariable, byte ASize);
        void BindVariableToPS(byte ARegister, UIntPtr AVariable, byte ASize);
        [PreserveSig] IntPtr GetVertexShader(out IntPtr Shader); // Shader: IDirect3DVertexShader9
        [PreserveSig] IntPtr GetPixelShader(out IntPtr Shader); // Shader: IDirect3DPixelShader9
        void LoadVertexShader(string AVertexShaderFilename);
        void LoadPixelShader(string APixelShaderFilename);
        void LoadComplexShader(string AVertexShaderFilename, string APixelShaderFilename);
        void SetShaderState(bool AIsEnabled);
    }


    /* Quad Font */

    /* Predefined colors for SmartColoring:
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
    ** Do not override "!" char **  */

    // font alignments
    public enum TqfAlign {qfaInvalid = 0,
                          qfaLeft    = 1,      /* Align by left */
                          qfaRight   = 2,      /* Align by right */
                          qfaCenter  = 3,      /* Align by center */
                          qfaJustify = 4};     /* Align by both sides */

    // distance field options
    [StructLayout(LayoutKind.Explicit)]
    public struct TDistanceFieldParams {
        [FieldOffset(0)] public float Edge1X;
        [FieldOffset(4)] public float Edge1Y;
        [FieldOffset(8)] public float Edge2X;
        [FieldOffset(12)] public float Edge2Y;
        [FieldOffset(16)] public UInt32 OuterColor;
        [FieldOffset(20)] public Boolean FirstEdge;
        [FieldOffset(21)] public Boolean SecondEdge;
    }

    [ComImport]
    [Guid("A47417BA-27C2-4DE0-97A9-CAE546FABFBA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadFont
    {
        /// <summary>Check is QuadFont's loading of data from file.</summary>
        /// <returns>True if data is loaded.</returns>
        /// <remarks>This will be very helpfull for multithread applications.</remarks>
        [PreserveSig] bool GetIsLoaded();
        [PreserveSig] float GetKerning();
        /// <summary>Set kerning for this font.</summary>
        /// <param name="value">Value to be set. 0.0f is default</param>
        void SetKerning(float value);
        [PreserveSig] float GetSpacing();
        void SetSpacing(float value);
        /// <summary>Load font data from file.</summary>
        /// <param name="textureFilename">Filename of texture file.</param>
        /// <param name="UVFilename">Filename of additional font data file.</param>
        void LoadFromFile(string textureFilename, string UVFilename);
        void LoadFromStream(IntPtr AStream, int AStreamSize, IQuadTexture ATexture);
        void SetSmartColor(string colorChar, UInt32 color);
        void SetDistanceFieldParams(ref TDistanceFieldParams distanceFieldParam);
        void SetIsSmartColoring(bool value);
        /// <summary>Get current font height.</summary>
        /// <param name="text">Text to be measured.</param>
        /// <param name="scale">Scale of the measured text.</param>
        /// <returns>Height in texels.</returns>
        [PreserveSig] float TextHeight(string text, float scale = 1.0F);
        /// <summary>Get current font width.</summary>
        /// <param name="text">Text to be measured.</param>
        /// <param name="scale">Scale of the measured text.</param>
        /// <returns>Width in texels.</returns>
        [PreserveSig] float TextWidth(string text, float scale = 1.0F);
        /// <summary>Draw text.</summary>
        /// <param name="position">Position of text to be drawn.</param>
        /// <param name="scale">Scale of rendered text. Default is 1.0</param>
        /// <param name="text">Text to be drawn. #13 char is allowed.</param>
        /// <param name="color">Color of text to be drawn.</param>
        /// <param name="align">Text alignment.</param>
        /// <remarks>Note that distancefield fonts will render with Y as baseline of the font instead top pixel in common fonts.</remarks>
        void TextOut(ref Vec2f position, float scale, string text, UInt32 color = 0xFFFFFFFF, TqfAlign align = TqfAlign.qfaLeft);
    }

    /* Quad Log */

    [ComImport]
    [Guid("7A4CE319-C7AF-4BF3-9218-C2A744F915E6")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    ///<summary>This interface will help to write any debug information to .log file.</summary>
    public interface IQuadLog
    {
        void Write(string aString);
    }

    /* Quad Timer */

    /// <summary>OnTimer Callback function prototype</summary>
    public delegate void TimerProcedure(ref double delta, UInt32 Id);

    /* Use [MTAThread] insted of [STAThread] 
      
      template:
    private void OnTimer(ref double delta, UInt32 Id)
    {

    }
      
      setting callback:
    QuadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate((TimerProcedure) OnTimer));
    */

    [ComImport]
    [Guid("EA3BD116-01BF-4E12-B504-07D5E3F3AD35")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    /// <summary>QuadTimer uses it's own thread. Be care of using multiple timers at once.
    /// If do you must use synchronization methods or critical sections.</summary>
    ///<remarks>Use [MTAThread] insted of [STAThread]</remarks>
    public interface IQuadTimer
    {
        [PreserveSig] float GetCPUload();
        [PreserveSig] double GetDelta();
        [PreserveSig] float GetFPS();
        [PreserveSig] double GetWholeTime();
        [PreserveSig] UInt32 GetTimerID();
        void ResetWholeTimeCounter();
        void SetCallBack(IntPtr proc);
        void SetInterval(UInt16 interval);
        void SetState(bool isEnabled);
    }

    /* Quad Window */

    public enum MouseButtons
    {
        Left = 0,
        Right = 1,
        Middle = 2,
        X1 = 3,
        X2 = 4
    };

    [StructLayout(LayoutKind.Sequential)]
    public struct PressedMouseButtons 
    {
        public bool Left;
        public bool Right;
        public bool Middle;
        public bool X1;
        public bool X2;
    }

    public enum KeyButtons
    {
        None = 0,
        Shift = 1,
        LShift = 2,
        RShift = 3,
        Ctrl = 4,
        LCtrl = 5,
        RCtrl = 6,
        Alt = 7,
        LAlt = 8,
        RAlt = 9        
    };

    [StructLayout(LayoutKind.Sequential)]
    public struct PressedKeyButtons
    {
        public bool None;
        public bool Shift;
        public bool LShift;
        public bool RShift;
        public bool Ctrl;
        public bool LCtrl;
        public bool RCtrl;
        public bool Alt;
        public bool LAlt;
        public bool RAlt;
    }

    public delegate void OnKeyPress(ref ushort key, ref PressedKeyButtons pressedButtons);
    public delegate void OnKeyChar(ref int ACharCode, ref PressedKeyButtons pressedButtons);
    public delegate void OnCreate();
    public delegate void OnMouseMoveEvent(ref Vec2i position, ref PressedMouseButtons pressedButtons); 
    public delegate void OnMouseEvent(ref Vec2i position, ref MouseButtons buttons, ref PressedMouseButtons pressedButtons);
    public delegate void OnMouseWheelEvent(ref Vec2i position, ref Vec2i vector, ref PressedMouseButtons pressedButtons);
    public delegate void OnEvent();
    public delegate void OnWindowMove(int xPos, int yPos);
    
    [ComImport]
    [Guid("AA8C8463-89EC-4A2B-BF84-47C3DCA6CB98")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadInput
    {
      [PreserveSig] bool IsKeyDown(byte AKey);
      [PreserveSig] bool IsKeyPress(byte AKey);      
      [PreserveSig] bool IsMouseDown(MouseButtons button);
      [PreserveSig] bool IsMouseClick(MouseButtons button);
      [PreserveSig] void GetMousePosition(out Vec2f position);
      [PreserveSig] void GetMouseVector(out Vec2f vector);
      [PreserveSig] void GetMouseWheel(out Vec2f vector);
      void Update();
    }

    /*
    function IsKeyDown(const AKey: Byte): Boolean; stdcall;
    function IsKeyPress(const AKey: Byte): Boolean; stdcall;
    function GetMousePosition: TVec2f; stdcall;
    function GetMouseVector: TVec2f; stdcall;
    function IsMouseDown(const AButton: TMouseButtons): Boolean; stdcall;
    function IsMouseClick(const AButton: TMouseButtons): Boolean; stdcall;
    function GetMouseWheel: TVec2f; stdcall;
    procedure Update; stdcall;
    */
    [ComImport]
    [Guid("8EB98692-67B1-4E64-9090-B6A0F47054BA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadWindow
    {
        /// <summary>Return a QuadInput object.</summary>
        /// <param name="QuadInput">IQuadInput variable to recieve object.</param>
        uint CreateInput(out IQuadInput IQuadInput);
        void Start(); 
        void SetCaption(string caption);
        void SetSize(int width, int height); 
        void SetPosition(int xPos, int yPos);
        [PreserveSig] UIntPtr GetHandle();

        void SetOnKeyDown(IntPtr onKeyDown); 
        void SetOnKeyUp(IntPtr onKeyUp); 
        void SetOnKeyChar(IntPtr onKeyChar); 
        void SetOnCreate(IntPtr onCreate); 
        void SetOnClose(IntPtr onClose);
        void SetOnActivate(IntPtr onActivate);
        void SetOnDeactivate(IntPtr onDeactivate);
        void SetOnMouseMove(IntPtr onMouseMove); 
        void SetOnMouseDown(IntPtr onMouseDown); 
        void SetOnMouseUp(IntPtr onMouseUp); 
        void SetOnMouseDblClick(IntPtr onMouseDblClick); 
        void SetOnMouseWheel(IntPtr onMouseWheel); 
        void SetOnWindowMove(IntPtr onWindowMove);
        void SetOnDeviceRestored(IntPtr onDeviceRestored);
    }

    /* Quad Camera */
 
    [ComImport]
    [Guid("BBC0BBF2-7602-489A-BE2A-37D681B7A242")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadCamera
    {
        void SetScale(float scale);
        void Rotate(float angle);
        void Translate(ref Vec2f distance);
        void Reset();
        void Enable();
        void Disable();
        void GetPosition(out Vec2f position);
        [PreserveSig] float GetAngle();
        void GetMatrix(out TMatrix4x4 matrix4x4);
        [PreserveSig] float GetScale();
        void SetAngle(float angle);
        void SetPosition(ref Vec2f position);
        void Project(ref Vec2f vec, out Vec2f projectedVec);
    }

    /* Quad GBuffer */

    [ComImport]
    [Guid("FD99AF6B-1A7A-4981-8A1D-F70D427EA2E9")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadGBuffer
    {
        void GetDiffuseMap(out IQuadTexture DiffuseMap);
        void GetNormalMap(out IQuadTexture NormalMap);
        void GetSpecularMap(out IQuadTexture SpecularMap);
        void GetHeightMap(out IQuadTexture HeightMap);
        void GetBuffer(out IQuadTexture Buffer);
        /// <summary>Draw light using GBuffer data</summary>
        /// <param name="APos">Position in world space</param>
        /// <param name="AHeight">Height of light. Lower is closer to plain.</param>
        /// <param name="ARadius">Radius of light</param>
        /// <param name="AColor">Light Color</param>
        /// <remarks>DrawLight must be used without using camera. GBuffer stores camera used to create it.</remarks>
        void DrawLight(ref Vec2f APos, float AHeight, float ARadius, UInt32 AColor);
    }

    /* Quad Profiler */

    public enum TQuadProfilerMessageType {
        pmtMessage = 0,
        pmtWarning = 1,
        pmtError = 2
    };

    [ComImport]
    [Guid("0CBAA03E-B54B-4351-B9EF-EEC46D99FCFB")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadProfilerTag {
      void BeginCount();
      void EndCount();
      string GetName();
      void SendMessage(string AMessage, TQuadProfilerMessageType AMessageType = TQuadProfilerMessageType.pmtMessage);
    }

    [ComImport]
    [Guid("06063E8F-A230-4920-BC28-A672F1B31529")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadProfiler {
      uint CreateTag(string AName, out IQuadProfilerTag ATag);
      void BeginTick();
      void EndTick();
      void SetGUID(ref Guid GUID);
      void SendMessage(string AMessage, TQuadProfilerMessageType AMessageType = TQuadProfilerMessageType.pmtMessage);
    }

    public static class QuadEngine
    {
        [DllImport("qei.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "CreateQuadDevice", CharSet = CharSet.Unicode)]
        public static extern IntPtr CreateQuadDevice(out IQuadDevice Device); //[Out, MarshalAs(UnmanagedType.Interface)]

        [DllImport("qei.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "IsSameVersion", CharSet = CharSet.Unicode)]
        public static extern bool IsSameVersion(byte ARelease, byte AMajor, byte AMinor);

        [DllImport("qei.dll", EntryPoint = "SecretMagicFunction", CharSet = CharSet.Unicode)]
        public static extern string SecretMagicFunction();
    }

}