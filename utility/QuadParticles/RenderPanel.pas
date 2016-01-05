unit RenderPanel;

interface

uses
  Winapi.Windows, Vcl.ExtCtrls, System.Classes, Vcl.Controls, System.Generics.Collections,
  QuadEngine, Vec2f, System.SysUtils, System.Variants, Winapi.Messages, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, QuadFX, QuadFX.Manager, QuadEngine.Color,
  QPTreeNode, QuadFX.Helpers;

type
  TRenderPanel = class;

  TRenderPanelDelayType = (
    rpdtRefresh = 0,
    rpdtDraw = 1
  );

  TBackgroundType = (
    btBlack = 0,
    btWhite = 1,
    btImage = 2,
    btColor = 3
  );

  TRenderPanelEvent = procedure(ADelay: TRenderPanelDelayType) of object;
  TRenderPanelPaintEvent = procedure of object;

  TRenderPanel = class(TPanel)
  private
    FMousePosition: TVec2f;
    FMouseOldPosition: TVec2f;
    FMouseCameraDrag: Boolean;

    FPlay: Boolean;
    FLoop: Boolean;
    FAction: Boolean;
    FTimerAction: Boolean;
    FIsFPS: Boolean;
    FIsShapeDraw: Boolean;
    FQuadDevice: IQuadDevice;
    FQuadRender: IQuadRender;
    FQuadTimer: IQuadTimer;
    FQuadCamera: IQuadCamera;
    FOnDelay: TRenderPanelEvent;
    FOnPaint: TRenderPanelPaintEvent;

    FBackground: array[0..2] of IQuadTexture;
    FBackgroundColor: TQuadColor;
    FFont: IQuadFont;
    FZoom: Single;

    FQuadFXManager: IQuadFXManager;
    FQuadFXLayer: IQuadFXLayer;
    FQuadFXEffectParams: IQuadFXEffectParams;
    FEffect: IQuadFXEffect;
    FEmitter: IQuadFXEmitter;

    FBackgroundType: TBackgroundType;
    class var FRenderPanel: TRenderPanel;
    procedure QuadDestroy;
    procedure QuadInit;
  protected
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure Paint; override;
    procedure EffectProcess(const Delta: Double);
    procedure SetAction(const Value: Boolean);
    procedure MouseWheel(var AMessage: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure ReDraw;
  public
    class var CriticalSection: TRTLCriticalSection;
    class procedure Process(ADelta: Double);
    constructor CreateEx(AOwner: TWinControl; AOnDelay: TRenderPanelEvent = nil; AOnPaint: TRenderPanelPaintEvent = nil);
    destructor Destroy; override;
    procedure ReInit(AOwner: TWinControl);
    procedure Play;
    procedure Pause;
    procedure Restart(ATime: Single = 0);
    procedure Loop(AEnable: Boolean);

    procedure OnRenderProcess(ADelta: Double);
    procedure SetBackgroundImage(AFileName: String);
    procedure SetBackgroundColor(AColor: TQuadColor);
    procedure SetBackgroundType(AType: TBackgroundType);
    procedure SetEffect(AEffectParams: IQuadFXEffectParams; AEffect: IQuadFXEffect; AEmitter: IQuadFXEmitter);
    function LoadTexture(AFileName: String; ARegister: Byte = 0): IQuadTexture;
    procedure EmitterDraw(AEmitterNode: TEmitterNode; AShapeDraw: Boolean = false);
    procedure WaitTimer;
 //  AEmitter: IQPEmitter; AParticles: PQPParticle; AParticleCount: Integer; AShapeDraw: Boolean = false);
    class function NewInstance: TObject; override;
    property QuadRender: IQuadRender read FQuadRender;
    property QuadDevice : IQuadDevice read FQuadDevice;
    property Action: Boolean read FAction write SetAction;
    property IsFPS: Boolean read FIsFPS write FIsFPS;
    property IsShapeDraw: Boolean read FIsShapeDraw write FIsShapeDraw;

    property Layer: IQuadFXLayer read FQuadFXLayer;
    property Manager: IQuadFXManager read FQuadFXManager;
    property EffectParams: IQuadFXEffectParams read FQuadFXEffectParams;
    property Effect: IQuadFXEffect read FEffect;
  end;

implementation

uses
  QuadFX.EffectParams, Math, QuadFX.Emitter, Textures,
  Vcl.Dialogs, QuadFX.Effect, Main;

procedure RenderUpdateAll(out delta: Double; Id: Cardinal); stdcall;
begin
  TRenderPanel.Process(delta);
end;

procedure TRenderPanel.SetAction(const Value: Boolean);
begin
  if FAction = Value then
    Exit;

  FAction := Value;
end;

procedure TRenderPanel.MouseWheel(var AMessage: TWMMouseWheel);
begin
  if (AMessage.WheelDelta > 0) and (FZoom > 0.1) then
    FZoom := FZoom * 0.95
  else
    if (AMessage.WheelDelta < 0) and (FZoom < 20) then
      FZoom := FZoom * 1.05;

  FQuadCamera.Scale(FZoom);
end;

procedure TRenderPanel.WaitTimer;
begin
  // Это просто безумие!
  // Безумие? Это СПАРТА!!!!!
  FTimerAction := True;
  FAction := False;
  while FTimerAction and not Action do
    Application.ProcessMessages;
end;

procedure TRenderPanel.Play;
begin
  FPlay := True;
end;

procedure TRenderPanel.Pause;
begin
  FPlay := False;
end;

procedure TRenderPanel.Restart(ATime: Single = 0);
begin
  if Assigned(FEffect) then
  begin
    TQuadFXEffect(FEffect).ToLife(ATime);
    EffectProcess(0);
  end;
end;

procedure TRenderPanel.Loop(AEnable: Boolean);
begin
  FLoop := AEnable;
end;

procedure TRenderPanel.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);
begin
  FMousePosition := TVec2f.Create(X, Y);
  if FMouseCameraDrag then
    FQuadCamera.Translate((FMouseOldPosition - FMousePosition) / FZoom);

  FMouseOldPosition := FMousePosition;
