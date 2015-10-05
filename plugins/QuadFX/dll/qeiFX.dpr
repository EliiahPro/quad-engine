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
  QuadFX.Manager in '..\QuadFX.Manager.pas',
  QuadFX.Helpers in '..\QuadFX.Helpers.pas',
  QuadFX.Atlas in '..\QuadFX.Atlas.pas',
  QuadFX.FileLoader in '..\QuadFX.FileLoader.pas',
  QuadFX.FileLoader.CustomFormat in '..\QuadFX.FileLoader.CustomFormat.pas',
  QuadFX.FileLoader.JSON in '..\QuadFX.FileLoader.JSON.pas',
  QuadFX.EffectEmitterProxy in '..\QuadFX.EffectEmitterProxy.pas',
  QuadFX.LayerEffectProxy in '..\QuadFX.LayerEffectProxy.pas';

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
    raise Exception.Create('QuadFX version and header version does not match!');
end;

function IsSameQuadVersion(ARelease, AMajor, AMinor: Byte): Boolean; stdcall;
begin
  Result := (ARelease = QuadEngineReleaseVersion) and
            (AMajor = QuadEngineMajorVersion) and
            (AMinor = QuadEngineMinorVersion);

  if not Result then
    raise Exception.Create('QuadFX: Quad Engine version and header version does not match!');
end;

exports
  CreateQuadFXManager,
  IsSameVersion,
  IsSameQuadVersion;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
end.
