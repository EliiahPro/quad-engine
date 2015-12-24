unit QuadMemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdctrls, ExtCtrls, StrUtils, analizator;

type
  TSelection = record
    StartPos: TPoint;
    EndPos: TPoint;
  end;

  TQuadMemoColors = record
    BackGround: TColor;
    SelectedLine: TColor;
    ErrorLine: TColor;
    Selection: TColor;
    Hint: TColor;
    ServiceBar: TColor;
    ScrollBars: TColor;
    Active: TColor;
    TextChanged: TColor;
    TextSaved: TColor;
    TextHighlight: TColor;
    RightMargin: TColor;

    TextNormal: TColor;
    TextReserved: TColor;
    TextComments: TColor;
    TextFunction: TColor;
    TextString: TColor;
    TextConstant: TColor;
    TextDevider: TColor;
    TextDefine: TColor;
  end;

  TQuadMemoOptions = record
    IsTextShadowed: Boolean;
    IsSelectedLineHighlight: Boolean;
    IsSelectedLineShadowed: Boolean;
    IsRightMagin: Boolean;
    IsHighlightVar: Boolean;
    IsServicebarShadowed: Boolean;
    IsCodeAssist: Boolean;
    IsKeywordsBold: Boolean;
    TabSpacesCount: Byte;
    HintAfter: Byte;
  end;

  TBookMark = record
    Caret: TPoint;
    Camera: TPoint;
    IsEnabled: Boolean;
  end;

  TQuadMemo = class(TCustomControl)
  private
    FServiceBarWidth: Integer;
    FCharHeight: Integer;
    FCharWidth: Integer;
    Flines: TStringList;
    FCaretPos: TPoint;
    FCameraPos: TPoint;
    FSelection: TSelection;
    FMouseCoord: TPoint;
    FIsChanged: Boolean;
    FIsVerticalScroll: Boolean;
    FIsHorizontalScroll: Boolean;
    FParser: Tparser;
    FAutoComplete: String;
    FAutoCompleteStart: Integer;
    FTokenAtCursor: PToken;
    FBackBuffer: TBitmap;
    FColors: TQuadMemoColors;
    FOptions: TQuadMemoOptions;
    FReadOnly: Boolean;
    FErrorLine: Integer;
//    FBookMarks: Array[0..9] of TBookMark;
    procedure ClearSelection;
    procedure CorrectCaretPos;
    function GetCorrectedSelection : TSelection;
    procedure DeleteText;
    procedure DrawBackGround;
    procedure DrawSelection;
    procedure DrawScrollBars;
    procedure DrawText;
    procedure DrawServiceBar;
    Procedure DrawHints;
    procedure CopySelection(AIsCut: Boolean = False);
    procedure InitMemoColors;
    function GetCurrentChar: Integer;
    function GetCurrentLine: Integer;
    function GetIsSelected: Boolean;
  protected
    procedure Paint; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMCut(var Message: TWMCut); message WM_CUT;

  public
    constructor Create(AOwner: TComponent); override;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure InsertText(AText: String);
    procedure Save;
    procedure TextPaste;
    procedure TextCut;
    procedure TextCopy;
    procedure Clear;
    procedure SetErrorWarning(AErrorLine, AErrorChar: Integer);
    procedure LoadFromFile(const AFileName: String);

    property CurrentLine: Integer read GetCurrentLine;
    property CurrentChar: Integer read GetCurrentChar;
    property IsChanged: Boolean read FIsChanged;
    property IsSelected: Boolean read GetIsSelected;
    property CorrectedSelection: TSelection read GetCorrectedSelection;
  published
    property Lines: TStringList read Flines write Flines;
    property Colors: TQuadMemoColors read FColors write FColors;
    property Options: TQuadMemoOptions read FOptions write FOptions;
    property Align;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

implementation

uses DateUtils, Math, ClipBrd;

{ TQuadMemo }

procedure TQuadMemo.AfterConstruction;
begin
  inherited;
  FParser.Source := Flines.Text;

  DoubleBuffered := True;

  FBackBuffer := TBitmap.Create;
  FBackBuffer.PixelFormat := pf24bit;
  FBackBuffer.Canvas.Font.Name := 'Consolas';
  FBackBuffer.Canvas.Font.Size := 11;
  FServiceBarWidth := 48;

  FOptions.IsTextShadowed := True;
  FOptions.IsServicebarShadowed := True;
  FOptions.IsSelectedLineHighlight := True;
  FOptions.IsRightMagin := True;
  FOptions.IsHighlightVar := True;
  FOptions.IsSelectedLineShadowed := True;
  FOptions.IsCodeAssist := True;
  FOptions.IsKeywordsBold := False;
  FOptions.HintAfter := 2;
  FOptions.TabSpacesCount := 2;

  InitMemoColors;

  Parent := TWinControl(Owner);

  FCharHeight := FBackBuffer.Canvas.TextHeight(' ');
  FCharWidth := FBackBuffer.Canvas.TextWidth(' ');

  FCameraPos.X := 0;
  FCameraPos.Y := 0;

  CreateCaret(Self.Handle, 0, 1, FCharHeight);
  ShowCaret(Self.Handle);
  SetCaretPos(FServiceBarWidth, 0);
  CorrectCaretPos;

  Clear;  
