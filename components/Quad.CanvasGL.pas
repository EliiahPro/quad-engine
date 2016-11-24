unit Quad.CanvasGL;

interface

uses
  Winapi.Windows, OpenGL, QuadEngine.Color, Vec2f, Vcl.Graphics, System.Generics.Collections,
  PNGImage, System.StrUtils, Winapi.Messages, System.Classes, Vcl.Forms;

type
  TQuadBitmaps = class;
  TQuadCanvasGLFont = class;
  TQuadCanvasGLCamera = class;

  TQuadCanvasGL = class
  private
    FHandle: HDC;
    FHRC: HGLRC;
    FWidth: Integer;
    FHeight: Integer;
    FPenColor, FBrushColor: array[0..3] of Single;

    FDefaultFont: TQuadCanvasGLFont;

    procedure InitOpenGL;
  public
    constructor Create(AHandle: HDC; AWidth, AHeight: Integer);
    destructor Destroy; override;

    procedure RenderingBegin(ABackgroundColor: TQuadColor);
    procedure RenderingEnd;
    procedure Resize(AWidth, AHeight: Integer);

    procedure SetPenColor(const AColor: TQuadColor);
    procedure SetBrushColor(const AColor: TQuadColor);
    procedure ApplyCamera(ACamera: TQuadCanvasGLCamera);

    procedure DrawLine(const APointA, APointB: TVec2f);
    procedure DrawPolyline(APoints: PVec2f; ACount: Integer);
    procedure FillPolygon(APoints: PVec2f; ACount: Integer);
    procedure DrawRectangle(const APointA, APointB: TVec2f; AFill: Boolean = False);
    procedure DrawBitmap(ABitmap: TBitmap; const APosition: TVec2f);
    procedure TextOut(AFont: TQuadCanvasGLFont; const APosition: TVec2f; const AText: WideString);

    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

  TQuadBitmaps = class
  private
    FBitmaps: TDictionary<string, TBitmap>;
    function GetItem(Index: string): TBitmap;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadBitmapFromPNG(const AName, AFileName: string): TBitmap;
    property Item[Index: string]: TBitmap read GetItem; default;
  end;

  TQuadCanvasGLFont = class
  private
    FFont: HFONT;
    FName: string;
    FSize: Integer;
    FStyles: TFontStyles;
  public
    constructor Create(const AName: WideString; ASize: Integer; AStyles: TFontStyles = []);
    destructor Destroy; override;
  end;

  TQuadCanvasGLCamera = class
  private
    FRotation: Single;
    FScale: TVec2f;
    FTranslate: TVec2f;
  public
    constructor Create;
    property Rotation: Single read FRotation write FRotation;
    property Scale: TVec2f read FScale write FScale;
    property Translate: TVec2f read FTranslate write FTranslate;
  end;

  TQuadCanvasGLTimerEvent = reference to procedure(const Delta: Double);

  TQuadCanvasGLTimer = class
  private
    class var FCounterFrequency: Int64;
    class var FTickMessage: Cardinal;
    class constructor Create;
    class destructor Destroy;
  private
    FProcInLoop: Boolean;
    FHandle: HWND;
    FTimerHandle: Cardinal;
    FEnabled: Boolean;
    FOnTimer: TQuadCanvasGLTimerEvent;
    FInterval: Integer;
    procedure WndProc(var AMessage: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
    property OnTimer: TQuadCanvasGLTimerEvent read FOnTimer write FOnTimer;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Interval: Integer read FInterval write FInterval;
  end;

implementation

const
  GL_TEXTURE_3D = $806F;
  GL_TEXTURE_CUBE_MAP_ARB = $8513;

type
  PPngPixel = ^TPngPixel;
  TPngPixel = record
    B, G, R: Byte;
  end;

  PBitPixel = ^TBitPixel;
  TBitPixel = record
    R, G, B, A: Byte;
  end;

constructor TQuadCanvasGLCamera.Create;
begin
  FRotation := 0;
  FScale := TVec2f.Create(1, 1);
  FTranslate := TVec2f.Zero;
end;

{ TQuadCanvasGL }

constructor TQuadCanvasGL.Create(AHandle: HDC; AWidth, AHeight: Integer);
begin
  FHandle := AHandle;
  FWidth := AWidth;
  FHeight := AHeight;

  InitOpenGL;

  FDefaultFont := TQuadCanvasGLFont.Create('MS Serif', 10);
end;

procedure TQuadCanvasGL.InitOpenGL;
var
   pfd: TPIXELFORMATDESCRIPTOR;
   pixelFormat: Integer;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize := SizeOf(TPIXELFORMATDESCRIPTOR);
    nVersion := 1;
    dwFlags := PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW;
    iPixelType := PFD_TYPE_RGBA;
    cColorBits := 32;
    cDepthBits := 16;
    iLayerType := PFD_MAIN_PLANE;
  end;
  pixelFormat := ChoosePixelFormat(FHandle, @pfd);
  SetPixelFormat(FHandle, pixelFormat, @pfd);
  FHRC := wglCreateContext(FHandle);
  wglMakeCurrent(FHandle, FHRC);
  GdiFlush();

  glPushAttrib(GL_ENABLE_BIT);
  glDisable(GL_CULL_FACE);
  glDisable(GL_LIGHTING);
  glDisable(GL_FOG);
  glDisable(GL_COLOR_MATERIAL);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_TEXTURE_1D);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_3D);
  glDisable(GL_TEXTURE_CUBE_MAP_ARB);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_SMOOTH);
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_POINT_SMOOTH);
  glEnable(GL_POLYGON_SMOOTH);
  glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);

  glViewPort(0, 0, FWidth, FHeight);
  glMatrixMode(GL_PROJECTION);
  gluOrtho2D(0, FWidth, FHeight, 0);
  glMatrixMode(GL_MODELVIEW);
