unit QuadFX.Effect;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter, QuadFX.LayerEffectProxy,
  System.Generics.Collections, Winapi.Windows, QuadFX.Helpers, QuadFX.EffectEmitterProxy;

type
  TQuadFXEffect = class(TInterfacedObject, IQuadFXEffect)
  private
    FOldPosition: TVec2f;
   // FPosition: TVec2f;
    FIsNeedToKill: Boolean;
    FParams: IQuadFXEffectParams;
    FEmmiters: TList<IQuadFXEmitter>;
    FCount: Integer;
    FLife: Single;
    FAction: Boolean;
    FOldScale: Single;
   //FScale: Single;
    FOldAngle: Single;
   // FAngle: Single;
   // FSinRad, FCosRad: Single;

    FEffectEmitterProxy: TEffectEmitterProxy;

    FSpawnWithLerp: Boolean;
  public
    constructor Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
    procedure SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);
    destructor Destroy; override;

    function CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
    function DeleteEmitter(AParams: PQuadFXEmitterParams): Boolean;
    procedure Update(const ADelta: Double); stdcall;
    procedure Draw; stdcall;
    function GetEmitter(Index: Integer; out AEmitter: IQuadFXEmitter): HResult; stdcall;
    function GetEmitterCount: integer; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
    function GetPosition: TVec2f; stdcall;
    function GetSpawnWithLerp: Boolean; stdcall;
    function GetLife: Single; stdcall;
    function GetAngle: Single; stdcall;
    function GetScale: Single; stdcall;

    procedure GetLerp(ADist: Single; out APosition: TVec2f; out AAngle, AScale: Single);

    procedure SetSpawnWithLerp(ASpawnWithLerp: Boolean); stdcall;
    procedure SetPosition(APosition: TVec2f); stdcall;
    procedure SetAngle(AAngle: Single); stdcall;
    procedure SetScal(AScale: Single); stdcall;
    procedure ToLife(ALife: Single);
    procedure Restart(APosition: TVec2f; AAngle, AScale: Single);
    property IsNeedToKill: Boolean read FIsNeedToKill;
    property Life: Single read FLife;
    property Action: Boolean read FAction;
  end;

implementation

uses
  QuadFX.Layer, QuadFX.EffectParams, QuadEngine.Utils, QuadFX.Profiler;

constructor TQuadFXEffect.Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
var
  i: Integer;
  EmitterParams: PQuadFXEmitterParams;
begin
  FEffectEmitterProxy := TEffectEmitterProxy.Create(APosition, AAngle, AScale);

  FLife := 0;
  FCount := 0;
  FIsNeedToKill := False;
  FAction := True;
  FParams := AParams;

  FEmmiters := TList<IQuadFXEmitter>.Create;
  for i := 0 to AParams.GetEmitterParamsCount - 1 do
  begin
    AParams.GetEmitterParams(i, EmitterParams);
    CreateEmitter(EmitterParams);
  end;
end;

procedure TQuadFXEffect.SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);
begin
  FEffectEmitterProxy.SetLayerEffectProxy(ALayerEffectProxy);
end;

procedure TQuadFXEffect.Restart(APosition: TVec2f; AAngle, AScale: Single);
var
  i: Integer;
  Emmiter: IQuadFXEmitter;
begin
  FLife := 0;
  FCount := 0;
  FIsNeedToKill := False;
  FAction := True;

  FEffectEmitterProxy.Create(APosition, AAngle, AScale);
  for Emmiter in FEmmiters do
    TQuadFXEmitter(Emmiter).Restart;
end;

function TQuadFXEffect.CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
begin
  Result := TQuadFXEmitter.Create(FEffectEmitterProxy, AParams);
  FEmmiters.Add(Result);
end;

function TQuadFXEffect.DeleteEmitter(AParams: PQuadFXEmitterParams): Boolean;
var
  i: Integer;
  Params: PQuadFXEmitterParams;
begin
  for i := 0 to FEmmiters.Count - 1 do
    if (FEmmiters[i].GetEmitterParams(Params) = S_OK) and (Params = AParams) then
    begin
      FEmmiters.Delete(i);
      Exit(True);
    end;
  Result := False;
end;

destructor TQuadFXEffect.Destroy;
begin
  FParams := nil;
  FEmmiters.Free;
  //FEffectEmitterProxy.free;
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
  Emmiter: IQuadFXEmitter;
  Ac: Boolean;
  ProfilerCounter: Int64;
begin
  if FIsNeedToKill then
    Exit;

//  ProfilerCounter := Profiler.StartPerformanceCounter;

  FLife := FLife + ADelta;

  Ac := False;
  FCount := 0;
  for Emmiter in FEmmiters do
    if Assigned(Emmiter) then
    begin
      Emmiter.Update(ADelta);
      FCount := FCount + Emmiter.GetParticleCount;
      if Emmiter.GetActive then
        Ac := True;
    end;

  if not Ac and (FCount = 0) then
  begin
    FAction := False;
    FIsNeedToKill := True;
  end;

//  Profiler.EndPerformanceCounter('Effect', ProfilerCounter);
end;

procedure TQuadFXEffect.Draw; stdcall;
var
  Emmiter: IQuadFXEmitter;
begin
  for Emmiter in FEmmiters do
    Emmiter.Draw;
end;

function TQuadFXEffect.GetParticleCount: integer; stdcall;
begin
  Result := FCount;
end;

function TQuadFXEffect.GetPosition: TVec2f; stdcall;
begin
  Result := FEffectEmitterProxy.Position;
end;

function TQuadFXEffect.GetLife: Single; stdcall;
begin
  Result := FLife;
end;

function TQuadFXEffect.GetAngle: Single; stdcall;
begin
  Result := FEffectEmitterProxy.Angle;
end;

function TQuadFXEffect.GetScale: Single; stdcall;
begin
  Result := FEffectEmitterProxy.Scale;
end;

procedure TQuadFXEffect.SetPosition(APosition: TVec2f); stdcall;
begin
  FEffectEmitterProxy.Position := APosition;
end;

procedure TQuadFXEffect.SetAngle(AAngle: Single); stdcall;
begin
  FEffectEmitterProxy.Angle := AAngle;
end;

procedure TQuadFXEffect.SetScal(AScale: Single); stdcall;
begin
  FEffectEmitterProxy.Scale := AScale;
end;

procedure TQuadFXEffect.SetSpawnWithLerp(ASpawnWithLerp: Boolean); stdcall;
begin
  FSpawnWithLerp := ASpawnWithLerp;
end;

procedure TQuadFXEffect.GetLerp(ADist: Single; out APosition: TVec2f; out AAngle, AScale: Single);
begin

end;

function TQuadFXEffect.GetSpawnWithLerp: Boolean; stdcall;
begin
  Result := FSpawnWithLerp;
end;

function TQuadFXEffect.GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
begin
  AEffectParams := FParams;
  if Assigned(AEffectParams) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXEffect.GetEmitter(Index: Integer; out AEmitter: IQuadFXEmitter): HResult; stdcall;
begin
  AEmitter := FEmmiters[Index];
  if Assigned(AEmitter) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXEffect.GetEmitterCount: integer; stdcall;
begin
  Result := FEmmiters.Count;
end;

end.
