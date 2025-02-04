unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dglOpenGL, Vcl.ExtCtrls, MyVector3f,
  Vcl.StdCtrls, Vcl.Menus, System.Actions, Vcl.ActnList, ChngCoordDialogUnit,
  SceneParamList, Winapi.ShellAPI;

type


  tConstNameArr = array [tConsts] of string;

  TMainForm = class(TForm)
    LeftPanel: TPanel;
    UpperPanel: TPanel;
    ReRenderButton: TButton;
    MainMenu1: TMainMenu;
    FSSegment: TPanel;
    ConstantA: TLabeledEdit;
    ConstantB: TLabeledEdit;
    ConstantC: TLabeledEdit;
    ConstantD: TLabeledEdit;
    ConstantE: TLabeledEdit;
    ConstantsLable: TLabel;
    ConstantX: TEdit;
    ConstantY: TEdit;
    ConstantZ: TEdit;
    Epsilon: TComboBox;
    EpsName: TLabel;
    FractalType: TComboBox;
    FSSegmentCaption: TPanel;
    FTLable: TLabel;
    IterationsNumber: TComboBox;
    ITLable: TLabel;
    FileOptions: TMenuItem;
    SaveOption: TMenuItem;
    SaveAsOption: TMenuItem;
    OpenOption: TMenuItem;
    CameraOptions: TMenuItem;
    ChngCoord: TMenuItem;
    ChngSpeed: TMenuItem;
    EditOptions: TMenuItem;
    UndoOption: TMenuItem;
    RedoOption: TMenuItem;
    ActionList1: TActionList;
    NewAction: TAction;
    SaveAction: TAction;
    SaveAsAction: TAction;
    LoadAction: TAction;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    ChangeCoords: TAction;
    ChangeSpeed: TAction;
    UndoAction: TAction;
    RedoAction: TAction;
    HelpOption: TMenuItem;
    HelpAction: TAction;
    AboutOption: TMenuItem;
    AboutAction: TAction;
    ChangeGUIState: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdleHandler(Sender: TObject; var Done: Boolean);
    procedure KeyPressed(Sender: TObject; var Key: Char);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure ReRender(Sender: TObject);
    procedure FractalTypeChange(Sender: TObject);
    procedure GUIOnExit(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure LoadActionExecute(Sender: TObject);
    procedure NewActionExecute(Sender: TObject);
    procedure ChangeCoordsExecute(Sender: TObject);
    procedure ChangeSpeedExecute(Sender: TObject);
    procedure UndoActionExecute(Sender: TObject);
    procedure RedoActionExecute(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
    procedure ChangeGUIStateExecute(Sender: TObject);
    procedure AboutActionExecute(Sender: TObject);
  private

  var
    StartTime, TimeCount, FrameCount: Cardinal;
    Frames, DrawTime: Cardinal;
    procedure SetupGl;
    procedure Render;
    procedure SetUniform;
    procedure initShaders;
    procedure init;
    procedure Move;
    procedure SetView;
    procedure MouseHandle;
    procedure FracParamInit(const Names, startVal: tConstNameArr);
    procedure SaveFile(const name: string);
    procedure LoadFile(const name: string);
    procedure SaveParams(var dest: tSceneParam);
    procedure LoadParams(const params: tSceneParam);
  public
  var
    DC: HDC;
    RC: HGLRC;
    ProgramOBJ: GLHandle;
    vbo, vao: GLint;
    prevX, prevY,  X0, Y0: GLint;
    xAng, yAng: GLfloat;
    RO, RD, RR, RU: Vector3f;
    IsGUIVisible,  BlockMovement: Boolean;
    ConstantsPtrArr: array [tConsts] of ^Vcl.ExtCtrls.TLabeledEdit;
    Fractal: tFracType;
    zoom: GLfloat;
  end;

const
  NearClipping = 0.1;
  FarClipping = 100000;
  MouseSensivity = 1;

var
  MainForm: TMainForm;
  FrameCount: Integer;
  leftMouseButtonPressed: Boolean;
  IsSecond: Boolean;
  RenderHeight, RenderWidth: GLint;
  Speed : GLFloat;
  ParamList : tList;

function MyStringToFloat(str: string): GLfloat;

implementation

{$R *.dfm}

procedure TMainForm.SaveParams(var dest: tSceneParam);
var
  i: tConsts;
begin
  for i := Low(ConstantsPtrArr) to High(ConstantsPtrArr) do
    dest.Consts[i] := MyStringToFloat(ConstantsPtrArr[i].Text);
  dest.Iterations := MyStringToFloat(IterationsNumber.Text);
  dest.Epsilon := MyStringToFloat(Epsilon.Text);
  dest.Fractal := Fractal;
end;

procedure TMainForm.LoadParams(const params: tSceneParam);
var
  i: tConsts;
  temp : Vector3f;
begin
  FractalType.ItemIndex := Ord(params.Fractal) - 1;
  temp := Vector3f.Create(RO);
  FractalTypeChange(Self);
  RO := Temp;
  for i := Low(ConstantsPtrArr) to High(ConstantsPtrArr) do
    ConstantsPtrArr[i].Text := FloatToStr(params.Consts[i]);
  IterationsNumber.Text := FloatToStr(params.Iterations);
  Epsilon.Text := FloatToStr(params.Epsilon);
end;

procedure TMainForm.SaveActionExecute(Sender: TObject);
var
  fileName: string;
  buttonSellected: Integer;
begin
  BlockMovement := true;
  if SaveDialog.Execute then
  begin
    fileName := SaveDialog.fileName;
    if FileExists(fileName) then
    begin
      buttonSellected := MessageDlg('File ' + ExtractFileName(fileName) +
        ' will be overwritten. Continue?', mtWarning, mbOKCancel, 0);
      case buttonSellected of
        mrOk:
          SaveFile(fileName);
        mrCancel:
          ;
      end;
    end
    else
      SaveFile(fileName);
  end;
  BlockMovement := false;
end;

procedure TMainForm.SaveFile(const name: string);
var
  SceneFile: File of tSceneParam;
  SceneParams: tSceneParam;
begin
  AssignFile(SceneFile, Name);
  Rewrite(SceneFile);
  SaveParams(SceneParams);
  Write(SceneFile, SceneParams);
end;

procedure TMainForm.LoadActionExecute(Sender: TObject);
var
  fileName: string;
  buttonSellected: Integer;
begin
  BlockMovement := true;
  if OpenDialog.Execute then
  begin
    fileName := OpenDialog.fileName;
    if FileExists(fileName) then
    begin
      LoadFile(fileName);
      ReRender(Self);
    end
    else
    begin
      MessageDlg(('File ' + ExtractFileName(fileName) + ' does not exist.'),
        mtConfirmation, [mbOK], 0);
    end;
  end;
  BlockMovement := false;
end;

procedure TMainForm.LoadFile(const name: string);
var
  SceneFile: File of tSceneParam;
  SceneParams: tSceneParam;
begin
  AssignFile(SceneFile, Name);
  Reset(SceneFile);
  Read(SceneFile, SceneParams);
  LoadParams(SceneParams);
end;

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

procedure TMainForm.FormCreate(Sender: TObject);
var
  Params : tSceneParam;
begin
  DC := GetDC(Handle);
  if not InitOpenGL then
    Application.Terminate;
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
  ActivateRenderingContext(DC, RC);
  Application.OnIdle := IdleHandler;

  initShaders;
  init;
  SetupGl;
  FractalTypeChange(Sender);
  SaveParams(Params);
  ParamList.AddElem(Params);
  SetUniform;
end;

procedure TMainForm.SetUniform;
const
  uniforms: array [tConsts] of AnsiString = ('u_ConstA', 'u_ConstB', 'u_ConstC',
    'u_ConstD', 'u_ConstE', 'u_X', 'u_Y', 'u_Z');
var
  i: tConsts;
begin
  glUniform2f(glGetUniformLocation(ProgramOBJ, PGLChar('u_resolution')),
    GLfloat(RenderWidth), GLfloat(RenderHeight));
  glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar('u_Iterations')),
    MyStringToFloat(IterationsNumber.Text));
  glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar('u_Epsilon')),
    MyStringToFloat(Epsilon.Text));
  glUniform1i(glGetUniformLocation(ProgramOBJ, PGLChar('u_FracType')),
    Ord(Fractal));
  for i := Low(ConstantsPtrArr) to High(ConstantsPtrArr) do
  begin
    glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar(uniforms[i])),
      MyStringToFloat(ConstantsPtrArr[i].Text));
  end;
