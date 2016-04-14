unit Quad.ObjectInspector;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, CommCtrl, System.Rtti, System.TypInfo,
  System.Types, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TQuadObjectInspectorNodeClass = class of TQuadObjectInspectorNode;

  TQuadObjectInspectorNode = class(TTreeNode)
  private
    FObject: TObject;
    FRttiProp: TRttiProperty;
    function GetControl: TControl; virtual; abstract;
    procedure Init(ARttiProp: TRttiProperty; AObject: TObject); virtual;
    procedure UpdateParams(AControl: TControl);
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

  TQuadObjectInspectorNodeSetItem = class(TQuadObjectInspectorNode)
  private
    FCheckBox: TCheckBox;
    FValue: Integer;
    function GetControl: TControl; override;
    function GetChecked: Boolean;
    procedure SetChecked(Value: Boolean);
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
    property Value: Integer read FValue;
    property Checked: Boolean read GetChecked write SetChecked;
  end;

  TQuadObjectInspectorNodeSet = class(TQuadObjectInspectorNode)
  private
    FLabel: TLabel;
    function GetControl: TControl; override;
    procedure Init(ARttiProp: TRttiProperty; AObject: TObject); override;
  public
    destructor Destroy; override;
  end;

  TQuadObjectInspector = class(TTreeView)
  private
    FPanel: TPanel;
    FSplitter: TSplitter;
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
  TreeView_SetItemHeight(Handle, 22);
  FRttiProp := ARttiProp;
  FObject := AObject;
end;

procedure TQuadObjectInspectorNode.UpdateParams(AControl: TControl);
begin
  AControl.Parent := TQuadObjectInspector(Owner.Owner).FPanel;
  AControl.Left := 0;
  AControl.Width := AControl.Parent.Width;
  AControl.Anchors := [akLeft, akRight, akTop];
end;

{ TQuadObjectInspectorNodeEdit }

procedure TQuadObjectInspectorNodeEdit.Init(ARttiProp: TRttiProperty; AObject: TObject);
begin
  inherited;
  FEdit := TEdit.Create(Owner.Owner);
  UpdateParams(FEdit);
  FEdit.OnChange := EditChange;
  FEdit.Text := ARttiProp.Name;
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
  UpdateParams(FComboBox);
  FComboBox.OnChange := ComboBoxChange;
  FComboBox.Text := ARttiProp.Name;

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

{ TQuadObjectInspectorNodeSetitem }

constructor TQuadObjectInspectorNodeSetItem.Create(AOwner: TTreeNodes);
begin
  inherited;
  FCheckBox := TCheckBox.Create(Owner.Owner);
  UpdateParams(FCheckBox);
  FCheckBox.Caption := 'False';
end;

destructor TQuadObjectInspectorNodeSetItem.Destroy;
begin
  if Assigned(FCheckBox) then
    FCheckBox.Free;
  inherited;
end;

function TQuadObjectInspectorNodeSetItem.GetControl: TControl;
begin
  Result := FCheckBox;
end;

function TQuadObjectInspectorNodeSetItem.GetChecked: Boolean;
begin

end;

procedure TQuadObjectInspectorNodeSetItem.SetChecked(Value: Boolean);
begin

end;

{ TQuadObjectInspectorNodeSet }

procedure TQuadObjectInspectorNodeSet.Init(ARttiProp: TRttiProperty; AObject: TObject);
var
  EnumTypeInfo: PTypeInfo;
  EnumTypeData: PTypeData;
  Index, i: Integer;
  Str: string;
  Value: TValue;
begin
  inherited;
  FLabel := TLabel.Create(Owner.Owner);
  UpdateParams(FLabel);
  FLabel.Caption := '[]';
end;

destructor TQuadObjectInspectorNodeSet.Destroy;
begin
  if Assigned(FLabel) then
    FLabel.Free;
  inherited;
end;

function TQuadObjectInspectorNodeSet.GetControl: TControl;
begin
  Result := FLabel;
end;

{ TQuadObjectInspector }

constructor TQuadObjectInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNodeClass := nil;
  FRttiContext := TRttiContext.Create;
  FPanel := TPanel.Create(Self);
  FPanel.Parent := Self;
  FPanel.Align := alRight;
  FPanel.Width := 85;
  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alRight;
  FSplitter.Width := 4;
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
          tkSet:
            FNodeClass := TQuadObjectInspectorNodeSet;
          // tkRecord, tkClass:
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
    Control.Visible := True;
    Control.Top := R.Top;
   // Control.Left := 100;
   // Control.Width := Self.Width - 123;
   // Control.Invalidate;
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
 // HideNode(Node);
  Repaint;
end;

end.
