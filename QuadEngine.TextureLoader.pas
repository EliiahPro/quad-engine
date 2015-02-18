unit QuadEngine.TextureLoader;

interface

uses
  direct3d9, QuadEngine, Generics.Collections, sysutils;

type
  TTextureSignature = array[0..31] of AnsiChar;

  TQuadCustomTextureFormat = class abstract
    class procedure LoadFromFile(const aFilename: String;
      var Texture: IDirect3DTexture9; ColorKey: Integer); virtual; abstract;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; virtual; abstract;
  end;

  TQuadBMPTextureFormat = class sealed(TQuadCustomTextureFormat)
    class procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadPNGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadTGATextureFormat = class sealed(TQuadCustomTextureFormat)
    class procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadJPGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadRAWTextureFormat = class sealed(TQuadCustomTextureFormat)
    class procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadCustomTextureClass = class of TQuadCustomTextureFormat;

  TQuadTextureLoader = class
  private
    class var FFormats: TList<TQuadCustomTextureClass>;
  public
    class procedure Register(AQuadCustomTextureClass: TQuadCustomTextureClass);
    class function LoadFromFile(AFileName: string): IQuadTexture;
  end;

  TQ = (TQuadBMPTextureClass, TQuadPNGTextureClass, TQuadTGATextureClass, TQuadJPGTextureClass, TQuadRAWTextureClass);

implementation

uses
  QuadEngine.Device;

{ TQuadJPGTextureFormat }

class function TQuadJPGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := (ASignature[6] = 'J') and (ASignature[7] = 'F') and (ASignature[8] = 'I') and (ASignature[9] = 'F');
end;

class procedure TQuadJPGTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadRAWTextureFormat }

class function TQuadRAWTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := True;
end;

class procedure TQuadRAWTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadTGATextureFormat }

class function TQuadTGATextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 16) = 'TRUEVISION-XFILE';
end;

class procedure TQuadTGATextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadPNGTextureFormat }

class function TQuadPNGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 2, 3) = 'PNG';
end;

class procedure TQuadPNGTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadBMPTextureFormat }

class function TQuadBMPTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 2) = 'BM';
end;

class procedure TQuadBMPTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadTextureLoader }

class function TQuadTextureLoader.LoadFromFile(AFileName: string): IQuadTexture;
var
  tf: TQuadCustomTextureClass;
  Signature: TTextureSignature;
  res: Boolean;
  f: file;
begin
  AssignFile(f, AFilename);
  Reset(f, 1);
  BlockRead(f, Signature[0], 31);
  CloseFile(f);

  for tf in FFormats do
  begin
    res := tf.CheckSignature(Signature);

    if res then
      Break;
  end;

  if not res then
    Exit;
end;

class procedure TQuadTextureLoader.Register(AQuadCustomTextureClass: TQuadCustomTextureClass);
begin
  FFormats.Add(AQuadCustomTextureClass);
end;

initialization
  TQuadTextureLoader.FFormats := TList<TQuadCustomTextureClass>.Create;
  TQuadTextureLoader.Register(TQuadBMPTextureFormat);
  TQuadTextureLoader.Register(TQuadPNGTextureFormat);
  TQuadTextureLoader.Register(TQuadTGATextureFormat);
  TQuadTextureLoader.Register(TQuadJPGTextureFormat);
  TQuadTextureLoader.Register(TQuadRAWTextureFormat);

finalization
  TQuadTextureLoader.FFormats.Free;

end.
