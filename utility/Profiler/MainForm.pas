unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Quad.CanvasGL, Vec2f,
  Vcl.StdCtrls, CommCtrl, QuadEngine.Socket, QuadEngine, QuadEngine.Profiler, System.Generics.Collections,
  System.ImageList, Vcl.ImgList;

const
  TREEVIEW_ITEM_HEIGHT = 60;
  LINEBLOCK_POINT_COUNT = 1000;

type
  TfMainForm = class;

  PAPICall = ^TAPICall;

  PLineBlock = ^TLineBlock;

  TLineBlock = record
    FillPoints: array[0..(LINEBLOCK_POINT_COUNT * 2 - 1)] of TVec2f;
    Points: array[0..(LINEBLOCK_POINT_COUNT - 1)] of TVec2f;
    PointCount: Integer;
  end;

  TProfilerCustomNode = class(TTreeNode)
  public
    procedure Draw(ACanvasGL: TQuadCanvasGL); virtual;
  end;

  TProfilerTagNode = class(TProfilerCustomNode)
  private
    FID: Integer;
    FCallList: TList<TAPICall>;
    FLineBlockList: TList<PLineBlock>;
    FColor: Cardinal;

    FMinValue, FMaxValue: Single;
    FValue: Single;
  public
    constructor Create(AOwner: TTreeNodes); override;

    destructor Destroy; override;
    procedure Add(const ACall: TAPICall; AX: Single);
    procedure Reset;
    procedure Draw(ACanvasGL: TQuadCanvasGL); override;

    property ID: Integer read FID write FID;
    property Color: Cardinal read FColor write FColor;
    property Value: Single read FValue;
    property MinValue: Single read FMinValue;
    property MaxValue: Single read FMaxValue;
  end;

  TProfilerNode = class(TProfilerCustomNode)
  private
    FGUID: TGUID;
    FClient: TQuadSocket;
    FPosition: Integer;
  public
    constructor Create(AOwner: TTreeNodes); override;
    function FindTag(AID: Integer): TProfilerTagNode;
    procedure Reset;

    property GUID: TGUID read FGUID write FGUID;
    property Client: TQuadSocket read FClient write FClient;
    property Position: Integer read FPosition write FPosition;
  end;

  TfMainForm = class(TForm)
    TopPanel: TPanel;
    PaintPanel: TPanel;
    FooterPanel: TPanel;
    ScrollBar: TScrollBar;
    StatusBar1: TStatusBar;
    RightPanel: TPanel;
    TreeView: TTreeView;
    Button2: TButton;
    PaintTimer: TTimer;
    Panel1: TPanel;
    Log: TListView;
    ImageLog: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PaintPanelResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeViewCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure Button2Click(Sender: TObject);
    procedure PaintTimerTimer(Sender: TObject);
    procedure PaintPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TreeViewCollapsed(Sender: TObject; Node: TTreeNode);
  private
    FShow: Boolean;
    FCanvasGL: TQuadCanvasGL;
    FServerSocket: TQuadServerSocket;
    FMemory: TMemoryStream;
    FNodeClass: TTreeNodeClass;
    FPerformanceFrequency: Int64;
    FMousePosition: TVec2i;
    function FindProfiler(const AGUID: TGUID): TProfilerNode; overload;
    function FindProfiler(AClient: TQuadSocket): TProfilerNode; overload;
    procedure ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
    procedure ServerSocketDisconnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
    procedure ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
    procedure Timer(const Delta: Double);
  public

  end;

var
  fMainForm: TfMainForm;

implementation

uses
  ShellApi, Math;

{$R *.dfm}


{ TProfilerCustomNode }

procedure TProfilerCustomNode.Draw(ACanvasGL: TQuadCanvasGL);
begin

end;

{ TProfilerTagNode }

constructor TProfilerTagNode.Create(AOwner: TTreeNodes);
begin
  inherited;
  FCallList := TList<TAPICall>.Create;
  FLineBlockList := TList<PLineBlock>.Create;
  FMaxValue := 0.01;
  FMinValue := 0;
    Reset;
end;

destructor TProfilerTagNode.Destroy;
var
  i: Integer;
begin
  for i := FLineBlockList.Count - 1 downto 0 do
    Dispose(FLineBlockList[i]);
  FLineBlockList.Free;
  FCallList.Free;
  inherited;
