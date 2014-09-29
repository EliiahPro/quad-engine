//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//
// For license see COPYING
//=============================================================================

unit QuadEngine.Timer;

interface

uses
  Windows, messages, classes, QuadEngine;

type
  TQuadTimer = class;

  TTimerThread = class(TThread)
  private
    FInterval: Word;
    FOwner: TQuadTimer;
  protected
    procedure Execute; override;
    property Interval: Word read FInterval write FInterval;
  end;

  TQuadTimer = class(TInterfacedObject, IQuadTimer)
  strict private
    FCPULoad: Single;
    FCPUTotalTime: Int64;
    FFPS: Single;
    FFramesRendered: Word;
    FId: Cardinal;
    FIsEnabled: Boolean;
    FOnTimer: TTimerProcedure;
    FPerformanceFrequency: Int64;
    FPerformanceLastCounter: Int64;
    FPerformanceCounter: Int64;
    FThread: TTimerThread;
    FTimeSpent: Double;
    FTime: Double;
    FTimeDeltaFPSCounter: Double;
    FWholeTime: Double;
  private
    FTimeSpentOnTick: Double;
  public
    constructor Create;
    destructor Destroy; override;

    function GetCPUload: Single; stdcall;
    function GetFPS: Single; stdcall;
    function GetDelta: Double; stdcall;
    function GetWholeTime: Double; stdcall;
    function GetTimerID: Cardinal; stdcall;
    procedure ResetWholeTimeCounter; stdcall;
    procedure SetInterval(AInterval: Word); stdcall;
    procedure SetCallBack(AProc: TTimerProcedure); stdcall;
    procedure SetState(AIsEnabled: Boolean); stdcall;
    procedure Timer;
    procedure Tick;
    property OnTimer: TTimerProcedure read FOnTimer write FOnTimer;
    property Id: Cardinal read FId write FId;
  end;

implementation

uses
  Math;

{ TQuadTimer }

//=============================================================================
//
//=============================================================================
constructor TQuadTimer.create;
begin
  inherited;

  QueryPerformanceFrequency(FPerformanceFrequency);
  QueryPerformanceCounter(FPerformanceCounter);
  FPerformanceLastCounter := FPerformanceCounter;
  FFramesRendered := 0;
  FTimeSpent := 0.0;
  FTime := 0.0;
  FTimeDeltaFPSCounter := 0.0;
  FFPS := 0.0;
  FWholeTime := 0.0;

  FThread := TTimerThread.Create(False);
  FThread.FOwner := Self;
  FThread.FreeOnTerminate := True;
  FThread.Priority := tpNormal;
  FThread.Interval := 0;
end;

//=============================================================================
//
//=============================================================================
destructor TQuadTimer.Destroy;
begin
  FThread.Terminate;

  inherited;
end;

//=============================================================================
//
//=============================================================================
function TQuadTimer.GetCPUload: Single;
begin
  Result := Min(FCPULoad, 100.0); // This prevent getting values more than 100.0
end;

//=============================================================================
//
//=============================================================================
function TQuadTimer.GetDelta: double;
begin
  Result := FTimeSpent;
end;

//=============================================================================
//
//=============================================================================
function TQuadTimer.GetFPS: single;
begin
  Result := FFPS;
end;

//=============================================================================
//
//=============================================================================
function TQuadTimer.GetTimerID: Cardinal;
begin
  Result := FId;
end;

//=============================================================================
//
//=============================================================================
function TQuadTimer.GetWholeTime: Double;
var
  APerformanceCounter : Int64;
begin
  QueryPerformanceCounter(APerformanceCounter);
  Result := FWholeTime + (APerformanceCounter - FPerformanceLastCounter) / FPerformanceFrequency;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.ResetWholeTimeCounter;
begin
  FWholeTime := 0;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.SetCallBack(AProc: TTimerProcedure);
begin
  FOnTimer := AProc;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.SetInterval(AInterval: Word);
begin
  FThread.Interval := AInterval;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.SetState(AIsEnabled: Boolean);
begin
  if AIsEnabled = FIsEnabled then
    Exit;

  FIsEnabled := AIsEnabled;
  if AIsEnabled then
  begin
    QueryPerformanceCounter(FPerformanceLastCounter);
    QueryPerformanceCounter(FPerformanceCounter);
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.Tick;
var
  mCreationTime, mExitTime, mKernelTime, mUserTime : _FILETIME;
  TempTime : Int64;
begin
  FPerformanceLastCounter := FPerformanceCounter;
  QueryPerformanceCounter(FPerformanceCounter);

  FTime := FTime + (FPerformanceCounter - FPerformanceLastCounter) / FPerformanceFrequency;
  FTimeSpent := (FPerformanceCounter - FPerformanceLastCounter) / FPerformanceFrequency;
  FWholeTime := FWholeTime + FTimeSpent;
  FFramesRendered := FFramesRendered + 1;

  if FTime >= 1.0 then
  begin
    FFPS := FFramesRendered / (FTime {+ FTimeDeltaFPSCounter});

    {$REGION 'CPU load %'}
    GetThreadTimes(GetCurrentThread, mCreationTime, mExitTime, mKernelTime, mUserTime);
    TempTime := int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32)) +
                int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));

    FCPULoad := (TempTime - FCPUTotalTime) / (FTime * 1000) / 100;

    FCPUTotalTime := TempTime;
    {$ENDREGION}

    FTime := FTime - 1.0;
    FTimeDeltaFPSCounter := FTime;
    FFramesRendered := 0;
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTimer.Timer;
var
  Timestart, TimeEnd : Int64;
begin
  if not FIsEnabled then
    Exit;
  
  QueryPerformanceCounter(TimeStart);

  Tick;

  if Assigned(FOnTimer) then
  begin
    try
      FOnTimer(FTimeSpent, FId);
    except
      //
    end;
  end;

  QueryPerformanceCounter(TimeEnd);
  FTimeSpentOnTick := (TimeEnd - TimeStart) / FPerformanceFrequency;
end;

{ TTimerThread }

//=============================================================================
//
//=============================================================================
procedure TTimerThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    if (FInterval - Round(FOwner.FTimeSpentOnTick * 1000)) > 0 then
      WaitForSingleObject(Self.Handle, FInterval - Round(FOwner.FTimeSpentOnTick * 1000));

    FOwner.Timer;
  end;

end;

end.
