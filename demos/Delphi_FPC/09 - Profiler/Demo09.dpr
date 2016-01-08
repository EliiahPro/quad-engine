program demo09;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f, System.SysUtils;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  QuadInput: IQuadInput;

  QuadProfiler: IQuadProfiler;
  QuadProfilerTag: IQuadProfilerTag;
  QuadProfilerTag2: IQuadProfilerTag;

  Points: array[0..999] of TVec2f;
  PointCount: Integer = 0;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i: Integer;
  MousePosition: TVec2f;
begin
  QuadProfiler.BeginTick;
  QuadProfilerTag2.BeginCount;
  QuadInput.Update;
  QuadInput.GetMousePosition(MousePosition);

  if QuadInput.IsMouseDown(mbLeft) and (PointCount < 1000) then
  begin
    Points[PointCount] := MousePosition;
    Inc(PointCount);
  end;


  if QuadInput.IsMouseClick(mbRight) then
    QuadProfiler.SendMessage('Mouse right button press', pmtMessage);

  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);
  QuadProfilerTag.BeginCount;

  for i := 0 to PointCount - 1 do
    QuadRender.DrawCircle(Points[i], 6, 5, $FFAAAAAA);

  QuadProfilerTag.EndCount;
  QuadRender.EndRender;
  QuadProfilerTag2.EndCount;
  QuadProfiler.EndTick;
end;

procedure OnClose; stdcall;
begin
  QuadTimer.SetState(False);

  QuadProfiler := nil;

  QuadTimer := nil;
  QuadRender := nil;
  QuadWindow := nil;
  QuadDevice := nil;
end;

begin
  QuadDevice := CreateQuadDevice;
  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.CreateInput(QuadInput);
  QuadWindow.SetOnClose(OnClose);
  QuadWindow.SetCaption('QuadEngine - Demo09 - Profiler');
  QuadWindow.SetSize(800, 600);
  QuadWindow.SetPosition(100, 100);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateProfiler('Demo 09 - Profiler', QuadProfiler);
  QuadProfiler.SetGUID(StringToGUID('{AFEBAB39-0D7C-40A4-AA2C-122F3E8950C1}'));
  QuadProfiler.CreateTag('Line 01', QuadProfilerTag);
  QuadProfiler.CreateTag('Line 02', QuadProfilerTag2);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
