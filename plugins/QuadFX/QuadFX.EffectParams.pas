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
    procedure Clear;
    function CreateEmitterParams: PQuadFXEmitterParams;
    function GetEmitterParams(Index: Integer): PQuadFXEmitterParams; stdcall;
    function GetEmitterParamsCount: integer; stdcall;

    procedure LoadParams(F: TFileStream; AParam: PQuadFXParams);
    function GetLifeTime: Single; stdcall;
  public
    procedure LoadFromFile(F: TFileStream);
    procedure SaveToFile(F: TFileStream);


    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);
    function ToJson: TJSONObject;
    procedure FromJson(AJsonObject: TJSONObject);

    property Name: WideString read FName write FName;
  end;

implementation

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

function TQuadFXEffectParams.CreateEmitterParams: PQuadFXEmitterParams;
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

procedure TQuadFXEffectParams.LoadFromFile(F: TFileStream);
 // NewEmitter: PQuadFXEmitterParams;
begin
 { CreateEmitterParams;
  CreateEmitterParams;
  CreateEmitterParams;}
end;

procedure TQuadFXEffectParams.SaveToFile(F: TFileStream);
begin

end;

procedure TQuadFXEffectParams.LoadParams(F: TFileStream; AParam: PQuadFXParams);
begin
  F.Read(AParam.ParamsType, 1);
  case AParam.ParamsType of
    qpptValue: F.Read(AParam.Value[0], SizeOf(AParam.Value[0]));
    qpptRandomValue: F.Read(AParam.Value, SizeOf(AParam.Value[0]) * 2);

  end;
end;

function TQuadFXEffectParams.ToMemory: TMemoryStream;
var
  Count, Size, i: Integer;
begin
  Result := TMemoryStream.Create;
  //Size := Length(Name);
//  Result.Write(Size, SizeOF(Size));
//  Result.Write(Name[1], Size * 2);

  Count := FEmitters.Count;
  Result.Write(Count, SizeOF(Count));
  for i := 0 to Count - 1 do
    Result.WriteStream(FEmitters[i].ToMemory);
end;

procedure TQuadFXEffectParams.FromMemory(AMemory: TStream);
var
  Count, Size, i: Integer;
  Params: PQuadFXEmitterParams;
begin
  Clear;
  AMemory.Read(Size, SizeOf(Size));
  SetLength(FName, Size);
  AMemory.Read(FName[1], Size * 2);

  AMemory.Read(Count, SizeOF(Count));
  for i := 0 to Count - 1 do
  begin
    Params := CreateEmitterParams;
    Params.FromMemory(AMemory);
  end;
end;

function TQuadFXEffectParams.ToJson: TJSONObject;
var
  i: Integer;
  JSONEmitters: TJSONArray;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Name', Name);

  JSONEmitters := TJSONArray.Create;

  for i := 0 to FEmitters.Count - 1 do
    JSONEmitters.Add(FEmitters[i].ToJson);

  Result.AddPair('Emitters', JSONEmitters);
end;

procedure TQuadFXEffectParams.FromJson(AJsonObject: TJSONObject);
var
  i: Integer;
  JSONEmitters: TJSONArray;
  Params: PQuadFXEmitterParams;
begin
  Clear;

  FName := AJsonObject.GetValue('Name').Value;
  JSONEmitters := AJsonObject.GetValue('Emitters') as TJSONArray;
  for i := 0 to JSONEmitters.Count - 1 do
  begin
    Params := CreateEmitterParams;
    Params.FromJson(JSONEmitters.Get(i) as TJSONObject);
  end;
end;