end;

procedure TProfilerTagNode.Reset;
var
  Block: PLineBlock;
begin
  New(Block);
  Block.PointCount := 0;
  FLineBlockList.Add(Block);
end;

procedure TProfilerTagNode.Add(const ACall: TAPICall; AX: Single);
var
  Block, LastBlock: PLineBlock;
begin
  FCallList.Add(ACall);
  Block := FLineBlockList[FLineBlockList.Count - 1];
  if Block.PointCount = LINEBLOCK_POINT_COUNT then
  begin
    Reset;
    LastBlock := Block;
    Block := FLineBlockList[FLineBlockList.Count - 1];
    Block.FillPoints[0] := LastBlock.FillPoints[LINEBLOCK_POINT_COUNT * 2 - 2];
    Block.FillPoints[1] := LastBlock.FillPoints[LINEBLOCK_POINT_COUNT * 2 - 1];
    Block.Points[0] := LastBlock.Points[LINEBLOCK_POINT_COUNT - 1];
    Block.PointCount := 1;
  end;

  FValue := ACall.Value / ACall.Count;
  Block.FillPoints[Block.PointCount * 2] := TVec2f.Create(AX, Min(ACall.MinValue, ACall.MaxValue));
  Block.FillPoints[Block.PointCount * 2 + 1] := TVec2f.Create(AX, Max(ACall.MinValue, ACall.MaxValue));
  Block.Points[Block.PointCount] := TVec2f.Create(AX, FValue);
  Inc(Block.PointCount);

  if FMaxValue < ACall.MaxValue then
    FMaxValue := ACall.MaxValue;

  if FMinValue > ACall.MinValue then
    FMinValue := ACall.MinValue;
end;

procedure TProfilerTagNode.Draw(ACanvasGL: TQuadCanvasGL);
var
  Rect: TRect;
  Camera: TQuadCanvasGLCamera;
  Scale: Single;
  Block: PLineBlock;
begin
  Rect := DisplayRect(False);
  Camera := TQuadCanvasGLCamera.Create;
  try
    ACanvasGL.SetPenColor($FF333333);
    ACanvasGL.DrawLine(TVec2f.Create(0, Rect.Bottom), TVec2f.Create(fMainForm.PaintPanel.Width, Rect.Bottom));
    Scale := (TREEVIEW_ITEM_HEIGHT - 4) / (MaxValue - MinValue);
    ACanvasGL.SetPenColor($FF444444);
    ACanvasGL.DrawLine(
      TVec2f.Create(0, Rect.Bottom + MinValue * Scale - 2),
      TVec2f.Create(fMainForm.PaintPanel.Width - 64, Rect.Bottom + MinValue * Scale - 2)
    );
    ACanvasGL.DrawLine(
      TVec2f.Create(fMainForm.PaintPanel.Width - 64, Rect.Top + 2),
      TVec2f.Create(fMainForm.PaintPanel.Width - 64, Rect.Bottom - 2)
    );
    ACanvasGL.SetPenColor($FF555555);

    ACanvasGL.TextOut(nil, TVec2f.Create(fMainForm.PaintPanel.Width - 62, Rect.Bottom + MinValue * Scale), '0');
    ACanvasGL.TextOut(nil, TVec2f.Create(fMainForm.PaintPanel.Width - 50, Rect.Top + 9), Format('%.3f', [MaxValue]));
    ACanvasGL.TextOut(nil, TVec2f.Create(fMainForm.PaintPanel.Width - 50, Rect.Bottom - 4), Format('%.3f', [MinValue]));
    ACanvasGL.TextOut(nil, TVec2f.Create(fMainForm.PaintPanel.Width - 50, Rect.Top + TREEVIEW_ITEM_HEIGHT div 2 + 2), Format('%.3f', [Value]));

    Camera.Translate := TVec2f.Create(
      fMainForm.PaintPanel.Width - TProfilerNode(Parent).Position - 64,
      Rect.Top + TREEVIEW_ITEM_HEIGHT + MinValue * Scale - 3
    );
    Camera.Scale := TVec2f.Create(1, -Scale);
    ACanvasGL.ApplyCamera(Camera);

    ACanvasGL.SetBrushColor(Color - $AA000000);
    ACanvasGL.SetPenColor(Color);

    for Block in FLineBlockList do
      if Block.PointCount > 1 then
      begin
        ACanvasGL.FillPolygon(@Block.FillPoints[0], Block.PointCount * 2);
        ACanvasGL.DrawPolyline(@Block.Points[0], Block.PointCount);
      end;

    ACanvasGL.ApplyCamera(nil);
    ACanvasGL.SetBrushColor(Color);

    ACanvasGL.FillCircle(TVec2f.Create(
      fMainForm.PaintPanel.Width - 64,
      Rect.Bottom - Value * Scale + MinValue * Scale - 3
    ), 2);
  finally
    Camera.Free;
  end;
