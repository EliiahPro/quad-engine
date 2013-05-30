//Theory is - when you know everything but nothing works.
//Practice is - when all works, but you don't know why.
//We combine theory and practice - nothing works and nobody knows why

library qei;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

//{$DEFINE DEBUG}

{$R 'Shaders.res' 'Shaders.rc'}

uses
  Windows,
  QuadEngine in '..\QuadEngine.pas',
  QuadEngine.Device in '..\QuadEngine.Device.pas',
  QuadEngine.Font in '..\QuadEngine.Font.pas',
  QuadEngine.Log in '..\QuadEngine.Log.pas',
  QuadEngine.Render in '..\QuadEngine.Render.pas',
  QuadEngine.Shader in '..\QuadEngine.Shader.pas',
  QuadEngine.Sprite in '..\QuadEngine.Sprite.pas',
  QuadEngine.Texture in '..\QuadEngine.Texture.pas',
  QuadEngine.Timer in '..\QuadEngine.Timer.pas',
  QuadEngine.Utils in '..\QuadEngine.Utils.pas',
  QuadEngine.Window in '..\QuadEngine.Window.pas',
  QuadEngine.Camera in '..\QuadEngine.Camera.pas',
  Vec2f in '..\Vec2f.pas',
  QuadEngine.Color in '..\QuadEngine.Color.pas';
//  QuadEngine.Profiler in '..\QuadEngine.Profiler.pas';

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


function SecretMagicFunction: PWideChar; stdcall;
begin
  Result := 'Theory is - when you know everything but nothing works.'#13 +
            'Practice is - when all works, but you don''t know why.'#13 +
            'We combine theory and practice - nothing works and nobody knows why.';
end;

exports
  CreateQuadDeviceEx,
  CreateQuadDevice,
  SecretMagicFunction;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
