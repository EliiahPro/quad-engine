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
    Camera.SetScale(0.5);
  if QuadInput.IsKeyDown(VK_F6) then
    Camera.SetScale(0.75);
  if QuadInput.IsKeyDown(VK_F7) then
    Camera.SetScale(1.0);
  if QuadInput.IsKeyDown(VK_F8) then
    Camera.SetScale(2.0);


  QuadRender.BeginRender;
  QuadRender.Clear($0);

  Camera.Enable;
  QuadRender.RenderToGBuffer(True, QuadGBuffer);
  QuadRender.SetBlendMode(qbmNone);
  Texture.Draw(TVec2f.Zero);
  Texture.Draw(TVec2f.Create(1024, 0));
  Texture.Draw(TVec2f.Create(-1024, 0));
  Texture.Draw(TVec2f.Create(0, 1024));
  Texture.Draw(TVec2f.Create(0, -1024));
//  QuadRender.RenderToGBuffer(False, QuadGBuffer);
  Camera.Disable;

  QuadRender.RenderToBackBuffer;

  QuadRender.SetBlendMode(qbmNone);
  QuadGBuffer.GetDiffuseMap(DiffuseMap);
  DiffuseMap.Draw(TVec2f.Zero, $FF999999);

  t := t + delta;

  if t > 0.5 then
  begin
    t := 0;
    GetMem(Vec, SizeOf(Tparticle));
    vec^.radius := Random(300) + 100;
    vec^.X := Random(1280);
    vec^.Y := - 100;
    vec^.Z := 10.0;//Random(30) + 5;
    vec^.color := Random($FFFFFF) + $FF000000;
    mList.Add(vec);
  end;

  QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  QuadGBuffer.DrawLight(TVec2f.Create(640, 400), 0, 1280, $FF444444);

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
    end;

  QuadRender.EndRender;

  QuadWindow.SetCaption(PWideChar(FloatToStr(QuadTimer.GetFPS)));
end;

begin
  Randomize;

  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo06 - Deffered shading');
  QuadWindow.SetSize(1280, 800);
  QuadWindow.SetPosition(100, 100);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 1280, 800, False, qsm30);

  QuadDevice.CreateAndLoadTexture(0, 'data\Diffuse.jpg', Texture);
  Texture.LoadFromFile(1, 'data\Normal.jpg');
  Texture.LoadFromFile(2, 'data\Specular.jpg');

  QuadDevice.CreateGBuffer(QuadGBuffer);
  QuadRender.SetAutoCalculateTBN(True);

  QuadDevice.CreateCamera(Camera);

  QuadWindow.CreateInput(QuadInput);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 0, True);

  mList := TList.Create;

  QuadWindow.Start;
end.
