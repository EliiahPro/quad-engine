/*==============================================================================

  Quad engine 0.5.2 header file for Visual C++

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
#include "Vec2f.h"

static const char* QUAD_DLL = "qei.dll";

// Blending mode types

enum QuadBlendMode {
	qbmInvalid = 0,
	qbmNone = 1,     /* Without blending */
	qbmAdd = 2,     /* Add source to dest */
	qbmSrcAlpha = 3,     /* Blend dest with alpha to source */
	qbmSrcAlphaAdd = 4,     /* Add source with alpha to dest */
	qbmSrcAlphaMul = 5,     /* Multiply source alpha with dest */
	qbmMul = 6,     /* Multiply Source with dest */
	qbmSrcColor = 7,     /* Blend source with color weight to dest */
	qbmSrcColorAdd = 8,     /* Blend source with color weight and alpha to dest */
	qbmInvertSrcColor = 9
};    /* Blend inverted source color */

// Texture adressing mode
enum QuadTextureAdressing {
	qtaInvalid = 0,
	qtaWrap = 1,		/* Repeat UV */
	qtaMirror = 2,		/* Repeat UV with mirroring */
	qtaClamp = 3,		/* Do not repeat UV */
	qtaBorder = 4,		/* Fill outranged UV with border */
	qtaMirrorOnce = 5	/* Mirror UV once */
};  

// Texture filtering mode
enum QuadTextureFiltering {
	qtfInvalid = 0,
	qtfNone = 1,			/* Filtering disabled (valid for mip filter only) */
	qtfPoint = 2,			/* Nearest */
	qtfLinear = 3,			/* Linear interpolation */
	qtfAnisotropic = 4,		/* Anisotropic */
	qtfPyramidalQuad = 5,	/* 4-sample tent */
	qtfGaussianQuad = 6,	/* 4-sample gaussian */
	qtfConvolutionMono = 7	/* Convolution filter for monochrome textures */
};   

// Texture Mirroring mode
enum QuadTextureMirroring {
	qtmInvalid = 0,
	qtmNone = 1,		/* No mirroring */
	qtmHorizontal = 2,	/* Horizontal mirroring */
	qtmVertical = 3,	/* Vertical mirroring */
	qtmBoth = 4			/* Horizontal and vertical mirroring */
}; 

// Shader model
enum QuadShaderModel {
	qsmInvalid = 0,
	qsmNone = 1,   // do not use shaders
	qsm20 = 2,   // shader model 2.0
	qsm30 = 3
};  // shader model 3.0

// Initialization record
typedef struct RenderInit {
	HWND handle;
	int width;
	int height;
	int backBufferCount;
	int refreshRate;
	bool fullscreen;
	bool softwareVertexProcessing;
	bool multiThreaded;
	bool verticalSync;
	QuadShaderModel shaderModel;
};

// Vector record declaration
struct QuadVec
{
	float x, y, z;
};

 // vertex record declaration
struct QuadVert
{
	float x, y, z;		/* X, Y of vertex. Z not used */
	QuadVec normal;		/* Normal vector */
	unsigned int color;	/* Color */
	float u, v;			/* Texture UV coord */
	QuadVec tangent;	/* Tangent vector */
	QuadVec binormal;	/* Binormal vector */
};

struct QuadRect
{
	unsigned int Left;
	unsigned int Top;
	unsigned int Right;
	unsigned int Bottom;
};

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
interface __declspec(uuid("FD99AF6B-1A7A-4981-8A1D-F70D427EA2E9")) IQuadGBuffer;
interface __declspec(uuid("AA8C8463-89EC-4A2B-BF84-47C3DCA6CB98")) IQuadInput;

typedef void (WINAPI *QuadOnErrorFunction)(char* Errorstring);
typedef void (WINAPI *QuadTimerProcedure)(double& delta, unsigned int id);

/* Quad Device */

