unit Quad.ObjectInspector;

interface


uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, System.Rtti, System.TypInfo,
  Vcl.ExtCtrls, Vcl.StdCtrls, Winapi.Messages, System.Generics.Collections, System.Generics.Defaults,
  Vcl.CheckLst;

type
  TQuadObjectInspectorPanel = class;
  TQuadObjectInspector = class;

  TQuadObjectInspectorItemType = (itNone, itProp, itField);

  TQuadObjectInspectorItem = class(TPanel)
  strict private
    function GetOwnerPanel: TQuadObjectInspectorPanel;
    function GetCaption: string;
  strict protected
    FType: TQuadObjectInspectorItemType;
    FLabel: TLabel;
    FRttiMember: TRttiMember;
    function GetValue: TValue;
    procedure SetValue(Value: TValue);
    function GetType: TRttiType;
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); virtual;
    property OwnerPanel: TQuadObjectInspectorPanel read GetOwnerPanel;
    property Caption: string read GetCaption;
  end;

  TQuadObjectInspectorItemEdit = class(TQuadObjectInspectorItem)
  strict protected
    FEdit: TEdit;
    procedure EditChange(Sender: TObject);
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); override;
  end;

  TQuadObjectInspectorItemBool = class(TQuadObjectInspectorItem)
  strict private
    FCheckBox: TCheckBox;
    procedure CheckBoxClick(Sender: TObject);
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); override;
  end;

  TQuadObjectInspectorItemEnum = class(TQuadObjectInspectorItem)
  strict private
    FComboBox: TComboBox;
    procedure ComboBoxChange(Sender: TObject);
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); override;
  end;

  TQuadObjectInspectorItemSet = class(TQuadObjectInspectorItemEdit)
  strict private
    FCheckListBox: TCheckListBox;
    procedure CheckListBoxClickCheck(Sender: TObject);
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); override;
  end;

  TQuadObjectInspectorItemRecord = class(TQuadObjectInspectorItem)
  strict private
    FPanel: TQuadObjectInspectorPanel;
    procedure PanelChange(Sender: TObject);
  public
    constructor Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember); override;
  end;

  TQuadObjectInspectorPanel = class(TPanel)
  strict private
    FInspectedObject: Pointer;
    FRttiContext: TRttiContext;
    FRttiType: TRttiType;
    FOnChange: TNotifyEvent;
    constructor Create(AOwner: TComponent); overload; override;
    function IsBoolean(ARttiType: TRttiType): Boolean;
    procedure Add(ARttiType: TRttiType; ARttiMember: TRttiMember);
  public
    constructor Create(AOwner: TQuadObjectInspector; AInspectedObject: TObject); overload;
    constructor Create(AOwner: TQuadObjectInspectorItem; AInspectedObject: Pointer; ARecordType: TRttiType); overload;
    procedure Change;
    procedure SetChange(AOnChange: TNotifyEvent);
    procedure Init;
    procedure FieldsInit;
    destructor Destroy; override;
    property InspectedObject: Pointer read FInspectedObject;
  end;

  TQuadObjectInspector = class(TScrollBox)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function AddObject(AObject: TObject): TQuadObjectInspectorPanel;
  end;

implementation

{ TQuadObjectInspectorItem }

constructor TQuadObjectInspectorItem.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
begin
  inherited Create(AOwner);
  FRttiMember := ARttiMember;
  if ARttiMember is TRttiProperty then
    FType := itProp
  else
    if ARttiMember is TRttiField then
      FType := itField
    else
      FType := itNone;

  Self.Parent := AOwner;
  Self.BevelOuter := bvNone;
  Self.Height := 21;
  Self.Align := alTop;
  FLabel := TLabel.Create(Self);
  FLabel.Parent := Self;
  FLabel.Left := 16;
  FLabel.Top := 4;
  FLabel.Caption := FRttiMember.Name;
end;

function TQuadObjectInspectorItem.GetOwnerPanel: TQuadObjectInspectorPanel;
begin
  if Owner is TQuadObjectInspectorPanel then
    Result := TQuadObjectInspectorPanel(Owner)
  else
    Result := nil;
end;

