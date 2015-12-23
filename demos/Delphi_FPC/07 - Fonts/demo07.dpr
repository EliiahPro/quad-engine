program demo07;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f, QuadEngine.Color;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  QuadFont: IQuadFont;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  df: TDistanceFieldParams;
begin
  QuadRender.BeginRender;
  QuadRender.Clear($FF111111);
  QuadRender.SetBlendMode(qbmSrcAlpha);

  //Simple non-antialiased text
  df.FirstEdge := False;
  df.Edge1X := 0.5;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 100), 1.0, 'Simple non-antialiased text');


    //Simple antialiased text
  df.FirstEdge := True;
  df.Edge1X := 0.43;
  df.Edge1Y := 0.5;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 140), 1.0, 'Simple antialiased text');

   //Thin antialiased text
  df.FirstEdge := True;
  df.Edge1X := 0.53;
  df.Edge1Y := 0.58;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 180), 1.0, 'Thin antialiased text');

    //Bold antialiased text
  df.FirstEdge := True;
  df.Edge1X := 0.40;
  df.Edge1Y := 0.45;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 220), 1.0, 'Bold antialiased text');


      // Text with inking
  df.FirstEdge := True;
  df.Edge1X := 0.35;
  df.Edge1Y := 0.40;
  df.SecondEdge := True;
  df.Edge2X := 0.45;
  df.Edge2Y := 0.50;
  df.OuterColor := TQuadColor.Orange;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 260), 1.0, 'Text with inking');

    //Outlined text
  df.FirstEdge := True;
  df.Edge1X := 0.35;
  df.Edge1Y := 0.40;
  df.SecondEdge := True;
  df.Edge2X := 0.45;
  df.Edge2Y := 0.50;
  df.OuterColor := TQuadColor.White;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.TextOut(TVec2f.Create(100, 300), 1.0, 'Outlined text', $00000000);

    //Outlined text
  df.FirstEdge := True;
  df.Edge1X := 0.05;
  df.Edge1Y := 0.50;
  df.SecondEdge := True;
  df.Edge2X := 0.45;
  df.Edge2Y := 0.50;
  df.OuterColor := TQuadColor.Violet;
  QuadFont.SetDistanceFieldParams(df);
  QuadFont.SetKerning(5);
  QuadFont.TextOut(TVec2f.Create(100, 340), 1.0, 'Glowing text', TQuadColor.Fuchsia);
  QuadFont.SetKerning(0);

  // downscale
  df.FirstEdge := True;
  df.Edge1X := 0.40;
  df.Edge1Y := 0.5;
  df.SecondEdge := False;
  QuadFont.SetDistanceFieldParams(df);

  QuadFont.SetKerning(0.5); // for better readability
  QuadFont.TextOut(TVec2f.Create(100, 400), 0.5, 'downscaled to 0.5 antialiased text');
  QuadFont.TextOut(TVec2f.Create(100, 415), 0.3, 'downscaled to 0.3 antialiased text');
  QuadFont.TextOut(TVec2f.Create(100, 440), 0.75, 'downscaled to 0.75 antialiased text');
  QuadFont.SetKerning(0);

  // upscale
  df.FirstEdge := True;
  df.Edge1X := 0.43;
  df.Edge1Y := 0.5;
  QuadFont.SetDistanceFieldParams(df);
  QuadFont.TextOut(TVec2f.Create(100, 500), 1.75, 'Upscale to 1.75 antialiased text');

  df.FirstEdge := True;
  df.Edge1X := 0.47;
  df.Edge1Y := 0.5;
  QuadFont.SetDistanceFieldParams(df);
  QuadFont.TextOut(TVec2f.Create(100, 600), 3.33, 'Upscale to 3.33');

  df.FirstEdge := True;
  df.Edge1X := 0.49;
  df.Edge1Y := 0.5;
  QuadFont.SetDistanceFieldParams(df);
  QuadFont.TextOut(TVec2f.Create(100, 800), 7.0, 'Zoom 7');

  QuadRender.EndRender;
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine fonts demo');
  QuadWindow.SetSize(1024, 768);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 1024, 768, False);

  QuadDevice.CreateAndLoadFont('data\font.png', 'data\font.qef', QuadFont);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
