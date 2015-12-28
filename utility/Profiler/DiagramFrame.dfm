object fDiagramFrame: TfDiagramFrame
  Left = 0
  Top = 0
  Width = 596
  Height = 210
  Align = alClient
  TabOrder = 0
  object List: TListView
    Left = 0
    Top = 0
    Width = 177
    Height = 210
    Align = alLeft
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
  end
  object Panel: TPanel
    Left = 177
    Top = 0
    Width = 419
    Height = 210
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 137
    ExplicitWidth = 459
    object Scroll: TScrollBar
      Left = 0
      Top = 193
      Width = 419
      Height = 17
      Align = alBottom
      PageSize = 0
      TabOrder = 0
      ExplicitWidth = 459
    end
  end
end