{
  NewEmitter.LifeTime := 10;

  NewEmitter.Emission.ParamsType := qpptCurve;
  NewEmitter.Emission.Value[0] := 10;
  NewEmitter.Emission.Value[1] := NewEmitter.Emission.Value[0];
  NewEmitter.Emission.Diagram[0].Count := 3;
  SetLength(NewEmitter.Emission.Diagram[0].List, NewEmitter.Emission.Diagram[0].Count);
  NewEmitter.Emission.Diagram[0].List[0] := TQPSingleDiagramValue.Create(0, NewEmitter.Emission.Value[0]);
  NewEmitter.Emission.Diagram[0].List[1] := TQPSingleDiagramValue.Create(0.5, 1000);
  NewEmitter.Emission.Diagram[0].List[2] := TQPSingleDiagramValue.Create(1, 10);

  NewEmitter.Position := TVec2f.Create(0, 0);

  NewEmitter.Shape.ShapeType := qeftLine;
  NewEmitter.Shape.ParamType := qpptValue;
  NewEmitter.Shape.Value[0] := 100;
  NewEmitter.Shape.Value[1] := 0;
  NewEmitter.Shape.Value[2] := 0;

  NewEmitter.Shape.Diagram[0].Count := 3;
  SetLength(NewEmitter.Shape.Diagram[0].List, NewEmitter.Shape.Diagram[0].Count);
  NewEmitter.Shape.Diagram[0].List[0] := TQuadFXSingleDiagramValue.Create(0, 10);
  NewEmitter.Shape.Diagram[0].List[1] := TQuadFXSingleDiagramValue.Create(0.5, 200);
  NewEmitter.Shape.Diagram[0].List[2] := TQuadFXSingleDiagramValue.Create(1, 10);

  NewEmitter.Shape.Diagram[1].Count := 5;
  SetLength(NewEmitter.Shape.Diagram[1].List, NewEmitter.Shape.Diagram[1].Count);
  NewEmitter.Shape.Diagram[1].List[0] := TQuadFXSingleDiagramValue.Create(0, 0);
  NewEmitter.Shape.Diagram[1].List[1] := TQuadFXSingleDiagramValue.Create(0.33, 90);
  NewEmitter.Shape.Diagram[1].List[2] := TQuadFXSingleDiagramValue.Create(0.5, 45);
  NewEmitter.Shape.Diagram[1].List[3] := TQuadFXSingleDiagramValue.Create(0.7, 180);
  NewEmitter.Shape.Diagram[1].List[4] := TQuadFXSingleDiagramValue.Create(1, 0);

  NewEmitter.Shape.Diagram[2].Count := 3;
  SetLength(NewEmitter.Shape.Diagram[2].List, NewEmitter.Shape.Diagram[2].Count);
  NewEmitter.Shape.Diagram[2].List[0] := TQuadFXSingleDiagramValue.Create(0, 0);
  NewEmitter.Shape.Diagram[2].List[1] := TQuadFXSingleDiagramValue.Create(0.5, 3.14);
  NewEmitter.Shape.Diagram[2].List[2] := TQuadFXSingleDiagramValue.Create(1, 0);


  NewEmitter.Particle.LifeTime.ParamsType := qpptValue;
  NewEmitter.Particle.LifeTime.Value[0] := 1.2;

  NewEmitter.Direction := 270 * (3.14 / 180);
  NewEmitter.Spread := 15 * (3.14 / 180);

  NewEmitter.Particle.StartVelocity.Min := 64;
  NewEmitter.Particle.StartVelocity.Max := 64;

  NewEmitter.Particle.Velocity.Diagram[0].Count := 2;
  NewEmitter.Particle.Velocity.Value[0] := 0;

  SetLength(NewEmitter.Particle.Velocity.Diagram[0].List, NewEmitter.Particle.Velocity.Diagram[0].Count);
  NewEmitter.Particle.Velocity.Diagram[0].List[0] := TQuadFXSingleDiagramValue.Create(0, 0);
  NewEmitter.Particle.Velocity.Diagram[0].List[1] := TQuadFXSingleDiagramValue.Create(1, 1);

  NewEmitter.Particle.StartAngle.Min := 0;
  NewEmitter.Particle.StartAngle.Max := 2 * Pi;

 // NewEmitter.StartSpin.Min := -Pi / 2;
 // NewEmitter.StartSpin.Max := Pi / 2;

  NewEmitter.Particle.Spin.ParamsType := qpptCurve;
  NewEmitter.Particle.Spin.Diagram[0].Count := 2;
  SetLength(NewEmitter.Particle.Spin.Diagram[0].List, NewEmitter.Particle.Spin.Diagram[0].Count);
  NewEmitter.Particle.Spin.Diagram[0].List[0] := TQuadFXSingleDiagramValue.Create(0, 1);
  NewEmitter.Particle.Spin.Diagram[0].List[1] := TQuadFXSingleDiagramValue.Create(1, 2);

//  NewEmitter.StartScale.Min := 0.3;
//  NewEmitter.StartScale.Max := 0.3;

  NewEmitter.Particle.Scale.ParamsType := qpptCurve;
  NewEmitter.Particle.Scale.Diagram[0].Count := 3;
  SetLength(NewEmitter.Particle.Scale.Diagram[0].List, NewEmitter.Particle.Scale.Diagram[0].Count);
  NewEmitter.Particle.Scale.Diagram[0].List[0] := TQuadFXSingleDiagramValue.Create(0, 1);
  NewEmitter.Particle.Scale.Diagram[0].List[1] := TQuadFXSingleDiagramValue.Create(0.7, 4);
  NewEmitter.Particle.Scale.Diagram[0].List[2] := TQuadFXSingleDiagramValue.Create(1, 2);

  NewEmitter.Particle.Color.Count := 5;
  SetLength(NewEmitter.Particle.Color.List, NewEmitter.Particle.Color.Count);
  NewEmitter.Particle.Color.List[0].Life := 0;
  NewEmitter.Particle.Color.List[0].Value := $FFFF2222;
  NewEmitter.Particle.Color.List[1].Life := 0.1;
  NewEmitter.Particle.Color.List[1].Value := $FFFF2222;
  NewEmitter.Particle.Color.List[2].Life := 0.2;
  NewEmitter.Particle.Color.List[2].Value := $FFFFFF00;
  NewEmitter.Particle.Color.List[3].Life := 0.8;
  NewEmitter.Particle.Color.List[3].Value := $FFFF2200;
  NewEmitter.Particle.Color.List[4].Life := 1;
  NewEmitter.Particle.Color.List[4].Value := $FFFF0000;

  NewEmitter.Particle.Opacity.ParamsType := qpptCurve;
  NewEmitter.Particle.Opacity.Diagram[0].Count := 5;
  SetLength(NewEmitter.Particle.Opacity.Diagram[0].List, NewEmitter.Particle.Opacity.Diagram[0].Count);
  NewEmitter.Particle.Opacity.Diagram[0].List[0] := TQuadFXSingleDiagramValue.Create(0, 0);
  NewEmitter.Particle.Opacity.Diagram[0].List[1] := TQuadFXSingleDiagramValue.Create(0.1, 0.26);
  NewEmitter.Particle.Opacity.Diagram[0].List[2] := TQuadFXSingleDiagramValue.Create(0.3, 1);
  NewEmitter.Particle.Opacity.Diagram[0].List[3] := TQuadFXSingleDiagramValue.Create(0.8, 0.26);
  NewEmitter.Particle.Opacity.Diagram[0].List[4] := TQuadFXSingleDiagramValue.Create(1, 0);

  NewEmitter.TextureParams.FrameWidth := 25;
  NewEmitter.TextureParams.FrameHeight := 25;

  NewEmitter.TextureFileName := 'Data\Particle1.png';

  NewEmitter.TextureParams.FrameCount := 5;
  SetLength(NewEmitter.TextureParams.Frame, NewEmitter.TextureParams.FrameCount);
  for i := 0 to 4 do
    NewEmitter.TextureParams.Frame[i] := i + 1;

  NewEmitter.BlendMode := qpbmSrcAlpha;//  qbmSrcAlphaAdd;  }

end.
