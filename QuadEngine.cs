/*==============================================================================

  Quad engine 0.6.2 Umber header file for Visual C#

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
    public enum TQuadBlendMode{qbmInvalid        = 0,
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


    // Vector record declaration
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TVector{
        float x;
        float y;
        float z;
    }

     // vertex record declaration
     [StructLayout(LayoutKind.Sequential, Pack = 1)]
     public struct TVertex{
        float x; float y; float z;  /* X, Y of vertex. Z not used */
        TVector Normal;             /* Normal vector */
        UInt32 color;               /* Color */
        float u; float v;           /* Texture UV coord */
        TVector tangent;            /* Tangent vector */
        TVector binormal;           /* Binormal vector */
    }

    public struct TCoord {
        ushort X;
        ushort Y;
    }

    public struct TRect {
        int Left;
        int Top;
        int Right;
        int Bootom;
    }

    /* Quad Device */

    [ComImport]
    [Guid("E28626FF-738F-43B0-924C-1AFC7DEC26C7")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    ///<summary>This is main quad-engine interface. Use it methods to create resources, change states and draw primitives.</summary>
    public interface IQuadDevice
    {
        uint CreateAndLoadFont(string AFontTextureFilename, string AUVFilename, out IQuadFont IQuadFont);
        uint CreateAndLoadTexture(byte ARegister, string AFilename, out IQuadTexture IQuadTexture,
                                  int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        uint CreateCamera(out IQuadCamera IQuadCamera);
        /// <summary>Return a QuadFont object.</summary>
        /// <param name="IQuadFont">IQuadFont variable to recieve object.</param>
        uint CreateFont(out IQuadFont IQuadFont);
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
        [PreserveSig]
        bool GetIsResolutionSupported(UInt16 AWidth, UInt16 AHeight);
        [PreserveSig] 
        string GetLastError();
        [PreserveSig]
        byte GetMonitorsCount();
        void GetSupportedScreenResolution(int index, out TCoord Resolution); 
        void SetActiveMonitor(byte AMonitorIndex);
        void SetOnErrorCallBack(IntPtr TOnErrorFunction);   // todo: Delegate
        void ShowCursor(bool Show);
        void SetCursorPosition(int x, int y); 
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
        UInt32 Handle;
        int Width;
        int Height;
        int BackBufferCount;
        int RefreshRate;
        bool Fullscreen;
        bool SoftwareVertexProcessing;
        bool MultiThreaded;
        bool VerticalSync;
        TQuadShaderModel ShaderModel;
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
        [preserveSig] TRect GetClipRect();
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
        void AddTrianglesToBuffer(IntPtr AVertexes, UInt32 ACount); // todo: Vertices
        void BeginRender();
        void ChangeResolution(UInt16 AWidth, UInt16 AHeight);
        void Clear(UInt32 AColor);
        void CreateOrthoMatrix();
        void DrawLine(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color);
        void DrawPoint(ref Vec2f Point, UInt32 Color);
        void DrawQuadLine(ref Vec2f PointA, ref Vec2f PointB, float Width1, float Width2, uint Color1, uint Color2);
        void EndRender();
        void Finalize();
        void FlushBuffer();
        void Initialize(IntPtr AHandle, int AWidth, int AHeight, bool AIsFullscreen, TQuadShaderModel AShaderModel = TQuadShaderModel.qsm20);
        void InitializeEx(ref TRenderInit ARenderInit);
        void InitializeFromIni(IntPtr AHandle, string AFilename);
        void Polygon(ref Vec2f PointA, ref Vec2f PointB, ref Vec2f PointC, ref Vec2f PointD, UInt32 Color);
        void Rectangle(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color);
        void RectangleEx(ref Vec2f PointA, ref Vec2f PointB, UInt32 Color1, UInt32 Color2, UInt32 Color3, UInt32 Color4);
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
        void SetTexture(byte ARegister, IntPtr ATexture);
        void SetTextureAdressing(TQuadTextureAdressing ATextureAdressing);
        void SetTextureFiltering(TQuadTextureFiltering ATextureAdressing);
        void SetPointSize(UInt32 ASize);
        void SkipClipRect();
        void TakeScreenshot(string AFileName);
        void ResetDevice();
        [PreserveSig]
        IntPtr GetD3DDevice();
    }
 
    /* Quad Texture */
 
    [ComImport]
    [Guid("9A617F86-2CEC-4701-BF33-7F4989031BBA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadTexture
    {
        [PreserveSig] 
        bool GetIsLoaded();
        [PreserveSig] 
        int GetPatternCount();
        [PreserveSig] 
        UInt16 GetPatternHeight();
        [PreserveSig] 
        UInt16 GetPatternWidth();
        [PreserveSig]
        UInt32 GetPixelColor(int x, int y, byte ARegister = 0);
        [PreserveSig]
        UInt16 GetSpriteHeight();
        [PreserveSig] 
        UInt16 GetSpriteWidth();
        [PreserveSig]
        IntPtr GetTexture(byte i);
        [PreserveSig]
        UInt16 GetTextureHeight();
        [PreserveSig]
        UInt16 GetTextureWidth();
        void AddTexture(byte ARegister, IntPtr ATexture);  // ATexture: IDirect3DTexture9
        void Draw(ref Vec2f Position, UInt32 Color = 0xFFFFFFFF);
        void DrawFrame(ref Vec2f Position, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, UInt32 Color = 0xFFFFFFFF);
        void DrawMap(ref Vec2f PointA, ref Vec2f PointB, ref Vec2f UVA, ref Vec2f UVB, UInt32 Color = 0xFFFFFFFF);
        void DrawMapRotAxis(ref Vec2f PointA, ref Vec2f PointB, ref Vec2f UVA, ref Vec2f UVB, ref Vec2f Axis, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawRot(ref Vec2f Center, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawRotFrame(ref Vec2f Center, double angle, double Scale, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxis(ref Vec2f Position, double angle, double Scale, ref Vec2f Axis, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxisFrame(ref Vec2f Position, double angle, double Scale, ref Vec2f Axis, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void LoadFromFile(byte ARegister, string AFilename, int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        void LoadFromRAW(byte ARegister, IntPtr AData, int AWidth, int AHeight);
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
        [PreserveSig]
        IntPtr GetVertexShader(out IntPtr Shader); // Shader: IDirect3DVertexShader9
        [PreserveSig]
        IntPtr GetPixelShader(out IntPtr Shader); // Shader: IDirect3DPixelShader9
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
        /// <summary>Load font data from file.</summary>
        /// <param name="ATextureFilename">Filename of texture file.</param>
        /// <param name="AUVFilename">Filename of additional font data file.</param>
        void LoadFromFile(string ATextureFilename, string AUVFilename);
        void SetSmartColor(string AColorChar, UInt32 AColor);
        void SetDistanceFieldParams(ref TDistanceFieldParams ADistanceFieldParam);
        void SetIsSmartColoring(bool Value);
        /// <summary>Set kerning for this font.</summary>
        /// <param name="AValue">Value to be set. 0.0f is default</param>
        void SetKerning(float AValue);
        /// <summary>Get current font height.</summary>
        /// <param name="AText">Text to be measured.</param>
        /// <param name="AScale">Scale of the measured text.</param>
        /// <returns>Height in texels.</returns>
        [PreserveSig] float TextHeight(string AText, float AScale = 1.0F);
        /// <summary>Get current font width.</summary>
        /// <param name="AText">Text to be measured.</param>
        /// <param name="AScale">Scale of the measured text.</param>
        /// <returns>Width in texels.</returns>
        [PreserveSig] float TextWidth(string AText, float AScale = 1.0F);
        /// <summary>Draw text.</summary>
        /// <param name="Position">Position of text to be drawn.</param>
        /// <param name="AScale">Scale of rendered text. Default is 1.0</param>
        /// <param name="AText">Text to be drawn. #13 char is allowed.</param>
        /// <param name="Color">Color of text to be drawn.</param>
        /// <param name="AAlign">Text alignment.</param>
        /// <remarks>Note that distancefield fonts will render with Y as baseline of the font instead top pixel in common fonts.</remarks>
        void TextOut(ref Vec2f Position, float AScale, string AText, UInt32 AColor = 0xFFFFFFFF, TqfAlign AAlign = TqfAlign.qfaLeft);
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
        void SetCallBack(IntPtr AProc);
        void SetInterval(UInt16 AInterval);
        void SetState(bool AIsEnabled);
    }

    /* Quad Window */

    public enum TMouseButtons
    {
        mbLeft = 0,
        mbRight = 1,
        mbMiddle = 2,
        mbX1 = 3,
        mbX2 = 4
    };

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TPressedMouseButtons 
    {
        Boolean Left;
        Boolean Right; 
        Boolean Middle;
        Boolean X1;
        Boolean X2;
    }

    public enum TKeyButtons
    {
        kbNone = 0,
        kbShift = 1,
        kbLShift = 2,
        kbRShift = 3,
        kbCtrl = 4,
        kbLCtrl = 5,
        kbRCtrl = 6,
        kbAlt = 7,
        kbLAlt = 8,
        kbRAlt = 9        
    };
    
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TPressedKeyButtons
    {
        Boolean None;
        Boolean Shift;
        Boolean LShift;
        Boolean RShift;
        Boolean Ctrl;
        Boolean LCtrl;
        Boolean RCtrl;
        Boolean Alt;
        Boolean LAlt;
        Boolean RAlt;
    }

    public delegate void TOnKeyPress(ushort Key, TPressedKeyButtons APressedButtons);
    public delegate void TOnKeyChar(int ACharCode, TPressedKeyButtons APressedButtons);
    public delegate void TOnCreate();
    public delegate void TOnMouseMoveEvent(Vec2i APosition, TPressedMouseButtons APressedButtons); 
    public delegate void TOnMouseEvent(Vec2i APosition, TMouseButtons AButtons, TPressedMouseButtons APressedButtons);
    public delegate void TOnMouseWheelEvent(Vec2i APosition, Vec2i AVector, TPressedMouseButtons APressedButtons); 
    public delegate void TOnWindowMove(int Xpos, int Ypos); 

    [ComImport]
    [Guid("8EB98692-67B1-4E64-9090-B6A0F47054BA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadWindow 
    {
        void Start(); 
        void SetCaption(string ACaption);
        void SetSize(int AWidth, int AHeight); 
        void SetPosition(int AXpos, int AYPos);
        [PreserveSig]
        UIntPtr GetHandle();

        void SetOnKeyDown(TOnKeyPress OnKeyDown); 
        void SetOnKeyUp(TOnKeyPress OnKeyUp); 
        void SetOnKeyChar(TOnKeyChar OnKeyChar); 
        void SetOnCreate(TOnCreate OnCreate); 
        void SetOnMouseMove(TOnMouseMoveEvent OnMouseMove); 
        void SetOnMouseDown(TOnMouseEvent OnMouseDown); 
        void SetOnMouseUp(TOnMouseEvent OnMouseUp); 
        void SetOnMouseDblClick(TOnMouseEvent OnMouseDblClick); 
        void SetOnMouseWheel(TOnMouseWheelEvent OnMouseWheel); 
        void SetOnWindowMove(TOnWindowMove OnWindowMove); 
    }
 
    /* Quad Camera */
 
    [ComImport]
    [Guid("BBC0BBF2-7602-489A-BE2A-37D681B7A242")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadCamera
    {
        void Scale(float AScale);
        void Rotate(float AAngle);
        void Translate(ref Vec2f ADistance);
        void Reset();
        void Enable();
        void Disable();
        [PreserveSig]
        Vec2f GetPosition();
        [PreserveSig]
        Vec2f GetAngle();
        [PreserveSig]
        Vec2f GetScale();
    }

    public static class QuadEngine
    {
        [DllImport("qei.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "CreateQuadDevice", CharSet = CharSet.Unicode)]
        public static extern IntPtr CreateQuadDevice(out IQuadDevice Device); //[Out, MarshalAs(UnmanagedType.Interface)]

        [DllImport("qei.dll", EntryPoint = "SecretMagicFunction", CharSet = CharSet.Unicode)]
        public static extern string SecretMagicFunction();
    }

}