program demo02;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;


procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(Random($FFFFFFFF));
  QuadRender.EndRender;
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo02 - Window');
  QuadWindow.SetSize(800, 600);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 200, True);

  QuadWindow.Start;
end.
