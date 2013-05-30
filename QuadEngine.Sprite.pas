//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================

unit QuadEngine.Sprite;

interface

uses
  QuadEngine.Render, QuadEngine.Texture, QuadEngine, vec2f;

type
  TQuadSprite = class(TInterfacedObject, IQuadSprite)
  private
//    FTexture : IQuadTexture;
//    FPosition : TVec2f;
//    FVelocity : TVec2f;
//    FAngle : Single;
//    FScale : Single;
  public
    constructor Create(aTexture : IQuadTexture);
    procedure SetPosition(X, Y : double); stdcall;
    procedure SetVelocity(X, Y : double); stdcall;    
    procedure Draw; stdcall;
  end;

implementation

{ TQuadSprite }

constructor TQuadSprite.Create(aTexture : IQuadTexture);
begin

end;

procedure TQuadSprite.Draw;
begin

end;

procedure TQuadSprite.SetPosition(X, Y: double);
begin

end;

procedure TQuadSprite.SetVelocity(X, Y: double);
begin

end;

end.