end;

{ TProfilerNode }

constructor TProfilerNode.Create(AOwner: TTreeNodes);
begin
  inherited;
end;

function TProfilerNode.FindTag(AID: Integer): TProfilerTagNode;
var
  Node: TTreeNode;
begin
  Node := getFirstChild;
  while Assigned(Node) do
  begin
    if (Node is TProfilerTagNode) and (TProfilerTagNode(Node).ID = AID) then
      Exit(TProfilerTagNode(Node));
    Node := GetNextChild(Node);
  end;
  Result := nil;
end;

procedure TProfilerNode.Reset;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Item[i] is TProfilerTagNode then
      TProfilerTagNode(Item[i]).Reset;
end;

{ TForm4 }

procedure TfMainForm.Button2Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'demo09.exe', nil, nil, SW_SHOWNORMAL);
end;

procedure TfMainForm.FormCreate(Sender: TObject);
begin
  QueryPerformanceFrequency(FPerformanceFrequency);
  FShow := False;
  TreeView_SetItemHeight(TreeView.Handle, TREEVIEW_ITEM_HEIGHT);
  FCanvasGL := TQuadCanvasGL.Create(GetDC(PaintPanel.Handle), PaintPanel.Width, PaintPanel.Height);

  FMemory := TMemoryStream.Create;
  FServerSocket := TQuadServerSocket.Create(17788);
  FServerSocket.OnClientConnect := ServerSocketConnect;
  FServerSocket.OnClientDisconnect := ServerSocketDisconnect;
  FServerSocket.OnRead := ServerSocketRead;
  FServerSocket.Open;
end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
  FMemory.Free;
  if Assigned(FServerSocket) then
    FServerSocket.Free;
  FCanvasGL.Free;
end;

procedure TfMainForm.ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
var
  Code: Word;
begin
  Code := 2;
  AClient.SendBuf(Code, SizeOf(Code));
end;

procedure TfMainForm.ServerSocketDisconnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
var
  Node: TTreeNode;
begin
  Node := TreeView.TopItem;
  while Assigned(Node) do
  begin
    if (Node is TProfilerNode) and (TProfilerNode(Node).Client = AClient) then
    begin
      TProfilerNode(Node).Client := nil;
      Exit;
    end;
    Node := Node.GetNext;
  end;
end;

function TfMainForm.FindProfiler(const AGUID: TGUID): TProfilerNode;
var
  Node: TTreeNode;
begin
  Node := TreeView.TopItem;
  while Assigned(Node) do
  begin
    if (Node is TProfilerNode) and (TProfilerNode(Node).GUID = AGUID) then
      Exit(TProfilerNode(Node));
    Node := Node.GetNext;
  end;
  Result := nil;
end;

function TfMainForm.FindProfiler(AClient: TQuadSocket): TProfilerNode;
var
  Node: TTreeNode;
begin
  Node := TreeView.TopItem;
  while Assigned(Node) do
  begin
    if (Node is TProfilerNode) and (TProfilerNode(Node).Client = AClient) then
      Exit(TProfilerNode(Node));
    Node := Node.GetNext;
  end;
  Result := nil;
end;

procedure TfMainForm.ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
var
  Code: Word;
  GUID: TGUID;
  Profiler: TProfilerNode;
  ProfilerTag: TProfilerTagNode;

  Str: WideString;
  StrLen: Byte;
  ID: Word;
  Color: Cardinal;
  MsgType: TQuadProfilerMessageType;
  DateTime: TDateTime;
  i, TagsCount: Word;
  Call: TAPICall;
  LogItem: TListItem;
