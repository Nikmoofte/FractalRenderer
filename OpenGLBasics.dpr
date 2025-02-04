program OpenGLBasics;

uses
  Vcl.Forms,
  SomeShit in 'SomeShit.pas' {Window},
  DGLUT in 'DGLUT.pas',
  dglOpenGL in 'dglOpenGL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Fractal Generator(Must be)';
  Application.CreateForm(TWindow, Window);
  Application.Run;
end.
