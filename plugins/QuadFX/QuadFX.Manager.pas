unit QuadFX.Manager;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections, QuadFX.Layer, QuadFX.EffectParams, Classes,
  QuadFX.Atlas, Winapi.Windows, QuadFX.Effect, System.SysUtils;

{$R 'resources\data.res' 'resources\data.rc'}

type
  TEffectsList = TList<IQuadFXEffect>;

  TQuadFXManager = class(TInterfacedObject, IQuadFXManager)
  private
    FQuadDevice: IQuadDevice;
    FQuadRender: IQuadRender;
    FLayers: TList<IQuadFXLayer>;
    FEffectParams: TList<IQuadFXEffectParams>;
    FAtlases: TList<IQuadFXAtlas>;
    FDefaultTexture: IQuadTexture;

    FEffectsPool: TObjectList<TQueue<IQuadFXEffect>>;
  public
    constructor Create(AQuadDevice: IQuadDevice);
    destructor Destroy; override;
    function CreateEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
    function CreateLayer(out ALayer: IQuadFXLayer): HResult; stdcall;
    function CreateAtlas(out AAtlas: IQuadFXAtlas): HResult; stdcall;

    function AtlasByName(const APackName, AAtlasName: WideString): IQuadFXAtlas;
    procedure AddLog(AString: PWideChar);
    property QuadDevice: IQuadDevice read FQuadDevice;
    property QuadRender: IQuadRender read FQuadRender;

    function AddEffectToPool(AEffect: IQuadFXEffect): Boolean;
    function GetEffectFromPool(AEffectParams: IQuadFXEffectParams): IQuadFXEffect;
    property DefaultTexture: IQuadTexture read FDefaultTexture;
  end;

var
  Manager: TQuadFXManager;

implementation

constructor TQuadFXManager.Create(AQuadDevice: IQuadDevice);
var
  ResStream: TResourceStream;
begin
  FQuadDevice := AQuadDevice;
  FQuadDevice.CreateRender(FQuadRender);
  AddLog(PWideChar(Format('QuadFX v%d.%d.%d', [QuadFXReleaseVersion, QuadFXMajorVersion, QuadFXMinorVersion])));
  FLayers := TList<IQuadFXLayer>.Create;
  FEffectParams := TList<IQuadFXEffectParams>.Create;
  FAtlases := TList<IQuadFXAtlas>.Create;
  FEffectsPool := TObjectList<TQueue<IQuadFXEffect>>.Create;

  ResStream := TResourceStream.Create(hInstance, 'DefaultTexture', RT_RCDATA);
  try
    FQuadDevice.CreateTexture(FDefaultTexture);
    FDefaultTexture.LoadFromStream(0, ResStream.Memory, ResStream.Size);
  finally
    ResStream.Free;
  end;
end;

destructor TQuadFXManager.Destroy;
begin
  FEffectParams.Free;
  FLayers.Free;
  FAtlases.Free;
  FEffectsPool.Free;
  inherited;
end;

function TQuadFXManager.AddEffectToPool(AEffect: IQuadFXEffect): Boolean;
var
  EffectParams: IQuadFXEffectParams;
  PoolIndex: Integer;
begin
  if Assigned(AEffect) then
  begin
    AEffect.GetEffectParams(EffectParams);
    if Assigned(EffectParams) then
    begin
      PoolIndex := TQuadFXEffectParams(EffectParams).PoolIndex;
      if PoolIndex >= 0 then
        FEffectsPool[PoolIndex].Enqueue(AEffect);
    end;
  end;
end;

function TQuadFXManager.GetEffectFromPool(AEffectParams: IQuadFXEffectParams): IQuadFXEffect;
var
  PoolIndex: Integer;
begin
  Result := nil;
  if Assigned(AEffectParams) then
  begin
    PoolIndex := TQuadFXEffectParams(AEffectParams).PoolIndex;
    if (PoolIndex >= 0) and (FEffectsPool[PoolIndex].Count > 0) then
      Result := FEffectsPool[PoolIndex].Dequeue;
  end;
end;

function TQuadFXManager.CreateEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
begin
  AEffectParams := TQuadFXEffectParams.Create;
  if Assigned(AEffectParams) then
  begin
    FEffectParams.Add(AEffectParams);
    TQuadFXEffectParams(AEffectParams).PoolIndex := FEffectsPool.Add(TQueue<IQuadFXEffect>.Create);
    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

function TQuadFXManager.CreateLayer(out ALayer: IQuadFXLayer): HResult; stdcall;
begin
  ALayer := TQuadFXLayer.Create;
  if Assigned(ALayer) then
  begin
    FLayers.Add(ALayer);
    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

function TQuadFXManager.CreateAtlas(out AAtlas: IQuadFXAtlas): HResult; stdcall;
begin
  AAtlas := TQuadFXAtlas.Create;
  if Assigned(AAtlas) then
  begin
    FAtlases.Add(AAtlas);
    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

function TQuadFXManager.AtlasByName(const APackName, AAtlasName: WideString): IQuadFXAtlas;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FAtlases.Count - 1 do
    if Assigned(FAtlases[i]) and ( FAtlases[i].GetPackName = APackName) and (FAtlases[i].GetName = AAtlasName) then
      Exit(FAtlases[i]);
end;

procedure TQuadFXManager.AddLog(AString: PWideChar);
var
  Log: IQuadLog;
begin
  if Assigned(FQuadDevice) then
  begin
    FQuadDevice.CreateLog(Log);
    Log.Write(AString);
  end;
end;

end.
