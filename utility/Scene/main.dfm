object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Scene'
  ClientHeight = 654
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MainPanel: TPanel
    Left = 237
    Top = 41
    Width = 665
    Height = 613
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object TimeLinePanel: TPanel
      Left = 0
      Top = 508
      Width = 665
      Height = 105
      Align = alBottom
      TabOrder = 0
    end
    object RenderPanel: TPanel
      Left = 0
      Top = 0
      Width = 665
      Height = 508
      Cursor = crCross
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      OnMouseDown = RenderPanelMouseDown
      OnMouseMove = RenderPanelMouseMove
      OnMouseUp = RenderPanelMouseUp
      OnResize = RenderPanelResize
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 237
    Height = 613
    Align = alLeft
    TabOrder = 1
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 1120
    Height = 41
    Align = alTop
    TabOrder = 2
  end
  object Panel4: TPanel
    Left = 902
    Top = 41
    Width = 218
    Height = 613
    Align = alRight
    TabOrder = 3
    object TreeView1: TTreeView
      Left = 1
      Top = 1
      Width = 216
      Height = 256
      Align = alTop
      Indent = 19
      TabOrder = 0
      Items.NodeData = {
        03040000002E0000000000000000000000FFFFFFFFFFFFFFFF00000000000000
        0000000000010854006500780074007500720065007300320000000000000000
        000000FFFFFFFFFFFFFFFF000000000000000000000000010A41006E0069006D
        006100740069006F006E007300280000000000000000000000FFFFFFFFFFFFFF
        FF000000000000000000000000010546006F006E00740073002C000000000000
        0000000000FFFFFFFFFFFFFFFF00000000000000000000000001075300680061
        006400650072007300}
    end
  end
  object ResizeTimer: TTimer
    Enabled = False
    OnTimer = ResizeTimerTimer
    Left = 118
    Top = 184
  end
  object MainMenu: TMainMenu
    Left = 108
    Top = 56
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New'
      end
      object Open1: TMenuItem
        Caption = '&Open'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Save1: TMenuItem
        Caption = '&Save'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
      end
    end
    object Project1: TMenuItem
      Caption = '&Project'
      object Additem1: TMenuItem
        Caption = '&Add'
        object Texture1: TMenuItem
          Action = Action1
          Caption = 'Texture...'
        end
        object Animation1: TMenuItem
          Caption = 'Animation...'
        end
        object Font1: TMenuItem
          Caption = 'Font...'
        end
        object Shader1: TMenuItem
          Caption = 'Shader...'
        end
      end
      object Options1: TMenuItem
        Caption = '&Options'
      end
    end
    object View1: TMenuItem
      Caption = '&View'
    end
    object About1: TMenuItem
      Caption = '&Help'
      object About2: TMenuItem
        Caption = '&About'
      end
    end
  end
  object OpenTextureDialog: TOpenDialog
    Filter = 
      'QuadEngine Textures (BMP,JPEG, PNG, TGA, DDS)|*.bmp;*.jpg;*.jpeg' +
      ';*.png;*.tga;*.dds'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 152
    Top = 118
  end
  object ActionManager1: TActionManager
    Left = 132
    Top = 260
    StyleName = 'Platform Default'
    object Action1: TAction
      Caption = 'Action1'
      OnExecute = Action1Execute
    end
  end
end
