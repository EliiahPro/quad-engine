unit QuadFX.Effect;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections;

type
  TQuadFXEffect = class(TInterfacedObject, IQuadFXEffect)
  private
    FPosition: TVec2f;
    FIsNeedToKill: Boolean;
    FParams: IQuadFXEffectParams;
    FEmmiters: TList<IQuadFXEmitter>;
    FCount: Integer;
    FLife: Single;
    FAction: Boolean;
  public
    constructor Create(AParams: IQuadFXEffectParams; APosition: TVec2f);
    destructor Destroy; override;

    function CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
    procedure Update(const ADelta: Double); stdcall;
   // procedure Draw; stdcall;
    function GetEmitter(Index: Integer): IQuadFXEmitter; stdcall;
    function GetEmitterCount: integer; stdcall;
    function GetParticleCount: integer; stdcall;
    procedure ToLife(ALife: Single);
    property IsNeedToKill: Boolean read FIsNeedToKill;
    property Life: Single read FLife;
    property Action: Boolean read FAction;
  end;

implementation

uses
  QuadFX.Layer, QuadFX.EffectParams;

constructor TQuadFXEffect.Create(AParams: IQuadFXEffectParams; APosition: TVec2f);
var
  i: Integer;
begin
  FPosition := APosition;
  FLife := 0;
  FCount := 0;
  FIsNeedToKill := False;
  FAction := True;
  FParams := AParams;

  FEmmiters := TList<IQuadFXEmitter>.Create;

  for i := 0 to AParams.EmitterParamsCount - 1 do
    CreateEmitter(AParams.EmitterParams[i]);
end;

function TQuadFXEffect.CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
begin
  Result := TQuadFXEmitter.Create(AParams, @FPosition);
  FEmmiters.Add(Result);
end;

destructor TQuadFXEffect.Destroy;
var
  i: Integer;
begin
  FParams := nil;
  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEmmiters[i]) then
      FEmmiters[i] := nil;

  FEmmiters.Free;
  inherited;
end;

procedure TQuadFXEffect.ToLife(ALife: Single);
var
  i: Integer;
begin
  FAction := True;
  FIsNeedToKill := False;
  FLife := ALife;
  for i := 0 to FEmmiters.Count - 1 do
  begin
    TQuadFXEmitter(FEmmiters[i]).Restart;
  //  FEmmiters[i].Update(ALife);
  end;
end;

procedure TQuadFXEffect.Update(const ADelta: Double); stdcall;
var
  i: Integer;
  Ac: Boolean;
begin     {
  if FIsNeedToKill then
    Exit;
        }
  FLife := FLife + ADelta;
 { if (FParams.LifeTime > 0) and (FLife >= FParams.LifeTime)  then
  begin
    FIsNeedToKill := True;
    Exit;
  end;
      }
  Ac := False;
  FCount := 0;
  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEmmiters[i]) and FEmmiters[i].Active then
    begin
      FEmmiters[i].Update(ADelta);
      FCount := FCount + FEmmiters[i].ParticleCount;
      if FEmmiters[i].Active then
        Ac := True;
    end;

  if not Ac and (FCount = 0) then
    FAction := False;
end;
                 {
procedure TQuadFXEffect.Draw; stdcall;
var
  i: Integer;
begin
  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEmmiters[i]) then
      FEmmiters[i].Draw;
end;
               }
function TQuadFXEffect.GetParticleCount: integer; stdcall;
begin
  Result := FCount;
end;

function TQuadFXEffect.GetEmitter(Index: Integer): IQuadFXEmitter; stdcall;
var
  Em: IQuadFXEmitter;
begin
  Em := FEmmiters[Index];
  Result := Em;
end;

function TQuadFXEffect.GetEmitterCount: integer; stdcall;
begin
  Result := FEmmiters.Count;
end;

end.
