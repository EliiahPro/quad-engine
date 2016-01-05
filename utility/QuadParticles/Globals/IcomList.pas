unit IcomList;

interface

uses
  System.SysUtils, System.Classes, Vcl.ImgList, Vcl.Controls,
  System.Generics.Collections, Vcl.ComCtrls, Vcl.Graphics;

type
  TCustomTreeNode = class(TTreeNode)
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
  end;

  TdmIcomList = class(TDataModule)
    List: TImageList;
    ilIcons32: TImageList;
    ilIcons16: TImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FStartIconCount: Integer;
    FPoolIcon: TList<Integer>;
    FTreeNodeCreateClass: TTreeNodeClass;
  public
    function CreateIcon: Integer;
    procedure DeleteIcon(AIndex: Integer);
    procedure ReplaceIcon(AIndex: Integer; AIcon: TBitmap);

    property TreeNodeCreateClass: TTreeNodeClass read FTreeNodeCreateClass write FTreeNodeCreateClass;
  end;

var
  dmIcomList: TdmIcomList;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TdmIcomList.CreateIcon: Integer;
begin
  if FPoolIcon.Count > 0 then
  begin
    Result := FPoolIcon[0];
    FPoolIcon.Delete(0);
  end
  else
    Result := List.Add(nil, nil);
end;

procedure TdmIcomList.DataModuleCreate(Sender: TObject);
begin
  FPoolIcon := TList<Integer>.Create;
  FStartIconCount := List.Count;
end;

procedure TdmIcomList.DataModuleDestroy(Sender: TObject);
begin
  FPoolIcon.Free;
end;

procedure TdmIcomList.DeleteIcon(AIndex: Integer);
begin
  if AIndex >= FStartIconCount then
    FPoolIcon.Add(AIndex);
end;

procedure TdmIcomList.ReplaceIcon(AIndex: Integer; AIcon: TBitmap);
begin
  if AIndex >= FStartIconCount then
    List.Replace(AIndex, AIcon, nil);
end;

{ TCustomTreeNode }

constructor TCustomTreeNode.Create(AOwner: TTreeNodes);
begin
  inherited;
  ImageIndex := dmIcomList.CreateIcon;
  SelectedIndex := ImageIndex;
end;

destructor TCustomTreeNode.Destroy;
begin
  dmIcomList.DeleteIcon(ImageIndex);
  inherited;
end;

end.
