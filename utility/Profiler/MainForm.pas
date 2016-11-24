unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Quad.CanvasGL, Vec2f,
  Vcl.StdCtrls, CommCtrl, QuadEngine.Socket, QuadEngine, QuadEngine.Profiler, System.Generics.Collections,
  QuadEngine.Timer, System.ImageList, Vcl.ImgList;

const
  TREEVIEW_ITEM_HEIGHT = 48;
  LINEBLOCK_POINT_COUNT = 10000;

type
  TfMainForm = class;

  PAPICall = ^TAPICall;

  PLineBlock = ^TLineBlock;
  TLineBlock = array[0..(LINEBLOCK_POINT_COUNT - 1)] of TVec2f;
  TLineFillBlock = array[0..(LINEBLOCK_POINT_COUNT * 2 - 1)] of TVec2f;

  TProfilerTagNode = class(TTreeNode)
  private
    FID: Integer;
    FCallList: TList<TAPICall>;

    FFillPoints: TLineBlock;
    FPoints: TLineBlock;
    FPointCount: Integer;

    FMaxValue: Single;
  public
    constructor Create(AOwner: TTreeNodes); override;

    destructor Destroy; override;
    procedure Add(const ACall: TAPICall; AX: Single);
    property ID: Integer read FID write FID;

    property FillPoints: TLineBlock read FFillPoints;
    property Points: TLineBlock read FPoints;
    property PointCount: Integer read FPointCount;
    property MaxValue: Single read FMaxValue;
  end;

  TProfilerNode = class(TTreeNode)
  private
    FGUID: TGUID;
    FClient: TQuadSocket;
    FPosition: Integer;
  public
    function FindTag(AID: Integer): TProfilerTagNode;

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
  private
    FShow: Boolean;
    FCanvasGL: TQuadCanvasGL;
    FServerSocket: TQuadServerSocket;
    FMemory: TMemoryStream;
    FNodeClass: TTreeNodeClass;
    FPerformanceFrequency: Int64;
    FOld: Int64;
    FTimer: TQuadCanvasGLTimer;
    procedure ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
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

{ TProfilerTagNode }

constructor TProfilerTagNode.Create(AOwner: TTreeNodes);
begin
  inherited;
  FCallList := TList<TAPICall>.Create;
  FPointCount := 0;
  FMaxValue := 0.1;
end;

destructor TProfilerTagNode.Destroy;
begin
  FCallList.Free;
  inherited;
end;

procedure TProfilerTagNode.Add(const ACall: TAPICall; AX: Single);
begin
  FCallList.Add(ACall);

  FFillPoints[FPointCount * 2] := TVec2f.Create(AX, ACall.MinValue);
  FFillPoints[FPointCount * 2 + 1] := TVec2f.Create(AX, ACall.MaxValue);
  FPoints[FPointCount] := TVec2f.Create(AX, ACall.Value / ACall.Count);
  Inc(FPointCount);

  if FMaxValue < ACall.MaxValue then
    FMaxValue := ACall.MaxValue;
end;

{ TProfilerNode }

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
  FServerSocket.OnRead := ServerSocketRead;
  FServerSocket.Open;

  FTimer := TQuadCanvasGLTimer.Create;
  FTimer.OnTimer := Timer;
end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
  FTimer.Free;

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

procedure TfMainForm.ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);

  function FindProfiler(const AGUID: TGUID): TProfilerNode;
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

var
  Code: Word;
  GUID: TGUID;
  Profiler: TProfilerNode;
  ProfilerTag: TProfilerTagNode;

  Str: WideString;
  StrLen: Byte;
  ID: Word;
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

      if not Assigned(Profiler) and (Code = 2) then
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
              end;
            2:
              begin
                Profiler.Client := AClient;
                Code := 4;
                AClient.SendBuf(Code, SizeOf(Code));
              end;
            3:
              begin
                FMemory.Read(ID, SizeOf(ID));
                FMemory.Read(StrLen, SizeOf(StrLen));
                SetLength(Str, StrLen);
                FMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));

                ProfilerTag := Profiler.FindTag(ID);
                if not Assigned(ProfilerTag) then
                begin
                  FNodeClass := TProfilerTagNode;
                  ProfilerTag := TreeView.Items.AddChild(Profiler, Str) as TProfilerTagNode;
                  ProfilerTag.ID := ID;
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

procedure TfMainForm.PaintPanelResize(Sender: TObject);
begin
  if Assigned(FCanvasGL) then
    FCanvasGL.Resize(PaintPanel.Width, PaintPanel.Height);
end;

procedure TfMainForm.PaintTimerTimer(Sender: TObject);
begin
    //
end;

procedure TfMainForm.Timer(const Delta: Double);
var
  i: Integer;
  Rect: TRect;
  Node: TTreeNode;
  ProfilerTag: TProfilerTagNode;
  Camera: TQuadCanvasGLCamera;
begin
  Camera := TQuadCanvasGLCamera.Create;
  FCanvasGL.RenderingBegin($FF191919);
  FCanvasGL.TextOut(nil, TVec2f.Create(-50, -50), ' ');
  try
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      Rect := Node.DisplayRect(False);
      if (Rect.Height > 0) and (Rect.Bottom > 0) and (Rect.Top < PaintPanel.Height) then
      begin
        if Node is TProfilerTagNode then
        begin
          FCanvasGL.SetPenColor($FF333333);
          FCanvasGL.DrawLine(TVec2f.Create(0, Rect.Bottom), TVec2f.Create(PaintPanel.Width, Rect.Bottom));
          ProfilerTag := TProfilerTagNode(Node);
          if ProfilerTag.PointCount > 1 then
          begin
            Camera.Translate := TVec2f.Create(PaintPanel.Width - TProfilerNode(ProfilerTag.Parent).Position, Rect.Top + TREEVIEW_ITEM_HEIGHT);
            Camera.Scale := TVec2f.Create(1, -((TREEVIEW_ITEM_HEIGHT - 4) / ProfilerTag.MaxValue) );
            FCanvasGL.ApplyCamera(Camera);
            FCanvasGL.SetBrushColor($55799C06);
            FCanvasGL.FillPolygon(@ProfilerTag.FFillPoints[0], ProfilerTag.PointCount * 2);
            FCanvasGL.SetPenColor($FF799C06);
            FCanvasGL.DrawPolyline(@ProfilerTag.Points[0], ProfilerTag.PointCount);
            FCanvasGL.ApplyCamera(nil);
          end;
          FCanvasGL.TextOut(nil, TVec2f.Create(20, Rect.Top), IntToStr(ProfilerTag.PointCount));
        end;
      end;
    end;
  finally
    FCanvasGL.RenderingEnd;
    Camera.Free;
  end;
end;

procedure TfMainForm.TreeViewCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := FNodeClass;
end;

end.
