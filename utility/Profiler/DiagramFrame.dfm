object fDiagramForm: TfDiagramForm
  Left = 0
  Top = 0
  Width = 451
  Height = 300
  Align = alTop
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 193
    Width = 451
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 156
  end
  object Panel: TPanel
    Left = 169
    Top = 25
    Width = 282
    Height = 168
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Scroll: TScrollBar
      Left = 0
      Top = 151
      Width = 282
      Height = 17
      Align = alBottom
      PageSize = 0
      TabOrder = 0
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 25
    Width = 169
    Height = 168
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object List: TListView
      Left = 0
      Top = 0
      Width = 169
      Height = 168
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          AutoSize = True
          Caption = 'Name'
        end
        item
          Caption = 'Count'
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 0
      ViewStyle = vsReport
      OnCreateItemClass = ListCreateItemClass
      OnItemChecked = ListItemChecked
    end
  end
  object Log: TListView
    Left = 0
    Top = 196
    Width = 451
    Height = 104
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
        Caption = 'Tag'
        Width = 100
      end>
    ColumnClick = False
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnCreateItemClass = LogCreateItemClass
  end
  object Header: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 25
    Align = alTop
    TabOrder = 3
    object Caption: TLabel
      Left = 24
      Top = 6
      Width = 37
      Height = 13
      Caption = 'Caption'
    end
  end
  object TimerPaint: TTimer
    Enabled = False
    Interval = 16
    OnTimer = TimerPaintTimer
    Left = 185
    Top = 41
  end
end