function TQuadObjectInspectorItem.GetValue: TValue;
begin
  Result := nil;
  case FType of
    itProp: Result := (FRttiMember as TRttiProperty).GetValue(OwnerPanel.InspectedObject);
    itField: Result := (FRttiMember as TRttiField).GetValue(OwnerPanel.InspectedObject);
  end;
end;

procedure TQuadObjectInspectorItem.SetValue(Value: TValue);
begin
  case FType of
    itProp: (FRttiMember as TRttiProperty).SetValue(OwnerPanel.InspectedObject, Value);
    itField: (FRttiMember as TRttiField).SetValue(OwnerPanel.InspectedObject, Value);
  end;
  OwnerPanel.Change;
end;

function TQuadObjectInspectorItem.GetType: TRttiType;
begin
  Result := nil;
  case FType of
    itProp: Result := (FRttiMember as TRttiProperty).PropertyType;
    itField: Result := (FRttiMember as TRttiField).FieldType;
  end;
end;

function TQuadObjectInspectorItem.GetCaption: string;
begin
  Result := FLabel.Caption;
end;

{ TQuadObjectInspectorItemEdit }

constructor TQuadObjectInspectorItemEdit.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
var
  Value: TValue;
begin
  inherited;
  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Align := alRight;
  FEdit.Width := 128;
  Value := GetValue;
  case GetType.TypeKind of
    tkFloat: FEdit.Text := FormatFloat('0.0#####', Value.AsExtended );
    else FEdit.Text := Value.ToString;
  end;
  FEdit.OnChange := EditChange;
end;

procedure TQuadObjectInspectorItemEdit.EditChange(Sender: TObject);
begin
  if Assigned(OwnerPanel) then
    case GetType.TypeKind of
      tkInteger:
        SetValue(StrToIntDef(FEdit.Text, 0));
      tkFloat:
        SetValue(StrToFloatDef(FEdit.Text, 0));
      tkString, tkLString, tkWString, tkUString, tkWChar, tkChar:
        SetValue(FEdit.Text);
    end;
end;

{ TQuadObjectInspectorItemBool }

constructor TQuadObjectInspectorItemBool.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
var
  Value: TValue;
begin
  inherited;
  FCheckBox := TCheckBox.Create(Self);
  FCheckBox.Parent := Self;
  FCheckBox.Align := alRight;
  FCheckBox.Width := 128;
  Value := GetValue;
  FCheckBox.Caption := Value.ToString;
  FCheckBox.OnClick := CheckBoxClick;
  FCheckBox.Checked := Value.AsOrdinal = 1;
end;

procedure TQuadObjectInspectorItemBool.CheckBoxClick(Sender: TObject);
begin
  SetValue(FCheckBox.Checked);
  FCheckBox.Caption := GetValue.ToString;
end;

{ TQuadObjectInspectorItemEnum }

constructor TQuadObjectInspectorItemEnum.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
var
  Value: TValue;
  EnumTypeInfo: PTypeInfo;
  EnumTypeData: PTypeData;
  i: Integer;
  Str: string;
begin
  inherited;
  FComboBox := TComboBox.Create(Self);
  FComboBox.Parent := Self;
  FComboBox.Align := alRight;
  FComboBox.Width := 128;
  Value := GetValue;
  EnumTypeInfo := GetType.Handle;
  EnumTypeData := GetTypeData(EnumTypeInfo);
  for i := EnumTypeData.MinValue to EnumTypeData.MaxValue do
  begin
    Str := GetEnumName(EnumTypeInfo, i);
    if Str <> '' then
      FComboBox.Items.AddObject(Str, TObject(i));
  end;
  FComboBox.Text := Value.ToString;
  FComboBox.OnChange := ComboBoxChange;
end;

procedure TQuadObjectInspectorItemEnum.ComboBoxChange(Sender: TObject);
begin
  SetValue(TValue.FromOrdinal(GetType.Handle, Integer(FComboBox.Items.Objects[FComboBox.ItemIndex])));
end;

{ TQuadObjectInspectorItemSet }

constructor TQuadObjectInspectorItemSet.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
var
  Value: TValue;
  TypeInfo, TypeInfo1: PTypeInfo;
  TypeData, TypeData1: PTypeData;
  i, Index: Integer;
  Str: string;
