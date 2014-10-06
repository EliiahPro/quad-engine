unit QuadEngine.TextureLoader;

interface

uses
  direct3d9, QuadEngine;

type
  TTextureSignature = array[0..31] of AnsiChar;

  TQuadCustomTextureFormat = class abstract
    procedure LoadFromFile(const aFilename: String;
      var Texture: IDirect3DTexture9; ColorKey: Integer); virtual; abstract;
    function CheckSignature(ASignature: TTextureSignature): Boolean; virtual; abstract;
  end;

  TQuadBMPTextureFormat = class sealed(TQuadCustomTextureFormat)
    procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadPNGTextureFormat = class sealed(TQuadCustomTextureFormat)
    procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadTGATextureFormat = class sealed(TQuadCustomTextureFormat)
    procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadJPGTextureFormat = class sealed(TQuadCustomTextureFormat)
    procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadRAWTextureFormat = class sealed(TQuadCustomTextureFormat)
    procedure LoadFromFile(const aFilename: string;
      var Texture: IDirect3DTexture9; ColorKey: Integer); override;
    function CheckSignature(ASignature: TTextureSignature): Boolean; override;
  end;

  TQuadTextureLoader = class
    function LoadFromFile: IQuadTexture;
  end;

implementation

{ TQuadJPGTextureFormat }

function TQuadJPGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := (ASignature[6] = 'J') and (ASignature[7] = 'F') and (ASignature[8] = 'I') and (ASignature[9] = 'F');
end;

procedure TQuadJPGTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadRAWTextureFormat }

function TQuadRAWTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := True;
end;

procedure TQuadRAWTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadTGATextureFormat }

function TQuadTGATextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 16) = 'TRUEVISION-XFILE';
end;

procedure TQuadTGATextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadPNGTextureFormat }

function TQuadPNGTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 2, 3) = 'PNG';
end;

procedure TQuadPNGTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

{ TQuadBMPTextureFormat }

function TQuadBMPTextureFormat.CheckSignature(ASignature: TTextureSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 2) = 'BM';
end;

procedure TQuadBMPTextureFormat.LoadFromFile(const aFilename: string;
  var Texture: IDirect3DTexture9; ColorKey: Integer);
begin

end;

end.
