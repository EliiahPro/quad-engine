unit QuadFX.LayerEffectProxy;

interface

uses
  Vec2f;

type
  ILayerEffectProxy = interface
  ['{FE55A7E0-DF3F-4248-82FD-2F623234506D}']
    function GetGravitation: TVec2f;
  end;

  TLayerEffectProxy = class(TInterfacedObject, ILayerEffectProxy)
  private
    FGravitation: TVec2f;
    function GetGravitation: TVec2f; inline;
  public
    property Gravitation: TVec2f read FGravitation write FGravitation;
  end;


implementation


function TLayerEffectProxy.GetGravitation: TVec2f;
begin
  Result := FGravitation;
end;

end.
