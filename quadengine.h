/*==============================================================================

  Quad engine 0.5.1 header file for Visual C++

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

#ifndef _QUAD_ENGINE_WRAPPER
#define _QUAD_ENGINE_WRAPPER

#include <windows.h>
#include <unknwn.h>
#include <objbase.h>
#include "d3d9.h"

static const char* QUAD_DLL = "qei.dll";

// Blending mode types

typedef enum QuadBlendMode{qbmInvalid        = 0,
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
typedef enum TQuadTextureAdressing{qtaInvalid    = 0,
								   qtaWrap       = 1,    /* Repeat UV */
								   qtaMirror     = 2,    /* Repeat UV with mirroring */
								   qtaClamp      = 3,    /* Do not repeat UV */
								   qtaBorder     = 4,    /* Fill outranged UV with border */
								   qtaMirrorOnce = 5};   /* Mirror UV once */

// Texture filtering mode
typedef enum TQuadTextureFiltering{qtfInvalid         = 0,
								   qtfNone            = 1,    /* Filtering disabled (valid for mip filter only) */
								   qtfPoint           = 2,    /* Nearest */
								   qtfLinear          = 3,    /* Linear interpolation */
								   qtfAnisotropic     = 4,    /* Anisotropic */
								   qtfPyramidalQuad   = 5,    /* 4-sample tent */
								   qtfGaussianQuad    = 6,    /* 4-sample gaussian */
								   qtfConvolutionMono = 7};   /* Convolution filter for monochrome textures */

// Vector record declaration
typedef struct QuadVec
{
	float x, y, z;
} QuadVec;

 // vertex record declaration
typedef struct QuadVert
{
	float x, y, z;		/* X, Y of vertex. Z not used */
	QuadVec normal;		/* Normal vector */
	unsigned int color;	/* Color */
	float u, v;			/* Texture UV coord */
	QuadVec tangent;	/* Tangent vector */
	QuadVec binormal;	/* Binormal vector */
} QuadVert;

interface __declspec(uuid("E28626FF-738F-43B0-924C-1AFC7DEC26C7")) IQuadDevice;
interface __declspec(uuid("D9E9C42B-E737-4CF9-A92F-F0AE483BA39B")) IQuadRender;
interface __declspec(uuid("9A617F86-2CEC-4701-BF33-7F4989031BBA")) IQuadTexture;
interface __declspec(uuid("7B7F4B1C-7F05-4BC2-8C11-A99696946073")) IQuadShader;
interface __declspec(uuid("A47417BA-27C2-4DE0-97A9-CAE546FABFBA")) IQuadFont;
interface __declspec(uuid("7A4CE319-C7AF-4BF3-9218-C2A744F915E6")) IQuadLog;
interface __declspec(uuid("EA3BD116-01BF-4E12-B504-07D5E3F3AD35")) IQuadTimer;
interface __declspec(uuid("3E6AF547-AB0B-42ED-A40E-8DC10FC6C45F")) IQuadSprite;
interface __declspec(uuid("E8691EB1-4C5D-4565-8B78-3FC7C620DFFB")) IQuadWindow;
interface __declspec(uuid("BBC0BBF2-7602-489A-BE2A-37D681B7A242")) IQuadCamera;

typedef void (WINAPI *QuadOnErrorFunction)(char* Errorstring);
typedef void (WINAPI *QuadTimerProcedure)(double& Delta, unsigned int Id);

	/* Quad Device */

