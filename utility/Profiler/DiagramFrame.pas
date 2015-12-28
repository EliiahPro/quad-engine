unit DiagramFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, DiagramLine;

type
  TfDiagramFrame = class(TFrame)
    List: TListView;
    Panel: TPanel;
    Scroll: TScrollBar;
    procedure ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
  private

  public
    function FindLineByID(AID: Word): TDiagramLine;
  end;

implementation

{$R *.dfm}

function TfDiagramFrame.FindLineByID(AID: Word): TDiagramLine;
var
  i: Integer;
begin
  for i := 0 to List.Items.Count - 1 do
    if TDiagramLine(List.Items[i]).ID = AID then
      Exit(TDiagramLine(List.Items[i]));
  Result := nil;
end;

procedure TfDiagramFrame.ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TDiagramLine;
end;

end.
