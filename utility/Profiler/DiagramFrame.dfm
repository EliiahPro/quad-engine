object fDiagramFrame: TfDiagramFrame
  Left = 0
  Top = 0
  Width = 596
  Height = 210
  Align = alClient
  TabOrder = 0
  object Panel: TPanel
    Left = 169
    Top = 0
    Width = 427
    Height = 210
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 175
    ExplicitTop = -3
    object Scroll: TScrollBar
      Left = 0
      Top = 193
      Width = 427
      Height = 17
      Align = alBottom
      PageSize = 0
      TabOrder = 0
      ExplicitTop = 176
      ExplicitWidth = 419
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 0
    Width = 169
    Height = 210
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object List: TListView
      Left = 0
      Top = 0
      Width = 169
      Height = 188
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
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 0
      ViewStyle = vsReport
      OnCreateItemClass = ListCreateItemClass
      ExplicitLeft = 8
      ExplicitWidth = 177
      ExplicitHeight = 210
    end
    object tbScale: TTrackBar
      Left = 0
      Top = 188
      Width = 169
      Height = 22
      Align = alBottom
      Max = 100
      Position = 10
      TabOrder = 1
      TickMarks = tmBoth
      TickStyle = tsNone
      ExplicitLeft = -6
    end
  end
end