begin
  inherited;
  FEdit.Align := alCustom;
  FEdit.Width := 128;
  FEdit.Top := 0;
  FEdit.Left := Width - FEdit.Width;
  FEdit.Anchors := [akTop, akRight];

  FCheckListBox := TCheckListBox.Create(Self);
  FCheckListBox.Parent := Self;
  //FCheckListBox.Align := alRight;
  FCheckListBox.OnClickCheck := CheckListBoxClickCheck;
  Value := GetValue;
  FEdit.ReadOnly := True;
  FEdit.Text := Value.ToString;
  TypeInfo := Value.TypeInfo;
  TypeData := GetTypeData(TypeInfo);

  TypeInfo1 := TypeData.CompType^;
  TypeData1 := GetTypeData(TypeInfo1);
  for i := TypeData1.MinValue to TypeData1.MaxValue do
  begin
    Str := GetEnumName(TypeInfo1, i);
    if Str <> '' then
    begin
      Index := FCheckListBox.Items.AddObject(Str, TObject(i));
      FCheckListBox.Checked[Index] := Pos(Str, FEdit.Text) > 0;
    end;
  end;
  FCheckListBox.Height := FCheckListBox.Count * FCheckListBox.ItemHeight + 4;
  FCheckListBox.Width := 128;
  FCheckListBox.Top := 21;
  FCheckListBox.Left := Width - FCheckListBox.Width;
  FCheckListBox.Anchors := [akTop, akRight];
  Height := FCheckListBox.Height + FEdit.Height;
end;

procedure TQuadObjectInspectorItemSet.CheckListBoxClickCheck(Sender: TObject);
var
  i: Integer;
  Str: String;
  Value: TValue;
begin
  Str := '[';
  for i := 0 to FCheckListBox.Count - 1 do
    if FCheckListBox.Checked[i] then
    begin
      if Str <> '[' then
        Str := Str + ',';
      Str := Str + FCheckListBox.Items[i];
    end;
  Str := Str + ']';
  Value := GetValue;
  i := StringToSet(Value.TypeInfo, Str);
  TValue.Make(@i, Value.TypeInfo, Value);
  SetValue(Value);
  FEdit.Text := Str;
end;

{ TQuadObjectInspectorItemRecord }

constructor TQuadObjectInspectorItemRecord.Create(AOwner: TQuadObjectInspectorPanel; ARttiMember: TRttiMember);
begin
  inherited;

  FPanel := TQuadObjectInspectorPanel.Create(Self, GetValue.GetReferenceToRawData, GetType.AsRecord);
  FPanel.Align := alCustom;
  FPanel.Anchors := [akTop, akLeft, akRight];
  FPanel.Width := Width - 16;
  FPanel.Top := 21;
  FPanel.Left := Width - FPanel.Width;
  Height := FPanel.Height + 21;
  FPanel.SetChange(PanelChange);
end;

procedure TQuadObjectInspectorItemRecord.PanelChange(Sender: TObject);
var
  Value: TValue;
begin
  TValue.Make(FPanel.InspectedObject, GetType.Handle, Value);
  SetValue(Value);
end;

{ TQuadObjectInspectorPanel }

constructor TQuadObjectInspectorPanel.Create(AOwner: TComponent);
begin
  inherited;
  Parent := TWinControl(AOwner);
  Top := MaxInt;
  Align := alTop;
  AutoSize := True;
  BevelOuter := bvNone;
  FInspectedObject := nil;
  FRttiContext := TRttiContext.Create;
end;

constructor TQuadObjectInspectorPanel.Create(AOwner: TQuadObjectInspector; AInspectedObject: TObject);
begin
  Create(AOwner);
  FInspectedObject := AInspectedObject;
  FRttiType := FRttiContext.GetType(AInspectedObject.ClassInfo);
  Init;
end;

constructor TQuadObjectInspectorPanel.Create(AOwner: TQuadObjectInspectorItem; AInspectedObject: Pointer; ARecordType: TRttiType);
begin
  Create(AOwner);
  FInspectedObject := AInspectedObject;
  FRttiType := ARecordType;
  FieldsInit;
end;

destructor TQuadObjectInspectorPanel.Destroy;
begin
  FRttiContext.Free;
  inherited;
end;

