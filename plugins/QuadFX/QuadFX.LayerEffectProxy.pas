unit QuadFX.LayerEffectProxy;

interface

uses
  Vec2f, QuadFX;

type
  ILayerEffectProxy = interface
  ['{FE55A7E0-DF3F-4248-82FD-2F623234506D}']
    function GetGravitation: TVec2f;
    function GetOnDraw: TQuadFXEmitterDrawEvent;
  end;

  TLayerEffectProxy = class(TInterfacedObject, ILayerEffectProxy)
  private
    FGravitation: TVec2f;
    FOnDraw: TQuadFXEmitterDrawEvent;
    function GetGravitation: TVec2f; inline;
    function GetOnDraw: TQuadFXEmitterDrawEvent; inline;
  public
    constructor Create;
    property Gravitation: TVec2f read GetGravitation write FGravitation;
    property OnDraw: TQuadFXEmitterDrawEvent read GetOnDraw write FOnDraw;
  end;


implementation

constructor TLayerEffectProxy.Create;
begin
  FGravitation := TVec2f.Zero;
  FOnDraw := nil;
end;

function TLayerEffectProxy.GetGravitation: TVec2f;
begin
  Result := FGravitation;
end;

function TLayerEffectProxy.GetOnDraw: TQuadFXEmitterDrawEvent;
begin
  Result := FOnDraw;
end;

end.
