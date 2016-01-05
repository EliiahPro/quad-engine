inherited FrameTexture: TFrameTexture
  Width = 489
  Height = 493
  ExplicitWidth = 489
  ExplicitHeight = 493
  object lvList: TListView
    Left = 0
    Top = 60
    Width = 489
    Height = 433
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = 'Sprite'
        Width = 120
      end
      item
        Caption = 'Size'
        Width = 100
      end>
    LargeImages = dmIcomList.List
    MultiSelect = True
    RowSelect = True
    SmallImages = dmIcomList.List
    TabOrder = 0
    ViewStyle = vsReport
    OnDeletion = lvListDeletion
    OnEdited = lvListEdited
    OnInsert = lvListDeletion
    OnResize = lvListResize
    OnItemChecked = lvListItemChecked
    ExplicitTop = 62
  end
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 489
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      489
      60)
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 61
      Height = 19
      Caption = 'Textures'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object cbAtlases: TComboBox
      Left = 8
      Top = 33
      Width = 393
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 12
      TabOrder = 0
      OnChange = cbAtlasesChange
    end
    object bTextures: TButton
      Left = 407
      Top = 31
      Width = 75
      Height = 25
      Action = fMain.aTextureConfig
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
  end
end
