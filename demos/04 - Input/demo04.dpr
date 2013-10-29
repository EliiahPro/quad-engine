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

  PressedButtons: TPressedMouseButtons;
  PressedButtons2: TPressedMouseButtons;

procedure OnMouseMove(Position: TVec2i; APressedButtons: TPressedMouseButtons); stdcall;
begin
  QuadWindow.SetCaption(PChar(IntToStr(Position.X) + 'x' + IntToStr(Position.Y)));
 //
  PressedButtons := APressedButtons;
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  Button: TMouseButtons;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(0);

  for Button := mbLeft to mbX2 do
  begin
    if PressedButtons.a[Button] then
      QuadRender.Rectangle(TVec2f.Create(15 * Integer(Button) + 10, 10), TVec2f.Create(15 * Integer(Button) + 20, 20), $FFFF0000)
    else
      QuadRender.Rectangle(TVec2f.Create(15 * Integer(Button) + 10, 10), TVec2f.Create(15 * Integer(Button) + 20, 20), $FFFFFFFF);

    if PressedButtons2.a[Button] then
      QuadRender.Rectangle(TVec2f.Create(15 * Integer(Button) + 10, 40), TVec2f.Create(15 * Integer(Button) + 20, 50), $FFFF0000)
    else
      QuadRender.Rectangle(TVec2f.Create(15 * Integer(Button) + 10, 40), TVec2f.Create(15 * Integer(Button) + 20, 50), $FFFFFFFF);

  end;

  QuadRender.EndRender;
end;

procedure OnMouseDown(APosition: TVec2i; AButtons: TMouseButtons; APressedButtons: TPressedMouseButtons); stdcall;
begin
  case AButtons of
    mbLeft: PressedButtons2.Left := True;
    mbRight: PressedButtons2.Right := True;
    mbMiddle: PressedButtons2.Middle := True;
    mbX1: PressedButtons2.X1 := True;
    mbX2: PressedButtons2.X2 := True;
  end;
end;

procedure OnMouseUp(APosition: TVec2i; AButtons: TMouseButtons; APressedButtons: TPressedMouseButtons); stdcall;
begin
  case AButtons of
    mbLeft: PressedButtons2.Left := False;
    mbRight: PressedButtons2.Right := False;
    mbMiddle: PressedButtons2.Middle := False;
    mbX1: PressedButtons2.X1 := False;
    mbX2: PressedButtons2.X2 := False;
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
