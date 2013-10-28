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

  PB: TPressedMouseButtons;
  PB2: TPressedMouseButtons;

procedure OnMouseMove(Position: TVec2i; PressedButtons: TPressedMouseButtons); stdcall;
begin
  QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y)));
 //
  PB := PressedButtons;
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i: Integer;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(0);

  for i := 0 to 4 do
  begin
    if PB.a[i] then
      QuadRender.Rectangle(TVec2f.Create(15 * i + 10, 10), TVec2f.Create(15 * i + 20, 20), $FFFF0000)
    else
      QuadRender.Rectangle(TVec2f.Create(15 * i + 10, 10), TVec2f.Create(15 * i + 20, 20), $FFFFFFFF);

    if PB2.a[i] then
      QuadRender.Rectangle(TVec2f.Create(15 * i + 10, 40), TVec2f.Create(15 * i + 20, 50), $FFFF0000)
    else
      QuadRender.Rectangle(TVec2f.Create(15 * i + 10, 40), TVec2f.Create(15 * i + 20, 50), $FFFFFFFF);

  end;

  QuadRender.EndRender;
end;

procedure OnMouseDown(Position: TVec2i; Buttons: TMouseButtons; PressedButtons: TPressedMouseButtons); stdcall;
begin
  case Buttons of
    mbLeft: PB2.Left := True;
    mbRight: PB2.Right := True;
    mbMiddle: PB2.Middle := True;
    mbX1: PB2.X1 := True;
    mbX2: PB2.X2 := True;
  end;
end;

procedure OnMouseUp(Position: TVec2i; Buttons: TMouseButtons; PressedButtons: TPressedMouseButtons); stdcall;
begin
  case Buttons of
    mbLeft: PB2.Left := False;
    mbRight: PB2.Right := False;
    mbMiddle: PB2.Middle := False;
    mbX1: PB2.X1 := False;
    mbX2: PB2.X2 := False;
  end;
end;

procedure OnMouseDblClick(Position: TVec2i; Buttons: TMouseButtons; PressedButtons: TPressedMouseButtons); stdcall;
begin
  case Buttons of
    mbLeft: QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y) + ' DblLeft'));
    mbRight: QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y) + ' DblRight'));
    mbMiddle: QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y) + ' DblMiddle'));
    mbX1: QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y) + ' DblX1'));
    mbX2: QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y) + ' DblX2'));
  end;
end;

procedure OnMouseWheel(Position: TVec2i; Vector: TVec2i; PressedButtons: TPressedMouseButtons); stdcall;
begin
  QuadWindow.SetCaption(PChar( 'Wheel: ' + IntToStr(Vector.X) + 'x' + IntToStr(Vector.Y)));
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine window demo');
  QuadWindow.SetSize(800, 600);
  QuadWindow.SetPosition(100, 100);

  QuadWindow.SetOnMouseMove(OnMouseMove);
  QuadWindow.SetOnMouseDown(OnMouseDown);
  QuadWindow.SetOnMouseUp(OnMouseUp);
  QuadWindow.SetOnMouseDblClick(OnMouseDblClick);

  QuadWindow.SetOnMouseWheel(OnMouseWheel);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
