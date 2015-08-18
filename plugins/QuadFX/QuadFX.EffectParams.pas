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
  public
    constructor Create;
    destructor Destroy; override;
    function CreateEmitterParams: PQuadFXEmitterParams; stdcall;
    function GetEmitterParams(Index: Integer): PQuadFXEmitterParams; stdcall;
    function GetEmitterParamsCount: integer; stdcall;

    function GetLifeTime: Single; stdcall;
  public
    procedure LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AEffectName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;

    procedure Clear;

    property Name: WideString read FName write FName;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParamsLoader;

constructor TQuadFXEffectParams.Create;
begin
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

function TQuadFXEffectParams.GetEmitterParams(Index: Integer): PQuadFXEmitterParams; stdcall;
begin
  Result := FEmitters[Index];
end;

function TQuadFXEffectParams.GetEmitterParamsCount: integer; stdcall;
begin
  Result := FEmitters.Count;
end;

function TQuadFXEffectParams.CreateEmitterParams: PQuadFXEmitterParams; stdcall;
var
  i: Integer;
begin
  new(Result);
  FEmitters.Add(Result);
  Result.Name := 'Emitter ' + IntToStr(FEmitters.Count);

  Result.EndTime := 2;
  Result.BeginTime := 0.5;
  Result.BlendMode := qpbmSrcAlphaAdd;
  Result.IsLoop := False;

  Result.Position.X := TQuadFXParams.Create(0);
  Result.Position.Y := TQuadFXParams.Create(0);
  Result.Shape.ShapeType := qeftPoint;
  Result.Shape.ParamType := qpptValue;

  for i := 0 to 2 do
  begin
    Result.Shape.Value[i] := 0;
    Result.Shape.Diagram[i].Count := 0;
    SetLength(Result.Shape.Diagram[i].List, Result.Shape.Diagram[i].Count);
  end;

  Result.Direction := TQuadFXParams.Create(Pi + Pi /2);
  Result.Spread := TQuadFXParams.Create(0.5);

  Result.Emission := TQuadFXParams.Create(10);
  Result.Particle.LifeTime := TQuadFXParams.Create(1.5);
  Result.Particle.Opacity := TQuadFXParams.Create(1);
  Result.Particle.StartAngle := TQuadFXParams.Create(-360, 360);
  Result.Particle.Spin := TQuadFXParams.Create(1);
  Result.Particle.Scale := TQuadFXParams.Create(1);
  Result.Particle.StartVelocity := TQuadFXParams.Create(64);
  Result.Particle.Velocity := TQuadFXParams.Create(1);

  Result.Particle.Color.Count := 2;
  SetLength(Result.Particle.Color.List, Result.Particle.Color.Count);
  Result.Particle.Color.List[0].Life := 0;
  Result.Particle.Color.List[0].Value := $FFFF0000;
  Result.Particle.Color.List[1].Life := 1;
  Result.Particle.Color.List[1].Value := $FF00FF00;

  Result.TextureCount := 0;
  SetLength(Result.Textures, Result.TextureCount);
end;

procedure TQuadFXEffectParams.LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
var
  Stream: TMemoryStream;
  Log: IQuadLog;
begin
  if Assigned(Manager.QuadDevice) then
    Manager.QuadDevice.CreateLog(Log);

  if Assigned(Log) then
    Log.Write(PWideChar('QuadFX: Loading effect "' + AEffectName + '" from file "' + AFileName + '"'));

  if not FileExists(AFileName) then
  begin
    if Assigned(Log) then
      Log.Write(PWideChar('QuadFX: File "' + AFileName + '" not found!'));
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
  Log: IQuadLog;
begin
  if Assigned(Manager.QuadDevice) then
    Manager.QuadDevice.CreateLog(Log);

  if Assigned(Log) then
    Log.Write(PWideChar('QuadFX: Loading effect "' + AEffectName + '" from stream'));

  Stream := TMemoryStream.Create;
  Stream.WriteBuffer((AStream)^, AStreamSize);
  Stream.Seek(0, soFromBeginning);
  try
    TQuadFXEffectLoader.LoadFromStream(AEffectName, Stream, Self);
  except
    if Assigned(Log) then
      Log.Write(PWideChar('QuadFX: Error loading effect'));
  end;
  Stream.Free;
end;

end.
