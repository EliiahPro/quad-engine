unit QuadFX.EffectParamsLoader.CustomFormat;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes;

type
  TEffectSignature = array[0..31] of AnsiChar;

  TQuadFXCustomEffectFormatClass = class of TQuadFXCustomEffectFormat;

  TQuadFXCustomEffectFormat = class abstract
    class function CheckSignature(ASignature: TEffectSignature): Boolean; virtual; abstract;
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); virtual; abstract;
  end;

implementation

end.
