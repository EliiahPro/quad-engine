//Theory is - when you know everything but nothing works.
//Practice is - when all works, but you don't know why.
//We combine theory and practice - nothing works and nobody knows why

library qei;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

//{$DEFINE DEBUG}

{$R 'Shaders.res' 'Shaders.rc'}

uses
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

{$R *.res}

procedure CreateQuadWindowEx(out AWindow: Pointer); stdcall;
var
  QW: IQuadWindow;
begin
  QW := TQuadWindow.Create;
  QW._AddRef;
  AWindow := Pointer(QW);
end;


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
end;


function CreateQuadWindow(out AQuadWindow: IQuadWindow): HResult; stdcall;
begin
  AQuadWindow := TQuadWindow.Create;
end;

function SecretMagicFunction: PWideChar; stdcall;
begin
  Result := 'Theory is - when you know everything but nothing works.'#13 +
            'Practice is - when all works, but you don''t know why.'#13 +
            'We combine theory and practice - nothing works and nobody knows why.';
end;

exports
  CreateQuadWindowEx,
  CreateQuadDeviceEx,
  CreateQuadDevice,
  CreateQuadWindow,
  SecretMagicFunction;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
