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
    Timer: TTimer;
    lvLog: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure lvLogCreateItemClass(Sender: TCustomListView;
      var ItemClass: TListItemClass);
  private
    FSocket: TQuadSocket;
    FMemory: TMemoryStream;
  public
    procedure RepaintAll;
    property Socket: TQuadSocket read FSocket;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.FormCreate(Sender: TObject);
begin
  FMemory := TMemoryStream.Create;
  FSocket := TQuadSocket.Create;
  FSocket.InitSocket(17788);
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FSocket) then
    FSocket.Free;
  if Assigned(FMemory) then
    FMemory.Free;
end;

procedure TfMain.lvLogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TLogListItem;
end;

procedure TfMain.TimerTimer(Sender: TObject);
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
  Address: PQuadSocketAddressItem;
  Code: Word;
  GUID: TGUID;
  Diagram: TDiagramView;
begin
  IsRefresh := False;

  while FSocket.Recv(Address, FMemory) do
    if FMemory.Size > 0 then
    begin
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
              PanelGroup.Panels.Add(TDiagramView.Create(PanelGroup, Address, GUID));
            IsRefresh := True;
          end;
      end;
    end;

  if IsRefresh then
    RepaintAll;
end;

procedure TfMain.RepaintAll;
var
  i: Integer;
begin
  for i := 0 to PanelGroup.Panels.Count - 1 do
    TDiagramView(PanelGroup.Panels[i]).Repaint;
end;

end.