end;

procedure TRenderPanel.SetEffect(AEffectParams: IQuadFXEffectParams; AEffect: IQuadFXEffect; AEmitter: IQuadFXEmitter);
begin
  FQuadFXEffectParams := AEffectParams;
  FEffect := AEffect;
  FEmitter := AEmitter;
end;

procedure TRenderPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  FMouseOldPosition := TVec2f.Create(X, Y);
  if Button = TMouseButton.mbRight then
    FMouseCameraDrag := True;
  Cursor := crSize;
end;

procedure TRenderPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  if Button = TMouseButton.mbRight then
    FMouseCameraDrag := False;
    Cursor := crDefault;
end;

procedure TRenderPanel.SetBackgroundImage(AFileName: String);
begin
  FBackground[2] := nil;
  if AFileName = '' then
    Exit;

  FBackground[2] := LoadTexture(AFileName, 0);
  if Assigned(FBackground[2]) then
    FBackgroundType := btImage
  else
    FBackgroundType := btBlack;
end;

procedure TRenderPanel.SetBackgroundColor(AColor: TQuadColor);
begin
  FBackgroundColor := AColor;
  FBackgroundType := btColor;
end;

procedure TRenderPanel.SetBackgroundType(AType: TBackgroundType);
begin
  FBackgroundType := AType;
  if (FBackgroundType = btImage) and not Assigned(FBackground[2]) then
    FBackgroundType := btBlack;
end;

class procedure TRenderPanel.Process(ADelta: Double);
begin
  if Assigned(FRenderPanel) then
    FRenderPanel.OnRenderProcess(ADelta);
end;

procedure TRenderPanel.OnRenderProcess(ADelta: Double);
  procedure DrawBackground;
  var
    X, Y, W, H: Integer;
    Cam: TVec2f;
    Tex: IQuadTexture;
    CameraPosition: TVec2f;
  begin
    if not FAction then
      Exit;

    if (FBackgroundType <> btColor) then
    begin
      Tex := FBackground[Integer(FBackgroundType)];
      if Assigned(Tex) then
      begin
        W := Tex.GetSpriteWidth;
        H := Tex.GetSpriteHeight;
        FQuadCamera.GetPosition(CameraPosition);
        Cam := CameraPosition * FZoom;
        Cam := TVec2f.Create(
          Round(Cam.X - Trunc(Cam.X / W) * W),
          Round(Cam.Y - Trunc(Cam.Y / H) * H)
        );
        FQuadRender.SetBlendMode(qbmNone);

        for Y := -1 to Height div H + 1 do
          for X := -1 to Width div W + 1 do
            Tex.Draw(TVec2f.Create(X * W, Y * H) - Cam);
      end
      else
        FQuadRender.Rectangle(TVec2f.Create(-10, -10), TVec2f.Create(Width + 10, Height + 10), $FF464646);
    end
    else
    begin
      FQuadRender.Rectangle(TVec2f.Create(-10, -10), TVec2f.Create(Width + 10, Height + 10), FBackgroundColor);
    end;
  end;
