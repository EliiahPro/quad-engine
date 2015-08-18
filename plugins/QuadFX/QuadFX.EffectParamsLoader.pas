unit QuadFX.EffectParamsLoader;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes, System.Json,
  QuadFX.EffectParamsLoader.CustomFormat, QuadFX.EffectParamsLoader.JSON;

type
  TQuadFXEffectLoader = class
  private
    class var FFormats: TList<TQuadFXCustomEffectFormatClass>;
  public
    class procedure Register(AQuadFXCustomEffectFormatClass: TQuadFXCustomEffectFormatClass);
    class procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams;

{ TQuadFXEffectLoader }

class procedure TQuadFXEffectLoader.LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  Signature: TEffectSignature;
  EffectClass: TQuadFXCustomEffectFormatClass;
  EffectFormat: TQuadFXCustomEffectFormat;
begin
  AStream.Seek(0, soFromBeginning);
  AStream.Read(Signature[0], 31);

  for EffectClass in FFormats do
    if EffectClass.CheckSignature(Signature) then
    begin
      AStream.Seek(0, soFromBeginning);
      EffectFormat := EffectClass.Create;
      try
        EffectFormat.LoadFromStream(AEffectName, AStream, AEffectParams);
      finally
        EffectFormat.Free;
      end;
      Break;
    end;
end;

class procedure TQuadFXEffectLoader.Register(AQuadFXCustomEffectFormatClass: TQuadFXCustomEffectFormatClass);
begin
  FFormats.Add(AQuadFXCustomEffectFormatClass);
end;

initialization
  TQuadFXEffectLoader.FFormats := TList<TQuadFXCustomEffectFormatClass>.Create;
  TQuadFXEffectLoader.Register(TQuadFXJSONEffectFormat);

finalization
  TQuadFXEffectLoader.FFormats.Free;

end.