DECLARE_INTERFACE_(IQuadDevice, IUnknown)
{
	virtual HRESULT CALLBACK CreateAndLoadFont(char* fontTextureFilename, wchar_t* UVFilename, IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateAndLoadTexture(unsigned char ARegister, wchar_t* filename, IQuadTexture* &pQuadTexture, int patternWidth = 0, int patternHeight = 0, int colorKey = -1) = 0;
	virtual HRESULT CALLBACK CreateCamera(IQuadCamera* &pQuadCamera) = 0;
	virtual HRESULT CALLBACK CreateFont(IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateGBuffer(IQuadGBuffer* &pQuadGBuffer) = 0;
	virtual HRESULT CALLBACK CreateLog(IQuadLog* &pQuadLog) = 0;
	virtual HRESULT CALLBACK CreateShader(IQuadShader* &pQuadShader) = 0;
	virtual HRESULT CALLBACK CreateTexture(IQuadTexture* &pQuadTexture) = 0;
	virtual HRESULT CALLBACK CreateTimer(IQuadTimer* &pQuadTimer) = 0;
	virtual HRESULT CALLBACK CreateTimerEx(IQuadTimer* &pQuadTimer, QuadTimerProcedure proc, unsigned short interval, bool isEnabled);
	virtual HRESULT CALLBACK CreateRender(IQuadRender* &pQuadRender) = 0;
	virtual HRESULT CALLBACK CreateRenderTarget(unsigned short width, unsigned short height, IQuadTexture* &texture, byte ARegister) = 0;
	virtual HRESULT CALLBACK CreateWindowEx(IQuadWindow* &pQuadWindow) = 0;
	virtual bool CALLBACK GetIsResolutionSupported(unsigned short width, unsigned short height) = 0;
	virtual char* CALLBACK GetLastError() = 0;
	virtual unsigned char CALLBACK GetMonitorsCount() = 0;
	virtual HRESULT CALLBACK GetSupportedScreenResolution(int index, COORD &Resolution) = 0;
	virtual void CALLBACK SetActiveMonitor(unsigned char monitorIndex) = 0;
	virtual void CALLBACK SetOnErrorCallBack(QuadOnErrorFunction proc) = 0;
	virtual void CALLBACK ShowCursor(bool show) = 0;
	virtual void CALLBACK SetCursorPosition(int x, int y) = 0;
	virtual void CALLBACK SetCursorProperties(unsigned int xHotSpot, unsigned int yHotSpot, IQuadTexture image) = 0;
};

/* Quad Render */

DECLARE_INTERFACE_(IQuadRender, IUnknown)
{
	virtual QuadRect CALLBACK GetClipRect() = 0;
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
	virtual wchar_t* CALLBACK GetRenderDeviceName() = 0;
	virtual void CALLBACK AddTrianglesToBuffer(const QuadVert* vertexes, unsigned int count) = 0;
	virtual void CALLBACK BeginRender() = 0;
	virtual void CALLBACK ChangeResolution(unsigned short width, unsigned short height, bool isVirtual = true) = 0;
	virtual void CALLBACK Clear(unsigned int color) = 0;
	//virtual void CALLBACK CreateOrthoMatrix() = 0;
	virtual void CALLBACK DrawCircle(const Vec2f& center, float radius, float innerRadius, unsigned int color = 0xFFFFFFFF) = 0;
	//virtual void CALLBACK DrawDistort(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	//virtual void CALLBACK DrawRect(double x, double y, double x2, double y2, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	//virtual void CALLBACK DrawRectRot(double x, double y, double x2, double y2, double Angle, double Scale, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	//virtual void CALLBACK DrawRectRotAxis(double x, double y, double x2, double y2, double Angle, double Scale, double xA, double yA, double u1, double v1, double u2, double v2, unsigned int Color) = 0;
	virtual void CALLBACK DrawLine(const Vec2f& pointA, const Vec2f& pointB, unsigned int color) = 0;
	virtual void CALLBACK DrawPoint(const Vec2f& point, unsigned int color) = 0;
    virtual	void CALLBACK DrawQuadLine(const Vec2f& pointA, const Vec2f& pointB, float width1, float width2, unsigned int color1, unsigned int color2) = 0;
	virtual void CALLBACK EndRender() = 0;
	virtual void CALLBACK Finalize() = 0;
	virtual void CALLBACK FlushBuffer() = 0;
	virtual void CALLBACK Initialize(HWND handle, int width, int height, bool isFullscreen, QuadShaderModel isCreateLog = qsm20) = 0;
	virtual void CALLBACK InitializeEx(const RenderInit renderInit) = 0;
	virtual void CALLBACK InitializeFromIni(HANDLE AHandle, wchar_t* AFilename) = 0;
	virtual void CALLBACK Polygon(const Vec2f& pointA, const Vec2f& pointB, const Vec2f& pointC, const Vec2f& pointD, unsigned int color) = 0;
	virtual void CALLBACK Rectangle(const Vec2f& pointA, const Vec2f& pointB, unsigned int Color) = 0;
	virtual void CALLBACK RectangleEx(const Vec2f& pointA, const Vec2f& pointB, unsigned int color1, unsigned int color2, unsigned int color3, unsigned int color4) = 0;
	virtual void CALLBACK RenderToGBuffer(bool isRenderToGBuffer, IQuadGBuffer* quadGBuffer = NULL, bool isCropScreen = false) = 0;
	virtual void CALLBACK RenderToTexture(bool isRenderToTexture, IQuadTexture* texture, unsigned char textureRegister = 0, unsigned char renderTargetRegister = 0, bool isCropScreen = false) = 0;
	virtual void CALLBACK SetAutoCalculateTBN(bool Value) = 0;
	virtual void CALLBACK SetBlendMode(QuadBlendMode Mode) = 0;
	virtual void CALLBACK SetClipRect(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2) = 0;
	virtual void CALLBACK SetTexture(unsigned char register, IDirect3DTexture9* texture) = 0;
	virtual void CALLBACK SetTextureAdressing(QuadTextureAdressing textureAdressing) = 0;
	virtual void CALLBACK SetTextureFiltering(QuadTextureFiltering textureFiltering) = 0;
	virtual void CALLBACK SetTextureMirroring(QuadTextureMirroring textureMirroring) = 0;
	virtual void CALLBACK SetPointSize(unsigned int size) = 0;
	virtual void CALLBACK SkipClipRect() = 0;
	virtual void CALLBACK TakeScreenshot(wchar_t* fileName) = 0;
	virtual void CALLBACK ResetDevice() = 0;
	virtual IDirect3DDevice9* CALLBACK GetD3DDevice() = 0;
};

	/* Quad Texture */

enum RAWDataFormat {
	rdfInvalid = 0,
	rdfARGB8 = 1,
	rdfRGBA8 = 2,
	rdfABGR8 = 3
};

DECLARE_INTERFACE_(IQuadTexture, IUnknown)
{
	virtual bool CALLBACK GetIsLoaded() = 0;
	virtual int CALLBACK GetPatternCount() = 0;
	virtual unsigned short CALLBACK GetPatternHeight() = 0;
	virtual unsigned short CALLBACK GetPatternWidth() = 0;
	virtual unsigned int CALLBACK GetPixelColor(int x, int y, unsigned char ARegister = 0);
	virtual unsigned short CALLBACK GetSpriteHeight() = 0;
	virtual unsigned short CALLBACK GetSpriteWidth() = 0;
	virtual IDirect3DTexture9* CALLBACK GetTexture(unsigned char i) = 0;
	virtual unsigned short CALLBACK GetTextureHeight() = 0;
	virtual unsigned short CALLBACK GetTextureWidth() = 0;
	virtual void CALLBACK AddTexture(unsigned char ARegister, IDirect3DTexture9* ATexture) = 0;
	virtual void CALLBACK AssignTexture(IQuadTexture* quadTexture, unsigned char sourceRegister, unsigned char targetRegister) = 0;
	virtual void CALLBACK Draw(const Vec2f& position, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawFrame(const Vec2f& position, unsigned short pattern, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawMap(const Vec2f& pointA, const Vec2f& pointB, const Vec2f& UVA, const Vec2f& UVB, unsigned int Color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawMapRotAxis(const Vec2f pointA, const Vec2f& pointB, const Vec2f& UVA, const Vec2f& UVB, const Vec2f& axis, double angle, double scale, unsigned int color = 0xFFFFFFFF) = 0;
	
	virtual void CALLBACK DrawPart(const Vec2f& position, Vec2i leftTop, Vec2i rightBottom, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawPartRot(const Vec2f& center, double angle, double scale, Vec2i leftTop, Vec2i rightBottom, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawPartRotAxis(const Vec2f& position, double angle, double scale, const Vec2f axis, Vec2i leftTop, Vec2i rightBottom, unsigned int color = 0xFFFFFFFF) = 0;

	virtual void CALLBACK DrawRot(const Vec2f& center, double angle, double scale, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawRotFrame(const Vec2f& center, double angle, double scale, unsigned short pattern, unsigned int Color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawRotAxis(const Vec2f& position, double angle, double scale, const Vec2f& axis, unsigned int color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK DrawRotAxisFrame(const Vec2f& position, double angle, double scale, const Vec2f& axis, unsigned short pattern, unsigned int color = 0xFFFFFFFF) = 0;

	virtual void CALLBACK LoadFromFile(unsigned char ARegister, const wchar_t* filename, int patternWidth = 0, int patternHeight = 0, int colorKey = -1) = 0;
	virtual void CALLBACK LoadFromStream(unsigned char ARegister, void* AStream, int streamSize, int patternWidth = 0, int patternHeight = 0, int colorKey = -1);
	virtual void CALLBACK LoadFromRAW(unsigned char ARegister, void* AData, int width, int height, RAWDataFormat sourceFormat = rdfARGB8) = 0;
	virtual void CALLBACK SetIsLoaded(unsigned short width, unsigned short height) = 0;
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
	virtual void CALLBACK TextOut(float x, float y, float Scale, char* Text, unsigned int Color = 0xFFFFFFFF) = 0;
	virtual void CALLBACK TextOutAligned(float x, float y, float Scale, char* Text, unsigned int Color = 0xFFFFFFFF, QuadFontAlign Align = qfaLeft) = 0;
	virtual void CALLBACK TextOutCentered(float x, float y, float Scale, char* Text, unsigned int Color = 0xFFFFFFFF) = 0;
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
};

typedef enum TMouseButtons {
	mbLeft = 0,
	mbRight = 1,
	mbMiddle = 2,
	mbX1 = 3,
	mbX2 = 4
};    

struct TPressedMouseButtons
{
	bool Left;
	bool Right;
	bool Middle;
	bool X1;
	bool X2;
};

DECLARE_INTERFACE_(IQuadWindow, IUnknown)
{
	virtual HRESULT CALLBACK CreateInput(IQuadInput* &pQuadInput) = 0;
	virtual void CALLBACK Start() = 0;
	virtual void CALLBACK SetCaption(wchar_t* caption) = 0;
	virtual void CALLBACK SetSize(int width, int height) = 0;
	virtual void CALLBACK SetPosition(int xPos, int yPos) = 0;
	virtual HWND CALLBACK GetHandle() = 0;
};

DECLARE_INTERFACE_(IQuadInput, IUnknown)
{
	
};

DECLARE_INTERFACE_(IQuadGBuffer, IUnknown)
{

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

#endif