begin
  EnterCriticalSection(CriticalSection);
  try
    if FAction and Assigned(FQuadTimer) and Assigned(FQuadRender) then
    begin
      if Assigned(FOnDelay) then
        FOnDelay(rpdtRefresh);

      FQuadRender.BeginRender;
      FQuadRender.Clear(0);
      DrawBackground;
      FQuadCamera.Enable;

      EffectProcess(ADelta);
      if Assigned(FOnDelay) then
        FOnDelay(rpdtDraw);
      //EffectDraw;

      FQuadCamera.Disable;
      if FIsFPS then
      begin
        FQuadRender.SetBlendMode(qbmSrcAlpha);
        FFont.TextOut(TVec2f.Create(8, 5), 1, PWideChar(format('FPS: %f', [FQuadTimer.GetFPS])));
        FFont.TextOut(TVec2f.Create(8, 18), 1, PWideChar(format('CPU: %f', [FQuadTimer.GetCPUload])));
      end;

      FQuadRender.EndRender;

      if Assigned(FEffect) and not TQuadFXEffect(FEffect).Action then
      begin
        Restart;
        if not FLoop then
          Pause;
      end;
    end
    else
      if FTimerAction then
        FTimerAction := False;

  finally
    LeaveCriticalSection(CriticalSection);

    fMain.ListBox1.Items.Insert(0, 'Draw End');
  end;
  if Assigned(FOnPaint) then
    ReDraw;
end;

procedure TRenderPanel.ReDraw;
begin
  if Assigned(FOnPaint) then
    FOnPaint;
end;

procedure TRenderPanel.Paint;
begin
//  inherited;
end;

constructor TRenderPanel.CreateEx(AOwner: TWinControl; AOnDelay: TRenderPanelEvent = nil; AOnPaint: TRenderPanelPaintEvent = nil);
begin
  inherited Create(AOwner);
  FZoom := 1;
  Parent := AOwner;
  FAction := True;
  FIsFPS := True;
  FIsShapeDraw := True;
  FOnDelay := AOnDelay;
  FOnPaint := AOnPaint;
  Align := alClient;
  QuadInit;
  FLoop := True;
  FPlay := True;
end;

destructor TRenderPanel.Destroy;
begin
  QuadDestroy;
  inherited;
end;

procedure TRenderPanel.ReInit(AOwner: TWinControl);
begin
  Parent := AOwner;
  QuadDestroy;
  QuadInit;
end;

procedure TRenderPanel.QuadDestroy;
begin
  Action := False;
  WaitTimer;

  if Assigned(FQuadTimer) then
    FQuadTimer.SetState(False);

  FQuadTimer := nil;
  FBackground[0] := nil;
  FBackground[1] := nil;
  FBackground[2] := nil;
  FQuadFXLayer := nil;
  FQuadFXEffectParams := nil;
  FQuadFXLayer := nil;
  FQuadFXManager := nil;
  FQuadCamera := nil;
  FQuadRender := nil;
  FQuadDevice := nil;
end;

procedure TRenderPanel.QuadInit;
var
  ResStream: TResourceStream;
  Texture: IQuadTexture;