end;

procedure TQuadMemo.BeforeDestruction;
begin
  Flines.Free;
  FBackBuffer.Free;

  inherited;
end;

procedure TQuadMemo.ClearSelection;
begin
  FSelection.StartPos.X := CurrentChar;
  FSelection.StartPos.Y := CurrentLine;
  FSelection.EndPos.X := CurrentChar;
  FSelection.EndPos.Y := CurrentLine;
  FAutoComplete := '';
end;

procedure TQuadMemo.CopySelection(AIsCut: Boolean);
var
  i: Integer;
  S: String;
begin
  if Not IsSelected then        
    Exit;

  if CorrectedSelection.EndPos.Y = CorrectedSelection.StartPos.Y then
    S := Copy(Flines[CorrectedSelection.StartPos.Y], CorrectedSelection.StartPos.X + 1, CorrectedSelection.EndPos.X - CorrectedSelection.StartPos.X)
  else
  begin             
    S := Copy(Flines[CorrectedSelection.StartPos.Y], CorrectedSelection.StartPos.X + 1, Length(Flines[CorrectedSelection.StartPos.Y]) - CorrectedSelection.StartPos.X) + #13#10;
    for i := CorrectedSelection.StartPos.Y + 1 to CorrectedSelection.EndPos.Y - 1 do
      S := S + Flines[i] + #13#10;
    S := S + Copy(Flines[CorrectedSelection.EndPos.Y], 0, CorrectedSelection.EndPos.X);
  end;

  Clipboard.AsText := S;

  if AIsCut then
    InsertText('');
end;

procedure TQuadMemo.CorrectCaretPos;
begin
  // x
  if FCaretPos.X < FServiceBarWidth then
  begin
    FCameraPos.X := Min(0, FCameraPos.X - (FCaretPos.X - FServiceBarWidth) div FCharWidth);
    FCaretPos.X := FServiceBarWidth;
  end;

  if FCaretPos.X > Width then
  begin
    FCameraPos.X := FCameraPos.X + (Width - FCaretPos.X) div FCharWidth - 1;
    FCaretPos.X := Width div FCharWidth * FCharWidth;
  end;

  // y
  if FCaretPos.Y < 0 then
  begin
    FCameraPos.Y := Min(0, FCameraPos.Y - FCaretPos.Y div FCharHeight);
    FCaretPos.Y := 0;
  end;

  if FCaretPos.Y > (Height - FCharHeight) then
  begin
    FCameraPos.Y := FCameraPos.Y + (Height - FCaretPos.Y) div FCharHeight - 1;
    FCaretPos.Y := (Height div FCharHeight - 1) * FCharHeight;
  end;

  // out of bounds
  if (FCaretPos.Y div FCharHeight - FCameraPos.Y) >= Flines.Count then
    FCaretPos.Y := (Flines.Count - 1 + FCameraPos.Y) * FCharHeight;

  if FCameraPos.Y > 0 then
    FCameraPos.Y := 0;

  if FCameraPos.Y + Flines.Count < 0 then
    FCameraPos.Y := -Flines.Count + 1;

  // refresh
  SetCaretPos(FCaretPos.X, FCaretPos.Y);
  Invalidate;
end;

function TQuadMemo.GetCorrectedSelection: TSelection;
begin
  if (FSelection.EndPos.Y < FSelection.StartPos.Y) or (FSelection.EndPos.X < FSelection.StartPos.X) then
  begin
    Result.StartPos := FSelection.EndPos;
    Result.EndPos := FSelection.StartPos;
  end
  else
    Result := FSelection;
end;

procedure TQuadMemo.DeleteText;
var
  i: Integer;
begin
  if CorrectedSelection.EndPos.Y > CorrectedSelection.StartPos.Y then
  begin
    Flines[CorrectedSelection.StartPos.Y] := Copy(Flines[CorrectedSelection.StartPos.Y], 0, CorrectedSelection.StartPos.X) +
      Copy(Flines[CorrectedSelection.EndPos.Y], CorrectedSelection.EndPos.X + 1, Length(Flines[CorrectedSelection.EndPos.Y]) - CorrectedSelection.EndPos.X);
  end;

  for i := CorrectedSelection.EndPos.Y downto CorrectedSelection.StartPos.Y + 1 do
    Flines.Delete(i);

  FCaretPos.Y := (CorrectedSelection.StartPos.Y + FCameraPos.Y) * FCharHeight;
  FCaretPos.X := FServiceBarWidth + (CorrectedSelection.StartPos.X + FCameraPos.X) * FCharWidth;
end;

