program demo06;

uses
  QuadEngine, Vec2f, Classes, Windows, System.SysUtils;

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
  QuadInput: IQuadInput;
  Texture: IQuadTexture;
  Camera: IQuadCamera;
  diff: IQuadTexture;
  //lightpos: TVec3f;
  //LightUV: array[0..3] of Single;
  QuadGBuffer: IQuadGBuffer;

  mList: TList;
  t: Double;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i, j: Integer;
  vec: PParticle;
  mVec: PParticle;
  DiffuseMap: IQuadTexture;
begin
  QuadInput.Update;

  if QuadInput.IsKeyDown(VK_LEFT) then
    Camera.Translate(TVec2f.Create(-3, 0));

  if QuadInput.IsKeyDown(VK_RIGHT) then
    Camera.Translate(TVec2f.Create(3, 0));

  if QuadInput.IsKeyDown(VK_DOWN) then
    Camera.Translate(TVec2f.Create(0, -3));

  if QuadInput.IsKeyDown(VK_UP) then
    Camera.Translate(TVec2f.Create(0, 3));

  if QuadInput.IsKeyDown(VK_F1) then
    Camera.Rotate(-1);
  if QuadInput.IsKeyDown(VK_F4) then
    Camera.Rotate(1);

  if QuadInput.IsKeyDown(VK_F5) then
    Camera.Scale(0.5);
  if QuadInput.IsKeyDown(VK_F6) then
    Camera.Scale(0.75);
  if QuadInput.IsKeyDown(VK_F7) then
    Camera.Scale(1.0);
  if QuadInput.IsKeyDown(VK_F8) then
    Camera.Scale(2.0);


  QuadRender.BeginRender;
  QuadRender.Clear($0);

  Camera.Enable;
  QuadRender.RenderToGBuffer(True, QuadGBuffer);
  QuadRender.SetBlendMode(qbmNone);
  Texture.Draw(TVec2f.Zero);
  QuadRender.RenderToGBuffer(False, QuadGBuffer);
  Camera.Disable;

  QuadGBuffer.GetDiffuseMap(DiffuseMap);
  DiffuseMap.Draw(TVec2f.Zero, $FF080808);

  t := t + delta;

  if t > 1.0 then
  begin
    t := 0;
    GetMem(Vec, SizeOf(Tparticle));
    vec^.radius := Random(200) + 50;
    vec^.X := Random(800);
    vec^.Y := - 100;
    vec^.Z := Random(30) + 5;
    vec^.color := Random($FFFFFF) + $FF000000;
    mList.Add(vec);
  end;

  QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  for i := 0 to mList.Count - 1 do
    begin
      mVec := mList.Items[i];

      mVec^.Y := mVec^.Y + delta * 100;

      QuadGBuffer.DrawLight(TVec2f.Create(mVec^.X, mVec.Y), mVec.Z, mVec^.radius, mVec^.color);

      Camera.Enable;
      QuadRender.Rectangle(TVec2f.Create(mVec^.X - 2, mVec^.Y - 2),
                           TVec2f.Create(mVec^.X + 2, mVec^.Y + 2),
                           mVec^.color);
      Camera.Disable;

      QuadRender.FlushBuffer;
    end;

  QuadRender.EndRender;
end;

begin
  Randomize;

  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo06 - Deffered shading');
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

  QuadDevice.CreateCamera(Camera);

  QuadWindow.CreateInput(QuadInput);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  mList := TList.Create;

  QuadWindow.Start;
end.
