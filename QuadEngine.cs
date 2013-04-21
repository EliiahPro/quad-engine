/*==============================================================================

  Quad engine 0.5.0 header file for Visual C#

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

    public enum TQuadBlendMode{qbmInvalid        = 0,
                               qbmNone           = 1,     /* Without blending */
                               qbmAdd            = 2,     /* Add source to dest */
                               qbmSrcAlpha       = 3,     /* Blend dest with alpha to source */
                               qbmSrcAlphaAdd    = 4,     /* Add source with alpha to dest */
                               qbmSrcAlphaMul    = 5,     /* Multiply source alpha with dest */
                               qbmMul            = 6,     /* Multiply Source with dest */
                               qbmSrcColor       = 7,     /* Blend source with color weight to dest */
                               qbmSrcColorAdd    = 8,     /* Blend source with color weight and alpha to dest */
                               qbmInvertSrcColor = 9};    /* Blend inverted source color */

    // Texture adressing mode
    public enum TQuadTextureAdressing{qtaInvalid    = 0,
                                      qtaWrap       = 1,    /* Repeat UV */
                                      qtaMirror     = 2,    /* Repeat UV with mirroring */
                                      qtaClamp      = 3,    /* Do not repeat UV */
                                      qtaBorder     = 4,    /* Fill outranged UV with border */
                                      qtaMirrorOnce = 5};   /* Mirror UV once */

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

    /* Quad Device */

    [ComImport]
    [Guid("E28626FF-738F-43B0-924C-1AFC7DEC26C7")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadDevice
    {
        uint CreateAndLoadFont(string AFontTextureFilename, string AUVFilename, out IQuadFont IQuadFont);
        uint CreateAndLoadTexture(byte ARegister, string AFilename, out IQuadTexture IQuadTexture,
                                  int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        uint CreateCamera(out IQuadCamera IQuadCamera);
        uint CreateFont(out IQuadFont IQuadFont);
        uint CreateLog(out IQuadLog IQuadLog);
        uint CreateShader(out IQuadShader IQuadShader);
        uint CreateTexture(out IQuadTexture IQuadTexture);
        uint CreateTimer(out IQuadTimer IQuadTimer);
        uint CreateRender(out IQuadRender Device);
        void CreateRenderTarget(UInt16 AWidth, UInt16 AHeight, ref IQuadTexture IQuadTexture, byte ARegister);
        [PreserveSig]
        bool GetIsResolutionSupported(UInt16 AWidth, UInt16 AHeight);
        [PreserveSig] 
        string GetLastError();
        [PreserveSig]
        byte GetMonitorsCount();
        void GetSupportedScreenResolution(int index, out TCoord Resolution); 
        void SetActiveMonitor(byte AMonitorIndex);
        void SetOnErrorCallBack(IntPtr TOnErrorFunction);   // todo: Delegate
    }
 
    /* Quad Render */
 
    [ComImport]
    [Guid("D9E9C42B-E737-4CF9-A92F-F0AE483BA39B")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadRender
    {
        [PreserveSig]
        UInt32 GetAvailableTextureMemory();
        [PreserveSig] 
        UInt32 GetMaxAnisotropy();
        [PreserveSig] 
        UInt32 GetMaxTextureHeight();
        [PreserveSig] 
        UInt32 GetMaxTextureStages();
        [PreserveSig]
        UInt32 GetMaxTextureWidth();
        [PreserveSig] 
        string GetPixelShaderVersionString();
        [PreserveSig] 
        Byte GetPSVersionMajor();
        [PreserveSig] 
        Byte GetPSVersionMinor();
        [PreserveSig] 
        string GetVertexShaderVersionString();
        [PreserveSig] 
        Byte GetVSVersionMajor();
        [PreserveSig] 
        Byte GetVSVersionMinor();
        void AddTrianglesToBuffer(IntPtr AVertexes, UInt32 ACount); // todo: Vertices
        void BeginRender();
        void ChangeResolution(UInt16 AWidth, UInt16 AHeight);
        void Clear(UInt32 AColor);
        void CreateOrthoMatrix();
        void DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, double u1, double v1, double u2, double v2, UInt32 Color);
        void DrawRect(Vec2f PointA, Vec2f PointB, Vec2f UVA, Vec2f UVB, UInt32 Color);
        void DrawRectRot(Vec2f PointA, Vec2f PointB, double Angle, double Scale, Vec2f UVA, Vec2f UVB, UInt32 Color);
        void DrawRectRotAxis(Vec2f PointA, Vec2f PointB, double Angle, double Scale, Vec2f Axis, Vec2f UVA, Vec2f UVB, UInt32 Color);
        void DrawLine(Vec2f PointA, Vec2f PointB, UInt32 Color);
        void DrawPoint(Vec2f Point, UInt32 Color);
        void DrawQuadLine(Vec2f PointA, Vec2f PointB, float Width1, float Width2, uint Color1, uint Color2);
        void EndRender();
        void Finalize();
        void FlushBuffer();
        void Initialize(IntPtr AHandle, int AWidth, int AHeight, bool AIsFullscreen, bool AIsCreateLog = true);
        void InitializeFromIni(IntPtr AHandle, string AFilename);
        void Polygon(Vec2f PointA, Vec2f PointB, Vec2f PointC, Vec2f PointD, UInt32 Color);
        void Rectangle(Vec2f PointA, Vec2f PointB, UInt32 Color);
        void RectangleEx(Vec2f PointA, Vec2f PointB, UInt32 Color1, UInt32 Color2, UInt32 Color3, UInt32 Color4);
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
        void AddTexture(byte ARegister, IntPtr ATexture);  // todo: IDirect3DTexture9
        void Draw(Vec2f Position, UInt32 Color = 0xFFFFFFFF);
        void DrawFrame(Vec2f Position, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, UInt32 Color = 0xFFFFFFFF);
        void DrawMap(Vec2f PointA, Vec2f PointB, Vec2f UVA, Vec2f UVB, UInt32 Color = 0xFFFFFFFF);
        void DrawMapRotAxis(double x, double y, double x2, double y2, double u1, double v1, double u2, double v2, double xA, double yA, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawRot(double x, double y, double angle, double Scale, UInt32 Color = 0xFFFFFFFF);
        void DrawRotFrame(double x, double y, double angle, double Scale, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxis(double x, double y, double angle, double Scale, double xA, double yA, UInt32 Color = 0xFFFFFFFF);
        void DrawRotAxisFrame(double x, double y, double angle, double Scale, double xA, double yA, UInt16 Pattern, UInt32 Color = 0xFFFFFFFF);
        void LoadFromFile(byte ARegister, string AFilename, int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1);
        void LoadFromRAW(byte ARegister, IntPtr AData, int AWidth, int AHeight);
        void SetIsLoaded(UInt16 AWidth, UInt16 AHeight);
    }

    /* Quad Shader */

    [ComImport]
    [Guid("7B7F4B1C-7F05-4BC2-8C11-A99696946073")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadShader
    {
        void BindVariableToVS(byte ARegister, UIntPtr AVariable, byte ASize);
        void BindVariableToPS(byte ARegister, UIntPtr AVariable, byte ASize);
        [PreserveSig]
        IntPtr GetVertexShader(out IntPtr Shader); // todo: IDirect3DVertexShader9
        [PreserveSig]
        IntPtr GetPixelShader(out IntPtr Shader); // todo: IDirect3DPixelShader9
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

    [ComImport]
    [Guid("A47417BA-27C2-4DE0-97A9-CAE546FABFBA")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadFont
    {
        [PreserveSig]
        bool GetIsLoaded();
        [PreserveSig]
        float GetKerning();
        void LoadFromFile(string ATextureFilename, string AUVFilename);
        void SetSmartColor(string AColorChar, UInt32 AColor);
        void SetIsSmartColoring(bool Value);
        void SetKerning(float AValue);
        [PreserveSig]
        float TextHeight(string AText, float AScale = 1.0F);
        [PreserveSig]
        float TextWidth(string AText, float AScale = 1.0F);
        void TextOut(Vec2f Position, float y, float AScale, string AText, UInt32 AColor = 0xFFFFFFFF, TqfAlign AAlign = TqfAlign.qfaLeft);
    }
 
    /* Quad Log */
   
    [ComImport]
    [Guid("7A4CE319-C7AF-4BF3-9218-C2A744F915E6")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadLog
    {
        void Write(string aString);
    }
 
    /* Quad Timer */

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
    public interface IQuadTimer
    {
        [PreserveSig] 
        float GetCPUload();
        [PreserveSig]
        double GetDelta();
        [PreserveSig]
        float GetFPS();
        [PreserveSig]
        double GetWholeTime();
        [PreserveSig]
        UInt32 GetTimerID();
        void ResetWholeTimeCounter();
        void SetCallBack(IntPtr AProc);
        void SetInterval(UInt16 AInterval);
        void SetState(bool AIsEnabled);
    }
 
    /* Quad Camera */
 
    [ComImport]
    [Guid("BBC0BBF2-7602-489A-BE2A-37D681B7A242")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IQuadCamera
    {
        void Shift(float AXShift, float AYShift);
        void Shear(float AXShear, float AYShear);
        void Zoom(float AScale);
        void Rotate(float AAngle);
        void Translate(float AXDistance, float AYDistance);
    }

    public static class QuadEngine
    {
        [DllImport("qei.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "CreateQuadDevice", CharSet = CharSet.Unicode)]
        public static extern IntPtr CreateQuadDevice(out IQuadDevice Device); //[Out, MarshalAs(UnmanagedType.Interface)]

        [DllImport("qei.dll", EntryPoint = "SecretMagicFunction", CharSet = CharSet.Unicode)]
        public static extern string SecretMagicFunction();
    }

}