procedure TQuadMemo.DrawBackGround;
begin
  with FBackBuffer.Canvas do
  begin
    Brush.Color := FColors.BackGround;
    FillRect(Rect(0, 0, Self.Width, Self.Height));


    if FErrorLine > 0 then
    begin
      Brush.Color := FColors.ErrorLine;
      Pen.Style := psClear;
      Rectangle(0, (FErrorLine + FCameraPos.Y) * FCharHeight, Width + 1, (FErrorLine + FCameraPos.Y + 1) * FCharHeight);
    end else
    if FOptions.IsSelectedLineHighlight {and not IsSelected }then
    begin
      Brush.Color := FColors.SelectedLine;
      FillRect(Rect(0, FCameraPos.Y * FCharHeight + CurrentLine * FCharHeight, Self.Width, FCameraPos.Y * FCharHeight + CurrentLine * FCharHeight + FCharHeight));
    end;

    if FOptions.IsRightMagin then
    begin
      brush.Style := bsClear;
      Pen.Color := FColors.RightMargin;
      Pen.Style := psDot;
      MoveTo(FServiceBarWidth + FCharWidth * (80 + FCameraPos.X), 0);
      LineTo(FServiceBarWidth + FCharWidth * (80 + FCameraPos.X), Height);
    end;
  end;
end;

procedure TQuadMemo.DrawHints;
var
  i: Integer;
  sl: TStringList;
  P: Integer;
begin
 with FBackBuffer.Canvas do
  begin
    // hint
    sl := TStringList.Create;
    sl.Text := FAutoComplete;

    if sl.Count > 0 then
    begin
      Brush.Color := FColors.Hint;
      FillRect(Rect(FServiceBarWidth + (FAutoCompleteStart - 1 + FCameraPos.X) * FCharWidth,
                    (CurrentLine + 1 + FCameraPos.Y) * FCharHeight,
                    FServiceBarWidth + (FAutoCompleteStart + 1 + FCameraPos.X) * FCharWidth + 128,
                    (CurrentLine + 2 + sl.Count + FCameraPos.Y) * FCharHeight));
      for i := 0 to sl.Count - 1 do
      begin
        Font.Color := clSilver;
        TextOut(FServiceBarWidth + (FAutoCompleteStart + FCameraPos.X) * FCharWidth, Trunc((CurrentLine + 1.5 + i + FCameraPos.Y) * FCharHeight), sl.Strings[i]);
        if FTokenAtCursor <> nil then
        begin
          p := Pos(FTokenAtCursor.TText, sl.Strings[i]);
          Font.Color := FColors.Active;
          TextOut(FServiceBarWidth + (FAutoCompleteStart + FCameraPos.X + p - 1) * FCharWidth, Trunc((CurrentLine + 1.5 + i + FCameraPos.Y) * FCharHeight), FTokenAtCursor.TText);
        end;
      end;
    end;
    sl.Free;
  end;
end;

procedure TQuadMemo.DrawScrollBars;
begin
  if Flines.Count > 0 then
  with FBackBuffer.Canvas do
  begin
    // vscroll
    Brush.Color := Fcolors.ScrollBars;

    if (FMouseCoord.X < (Width - 16)) then
      FillRect(Rect(Width - 6, Trunc((-FCameraPos.Y) / Flines.Count * Height) - 50,
                    Width, Trunc((-FCameraPos.Y) / Flines.Count * Height) + 50));

    if (FMouseCoord.X > (Width - 160)) then
      FillRect(Rect(Width - 6 - (10 - (Width - FMouseCoord.X) div 10 ), Trunc((-FCameraPos.Y) / Flines.Count * Height) - 50 ,
                    Width, Trunc((-FCameraPos.Y) / Flines.Count * Height) + 50));

    // hscroll
    if (FMouseCoord.Y < (Height - 16)) then
      FillRect(Rect(Trunc((-FCameraPos.X) / 256 * Width) - 50 + FServiceBarWidth, Height - 6,
                    Trunc((-FCameraPos.X) / 256 * Width) + 50 + FServiceBarWidth, Height));

    if (FMouseCoord.Y > (Height - 160)) then
      FillRect(Rect(Trunc((-FCameraPos.X) / 256 * Width) - 50 + FServiceBarWidth, Height - 6 - (10 - (Height - FMouseCoord.Y) div 10 ),
                    Trunc((-FCameraPos.X) / 256 * Width) + 50 + FServiceBarWidth, Height));
  end;
end;

procedure TQuadMemo.DrawSelection;
var
  i, j: Integer;
  p: PByteArray;
begin
  with FBackBuffer.Canvas do
  begin
    // selection
    if CorrectedSelection.StartPos.Y = CorrectedSelection.EndPos.Y then
    begin
      Brush.Color := FColors.Selection;
      FillRect(Rect(FServiceBarWidth + (FCameraPos.X + CorrectedSelection.StartPos.X) * FCharWidth,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.StartPos.Y * FCharHeight,
                    FServiceBarWidth + (FCameraPos.X + CorrectedSelection.EndPos.X) * FCharWidth,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.EndPos.Y * FCharHeight + FCharHeight));
    end else
    begin
      Brush.Color := FColors.Selection;
      FillRect(Rect(FServiceBarWidth + (FCameraPos.X + CorrectedSelection.StartPos.X) * FCharWidth,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.StartPos.Y * FCharHeight,
                    Self.Width,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.StartPos.Y * FCharHeight + FCharHeight));
      FillRect(Rect(FServiceBarWidth,
                    (FCameraPos.Y + CorrectedSelection.StartPos.Y + 1) * FCharHeight,
                    Self.Width,
                    (FCameraPos.Y + CorrectedSelection.EndPos.Y) * FCharHeight));
      FillRect(Rect(FServiceBarWidth,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.EndPos.Y * FCharHeight,
                    FServiceBarWidth + (FCameraPos.X + CorrectedSelection.EndPos.X) * FCharWidth,
                    FCameraPos.Y * FCharHeight + CorrectedSelection.EndPos.Y * FCharHeight + FCharHeight));
    end;

    if FOptions.IsSelectedLineShadowed then
    begin
      for i := 0 to 3 do
      begin
        if (i + (FCameraPos.Y + CurrentLine) * FCharHeight) < Height then
        begin
          P := FBackBuffer.ScanLine[Max(0, i + (FCameraPos.Y + CurrentLine) * FCharHeight)];
          for j := FServiceBarWidth - 5 to Width - 1 do
          begin
            P[j*3] := Trunc(P[j * 3] * (1 - (3 - i) / 10));
            P[j*3+1] := Trunc(P[j * 3 + 1] * (1 - (3 - i) / 10));
            P[j*3+2] := Trunc(P[j * 3 + 2] * (1 - (3 - i) / 10));
          end;
        end;
      end;
    end;

  end;
