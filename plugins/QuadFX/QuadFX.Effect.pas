unit QuadFX.Effect;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections, Windows;

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
    FScale: Single;
    FAngle: Single;
    FSinRad, FCosRad: Single;
  public
    constructor Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
    destructor Destroy; override;

    function CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
    procedure Update(const ADelta: Double); stdcall;
   // procedure Draw; stdcall;
    function GetEmitter(Index: Integer): IQuadFXEmitter; stdcall;
    function GetEmitterCount: integer; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
    function GetPosition: TVec2f; stdcall;
    function GetLife: Single; stdcall;
    function GetAngle: Single; stdcall;
    function GetScale: Single; stdcall;
    procedure SetPosition(APosition: TVec2f); stdcall;
    procedure SetAngle(AAngle: Single); stdcall;
    procedure SetScal(AScale: Single); stdcall;
    procedure GetSinCos(out ASinRad, ACosRad: Single);
    procedure ToLife(ALife: Single);
    property IsNeedToKill: Boolean read FIsNeedToKill;
    property Life: Single read FLife;
    property Action: Boolean read FAction;
  end;

implementation

uses
  QuadFX.Layer, QuadFX.EffectParams, QuadEngine.Utils;

constructor TQuadFXEffect.Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
var
  i: Integer;
begin
  FPosition := APosition;
  FAngle := AAngle;
  FastSinCos(FAngle, FSinRad, FCosRad);
  FScale := AScale;
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
  Result := TQuadFXEmitter.Create(Self, AParams);
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
begin
  if FIsNeedToKill then
    Exit;

  FLife := FLife + ADelta;

  Ac := False;
  FCount := 0;
  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEmmiters[i]) then
    begin
      FEmmiters[i].Update(ADelta);
      FCount := FCount + FEmmiters[i].ParticleCount;
      if FEmmiters[i].Active then
        Ac := True;
    end;

  if not Ac and (FCount = 0) then
  begin
    FAction := False;
    FIsNeedToKill := True;
  end;
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

procedure TQuadFXEffect.GetSinCos(out ASinRad, ACosRad: Single);
begin
  ACosRad := FCosRad;
  ASinRad := FSinRad;
end;

function TQuadFXEffect.GetPosition: TVec2f; stdcall;
begin
  Result := FPosition;
end;

function TQuadFXEffect.GetLife: Single; stdcall;
begin
  Result := FLife;
end;

function TQuadFXEffect.GetAngle: Single; stdcall;
begin
  Result := FAngle;
end;

function TQuadFXEffect.GetScale: Single; stdcall;
begin
  Result := FScale;
end;

procedure TQuadFXEffect.SetPosition(APosition: TVec2f); stdcall;
begin
  FPosition := APosition;
end;

procedure TQuadFXEffect.SetAngle(AAngle: Single); stdcall;
begin
  if FAngle <> AAngle then
    FastSinCos(AAngle, FSinRad, FCosRad);
  FAngle := AAngle;
end;

procedure TQuadFXEffect.SetScal(AScale: Single); stdcall;
begin
  FScale := AScale;
end;

function TQuadFXEffect.GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
begin
  AEffectParams := FParams;
  if Assigned(AEffectParams) then
    Result := S_OK
  else
    Result := E_FAIL;
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