end;

procedure TMainForm.SetupGl;
const
  bufferData: array [0 .. 11] of GLfloat = (1, 1, 0, -1, 1, 0, -1, -1, 0,
    1, -1, 0);
begin
  glClearColor(0, 0, 0, 0.0);
  glUseProgram(ProgramOBJ);
  SetUniform;

  glGenBuffers(1, @vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(bufferData), @bufferData,
    GL_STATIC_DRAW);

  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);

  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nil);
  glEnableVertexAttribArray(0);

  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext;
  DestroyRenderingContext(RC);
  ReleaseDC(Handle, DC);
end;

procedure TMainForm.init;
begin
  ParamList := tList.Create;
  RenderHeight := ClientHeight - UpperPanel.Height;
  RenderWidth := ClientWidth - LeftPanel.Width;
  X0 := RenderWidth div 2;
  Y0 := RenderHeight div 2;
  yAng := 0;
  xAng := 0;
  BlockMovement := false;
  Speed := 0.01;
  RedoOption.Enabled := false;
  UndoOption.Enabled := false;


  TimeCount := 0;
  IsSecond := false;
  zoom := 0;
  IsGUIVisible := true;


  RO := Vector3f.Create(0, 0, -2);
  ConstantsPtrArr[A] := @ConstantA;
  ConstantsPtrArr[B] := @ConstantB;
  ConstantsPtrArr[C] := @ConstantC;
  ConstantsPtrArr[D] := @ConstantD;
  ConstantsPtrArr[E] := @ConstantE;
  ConstantsPtrArr[X] := @ConstantX;
  ConstantsPtrArr[Y] := @ConstantY;
  ConstantsPtrArr[Z] := @ConstantZ;

