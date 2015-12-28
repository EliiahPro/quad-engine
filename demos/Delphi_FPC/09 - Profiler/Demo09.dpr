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

  QuadProfiler: IQuadProfiler;
  QuadProfilerTag: IQuadProfilerTag;


procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadProfiler.BeginTick;
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);
  QuadProfilerTag.BeginCount;
  QuadProfilerTag.EndCount;
  QuadRender.EndRender;
  QuadProfiler.EndTick;
end;

procedure OnClose; stdcall;
begin
  QuadTimer.SetState(False);
  sleep(500);

  QuadTimer := nil;
  QuadRender := nil;
  QuadWindow := nil;
  QuadDevice := nil;
end;

begin
  Device := TQuadDevice.Create; QuadDevice := Device;
  //QuadDevice := CreateQuadDevice;
  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetOnClose(OnClose);
  QuadWindow.SetCaption('Quad-engine profiler demo');
  QuadWindow.SetSize(160, 90);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateProfiler('Demo 09 - Profiler', QuadProfiler);
  QuadProfiler.SetGUID(StringToGUID('{AFEBAB39-0D7C-40A4-AA2C-122F3E8950C1}'));
  QuadProfiler.CreateTag('Line 01', QuadProfilerTag);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
