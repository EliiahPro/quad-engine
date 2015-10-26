unit QuadFX.EffectParams;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections, System.Classes, System.SysUtils, System.Json;

type
  TQuadFXEffectParams = class(TInterfacedObject, IQuadFXEffectParams)
  public
    FEmitters: TList<PQuadFXEmitterParams>;
    FName: WideString;
    FLifeTime: Single;
    FLoadFromFile: Boolean;
    FPoolIndex: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateEmitterParams(out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    function DeleteEmitterParams(AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    function GetEmitterParams(Index: Integer; out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    function GetEmitterParamsCount: integer; stdcall;

    function GetLifeTime: Single; stdcall;
  public
    procedure LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AEffectName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;

    procedure Clear;

    property Name: WideString read FName write FName;
    property PoolIndex: Integer read FPoolIndex write FPoolIndex;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.FileLoader, Winapi.Windows;

constructor TQuadFXEffectParams.Create;
begin
  FPoolIndex := -1;
  FLoadFromFile := False;
  FEmitters := TList<PQuadFXEmitterParams>.Create;
  FName := 'Effect 1';

  FLifeTime := 5;
end;

destructor TQuadFXEffectParams.Destroy;
begin
  Clear;
  FEmitters.Free;
  inherited;
end;

function TQuadFXEffectParams.GetLifeTime: Single;
begin
  Result := FLifeTime;
end;

procedure TQuadFXEffectParams.Clear;
var
  i: Integer;
begin
  for i := FEmitters.Count - 1 downto 0 do
  begin
  //  FEmitters[i].Texture := nil;
    Dispose(FEmitters[i]);
  end;
  FEmitters.Clear;
end;

function TQuadFXEffectParams.GetEmitterParams(Index: Integer; out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
begin
  AEmitterParams := FEmitters[Index];
  if Assigned(AEmitterParams) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXEffectParams.GetEmitterParamsCount: integer; stdcall;
begin
  Result := FEmitters.Count;
end;

function TQuadFXEffectParams.DeleteEmitterParams(AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
begin
  if FEmitters.Remove(AEmitterParams) >= 0 then
  begin
    Dispose(AEmitterParams);
    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

function TQuadFXEffectParams.CreateEmitterParams(out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
var
  i: Integer;
begin
  new(AEmitterParams);
  FEmitters.Add(AEmitterParams);
  AEmitterParams.Name := 'Emitter ' + IntToStr(FEmitters.Count);

  AEmitterParams.EndTime := 2;
  AEmitterParams.BeginTime := 0.5;
  AEmitterParams.BlendMode := qbmSrcAlphaAdd;
  AEmitterParams.IsLoop := False;

  AEmitterParams.Position.X := TQuadFXParams.Create(0);
  AEmitterParams.Position.Y := TQuadFXParams.Create(0);
  AEmitterParams.Shape.ShapeType := qeftPoint;
  AEmitterParams.Shape.ParamType := qpptValue;

  AEmitterParams.MaxParticles := 128;

  for i := 0 to 2 do
  begin
    AEmitterParams.Shape.Value[i] := 0;
    AEmitterParams.Shape.Diagram[i].Count := 0;
    SetLength(AEmitterParams.Shape.Diagram[i].List, AEmitterParams.Shape.Diagram[i].Count);
  end;

  AEmitterParams.Direction := TQuadFXParams.Create(Pi + Pi /2);
  AEmitterParams.Spread := TQuadFXParams.Create(0.5);

  AEmitterParams.Emission := TQuadFXParams.Create(10);
  AEmitterParams.Particle.LifeTime := TQuadFXParams.Create(1.5);
  AEmitterParams.Particle.Opacity := TQuadFXParams.Create(1);
  AEmitterParams.Particle.StartAngle := TQuadFXParams.Create(-360, 360);
  AEmitterParams.Particle.Spin := TQuadFXParams.Create(1);
  AEmitterParams.Particle.Scale := TQuadFXParams.Create(1);
  AEmitterParams.Particle.StartVelocity := TQuadFXParams.Create(64);
  AEmitterParams.Particle.Velocity := TQuadFXParams.Create(1);

  AEmitterParams.Particle.Color.Count := 2;
  SetLength(AEmitterParams.Particle.Color.List, AEmitterParams.Particle.Color.Count);
  AEmitterParams.Particle.Color.List[0].Life := 0;
  AEmitterParams.Particle.Color.List[0].Value := $FFFF0000;
  AEmitterParams.Particle.Color.List[1].Life := 1;
  AEmitterParams.Particle.Color.List[1].Value := $FF00FF00;

  AEmitterParams.TextureCount := 0;
  SetLength(AEmitterParams.Textures, AEmitterParams.TextureCount);

  if Assigned(AEmitterParams) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

procedure TQuadFXEffectParams.LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
var
  Stream: TMemoryStream;
begin
  FLoadFromFile := True;
  Manager.AddLog(PWideChar('QuadFX: Loading effect "' + AEffectName + '" from file "' + AFileName + '"'));

  if not FileExists(AFileName) then
  begin
    Manager.AddLog(PWideChar('QuadFX: File "' + AFileName + '" not found!'));
    Exit;
  end;

  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(AFileName);
  LoadFromStream(AEffectName, Stream.Memory, Stream.Size);
  FreeAndNil(Stream);
end;

procedure TQuadFXEffectParams.LoadFromStream(AEffectName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
var
  Stream: TMemoryStream;
begin
  if not FLoadFromFile then
    Manager.AddLog(PWideChar('QuadFX: Loading effect "' + AEffectName + '" from stream'));
  FLoadFromFile := False;

  Stream := TMemoryStream.Create;
  Stream.WriteBuffer((AStream)^, AStreamSize);
  Stream.Seek(0, soFromBeginning);
  try
    TQuadFXFileLoader.EffectLoadFromStream(AEffectName, Stream, Self);
  except
    Manager.AddLog(PWideChar('QuadFX: Error loading effect'));
  end;
  Stream.Free;
end;

end.
