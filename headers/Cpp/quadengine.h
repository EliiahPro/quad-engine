/*==============================================================================

  Quad engine 0.8.2 Diamond header file for Visual C++

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

==============================================================================*/

#ifndef _QUAD_ENGINE_WRAPPER
#define _QUAD_ENGINE_WRAPPER

#include <windows.h>
#include <unknwn.h>
#include <objbase.h>
#include "d3d9.h"
#include "Vec2f.h"

static const char* QUAD_DLL = "qei.dll";
static const char* CreateQuadDeviceProcName = "CreateQuadDevice";
static const char* CheckLibraryVersionProcName = "IsSameVersion";
static const char* SecretMagicFunctionProcName = "SecretMagicFunction";
static const unsigned char QuadEngineMinorVersion = 0;
static const unsigned char QuadEngineMajorVersion = 8;
static const unsigned char QuadEngineReleaseVersion = 2;

interface __declspec(uuid("E28626FF-738F-43B0-924C-1AFC7DEC26C7")) IQuadDevice;
interface __declspec(uuid("D9E9C42B-E737-4CF9-A92F-F0AE483BA39B")) IQuadRender;
interface __declspec(uuid("9A617F86-2CEC-4701-BF33-7F4989031BBA")) IQuadTexture;
interface __declspec(uuid("7B7F4B1C-7F05-4BC2-8C11-A99696946073")) IQuadShader;
interface __declspec(uuid("A47417BA-27C2-4DE0-97A9-CAE546FABFBA")) IQuadFont;
interface __declspec(uuid("7A4CE319-C7AF-4BF3-9218-C2A744F915E6")) IQuadLog;
interface __declspec(uuid("EA3BD116-01BF-4E12-B504-07D5E3F3AD35")) IQuadTimer;
interface __declspec(uuid("AA8C8463-89EC-4A2B-BF84-47C3DCA6CB98")) IQuadInput;
interface __declspec(uuid("E8691EB1-4C5D-4565-8B78-3FC7C620DFFB")) IQuadWindow;
interface __declspec(uuid("BBC0BBF2-7602-489A-BE2A-37D681B7A242")) IQuadCamera;
interface __declspec(uuid("FD99AF6B-1A7A-4981-8A1D-F70D427EA2E9")) IQuadGBuffer;

// Blending mode types
enum TQuadBlendMode {
	qbmInvalid = 0,
	qbmNone = 1,			/* Without blending */
	qbmAdd = 2,				/* Add source to dest */
	qbmSrcAlpha = 3,		/* Blend dest with alpha to source */
	qbmSrcAlphaAdd = 4,     /* Add source with alpha to dest */
	qbmSrcAlphaMul = 5,     /* Multiply source alpha with dest */
	qbmMul = 6,				/* Multiply Source with dest */
	qbmSrcColor = 7,		/* Blend source with color weight to dest */
	qbmSrcColorAdd = 8,     /* Blend source with color weight and alpha to dest */
	qbmInvertSrcColor = 9,	/* Blend inverted source color */
	qbmDstAlpha = 10        /* Copy destination alpha to source */
};    

// Texture adressing mode
enum TQuadTextureAdressing {
	qtaInvalid = 0,
	qtaWrap = 1,		/* Repeat UV */
	qtaMirror = 2,		/* Repeat UV with mirroring */
	qtaClamp = 3,		/* Do not repeat UV */
	qtaBorder = 4,		/* Fill outranged UV with border */
	qtaMirrorOnce = 5	/* Mirror UV once */
};  

// Texture filtering mode
enum TQuadTextureFiltering {
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
enum TQuadTextureMirroring {
	qtmInvalid = 0,
	qtmNone = 1,		/* No mirroring */
	qtmHorizontal = 2,	/* Horizontal mirroring */
	qtmVertical = 3,	/* Vertical mirroring */
	qtmBoth = 4			/* Horizontal and vertical mirroring */
}; 

// Vector record declaration
struct TVector
{
	float x, y, z;
};

struct TMatrix4x4
{
	float _11, _12, _13, _14;
	float _21, _22, _23, _24;
	float _31, _32, _33, _34;
	float _41, _42, _43, _44;
};

