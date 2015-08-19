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
    FQuadRender: IQuadRender;
    FLayers: TList<TQuadFXLayer>;
    FEffectParams: TList<TQuadFXEffectParams>;
    FAtlases: TList<TQuadFXAtlas>;

  public
    constructor Create(AQuadDevice: IQuadDevice);
    destructor Destroy; override;
    procedure CreateEffectParams(out AEffectParams: IQuadFXEffectParams); stdcall;
    procedure CreateLayer(out ALayer: IQuadFXLayer); stdcall;
    procedure CreateAtlas(out AAtlas: IQuadFXAtlas); stdcall;

    function SearchTexture(const APackName: WideString; const AID: Integer): PQuadFXTextureInfo;
    function SearchAtlas(const APackName, AAtlasName: WideString): IQuadFXAtlas;
    procedure AddLog(AString: PWideChar);
    property QuadDevice: IQuadDevice read FQuadDevice;
    property QuadRender: IQuadRender read FQuadRender;
  end;

var
  Manager: TQuadFXManager;

implementation

constructor TQuadFXManager.Create(AQuadDevice: IQuadDevice);
begin
  FQuadDevice := AQuadDevice;
  FQuadDevice.CreateRender(FQuadRender);
  AddLog(QuadFXVersion);
  FLayers := TList<TQuadFXLayer>.Create;
  FEffectParams := TList<TQuadFXEffectParams>.Create;
  FAtlases := TList<TQuadFXAtlas>.Create;
end;

destructor TQuadFXManager.Destroy;
begin
  FEffectParams.Free;
  FLayers.Free;
  FAtlases.Free;
  inherited;
end;

procedure TQuadFXManager.CreateEffectParams(out AEffectParams: IQuadFXEffectParams); stdcall;
var
  NewEffectParams: TQuadFXEffectParams;
begin
  NewEffectParams := TQuadFXEffectParams.Create;
  FEffectParams.Add(NewEffectParams);
  AEffectParams := NewEffectParams;
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

function TQuadFXManager.SearchTexture(const APackName: WideString; const AID: Integer): PQuadFXTextureInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FAtlases.Count - 1 do
    if Assigned(FAtlases[i]) and (TQuadFXAtlas(FAtlases[i]).PackName = APackName) then
    begin
      Result := FAtlases[i].SearchSprite(AID);
      if Assigned(Result) then
        Exit;
    end;
end;

function TQuadFXManager.SearchAtlas(const APackName, AAtlasName: WideString): IQuadFXAtlas;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FAtlases.Count - 1 do
    if Assigned(FAtlases[i]) and (TQuadFXAtlas(FAtlases[i]).PackName = APackName) and (TQuadFXAtlas(FAtlases[i]).Name = AAtlasName) then
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
