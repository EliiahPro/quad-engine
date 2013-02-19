//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================

unit QuadEngine.Device;

interface

uses
  Winapi.Windows, Winapi.Direct3D9, QuadEngine.Utils, QuadEngine.Log, Vec2f,
  QuadEngine.Render, System.IniFiles, QuadEngine;

const
  QuadVersion: PAnsiChar = 'Quad Engine v0.5.0';

type
  TQuadDevice = class(TInterfacedObject, IQuadDevice)
  private
    FActiveMonitorIndex: Byte;
    FD3D: IDirect3D9;
    FLastResultCode: HResult;
    FLog: TQuadLog;
    FRender: TQuadRender;
    FLastErrorText: PAnsiChar;
    FOnErrorFunction: TOnErrorFunction;
    procedure SetLastResultCode(const Value: HResult);
    procedure GetErrorTextByCode(AErrorCode: HResult);
    procedure SetOnErrorFunction(const Value: TOnErrorFunction);
  public
    constructor Create;
    destructor Destroy; override;

    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar; out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateAndLoadTexture(ARegister: Byte; AFilename: PAnsiChar; out pQuadTexture: IQuadTexture;
      APatternWidth: Integer = 0; APatternHeight: Integer = 0; AColorKey : Integer = -1): HResult; stdcall;
    function CreateCamera(out pQuadCamera: IQuadCamera): HResult; stdcall;
    function CreateFont(out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateShader(out pQuadShader: IQuadShader): HResult; stdcall;
    function CreateTexture(out pQuadTexture: IQuadTexture): HResult; stdcall;
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PAnsiChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;

    property ActiveMonitorIndex: Byte read FActiveMonitorIndex;
    property D3D: IDirect3D9 read FD3D;
    property LastResultCode: HRESULT read FLastResultCode write SetLastResultCode;
    property Log: TQuadLog read FLog;
    property OnError: TOnErrorFunction read FOnErrorFunction write SetOnErrorFunction;
  end;

var
  Device: TQuadDevice;   // QuadDevice is global for all classes

implementation

uses
  System.SysUtils, QuadEngine.Font, QuadEngine.Shader, QuadEngine.Timer,
  QuadEngine.Texture, QuadEngine.Camera;

{ TQuadDevice }

constructor TQuadDevice.Create;
var
  AD3DDM: TD3DDisplayMode;
  Aspect: Single;
  AspectString: String;
  MonitorsCount: Byte;
  i: Byte;
begin
  FD3D := Direct3DCreate9(D3D_SDK_VERSION);

  FLog := TQuadLog.Create;
  if FLog <> nil then
    Flog.Write(QuadVersion);

  FActiveMonitorIndex := D3DADAPTER_DEFAULT;
  MonitorsCount := GetMonitorsCount;

  {$REGION 'Aspect Ratio'}
  if FLog <> nil then
  FLog.Write('Monitors Count: ' + IntToStr(MonitorsCount));

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
      FLog.Write('Monitor #' + IntToStr(i + 1) + ': ' + AspectString);
  end;
  {$ENDREGION}

  FRender := TQuadRender.Create;
end;

destructor TQuadDevice.Destroy;
begin
  Log.Free;
  FD3D := nil;
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

function TQuadDevice.GetLastError: PAnsiChar;
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
    Result := (AResolution.X = AWidth) and (AResolution.Y = AHeight);
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
    FLastErrorText := PAnsiChar('Unknown error. Code ' + IntToStr(FLastResultCode));
  end;

  if FLog <> nil then        {todo : why that?}
    FLog.Write('Error: ' + FLastErrorText);
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
end;

function TQuadDevice.CreateShader(out pQuadShader: IQuadShader): HResult;
begin
  pQuadShader := TQuadShader.create(FRender);
end;

function TQuadDevice.CreateTexture(out pQuadTexture: IQuadTexture): HResult;
begin
  pQuadTexture := TQuadTexture.create(FRender);
end;

function TQuadDevice.CreateTimer(out pQuadTimer: IQuadTimer): HResult;
begin
  pQuadTimer := TQuadTimer.create;
end;

function TQuadDevice.CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar;
  out pQuadFont: IQuadFont): HResult; stdcall;
begin
  pQuadFont := TQuadFont.Create(FRender);
  pQuadFont.LoadFromFile(AFontTextureFilename, AUVFilename);
end;

function TQuadDevice.CreateAndLoadTexture(ARegister: Byte;
  AFilename: PAnsiChar; out pQuadTexture: IQuadTexture; APatternWidth, APatternHeight,
  AColorKey: Integer): HResult;
begin
  pQuadTexture := TQuadTexture.Create(FRender);
  pQuadTexture.LoadFromFile(ARegister, AFilename, APatternWidth, APatternHeight, AColorKey);
end;

function TQuadDevice.CreateCamera(out pQuadCamera: IQuadCamera): HResult;
begin
  pQuadCamera := TQuadCamera.create(FRender);
end;

function TQuadDevice.CreateRender(out pQuadRender: IQuadRender): HResult;
begin
  pQuadRender := FRender;
end;

//=============================================================================
// Create render target
//=============================================================================
procedure TQuadDevice.CreateRenderTarget(AWidth, AHeight: Word;
  var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
var
  Target: IDirect3DTexture9;
begin
  if AQuadTexture = nil then
    Device.CreateTexture(AQuadTexture);

  Device.LastResultCode := FRender.D3DDevice.CreateTexture(AWidth, AHeight, 1,
                                             D3DUSAGE_RENDERTARGET or D3DUSAGE_AUTOGENMIPMAP,  // with mipmaps
                                             D3DFMT_A8R8G8B8,                                  // 8888 ARGB format
                                             D3DPOOL_DEFAULT,
                                             Target,
                                             nil);

  AQuadTexture.AddTexture(ARegister, Target);

  AQuadTexture.SetIsLoaded(AWidth, AHeight);
end;

end.
