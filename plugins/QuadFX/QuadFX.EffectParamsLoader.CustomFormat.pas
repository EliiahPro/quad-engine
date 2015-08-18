unit QuadFX.EffectParamsLoader.CustomFormat;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes;

type
  TEffectSignature = array[0..31] of AnsiChar;

  TQuadFXCustomEffectFormatClass = class of TQuadFXCustomEffectFormat;

  TQuadFXCustomEffectFormat = class abstract
  protected
    FPackName: WideString;
    FEffectName: WideString;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; virtual; abstract;
    constructor Create;
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); virtual; abstract;
  end;

implementation

constructor TQuadFXCustomEffectFormat.Create;
begin
  FPackName := '';
  FEffectName := '';
end;

end.
