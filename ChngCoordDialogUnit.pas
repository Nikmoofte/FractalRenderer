unit ChngCoordDialogUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MyVector3f, dglOpenGL;

type
  TChngCoordDialog = class(TForm)
    ConstantsLable: TLabel;
    CamX: TEdit;
    CamY: TEdit;
    CamZ: TEdit;
    OkButton: TButton;

  private

  public
    function Execute(const RO : Vector3f) : Boolean;
    function GetCoords : Vector3f;
  end;

var
  ChngCoordDialog: TChngCoordDialog;

implementation

{$R *.dfm}

function TChngCoordDialog.Execute(const RO : Vector3f) : Boolean;
var
  res : integer;
begin
  CamX.Text := FloatToStr(Ro.GetX);
  CamY.Text := FloatToStr(Ro.GetY);
  CamZ.Text := FloatToStr(Ro.GetZ);
  res := ShowModal;
  Result := res = mrOk;
end;
function TChngCoordDialog.GetCoords : Vector3f;
function MyStringToFloat(str: string): GLfloat;
var
  temp: Integer;
begin
  if str <> '' then
  begin
    temp := pos('.', str);
    While temp <> 0 do
    begin
      str[temp] := ',';
      temp := pos('.', str);
    end;
    Result := StrToFloat(str);
  end
  else
    Result := 0.0;
end;
begin
  Result := Vector3f.Create(MyStringToFloat(CamX.Text),
                            MyStringToFloat(CamY.Text),
                            MyStringToFloat(CamZ.Text))
end;

end.
