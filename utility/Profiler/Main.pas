unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DiagramView, QuadEngine.Socket,
  System.Generics.Collections, DiagramLine, Vcl.ComCtrls, ListLogItem;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    PanelGroup: TCategoryPanelGroup;
    lvLog: TListView;
    Timer: TTimer;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvLogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure TimerTimer(Sender: TObject);
  private
    FServerSocket: TQuadServerSocket;
    FMemory: TMemoryStream;

    procedure ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
    procedure ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
  public
    procedure RepaintAll;
    property ServerSocket: TQuadServerSocket read FServerSocket;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.FormCreate(Sender: TObject);
begin
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
end;

procedure TfMain.lvLogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TLogListItem;
end;

procedure TfMain.ServerSocketConnect(AServer: TQuadServerSocket; AClient: TQuadSocket);
begin

end;

procedure TfMain.ServerSocketRead(AServer: TQuadServerSocket; AClient: TQuadSocket);
  function FindPanel(const GUID: TGUID): TDiagramView;
  var
    i: Integer;
  begin
    for i := 0 to PanelGroup.Panels.Count - 1 do
      if TDiagramView(PanelGroup.Panels[i]).GUID = GUID then
        Exit(TDiagramView(PanelGroup.Panels[i]));
    Result := nil;
  end;
var
  IsRefresh: Boolean;
  Code: Word;
  GUID: TGUID;
  Diagram: TDiagramView;
begin
  //ShowMessage(AClient.ReceiveText);
  {it := lvLog.Items.Insert(0);
  it.Caption := AClient.ReceiveText;
  Exit; }
  if AClient.ReceiveStream(FMemory) <= 0 then
    Exit;

  IsRefresh := False;
  FMemory.Read(Code, SizeOf(Code));
  case Code of
    1, 2, 3, 4:
      begin
        FMemory.Read(GUID, SizeOf(GUID));
        Diagram := FindPanel(GUID);
        if Assigned(Diagram) then
        begin
          case Code of
            1: Diagram.Write(FMemory);
            2, 3, 4: Diagram.UpdateInfo(Code, FMemory);
          end;
        end
        else
          PanelGroup.Panels.Add(TDiagramView.Create(PanelGroup, AClient, GUID));
        IsRefresh := True;
      end;
  end;

  if IsRefresh then
    Timer.Enabled := True;
 //   RepaintAll;
 // Application.ProcessMessages;
end;

procedure TfMain.TimerTimer(Sender: TObject);
begin
  RepaintAll;
  Timer.Enabled := False;
end;

procedure TfMain.RepaintAll;
var
  i: Integer;
begin
  for i := 0 to PanelGroup.Panels.Count - 1 do
    TDiagramView(PanelGroup.Panels[i]).Repaint;
end;

end.
