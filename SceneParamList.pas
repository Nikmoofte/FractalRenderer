unit SceneParamList;

interface

uses
  dglOpenGL;

type
  tConsts = (A = 1, B, C, D, E, X, Y, Z);
  tFracType = (Mandelbulb = 1, Mandelbox, JuliaSet, SerpinskyTetrahidron);
  tSceneParam = record
    Consts: array [tConsts] of GLfloat;
    Iterations, Epsilon: GLfloat;
    Fractal: tFracType;
    zoom: GLfloat;
  end;
  tList = class
  private
  type
    val = tSceneParam;
    elem = ^tListElem;

    tListElem = record
      next, prev: elem;
      value: val;
    end;

  var
    header: elem;
    p: elem;
  private
    procedure Delete(prevElem : elem);
  public
    constructor Create; //Конструктор
    destructor Destroy; //Деструктор
    procedure AddElem(const value: val); //Процедура добавления элемента
                                         //в конец списка
    function next: boolean; //Функция перемещающая указатель p вперёд по списку
                            //Если перемещение не возможно возвращает false
    function prev: boolean; //Функция перемещающая указатель p назад по списку
                            //Если перемещение не возможно возвращает false
    function GetValOnPtr: val; //Функция возвращающая значение ячейки, на которую
                               //указывает p
  end;

implementation


procedure tList.Delete(prevElem: tList.elem);
var
  temp : elem;
begin
  temp := prevElem^.next;
  prevElem^.next := temp^.next;
  if temp^.next <> nil then
    temp^.next^.prev := prevElem;
  Dispose(temp);
end;

constructor tList.Create;
begin
  New(header);
  header^.prev := nil;
  header^.next := nil;
  p := header;
end;

destructor  tList.Destroy;
begin
  p := header^.next;
  if p = nil then
    Dispose(header);
  while p <> nil do
  begin
    header := p;
    p := p^.next;
    Dispose(header);
  end;
end;

procedure tList.AddElem(const value: val);
var
  currElem, prevElem: elem;
begin
  if p^.next <> nil then
    Dispose(p^.next);

  New(p^.next);
  prevElem := p;
  p := p^.next;
  p^.prev := prevElem;
  p^.next := nil;
  p^.value := value;
end;

function tList.Next: boolean;
begin
  if p^.next = nil then
    result := false
  else
  begin
    p := p^.next;
    result := true;
  end;
end;

function tList.Prev: boolean;
begin
  if (p^.prev = nil) or (p^.prev = header) then
    result := false
  else
  begin
    p := p^.prev;
    result := true;
  end;
end;

function tList.GetValOnPtr: val;
begin
  result := p^.value;
end;

end.
