unit QuadEngine.TextureLoader;

interface

uses
  direct3d9, QuadEngine, Generics.Collections, sysutils, classes;

type
  TTextureSignature = array[0..31] of AnsiChar;

  TQuadCustomTextureFormat = class abstract
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; virtual; abstract;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; virtual; abstract;
  end;

  TQuadBMPTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadPNGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadTGATextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadJPGTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadRAWTextureFormat = class sealed(TQuadCustomTextureFormat)
    class function LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9; override;
    class function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadCustomTextureClass = class of TQuadCustomTextureFormat;

  TQuadTextureLoader = class
  private
    class var FFormats: TList<TQuadCustomTextureClass>;
  public
    class procedure Register(AQuadCustomTextureClass: TQuadCustomTextureClass);
    class function LoadFromFile(AFileName: string): IDirect3DTexture9;
    class function LoadFromStream(AStream: TStream): IDirect3DTexture9;
  end;

  TQ = (TQuadBMPTextureClass, TQuadPNGTextureClass, TQuadTGATextureClass, TQuadJPGTextureClass, TQuadRAWTextureClass);

implementation

uses
  QuadEngine.Device, graphics, VCL.Imaging.pngimage, VCL.Imaging.JPEG, QuadEngine.Utils;

{ TQuadJPGTextureFormat }

class function TQuadJPGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := (ASignature[6] = 'J') and (ASignature[7] = 'F') and (ASignature[8] = 'I') and (ASignature[9] = 'F');
end;

class function TQuadJPGTextureFormat.LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9;
var
  aData: TD3DLockedRect;
  bmp : TBitmap;
  jpg : TJPEGImage;
  i, j : Integer;
  p : Pointer;
  Width, Height: Integer;
  FrameWidth, FrameHeight: Integer;
begin
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  jpg.LoadFromStream(AStream);
  bmp.Assign(jpg);
  jpg.Free;

  Width := NormalizeSize(bmp.Width);
  Height := NormalizeSize(bmp.Height);

  FrameWidth := bmp.Width;
  FrameHeight := bmp.Height;

  Device.LastResultCode := Device.Render.D3DDevice.CreateTexture(Width, Height, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Result, nil);
  Device.LastResultCode := result.LockRect(0, aData, nil, 0);

  for I := 0 to FrameHeight - 1 do
  begin
    p:= bmp.ScanLine[i];
    for j:= 0 to FrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 3);
      Inc(NativeInt(aData.pBits), 3);
      Byte(aData.pBits^) := 255;
      Inc(NativeInt(aData.pBits), 1);
      Inc(NativeInt(p), 3);
    end;
    Inc(NativeInt(aData.pBits), 4 * (Width - FrameWidth));
  end;

  Device.LastResultCode := Result.UnlockRect(0);

  bmp.Free;
end;

{ TQuadRAWTextureFormat }

class function TQuadRAWTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := True;
end;

class function TQuadRAWTextureFormat.LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9;
begin

end;

{ TQuadTGATextureFormat }

class function TQuadTGATextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 16) = 'TRUEVISION-XFILE';
end;

class function TQuadTGATextureFormat.LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9;
begin

end;

{ TQuadPNGTextureFormat }

class function TQuadPNGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 2, 3) = 'PNG';
end;

class function TQuadPNGTextureFormat.LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9;
begin

end;

{ TQuadBMPTextureFormat }

class function TQuadBMPTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 2) = 'BM';
end;

class function TQuadBMPTextureFormat.LoadFromStream(AStream: TStream; ColorKey: Integer) : IDirect3DTexture9;
begin

end;

{ TQuadTextureLoader }

class function TQuadTextureLoader.LoadFromFile(AFileName: string): IDirect3DTexture9;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(AFileName);
  Result := LoadFromStream(Stream);
  FreeAndNil(Stream);
end;

class function TQuadTextureLoader.LoadFromStream(AStream: TStream): IDirect3DTexture9;
var
  tf: TQuadCustomTextureClass;
  Signature: TTextureSignature;
  res: Boolean;
begin
  AStream.Position := 0;
  AStream.Read(Signature[0], 31);

  res := False;

  for tf in FFormats do
  begin
    res := tf.CheckSignature(Signature);

    if res then
      Break;
  end;

  if not res then
    Exit;

  Result := tf.LoadFromStream(AStream, -1);

  FreeAndNil(AStream);
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