DECLARE_INTERFACE_(IQuadDevice, IUnknown)
{
	virtual HRESULT CALLBACK CreateAndLoadFont(char* AFontTextureFilename, char* AUVFilename, IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateAndLoadTexture(unsigned char ARegister, char* AFilename, IQuadTexture* &pQuadTexture, int APatternWidth = 0, int APatternHeight = 0, int AColorKey = -1) = 0;
	virtual HRESULT CALLBACK CreateCamera(IQuadCamera* &pQuadCamera) = 0;
	virtual HRESULT CALLBACK CreateFont(IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateFont(IQuadLog* &pQuadLog) = 0;
	virtual HRESULT CALLBACK CreateShader(IQuadShader* &pQuadShader) = 0;
	virtual HRESULT CALLBACK CreateTexture(IQuadTexture* &pQuadTexture) = 0;
	virtual HRESULT CALLBACK CreateTimer(IQuadTimer* &pQuadTimer) = 0;
	virtual HRESULT CALLBACK CreateRender(IQuadRender* &pQuadRender) = 0;
	virtual HRESULT CALLBACK CreateRenderTarget(unsigned short AWidth, unsigned short AHeight, IQuadTexture* &ATexture, byte ARegister) = 0;
	virtual bool CALLBACK GetIsResolutionSupported(unsigned short AWidth, unsigned short AHeight) = 0;
	virtual char* CALLBACK GetLastError() = 0;
	virtual unsigned char CALLBACK GetMonitorsCount() = 0;
	virtual HRESULT CALLBACK GetSupportedScreenResolution(int index, COORD &Resolution) = 0;
	virtual void CALLBACK SetActiveMonitor(unsigned char AMonitorIndex) = 0;
	virtual void CALLBACK SetOnErrorCallBack(QuadOnErrorFunction Proc) = 0;
};

	/* Quad Render */

DECLARE_INTERFACE_(IQuadRender, IUnknown)
{
	virtual unsigned int CALLBACK GetAvailableTextureMemory() = 0;
	virtual unsigned int CALLBACK GetMaxAnisotropy() = 0;
	virtual unsigned int CALLBACK GetMaxTextureHeight() = 0;
	virtual unsigned int CALLBACK GetMaxTextureStages() = 0;
	virtual unsigned int CALLBACK GetMaxTextureWidth() = 0;
	virtual char* CALLBACK GetPixelShaderVersionString() = 0;
	virtual unsigned char CALLBACK GetPSVersionMajor() = 0;
	virtual unsigned char CALLBACK GetPSVersionMinor() = 0;
	virtual char* CALLBACK GetVertexShaderVersionString() = 0;
	virtual unsigned char CALLBACK GetVSVersionMajor() = 0;
	virtual unsigned char CALLBACK GetVSVersionMinor() = 0;
	virtual void CALLBACK AddTrianglesToBuffer(const QuadVert* AVertexes, unsigned int ACount) = 0;
	virtual void CALLBACK BeginRender() = 0;
	virtual void CALLBACK ChangeResolution(unsigned short AWidth, unsigned short AHeight) = 0;
	virtual void CALLBACK Clear(unsigned int AColor) = 0;
	virtual void CALLBACK CreateOrthoMatrix() = 0;
	virtual void CALLBACK DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	virtual void CALLBACK DrawRect(double x, double y, double x2, double y2, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	virtual void CALLBACK DrawRectRot(double x, double y, double x2, double y2, double Angle, double Scale, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	virtual void CALLBACK DrawRectRotAxis(double x, double y, double x2, double y2, double Angle, double Scale, double xA, double yA, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	virtual void CALLBACK DrawLine(float x1, float y1, float x2, float y2, unsigned int Color) = 0;
	virtual void CALLBACK DrawPoint(float x, float y, unsigned int Color) = 0;
    virtual	void CALLBACK DrawQuadLine(float x1, float y1, float x2, float y2, float width1, float width2, unsigned int Color1, unsigned int Color2) = 0;
	virtual void CALLBACK EndRender() = 0;
	virtual void CALLBACK Finalize() = 0;
	virtual void CALLBACK FlushBuffer() = 0;
	virtual void CALLBACK Initialize(HWND Handle, int AWidth, int AHeight, bool AIsFullscreen, bool AIsCreateLog = true) = 0;
	virtual void CALLBACK InitializeFromIni(HANDLE AHandle, char* AFilename) = 0;
	virtual void CALLBACK Rectangle(double x1, double y1, double x2, double y2, unsigned int Color) = 0;
	virtual void CALLBACK RectangleEx(double x1, double y1, double x2, double y2, unsigned int Color1, unsigned int Color2, unsigned int Color3, unsigned int Color4) = 0;
	virtual void CALLBACK RenderToTexture(bool AIsRenderToTexture, IQuadTexture* ATexture, unsigned char ATextureRegister = 0, unsigned char ARenderTargetRegister = 0, bool AIsCropScreen = false) = 0;
	virtual void CALLBACK SetAutoCalculateTBN(bool Value) = 0;
	virtual void CALLBACK SetBlendMode(QuadBlendMode Mode) = 0;
	virtual void CALLBACK SetClipRect(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2) = 0;
	virtual void CALLBACK SetTexture(unsigned char ARegister, IDirect3DTexture9* ATexture) = 0;
	virtual void CALLBACK SetTextureAdressing(D3DTEXTUREADDRESS ATextureAdressing) = 0;
	virtual void CALLBACK SetTextureFiltering(D3DTEXTUREFILTERTYPE ATextureFiltering) = 0;
	virtual void CALLBACK SetPointSize(unsigned int ASize) = 0;
	virtual void CALLBACK SkipClipRect() = 0;
	virtual void CALLBACK ResetDevice() = 0;
	virtual IDirect3DDevice9* CALLBACK GetD3DDevice() = 0;
};

	/* Quad Texture */

DECLARE_INTERFACE_(IQuadTexture, IUnknown)
{
	virtual bool CALLBACK GetIsLoaded() = 0;
	virtual int CALLBACK GetPatternCount() = 0;
	virtual unsigned short CALLBACK GetPatternWidth() = 0;
	virtual unsigned short CALLBACK GetPatternHeight() = 0;
	virtual unsigned int CALLBACK GetPixelColor(int x, int y, unsigned char ARegister = 0);
	virtual unsigned short CALLBACK GetSpriteWidth() = 0;
	virtual unsigned short CALLBACK GetSpriteHeight() = 0;
	virtual IDirect3DTexture9* CALLBACK GetTexture(unsigned char i) = 0;
	virtual unsigned short CALLBACK GetTextureHeight() = 0;
	virtual unsigned short CALLBACK GetTextureWidth() = 0;
	virtual void CALLBACK AddTexture(unsigned char ARegister, IDirect3DTexture9* ATexture) = 0;
	virtual void CALLBACK Draw(double x, double y, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawFrame(double x, double y, unsigned short Pattern, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawMap(double x, double y, double x2, double y2, double u1, double v1, double u2, double v2, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawMapRotAxis(double x, double y, double x2, double y2, double u1, double v1, double u2, double v2, double xA, double yA, double Angle, double Scale, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawRot(double x, double y, double Angle, double Scale, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawRotFrame(double x, double y, double Angle, double Scale, unsigned short Pattern, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawRotAxis(double x, double y, double Angle, double Scale, double aX, double aY, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK DrawRotAxisFrame(double x, double y, double Angle, double Scale, double aX, double aY, unsigned short Pattern, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK LoadFromFile(unsigned char ARegister, const char* AFilename, int PatternWidth = 0, int PatternHeight = 0, int ColorKey = -1) = 0;
	virtual void CALLBACK LoadFromRAW(unsigned char ARegister, void* AData, int AWidth, int AHeight) = 0;
	virtual void CALLBACK SetIsLoaded(unsigned short AWidth, unsigned short AHeight) = 0;
};

	/* Quad Shader */

DECLARE_INTERFACE_(IQuadShader, IUnknown)
{
	virtual void CALLBACK BindVariableToVS(unsigned char ARegister, void* AVariable, unsigned char ASize) = 0;
	virtual void CALLBACK BindVariableToPS(unsigned char ARegister, void* AVariable, unsigned char ASize) = 0;
	virtual HRESULT CALLBACK GetVertexShader(IDirect3DVertexShader9* &Shader) = 0;
	virtual HRESULT CALLBACK GetPixelShader(IDirect3DPixelShader9* &Shader) = 0;
	virtual void CALLBACK LoadVertexShader(char * AVertexShaderFilename) = 0;
	virtual void CALLBACK LoadPixelShader(char* APixelShaderFilename) = 0;
	virtual void CALLBACK LoadComplexShader(char* AVertexShaderFilename, char* APixelShaderFilename) = 0;
	virtual void CALLBACK SetShaderState(bool AIsEnabled) = 0;
};

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
typedef enum QuadFontAlign{qfaInvalid = 0,
						   qfaLeft    = 1,      /* Align by left */
						   qfaRight   = 2,      /* Align by right */
						   qfaCenter  = 3,      /* Align by center */
						   qfaJustify = 4};     /* Align by both sides */

DECLARE_INTERFACE_(IQuadFont, IUnknown)
{
	virtual bool CALLBACK GetIsLoaded() = 0;
	virtual float CALLBACK GetKerning() = 0;
	virtual void CALLBACK LoadFromFile(char* ATextureFilename, char* AUVFilename) = 0;
	virtual void CALLBACK SetSmartColor(char AColorChar, unsigned int AColor) = 0;
	virtual void CALLBACK SetIsSmartColoring(bool Value) = 0;
	virtual void CALLBACK SetKerning(float AValue) = 0;
	virtual float CALLBACK TextHeight(char* AText, float AScale = 1.0) = 0;
	virtual float CALLBACK TextWidth(char* AText, float AScale = 1.0) = 0;
	virtual void CALLBACK TextOut(float x, float y, float Scale, char* Text, unsigned int Color = qclWhite) = 0;
	virtual void CALLBACK TextOutAligned(float x, float y, float Scale, char* Text, unsigned int Color = qclWhite, QuadFontAlign Align = qfaLeft) = 0;
	virtual void CALLBACK TextOutCentered(float x, float y, float Scale, char* Text, unsigned int Color = qclWhite) = 0;
};

DECLARE_INTERFACE_(IQuadLog, IUnknown)
{
	virtual void CALLBACK Write(void* str) = 0;
};

	/* Quad Timer */

DECLARE_INTERFACE_(IQuadTimer, IUnknown)
{
	virtual float CALLBACK GetCPULoad() = 0;
	virtual double CALLBACK GetDelta() = 0;
	virtual float CALLBACK GetFPS() = 0;
	virtual double CALLBACK GetWholeTime() = 0;
	virtual unsigned int CALLBACK GetTimerId() = 0;
	virtual void CALLBACK ResetWholeTimeCounter() = 0;
	virtual void CALLBACK SetCallBack(QuadTimerProcedure AProc) = 0;
	virtual void CALLBACK SetInterval(unsigned short AInterval) = 0;
	virtual void CALLBACK SetState(bool AIsEnabled) = 0;
};

	/* Quad Camera */

DECLARE_INTERFACE_(IQuadCamera, IUnknown)   
{
    virtual void CALLBACK Shift(float AXShift, float AYShift) = 0;
    virtual void CALLBACK Shear(float AXShear, float AYShear) = 0;
    virtual void CALLBACK Zoom(float AScale) = 0;
    virtual void CALLBACK Rotate(float AAngle) = 0;
    virtual void CALLBACK Translate(float AXDistance, float AYDistance) = 0;
}

DECLARE_INTERFACE_(IQuadSprite, IUnknown)
{
	virtual void CALLBACK Draw() = 0;
	virtual void CALLBACK SetPosition(double x, double y) = 0;
	virtual void CALLBACK SetVelocity(double x, double y) = 0;
};

DECLARE_INTERFACE_(IQuadWindow, IUnknown)
{
	virtual unsigned int CALLBACK GetHandle() = 0;
	virtual void CALLBACK SetPosition(int ATop, int ALeft) = 0;
	virtual void CALLBACK SetDimension(int AWidth, int AHeight) = 0;
};

template <class T> void CreateQuadInstance(T*& Object, const char* CreatorName)
{
	HMODULE hDLL = LoadLibraryA(QUAD_DLL);
	
	if (!hDLL)
	{
		Object = NULL;
		return;
	}

	HRESULT (WINAPI *Creator)(void*& obj) = reinterpret_cast<HRESULT (WINAPI*)(void*&)>(GetProcAddress(hDLL, CreatorName));
	
	if (Creator)
	{
		void* pObj;
		Creator(pObj);
		Object = reinterpret_cast<T*>(pObj);
	}
	else
		Object = NULL;
}

inline void CreateQuadDevice(IQuadDevice* &QuadDevice)
{
	CreateQuadInstance(QuadDevice, "CreateQuadDevice");
}

inline void CreateQuadWindow(IQuadWindow* &QuadWindow)
{
	CreateQuadInstance(QuadWindow, "CreateQuadWindow");
}

#endif