procedure TQuadObjectInspectorPanel.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TQuadObjectInspectorPanel.Init;

  procedure PropListSort(var APropList: TArray<TRttiProperty>);
  var
    i, k: Integer;
    Prop: TRttiProperty;
  begin
    for k := 1 to High(APropList) do
      for i := 1 to High(APropList) do
        if CompareText(APropList[i - 1].Name, APropList[i].Name) < 0 then
        begin
          Prop := APropList[i - 1];
          APropList[i - 1] := APropList[i];
          APropList[i] := Prop;
        end;
  end;

var
  RttiProp: TRttiProperty;
  PropList: TArray<TRttiProperty>;
begin
  PropList := FRttiType.GetProperties;
  PropListSort(PropList);
  for RttiProp in PropList do
    if Assigned(RttiProp) and RttiProp.IsWritable and RttiProp.IsReadable then
      Add(RttiProp.PropertyType, RttiProp);
end;

procedure TQuadObjectInspectorPanel.FieldsInit;

  procedure FieldListSort(var AFieldList: TArray<TRttiField>);
  var
    i, k: Integer;
    Field: TRttiField;
  begin
    for k := 1 to High(AFieldList) do
      for i := 1 to High(AFieldList) do
        if CompareText(AFieldList[i - 1].Name, AFieldList[i].Name) < 0 then
        begin
          Field := AFieldList[i - 1];
          AFieldList[i - 1] := AFieldList[i];
          AFieldList[i] := Field;
        end;
  end;

var
  RttiField: TRttiField;
  FieldList: TArray<TRttiField>;
begin
  FieldList := FRttiType.GetFields;
  FieldListSort(FieldList);
  for RttiField in FieldList do
    if Assigned(RttiField) and Assigned(RttiField.FieldType) then
      Add(RttiField.FieldType, RttiField);
end;

procedure TQuadObjectInspectorPanel.Add(ARttiType: TRttiType; ARttiMember: TRttiMember);
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TQuadObjectInspectorItem) and ((Components[i] as TQuadObjectInspectorItem).Caption = ARttiMember.Name) then
      Exit;

  case ARttiType.TypeKind of
    tkInteger, tkFloat, tkString, tkLString, tkWString, tkUString, tkWChar, tkChar:
      TQuadObjectInspectorItemEdit.Create(Self, ARttiMember);
    tkEnumeration:
      if IsBoolean(ARttiType) then
        TQuadObjectInspectorItemBool.Create(Self, ARttiMember)
      else
        TQuadObjectInspectorItemEnum.Create(Self, ARttiMember);
    tkSet:
      TQuadObjectInspectorItemSet.Create(Self, ARttiMember);
    tkRecord:
      TQuadObjectInspectorItemRecord.Create(Self, ARttiMember);
    tkProcedure, tkClass: ;
    else
      TQuadObjectInspectorItem.Create(Self, ARttiMember);
  end;
end;

function TQuadObjectInspectorPanel.IsBoolean(ARttiType: TRttiType): Boolean;
var
  EnumTypeInfo: PTypeInfo;
  EnumTypeData: PTypeData;
begin
  EnumTypeInfo := ARttiType.Handle;
  EnumTypeData := GetTypeData(EnumTypeInfo);

  Result := (EnumTypeData.MinValue = 0) and (EnumTypeData.MaxValue = 1)
    and (CompareText(GetEnumName(EnumTypeInfo, 0), 'false') = 0)
    and (CompareText(GetEnumName(EnumTypeInfo, 1), 'true') = 0);
end;

procedure TQuadObjectInspectorPanel.SetChange(AOnChange: TNotifyEvent);
begin
  FOnChange := AOnChange;
end;

{ TQuadObjectInspector }

constructor TQuadObjectInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TQuadObjectInspector.Destroy;
begin
  inherited;
end;

procedure TQuadObjectInspector.Clear;
var
  i: Integer;
begin
  for i := ComponentCount - 1 downto 0 do
    if Components[i] is TQuadObjectInspectorPanel then
      Components[i].Free;
end;

function TQuadObjectInspector.AddObject(AObject: TObject): TQuadObjectInspectorPanel;
begin
  Result := TQuadObjectInspectorPanel.Create(Self, AObject);
end;

end.

