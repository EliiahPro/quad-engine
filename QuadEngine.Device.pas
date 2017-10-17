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
  QuadEngine.Render, System.IniFiles, QuadEngine, Classes, vcl.graphics;

const
  QuadVersion: PWideChar = 'Quad Engine v0.9.0 (Diamond)';

type
  PRenderTarget = ^TRenderTarget;
  TRenderTarget = record
    Texture: IQuadTexture;
    Reg: Byte;
    Width: Word;
    Height: Word;
    IsAlive: Boolean;
    Format: TQuadTextureFormat;
  end;

  TQuadDevice = class(TInterfacedObject, IQuadDevice)
  private
    FActiveMonitorIndex: Byte;
    FD3D: IDirect3D9;
    FLastResultCode: HResult;
    FLog: IQuadLog;
    FRender: TQuadRender;
    FLastErrorText: PWideChar;
    FOnErrorFunction: TOnErrorFunction;
    FMaxTimerID: Cardinal;
    FRenderTargets: TList;
    FCursorSurface: IDirect3DSurface9;
    FIsHardwareCursor: Boolean;
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
    function CreateTextureFromRenderTarget(ARenderTarget: IQuadTexture; out pQuadTexture: IQuadTexture): HResult; stdcall;
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    function CreateTimerEx(out pQuadTimer: IQuadTimer; AProc: TTimerProcedure; AInterval: Word; IsEnabled: Boolean): HResult; stdcall;
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte; AFormat: TQuadTextureFormat = qtfA8R8G8B8); stdcall;
    function CreateWindow(out pQuadWindow: IQuadWindow): HResult; stdcall;
    function CreateProfiler(AName: PWideChar; out pQuadProfiler: IQuadProfiler): HResult; stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PWideChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;
    procedure ShowCursor(Show: Boolean); stdcall;
    procedure SetCursorPosition(x, y: Integer); stdcall;
    procedure SetCursorProperties(XHotSpot, YHotSpot: Cardinal; const Image: IQuadTexture); stdcall;

    property ActiveMonitorIndex: Byte read FActiveMonitorIndex;
    property D3D: IDirect3D9 read FD3D;
    property LastResultCode: HRESULT read FLastResultCode write SetLastResultCode;
    property Log: IQuadLog read FLog;
    property OnError: TOnErrorFunction read FOnErrorFunction write SetOnErrorFunction;
    property Render: TQuadRender read FRender;
    property IsHardwareCursor: Boolean read FIsHardwareCursor;
  end;

var
  Device: TQuadDevice;   // QuadDevice is global for all classes

implementation

uses
  System.SysUtils, QuadEngine.Font, QuadEngine.Shader, QuadEngine.Timer,
  QuadEngine.Texture, QuadEngine.Camera, QuadEngine.Window, QuadEngine.GBuffer,
  QuadEngine.Profiler;

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
end;

destructor TQuadDevice.Destroy;
var
  i: Integer;
begin
  for i := FRenderTargets.Count - 1 downto 0 do
    Dispose(FRenderTargets[i]);
  FRenderTargets.Free;
  FLog := nil;
  FD3D := nil;
end;

procedure TQuadDevice.FreeRenderTargets;
var
  RenderTarget: PRenderTarget;
begin
  for RenderTarget in FRenderTargets do
  begin
    if TInterfacedObject(RenderTarget.Texture).RefCount = 0 then
       RenderTarget.IsAlive := False
     else
      RenderTarget.Texture.AddTexture(RenderTarget.Reg, nil);
  end;
end;

procedure TQuadDevice.ReInitializeRenderTargets;
var
  RenderTarget: PRenderTarget;
begin
  for RenderTarget in FRenderTargets do
    if RenderTarget.IsAlive then
      CreateRenderTarget(RenderTarget.Width, RenderTarget.Height, RenderTarget.Texture, RenderTarget.Reg, RenderTarget.Format);
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
  Count: Integer;
  FD3DDM: TD3DDisplayMode;
begin
  FD3D.GetAdapterDisplayMode(Device.ActiveMonitorIndex, FD3DDM);
  Count := FD3D.GetAdapterModeCount(FActiveMonitorIndex, FD3DDM.Format);
  for i := 0 to Count - 1 do
  begin
    GetSupportedScreenResolution(i, AResolution);
    Result := (Integer(AResolution.X) = Integer(AWidth)) and (Integer(AResolution.Y) = Integer(AHeight));
    if Result then
      Break;
  end;
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
  AD3DDM: TD3DDisplayMode;
  FD3DDM: TD3DDisplayMode;
begin
  FD3D.GetAdapterDisplayMode(Device.ActiveMonitorIndex, FD3DDM);
  if FD3D.EnumAdapterModes(FActiveMonitorIndex, FD3DDM.Format, index, AD3DDM) = D3D_OK then
  begin
    Resolution.X := AD3DDM.Width;
    Resolution.Y := AD3DDM.Height;
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

