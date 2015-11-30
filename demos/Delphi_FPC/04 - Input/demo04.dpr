program demo04;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f, SysUtils, Windows;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  QuadInput: IQuadInput;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;

  procedure DrawRect(APosition: TVec2f; AState: Boolean);
  begin
    if AState then
      QuadRender.Rectangle(APosition * 15, APosition * 15 + TVec2f.Create(10, 10), $FFFF0000)
    else
      QuadRender.Rectangle(APosition * 15, APosition * 15 + TVec2f.Create(10, 10), $FFFFFFFF);
  end;

begin
  QuadInput.Update;

  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);

  DrawRect(TVec2f.Create(2, 1), QuadInput.IsKeyDown(ord('W')));
  DrawRect(TVec2f.Create(2, 2), QuadInput.IsKeyDown(ord('S')));
  DrawRect(TVec2f.Create(1, 2), QuadInput.IsKeyDown(ord('A')));
  DrawRect(TVec2f.Create(3, 2), QuadInput.IsKeyDown(ord('D')));

  DrawRect(TVec2f.Create(2, 4), QuadInput.IsKeyPress(ord('W')));
  DrawRect(TVec2f.Create(2, 5), QuadInput.IsKeyPress(ord('S')));
  DrawRect(TVec2f.Create(1, 5), QuadInput.IsKeyPress(ord('A')));
  DrawRect(TVec2f.Create(3, 5), QuadInput.IsKeyPress(ord('D')));

  DrawRect(TVec2f.Create(6, 1), QuadInput.IsMouseDown(mbLeft));
  DrawRect(TVec2f.Create(7, 1), QuadInput.IsMouseDown(mbMiddle));
  DrawRect(TVec2f.Create(8, 1), QuadInput.IsMouseDown(mbRight));
  DrawRect(TVec2f.Create(9, 1), QuadInput.IsMouseDown(mbX1));
  DrawRect(TVec2f.Create(10, 1), QuadInput.IsMouseDown(mbX2));

  DrawRect(TVec2f.Create(6, 4), QuadInput.IsMouseClick(mbLeft));
  DrawRect(TVec2f.Create(7, 4), QuadInput.IsMouseClick(mbMiddle));
  DrawRect(TVec2f.Create(8, 4), QuadInput.IsMouseClick(mbRight));
  DrawRect(TVec2f.Create(9, 4), QuadInput.IsMouseClick(mbX1));
  DrawRect(TVec2f.Create(10, 4), QuadInput.IsMouseClick(mbX2));

  QuadRender.DrawCircle(QuadInput.GetMousePosition, 20, 18 );

  QuadRender.DrawQuadLine(TVec2f.Create(400, 300), TVec2f.Create(400, 300) + QuadInput.GetMouseVector, 3, 1, $FFFFFFFF, $FFFFFFFF);
  QuadRender.DrawQuadLine(TVec2f.Create(100, 300), TVec2f.Create(100, 300) + QuadInput.GetMouseWheel, 7, 1, $FFFFFFFF, $FF00FF00);

  QuadRender.EndRender;
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.CreateInput(QuadInput);
  QuadWindow.SetCaption('Quad-engine window demo');
  QuadWindow.SetSize(800, 600);
  QuadWindow.SetPosition(100, 100);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
