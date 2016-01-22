unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RenderPanel, QuadEngine, Vcl.Graphics,
  Vec2f, QuadFX, QuadFX.Emitter, Frame.Custom, QPTreeNode,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls,
  Vcl.ImgList, Quad.Diagram, QuadFX.EffectParams, XMLIntf, XMLDoc,
  QuadFX.Effect, Vcl.Themes, Vcl.Styles, FileAssociationContoller, System.Json,
  QuadFX.Helpers, System.Generics.Collections, Quad.EffectTimeLine,
  FloatSpinEdit, Vcl.ExtDlgs, iniFiles;

type
  TfMain = class(TForm)
    tvEffectList: TTreeView;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter2: TSplitter;
    Splitter1: TSplitter;
    pPreview: TPanel;
    Panel6: TPanel;
    MainMenu: TMainMenu;
    StatusBar1: TStatusBar;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    ActionList: TActionList;
    aParamShape: TAction;
    aParamEmission: TAction;
    ToolBar2: TToolBar;
    tbDrawShape: TToolButton;
    aParamOpacity: TAction;
    aParamScale: TAction;
    aParamSpin: TAction;
    pmEffectList: TPopupMenu;
    aCreateEffect: TAction;
    aCreateEmitter: TAction;
    CreateEffect1: TMenuItem;
    CreateEmitter1: TMenuItem;
    N2: TMenuItem;
    aOpen: TAction;
    aSave: TAction;
    aPlayerPlay: TAction;
    aPlayerPause: TAction;
    aPlayerRestart: TAction;
    aPlayerLoop: TAction;
    Panel5: TPanel;
    tbTimeLine: TToolBar;
    tbPlayerRestart: TToolButton;
    tbPlayerPlay: TToolButton;
    tbPlayerPause: TToolButton;
    tbPlayerLoop: TToolButton;
    TrackBar1: TTrackBar;
    EffectTimeLine: TEffectTimeLine;
    Panel7: TPanel;
    EffectTimeLineScrollH: TScrollBar;
    EffectTimeLineScrollV: TScrollBar;
    Splitter3: TSplitter;
    aTextureConfig: TAction;
    aNew: TAction;
    aSaveAs: TAction;
    aExit: TAction;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    textures1: TMenuItem;
    pcParams: TPageControl;
    tsProperties: TTabSheet;
    tsGravitation: TTabSheet;
    pParam: TPanel;
    lvParamList: TListView;
    pCaption: TPanel;
    lCaption: TLabel;
    Panel1: TPanel;
    ListBox1: TListBox;
    dGravDirection: TQuadDiagram;
    Label1: TLabel;
    FloatSpinEdit1: TFloatSpinEdit;
    dGravForce: TQuadDiagram;
    aDelete: TAction;
    miDeleteEffectEmitter: TMenuItem;
    ToolButton1: TToolButton;
    tbBackgroundBlack: TToolButton;
    tbBackgroundWhite: TToolButton;
    tbBackgroundColor: TToolButton;
    tbBackgroundImg: TToolButton;
    ColorDialog: TColorDialog;
    OpenPictureDialog: TOpenPictureDialog;
    aCreatePack: TAction;
    aCreatePack1: TMenuItem;
    miReopen: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure pPreviewResize(Sender: TObject);
    procedure lvParamListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure tbDrawShapeClick(Sender: TObject);
    procedure aCreateEffectExecute(Sender: TObject);
    procedure aCreateEmitterExecute(Sender: TObject);
    procedure tvEffectListCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure tvEffectListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure tvEffectListEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure aTextureDelExecute(Sender: TObject);
    procedure aPlayerRestartExecute(Sender: TObject);
    procedure aPlayerPlayExecute(Sender: TObject);
    procedure aPlayerPauseExecute(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure aPlayerLoopExecute(Sender: TObject);
    procedure aTextureConfigExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure tvEffectListChange(Sender: TObject; Node: TTreeNode);
    procedure lvParamListResize(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure tvEffectListCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormResize(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure tbBackgroundBlackClick(Sender: TObject);
    procedure tbBackgroundWhiteClick(Sender: TObject);
    procedure tbBackgroundColorClick(Sender: TObject);
    procedure tbBackgroundImgClick(Sender: TObject);
    procedure aCreatePackExecute(Sender: TObject);
    procedure tvEffectListExpanded(Sender: TObject; Node: TTreeNode);
    procedure tvEffectListCollapsed(Sender: TObject; Node: TTreeNode);
  private
    FRenderPreview: TRenderPanel;
    FMax: Integer;
    FParamFrame: TCustomParamFrame;
    FPackSelected: TPackNode;
    FEffectSelected: TEffectNode;
    FEmitterSelected: TEmitterNode;

    procedure SetParamFrame(AItem: TListItem);
    procedure ParamsMessage(ACommand: WideString);
    procedure SaveJson(AFileName: String);
    procedure SaveXml(AFileName: String);
    procedure SaveQFX(AFileName: String);
    procedure SetEffectSelected(Value: TEffectNode);
    procedure ClearAll;
    procedure AddReopen(AFileName: String; AIsSave: Boolean = True);
    procedure LoadConfig;
    procedure SaveReopen;
    procedure ReopenClick(Sender: TObject);
    procedure LoadFile(AFileName: String);
  public
    procedure OnPaint;
    property RenderPreview: TRenderPanel read FRenderPreview;
    property EffectSelected: TEffectNode read FEffectSelected write SetEffectSelected;
    property EmitterSelected: TEmitterNode read FEmitterSelected;
    property ParamFrame: TCustomParamFrame read FParamFrame;
  end;

var
  fMain: TfMain;

type
  TMemoryStreamHelper = class helper for TMemoryStream
  public
    procedure WriteStream(AMemory: TMemoryStream);
  end;

implementation

uses
  Math, Sprite, Frame.Shape, Frame.Value, Frame.Texture, IcomList, Textures, Frame.Color,
  Frame.Position, Frame.DirectionSpread, Frame.Globals, QuadFX.FileLoader.JSON, QuadFX.Atlas,
  Atlas, QuadFX.FileLoader.XML;

{$R *.dfm}

procedure TMemoryStreamHelper.WriteStream(AMemory: TMemoryStream);
var
  Sz: Integer;
begin
  if not Assigned(AMemory) then
    Exit;

  Sz := AMemory.Size;
  Write(Sz, SizeOf(Sz));
  Write(AMemory.Memory, Sz);
  AMemory.Free;
end;

procedure TfMain.LoadConfig;
var
  ini: TIniFile;
  FileList: TStringList;
  i: Integer;
  FileName: String;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  FileList := TStringList.Create;
  try
    ini.ReadSection('Reopen', FileList);
    for i := FileList.Count - 1 downto 0 do
    begin
      FileName := ini.ReadString('Reopen', FileList[i], '');
      if FileExists(FileName) then
        AddReopen(FileName, False);
    end;
  finally
    FileList.Free;
    ini.Free;
  end;
end;

procedure TfMain.ReopenClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    LoadFile(TMenuItem(Sender).Caption);
end;

procedure TfMain.SaveReopen;
var
  ini: TIniFile;
  FileList: TStringList;
  i: Integer;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  FileList := TStringList.Create;
  try
    ini.ReadSection('Reopen', FileList);
    for i := 0 to FileList.Count - 1 do
      ini.DeleteKey('Reopen', FileList[i]);

    for i := 0 to miReopen.Count - 1 do
      ini.WriteString('Reopen', 'File_' + i.ToString, miReopen.Items[i].Caption);
  finally
    FileList.Free;
    ini.Free;
  end;
end;

procedure TfMain.AddReopen(AFileName: String; AIsSave: Boolean = True);
var
  MenuItem: TMenuItem;
  i: integer;
begin
  MenuItem := nil;
  for i := 0 to miReopen.Count - 1 do
    if AnsiCompareText(miReopen[i].Caption, AFileName) = 0 then
    begin
      MenuItem := miReopen.Items[i];
      miReopen.Items[i].MenuIndex := 0;
      Break;
    end;

  if not Assigned(MenuItem) then
  begin
    MenuItem := TMenuItem.Create(miReopen);
    MenuItem.OnClick := ReopenClick;
    MenuItem.Caption := AFileName;
    miReopen.Insert(0, MenuItem);
  end;

  if miReopen.Count > 10 then
    miReopen.Delete(miReopen.Count - 1);

  if AIsSave then
    SaveReopen;

  miReopen.Enabled := True;
end;

procedure TfMain.ParamsMessage(ACommand: WideString);
begin
  ListBox1.Items.Add(ACommand);

//  Memo1.Lines.LoadFromFile(ACommand);
end;

procedure TfMain.SetParamFrame(AItem: TListItem);
begin
  if Assigned(FParamFrame) then
    FParamFrame.Free;

  FParamFrame := nil;

  if not Assigned(FEmitterSelected) or not Assigned(AItem) then
    Exit;

  if AItem is TCustomParamListItem then
    FParamFrame := TCustomParamListItem(AItem).CreateFrame(pParam, FEmitterSelected.EmitterParams);

  if Assigned(FParamFrame) then
    FParamFrame.Parent := pParam;
end;

procedure TfMain.tbBackgroundBlackClick(Sender: TObject);
begin
  tbBackgroundWhite.Down := False;
  tbBackgroundColor.Down := False;
  tbBackgroundImg.Down := False;
  FRenderPreview.SetBackgroundType(btBlack);
end;

procedure TfMain.tbBackgroundWhiteClick(Sender: TObject);
begin
  tbBackgroundBlack.Down := False;
  tbBackgroundColor.Down := False;
  tbBackgroundImg.Down := False;
  FRenderPreview.SetBackgroundType(btWhite);
end;

procedure TfMain.tbBackgroundColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    tbBackgroundBlack.Down := False;
    tbBackgroundWhite.Down := False;
    tbBackgroundImg.Down := False;
    FRenderPreview.SetBackgroundColor(ColorToARGB(ColorDialog.Color));
  end;
end;

procedure TfMain.tbBackgroundImgClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    tbBackgroundBlack.Down := False;
    tbBackgroundWhite.Down := False;
    tbBackgroundColor.Down := False;
    FRenderPreview.SetBackgroundImage(OpenPictureDialog.FileName);
  end;
end;

procedure TfMain.tbDrawShapeClick(Sender: TObject);
begin
  FRenderPreview.IsShapeDraw := tbDrawShape.Down;
end;

procedure TfMain.TrackBar1Change(Sender: TObject);
begin
  EffectTimeLine.Scale := TrackBar1.Position;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  try
    EnterCriticalSection(TRenderPanel.CriticalSection);
    try
      ClearAll;
      FRenderPreview.Free;
    finally
      LeaveCriticalSection(TRenderPanel.CriticalSection);
    end;
  except
    on E : Exception do
      ListBox1.Items.Add(E.ClassName + ' ошибка с сообщением: ' + E.Message);
  end;
end;

procedure TfMain.ClearAll;
begin
  try
    tvEffectList.Items.Clear;
  //  fTextures.Clear;
    FEffectSelected := nil;
    FEmitterSelected := nil;
    FRenderPreview.SetEffect(nil, nil, nil);
    SetParamFrame(nil);
  except
    on E : Exception do
      ListBox1.Items.Add(E.ClassName + ' ошибка с сообщением: ' + E.Message);
  end;
end;

procedure TfMain.FormResize(Sender: TObject);
begin
  tvEffectList.Repaint;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  FRenderPreview.Action := true;
 // TFileAssociationContoller.Create.Show;
end;

procedure TfMain.OnPaint;
var
  Effect: TEffectNode;
begin
  if not Assigned(FEffectSelected) then
    Exit;
  Effect := FEffectSelected;
  EffectTimeLine.Position := TQuadFXEffect(Effect.Effect).Life;
  if Assigned(FParamFrame) and Assigned(FEmitterSelected) and Assigned(FEmitterSelected.Emitter) then
    FParamFrame.SetLife(TQuadFXEmitter(FEmitterSelected.Emitter).Life);
  dGravDirection.Position := EffectTimeLine.Position - Trunc(EffectTimeLine.Position / 5) * 5;
  dGravForce.Position := dGravDirection.Position;
end;

procedure TfMain.LoadFile(AFileName: String);
var
  Node: TPackNode;
  i: Integer;
begin
  for i := 0 to tvEffectList.Items.Count - 1 do
    if (tvEffectList.Items[i] is TPackNode) and (AnsiCompareText(TPackNode(tvEffectList.Items[i]).FileName, AFileName) = 0) then
    begin
      Exit;
    end;

  try
    FEffectSelected := nil;
    FEmitterSelected := nil;
    FRenderPreview.SetEffect(nil, nil, nil);
    SetParamFrame(nil);

    dmIcomList.TreeNodeCreateClass := TPackNode;
    Node := tvEffectList.Items.AddChild(nil, 'New pack') as TPackNode;
    Node.LoadFromFile(AFileName);
  //  Node.Expanded := True;
  except
    on E : Exception do
      ListBox1.Items.Add(E.ClassName + ' ошибка с сообщением: ' + E.Message);
  end;
  AddReopen(AFileName);
end;

procedure TfMain.aOpenExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    LoadFile(OpenDialog.FileName);
end;

procedure TfMain.aCreatePackExecute(Sender: TObject);
var
  Node: TPackNode;
begin
  dmIcomList.TreeNodeCreateClass := TPackNode;
  Node := tvEffectList.Items.AddChild(nil, 'New pack') as TPackNode;
  Node.Expanded := True;
end;
    {
procedure TfMain.OpenFile(AFileName: String);
begin
  //

  FFileFormat := ffJSON;
  OpenJson(AFileName);
  if tvEffectList.Items.Count > 0 then
    tvEffectList.Items.GetFirstNode.Focused := true;

end;
   }

procedure TfMain.SaveQFX(AFileName: String);
var
  i: Integer;
  Mem: TMemoryStream;
begin
  ListBox1.Items.Add(Format('SaveQFX: %s;', [AFileName]));
  Mem := TMemoryStream.Create;
  try
  {  for i := 0 to tvEffectList.TopItem.Count - 1 do
      if tvEffectList.Items[i] is TEffectNode then
        Mem.WriteStream(TQuadFXEffectParams(TEffectNode(tvEffectList.Items[i]).EffectParams).ToMemory);
     }
    Mem.SaveToFile(AFileName);
  finally
    Mem.Free;
  end;
end;

procedure TfMain.SaveXml(AFileName: String);

  function EffectParamsToXml(AParent: IXMLNode; AEffectParams: IQuadFXEffectParams): IXMLNode;
  var
    i: Integer;
    Node: IXMLNode;
    EffectParams: TQuadFXEffectParams;
    EmitterParams: PQuadFXEmitterParams;
    FileFormat: TQuadFXXMLFileFormat;
  begin
    Result := AParent.OwnerDocument.CreateNode('Effect');
    EffectParams := TQuadFXEffectParams(AEffectParams);

    Result.Attributes['Name'] := EffectParams.Name;

    FileFormat := TQuadFXXMLFileFormat.Create;
    try
      for i := 0 to EffectParams.GetEmitterParamsCount - 1 do
      begin
        EffectParams.GetEmitterParams(i, EmitterParams);
        FileFormat.SaveEmitterParams(Result, EmitterParams);
      end;
    finally
      FileFormat.Free;
    end;
    AParent.ChildNodes.Add(Result);
  end;

var
  i: Integer;
  XML: IXMLDocument;
  Effects: IXMLNode;
begin
  XML := TXMLDocument.Create(nil);
  XML.Active := True;

  XML.DocumentElement := XML.CreateNode('quadfx');
  XML.DocumentElement.Attributes['PackName'] := 'TestPack';

  fTextures.ToXml(XML.DocumentElement);

  Effects := XML.CreateNode('Effects');

  for i := 0 to tvEffectList.Items.Count - 1 do
    if tvEffectList.Items[i] is TEffectNode then
      EffectParamsToXml(Effects, TEffectNode(tvEffectList.Items[i]).EffectParams);

  XML.DocumentElement.ChildNodes.Add(Effects);

  XML.SaveToFile(AFileName);
end;

procedure TfMain.SaveJson(AFileName: String);
begin

end;

procedure TfMain.lvParamListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  SetParamFrame(lvParamList.Selected);
end;

procedure TfMain.lvParamListResize(Sender: TObject);
begin
  lvParamList.Columns[0].Width := lvParamList.Width - 30;
end;

procedure TfMain.pPreviewResize(Sender: TObject);
begin
  //Caption := IntToStr(StrToIntDef(Caption, 0) + 1);
end;

procedure TfMain.SetEffectSelected(Value: TEffectNode);
var
  i: Integer;
  Emitter: TEmitterNode;
begin
  if FEffectSelected <> Value then
  begin
    FEffectSelected := Value;
    EffectTimeLine.Lines.BeginUpdate;
    EffectTimeLine.Clear;
    if Assigned(FEffectSelected) then
      for i := 0 to Value.Count - 1 do
        if Assigned(Value[i]) and (Value[i] is TEmitterNode) then
        begin
          Emitter := TEmitterNode(Value[i]);
          Emitter.TimeLine := EffectTimeLine.Lines.Add;
        end;
    EffectTimeLine.Lines.EndUpdate;
  end;
end;

procedure TfMain.aCreateEffectExecute(Sender: TObject);
var
  Effect: TEffectNode;
begin
  EnterCriticalSection(TRenderPanel.CriticalSection);
  try
    Effect := FPackSelected.CreateEffect;
    tvEffectList.Select(Effect);
    //Effect.EditText;
  finally
    LeaveCriticalSection(TRenderPanel.CriticalSection);
  end;
end;

procedure TfMain.aCreateEmitterExecute(Sender: TObject);
{var
  Emitter: TEmitterNode;   }
begin
  EnterCriticalSection(TRenderPanel.CriticalSection);
  try
    FEffectSelected.CreateEmitter;
    //Emitter.EditText;
  finally
    LeaveCriticalSection(TRenderPanel.CriticalSection);
  end;
end;

procedure TfMain.aExitExecute(Sender: TObject);
begin
  RenderPreview.Action := False;
  sleep(100);
  Close;
end;

procedure TfMain.aNewExecute(Sender: TObject);
begin
  fTextures.Clear;
  tvEffectList.Items.Clear;
end;

procedure TfMain.aSaveAsExecute(Sender: TObject);
begin
  if Assigned(FPackSelected) then
    FPackSelected.SaveToFile(True);
end;

procedure TfMain.aSaveExecute(Sender: TObject);
begin
  if Assigned(FPackSelected) then
    FPackSelected.SaveToFile;
end;

procedure TfMain.aTextureConfigExecute(Sender: TObject);
begin
  fTextures.ShowModal;
  if not Assigned(FParamFrame) or not (FParamFrame is TFrameTexture) then
    Exit;

  TFrameTexture(FParamFrame).Refresh;

end;

procedure TfMain.aTextureDelExecute(Sender: TObject);
var
//  i: Integer;
  Frame: TFrameTexture;
begin
  if not Assigned(FParamFrame) or not (FParamFrame is TFrameTexture) then
    Exit;

  Frame := TFrameTexture(FParamFrame);
        {
  for i := 0 to Frame.lvList.Items.Count - 1 do
    if Frame.lvList.Items[i].Selected then
    begin
          }
      Frame.lvList.DeleteSelected;
      Frame.Refresh;
    //end;
end;

procedure TfMain.aPlayerLoopExecute(Sender: TObject);
begin
  FRenderPreview.Loop(tbPlayerLoop.Down);
end;

procedure TfMain.aPlayerPauseExecute(Sender: TObject);
begin
  FRenderPreview.Pause;
end;

procedure TfMain.aPlayerPlayExecute(Sender: TObject);
begin
  FRenderPreview.Play;
end;

procedure TfMain.aPlayerRestartExecute(Sender: TObject);
begin
  FRenderPreview.Restart;
  EffectTimeLine.Position := 0;
end;

procedure TfMain.Button2Click(Sender: TObject);
var
  guid: TGUID;
begin
  guid := TGUID.NewGuid;
  if not DirectoryExists('Screens') then
    MkDir('Screens');
  FRenderPreview.QuadRender.TakeScreenshot(PWideChar('Screens\' + guid.ToString + '.png'));
end;

procedure TfMain.aDeleteExecute(Sender: TObject);
begin
  if Assigned(tvEffectList.Selected) then
  begin
    fMain.ListBox1.Items.Insert(0, 'Save Begin');
    Application.ProcessMessages;
    EnterCriticalSection(TRenderPanel.CriticalSection);
    try
      tvEffectList.Selected.Delete;
    finally
     LeaveCriticalSection(TRenderPanel.CriticalSection);
    end;
  end;
end;

procedure TfMain.tvEffectListChange(Sender: TObject; Node: TTreeNode);
var
  PackNode: TTreeNode;
begin
  if Assigned(tvEffectList.Selected) then
  begin
    if tvEffectList.Selected is TPackNode then
    begin
      FPackSelected := TPackNode(tvEffectList.Selected);
      EffectSelected := nil;
      FEmitterSelected := nil;
      FRenderPreview.SetEffect(nil, nil, nil);
      SetParamFrame(nil);
    end
    else
    begin
      PackNode := tvEffectList.Selected;
      while not (PackNode is TPackNode) and (PackNode.Level > 0) do
        PackNode := PackNode.Parent;

      if PackNode is TPackNode then
        FPackSelected := TPackNode(PackNode);

      if tvEffectList.Selected is TEffectNode then
      begin
        EffectSelected := TEffectNode(tvEffectList.Selected);
        FEmitterSelected := nil;
        FRenderPreview.SetEffect(FEffectSelected.EffectParams, FEffectSelected, nil);
        SetParamFrame(nil);
      end
      else
        if tvEffectList.Selected is TEmitterNode then
        begin
          FEmitterSelected := TEmitterNode(tvEffectList.Selected);
          EffectSelected := TEffectNode(FEmitterSelected.Parent);
          FRenderPreview.SetEffect(FEffectSelected.EffectParams, EffectSelected, FEmitterSelected.Emitter);
          SetParamFrame(lvParamList.Selected);
        end
        else
        begin
          FRenderPreview.SetEffect(nil, nil, nil);
          SetParamFrame(nil);
        end;
    end;
  end
  else
  begin
    FRenderPreview.SetEffect(nil, nil, nil);
    SetParamFrame(nil);
  end;

  lvParamList.Enabled := Assigned(FEmitterSelected);

  aCreateEffect.Enabled := Assigned(FPackSelected);
  aCreateEmitter.Enabled := Assigned(FEffectSelected);
  aDelete.Enabled := Assigned(tvEffectList.Selected);
end;

procedure TfMain.tvEffectListCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := dmIcomList.TreeNodeCreateClass;
end;

procedure TfMain.tvEffectListCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Rect: TRect;
begin
  if Node is TEmitterNode then
  begin
    Rect := Node.DisplayRect(False);

    Canvas.Font.Assign(tvEffectList.Font);

    if TEmitterNode(Node).Visible then
      dmIcomList.ilIcons16.Draw(Sender.Canvas, Rect.Right - 20, Rect.Top + Rect.Height div 2 - 8, 1)
    else
      dmIcomList.ilIcons16.Draw(Sender.Canvas, Rect.Right - 20, Rect.Top + Rect.Height div 2 - 8, 0);
  end;
end;

procedure TfMain.tvEffectListEdited(Sender: TObject; Node: TTreeNode; var S: string);
  function GetFullName(ANode: TTreeNode): WideString;
  begin
    Result := ANode.Text;
    while not (ANode is TPackNode) and (ANode.Level > 1) do
    begin
      ANode := ANode.Parent;
      Result := ANode.Text + '\' + Result;
    end;
  end;

  procedure RenameEffect(ANode: TTreeNode);
  var
    i: Integer;
  begin
    for i := 0 to ANode.Count - 1 do
      if ANode[i] is TEffectNode then
        TQuadFXEffectParams(TEffectNode(ANode[i]).EffectParams).Name := GetFullName(ANode[i])
      else
        if ANode[i] is TFolderNode then
          RenameEffect(ANode[i]);
  end;
begin
  Node.Text := S;
  if Node is TEmitterNode then
  begin
    TEmitterNode(Node).EmitterParams.Name := S;
    TEmitterNode(Node).TimeLine.Name := S;
  end
  else
    if Node is TEffectNode then
      TQuadFXEffectParams(TEffectNode(Node).EffectParams).Name := GetFullName(Node)
    else
      if Node is TFolderNode then
        RenameEffect(Node);
end;

procedure TfMain.tvEffectListCollapsed(Sender: TObject; Node: TTreeNode);
begin
  if Node is TPackNode then
  begin
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
  end
  else
    if Node is TFolderNode then
    begin
      Node.ImageIndex := 4;
      Node.SelectedIndex := 4;
    end;
end;

procedure TfMain.tvEffectListExpanded(Sender: TObject; Node: TTreeNode);
begin
  if Node is TPackNode then
  begin
    Node.ImageIndex := 3;
    Node.SelectedIndex := 3;
  end
  else
    if Node is TFolderNode then
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := 5;
    end;
end;

procedure TfMain.tvEffectListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  EmitterNode: TEmitterNode;
  RectNode, RectEye: TRect;
begin
  Node := tvEffectList.GetNodeAt(X, Y);
  if Node is TEmitterNode then
  begin
    EmitterNode := TEmitterNode(Node);
    RectNode := Node.DisplayRect(False);
    RectEye.Left := RectNode.Right - 22;
    RectEye.Top := RectNode.Top + RectNode.Height div 2 - 10;
    RectEye.Width := 20;
    RectEye.Height := 20;

    if (X > RectEye.Left) and (X < RectEye.Right) and (Y > RectEye.Top) and (Y < RectEye.Bottom) then
    begin
      EmitterNode.Visible := not EmitterNode.Visible;
      EnterCriticalSection(TRenderPanel.CriticalSection);
      try
        FRenderPreview.RefreshEmittersList;
      finally
       LeaveCriticalSection(TRenderPanel.CriticalSection);
      end;
      tvEffectList.Repaint;
    end;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  LoadConfig;

  TFileAssociationContoller.Create.SetOnCommandEvent(ParamsMessage);

  ListBox1.Clear;
  for i := 0 to ParamCount do
    ListBox1.Items.Add(ParamStr(i));
  FRenderPreview := TRenderPanel.CreateEx(pPreview, OnPaint);
  FMax := 0;

  TListItemGlobals.CreateEx(lvParamList.Items);
  TListItemPosition.CreateEx(lvParamList.Items);
  TListItemTextures.CreateEx(lvParamList.Items);
  TListItemShape.CreateEx(lvParamList.Items);
  TListItemColor.CreateEx(lvParamList.Items);

  TListItemLifeTime.CreateEx(lvParamList.Items);
  TListItemEmission.CreateEx(lvParamList.Items);

  TListItemDirectionSpread.CreateEx(lvParamList.Items);

  TListItemStartVelocity.CreateEx(lvParamList.Items);

  TListItemVelocity.CreateEx(lvParamList.Items);
  TListItemScale.CreateEx(lvParamList.Items);
  TListItemStartAngle.CreateEx(lvParamList.Items);
  TListItemSpin.CreateEx(lvParamList.Items);
  TListItemOpacity.CreateEx(lvParamList.Items);
  TListItemGravitation.CreateEx(lvParamList.Items);

end;

end.
