program Demo09;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f, System.SysUtils, QuadEngine.Device;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);

  QuadRender.EndRender;
end;

begin
  Device := TQuadDevice.Create; QuadDevice := Device;
  //QuadDevice := CreateQuadDevice;
  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine profiler demo');
  QuadWindow.SetSize(160, 90);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