end;

procedure TMainForm.initShaders;
var
  src: TStringList;
  rawStr: RawByteString;
  len: GLint;
  VertexShdrOBJ, FragmenShdrOBJ: GLHandle;
  Stream : TResourceStream;
begin
  ProgramOBJ := glCreateProgram;

  VertexShdrOBJ := glCreateShader(GL_VERTEX_SHADER);
  FragmenShdrOBJ := glCreateShader(GL_FRAGMENT_SHADER);

  src := TStringList.Create;

  Stream := TResourceStream.Create(HInstance, 'Vertex_Shader', RT_RCDATA);
  src.LoadFromStream(Stream);
  rawStr := src.Text;
  len := Length(rawStr);

  glShaderSource(VertexShdrOBJ, 1, @rawStr, @len);
  Stream := TResourceStream.Create(HInstance, 'Fragment_Shader', RT_RCDATA);
  src.LoadFromStream(Stream);
  rawStr := src.Text;
  len := Length(rawStr);

  glShaderSource(FragmenShdrOBJ, 1, @rawStr, @len);

  glCompileShader(VertexShdrOBJ);

  glCompileShader(FragmenShdrOBJ);

  glAttachShader(ProgramOBJ, VertexShdrOBJ);
  glAttachShader(ProgramOBJ, FragmenShdrOBJ);

  glDeleteShader(VertexShdrOBJ);
  glDeleteShader(FragmenShdrOBJ);

  glLinkProgram(ProgramOBJ);
end;

procedure TMainForm.KeyPressed(Sender: TObject; var Key: Char);
begin
  if Hi(GetKeyState(Ord('F'))) <> 0 then
    ChangeGUIStateExecute(Sender);


end;



procedure TMainForm.AboutActionExecute(Sender: TObject);
var
  Text : TextFile;
