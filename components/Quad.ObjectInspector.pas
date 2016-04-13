unit Quad.ObjectInspector;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, CommCtrl, System.Rtti, System.TypInfo,
  System.Types, Vcl.StdCtrls;

type
  TQuadObjectInspectorNodeClass = class of TQuadObjectInspectorNode;

  TQuadObjectInspectorNode = class(TTreeNode)
  private
    FObject: TObject;
    FRttiProp: TRttiProperty;
    function GetControl: TControl; virtual; abstract;
    procedure Init(ARttiProp: TRttiProperty; AObject: TObject); virtual;
  public
    property Control: TControl read GetControl;

  end;

  TQuadObjectInspectorNodeEdit = class(TQuadObjectInspectorNode)
  private
    FEdit: TEdit;
    procedure EditChange(Sender: TObject);
    function GetControl: TControl; override;
    procedure Init(ARttiProp: TRttiProperty; AObject: TObject); override;
  public
    destructor Destroy; override;
  end;

  TQuadObjectInspectorNodeEnum = class(TQuadObjectInspectorNode)
  private
    FComboBox: TComboBox;
    procedure ComboBoxChange(Sender: TObject);
    function GetControl: TControl; override;
    procedure Init(ARttiProp: TRttiProperty; AObject: TObject); override;
  public
    destructor Destroy; override;
  end;

  TQuadObjectInspector = class(TTreeView)
  private
    FRttiContext: TRttiContext;
    FObject: TObject;
    FNodeClass: TQuadObjectInspectorNodeClass;
    procedure HideNode(Node : TTreeNode);
  protected
    procedure Collapse(Node: TTreeNode); override;
    function CustomDrawItem(Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages: Boolean): Boolean; override;
    function IsCustomDrawn(Target: TCustomDrawTarget; Stage: TCustomDrawStage): Boolean; override;
    function CreateNode: TTreeNode; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetObject(AObject: TObject);
  published

  end;

implementation

{ TQuadObjectInspectorNode }

procedure TQuadObjectInspectorNode.Init(ARttiProp: TRttiProperty; AObject: TObject);
begin
  TreeView_SetItemHeight(Handle, 21);
  FRttiProp := ARttiProp;
  FObject := AObject;
end;

{ TQuadObjectInspectorNodeEdit }

procedure TQuadObjectInspectorNodeEdit.Init(ARttiProp: TRttiProperty; AObject: TObject);
begin
  inherited;
  FEdit := TEdit.Create(Owner.Owner);
  FEdit.Parent := Owner.Owner;
  FEdit.OnChange := EditChange;
end;

destructor TQuadObjectInspectorNodeEdit.Destroy;
begin
  if Assigned(FEdit) then
    FEdit.Free;
  inherited;
end;

procedure TQuadObjectInspectorNodeEdit.EditChange(Sender: TObject);
begin
  //
end;

function TQuadObjectInspectorNodeEdit.GetControl: TControl;
begin
  Result := FEdit;
end;

{ TQuadObjectInspectorNodeEnum }

procedure TQuadObjectInspectorNodeEnum.Init(ARttiProp: TRttiProperty; AObject: TObject);
var
  EnumTypeInfo: PTypeInfo;
  EnumTypeData: PTypeData;
  Index, i: Integer;
  Str: string;
  Value: TValue;
begin
  inherited;
  FComboBox := TComboBox.Create(Owner.Owner);
  FComboBox.Parent := Owner.Owner;
  FComboBox.OnChange := ComboBoxChange;
  FComboBox.Style := csDropDownList;

  Value := FRttiProp.GetValue(FObject);
  EnumTypeInfo := Value.TypeInfo;
  EnumTypeData := GetTypeData(EnumTypeInfo);
  for i := EnumTypeData.MinValue to EnumTypeData.MaxValue do
  begin
    Str := GetEnumName(EnumTypeInfo, i);
    if Str <> '' then
    begin
      Index := FComboBox.Items.AddObject(Str, TObject(i));
    end;
  end;
end;

destructor TQuadObjectInspectorNodeEnum.Destroy;
begin
  if Assigned(FComboBox) then
    FComboBox.Free;
  inherited;
end;

procedure TQuadObjectInspectorNodeEnum.ComboBoxChange(Sender: TObject);
begin
  //
end;

function TQuadObjectInspectorNodeEnum.GetControl: TControl;
begin
  Result := FComboBox;
end;

{ TQuadObjectInspector }

constructor TQuadObjectInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNodeClass := nil;
  FRttiContext := TRttiContext.Create;
end;

destructor TQuadObjectInspector.Destroy;
begin
  FRttiContext.Free;
  inherited;
end;

function TQuadObjectInspector.CreateNode: TTreeNode;
var
  LClass: TTreeNodeClass;
begin
  if not Assigned(FNodeClass) then
  begin
    LClass := TTreeNode;
    if Assigned(OnCreateNodeClass) then
      OnCreateNodeClass(Self, LClass);
    Result := LClass.Create(Items);
  end
  else
    Result := FNodeClass.Create(Items);
end;

procedure TQuadObjectInspector.SetObject(AObject: TObject);
var
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  Value: TValue;
  Node, MainNode: TTreeNode;
begin
  if FObject = AObject then
    Exit;
  FObject := AObject;
  Items.Clear;

  RttiType := FRttiContext.GetType(ClassInfo);

  Items.BeginUpdate;
  try
    for RttiProp in RttiType.GetProperties do
      if Assigned(RttiProp) then
      begin
        case RttiProp.PropertyType.TypeKind of
          tkInteger, tkString, tkFloat, tkLString, tkWString:
            FNodeClass := TQuadObjectInspectorNodeEdit;
          tkEnumeration:
            FNodeClass := TQuadObjectInspectorNodeEnum;

          // tkSet, tkRecord, tkClass:
           //  Self.Items.AddChild(nil, RttiProp.Name);
        end;

        if Assigned(FNodeClass) then
        begin
          Node := Items.AddChild(nil, RttiProp.Name);
          TQuadObjectInspectorNodeEdit(Node).Init(RttiProp, FObject);
        end;

        FNodeClass := nil;
      end;
  finally
    Items.EndUpdate;
  end;
end;

function TQuadObjectInspector.IsCustomDrawn(Target: TCustomDrawTarget; Stage: TCustomDrawStage): Boolean;
begin
  Result := True;
end;

function TQuadObjectInspector.CustomDrawItem(Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages: Boolean): Boolean;
var
  Control: TControl;
  R: TRect;
  i: Integer;
begin
  inherited;
  Result := True;
  PaintImages := False;

  for i := 0 to Node.Count - 1 do
    if Node.Item[i] is TQuadObjectInspectorNode then
      TQuadObjectInspectorNode(Node.Item[i]).Control.Visible := Node.Expanded;

  if Node is TQuadObjectInspectorNode then
  begin
    Control := TQuadObjectInspectorNode(Node).Control;
    R := Node.DisplayRect(True);
    Control.Top := R.Top;
    Control.Left := 100;
    Control.Width := Self.Width - 123;
  end;
end;

procedure TQuadObjectInspector.HideNode(Node : TTreeNode);
begin
  while Node <> nil do
  begin
    if Node.HasChildren then
      HideNode(node.GetFirstChild);

    if Assigned(Node.Data) then
      TControl(Node.Data).Visible := False;

    Node := Node.GetNextSibling;
  end;
end;

procedure TQuadObjectInspector.Collapse(Node: TTreeNode);
begin
  inherited;
  HideNode(Node);
  Repaint;
end;

end.