begin
  FQuadDevice := CreateQuadDevice;
  FQuadDevice.CreateRender(FQuadRender);
  FQuadRender.Initialize(Handle, Parent.Width, Parent.Height, False);

  ResStream := TResourceStream.Create(hInstance, 'FontConsoleTex', RT_RCDATA);
  try
    FQuadDevice.CreateTexture(Texture);
    Texture.LoadFromStream(0, ResStream.Memory, ResStream.Size);
  finally
    ResStream.Free;
  end;

  ResStream := TResourceStream.Create(hInstance, 'FontConsole', RT_RCDATA);
  try
    FQuadDevice.CreateFont(FFont);
    FFont.LoadFromStream(ResStream.Memory, ResStream.Size, Texture);
  finally
    ResStream.Free;
  end;

  //FQuadDevice.CreateAndLoadFont(PWideChar('Data\quad.png'), PWideChar('Data\quad.qef'), FFont);
  //FQuadDevice.CreateAndLoadFont(PWideChar('Data\console.bmp'), PWideChar('Data\console.qef'), FFont);

  FFont.SetIsSmartColoring(True);
  FQuadRender.SetAutoCalculateTBN(False);
  FQuadDevice.CreateCamera(FQuadCamera);
  FQuadCamera.Translate(-TVec2f.Create(Width div 2, Height div 2));

  ResStream := TResourceStream.Create(hInstance, 'Background', RT_RCDATA);
  try
    FQuadDevice.CreateTexture(FBackground[0]);
    FBackground[0].LoadFromStream(0, ResStream.Memory, ResStream.Size);
  finally
    ResStream.Free;
  end;

  ResStream := TResourceStream.Create(hInstance, 'Background1', RT_RCDATA);
  try
    FQuadDevice.CreateTexture(FBackground[1]);
    FBackground[1].LoadFromStream(0, ResStream.Memory, ResStream.Size);
  finally
    ResStream.Free;
  end;

  //FBackground[0] := LoadTexture('Data\Background.png', 0);
  //FBackground[1] := LoadTexture('Data\Background1.png', 0);
  FBackground[2] := nil;

  QuadFX.Manager.Manager := TQuadFXManager.Create(FQuadDevice);
  FQuadFXManager := QuadFX.Manager.Manager;
  FQuadFXManager.CreateLayer(FQuadFXLayer);
                 {
  FQPManager.CreateEffectParams(FQPEffectParams);

  TQPEffectParams(FQPEffectParams).LoadFromFile(nil);

  FTextures.Clear;
  for i := 0 to FQuadFXEffectParams.EmitterParamsCount - 1 do
  begin
    FQuadFXEffectParams.EmitterParams[0].TextureID := i;
    FQuadDevice.CreateAndLoadTexture(0, PWideChar(FQuadFXEffectParams.EmitterParams[0].TextureFileName), Texture,
      FQuadFXEffectParams.EmitterParams[0].TextureParams.FrameWidth, FQuadFXEffectParams.EmitterParams[0].TextureParams.FrameHeight);
    FTextures.Add(Texture);
  end;

  FQPLayer.CreateEffect(FQuadFXEffectParams, TVec2f.Zero, FEffect);   }
  //FQPLayer.SetOnDraw(EmitterDraw);

  FQuadDevice.CreateTimer(FQuadTimer);
  FQuadTimer.SetInterval(16);
  FQuadTimer.SetCallBack(RenderUpdateAll);
  FQuadTimer.SetState(True);
end;

procedure TRenderPanel.Resize;
begin
  inherited;

  if FAction and Assigned(FQuadRender) then
  begin
    //FQuadRender.ChangeResolution(Width, Height);
    //QuadDestroy;
    //QuadInit;
  end;
end;

function TRenderPanel.LoadTexture(AFileName: String; ARegister: Byte = 0): IQuadTexture;
begin
  FQuadDevice.CreateAndLoadTexture(ARegister, PWideChar(AFileName), Result);
end;

class function TRenderPanel.NewInstance: TObject;
begin
  if FRenderPanel = nil then
    FRenderPanel := TRenderPanel(inherited NewInstance);

  Result := FRenderPanel;
end;

procedure TRenderPanel.EffectProcess(const Delta: Double);
begin
  if FPlay and Assigned(FEffect) then
    FEffect.Update(Delta);
end;