begin
  AssignFile(Text, 'Info.txt');
  Rewrite(Text);
  Writeln(Text, 'Name: DeFrac' + #13 + #10 +
               'Version: 1.0' + #13 + #10 +
               'Date:    May 28 2022' + #13 + #10 +
               'Author:  Mikhail Barylka' + #13 + #10 +
               'EMail:   isnotanick@gmail.com' + #13 + #10 + #13 + #10 +

               'Status:  Course Project' + #13 + #10 +
               'Distribution Status: Freely distributable' + #13 + #10 + #13 + #10 +


               'Installation:' + #13 + #10 +
               '-------------' + #13 + #10 + #13 + #10 +

               'Run DeFrac.exe' + #13 + #10 + #13 + #10 +


               'Uninstall:' + #13 + #10 +
               '----------' + #13 + #10 +

               'The program can be uninstalled using the uninstaller.' +
               'But it will leave files in your local directory as it cannot' +
               'know whether you want to keep them.' + #13 + #10 +
                #13 + #10 +


               'Short description:' + #13 + #10 +
               '------------------' + #13 + #10 + #13 + #10 +

               'DeFrac is a fractal generator that uses "Ray Marching" for rendering images, i.e. you can get extremly accurate fractal without expensive hardware.' + #13 + #10 +

               'It can save and open file with .frac extention, palette and formula files, supporting 4 of fractal type.' + #13 + #10 +

               'You can explore fractal from any direction.');

  Writeln(Text, 'Is supports some parameters for generatin so you can generate almos unlimited variation of fractal.');



  ShellExecute(0, PChar('open'), PChar('Info.txt'), nil, nil, SW_RESTORE);
  CloseFile(Text);

end;

procedure TMainForm.ChangeCoordsExecute(Sender: TObject);
begin
  BlockMovement := true;
  if ChngCoordDialog.Execute(RO) then
  begin
    RO := ChngCoordDialog.GetCoords;
  end;
  BlockMovement := false;
end;


procedure TMainForm.ChangeGUIStateExecute(Sender: TObject);
begin
  IsGUIVisible := not IsGUIVisible;
  if not IsGUIVisible then
  begin
    UpperPanel.hide;
    LeftPanel.hide;
    RenderHeight := ClientHeight;
    RenderWidth := ClientWidth;
  end
  else
  begin
    UpperPanel.show;
    LeftPanel.show;
    RenderHeight := ClientHeight - UpperPanel.Height;
    RenderWidth := ClientWidth - LeftPanel.Width;
  end;
  SetUniform;
  glViewport(0, 0, RenderWidth, RenderHeight);
end;

procedure TMainForm.ChangeSpeedExecute(Sender: TObject);
var
  temp : string;
begin
  temp := InputBox('Speed Change', 'Input new speed', FloatToStr(Speed));
  if temp <> '' then
    Speed := MyStringToFloat(temp);
end;

procedure TMainForm.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    leftMouseButtonPressed := true;
    ShowCursor(false);
  end;
end;

procedure TMainForm.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    leftMouseButtonPressed := false;
    ShowCursor(true);
  end;

end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if IsGUIVisible then
  begin
    RenderHeight := ClientHeight - UpperPanel.Height;
    RenderWidth := ClientWidth - LeftPanel.Width
  end
  else
  begin
    RenderHeight := ClientHeight;
    RenderWidth := ClientWidth;
  end;
  SetUniform;
  glViewport(0, 0, RenderWidth, RenderHeight);
  Render;
end;

procedure TMainForm.FracParamInit(const Names, startVal: tConstNameArr);
var
  i: tConsts;
begin
  for i := Low(Names) to E do
    if Names[i] <> '' then
    begin
      ConstantsPtrArr[i].Visible := true;
      ConstantsPtrArr[i].EditLabel.Caption := Names[i];
      ConstantsPtrArr[i].Text := startVal[i]
    end
    else
      ConstantsPtrArr[i].Visible := false;
end;

procedure TMainForm.FractalTypeChange(Sender: TObject);
var
  i: tConsts;
  Names, startVal: tConstNameArr;
