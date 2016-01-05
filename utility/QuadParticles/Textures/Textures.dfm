object fTextures: TfTextures
  Left = 0
  Top = 0
  Caption = 'fTextures'
  ClientHeight = 546
  ClientWidth = 799
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = pmTreeList
  OnClick = FormClick
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseLeave = FormMouseLeave
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object RightPanel: TPanel
    Left = 526
    Top = 0
    Width = 273
    Height = 527
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object TreeList: TTreeView
      Left = 0
      Top = 38
      Width = 273
      Height = 467
      Align = alClient
      DragMode = dmAutomatic
      HotTrack = True
      Images = dmIcomList.List
      Indent = 51
      PopupMenu = pmTreeList
      RowSelect = True
      ShowButtons = False
      ShowRoot = False
      StateImages = dmIcomList.List
      TabOrder = 0
      OnChange = TreeListChange
      OnCreateNodeClass = TreeListCreateNodeClass
      OnDragDrop = TreeListDragDrop
      OnDragOver = TreeListDragOver
    end
    object ToolBar1: TToolBar
      Left = 0
      Top = 0
      Width = 273
      Height = 38
      ButtonHeight = 38
      ButtonWidth = 39
      Caption = 'ToolBar1'
      Images = dmIcomList.ilIcons32
      TabOrder = 1
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = aCreateAtlas
      end
      object ToolButton2: TToolButton
        Left = 39
        Top = 0
        Action = aOpenSprite
      end
      object ToolButton4: TToolButton
        Left = 78
        Top = 0
        Action = aRemove
      end
      object ToolButton3: TToolButton
        Left = 117
        Top = 0
        Caption = 'ToolButton3'
        ImageIndex = 4
      end
    end
    object ToolBar2: TToolBar
      Left = 0
      Top = 505
      Width = 273
      Height = 22
      Align = alBottom
      Caption = 'ToolBar2'
      Ctl3D = False
      TabOrder = 2
      object ToolButton5: TToolButton
        Left = 0
        Top = 0
        Caption = 'ToolButton5'
        ImageIndex = 0
        OnClick = ToolBarColorClick
      end
      object ToolButton6: TToolButton
        Left = 23
        Top = 0
        Caption = 'ToolButton6'
        ImageIndex = 1
        OnClick = ToolBarColorClick
      end
      object ToolButton7: TToolButton
        Left = 46
        Top = 0
        Caption = 'ToolButton7'
        ImageIndex = 2
        OnClick = ToolBarColorClick
      end
      object ToolButton8: TToolButton
        Left = 69
        Top = 0
        Caption = 'ToolButton8'
        ImageIndex = 3
        OnClick = ToolBarColorClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 527
    Width = 799
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
  end
  object pmTreeList: TPopupMenu
    Left = 320
    Top = 280
    object CreateAtlas1: TMenuItem
      Action = aCreateAtlas
    end
    object OpenSprite1: TMenuItem
      Action = aOpenSprite
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Remove1: TMenuItem
      Action = aRemove
    end
  end
  object ActionList: TActionList
    Images = dmIcomList.ilIcons32
    Left = 208
    Top = 184
    object aCreateAtlas: TAction
      Category = 'TreeList'
      Caption = 'Create Atlas'
      ImageIndex = 2
      OnExecute = aCreateAtlasExecute
    end
    object aOpenSprite: TAction
      Category = 'TreeList'
      Caption = 'Open Sprite'
      ImageIndex = 3
      OnExecute = aOpenSpriteExecute
    end
    object aRemove: TAction
      Category = 'TreeList'
      Caption = 'Remove'
      ImageIndex = 1
      OnExecute = aRemoveExecute
    end
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 168
    Top = 72
  end
  object ColorDialog: TColorDialog
    Left = 304
    Top = 344
  end
end