procedure TRenderPanel.EmitterDraw(AEmitterNode: TEmitterNode; AShapeDraw: Boolean = false);
  procedure DrawLine(const APointA, APointB: TVec2f; AColor: Cardinal = $FFFF0000; AWidth: Single = 1);
  begin
    FQuadRender.DrawQuadLine(APointA, APointB, AWidth, AWidth, AColor, AColor);
  end;

  procedure DrawRectAngle(Center, Size: TVec2f; AAngle: Single = 0; AColor: Cardinal = $FFFF0000; AWidth: Single = 1);
  var
    Vector, p: TVec2f;
  begin
    Vector := TVec2f.Create(cos(AAngle), sin(AAngle));

    p := Center - Vector * Size.X / 2 - Vector.Normal * Size.Y / 2;
    DrawLine(P, P + Vector * Size.X, AColor, AWidth);
    DrawLine(P, P + Vector.Normal * Size.Y, AColor, AWidth);

    p := Center + Vector * Size.X / 2 + Vector.Normal * Size.Y / 2;
    DrawLine(P, P - Vector * Size.X, AColor, AWidth);
    DrawLine(P, P - Vector.Normal * Size.Y, AColor, AWidth);
  end;

  procedure DrawRect(ALeftTop, ARightBottom: TVec2f; AColor: Cardinal = $FFFF0000; AWidth: Single = 1);
  begin
    DrawLine(ALeftTop, TVec2f.Create(ARightBottom.X, ALeftTop.Y), AColor, AWidth);
    DrawLine(TVec2f.Create(ARightBottom.X, ALeftTop.Y), ARightBottom, AColor, AWidth);
    DrawLine(ARightBottom, TVec2f.Create(ALeftTop.X, ARightBottom.Y), AColor, AWidth);
    DrawLine(TVec2f.Create(ALeftTop.X, ARightBottom.Y), ALeftTop, AColor, AWidth);
  end;

  procedure DrawCircle(const APoint: TVec2f; Const ARadius: Single; AColor: Cardinal = $FFFF0000; AWidth: Single = 1);
  var
    i, Q: Integer;
    Rad: Single;
    OldPoint, NewPoint: Tvec2f;
  begin
    Q := Round(2 * Pi * ARadius) div Max(5, Round(ARadius / 5));
    Rad := Pi / (Q / 2);
    OldPoint := APoint + Tvec2f.Create(ARadius, 0);
    for i := 0 to Q do
    begin
      NewPoint := APoint + Tvec2f.Create(Cos(Rad * i), Sin(Rad * i)) * ARadius;
      FQuadRender.DrawQuadLine(OldPoint, NewPoint, AWidth, AWidth, AColor, AColor);
      OldPoint := NewPoint;
    end;
  end;

  procedure DrawArc(const APoint: TVec2f; Const ARadius, ADirection, ASpread: Single; AColor: Cardinal = $FFFF0000; AWidth: Single = 1);
  var
    i, Q: Integer;
    Rad: Single;
    OldPoint, NewPoint: Tvec2f;
    StartAngle: Single;
  begin
    Q := Round(ASpread * ARadius) div Max(5, Round(ARadius / 5));
    Rad := ASpread / Q;
    StartAngle := ADirection - ASpread / 2;
    OldPoint := APoint + Tvec2f.Create(Cos(StartAngle), Sin(StartAngle)) * ARadius;
    for i := 1 to Q do
    begin
      NewPoint := APoint + Tvec2f.Create(Cos(StartAngle + Rad * i), Sin(StartAngle + Rad * i)) * ARadius;
      FQuadRender.DrawQuadLine(OldPoint, NewPoint, AWidth, AWidth, AColor, AColor);
      OldPoint := NewPoint;
    end;
  end;
var
  AParams: PQuadFXEmitterParams;
  Vec: TVec2f;
  Angle: Single;
  Emitter: TQuadFXEmitter;
  Speed: Single;
