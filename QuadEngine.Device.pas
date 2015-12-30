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

unit QuadEngine.Device;

interface

{$INCLUDE QUADENGINE.INC}

uses
  Winapi.Windows, Winapi.Direct3D9, QuadEngine.Utils, QuadEngine.Log, Vec2f,
  QuadEngine.Render, System.IniFiles, QuadEngine, Classes, QuadEngine.Profiler;

const
  QuadVersion: PWideChar = 'Quad Engine v0.8.0 (Diamond)';

type
  PRenderTarget = ^TRenderTarget;
  TRenderTarget = record
    Texture: IQuadTexture;
    Reg: Byte;
    Width: Word;
    Height: Word;
  end;

  TQuadDevice = class(TInterfacedObject, IQuadDevice)
  private
    FActiveMonitorIndex: Byte;
    FD3D: IDirect3D9;
    FLastResultCode: HResult;
    FLog: TQuadLog;
    FRender: TQuadRender;
    FLastErrorText: PWideChar;
    FOnErrorFunction: TOnErrorFunction;
    FMaxTimerID: Cardinal;
    FRenderTargets: TList;
    FCursorSurface: IDirect3DSurface9;
    FIsHardwareCursor: Boolean;
    {$IFDEF DEBUG}
    //FProfiler: TQuadProfiler;
    {$ENDIF}
    procedure SetLastResultCode(const Value: HResult);
    procedure GetErrorTextByCode(AErrorCode: HResult);
    procedure SetOnErrorFunction(const Value: TOnErrorFunction);
  public
    constructor Create;
    destructor Destroy; override;
    procedure FreeRenderTargets;
    procedure ReInitializeRenderTargets;

    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar; out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateAndLoadTexture(ARegister: Byte; AFilename: PWideChar; out pQuadTexture: IQuadTexture;
      APatternWidth: Integer = 0; APatternHeight: Integer = 0; AColorKey : Integer = -1): HResult; stdcall;
    function CreateCamera(out pQuadCamera: IQuadCamera): HResult; stdcall;
    function CreateFont(out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateGBuffer(out pQuadGBuffer: IQuadGBuffer): HResult; stdcall;
    function CreateLog(out pQuadLog: IQuadLog): HResult; stdcall;
    function CreateShader(out pQuadShader: IQuadShader): HResult; stdcall;
    function CreateTexture(out pQuadTexture: IQuadTexture): HResult; stdcall;
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    function CreateTimerEx(out pQuadTimer: IQuadTimer; AProc: TTimerProcedure; AInterval: Word; IsEnabled: Boolean): HResult;
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function CreateWindow(out pQuadWindow: IQuadWindow): HResult; stdcall;
    function CreateProfiler(AName: PWideChar; out pQuadProfiler: IQuadProfiler): HResult; stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PWideChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;
    procedure ShowCursor(Show: Boolean); stdcall;
    procedure SetCursorPosition(x, y: integer); stdcall;
    procedure SetCursorProperties(XHotSpot, YHotSpot: Cardinal; Image: IQuadTexture); stdcall;

    property ActiveMonitorIndex: Byte read FActiveMonitorIndex;
    property D3D: IDirect3D9 read FD3D;
    property LastResultCode: HRESULT read FLastResultCode write SetLastResultCode;
    property Log: TQuadLog read FLog;
    property OnError: TOnErrorFunction read FOnErrorFunction write SetOnErrorFunction;
    property Render: TQuadRender read FRender;
    property IsHardwareCursor: Boolean read FIsHardwareCursor;
  end;

var
  Device: TQuadDevice;   // QuadDevice is global for all classes

implementation

uses
  System.SysUtils, QuadEngine.Font, QuadEngine.Shader, QuadEngine.Timer,
  QuadEngine.Texture, QuadEngine.Camera, QuadEngine.Window, QuadEngine.GBuffer;

{ TQuadDevice }

constructor TQuadDevice.Create;
var
  AD3DDM: TD3DDisplayMode;
  Aspect: Single;
  AspectString: string;
  MonitorsCount: Byte;
  i: Byte;
begin
  if Win32MajorVersion >= 6 then
    SetProcessDPIAware;

  FD3D := Direct3DCreate9(D3D_SDK_VERSION);

  FLog := TQuadLog.Create;
  if FLog <> nil then
    Flog.Write(QuadVersion);

  FActiveMonitorIndex := D3DADAPTER_DEFAULT;
  MonitorsCount := GetMonitorsCount;

  {$REGION 'Aspect Ratio'}
  if FLog <> nil then
  FLog.Write(PChar('Monitors Count: ' + IntToStr(MonitorsCount)));

  for i := 0 to MonitorsCount - 1 do
  begin
    LastResultCode := FD3D.GetAdapterDisplayMode(i, AD3DDM);

    Aspect := AD3DDM.Width / AD3DDM.Height;
    if IsSingleIn(Aspect, 1, 1.26) then AspectString := '5:4' else
    if IsSingleIn(Aspect, 1.26, 1.34) then AspectString := '4:3' else
    if IsSingleIn(Aspect, 1.34, 1.51) then AspectString := '15:10' else
    if IsSingleIn(Aspect, 1.51, 1.58) then AspectString := '14:9' else
    if IsSingleIn(Aspect, 1.58, 1.61) then AspectString := '16:10' else
    if IsSingleIn(Aspect, 1.61, 1.68) then AspectString := '15:9' else
    if IsSingleIn(Aspect, 1.68, 1.78) then AspectString := '16:9' else
    if IsSingleIn(Aspect, 1.78, 2.13) then AspectString := '16:7,5' else
      AspectString := FormatFloat('#.##', Aspect);


    AspectString := AspectString + ' ' + IntToStr(AD3DDM.Width) + 'x' + IntToStr(AD3DDM.Height);

    if AD3DDM.Height >= 1080 then
      AspectString := AspectString + ' (FullHD)';

    if FLog <> nil then
      FLog.Write(PChar('Monitor #' + IntToStr(i + 1) + ': ' + AspectString));
  end;
  {$ENDREGION}

  FRender := TQuadRender.Create;

  FMaxTimerID := 0;

  FRenderTargets := TList.Create;
  FIsHardwareCursor := False;
  {$IFDEF DEBUG}
  //FProfiler := TQuadProfiler.Create('Quad Device');
  {$ENDIF}
end;

destructor TQuadDevice.Destroy;
begin
  {$IFDEF DEBUG}
  //if Assigned(FProfiler) then
  // FProfiler.Free;
  {$ENDIF}

  FRenderTargets.Free;
  FD3D := nil;
end;

procedure TQuadDevice.FreeRenderTargets;
var
  RenderTarget: PRenderTarget;
begin
  for RenderTarget in FRenderTargets do
    RenderTarget.Texture.AddTexture(RenderTarget.Reg, nil);
end;

procedure TQuadDevice.ReInitializeRenderTargets;
var
  RenderTarget: PRenderTarget;
begin
  for RenderTarget in FRenderTargets do
    CreateRenderTarget(RenderTarget.Width, RenderTarget.Height, RenderTarget.Texture, RenderTarget.Reg);
end;

function TQuadDevice.GetMonitorsCount: Byte;
begin
  Result := FD3D.GetAdapterCount;
end;

procedure TQuadDevice.SetActiveMonitor(AMonitorIndex: Byte);
begin
  FActiveMonitorIndex := AMonitorIndex;
  if FActiveMonitorIndex > GetMonitorsCount - 1 then
    FActiveMonitorIndex := D3DADAPTER_DEFAULT;
end;

function TQuadDevice.GetLastError: PWideChar;
begin
  GetErrorTextByCode(LastResultCode);
  Result := FLastErrorText;
  FLastErrorText := '';
  FLastResultCode := 0;
end;

procedure TQuadDevice.SetLastResultCode(const Value: HRESULT);
begin
  if (Value = FLastResultCode) or (Value = D3D_OK) then
    Exit;

  FLastResultCode := Value;
  GetErrorTextByCode(FLastResultCode);

  if Assigned(OnError) then
    OnError(FLastErrorText);
end;

function TQuadDevice.GetIsResolutionSupported(AWidth, AHeight: Word): Boolean;
var
  AResolution: TCoord;
  i: Integer;
begin
  i := 0;
  repeat
    GetSupportedScreenResolution(i, AResolution);
    Result := (Integer(AResolution.X) = Integer(AWidth)) and (Integer(AResolution.Y) = Integer(AHeight));
    Inc(i);
  until Result or (AResolution.X = -1);
end;

procedure TQuadDevice.GetErrorTextByCode(AErrorCode: HRESULT);
begin
  case AErrorCode of
    D3D_OK                          : FLastErrorText := 'No errors.';
    D3DERR_WRONGTEXTUREFORMAT       : FLastErrorText := 'The pixel format of the texture surface is not valid.';
    D3DERR_UNSUPPORTEDCOLOROPERATION: FLastErrorText := 'The device does not support a specified texture-blending operation for color values.';
    D3DERR_UNSUPPORTEDCOLORARG      : FLastErrorText := 'The device does not support a specified texture-blending argument for color values.';
    D3DERR_UNSUPPORTEDALPHAOPERATION: FLastErrorText := 'The device does not support a specified texture-blending operation for the alpha channel.';
    D3DERR_UNSUPPORTEDALPHAARG      : FLastErrorText := 'The device does not support a specified texture-blending argument for the alpha channel.';
    D3DERR_TOOMANYOPERATIONS        : FLastErrorText := 'The application is requesting more texture-filtering operations than the device supports.';
    D3DERR_CONFLICTINGTEXTUREFILTER : FLastErrorText := 'The current texture filters cannot be used together.';
    D3DERR_CONFLICTINGRENDERSTATE   : FLastErrorText := 'The currently set render states cannot be used together.';
    D3DERR_UNSUPPORTEDTEXTUREFILTER : FLastErrorText := 'The device does not support the specified texture filter.';
    D3DERR_CONFLICTINGTEXTUREPALETTE: FLastErrorText := 'The current textures cannot be used simultaneously.';
    D3DERR_DRIVERINTERNALERROR      : FLastErrorText := 'Internal driver error.';
    D3DERR_NOTFOUND                 : FLastErrorText := 'The requested item was not found.';
    D3DERR_MOREDATA                 : FLastErrorText := 'There is more data available than the specified buffer size can hold.';
    D3DERR_DEVICELOST               : FLastErrorText := 'The device has been lost but cannot be reset at this time. ';
    D3DERR_DEVICENOTRESET           : FLastErrorText := 'The device has been lost but can be reset at this time.';
    D3DERR_NOTAVAILABLE             : FLastErrorText := 'This device does not support the queried technique.';
    D3DERR_OUTOFVIDEOMEMORY         : FLastErrorText := 'Direct3D does not have enough display memory to perform the operation.';
    D3DERR_INVALIDDEVICE            : FLastErrorText := 'The requested device type is not valid.';
    D3DERR_INVALIDCALL              : FLastErrorText := 'The method call is invalid.';
    D3DERR_WASSTILLDRAWING          : FLastErrorText := 'The previous blit operation that is transferring information to or from this surface is incomplete.';
    E_FAIL                          : FLastErrorText := 'An undetermined error occurred inside the Direct3D subsystem.';
    E_INVALIDARG                    : FLastErrorText := 'An invalid parameter was passed to the returning function.';
    E_NOINTERFACE                   : FLastErrorText := 'No object interface is available.';
    E_NOTIMPL                       : FLastErrorText := 'Not implemented.';
    E_OUTOFMEMORY                   : FLastErrorText := 'Direct3D could not allocate sufficient memory to complete the call.';
  else
    FLastErrorText := PWideChar('Unknown error. Code ' + IntToStr(FLastResultCode));
  end;

  if Assigned(FLog) then
    FLog.Write(PChar('Error: ' + FLastErrorText));
end;

procedure TQuadDevice.SetOnErrorFunction(const Value: TOnErrorFunction);
begin
  FOnErrorFunction := Value;
end;

procedure TQuadDevice.SetOnErrorCallBack(Proc: TOnErrorFunction);
begin
  FOnErrorFunction := Proc;
end;

procedure TQuadDevice.GetSupportedScreenResolution(index: Integer; out Resolution: TCoord);
var
  ADevMode: DEVMODE;
begin
  if EnumDisplaySettings(nil, index, ADevMode) then
  begin
    Resolution.X := ADevMode.dmPelsWidth;
    Resolution.Y := ADevMode.dmPelsHeight;
  end
  else
  begin
    Resolution.X := -1;
    Resolution.Y := -1;
  end;
end;

function TQuadDevice.CreateFont(out pQuadFont: IQuadFont): HResult;
begin
  pQuadFont := TQuadFont.Create(FRender);

  if Assigned(pQuadFont) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateGBuffer(out pQuadGBuffer: IQuadGBuffer): HResult;
begin
  pQuadGBuffer := TQuadGBuffer.Create(FRender);

  if Assigned(pQuadGBuffer) then
    Result := S_OK
  else
    Result := E_FAIL;
end;


function TQuadDevice.CreateLog(out pQuadLog: IQuadLog): HResult;
begin
  if not Assigned(FLog) then
    FLog := TQuadLog.Create;

  pQuadLog := FLog;
  pQuadLog._AddRef;

  if Assigned(pQuadLog) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateShader(out pQuadShader: IQuadShader): HResult;
begin
  pQuadShader := TQuadShader.create(FRender);

  if Assigned(pQuadShader) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateTexture(out pQuadTexture: IQuadTexture): HResult;
begin
  pQuadTexture := TQuadTexture.create(FRender);

  if Assigned(pQuadTexture) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateTimer(out pQuadTimer: IQuadTimer): HResult;
var
  Timer: TQuadTimer;
begin
  inc(FMaxTimerID);
  Timer := TQuadTimer.create;
  Timer.Id := FMaxTimerID;
  pQuadTimer := Timer;

  if Assigned(pQuadTimer) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateTimerEx(out pQuadTimer: IQuadTimer; AProc: TTimerProcedure; AInterval: Word; IsEnabled: Boolean): HResult;
begin
  Result := CreateTimer(pQuadTimer);
  pQuadTimer.SetCallBack(AProc);
  pQuadTimer.SetInterval(AInterval);
  pQuadTimer.SetState(IsEnabled);
end;

function TQuadDevice.CreateWindow(out pQuadWindow: IQuadWindow): HResult;
begin
  pQuadWindow := TQuadWindow.Create;

  if Assigned(pQuadWindow) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateProfiler(AName: PWideChar; out pQuadProfiler: IQuadProfiler): HResult; stdcall;
begin
  pQuadProfiler := TQuadProfiler.Create(AName);
  if Assigned(pQuadProfiler) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar;
  out pQuadFont: IQuadFont): HResult;