end;

procedure TQuadMemo.DrawServiceBar;
var
  i, j: Integer;
  P: PByteArray;
begin
  with FBackBuffer.Canvas do
  begin
    // servicebar
    Brush.Color := FColors.ServiceBar;
    FillRect(Rect(0, 0, FServiceBarWidth-3, Self.Height));

    if not FOptions.IsServicebarShadowed then
    begin
      Brush.Color := $00303030;
      FillRect(Rect(FServiceBarWidth - 3, 0, FServiceBarWidth, Self.Height));
    end;

    for i := -FCameraPos.Y to -FCameraPos.Y + Height div FCharHeight do
    if i < Flines.Count then
    begin
      if Flines.Objects[i] = TObject(1) then
      begin
        Brush.Color := FColors.TextChanged;
        FillRect(Rect(FServiceBarWidth - 3, (FCameraPos.Y + i) * FCharHeight, FServiceBarWidth, (FCameraPos.Y + i + 1) * FCharHeight));
      end;

      if Flines.Objects[i] = TObject(2) then
      begin
        Brush.Color := FColors.TextSaved;
        FillRect(Rect(FServiceBarWidth - 3, (FCameraPos.Y + i) * FCharHeight, FServiceBarWidth, (FCameraPos.Y + i + 1) * FCharHeight));
      end;


      if i = CurrentLine then
        Font.Color := FColors.Active
      else
        Font.Color := FColors.TextNormal;

      Brush.Style := bsClear;
      if (i mod 10 = 0) or (i = CurrentLine) then
        TextOut(FServiceBarWidth - TextWidth(IntToStr(i)) - FCharWidth, (FCameraPos.Y + i) * FCharHeight, IntToStr(i))
      else
        if i mod 5 = 0 then
          TextOut(FServiceBarWidth - FCharWidth * 2, (FCameraPos.Y + i) * FCharHeight, '-')
        else
          TextOut(FServiceBarWidth - FCharWidth * 2, (FCameraPos.Y + i) * FCharHeight, '·');
    end;

    if FOptions.IsServicebarShadowed then
    for i := 0 to Height - 1 do
    begin
      P := FBackBuffer.ScanLine[i];
      for j := 0 to 4 do
      begin
        P[(FServiceBarWidth - j) * 3 + 0] := Trunc(P[(FServiceBarWidth - j) * 3 + 0] * (1 - j / 7));
        P[(FServiceBarWidth - j) * 3 + 1] := Trunc(P[(FServiceBarWidth - j) * 3 + 1] * (1 - j / 7));
        P[(FServiceBarWidth - j) * 3 + 2] := Trunc(P[(FServiceBarWidth - j) * 3 + 2] * (1 - j / 7));
      end;
    end;

    if FOptions.IsSelectedLineShadowed then
    begin
      for i := 0 to 6 - 1 do
      begin
        P := FBackBuffer.ScanLine[i];
        for j := 0 to Width - 1 do
        begin
     {     P[j * 3 + 0] := Trunc(P[j * 3 + 0] * (1 - (6 - i)/6));
          P[j * 3 + 1] := Trunc(P[j * 3 + 1] * (1 - (6 - i)/6));
          P[j * 3 + 2] := Trunc(P[j * 3 + 2] * (1 - (6 - i)/6));
             }
          P[j * 3 + 0] := Trunc(P[j * 3 + 0] * (1 - (6 - i) / 9 * (1 - abs(Width / 2 - j) / Width)));
          P[j * 3 + 1] := Trunc(P[j * 3 + 1] * (1 - (6 - i) / 9 * (1 - abs(Width / 2 - j) / Width)));
          P[j * 3 + 2] := Trunc(P[j * 3 + 2] * (1 - (6 - i) / 9 * (1 - abs(Width / 2 - j) / Width)));
        end;
      end;      
    end;
  end;
end;

procedure TQuadMemo.DrawText;
var
  i, j: Integer;