begin
  if not Assigned(AEmitterNode) or not AEmitterNode.Visible or not Assigned(AEmitterNode.Emitter) then
    Exit;
  Emitter := TQuadFXEmitter(AEmitterNode.Emitter);

  Emitter.Draw;

  FQuadRender.SetBlendMode(qbmSrcAlpha);

  AParams := AEmitterNode.EmitterParams;
  if not Assigned(AParams) then
    Exit;

  FQuadCamera.Disable;
  if Assigned(FEffect) then
  begin
    FFont.TextOut(TVec2f.Create(300, 8), 1, PWideChar(format('Life: %f', [TQuadFXEffect(FEffect).Life])));
    if TQuadFXEffect(FEffect).Action then
      FFont.TextOut(TVec2f.Create(150, 8), 1, PWideChar('Action: True'))
    else
      FFont.TextOut(TVec2f.Create(150, 8), 1, PWideChar('Action: False'));
  end;

  if FEmitter = AEmitterNode.Emitter then
  begin

  FFont.TextOut(TVec2f.Create(8, 45), 1, PWideChar(format('Particles: %d', [Emitter.ParticleCount])));
 // FFont.TextOut(TVec2f.Create(8, 80), 1, PWideChar(format('Emissin: %f', [TQPEmitter(AEmitter).Emission])));
 // FFont.TextOut(TVec2f.Create(8, 60), 1, PWideChar(format('Particle Count: %f', [1])));

  FFont.TextOut(TVec2f.Create(100, 30), 1, PWideChar(format('Time: %f', [Emitter.Time])));
  FFont.TextOut(TVec2f.Create(8, 30), 1, PWideChar(format('Life: %f', [Emitter.Life])));
                                    {
  FFont.TextOut(TVec2f.Create(200, 30), 1, PWideChar(format('Begin: %f', [Emitter.EmitterParams.BeginTime])));
  FFont.TextOut(TVec2f.Create(300, 30), 1, PWideChar(format('End: %f', [Emitter.EmitterParams.EndTime])));

  if FEmitter.GetActive then
    FFont.TextOut(TVec2f.Create(150, 60), 1, PWideChar('Action: True'))
  else
    FFont.TextOut(TVec2f.Create(150, 60), 1, PWideChar('Action: False'));

  FFont.TextOut(TVec2f.Create(8, 60), 1, PWideChar(format('0: %f', [AEmitter.Values[0]])));
  FFont.TextOut(TVec2f.Create(8, 75), 1, PWideChar(format('1: %f', [AEmitter.Values[1]])));
  FFont.TextOut(TVec2f.Create(8, 90), 1, PWideChar(format('2: %f', [AEmitter.Values[2]])));

  FFont.TextOut(TVec2f.Create(80, 60), 1, PWideChar(format('0: %d', [TQPEmitter(AEmitter).FValuesIndex[0]])));
  FFont.TextOut(TVec2f.Create(80, 75), 1, PWideChar(format('1: %d', [TQPEmitter(AEmitter).FValuesIndex[1]])));
  FFont.TextOut(TVec2f.Create(80, 90), 1, PWideChar(format('2: %d', [TQPEmitter(AEmitter).FValuesIndex[2]])));
          }
  end;
  FQuadCamera.Enable;
  if FIsShapeDraw and AShapeDraw then
  begin
    case AParams.Shape.ShapeType of
      qeftPoint: ;
        //  DrawCircle(AParams.Shape.Position, 5, $FFFF0000);
      qeftLine:
        begin
          Angle := DegToRad(Emitter.Values[1]);
          Vec := TVec2f.Create(cos(Angle), sin(Angle)) * Emitter.Values[0];
          DrawLine(Emitter.Position - Vec, Emitter.Position + Vec, $FFFF0000, 1);
        end;
      qeftCircle:
        begin
          DrawCircle(Emitter.Position, Emitter.Values[0], $FFFF0000);
          DrawCircle(Emitter.Position, Emitter.Values[1], $FFFF0000);
        end;
      qeftRect:
        begin
          DrawRectAngle(
            Emitter.Position,
            TVec2f.Create(Emitter.Values[0], Emitter.Values[1]),
            Emitter.Values[2], $FFFF0000, 1);

        end;
    end;
    DrawLine(Emitter.Position - TVec2f.Create(5, 5), Emitter.Position + TVec2f.Create(5, 5), $FFFF0000, 1);
    DrawLine(Emitter.Position - TVec2f.Create(5, -5), Emitter.Position + TVec2f.Create(5, -5), $FFFF0000, 1);

    Speed := Emitter.StartVelocity;

    Vec := TVec2f.Create(
      Cos(Emitter.Direction - Emitter.Spread / 2),
      Sin(Emitter.Direction - Emitter.Spread / 2)
    );
    DrawLine(Emitter.Position, Emitter.Position + Vec * Speed, $FFFF0000, 1);

    Vec := TVec2f.Create(
      Cos(Emitter.Direction + Emitter.Spread / 2),
      Sin(Emitter.Direction + Emitter.Spread / 2)
    );
    DrawLine(Emitter.Position, Emitter.Position + Vec * Speed, $FFFF0000, 1);

    DrawArc(Emitter.Position, Speed, Emitter.Direction, Emitter.Spread, $FFFF0000);
  end;
end;

initialization
  InitializeCriticalSection(TRenderPanel.CriticalSection);

finalization
  DeleteCriticalSection(TRenderPanel.CriticalSection);


end.
