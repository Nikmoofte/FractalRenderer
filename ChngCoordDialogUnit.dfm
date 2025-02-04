object ChngCoordDialog: TChngCoordDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Coordinates'
  ClientHeight = 174
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ConstantsLable: TLabel
    Left = 69
    Top = 8
    Width = 170
    Height = 23
    Caption = 'Camera Coordinates'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object CamX: TEdit
    Left = 32
    Top = 54
    Width = 65
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TextHint = 'X'
  end
  object CamY: TEdit
    Left = 120
    Top = 54
    Width = 65
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TextHint = 'Y'
  end
  object CamZ: TEdit
    Left = 208
    Top = 54
    Width = 65
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    TextHint = 'Z'
  end
  object OkButton: TButton
    Left = 86
    Top = 120
    Width = 139
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
end
