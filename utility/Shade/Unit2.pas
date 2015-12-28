unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, QuadMemo, ExtCtrls, QuadIcon;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    ColoringPanel: TPanel;
    QuadMemo2: TQuadMemo;
    ColorDialog1: TColorDialog;
    ListBox1: TListBox;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    QuadIcon1: TQuadIcon;
    Label4: TLabel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label5: TLabel;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure QuadIcon1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Types;

{$R *.dfm}

procedure TForm2.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ColorRect: TRect;
begin
  ListBox1.Canvas.Font.Color := clSilver;
  if odSelected in State then
  begin
    ListBox1.Canvas.Brush.Color := $252525;
    ListBox1.Canvas.Font.Color := $0080FF;
  end;

  ListBox1.Canvas.FillRect(Rect);

  ListBox1.Canvas.TextOut(Rect.Left + 24 + 64, Rect.Top, ListBox1.Items[Index]);

  ColorRect := Rect;
  //ColorRect.Left := Rect.Left + 32 + ListBox1.Canvas.TextWidth(ListBox1.Items[Index]);
  ColorRect.Left := Rect.Left + 64;
  ColorRect.Right := ColorRect.Left + 16;
  ColorRect.Top := ColorRect.Top + 4;
  ColorRect.Bottom := ColorRect.Bottom - 4;



  case Index of
    0: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.BackGround;
    1: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.SelectedLine;
    2: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.ErrorLine;
    3: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.Selection;
    4: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.Hint;
    5: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.ServiceBar;
    6: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.ScrollBars;
    7: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.Active;
    8: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextChanged;
    9: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextSaved;
    10: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextHighlight;
    11: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.RightMargin;
    12: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextNormal;
    13: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextReserved;
    14: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextComments;
    15: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextFunction;
    16: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextString;
    17: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextConstant;
    18: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextDevider;
    19: ListBox1.Canvas.Brush.Color := QuadMemo2.Colors.TextDefine;
  end;


  ListBox1.Canvas.Rectangle(ColorRect);


  if odSelected in State then
    ListBox1.Canvas.DrawFocusRect(Rect);
end;

procedure TForm2.QuadIcon1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TForm2.Label2Click(Sender: TObject);
begin
  Label1.Font.Color := clSilver;
  Label2.Font.Color := clSilver;
  Label3.Font.Color := clSilver;

  Label2.Font.Color := $0080FF;
  Label4.Caption := 'HLSL compiler options';

  ColoringPanel.Visible := Label1.Font.Color = $0080FF;
  Panel4.Visible := Label2.Font.Color = $0080FF;
  Panel5.Visible := Label3.Font.Color = $0080FF;
end;

procedure TForm2.Label1Click(Sender: TObject);
begin
  Label1.Font.Color := clSilver;
  Label2.Font.Color := clSilver;
  Label3.Font.Color := clSilver;

  Label1.Font.Color := $0080FF;
  Label4.Caption := 'Syntax highlight colors can be changed here';

  ColoringPanel.Visible := Label1.Font.Color = $0080FF;
  Panel4.Visible := Label2.Font.Color = $0080FF;
  Panel5.Visible := Label3.Font.Color = $0080FF;
end;

procedure TForm2.Label3Click(Sender: TObject);
begin
  Label1.Font.Color := clSilver;
  Label2.Font.Color := clSilver;
  Label3.Font.Color := clSilver;

  Label3.Font.Color := $0080FF;
  Label4.Caption := 'IDE Environment tuning options';

  ColoringPanel.Visible := Label1.Font.Color = $0080FF;
  Panel4.Visible := Label2.Font.Color = $0080FF;
  Panel5.Visible := Label3.Font.Color = $0080FF;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Label2.OnClick(nil);
end;

procedure TForm2.ListBox1DblClick(Sender: TObject);
var
  Col: PColor;
begin
  case ListBox1.ItemIndex of
    0: Col := @QuadMemo2.Colors.BackGround;
    1: Col := @QuadMemo2.Colors.SelectedLine;
    2: Col := @QuadMemo2.Colors.ErrorLine;
    3: Col := @QuadMemo2.Colors.Selection;
    4: Col := @QuadMemo2.Colors.Hint;
    5: Col := @QuadMemo2.Colors.ServiceBar;
    6: Col := @QuadMemo2.Colors.ScrollBars;
    7: Col := @QuadMemo2.Colors.Active;
    8: Col := @QuadMemo2.Colors.TextChanged;
    9: Col := @QuadMemo2.Colors.TextSaved;
    10: Col := @QuadMemo2.Colors.TextHighlight;
    11: Col := @QuadMemo2.Colors.RightMargin;
    12: Col := @QuadMemo2.Colors.TextNormal;
    13: Col := @QuadMemo2.Colors.TextReserved;
    14: Col := @QuadMemo2.Colors.TextComments;
    15: Col := @QuadMemo2.Colors.TextFunction;
    16: Col := @QuadMemo2.Colors.TextString;
    17: Col := @QuadMemo2.Colors.TextConstant;
    18: Col := @QuadMemo2.Colors.TextDevider;
    19: Col := @QuadMemo2.Colors.TextDefine;
  end;

  ColorDialog1.Color := Col^;

  if ColorDialog1.Execute then
    Col^ := ColorDialog1.Color;

  ListBox1.Refresh;
end;

procedure TForm2.Label5Click(Sender: TObject);
begin
  Label1.Font.Color := clSilver;
  Label2.Font.Color := clSilver;
  Label3.Font.Color := clSilver;

  Label3.Font.Color := $0080FF;
  Label4.Caption := 'About QuadShade';

  ColoringPanel.Visible := Label1.Font.Color = $0080FF;
  Panel4.Visible := Label2.Font.Color = $0080FF;
  Panel5.Visible := Label3.Font.Color = $0080FF;
end;

end.