begin
  Result := CreateFont(pQuadFont);
  pQuadFont.LoadFromFile(AFontTextureFilename, AUVFilename);
end;

function TQuadDevice.CreateAndLoadTexture(ARegister: Byte;
  AFilename: PWideChar; out pQuadTexture: IQuadTexture; APatternWidth, APatternHeight,
  AColorKey: Integer): HResult;
begin
  Result := CreateTexture(pQuadTexture);
  pQuadTexture.LoadFromFile(ARegister, AFilename, APatternWidth, APatternHeight, AColorKey);
end;

function TQuadDevice.CreateCamera(out pQuadCamera: IQuadCamera): HResult;
begin
  pQuadCamera := TQuadCamera.Create(FRender);

  if Assigned(pQuadCamera) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadDevice.CreateRender(out pQuadRender: IQuadRender): HResult;
begin
  pQuadRender := FRender;

  if Assigned(pQuadRender) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

//=============================================================================
// Create render target
//=============================================================================
procedure TQuadDevice.CreateRenderTarget(AWidth, AHeight: Word;
  var AQuadTexture: IQuadTexture; ARegister: Byte);
var
  Target: IDirect3DTexture9;
  RenderTarget : PRenderTarget;
begin
  if ((AWidth mod 4) > 0) or ((AHeight mod 4) > 0) then
    Exception.Create('RenderTarget size must be scale of 4.');

  if AQuadTexture = nil then
  begin
    Device.CreateTexture(AQuadTexture);

    New(RenderTarget);
    RenderTarget.Texture := AQuadTexture;
    RenderTarget.Reg := ARegister;
    RenderTarget.Width := AWidth;
    RenderTarget.Height := AHeight;
    FRenderTargets.Add(RenderTarget);
  end;

  Device.LastResultCode := FRender.D3DDevice.CreateTexture(AWidth, AHeight, 1,
                                             D3DUSAGE_RENDERTARGET or D3DUSAGE_AUTOGENMIPMAP,  // with mipmaps
                                             D3DFMT_A8R8G8B8,
                                             D3DPOOL_DEFAULT,
                                             Target,
                                             nil);

  AQuadTexture.AddTexture(ARegister, Target);

  AQuadTexture.SetIsLoaded(AWidth, AHeight);
end;

procedure TQuadDevice.ShowCursor(Show: Boolean);
begin
  FIsHardwareCursor := Show;

  if not IsHardwareCursor then
    FRender.D3DDevice.ShowCursor(False);
end;

procedure TQuadDevice.SetCursorPosition(x, y: Integer);
begin
  FRender.D3DDevice.SetCursorPosition(x, y, D3DCURSOR_IMMEDIATE_UPDATE);
end;

procedure TQuadDevice.SetCursorProperties(XHotSpot, YHotSpot: Cardinal; Image: IQuadTexture);
begin
  Image.GetTexture(0).GetSurfaceLevel(0, FCursorSurface);
  FRender.D3DDevice.SetCursorProperties(XHotSpot, YHotSpot, FCursorSurface);
end;

end.
