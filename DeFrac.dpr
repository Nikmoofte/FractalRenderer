program DeFrac;

{$R *.dres}

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  dglOpenGL in 'dglOpenGL.pas',
  MyVector3f in 'MyVector3f.pas',
  ChngCoordDialogUnit in 'ChngCoordDialogUnit.pas' {ChngCoordDialog},
  SceneParamList in 'SceneParamList.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TChngCoordDialog, ChngCoordDialog);
  Application.Run;
end.