end;

destructor TQuadCanvasGL.Destroy;
begin
  if Assigned(FDefaultFont) then
    FDefaultFont.Free;

  wglDeleteContext(FHRC);
  inherited;
end;

procedure TQuadCanvasGL.Resize(AWidth, AHeight: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  wglDeleteContext(FHRC);
  InitOpenGL;
end;

procedure TQuadCanvasGL.RenderingBegin(ABackgroundColor: TQuadColor);
begin
  //if FRendering then
  //  Exit;
  //FRendering := True;
  //if (FWidth <> FControl.ClientWidth) or (FHeight <> FControl.ClientHeight) then
  //  Recreate
  wglMakeCurrent(FHandle, FHRC);
  GdiFlush();

  glClearColor(ABackgroundColor.R, ABackgroundColor.G, ABackgroundColor.B, ABackgroundColor.A);
  glClear(GL_COLOR_BUFFER_BIT);

  ApplyCamera(nil);

  // User must keep in mind that Matrix Mode mustn't be changed during rendering.
  //glColor4fv(@FPenColor);
end;

procedure TQuadCanvasGL.RenderingEnd;
begin
  SwapBuffers(FHandle);
end;

procedure TQuadCanvasGL.SetPenColor(const AColor: TQuadColor);
begin
  FPenColor[0] := AColor.R;
  FPenColor[1] := AColor.G;
  FPenColor[2] := AColor.B;
  FPenColor[3] := AColor.A;
end;

procedure TQuadCanvasGL.SetBrushColor(const AColor: TQuadColor);
begin
  FBrushColor[0] := AColor.R;
  FBrushColor[1] := AColor.G;
  FBrushColor[2] := AColor.B;
  FBrushColor[3] := AColor.A;
end;

procedure TQuadCanvasGL.ApplyCamera(ACamera: TQuadCanvasGLCamera);
begin
  glLoadIdentity;
  if Assigned(ACamera) then
  begin
    glTranslate(ACamera.Translate.X, ACamera.Translate.Y, 0);
    glScale(ACamera.Scale.X, ACamera.Scale.Y, 1.0);
    glRotatef(ACamera.Rotation, 0.0, 0.0, 1.0);
  end
  else
  begin
    glTranslate(0, 0, 0.0);
    glScale(1, 1, 1);
    glRotatef(0, 0, 0, 1);
  end;
end;

procedure TQuadCanvasGL.DrawLine(const APointA, APointB: TVec2f);
begin
  glColor4fv(@FPenColor);
  glBegin(GL_LINES);
  glVertex2f(APointA.X, APointA.Y);
  glVertex2f(APointB.X, APointB.Y);
  glEnd;
end;

procedure TQuadCanvasGL.DrawPolyline(APoints: PVec2f; ACount: Integer);
var
  i: Integer;
begin
  if ACount > 1 then
  begin
    glColor4fv(@FPenColor);
    glBegin(GL_LINE_STRIP);
    for i := 0 to ACount - 1 do
    begin
      glVertex2f(APoints.X, APoints.Y);
      Inc(APoints);
    end;
    glEnd;
  end;
end;

procedure TQuadCanvasGL.FillPolygon(APoints: PVec2f; ACount: Integer);
var
  i: Integer;
begin
  if ACount > 1 then
  begin
    glColor4fv(@FBrushColor);
    glBegin(GL_QUAD_STRIP);
    for i := 0 to ACount - 1 do
    begin
      glVertex2f(APoints.X, APoints.Y);
      Inc(APoints);
    end;
    glEnd;
  end;
end;

procedure TQuadCanvasGL.DrawRectangle(const APointA, APointB: TVec2f; AFill: Boolean = False);
begin
  if AFill then
  begin
    glColor4fv(@FBrushColor);
    glRectf(APointA.X, APointA.Y, APointB.X, APointB.Y);
  end;

  glColor4fv(@FPenColor);
  glBegin(GL_LINE_LOOP);
  glVertex2f(APointA.X, APointA.Y);
  glVertex2f(APointB.X, APointA.Y);
  glVertex2f(APointB.X, APointB.Y);
  glVertex2f(APointA.X, APointB.Y);
  glEnd;
end;

procedure TQuadCanvasGL.DrawBitmap(ABitmap: TBitmap; const APosition: TVec2f);
begin
  if not Assigned(ABitmap) then
    Exit;
  //glPixelZoom(1, 1);
  glPushMatrix;
  glLoadIdentity;
  glRasterPos2i(Round(APosition.X), Round(APosition.Y));
  glDrawPixels(ABitmap.Width, ABitmap.Height, GL_RGBA, GL_UNSIGNED_BYTE, ABitmap.ScanLine[ABitmap.Height - 1]);
  glPopMatrix;
end;

procedure TQuadCanvasGL.TextOut(AFont: TQuadCanvasGLFont; const APosition: TVec2f; const AText: WideString);
var
  i: Integer;
  List: GLuint;
begin
  if not Assigned(AFont) then
    AFont := FDefaultFont;

  SelectObject(FHandle, AFont.FFont);
  glColor4fv(@FPenColor);

  glPushMatrix;
  glLoadIdentity;
  glRasterPos2f(APosition.X, APosition.Y);
  for i := 1 to Length(AText) do
  begin
    wglUseFontBitmapsW(FHandle, Ord(AText[i]), 1, List);
    glCallList(List);
  end;
  glDeleteLists(List, 1);
  glPopMatrix;
end;

{ TQuadBitmaps }

constructor TQuadBitmaps.Create;
begin
  FBitmaps := TDictionary<string, TBitmap>.Create;
end;

destructor TQuadBitmaps.Destroy;
var
  Bitmap: TPair<string, TBitmap>;
begin
  for Bitmap in FBitmaps do
    Bitmap.Value.Free;
  FBitmaps.Free;
  inherited;
end;

function TQuadBitmaps.GetItem(Index: string): TBitmap;
begin
  if FBitmaps.ContainsKey(Index) then
    Exit(FBitmaps.Items[Index]);
  Result := nil;
end;

function TQuadBitmaps.LoadBitmapFromPNG(const AName, AFileName: string): TBitmap;
var
  bit: TBitmap;
  png: TPngImage;
  l, i: Integer;
  PngPixel: PPngPixel;
  BitPixel: PBitPixel;
begin
  png := TPngImage.Create;
  try
    png.LoadFromFile(AFileName);
    bit := TBitmap.Create;
    try
      bit.PixelFormat := pf32bit;
      bit.SetSize(png.Width, png.Height);

      for l := 0 to png.Height - 1 do
      begin
        PngPixel := png.Scanline[l];
        BitPixel := bit.ScanLine[l];

        for i := 0 to png.Width - 1 do
        begin
          BitPixel.R := PngPixel.R;
          BitPixel.G := PngPixel.G;
          BitPixel.B := PngPixel.B;
          BitPixel.A := png.AlphaScanline[l][i];

          Inc(PngPixel);
          Inc(BitPixel);
        end;
      end;
      FBitmaps.Add(AName, bit);
    except
      bit.Free;
    end;
  finally
    png.Free;
  end;
end;

{ TQuadCanvasGLFont }

constructor TQuadCanvasGLFont.Create(const AName: WideString; ASize: Integer; AStyles: TFontStyles = []);
const
  IF_BOOL: array [Boolean] of Integer = (0, 1);
  IF_BOLD: array [Boolean] of Integer = (FW_NORMAL, FW_BOLD);
begin
  FName := AName;
  FSize := ASize;
  FStyles := AStyles;

  FFont := CreateFontW(FSize, 0, 0, 0, IF_BOLD[fsBold in FStyles], IF_BOOL[fsItalic in FStyles], IF_BOOL[fsUnderline in FStyles],
                       IF_BOOL[fsStrikeOut in FStyles], DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                       CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_SWISS,
                       PWideChar(FName));
end;

destructor TQuadCanvasGLFont.Destroy;
begin
  DeleteObject(FFont);
  inherited;
end;

{ TQuadCanvasGLTimer }

class constructor TQuadCanvasGLTimer.Create;
begin
  FTickMessage := RegisterWindowMessage('QuadTimerTick');
  QueryPerformanceFrequency(FCounterFrequency);
end;

class destructor TQuadCanvasGLTimer.Destroy;
begin
  inherited;
end;

constructor TQuadCanvasGLTimer.Create;
begin
  FProcInLoop := False;
  FHandle := AllocateHWnd(WndProc);
  FTimerHandle := SetTimer(FHandle, 1, 1, nil);
  PostMessage(FHandle, FTickMessage, 0, 0);
end;

destructor TQuadCanvasGLTimer.Destroy;
begin
  KillTimer(FHandle, FTimerHandle);
  FTimerHandle := 0;
  inherited;
end;

procedure TQuadCanvasGLTimer.WndProc(var AMessage: TMessage);
begin
  if (AMessage.Msg = FTickMessage) or (AMessage.Msg = WM_TIMER) and FEnabled and not FProcInLoop then
  begin
    try
      FProcInLoop := True;
      if not Application.Terminated then
      begin
        try
          sleep(16);
          Application.ProcessMessages;
          if Assigned(FOnTimer) then
            FOnTimer(0);
          PostMessage(FHandle, FTickMessage, 0, 0);
        except
          Application.HandleException(Self);
          FEnabled := False;
        end;
      end
      else
        FEnabled := False;
    finally
      FProcInLoop := False;
    end;
  end;
  AMessage.Result := 0;
end;

end.
