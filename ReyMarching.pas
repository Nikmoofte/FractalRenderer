unit ReyMarching;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, DGLUT;

type
  TTryingReyMarching = class(TForm)
  private
    { Private declarations }
  public
    function trace(): double;
  end;

var
  TryingReyMarching: TTryingReyMarching;

implementation

{$R *.dfm}

end.
