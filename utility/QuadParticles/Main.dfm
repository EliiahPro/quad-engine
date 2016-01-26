object fMain: TfMain
  Left = 200
  Top = 10
  Caption = 'Quad Particles - Alpha'
  ClientHeight = 648
  ClientWidth = 987
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    AlignWithMargins = True
    Left = 288
    Top = 3
    Height = 570
    Beveled = True
    ResizeStyle = rsLine
    ExplicitLeft = 165
    ExplicitTop = 63
    ExplicitHeight = 554
  end
  object Splitter1: TSplitter
    AlignWithMargins = True
    Left = 564
    Top = 3
    Height = 570
    Beveled = True
    ResizeStyle = rsLine
    ExplicitLeft = 581
    ExplicitTop = 17
    ExplicitHeight = 663
  end
  object tvEffectList: TTreeView
    Left = 0
    Top = 0
    Width = 285
    Height = 576
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    HideSelection = False
    Images = dmIcomList.List
    Indent = 35
    ParentDoubleBuffered = False
    ParentFont = False
    PopupMenu = pmEffectList
    RowSelect = True
    TabOrder = 0
    OnChange = tvEffectListChange
    OnCollapsed = tvEffectListCollapsed
    OnCreateNodeClass = tvEffectListCreateNodeClass
    OnCustomDrawItem = tvEffectListCustomDrawItem
    OnEdited = tvEffectListEdited
    OnExpanded = tvEffectListExpanded
    OnMouseDown = tvEffectListMouseDown
    ExplicitHeight = 728
  end
  object Panel2: TPanel
    Left = 570
    Top = 0
    Width = 417
    Height = 576
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 656
    ExplicitHeight = 728
    object Splitter3: TSplitter
      Left = 0
      Top = 368
      Width = 417
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ResizeStyle = rsLine
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 470
    end
    object Panel3: TPanel
      Left = 0
      Top = 371
      Width = 417
      Height = 205
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 523
      ExplicitWidth = 656
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 417
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 656
        object tbTimeLine: TToolBar
          Left = 3
          Top = 0
          Width = 299
          Height = 38
          Align = alNone
          ButtonHeight = 38
          ButtonWidth = 39
          Caption = 'tbTimeLine'
          Images = dmIcomList.ilIcons32
          TabOrder = 0
          object tbPlayerRestart: TToolButton
            Left = 0
            Top = 0
            Action = aPlayerRestart
          end
          object tbPlayerPlay: TToolButton
            Left = 39
            Top = 0
            Action = aPlayerPlay
          end
          object tbPlayerPause: TToolButton
            Left = 78
            Top = 0
            Action = aPlayerPause
          end
          object tbPlayerLoop: TToolButton
            Left = 117
            Top = 0
            Action = aPlayerLoop
            Down = True
            Style = tbsCheck
          end
        end
        object TrackBar1: TTrackBar
          Left = 248
          Top = 0
          Width = 169
          Height = 38
          Align = alRight
          Max = 1000
          Min = 10
          Position = 64
          TabOrder = 1
          TickMarks = tmBoth
          TickStyle = tsManual
          OnChange = TrackBar1Change
          ExplicitLeft = 487
        end
      end
      object EffectTimeLine: TEffectTimeLine
        Left = 0
        Top = 38
        Width = 400
        Height = 150
        Align = alClient
        HeightLine = 21
        Scale = 256
        Lines = <>
        ScrollBarV = EffectTimeLineScrollV
        ScrollBarH = EffectTimeLineScrollH
        ExplicitWidth = 639
      end
      object Panel7: TPanel
        Left = 0
        Top = 188
        Width = 417
        Height = 17
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitWidth = 656
        DesignSize = (
          417
          17)
        object EffectTimeLineScrollH: TScrollBar
          Left = 128
          Top = 0
          Width = 272
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Max = 1000
          PageSize = 2
          TabOrder = 0
          ExplicitWidth = 511
        end
      end
      object EffectTimeLineScrollV: TScrollBar
        Left = 400
        Top = 38
        Width = 17
        Height = 150
        Align = alRight
        Kind = sbVertical
        PageSize = 0
        TabOrder = 3
        ExplicitLeft = 639
      end
    end
    object Panel6: TPanel
      Left = 413
      Top = 0
      Width = 4
      Height = 345
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitLeft = 652
      ExplicitHeight = 497
    end
    object pPreview: TPanel
      Left = 0
      Top = 0
      Width = 413
      Height = 345
      Align = alClient
      BevelOuter = bvLowered
      TabOrder = 2
      OnResize = pPreviewResize
      ExplicitWidth = 652
      ExplicitHeight = 497
    end
    object ToolBar2: TToolBar
      Left = 0
      Top = 345
      Width = 417
      Height = 23
      Align = alBottom
      Caption = 'ToolBar2'
      Images = dmIcomList.ilIcons16
      TabOrder = 3
      ExplicitTop = 497
      ExplicitWidth = 656
      object tbDrawShape: TToolButton
        Left = 0
        Top = 0
        Hint = 'Draw Shape'
        Caption = 'Draw Shape'
        Down = True
        ImageIndex = 2
        Style = tbsCheck
        OnClick = tbDrawShapeClick
      end
      object ToolButton1: TToolButton
        Left = 23
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object tbBackgroundBlack: TToolButton
        Left = 31
        Top = 0
        Caption = 'Background Black'
        Down = True
        ImageIndex = 3
        OnClick = tbBackgroundBlackClick
      end
      object tbBackgroundWhite: TToolButton
        Left = 54
        Top = 0
        Caption = 'Background White'
        ImageIndex = 4
        OnClick = tbBackgroundWhiteClick
      end
      object tbBackgroundColor: TToolButton
        Left = 77
        Top = 0
        Caption = 'Background Color'
        ImageIndex = 5
        OnClick = tbBackgroundColorClick
      end
      object tbBackgroundImg: TToolButton
        Left = 100
        Top = 0
        Caption = 'Background Image'
        ImageIndex = 6
        OnClick = tbBackgroundImgClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 629
    Width = 987
    Height = 19
    Panels = <>
    ExplicitTop = 781
    ExplicitWidth = 1226
  end
  object pcParams: TPageControl
    Left = 294
    Top = 0
    Width = 267
    Height = 576
    ActivePage = tsProperties
    Align = alLeft
    TabOrder = 3
    ExplicitHeight = 728
    object tsProperties: TTabSheet
      Caption = 'Properties'
      ExplicitHeight = 700
      object lvParamList: TListView
        Left = 0
        Top = 35
        Width = 259
        Height = 268
        Align = alTop
        Columns = <
          item
            Width = 250
          end>
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        PopupMenu = pmParamList
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = lvParamListChange
        OnResize = lvParamListResize
      end
      object pCaption: TPanel
        Left = 0
        Top = 0
        Width = 259
        Height = 35
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lCaption: TLabel
          Left = 8
          Top = 8
          Width = 71
          Height = 19
          Caption = 'Properties'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object pParam: TPanel
        Left = 0
        Top = 303
        Width = 259
        Height = 245
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitHeight = 397
      end
    end
    object tsGravitation: TTabSheet
      Caption = 'Gravitation'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 259
        Height = 89
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 16
          Width = 77
          Height = 19
          Caption = 'Gravitation'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object FloatSpinEdit1: TFloatSpinEdit
          Left = 88
          Top = 53
          Width = 121
          Height = 21
          Increment = 0.050000000000000000
        end
      end
      object dGravDirection: TQuadDiagram
        Left = 0
        Top = 89
        Width = 259
        Height = 200
        Align = alTop
        Style.Background1 = clBtnFace
        Style.Background2 = clBtnFace
        Style.GridLine = clWindowText
        Style.Axis = clWindowText
        Style.AxisTitle = clWindowText
        Style.Gradient = LinearGradientModeVertical
        Style.LegendVisible = False
        Style.LegendColumns = 0
        Lines = <
          item
            Color = clRed
            Points = <
              item
                Color = clBlack
              end>
            Width = 1
            Style = DashStyleSolid
            Enabled = True
            Caption = 'Direction'
          end>
        Position = -1.000000000000000000
        AxisV.Name = 'Angle, '#176
        AxisV.Format = '0'
        AxisV.MaxValue = 360.000000000000000000
        AxisV.GridSize = 90.000000000000000000
        AxisV.LowMin = 360.000000000000000000
        AxisV.LowMax = 360.000000000000000000
        AxisH.Name = 'Time, s'
        AxisH.Format = '0'
        AxisH.MaxValue = 5.000000000000000000
        AxisH.GridSize = 1.000000000000000000
        AxisH.LowMin = 5.000000000000000000
        AxisH.LowMax = 100.000000000000000000
      end
      object dGravForce: TQuadDiagram
        Left = 0
        Top = 289
        Width = 259
        Height = 248
        Align = alTop
        Style.Background1 = clBtnFace
        Style.Background2 = clBtnFace
        Style.GridLine = clWindowText
        Style.Axis = clWindowText
        Style.AxisTitle = clWindowText
        Style.Gradient = LinearGradientModeVertical
        Style.LegendVisible = False
        Style.LegendColumns = 0
        Lines = <
          item
            Color = clRed
            Points = <
              item
                Color = clBlack
              end>
            Width = 1
            Style = DashStyleSolid
            Enabled = True
          end>
        Position = -1.000000000000000000
        AxisV.Name = 'Force, Px'
        AxisV.Format = '0'
        AxisV.MinValue = -50.000000000000000000
        AxisV.MaxValue = 50.000000000000000000
        AxisV.GridSize = 25.000000000000000000
        AxisV.LowMin = -50.000000000000000000
        AxisV.LowMax = 50.000000000000000000
        AxisV.HighMin = -500.000000000000000000
        AxisV.HighMax = 500.000000000000000000
        AxisH.Name = 'Time, s'
        AxisH.Format = '0'
        AxisH.MaxValue = 5.000000000000000000
        AxisH.GridSize = 1.000000000000000000
        AxisH.LowMin = 5.000000000000000000
        AxisH.LowMax = 100.000000000000000000
      end
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 576
    Width = 987
    Height = 53
    Align = alBottom
    ItemHeight = 13
    TabOrder = 4
    ExplicitTop = 728
    ExplicitWidth = 1226
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Images = dmIcomList.ilIcons32
    Left = 26
    Top = 297
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Action = aNew
      end
      object Open1: TMenuItem
        Action = aOpen
      end
      object miReopen: TMenuItem
        Caption = 'Reopen'
        Enabled = False
      end
      object Save1: TMenuItem
        Action = aSave
      end
      object SaveAs1: TMenuItem
        Action = aSaveAs
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = aExit
      end
    end
    object textures1: TMenuItem
      Action = aTextureConfig
      Caption = 'Textures'
    end
  end
  object pmParamList: TPopupMenu
    Left = 34
    Top = 189
    object miParamAdd: TMenuItem
      Caption = 'Add'
      object Shape1: TMenuItem
        Action = aParamShape
      end
      object Emission1: TMenuItem
        Action = aParamEmission
      end
      object Opacity1: TMenuItem
        Action = aParamOpacity
      end
      object Scale1: TMenuItem
        Action = aParamScale
      end
      object Spin1: TMenuItem
        Action = aParamSpin
      end
    end
  end
  object ActionList: TActionList
    Images = dmIcomList.ilIcons32
    Left = 138
    Top = 13
    object aNew: TAction
      Category = 'Menu'
      Caption = 'New'
      ImageIndex = 14
      OnExecute = aNewExecute
    end
    object aParamShape: TAction
      Category = 'Params'
      Caption = 'Shape'
    end
    object aParamEmission: TAction
      Category = 'Params'
      Caption = 'Emission'
    end
    object aParamOpacity: TAction
      Category = 'Params'
      Caption = 'Opacity'
    end
    object aParamScale: TAction
      Category = 'Params'
      Caption = 'Scale'
    end
    object aParamSpin: TAction
      Category = 'Params'
      Caption = 'Spin'
    end
    object aCreatePack: TAction
      Category = 'EffectList'
      Caption = 'Create Pack'
      OnExecute = aCreatePackExecute
    end
    object aCreateEffect: TAction
      Category = 'EffectList'
      Caption = 'Create Effect'
      Enabled = False
      ImageIndex = 5
      OnExecute = aCreateEffectExecute
    end
    object aCreateEmitter: TAction
      Category = 'EffectList'
      Caption = 'Create Emitter'
      Enabled = False
      ImageIndex = 6
      OnExecute = aCreateEmitterExecute
    end
    object aOpen: TAction
      Category = 'Menu'
      Caption = 'Open'
      ImageIndex = 15
      OnExecute = aOpenExecute
    end
    object aSave: TAction
      Category = 'Menu'
      Caption = 'Save'
      ImageIndex = 16
      OnExecute = aSaveExecute
    end
    object aPlayerPlay: TAction
      Category = 'Player'
      Caption = 'Play'
      ImageIndex = 8
      OnExecute = aPlayerPlayExecute
    end
    object aPlayerPause: TAction
      Category = 'Player'
      Caption = 'Pause'
      ImageIndex = 7
      OnExecute = aPlayerPauseExecute
    end
    object aPlayerRestart: TAction
      Category = 'Player'
      Caption = 'Restart'
      ImageIndex = 10
      OnExecute = aPlayerRestartExecute
    end
    object aPlayerLoop: TAction
      Category = 'Player'
      Caption = 'Loop'
      ImageIndex = 9
      OnExecute = aPlayerLoopExecute
    end
    object aTextureConfig: TAction
      Category = 'ParamsTexture'
      Caption = 'Config'
      ImageIndex = 11
      OnExecute = aTextureConfigExecute
    end
    object aSaveAs: TAction
      Category = 'Menu'
      Caption = 'Save As...'
      ImageIndex = 17
      OnExecute = aSaveAsExecute
    end
    object aExit: TAction
      Category = 'Menu'
      Caption = 'Exit'
      ImageIndex = 18
      OnExecute = aExitExecute
    end
    object aDelete: TAction
      Category = 'EffectList'
      Caption = 'Delete'
      OnExecute = aDeleteExecute
    end
  end
  object pmEffectList: TPopupMenu
    Images = dmIcomList.ilIcons32
    Left = 120
    Top = 184
    object CreateEmitter1: TMenuItem
      Action = aCreateEmitter
    end
    object CreateEffect1: TMenuItem
      Action = aCreateEffect
    end
    object aCreatePack1: TMenuItem
      Action = aCreatePack
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miDeleteEffectEmitter: TMenuItem
      Action = aDelete
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.json'
    Filter = 
      #1069#1092#1092#1077#1082#1090' (*.qfx;*.json)|*.qfx;*.json|QFX (*.qfx)|*.qfx|JSON (*.jso' +
      'n)|*.json'
    Left = 34
    Top = 344
  end
  object SaveDialog: TSaveDialog
    DefaultExt = '*.json'
    Filter = 'JSON|*.json|QFX|*.qfx|XML|*.xml'
    Left = 90
    Top = 72
  end
  object ColorDialog: TColorDialog
    Left = 608
    Top = 252
  end
  object OpenPictureDialog: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Portable' +
      ' Network Graphics (*.png)|*.png|JPEG Image File (*.jpg,*.jpeg)|*' +
      '.jpg;*.jpeg|Bitmaps (*.bmp)|*.bmp'
    Left = 676
    Top = 256
  end
end
