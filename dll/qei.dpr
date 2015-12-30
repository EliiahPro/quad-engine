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
// for license see COPYING
//=============================================================================

//Theory is - when you know everything but nothing works.
//Practice is - when all works, but you don't know why.
//We combine theory and practice - nothing works and nobody knows why

library qei;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

{$INCLUDE QuadEngine.inc}

{$R 'Shaders.res' 'Shaders.rc'}

uses
  Windows,
  SysUtils,
  QuadEngine in '..\headers\Delphi_FPC\QuadEngine.pas',
  QuadEngine.Device in '..\QuadEngine.Device.pas',
  QuadEngine.Font in '..\QuadEngine.Font.pas',
  QuadEngine.GBuffer in '..\QuadEngine.GBuffer.pas',  
  QuadEngine.Log in '..\QuadEngine.Log.pas',
  QuadEngine.Render in '..\QuadEngine.Render.pas',
  QuadEngine.Shader in '..\QuadEngine.Shader.pas',
  QuadEngine.Texture in '..\QuadEngine.Texture.pas',
  QuadEngine.TextureLoader in '..\QuadEngine.TextureLoader.pas',
  QuadEngine.Timer in '..\QuadEngine.Timer.pas',
  QuadEngine.Utils in '..\QuadEngine.Utils.pas',
  QuadEngine.Window in '..\QuadEngine.Window.pas',
  QuadEngine.Input in '..\QuadEngine.Input.pas',
  QuadEngine.Camera in '..\QuadEngine.Camera.pas',
  QuadEngine.Color in '..\headers\Delphi_FPC\QuadEngine.Color.pas',
  Vec2f in '..\headers\Delphi_FPC\Vec2f.pas',
  BeRoDDS in '..\BeRoDDS.pas'
  {$IFDEF DEBUG}
, QuadEngine.Profiler in '..\QuadEngine.Profiler.pas',
  QuadEngine.Socket in '..\QuadEngine.Socket.pas'
  {$ENDIF};

{$R *.res}

procedure CreateQuadDeviceEx(out ADevice: Pointer); stdcall;
var
  QD: IQuadDevice;
begin
  QD := TQuadDevice.Create;
  QD._AddRef;
  ADevice := Pointer(QD);
end;

function CreateQuadDevice(out AQuadDevice: IQuadDevice): HResult; stdcall;
begin
  Device := TQuadDevice.Create;
  AQuadDevice := Device;

  if Assigned(Device) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function IsSameVersion(ARelease, AMajor, AMinor: Byte): Boolean; stdcall;
begin
  Result := (ARelease = QuadEngineReleaseVersion) and
            (AMajor = QuadEngineMajorVersion) and
            (AMinor = QuadEngineMinorVersion);

  if not Result then
    raise Exception.Create('Quad Engine version and header version does not match!');
end;

function SecretMagicFunction: PWideChar; stdcall;
begin
  Result := 'Theory is - when you know everything but nothing works.'#13 +
            'Practice is - when all works, but you don''t know why.'#13 +
            'We combine theory and practice - nothing works and nobody knows why.';
end;

exports
  CreateQuadDeviceEx,
  CreateQuadDevice,
  IsSameVersion,
  SecretMagicFunction;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
