unit QuadFX.EffectParamsLoader.CustomFormat;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes;

type
  TEffectSignature = array[0..31] of AnsiChar;

  TQuadFXCustomEffectFormatClass = class of TQuadFXCustomEffectFormat;

  TQuadFXCustomEffectFormat = class abstract
  private
    FIsLoadTexture: Boolean;
    FEffectParams: IQuadFXEffectParams;
  protected
    FPackName: WideString;
    FEffectName: WideString;
    property IsLoadTexture: Boolean read FIsLoadTexture;
    property EffectParams: IQuadFXEffectParams read FEffectParams;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; virtual; abstract;
    constructor Create(AEffectParams: IQuadFXEffectParams; AIsLoadTexture: Boolean = True);
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream); virtual; abstract;
  end;

implementation

constructor TQuadFXCustomEffectFormat.Create(AEffectParams: IQuadFXEffectParams; AIsLoadTexture: Boolean = True);
begin
  FPackName := '';
  FEffectName := '';
  FEffectParams := AEffectParams;
  FIsLoadTexture := AIsLoadTexture;
end;

end.
