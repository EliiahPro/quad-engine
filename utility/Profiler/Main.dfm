object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'fMain'
  ClientHeight = 572
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 794
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 392
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
    end
  end
  object PanelGroup: TCategoryPanelGroup
    Left = 0
    Top = 33
    Width = 794
    Height = 447
    VertScrollBar.Tracking = True
    Align = alClient
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    TabOrder = 1
    ExplicitHeight = 458
  end
  object lvLog: TListView
    Left = 0
    Top = 480
    Width = 794
    Height = 92
    Align = alBottom
    Columns = <
      item
        Width = 20
      end
      item
        Caption = 'Time'
        Width = 70
      end
      item
        AutoSize = True
        Caption = 'Message'
      end
      item
        Caption = 'Profiler'
        Width = 100
      end
      item
        Caption = 'Tag'
        Width = 100
      end>
    ColumnClick = False
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnCreateItemClass = lvLogCreateItemClass
  end
  object Timer: TTimer
    Interval = 16
    OnTimer = TimerTimer
    Left = 344
    Top = 225
  end
end
