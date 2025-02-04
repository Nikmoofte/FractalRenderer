unit SomeShit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, DGLUT, dglOpenGL;

type
  tVector2d = array[0..1] of Double;
  tVector3d = array[0..2] of Double;
  tVector4d = array[0..3] of Double;
  TWindow = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure KeyCheck(Sender: TObject; var Key: Char);
  private

  public
    function VecUp(vec : tVector2d; k : double) : tVector3d; overload;
    function VecUp(vec : tVector3d; l : double) : tVector4d; overload;
  end;

var
  Window: TWindow;
  HRC: HGLRC;
  n, m, i : real;
  a, CameraAngle : float32;
  max, ind : integer;
  Key : Char;
implementation

{$R *.dfm}
function TWindow.VecUp(vec : tVector2d; k : double) : tVector3d;
var
  i : shortint;
begin
  for i := 0 to 1 do
    result[i] := vec[i];
  result[i + 1] := k;
end;
function TWindow.VecUp(vec : tVector3d; l : double) : tVector4d;
var
  i : shortint;
begin
  for i := 0 to 2 do
    result[i] := vec[i];
  result[i + 1] := l;
end;
procedure SetDCPixelFormat(hdc: hdc);
var
  pfd: TPixelFormatDescriptor;
  nPixelFormat: Integer;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL;

  nPixelFormat := ChoosePixelFormat(hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd);
end;

procedure TWindow.FormCreate(Sender: TObject);
var
  i : integer;
begin
  SetDCPixelFormat(Canvas.Handle); // ��������� ������ ������� �������� �����
  HRC := wglCreateContext(Canvas.Handle); // �������� �������� ����������
  wglMakeCurrent(Canvas.Handle, HRC);
  glEnable(GL_DEPTH_TEST); // �������� �������� ���������� ����� (������� ������� ��������� ������ �� ���)
  glDepthFunc(GL_LEQUAL); //��� ��������


end;

procedure fract(x,y,l,a:real); forward;


procedure TWindow.FormPaint(Sender: TObject);
var
  i : integer;
begin
  FormResize(Sender);
  If GetAsyncKeyState(VK_LEFT)<>0 then
  begin
    CameraAngle := CameraAngle - 0.05;
  end;
  if GetAsyncKeyState(VK_RIGHT)<>0 then
  begin
    CameraAngle := CameraAngle + 0.05;
  end;
  glClearColor(1, 1, 1, 1.0); // ���� ����
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  // ������� ������ ����� � �������

  glRotatef(CameraAngle, 0,0,1);


  ind := ind + 1;

  glColor3f(1,0,0);
  glBegin(GL_LINES);
    glVertex3f(0,0, -0.4);
    glVertex3f(3,0, -0.4);
  glEnd;
  glColor3f(0,1,0);
  glBegin(GL_LINES);
    glVertex3f(0,0, -0.4);
    glVertex3f(0,3, -0.4);
  glEnd;


  for i := 1 to 3 do
  begin
    glBegin(GL_LINES);
      glVertex2f(i, 0.1);
      glVertex2f(i, -0.1);
    glEnd;
    glBegin(GL_LINES);
      glVertex2f(0.1, i);
      glVertex2f(-0.1, i);
    glEnd;
    glBegin(GL_LINES);
      glVertex3f(0.1, -0.1, i);
      glVertex3f(-0.1, 0.1, i);
    glEnd;
    glBegin(GL_LINES);
      glVertex3f(0.1, 0.1, i);
      glVertex3f(-0.1, -0.1, i);
    glEnd;
  end;

  If GetAsyncKeyState(VK_DOWN)<>0 then
  begin
    SomeShit.i := SomeShit.i - 0.001;
  end;
  if GetAsyncKeyState(VK_UP)<>0 then
  begin
    SomeShit.i := SomeShit.i + 0.001;
  end;

  glShadeModel(GL_Flat);
  glPushMatrix;
  glTranslatef(0,SomeShit.i,0);
  glRotatef(a, 0,0,1);
  case Key of
    '1':
      glutSolidCube(1);
    '2':
      glutWireCube(1);
    '3':
      glutSolidSphere(1,30,30);
    '4':
      glutWireSphere(1,30,30);
    '5':
      glutWireCone(1,1,10,10);
    '6':
      glutSolidCone(1,1,10,10);
    else;
  end;

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glPopMatrix;



  SwapBuffers(Canvas.Handle);
end;

procedure fract(x,y,l,a:real);
begin
 if L>max then          // ������� ����� ��������
   begin
     L:=L*0.7;
     glBegin(GL_LINE_STRIP);
       glVertex2f(x/300,y/300);                             // ������� ��������� �����
       glVertex2f((x+L*cos(a))/300,(y-L*sin(a))/300);
     glEnd;
     x:=x+L*cos(a);                 // ������� ��������� ��������� �����
     y:=y-L*sin(a);
     fract(x,y,L,a+Pi/n);              // ��������
     fract(x,y,L,a-Pi/m);
   end;
end;

procedure TWindow.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight); //�������� ������� ���� ����� ���������� ��� �����
  glMatrixMode ( GL_PROJECTION ); //��������� � ������� ��������
  glLoadIdentity; //���������� ������� �������
  glFrustum ( -ClientWidth/ClientHeight , ClientWidth/ClientHeight, -1 , 1 , 1.25 , 100.0 ); //������� ���������
  glMatrixMode ( GL_MODELVIEW ); // ��������� � ��������� �������
  glLoadIdentity; //���������� ������� �������
  gluLookAt(0,0,1,0,0,0,0,1,0); //������� �����������
  InvalidateRect ( Handle,nil,False ); //����������� �����
end;

procedure TWindow.KeyCheck(Sender: TObject; var Key: Char);
begin
  SomeShit.Key := Key;
end;

end.
