object fDiagramFrame: TfDiagramFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 305
  Align = alClient
  TabOrder = 0
  object Panel: TPanel
    Left = 169
    Top = 0
    Width = 282
    Height = 305
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Scroll: TScrollBar
      Left = 0
      Top = 288
      Width = 282
      Height = 17
      Align = alBottom
      PageSize = 0
      TabOrder = 0
    end
  end
  object pLeft: TPanel
    Left = 0
    Top = 0
    Width = 169
    Height = 305
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object List: TListView
      Left = 0
      Top = 0
      Width = 169
      Height = 305
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
      OnItemChecked = ListItemChecked
    end
  end
end