begin
  if AClient.ReceiveStream(FMemory) <= 0 then
    Exit;

    repeat
      FMemory.Read(Code, SizeOf(Code));
      FMemory.Read(GUID, SizeOf(GUID));

      Profiler := FindProfiler(GUID);

      if (Code = 2) and not Assigned(Profiler) then
      begin
        FNodeClass := TProfilerNode;
        Profiler := TreeView.Items.AddChild(nil, '') as TProfilerNode;
        Profiler.GUID := GUID;
        Profiler.Client := AClient;
        FMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        FMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
        Profiler.Text := Str;
        Code := 4;
        AClient.SendBuf(Code, SizeOf(Code));
        PaintTimer.Enabled := True;
      end
      else
        if Assigned(Profiler) then
        begin
          case Code of
            1:
              begin
                FMemory.Read(TagsCount, SizeOf(TagsCount));
                for i := 0 to TagsCount - 1 do
                begin
                  FMemory.Read(ID, SizeOf(ID));
                  FMemory.Read(Call, SizeOf(Call));
                  ProfilerTag := Profiler.FindTag(ID);
                  if Assigned(ProfilerTag) then
                    ProfilerTag.Add(Call, Profiler.Position);
                end;
                Profiler.Position := Profiler.Position + 1;
                PaintTimer.Enabled := True;
              end;
            2:
              if not Assigned(Profiler.Client) then
              begin
                Profiler.Client := AClient;
                Profiler.Position := Profiler.Position + 16;
                Profiler.Reset;
                Code := 4;
                AClient.SendBuf(Code, SizeOf(Code));
              end;
            3:
              begin
                FMemory.Read(ID, SizeOf(ID));
                FMemory.Read(Color, SizeOf(Color));
                FMemory.Read(StrLen, SizeOf(StrLen));
                SetLength(Str, StrLen);
                FMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));

                ProfilerTag := Profiler.FindTag(ID);
                if not Assigned(ProfilerTag) then
                begin
                  FNodeClass := TProfilerTagNode;
                  ProfilerTag := TreeView.Items.AddChild(Profiler, Str) as TProfilerTagNode;
                  ProfilerTag.ID := ID;
                  ProfilerTag.Color := Color;
                end;
                Profiler.Expand(True);
              end;
            4:
              begin
                FMemory.Read(ID, SizeOf(ID));
                FMemory.Read(DateTime, SizeOf(DateTime));
                FMemory.Read(MsgType, SizeOf(MsgType));
                FMemory.Read(StrLen, SizeOf(StrLen));
                SetLength(Str, StrLen);
                FMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
                LogItem := Log.Items.Insert(0);
                LogItem.Caption := '';
                LogItem.SubItems.Add(FormatDateTime('hh:nn:ss', DateTime));
                LogItem.SubItems.Add(Str);
                LogItem.ImageIndex := Integer(MsgType);
                LogItem.StateIndex := LogItem.ImageIndex;
              end;
          end;
        end;
    until FMemory.Position >= FMemory.Size;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
  FShow := True;
end;

procedure TfMainForm.PaintPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMousePosition := TVec2i.Create(X, Y);
  PaintTimer.Enabled := True;
end;

procedure TfMainForm.PaintPanelResize(Sender: TObject);
begin
  PaintTimer.Enabled := False;
  if Assigned(FCanvasGL) then
    FCanvasGL.Resize(PaintPanel.Width, PaintPanel.Height);
  PaintTimer.Enabled := True;
end;

procedure TfMainForm.PaintTimerTimer(Sender: TObject);
begin
  Timer(0);
end;

procedure TfMainForm.Timer(const Delta: Double);
var
  i: Integer;
  Rect: TRect;
  Node: TTreeNode;
begin
  PaintTimer.Enabled := False;
  FCanvasGL.RenderingBegin($FF191919);
  try
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      if Node is TProfilerCustomNode then
      begin
        Rect := Node.DisplayRect(False);
        if (Rect.Height > 0) and (Rect.Bottom > 0) and (Rect.Top < PaintPanel.Height) then
          TProfilerCustomNode(Node).Draw(FCanvasGL);
      end;
    end;

  finally
    FCanvasGL.RenderingEnd;
  end;
end;

procedure TfMainForm.TreeViewCollapsed(Sender: TObject; Node: TTreeNode);
begin
  PaintTimer.Enabled := True;
end;

procedure TfMainForm.TreeViewCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := FNodeClass;
end;

end.
