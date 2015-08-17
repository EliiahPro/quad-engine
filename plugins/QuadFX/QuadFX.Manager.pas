unit QuadFX.Manager;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections, QuadFX.Layer, QuadFX.EffectParams, Classes,
  QuadFX.Atlas;

const
  QuadFXVersion: PWideChar = 'QuadFX v0.5.0';

type
  TQuadFXManager = class(TInterfacedObject, IQuadFXManager)
  private
    FQuadDevice: IQuadDevice;
    FLayers: TList<TQuadFXLayer>;
    FEffectParams: TList<TQuadFXEffectParams>;
    FAtlases: TList<TQuadFXAtlas>;

    FOnTextureLoad: TQuadFXTextureLoadEvent;
  public
    constructor Create(AQuadDevice: IQuadDevice);
    destructor Destroy; override;
    procedure CreateEffectParams(out AEffect: IQuadFXEffectParams); stdcall;
    procedure CreateLayer(out ALayer: IQuadFXLayer); stdcall;
    procedure CreateAtlas(out AAtlas: IQuadFXAtlas); stdcall;
    procedure SetOnTextureLoad(AOnTextureLoad: TQuadFXTextureLoadEvent); stdcall;
    procedure LoadFromFile(AFileName: PWideChar); stdcall;

    function SearchTexture(const AID: Integer): PQuadFXTextureInfo;
    procedure AddLog(AString: PWideChar);
    property QuadDevice: IQuadDevice read FQuadDevice;
  end;

var
  Manager: TQuadFXManager;

implementation

procedure TQuadFXManager.SetOnTextureLoad(AOnTextureLoad: TQuadFXTextureLoadEvent); stdcall;
begin
  FOnTextureLoad := AOnTextureLoad;
end;

constructor TQuadFXManager.Create(AQuadDevice: IQuadDevice);
begin
  FQuadDevice := AQuadDevice;
  AddLog(QuadFXVersion);
  FLayers := TList<TQuadFXLayer>.Create;
  FEffectParams := TList<TQuadFXEffectParams>.Create;
end;

destructor TQuadFXManager.Destroy;
begin
  FEffectParams.Free;
  FLayers.Free;
  inherited;
end;

procedure TQuadFXManager.CreateEffectParams(out AEffect: IQuadFXEffectParams); stdcall;
var
  NewEffectParams: TQuadFXEffectParams;
begin
  NewEffectParams := TQuadFXEffectParams.Create;
  FEffectParams.Add(NewEffectParams);
  AEffect := NewEffectParams;
end;

procedure TQuadFXManager.CreateLayer(out ALayer: IQuadFXLayer); stdcall;
var
  NewLayer: TQuadFXLayer;
begin
  NewLayer := TQuadFXLayer.Create;
  FLayers.Add(NewLayer);
  ALayer := NewLayer;
end;

procedure TQuadFXManager.CreateAtlas(out AAtlas: IQuadFXAtlas); stdcall;
var
  NewAtlas: TQuadFXAtlas;
begin
  NewAtlas := TQuadFXAtlas.Create;
  FAtlases.Add(NewAtlas);
  AAtlas := NewAtlas;
end;

function TQuadFXManager.SearchTexture(const AID: Integer): PQuadFXTextureInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FAtlases.Count - 1 do
    if Assigned(FAtlases[i]) then
    begin
      Result := FAtlases[i].SearchSprite(AID);
      if Assigned(Result) then
        Exit;
    end;
end;

procedure TQuadFXManager.LoadFromFile(AFileName: PWideChar); stdcall;
begin
  //
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
