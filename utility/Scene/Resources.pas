unit Resources;

interface

uses
  QuadEngine, Vec2f, QuadEngine.Color, CustomScene, System.Generics.Collections;

type
  TGlobals = class sealed
  class var
    QuadDevice: IQuadDevice;
    QuadRender: IQuadRender;
    QuadTimer: IQuadTimer;
    QuadCamera: IQuadCamera;
    QuadScene: TCustomScene;
    Cursor: IQuadTexture;
    Textures: TList<IQuadTexture>;
  class procedure AddTexture(Filename: string);
  end;

implementation

{ TGlobals }

class procedure TGlobals.AddTexture(Filename: string);
var
  tex: IQuadTexture;
begin
  QuadDevice.CreateAndLoadTexture(0, PWideChar(Filename), tex);
  Textures.Add(tex);
end;

initialization
  TGlobals.Textures := TList<IQuadTexture>.Create;

finalization
  TGlobals.Textures.Free;

end.
