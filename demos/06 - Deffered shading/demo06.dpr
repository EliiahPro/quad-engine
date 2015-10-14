program demo06;

uses
  QuadEngine, Vec2f, Classes;

type
  PParticle = ^TParticle;
  TParticle = record
    X, Y, Z: Single;
    color: Cardinal;
    radius: Single;
  end;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  Texture: IQuadTexture;
  diff: IQuadTexture;
  lightpos: TVec3f;
  LightUV: array[0..3] of Single;
  QuadGBuffer: IQuadGBuffer;

  mList: TList;
  t: Double;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i, j: Integer;
  vec: PParticle;
  mVec: PParticle;
begin
  QuadRender.BeginRender;
  QuadRender.Clear($0);


  QuadRender.RenderToGBuffer(True, QuadGBuffer);
  QuadRender.SetBlendMode(qbmNone);
  Texture.Draw(TVec2f.Zero);
  QuadRender.RenderToGBuffer(False, QuadGBuffer);


  QuadGBuffer.DiffuseMap.Draw(TVec2f.Zero, $FF080808);

  t := t + delta;

  if t > 1.0 then
  begin
    t := 0;
    GetMem(Vec, SizeOf(Tparticle));
    vec^.radius := Random(250) / 1000 + 0.125;
    vec^.X := Random(800) / 800;
    vec^.Y := - 0.4;
    vec^.Z := Random(500) / 1500 + 0.05;
    vec^.color := Random($FFFFFF) + $FF000000;
    mList.Add(vec);
  end;

  QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  for i := 0 to mList.Count - 1 do
    begin
      mVec := mList.Items[i];

      mVec^.Y := mVec^.Y + delta / 10;

      QuadGBuffer.DrawLight(TVec3f.Create(mVec^.X, mVec.Y, mVec.Z), mVec^.radius, mVec^.color);

      QuadRender.Rectangle(TVec2f.Create(mVec^.X * 800 - 2, mVec^.Y * 600 - 2),
                           TVec2f.Create(mVec^.X * 800 + 2, mVec^.Y * 600 + 2),
                           mVec^.color);
      QuadRender.FlushBuffer;
    end;
    
  QuadRender.EndRender;
end;

begin
  Randomize;

  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine window demo');
  QuadWindow.SetSize(800, 600);
  QuadWindow.SetPosition(100, 100);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False, qsm30);

  QuadDevice.CreateAndLoadTexture(0, 'data\Diffuse.jpg', diff);

  QuadDevice.CreateAndLoadTexture(0, 'data\Diffuse.jpg', Texture);
  Texture.LoadFromFile(1, 'data\Normal.jpg');
  Texture.LoadFromFile(2, 'data\Specular.jpg');
  Texture.LoadFromFile(3, 'data\Bump.jpg');

  QuadDevice.CreateGBuffer(QuadGBuffer);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  mList := TList.Create;

  QuadWindow.Start;
end.