begin
  for i := Low(Names) to High(Names) do
  begin
    Names[i] := '';
    startVal[i] := '';
  end;
  Fractal := tFracType(FractalType.ItemIndex + 1);
  case Fractal of
    Mandelbulb:
      begin
        RO := Vector3f.Create(0.0, 0.0, -2.0);
        Names[A] := 'Power';
        startVal[A] := '8';
      end;
    Mandelbox:
      begin
        IterationsNumber.ItemIndex := 2;
        RO := Vector3f.Create(0.0, 0.0, -10.0);
        Names[A] := 'Scale(>1)';
        startVal[A] := '2';
        Names[B] := 'Folding limit(<= 1)';
        startVal[B] := '1';
        Names[C] := 'Fixed radius';
        startVal[C] := '1';
        Names[D] := 'Min radius';
        startVal[D] := '-1';
      end;
    JuliaSet:
      begin
        RO := Vector3f.Create(0.0, 0.0, -2.0);
        Names[A] := '4th component';
        startVal[A] := '0';
        ConstantX.Text := '1';
        ConstantY.Text := '1';
        ConstantZ.Text := '1';
      end;
    SerpinskyTetrahidron:
      begin
        RO := Vector3f.Create(0.0, 0.0, -3.0);
        IterationsNumber.ItemIndex := 3;
        Names[A] := 'Scale(>1)';
        startVal[A] := '2';
      end;
  end;
  case tFracType(FractalType.ItemIndex + 1) of
    SerpinskyTetrahidron:
      begin
        for i := X to Z do
          ConstantsPtrArr[i].Enabled := false;
      end;
  else
    begin
      for i := X to Z do
        ConstantsPtrArr[i].Enabled := true;
    end;
  end;
  FracParamInit(Names, startVal);

end;


procedure TMainForm.GUIOnExit(Sender: TObject);
begin
  ReRenderButton.SetFocus;
end;

procedure TMainForm.HelpActionExecute(Sender: TObject);
begin
  MessageDlg((
  'You can use "W", "A", "S", "D", "Shift", "Space" to move around.' + #13 + #10 +
  'To look around use mouse with rigth mouse button pressed.' + #13 + #10 +
  'Iterations is how many times formula would calculate itself.' + #13 + #10 +
  'Epsilon is accuracy of calculations.' + #13 + #10 +
  'You can choose one of 4 formulas to work with.' + #13 + #10 +
  'Constant is a three dimentional number which will be added to formula.' + #13 + #10 +
  'And other parameters there for variety.'+ #13 + #10 +
  'When you define all the parameters click RENDER button to see the result.'+ #13 + #10 +
  'Enjoy!'),
        mtInformation, [mbOK], 0);
end;

procedure TMainForm.Move;
var
  Accseleration: Vector3f;
begin

  Accseleration := Vector3f.Create(0.0);
  if Hi(GetKeyState(Ord('W'))) <> 0 then
  begin
    Accseleration.SetX(Speed);
  end;
  if Hi(GetKeyState(Ord('S'))) <> 0 then
  begin
    Accseleration.SetX(-Speed);
  end;
  if Hi(GetKeyState(Ord('D'))) <> 0 then
  begin
    Accseleration.SetY(Speed);
  end;
  if Hi(GetKeyState(Ord('A'))) <> 0 then
  begin
    Accseleration.SetY(-Speed);
  end;
  if Hi(GetKeyState(VK_SPACE)) <> 0 then
  begin
    Accseleration.SetZ(Speed);
  end;
  if Hi(GetKeyState(VK_SHIFT)) <> 0 then
  begin
    Accseleration.SetZ(-Speed);
  end;
  RO.Sum(Multiply(RD, Accseleration.GetX));
  RO.Sum(Multiply(RR, -Accseleration.GetY));
  RO.Sum(Multiply(RU, Accseleration.GetZ));

end;

procedure TMainForm.NewActionExecute(Sender: TObject);
begin
  IterationsNumber.ItemIndex := 0;
  Epsilon.ItemIndex := 0;
  FractalTypeChange(Sender);
  ReRender(Sender);
end;

