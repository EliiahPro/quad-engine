object DialogForm: TDialogForm
  Left = 533
  Top = 373
  BorderStyle = bsNone
  Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1076#1080#1072#1083#1086#1075#1072
  ClientHeight = 214
  ClientWidth = 626
  Color = 3381759
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 1
    Top = 0
    Width = 625
    Height = 214
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 12
    ExplicitWidth = 629
    ExplicitHeight = 210
    DesignSize = (
      625
      214)
    object DialogCaption: TLabel
      Left = 20
      Top = 20
      Width = 127
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = 4473924
      Font.Height = -28
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object DialogText: TLabel
      Left = 22
      Top = 63
      Width = 591
      Height = 19
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 
        #1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' v '#1058#1077#1082#1089#1090' '#1058#1077 +
        #1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' v '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' v '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090'v  ' +
        #1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' v '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090' '#1058#1077#1082#1089#1090
      Color = 4473924
      Constraints.MaxWidth = 591
      Constraints.MinWidth = 480
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -17
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object ButtonCancel: TButton
      Left = 492
      Top = 162
      Width = 122
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Arial'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 439
      ExplicitTop = 158
    end
    object ButtonOk: TButton
      Left = 365
      Top = 162
      Width = 122
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1085#1103#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Arial'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 1
      ExplicitLeft = 304
      ExplicitTop = 158
    end
    object ButtonYes: TButton
      Left = 235
      Top = 162
      Width = 122
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1044#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Arial'
      Font.Style = []
      ModalResult = 6
      ParentFont = False
      TabOrder = 2
      Visible = False
      ExplicitLeft = 174
      ExplicitTop = 158
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1
    Height = 214
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
  end
end