 // vertex record declaration
struct TVertex
{
	float x, y, z;		/* X, Y of vertex. Z not used */
	TVector normal;		/* Normal vector */
	unsigned int color;	/* Color */
	float u, v;			/* Texture UV coord */
	TVector tangent;	/* Tangent vector */
	TVector binormal;	/* Binormal vector */
};

// Shader model
enum TQuadShaderModel {
	qsmInvalid = 0,
	qsmNone = 1,	// do not use shaders
	qsm20 = 2,		// shader model 2.0
	qsm30 = 3		// shader model 3.0
};

// Initialization record
struct TRenderInit {
	HWND handle;
	int width;
	int height;
	int backBufferCount;
	int refreshRate;
	bool fullscreen;
	bool softwareVertexProcessing;
	bool multiThreaded;
	bool verticalSync;
	TQuadShaderModel shaderModel;
};

struct TRect
{
	unsigned int Left;
	unsigned int Top;
	unsigned int Right;
	unsigned int Bottom;
};

typedef void (WINAPI *TOnErrorFunction)(wchar_t* Errorstring);
typedef void (WINAPI *TTimerProcedure)(double& delta, unsigned int id);

/* Quad Device */

DECLARE_INTERFACE_(IQuadDevice, IUnknown)
{
	virtual HRESULT CALLBACK CreateAndLoadFont(wchar_t* fontTextureFilename, wchar_t* UVFilename, IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateAndLoadTexture(unsigned char ARegister, wchar_t* filename, IQuadTexture* &pQuadTexture, int patternWidth = 0, int patternHeight = 0, int colorKey = -1) = 0;
	virtual HRESULT CALLBACK CreateCamera(IQuadCamera* &pQuadCamera) = 0;
	virtual HRESULT CALLBACK CreateFont(IQuadFont* &pQuadFont) = 0;
	virtual HRESULT CALLBACK CreateGBuffer(IQuadGBuffer* &pQuadGBuffer) = 0;
	virtual HRESULT CALLBACK CreateLog(IQuadLog* &pQuadLog) = 0;
	virtual HRESULT CALLBACK CreateShader(IQuadShader* &pQuadShader) = 0;
	virtual HRESULT CALLBACK CreateTexture(IQuadTexture* &pQuadTexture) = 0;
	virtual HRESULT CALLBACK CreateTimer(IQuadTimer* &pQuadTimer) = 0;
	virtual HRESULT CALLBACK CreateTimerEx(IQuadTimer* &pQuadTimer, TTimerProcedure proc, unsigned short interval, bool isEnabled) = 0;
	virtual HRESULT CALLBACK CreateRender(IQuadRender* &pQuadRender) = 0;
	virtual HRESULT CALLBACK CreateRenderTarget(unsigned short width, unsigned short height, IQuadTexture* &texture, byte ARegister) = 0;
	virtual HRESULT CALLBACK CreateWindowEx(IQuadWindow* &pQuadWindow) = 0;
	virtual bool CALLBACK GetIsResolutionSupported(unsigned short width, unsigned short height) = 0;
	virtual wchar_t* CALLBACK GetLastError() = 0;
	virtual unsigned char CALLBACK GetMonitorsCount() = 0;
	virtual HRESULT CALLBACK GetSupportedScreenResolution(int index, COORD &Resolution) = 0;
	virtual void CALLBACK SetActiveMonitor(unsigned char monitorIndex) = 0;
	virtual void CALLBACK SetOnErrorCallBack(TOnErrorFunction proc) = 0;
	virtual void CALLBACK ShowCursor(bool show) = 0;
	virtual void CALLBACK SetCursorPosition(int x, int y) = 0;
	virtual void CALLBACK SetCursorProperties(unsigned int xHotSpot, unsigned int yHotSpot, IQuadTexture* image) = 0;
};

/* Quad Render */

DECLARE_INTERFACE_(IQuadRender, IUnknown)
{
	virtual void CALLBACK GetClipRect(TRect ARect) = 0;
	virtual unsigned int CALLBACK GetAvailableTextureMemory() = 0;
	virtual unsigned int CALLBACK GetMaxAnisotropy() = 0;
	virtual unsigned int CALLBACK GetMaxTextureHeight() = 0;
	virtual unsigned int CALLBACK GetMaxTextureStages() = 0;
	virtual unsigned int CALLBACK GetMaxTextureWidth() = 0;
	virtual wchar_t* CALLBACK GetPixelShaderVersionString() = 0;
	virtual unsigned char CALLBACK GetPSVersionMajor() = 0;
	virtual unsigned char CALLBACK GetPSVersionMinor() = 0;
	virtual wchar_t* CALLBACK GetVertexShaderVersionString() = 0;
	virtual unsigned char CALLBACK GetVSVersionMajor() = 0;
	virtual unsigned char CALLBACK GetVSVersionMinor() = 0;
	virtual wchar_t* CALLBACK GetRenderDeviceName() = 0;
	virtual void CALLBACK AddTrianglesToBuffer(const TVertex* vertexes, unsigned int count) = 0;
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
	virtual void CALLBACK Initialize(HWND handle, int width, int height, bool isFullscreen, TQuadShaderModel isCreateLog = qsm20) = 0;
	virtual void CALLBACK InitializeEx(const TRenderInit renderInit) = 0;
	virtual void CALLBACK InitializeFromIni(HANDLE AHandle, wchar_t* AFilename) = 0;
	virtual void CALLBACK Polygon(const Vec2f& pointA, const Vec2f& pointB, const Vec2f& pointC, const Vec2f& pointD, unsigned int color) = 0;
	virtual void CALLBACK Rectangle(const Vec2f& pointA, const Vec2f& pointB, unsigned int color) = 0;
	virtual void CALLBACK RectangleEx(const Vec2f& pointA, const Vec2f& pointB, unsigned int color1, unsigned int color2, unsigned int color3, unsigned int color4) = 0;
	virtual void CALLBACK RenderToGBuffer(bool isRenderToGBuffer, IQuadGBuffer* quadGBuffer = NULL, bool isCropScreen = false) = 0;
	virtual void CALLBACK RenderToTexture(bool isRenderToTexture, IQuadTexture* texture, unsigned char textureRegister = 0, unsigned char renderTargetRegister = 0, bool isCropScreen = false) = 0;
	virtual void CALLBACK RenderToBackBuffer() = 0;
	virtual void CALLBACK SetAutoCalculateTBN(bool Value) = 0;
	virtual void CALLBACK SetBlendMode(TQuadBlendMode Mode) = 0;
	virtual void CALLBACK SetClipRect(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2) = 0;
	virtual void CALLBACK SetTexture(unsigned char register, IDirect3DTexture9* texture) = 0;
	virtual void CALLBACK SetTextureAdressing(TQuadTextureAdressing textureAdressing) = 0;
	virtual void CALLBACK SetTextureFiltering(TQuadTextureFiltering textureFiltering) = 0;
	virtual void CALLBACK SetTextureMirroring(TQuadTextureMirroring textureMirroring) = 0;
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
	virtual void CALLBACK BindVariableToVS(unsigned char ARegister, void* variable, unsigned char size) = 0;
	virtual void CALLBACK BindVariableToPS(unsigned char ARegister, void* variable, unsigned char size) = 0;
	virtual HRESULT CALLBACK GetVertexShader(IDirect3DVertexShader9* &Shader) = 0;
	virtual HRESULT CALLBACK GetPixelShader(IDirect3DPixelShader9* &Shader) = 0;
	virtual void CALLBACK LoadVertexShader(wchar_t * vertexShaderFilename) = 0;
	virtual void CALLBACK LoadPixelShader(wchar_t* pixelShaderFilename) = 0;
	virtual void CALLBACK LoadComplexShader(wchar_t* vertexShaderFilename, wchar_t* pixelShaderFilename) = 0;
	virtual void CALLBACK SetShaderState(bool isEnabled) = 0;
	virtual void CALLBACK SetAutoCalculateTBN(bool Value) = 0;
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
enum TqfAlign {
	qfaInvalid = 0,
	qfaLeft = 1,		/* Align by left */
	qfaRight = 2,		/* Align by right */
	qfaCenter = 3,      /* Align by center */
	qfaJustify = 4		/* Align by both sides */
};   

// distance field options
struct TDistanceFieldParams {
	float edge1X, edge1Y;
	float edge2X, edge2Y;
	unsigned int outerColor;
	bool firstEdge, secondEdge;
};

DECLARE_INTERFACE_(IQuadFont, IUnknown)
{
	virtual bool CALLBACK GetIsLoaded() = 0;
	virtual float CALLBACK GetKerning() = 0;
	virtual void CALLBACK SetKerning(float value) = 0;
	virtual float CALLBACK GetSpacing() = 0;
	virtual void CALLBACK SetSpacing(float value) = 0;
	virtual void CALLBACK LoadFromFile(wchar_t* textureFilename, wchar_t* UVFilename) = 0;
	virtual void CALLBACK LoadFromStream(void* AStream, int AStreamSize, IQuadTexture* ATexture) = 0;
	virtual void CALLBACK SetSmartColor(wchar_t colorChar, unsigned int color) = 0;
	virtual void CALLBACK SetDistanceFieldParams(const TDistanceFieldParams& distanceFieldParams) = 0;
	virtual void CALLBACK SetIsSmartColoring(bool Value) = 0;
	virtual float CALLBACK TextHeight(wchar_t* AText, float AScale = 1.0) = 0;
	virtual float CALLBACK TextWidth(wchar_t* AText, float AScale = 1.0) = 0;
	virtual void CALLBACK TextOut(const Vec2f& position, float scale, wchar_t* text, unsigned int color = 0xFFFFFFFF, TqfAlign align = qfaLeft) = 0;
};

DECLARE_INTERFACE_(IQuadLog, IUnknown)
{
	virtual void CALLBACK Write(wchar_t* str) = 0;
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
	virtual void CALLBACK SetCallBack(TTimerProcedure AProc) = 0;
	virtual void CALLBACK SetInterval(unsigned short AInterval) = 0;
	virtual void CALLBACK SetState(bool AIsEnabled) = 0;
};

/* Quad Input */

enum TMouseButtons {
	mbLeft = 0,
	mbRight = 1,
	mbMiddle = 2,
	mbX1 = 3,
	mbX2 = 4
};    

struct TPressedMouseButtons {
	bool Left;
	bool Right;
	bool Middle;
	bool X1;
	bool X2;
};

enum TKeyButtons {
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

struct TPressedKeyButtons {
	bool None, Shift, LShift, RShift, Ctrl, LCtrl, RCtrl, Alt, LAlt, RAlt;
};

typedef void (WINAPI *TOnKeyPress)(const unsigned short key, const TPressedKeyButtons pressedButtons);
typedef void (WINAPI *TOnKeyChar)(const int charCode, const TPressedKeyButtons pressedButtons);
typedef void (WINAPI *TOnMouseMoveEvent)(const Vec2i& position, const TPressedMouseButtons pressedButtons);
typedef void (WINAPI *TOnMouseEvent)(const Vec2i& position, const TMouseButtons buttons, const TPressedMouseButtons pressedButtons);
typedef void (WINAPI *TOnMouseWheelEvent)(const Vec2i& position, const Vec2i& vector, const TPressedMouseButtons pressedButtons);
typedef void (WINAPI *TOnEvent)();
typedef void (WINAPI *TOnWindowMove)(const int xPos, const int yPos);


DECLARE_INTERFACE_(IQuadInput, IUnknown)
{
	virtual bool CALLBACK IsKeyDown(unsigned char key) = 0;
	virtual bool CALLBACK IsKeyPress(unsigned char key) = 0;
	virtual bool CALLBACK IsMouseDown(TMouseButtons button) = 0;
	virtual bool CALLBACK IsMouseClick(TMouseButtons button) = 0;
	virtual void CALLBACK GetMousePosition(Vec2f &AMousePosition) = 0;
	virtual void CALLBACK GetMouseVector(Vec2f &AMouseVector) = 0;
	virtual void CALLBACK GetMouseWheel(Vec2f &AMouseWheel) = 0;
	virtual void CALLBACK Update() = 0;
};

/* Quad Window */

DECLARE_INTERFACE_(IQuadWindow, IUnknown)
{
	virtual HRESULT CALLBACK CreateInput(IQuadInput* &pQuadInput) = 0;
	virtual void CALLBACK Start() = 0;
	virtual void CALLBACK SetCaption(const wchar_t* caption) = 0;
	virtual void CALLBACK SetSize(int width, int height) = 0;
	virtual void CALLBACK SetPosition(int xPos, int yPos) = 0;
	virtual HWND CALLBACK GetHandle() = 0;
		
	virtual void CALLBACK SetOnKeyDown(TOnKeyPress onKeyDown) = 0;
	virtual void CALLBACK SetOnKeyUp(TOnKeyPress onKeyUp) = 0;
	virtual void CALLBACK SetOnKeyChar(TOnKeyChar onKeyChar) = 0;
	virtual void CALLBACK SetOnCreate(TOnEvent onCreate) = 0;
	virtual void CALLBACK SetOnClose(TOnEvent onClose) = 0;
	virtual void CALLBACK SetOnActivate(TOnEvent onActivate) = 0;
	virtual void CALLBACK SetOnDeactivate(TOnEvent onDeactivate) = 0;
	virtual void CALLBACK SetOnMouseMove(TOnMouseMoveEvent onMouseMove) = 0;
	virtual void CALLBACK SetOnMouseDown(TOnMouseEvent onMouseDown) = 0;
	virtual void CALLBACK SetOnMouseUp(TOnMouseEvent onMouseUp) = 0;
	virtual void CALLBACK SetOnMouseDblClick(TOnMouseEvent onMouseDblClick) = 0;
	virtual void CALLBACK SetOnMouseWheel(TOnMouseWheelEvent onMouseWheel) = 0;
	virtual void CALLBACK SetOnWindowMove(TOnWindowMove onWindowMove) = 0;
    virtual void CALLBACK SetOnDeviceRestored(TOnEvent onDeviceRestored) = 0;
};

/* Quad Camera */

DECLARE_INTERFACE_(IQuadCamera, IUnknown)
{
	virtual void CALLBACK SetScale(float scale) = 0;
	virtual void CALLBACK Rotate(float angle) = 0;
	virtual void CALLBACK Translate(const Vec2f& distance) = 0;
	virtual void CALLBACK Reset() = 0;
	virtual void CALLBACK Enable() = 0;
	virtual void CALLBACK Disable() = 0;
	virtual Vec2f CALLBACK GetPosition() = 0;
	virtual float CALLBACK GetAngle() = 0;
	virtual TMatrix4x4 CALLBACK GetMatrix() = 0;
	virtual float CALLBACK GetScale() = 0;
	virtual void CALLBACK SetAngle(float angle) = 0;
	virtual void CALLBACK SetPosition(const Vec2f& position) = 0;
	virtual Vec2f CALLBACK GetTransformed(const Vec2f& vector) = 0;
};

/* Quad GBuffer */

DECLARE_INTERFACE_(IQuadGBuffer, IUnknown)
{
	virtual IQuadTexture* CALLBACK DiffuseMap() = 0;
	virtual IQuadTexture* CALLBACK NormalMap() = 0;
	virtual IQuadTexture* CALLBACK SpecularMap() = 0;
	virtual IQuadTexture* CALLBACK HeightMap() = 0;
	virtual IQuadTexture* CALLBACK Buffer() = 0;
	/// <summary>Draw light using GBuffer data</summary>
	/// <param name="position">Position in world space</param>
	/// <param name="height">Height of light. Lower is closer to plain.</param>
	/// <param name="radius">Radius of light</param>
	/// <param name="color">Light Color</param>
	/// <remarks>DrawLight must be used without using camera. GBuffer stores camera used to create it.</remarks>
	virtual void CALLBACK DrawLight(const Vec2f& position, float height, float radius, unsigned int color) = 0;
};

typedef void (WINAPI *TCreateQuadDevice)(IQuadDevice* &QuadDevice);
typedef bool (WINAPI *TCheckLibraryVersion)(unsigned char ARelease, unsigned char AMajor, unsigned char AMinor);
typedef wchar_t* (WINAPI *TSecretMagicFunction)();

HMODULE quadHandle;

inline void CreateQuadDevice(IQuadDevice* &quadDevice)
{
	quadHandle = LoadLibraryA(QUAD_DLL);
	if (quadHandle > 0)
	{
		TCheckLibraryVersion checkLibrary = (TCheckLibraryVersion)GetProcAddress(quadHandle, CheckLibraryVersionProcName);
		if (checkLibrary(QuadEngineReleaseVersion, QuadEngineMajorVersion, QuadEngineMinorVersion))
		{
			TCreateQuadDevice Creator = (TCreateQuadDevice)GetProcAddress(quadHandle, CreateQuadDeviceProcName);
			if (Creator > 0)
				Creator(quadDevice);
		}
	}
}

#endif