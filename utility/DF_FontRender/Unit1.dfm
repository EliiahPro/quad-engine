object Main: TMain
  Left = 225
  Top = 140
  Caption = 'Main'
  ClientHeight = 525
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RenderBox: TPaintBox
    Left = 6
    Top = 6
    Width = 512
    Height = 512
  end
  object PreRenderBox: TPaintBox
    Left = 524
    Top = 454
    Width = 64
    Height = 64
  end
  object cxLabel1: TLabel
    Left = 523
    Top = 92
    Width = 51
    Height = 13
    Caption = 'Characters'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object cxLabel2: TLabel
    Left = 524
    Top = 249
    Width = 41
    Height = 13
    Caption = 'Progress'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object RenderButton: TButton
    Left = 575
    Top = 326
    Width = 75
    Height = 27
    Caption = 'Render'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = RenderButtonClick
  end
  object RenderChars: TMemo
    Left = 524
    Top = 111
    Width = 201
    Height = 132
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'ABCDEFGHIJKLMNOPQRSTUVWX'
      'YZ01234567890`~!@#$%^&*()_+-'
      '=;:,.<>{}[]\|/?'
      'abcdefghijklmnopqrstuvwxyz'#1040#1041#1042#1043#1044
      #1045#1025#1046#1047#1048#1049#1050#1051#1052#1053#1054#1055#1056#1057#1058#1059#1060#1061#1062#1063#1064#1065
      #1066#1068#1067#1069#1070#1071#1072#1073#1074#1075#1076#1077#1105#1078#1079#1080#1081#1082#1083#1084#1085#1086#1087#1088#1089#1090
      #1091#1092#1093#1094#1095#1096#1097#1098#1100#1099#1101#1102#1103)
    ParentFont = False
    TabOrder = 1
  end
  object cxProgressBar1: TProgressBar
    Left = 520
    Top = 268
    Width = 205
    Height = 20
    TabOrder = 2
  end
  object FontNames: TComboBox
    Left = 524
    Top = 24
    Width = 201
    Height = 38
    Style = csOwnerDrawFixed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 32
    ParentFont = False
    TabOrder = 3
    OnDrawItem = FontNamesDrawItem
  end
  object IsVisialize: TCheckBox
    Left = 529
    Top = 294
    Width = 121
    Height = 17
    Caption = 'Visualize render'
    TabOrder = 4
  end
end