begin
 with FBackBuffer.Canvas do
  begin
    for i := -FCameraPos.Y to -FCameraPos.Y + Height div FCharHeight do
    if i < Flines.Count then
    begin
      for j := 0 to FParser.tokens.Count - 1 do
      begin
        if FParser.TokenItems[j].TLine = Cardinal(i) then
        if (FParser.TokenItems[j].TText <> #10) and (FParser.TokenItems[j].TText <> #13) then
        begin
          Brush.Style := bsClear;

          if FOptions.IsTextShadowed and (i <> CurrentLine) then
          begin
            font.Color := RGB(Trunc(GetRValue(FColors.BackGround) * 0.90), Trunc(GetGValue(FColors.BackGround)*0.90), Trunc(GetBValue(FColors.BackGround) * 0.90));
            TextOut(FServiceBarWidth + (FParser.TokenItems[j].TLineChar + FCameraPos.X) * FCharWidth, (i + FCameraPos.Y) * FCharHeight + 3, FParser.TokenItems[j].TText);
            font.Color := RGB(Trunc(GetRValue(FColors.BackGround) * 0.80), Trunc(GetGValue(FColors.BackGround)*0.80), Trunc(GetBValue(FColors.BackGround) * 0.80));
            TextOut(FServiceBarWidth + (FParser.TokenItems[j].TLineChar + FCameraPos.X) * FCharWidth, (i + FCameraPos.Y) * FCharHeight + 2, FParser.TokenItems[j].TText);
            font.Color := RGB(Trunc(GetRValue(FColors.BackGround) * 0.70), Trunc(GetGValue(FColors.BackGround)*0.70), Trunc(GetBValue(FColors.BackGround) * 0.70));
            TextOut(FServiceBarWidth + (FParser.TokenItems[j].TLineChar + FCameraPos.X) * FCharWidth, (i + FCameraPos.Y) * FCharHeight + 1, FParser.TokenItems[j].TText);
          end;

          case FParser.TokenItems[j].TType of
            ttReserved : begin
                           font.Color := FColors.TextReserved;
                           if FOptions.IsKeywordsBold then
                             font.Style := [fsBold];
                         end;
            ttComments : begin
                           font.Color := FColors.TextComments;
                           font.Style := [fsItalic];
                         end;
            ttFunction : begin
                           font.Color := FColors.TextFunction;
                         end;
            ttString : begin
                           font.Color := FColors.TextString;
                         end;
            ttConstant : begin
                           font.Color := FColors.TextConstant;
                         end;
            ttDevider : begin
                           font.Color := FColors.TextDevider;
                         end;
            ttDefine : begin
                           font.Color := FColors.TextDefine;
                         end;
            else
            begin
              font.Color := FColors.TextNormal;
              font.Style := [];
            end;
          end;

          if FOptions.IsHighlightVar and (not IsSelected) then
          begin
            if FTokenAtCursor <> nil then
              if FTokenAtCursor.TText = FParser.TokenItems[j].TText then
                Brush.Color := FColors.TextHighlight
              else
                Brush.Style := bsClear;
          end;

          if fParser.TokenItems[j].TText <> #9 then
            TextOut(FServiceBarWidth + (FParser.TokenItems[j].TLineChar + FCameraPos.X) * FCharWidth, (i + FCameraPos.Y) * FCharHeight, FParser.TokenItems[j].TText);
        end;
      end;
    end;
  end;
end;

function TQuadMemo.GetCurrentChar: Integer;
begin
  Result := (FCaretPos.X - FServiceBarWidth) div FCharWidth - FCameraPos.X;
end;

function TQuadMemo.GetCurrentLine: Integer;
begin
  Result := FCaretPos.Y div FCharHeight - FCameraPos.Y;
end;

function TQuadMemo.GetIsSelected: Boolean;
begin
  Result := not ((FSelection.StartPos.X = FSelection.EndPos.X) and (FSelection.StartPos.Y = FSelection.EndPos.Y));
end;

procedure TQuadMemo.InitMemoColors;
begin
  FColors.BackGround := $00414141;
  FColors.SelectedLine := $00353535;
  FColors.ErrorLine := $00002288;
  FColors.Selection := $00505040;
  FColors.Hint := $00413100;
  FColors.ServiceBar := $00353535;
  FColors.ScrollBars := $000080FF;
  FColors.Active := $000080FF;
  FColors.TextChanged := $000080FF;
  FColors.TextSaved := $0001C57B;
  FColors.TextHighlight := $00222222;
  FColors.RightMargin := $00808080;

  FColors.TextNormal := $00C0C0C0;
  FColors.TextReserved := $00FFFFFF;
  FColors.TextComments := $0001C57B;
  FColors.TextFunction := $00ECB87D;
  FColors.TextString := $00C6B08C;
  FColors.TextConstant := $000080FF;
  FColors.TextDevider := $0053A9FF;
  FColors.TextDefine := $00879159;


  // white scheme
 { FColors.BackGround := clWhite;
  FColors.SelectedLine := clSkyBlue;
  FColors.Selection := clSkyBlue;
  FColors.Hint := clSilver;
  FColors.ServiceBar := clBtnFace;
  FColors.ScrollBars := clGray;
  FColors.Active := clRed;
  FColors.TextChanged := clYellow;
  FColors.TextSaved := clLime;
  FColors.TextHighlight := clSilver;
  FColors.RightMargin := clSilver;

  FColors.TextNormal := clBlack;
  FColors.TextReserved := clBlack;
  FColors.TextComments := clGreen;
  FColors.TextFunction := clBlack;
  FColors.TextString := clNavy;
  FColors.TextConstant := clNavy;
  FColors.TextDevider := clBlack;
  FColors.TextDefine := clBlack;

  FOptions.IsTextShadowed:= False;
  FOptions.IsSelectedLineShadowed:= False;
  FOptions.IsServicebarShadowed:= False;  }
end;

procedure TQuadMemo.InsertText(AText: String);
var
  S: String;
  SL: TStringList;
  i: Integer;
  DeltaX: Integer;
  Token: PToken;
  CaretDelta: Smallint;
begin
  if FReadOnly then
    Exit;

  FIsChanged := True;

  DeleteText;
  CaretDelta := Pos('|', AText);
  if CaretDelta > 0 then
  begin
    CaretDelta := Length(AText) - CaretDelta;  
    AText := AnsiReplaceStr(AText, '|', '');
  end;

  SL := TStringList.Create;
  SL.Text := AText;
  if SL.Text <> '' then
    DeltaX := Length(SL[SL.Count - 1])
  else
    DeltaX := Length(AText);

  S := Flines[CurrentLine];
  if Length(S) < CurrentChar then
    S := S + StringOfChar(' ', CurrentChar - Length(S));

  if CorrectedSelection.StartPos.Y = CorrectedSelection.EndPos.Y then
    S := Copy(S, 0, CorrectedSelection.StartPos.X) + AText + Copy(S, CorrectedSelection.EndPos.X + 1, Length(S) - CorrectedSelection.EndPos.X)
  else
    S := Copy(S, 0, CorrectedSelection.StartPos.X) + AText + Copy(S, CorrectedSelection.StartPos.X + 1, Length(S) - CorrectedSelection.StartPos.X);

  SL.Text := S;

  Flines.Delete(CurrentLine);
  for i := 0 to SL.Count - 1 do
  begin
    Flines.Insert(CurrentLine + i, SL[i]);
    Flines.Objects[CurrentLine + i] := TObject(1);
  end;

  // caret correction
  if SL.Count > 1 then
    FCaretPos.X := FServiceBarWidth + FCharWidth * DeltaX
  else
    FCaretPos.X := FCaretPos.X + FCharWidth * (DeltaX - CaretDelta);
  FCaretPos.Y := FCaretPos.Y + FCharHeight * (SL.Count - 1);

  SL.Free;

  CorrectCaretPos;
  ClearSelection;

  FParser.Source := Flines.Text;

  Token := FParser.GetTokenAtPos(CurrentLine, CurrentChar);
  if (Token <> nil) and (Token.TLength >= FOptions.HintAfter) then
  begin
    FAutoComplete := FParser.GetPossibleTokens(Token.TText);
    FAutoCompleteStart := CurrentChar - Token.TLength;
  end;
end;

procedure TQuadMemo.KeyDown(var Key: Word; Shift: TShiftState);
var
  Caret: TPoint;
  cd: TColorDialog;
  DecimalChar: Char;

begin
  inherited;
  GetCaretPos(Caret);
  FCaretPos := Caret;

  if FErrorLine > 0 then
    FErrorLine := -1;

  case Key of
    VK_DOWN:
      begin
        if ssctrl in Shift then
          FCameraPos.Y := FCameraPos.Y - 1
        else
        FCaretPos.Y := FCaretPos.Y + FCharHeight;

        if ssshift in Shift then
          FSelection.EndPos.Y := FSelection.EndPos.Y + 1
        else
          ClearSelection;
      end;
    VK_UP:
      begin
        if ssctrl in Shift then
          FCameraPos.Y := FCameraPos.Y + 1
        else
        FCaretPos.Y := FCaretPos.Y - FCharHeight;

        if ssshift in Shift then
          FSelection.EndPos.Y := FSelection.EndPos.Y - 1
        else
          ClearSelection;
      end;
    VK_LEFT:
      begin
        FCaretPos.X := FCaretPos.X - FCharWidth;
        if ssshift in Shift then
          FSelection.EndPos.X := FSelection.EndPos.X - 1
        else
          ClearSelection;
      end;
    VK_RIGHT:
      begin
        FCaretPos.X := FCaretPos.X + FCharWidth;
        if ssshift in Shift then
          FSelection.EndPos.X := FSelection.EndPos.X + 1
        else
          ClearSelection;
      end;
    VK_HOME:
      begin
        FCaretPos.X := FServiceBarWidth;
        FCameraPos.X := 0;
        if ssshift in Shift then
          FSelection.EndPos.X := 0
        else
          ClearSelection;

        if ssCtrl in Shift then
        begin
          FCaretPos.Y := 0;
          FCameraPos.Y := 0;
        end;
      end;
    VK_END:
      begin
        FCaretPos.X := FServiceBarWidth + Length(Flines[CurrentLine]) * FCharWidth + FCameraPos.X*FCharWidth;
        if ssshift in Shift then
          FSelection.EndPos.X := Length(Flines[CurrentLine])
        else
          ClearSelection;

        if ssCtrl in Shift then
        begin
          FCaretPos.Y := height;
          FCameraPos.Y := - Flines.Count + height div 2 div FCharHeight;
        end;
      end;
    VK_NEXT: FCaretPos.Y := FCaretPos.Y + (Height div FCharHeight - 1) * FCharHeight;
    VK_PRIOR: FCaretPos.Y := FCaretPos.Y - (Height div FCharHeight - 1) * FCharHeight;
    VK_F1: Save;
    VK_ESCAPE: FAutoComplete := '';
    VK_BACK:
      begin
        if not IsSelected then
        begin
          ClearSelection;

          if CurrentChar = 0 then
          begin
            FSelection.EndPos.Y := FSelection.StartPos.Y;
            FSelection.EndPos.X := 0;
            FSelection.StartPos.Y := FSelection.StartPos.Y - 1;
            FSelection.StartPos.X := Length(Flines[FSelection.StartPos.Y]);
          end
          else
          FSelection.StartPos.X := CurrentChar - 1;
        end;
        FCaretPos.X := FCaretPos.X - FCharWidth * (FSelection.EndPos.X - FSelection.StartPos.X);

        InsertText('');
      end;
    VK_DELETE:
      begin
        if not IsSelected then
        begin
          ClearSelection;
          FSelection.EndPos.X := CurrentChar + 1;
        end;
        InsertText('');
      end;
    VK_RETURN:
      begin
        if not IsSelected then
        begin
          ClearSelection;
        end;
        if Length(Flines[CurrentLine]) > CurrentChar then
          InsertText(#13#10)
        else
        begin // for thruth this is the bad code
          InsertText(#13#10' ');
          Flines[CurrentLine] := TrimRight(Flines[CurrentLine]);
          FCaretPos.X := 0;

          if (CurrentLine > 0) and (Length(Flines[CurrentLine - 1]) > 0) then
            InsertText(StringOfChar(' ', Length(Flines[CurrentLine - 1]) - Length(TrimLeft(Flines[CurrentLine - 1])) - 1));
        end;
      end;
    VK_TAB:
      begin
        if not IsSelected then
        begin
          ClearSelection;
        end;
        InsertText(StringOfChar(' ', FOptions.TabSpacesCount - ((FCaretPos.X - FServiceBarWidth) div FCharWidth) mod (FOptions.TabSpacesCount)));
      end;
    Ord('Q'): if ssCtrl in Shift then
      begin
        cd := TColorDialog.Create(Self);
        cd.Options := [cdFullOpen];

        {$IF CompilerVersion >= 22}
        DecimalChar := FormatSettings.DecimalSeparator;
        FormatSettings.DecimalSeparator := '.';
        {$ELSE}
        DecimalChar := DecimalSeparator;
        DecimalSeparator := '.';
        {$IFEND}
        if cd.Execute then
          InsertText(Format('(%f, %f, %f, 1.0)', [GetRValue(cd.Color) / 255, GetGValue(cd.Color) / 255, GetBValue(cd.Color) / 255]));

        {$IF CompilerVersion >= 22}
        FormatSettings.DecimalSeparator := DecimalChar;
        {$ELSE}
        DecimalSeparator := DecimalChar;
        {$IFEND}
      end;
{    Ord('V'): if ssCtrl in Shift then InsertText(Clipboard.AsText);
    Ord('X'): if ssCtrl in Shift then CopySelection(True);
    Ord('C'): if ssCtrl in Shift then CopySelection;}
  end;

  CorrectCaretPos;
end;

procedure TQuadMemo.KeyPress(var Key: Char);
var
  AText: String;
begin
  inherited;
{  if Key = '`' then
  begin
    SetErrorWarning(70, 15);
    Exit;
  end;
 }

  if Key > #31 then
  begin
    if not IsSelected then
      ClearSelection;

    AText := Key;

    if FOptions.IsCodeAssist then
    begin
      if Key = '{' then
        AText := AText + '|}';

      if Key = '(' then
        AText := AText + '|)';

      if Key = '[' then
        AText := AText + '|]';

      if Key = ',' then
        AText := AText + ' |';
    end;

    InsertText(AText);
  end;
  Key := #0;
end;

procedure TQuadMemo.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

end;

procedure TQuadMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if FErrorLine > 0 then
    FErrorLine := -1;

  if (FMouseCoord.X > (Width - 16)) then
  begin
    FIsVerticalScroll := True;
    Exit;
  end;

  if (FMouseCoord.Y > (Height - 16)) then
  begin
    FIsHorizontalScroll := True;
    Exit;
  end;

  if (FMouseCoord.X < FServiceBarWidth) then
    Exit;

  FCaretPos.Y := FMouseCoord.Y div FCharHeight * FCharHeight;
  FCaretPos.X := FServiceBarWidth + Round((FMouseCoord.X - FServiceBarWidth) / FCharWidth) * FCharWidth;
  CorrectCaretPos;

  if Button = mbLeft then
  begin
    ClearSelection;
  end;
end;

procedure TQuadMemo.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FMouseCoord.X := X;
  FMouseCoord.Y := Y;

  if (FMouseCoord.X < FServiceBarWidth) then
  begin
    Cursor := crArrow;
    Exit;
  end;

  if (FMouseCoord.X > Width - 16) then
    Cursor := crVSplit
  else
    if (FMouseCoord.Y > Height - 16) then
      Cursor := crHSplit
    else
      Cursor := crIBeam;

  //scroll
  if FIsVerticalScroll then
  begin
    if (FMouseCoord.Y > 0) and (FMouseCoord.Y < Height) then
      FCameraPos.Y := -Trunc(FMouseCoord.Y / Height * Flines.Count);
  end
  else
  if FIsHorizontalScroll then
  begin
    if (FMouseCoord.X > FServiceBarWidth) and (FMouseCoord.X < Width) then
      FCameraPos.X := -Trunc((FMouseCoord.X - FServiceBarWidth) / Width * 256);
  end
  else
  if ssLeft in Shift then
  begin
    FCaretPos.Y := Y div FCharHeight * FCharHeight;
    FCaretPos.X := FServiceBarWidth + (X - FServiceBarWidth) div FCharWidth * FCharWidth;
    CorrectCaretPos;

    FSelection.EndPos.X := CurrentChar;
    FSelection.EndPos.Y := CurrentLine;
  end;

  Invalidate;
end;

procedure TQuadMemo.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FIsVerticalScroll := False;
  FIsHorizontalScroll := False;  
end;

procedure TQuadMemo.Paint;
begin
//  inherited;

  FBackBuffer.Width := Width;
  FBackBuffer.Height := Height;

  FTokenAtCursor := FParser.GetTokenAtPos(CurrentLine, CurrentChar);

  with FBackBuffer.Canvas do
  begin
    Lock;
    try
      DrawBackGround;
      DrawSelection;
      DrawText;
      DrawScrollBars;
      DrawServiceBar;
      DrawHints;
    finally
      Unlock;
    end;
  end;
  BitBlt(Canvas.Handle, 0, 0, Width, Height, FBackBuffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TQuadMemo.Save;
var
  i: Integer;
begin
  for i := 0 to Flines.Count - 1 do
    if Flines.Objects[i] = TObject(1) then
      Flines.Objects[i] := TObject(2);
end;

procedure TQuadMemo.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  // trick to get Tab, arrow and other keys in msg
  Message.Result := Message.Result or
    DLGC_WANTCHARS or DLGC_WANTARROWS or DLGC_WANTTAB or DLGC_WANTALLKEYS or DLGC_WANTMESSAGE;
end;

procedure TQuadMemo.WMMouseWheel(var Message: TWMMouseWheel);
begin
  FCameraPos.Y := FCameraPos.Y + Message.WheelDelta div FCharHeight;
  CorrectCaretPos;
  FAutoComplete := '';
end;

procedure TQuadMemo.WMKillFocus(var Message: TWMKillFocus);
begin
  HideCaret(Self.Handle);
  Message.Result := 0;
end;

procedure TQuadMemo.WMSetFocus(var Message: TWMSetFocus);
begin
  CreateCaret(Self.Handle, 0, 1, FCharHeight);
  ShowCaret(Self.Handle);
  SetCaretPos(FCaretPos.X, FCaretPos.Y);
  Message.Result := 0;
end;

procedure TQuadMemo.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // trick to get WMSETFOCUS and WMKILLFOCUS messages
  CreateSubClass(Params, 'EDIT');
end;

procedure TQuadMemo.WMPaste(var Message: TWMPaste);
begin
  TextPaste;
  Message.Result := 0;
end;

procedure TQuadMemo.WMCopy(var Message: TWMCopy);
begin
  TextCopy;
  Message.Result := 0;
end;

procedure TQuadMemo.WMCut(var Message: TWMCut);
begin
  TextCut;
  Message.Result := 0;
end;

procedure TQuadMemo.TextCopy;
begin
  CopySelection;
end;

procedure TQuadMemo.TextCut;
begin
  CopySelection(True);
end;

procedure TQuadMemo.TextPaste;
begin
  InsertText(Clipboard.AsText);
end;

procedure TQuadMemo.Clear;
begin
  Lines.Clear;
  Lines.Add('');
  InsertText(' ');
  Refresh;
end;

procedure TQuadMemo.SetErrorWarning(AErrorLine, AErrorChar: Integer);
begin
  FErrorLine := AErrorLine;
  FCameraPos.X := 0;
  FCameraPos.Y := -AErrorLine + 5;
  FCaretPos.Y := 5 * FCharHeight;
  FCaretPos.X := FServiceBarWidth + AErrorChar * FCharWidth;
  CorrectCaretPos;
end;

procedure TQuadMemo.LoadFromFile(const AFileName: String);
begin
  Flines.LoadFromFile(AFileName);
  Flines.Text := AnsiReplaceStr(Flines.Text, #9, ' ');
  FParser.Source := Flines.Text;
  FCaretPos.X := FServiceBarWidth;
  FCaretPos.Y := 0;
  FCameraPos.X := 0;
  FCameraPos.Y := 0;
  Invalidate;
end;

constructor TQuadMemo.Create(AOwner: TComponent);
begin
  inherited;
  Flines := TStringList.Create;
  FParser := Tparser.create;  
end;

end.

