unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, QuadEngine, QuadEngine.Socket,
  System.Generics.Collections, DiagramLine, Vcl.ComCtrls, ListLogItem, Vcl.Menus, ShellApi, DiagramFrame;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    Timer: TTimer;
    ScrollBox1: TScrollBox;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvLogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure TimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FServerSocket: TQuadServerSocket;
    FMemory: TMemoryStream;
    FFrames: TList<TfDiagramForm>;

    procedure ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
    procedure ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
  public
    property ServerSocket: TQuadServerSocket read FServerSocket;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.Button1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'demo09.exe', nil, nil, SW_SHOWNORMAL);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  FFrames := TList<TfDiagramForm>.Create;
  FMemory := TMemoryStream.Create;
  FServerSocket := TQuadServerSocket.Create(17788);
  FServerSocket.OnClientConnect := ServerSocketConnect;
  FServerSocket.OnRead := ServerSocketRead;
  FServerSocket.Open;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FServerSocket) then
    FServerSocket.Free;
  if Assigned(FMemory) then
    FMemory.Free;

  FFrames.Free;
end;

procedure TfMain.lvLogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TLogListItem;
end;

procedure TfMain.ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
var
  Code: Word;
begin
  Code := 2;
  AClient.SendBuf(Code, SizeOf(Code));
end;

procedure TfMain.ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
  function FindPanel(const GUID: TGUID): TfDiagramForm;
  var
    i: Integer;
  begin
    for i := 0 to FFrames.Count - 1 do
      if TfDiagramForm(FFrames[i]).GUID = GUID then
        Exit(TfDiagramForm(FFrames[i]));

    Result := nil;
  end;
var
  IsRefresh: Boolean;
  Code: Word;
  GUID: TGUID;
  Form: TfDiagramForm;
  Splitter: TSplitter;
begin
  if AClient.ReceiveStream(FMemory) <= 0 then
    Exit;

  IsRefresh := False;

  repeat
    FMemory.Read(Code, SizeOf(Code));
    case Code of
      1, 2, 3, 4:
        begin
          FMemory.Read(GUID, SizeOf(GUID));
          Form := FindPanel(GUID);
          if Assigned(Form) then
          begin
            case Code of
              1: Form.Write(FMemory);
              3, 4: Form.UpdateInfo(Code, FMemory);
            end;
          end
          else
            if Code = 2 then
            begin
              Form := TfDiagramForm.Create(Self, AClient, GUID);
              Form.Name := '';
              Form.Parent := ScrollBox1;
              Form.UpdateInfo(Code, FMemory);
              Form.Top := FFrames.Count * 300;
              FFrames.Add(Form);
              Splitter := TSplitter.Create(Self);
              Splitter.Align := alTop;
              Splitter.Height := 5;
              Splitter.Top := Form.Top + Form.ClientHeight;
              Splitter.Parent := ScrollBox1;
            end;

          IsRefresh := True;
        end;
    end;
  until FMemory.Position >= FMemory.Size;

  if IsRefresh then
    Timer.Enabled := True;
end;

procedure TfMain.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
end;

end.