function TQuadDevice.CreateTextureFromRenderTarget(ARenderTarget: IQuadTexture; out pQuadTexture: IQuadTexture): HResult; stdcall;
var
  surface: IDirect3DSurface9;
  surfaceDest: IDirect3DSurface9;
  aData : TD3DLockedRect;
begin
  CreateTexture(pQuadTexture);

  Device.LastResultCode := ARenderTarget.GetTexture(0).GetSurfaceLevel(0, surface);
  Device.LastResultCode := Render.D3DDevice.CreateOffscreenPlainSurface(ARenderTarget.GetTextureWidth, ARenderTarget.GetTextureHeight, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, surfaceDest, nil);
  Device.LastResultCode := Render.D3DDevice.GetRenderTargetData(surface, surfaceDest);

  Device.LastResultCode := surfaceDest.LockRect(aData, nil, D3DLOCK_READONLY or D3DLOCK_NO_DIRTY_UPDATE or D3DLOCK_NOSYSLOCK);
  pQuadTexture.LoadFromRAW(0, aData.pBits, ARenderTarget.GetTextureWidth, ARenderTarget.GetTextureHeight, rdfARGB8);
  Device.LastResultCode := surfaceDest.UnlockRect;

  if Assigned(pQuadTexture) then
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

function TQuadDevice.CreateProfiler(AName: PWideChar; out pQuadProfiler: IQuadProfiler): HResult;
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
  var AQuadTexture: IQuadTexture; ARegister: Byte; AFormat: TQuadTextureFormat = qtfA8R8G8B8);
var
  Target: IDirect3DTexture9;
  RenderTarget: PRenderTarget;
  fmt: TD3DFormat;
begin
//  if ((AWidth mod 4) > 0) or ((AHeight mod 4) > 0) then
//    Log.Write('HINT: RenderTarget size must be scale of 4.');

  if not Assigned(FRender) then
  begin
    Log.Write('ERROR: CreateRenderTarget called before QuadRender was initialized');
    Exit;
  end;

  if AQuadTexture = nil then
  begin
    Device.CreateTexture(AQuadTexture);
  end;

  case AFormat of
    qtfA8R8G8B8 : fmt := D3DFMT_A8R8G8B8;
    qtfR5G6B5   : fmt := D3DFMT_R5G6B5;
    qtfD16      : fmt := D3DFMT_D16;
    qtfD32      : fmt := D3DFMT_D32;
    qtfG16R16   : fmt := D3DFMT_G16R16;
  end;
  
  if not Render.IsDeviceLost then
  begin
    New(RenderTarget);
    RenderTarget.Texture := AQuadTexture;
    RenderTarget.Texture._Release;
    RenderTarget.Reg := ARegister;
    RenderTarget.Width := AWidth;
    RenderTarget.Height := AHeight;
    RenderTarget.IsAlive := True;
    RenderTarget.Format := AFormat;
    FRenderTargets.Add(RenderTarget);
  end;

  Device.LastResultCode := FRender.D3DDevice.CreateTexture(AWidth, AHeight, 0,
                                             D3DUSAGE_RENDERTARGET or D3DUSAGE_AUTOGENMIPMAP,  // with mipmaps
                                             fmt,
                                             D3DPOOL_DEFAULT,
                                             Target,
                                             nil);

  AQuadTexture.AddTexture(ARegister, Target);

  AQuadTexture.SetIsLoaded(AWidth, AHeight);
end;

procedure TQuadDevice.ShowCursor(Show: Boolean);
begin
  if Assigned(FRender) then
  begin
    FIsHardwareCursor := Show;

    if not IsHardwareCursor then
      FRender.D3DDevice.ShowCursor(False);
  end
  else
    Log.Write('ERROR: ShowCursor called before QuadRender was initialized');
end;

procedure TQuadDevice.SetCursorPosition(x, y: Integer);
begin
  if Assigned(FRender) then
    FRender.D3DDevice.SetCursorPosition(x, y, D3DCURSOR_IMMEDIATE_UPDATE)
  else
    Log.Write('ERROR: SetCursorPosition called before QuadRender was initialized');
end;

procedure TQuadDevice.SetCursorProperties(XHotSpot, YHotSpot: Cardinal; const Image: IQuadTexture);
begin
  if Assigned(FRender) then
  begin
    if Assigned(Image) then
    begin
      Image.GetTexture(0).GetSurfaceLevel(0, FCursorSurface);
      LastResultCode := FRender.D3DDevice.SetCursorProperties(XHotSpot, YHotSpot, FCursorSurface);
    end
    else
      FRender.D3DDevice.ShowCursor(False);

    if LastResultCode <> D3D_OK then
      Log.Write('Failed to set hardware cursor');
  end
  else
    Log.Write('ERROR: SetCursorProperties called before QuadRender was initialized');
end;

end.
