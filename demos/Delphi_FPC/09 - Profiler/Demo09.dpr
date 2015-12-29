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
  QuadInput: IQuadInput;

  QuadProfiler: IQuadProfiler;
  QuadProfilerTag: IQuadProfilerTag;

  Points: array[0..999] of TVec2f;
  PointCount: Integer = 0;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i: Integer;
  MousePosition: TVec2f;
begin
  QuadInput.Update;
  QuadInput.GetMousePosition(MousePosition);

  if QuadInput.IsMouseDown(mbLeft) and (PointCount < 1000) then
  begin
    Points[PointCount] := MousePosition;
    Inc(PointCount);
  end;

  //QuadProfiler.BeginTick;
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);
  QuadProfilerTag.BeginCount;

  for i := 0 to PointCount - 1 do
    QuadRender.DrawCircle(Points[i], 6, 5, $FFAAAAAA);

  QuadProfilerTag.EndCount;
  QuadRender.EndRender;
  //QuadProfiler.EndTick;
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
  QuadWindow.CreateInput(QuadInput);
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
