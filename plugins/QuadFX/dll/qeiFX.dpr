library qeiFX;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

uses
  Windows,
  SysUtils,
  QuadEngine,
  QuadFX in '..\headers\QuadFX.pas',
  QuadFX.Emitter in '..\QuadFX.Emitter.pas',
  QuadFX.Effect in '..\QuadFX.Effect.pas',
  QuadFX.Layer in '..\QuadFX.Layer.pas',
  QuadFX.EffectParams in '..\QuadFX.EffectParams.pas',
  QuadFX.EffectParamsList in '..\QuadFX.EffectParamsList.pas',
  QuadFX.Manager in '..\QuadFX.Manager.pas',
  QuadFX.Helpers in '..\QuadFX.Helpers.pas',
  QuadFX.Atlas in '..\QuadFX.Atlas.pas';

{$R *.res}

function CreateQuadFXManager(AQuadDevice: IQuadDevice; out AQuadFXManager: IQuadFXManager): HResult; stdcall;
begin
  Manager := TQuadFXManager.Create(AQuadDevice);
  AQuadFXManager := Manager;

  if Assigned(Manager) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function IsSameVersion(ARelease, AMajor, AMinor: Byte): Boolean; stdcall;
begin
  Result := (ARelease = QuadFXReleaseVersion) and
            (AMajor = QuadFXMajorVersion) and
            (AMinor = QuadFXMinorVersion);

  if not Result then
    raise Exception.Create('Quad Engine: QuadFX version and header version does not match!');
end;

exports
  CreateQuadFXManager,
  IsSameVersion;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
