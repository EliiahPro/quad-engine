program demo03;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

{$R *.res}

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
  QuadWindow.SetCaption('Quad-engine window demo');
  QuadWindow.SetSize(800, 600);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimer(QuadTimer);
  QuadTimer.SetInterval(200);
  QuadTimer.SetCallBack(OnTimer);
  QuadTimer.SetState(True);

  QuadWindow.Start;
end.