procedure TMainForm.SetView;
begin
  RD := Vector3f.Create(0, 0, 1);
  RD.GetXRotation(-yAng);
  RD.GetYRotation(-xAng);
  RD.Normalize;
  RR := Vector3f.Create(RD);
  RR.Multiply90D;
  RR.Normalize;
  RU := Cross(RD, RR);

  RU.Normalize;
end;

procedure TMainForm.UndoActionExecute(Sender: TObject);
begin
  if ParamList.prev then
  begin
    LoadParams(ParamList.GetValOnPtr);

    Fractal := tFracType(FractalType.ItemIndex + 1);
    SetUniform;
    RedoOption.Enabled := true;
    if not ParamList.prev then
      UndoOption.Enabled := false
    else
      ParamList.next;
  end;
end;

procedure TMainForm.MouseHandle;
var
  mouse: TMouse;
  dx, dy: GLDouble;
begin
  dx := (mouse.CursorPos.X - X0) / ClientWidth;
  dy := (mouse.CursorPos.Y - Y0) / ClientHeight;
  xAng := xAng + dx * MouseSensivity;
  yAng := yAng + dy * MouseSensivity;

  if xAng > Pi * 2 then
    xAng := xAng - 2 * Pi;
  if xAng < -Pi * 2 then
    xAng := xAng + 2 * Pi;

  if yAng > Pi / 2 then
    yAng := Pi / 2;
  if yAng < -Pi / 2 then
    yAng := -Pi / 2;

  glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar('u_rotateX')), xAng);
  glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar('u_rotateY')), yAng);

  SetCursorPos(Trunc(X0), Trunc(Y0));
end;

procedure TMainForm.RedoActionExecute(Sender: TObject);
begin
  if ParamList.next then
  begin
    LoadParams(ParamList.GetValOnPtr);
    Fractal := tFracType(FractalType.ItemIndex + 1);
    SetUniform;
    UndoOption.Enabled := true;
    if not ParamList.next then
      RedoOption.Enabled := false
    else
      ParamList.prev;
  end;
end;

procedure TMainForm.Render;
begin

  glBindVertexArray(vao);
  glDrawArrays(GL_QUADS, 0, 4);
  glBindVertexArray(0);

  if Hi(GetKeyState(VK_UP)) <> 0 then
    zoom := zoom + Speed;
  if Hi(GetKeyState(VK_DOWN)) <> 0 then
    zoom := zoom - Speed;
  if leftMouseButtonPressed then
    MouseHandle;

  glUniform1f(glGetUniformLocation(ProgramOBJ, PGLChar('u_zoom')), zoom);

  SetView;
  // glUniform3f(glGetUniformLocation(ProgramOBJ, PGLChar('u_RayDirection')
  // ), RD.GetX, RD.GetY, RD.GetZ);
  // glUniform3f(glGetUniformLocation(ProgramOBJ, PGLChar('u_RayRight')
  // ), RR.GetX, RR.GetY, RR.GetZ);
  // glUniform3f(glGetUniformLocation(ProgramOBJ, PGLChar('u_RayUp')
  // ), RU.GetX, RU.GetY, RU.GetZ);
  if not BlockMovement then
  begin
    Move;
    glUniform3f(glGetUniformLocation(ProgramOBJ, PGLChar('u_RayOrigin')), RO.GetX,
      RO.GetY, RO.GetZ);
  end;

  SwapBuffers(DC);
end;

procedure TMainForm.ReRender(Sender: TObject);
var
  Params : tSceneParam;
begin
  Fractal := tFracType(FractalType.ItemIndex + 1);
  SaveParams(Params);
  ParamList.AddElem(Params);
  RedoOption.Enabled := false;
  UndoOption.Enabled := true;
  SetUniform;
end;

procedure TMainForm.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  StartTime := GetTickCount;
  Render;
  DrawTime := GetTickCount - StartTime;
  inc(TimeCount, DrawTime);
  inc(FrameCount);

  if TimeCount >= 1000 then
  begin
    Frames := FrameCount;
    TimeCount := TimeCount - 1000;
    FrameCount := 0;
    Caption := InttoStr(Frames) + 'FPS';
  end;

  Done := false;
end;

end.
