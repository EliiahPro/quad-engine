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
  Shader: IQuadShader;
  lightpos: TVec3f;
  VPM: packed array[0..15] of Single;
  LightUV: array[0..3] of Single;

  mList: TList;
  t: Double;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  i, j: Integer;
  vec: PParticle;
  mVec: PParticle;
  dX, dY: Integer;
begin
  QuadRender.BeginRender;
  QuadRender.Clear($0);
  QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  diff.Draw(TVec2f.Zero, $FF080808);

  t := t + delta;

  if t > 0.5 then
  begin
    t := 0;
    GetMem(Vec, sizeof(Tparticle));
    vec^.radius := random(250) / 1000 + 0.125;
    vec^.X := random(1024) / 160;
    vec^.Y := -1;
    vec^.Z := random(500) / 1500 + 0.05;
    vec^.color := random($FFFFFF) + $FF000000;
    mList.Add(vec);
  end;

  QuadRender.SetBlendMode(qbmSrcAlphaAdd);

  dX := 1024;
  dY := 1024;

  for i := 0 to mList.Count - 1 do
    begin
      mVec := mList.Items[i];

      mVec^.Y := mVec^.Y + delta / 2;

      lightpos := TVec3f.Create(mVec^.X * dX * mVec^.radius - 400 + dX * mVec^.radius / 2, mVec^.Y * dY * mVec^.radius + dY * mVec^.radius / 2 - 300, 0.5);
      lightUV[0] := mVec^.X * mVec^.radius + mVec^.radius / 2;
      lightUV[1] := mVec^.Y * mVec^.radius + mVec^.radius / 2;
      lightUV[2] := mVec^.Z;
      lightUV[3] := mVec^.radius;

      Shader.SetShaderState(True);
      Texture.DrawMap(TVec2f.Create(mVec^.X * dX * mVec^.radius, mVec^.Y * dY * mVec^.radius),
                      TVec2f.Create(mVec^.X * dX * mVec^.radius + dX * mVec^.radius, mVec^.Y * dY * mVec^.radius + dY * mVec^.radius),
                      TVec2f.Create((mVec^.X ) * mVec^.radius, (mVec^.Y ) * mVec^.radius),
                      TVec2f.Create((mVec^.X ) * mVec^.radius + mVec^.radius, (mVec^.Y ) * mVec^.radius + mVec^.radius),
                      mVec^.Color);
      Shader.SetShaderState(False);
      QuadRender.Rectangle(TVec2f.Create(mVec^.X * dX * mVec^.radius + dX * mVec^.radius / 2 - 2, mVec^.Y * dY * mVec^.radius + dY * mVec^.radius / 2 - 2),
                           TVec2f.Create(mVec^.X * dX * mVec^.radius + dX * mVec^.radius / 2 + 2, mVec^.Y * dY * mVec^.radius + dY * mVec^.radius / 2 + 2),
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
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False, qsm20);

  QuadDevice.CreateAndLoadTexture(0, 'data\Diffuse.jpg', diff);

  QuadDevice.CreateAndLoadTexture(0, 'data\Diffuse.jpg', Texture);
  Texture.LoadFromFile(1, 'data\Normal.jpg');
  Texture.LoadFromFile(2, 'data\Specular.jpg');
  Texture.LoadFromFile(3, 'data\Bump.jpg');

  QuadRender.SetAutoCalculateTBN(True);

  QuadDevice.CreateShader(Shader);
  Shader.LoadComplexShader('data\DefferedShading_vs.bin', 'data\DefferedShading_ps.bin');
  Shader.BindVariableToVS(4, @lightpos, 1);
  Shader.BindVariableToPS(5, @lightuv[0], 1);
 
  VPM[0] := 2 / 800;
  VPM[1] := 0;
  VPM[2] := 0;
  VPM[3] := 0;

  VPM[4] := 0;
  VPM[5] := -2 / 600;
  VPM[6] := 0;
  VPM[7] := 0;

  VPM[8] := 0;
  VPM[9] := 0;
  VPM[10] := 1;
  VPM[11] := 0;

  VPM[12] := -1;
  VPM[13] := 1;
  VPM[14] := 0;
  VPM[15] := 1;

  Shader.BindVariableToVS(0, @VPM, 4);  

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  mList := TList.Create;

  QuadWindow.Start;
end.
