unit QuadFX.FileLoader;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes, System.Json,
  QuadFX.FileLoader.CustomFormat, QuadFX.FileLoader.JSON;

type
  TQuadFXFileLoader = class
  private
    class var FFormats: TList<TQuadFXCustomFileFormatClass>;
  public
    class procedure Register(AQuadFXCustomFileFormatClass: TQuadFXCustomFileFormatClass);
    class procedure EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
    class procedure AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas);
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams;

{ TQuadFXEffectLoader }

class procedure TQuadFXFileLoader.EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  Signature: TEffectSignature;
  FileFormatClass: TQuadFXCustomFileFormatClass;
  FileFormat: TQuadFXCustomFileFormat;
begin
  AStream.Seek(0, soFromBeginning);
  AStream.Read(Signature[0], 31);

  for FileFormatClass in FFormats do
    if FileFormatClass.CheckSignature(Signature) then
    begin
      AStream.Seek(0, soFromBeginning);
      FileFormat := FileFormatClass.Create;
      try
        FileFormat.EffectLoadFromStream(AEffectName, AStream, AEffectParams);
      finally
        FileFormat.Free;
      end;
      Break;
    end;
end;

class procedure TQuadFXFileLoader.AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas);
var
  Signature: TEffectSignature;
  FileFormatClass: TQuadFXCustomFileFormatClass;
  FileFormat: TQuadFXCustomFileFormat;
begin
  AStream.Seek(0, soFromBeginning);
  AStream.Read(Signature[0], 31);

  for FileFormatClass in FFormats do
    if FileFormatClass.CheckSignature(Signature) then
    begin
      AStream.Seek(0, soFromBeginning);
      FileFormat := FileFormatClass.Create;

      try
        FileFormat.AtlasLoadFromStream(AAtlasName, AStream, AAtlas);
      finally
        FileFormat.Free;
      end;
      Break;
    end;

end;

class procedure TQuadFXFileLoader.Register(AQuadFXCustomFileFormatClass: TQuadFXCustomFileFormatClass);
begin
  if not Assigned(FFormats) then
    FFormats := TList<TQuadFXCustomFileFormatClass>.Create;
  FFormats.Add(AQuadFXCustomFileFormatClass);
end;

initialization

finalization
  if Assigned(TQuadFXFileLoader.FFormats) then
    TQuadFXFileLoader.FFormats.Free;

end.
