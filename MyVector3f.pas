unit MyVector3f;

interface
uses
  dglOpenGL;
type
  Vector3f = class;
  Matrix3f  = class
  type
    val = Vector3f;
    tElem = array[0..2] of val;
  var
    body : tElem;
    constructor Create(const vec1, vec2, vec3: Vector3f); overload;
    constructor Create(const X: val); overload;
    constructor Create(const mat : Matrix3f); overload;
  end;
  Vector3f = class
  private
    type
      val = type GLfloat;
      tElem = array[0..2] of val;
    var
      body : tElem;
  public
      constructor Create(const X1, X2, X3 : val); overload;
      constructor Create(const X : val); overload;
      constructor Create(const vec : Vector3f); overload;
      procedure Multiply(const mat : Matrix3f); overload;
      procedure Multiply(const val : val); overload;
      procedure Multiply90D;
      procedure GetXRotation(const theta : GLfloat);
      procedure GetYRotation(const theta : GLfloat);
      procedure Sum(const vec : Vector3f);
      function GetX : val;
      function GetY : val;
      function GetZ : val;
      procedure SetX(const val : val);
      procedure SetY(const val : val);
      procedure SetZ(const val : val);
      procedure Normalize;
  end;
  function Cross(const vec1, vec2 : Vector3f) : Vector3f;
  function Normalize(const vec : Vector3f) : Vector3f;
  function len(const vec : Vector3f) : GLfloat;
  function Multiply(const vec1 : Vector3f; const val : Vector3f.val) : Vector3f;
  function Sub(const vec1 : Vector3f; const val : Vector3f) : Vector3f;

implementation
  function Sub(const vec1 : Vector3f; const val : Vector3f) : Vector3f;
  begin
    Result := Vector3f.Create(vec1.body[0] - val.body[0],
                              vec1.body[1] - val.body[1],
                              vec1.body[2] - val.body[2]);
  end;
  function Multiply(const vec1 : Vector3f; const val : Vector3f.val) : Vector3f;
  begin
    Result := Vector3f.Create(vec1);
    Result.Multiply(val);
  end;
  constructor Vector3f.Create(const X1, X2, X3 : val);
  begin
    body[0] := X1;
    body[1] := X2;
    body[2] := X3;
  end;
  constructor Vector3f.Create(const X : val);
  var
    i : integer;
  begin
    for i := Low(body) to High(body) do
      body[i] := X;
  end;
  constructor Vector3f.Create(const vec : Vector3f);
  var
    i : integer;
  begin
    for i := Low(body) to High(body) do
      body[i] := vec.body[i];
  end;
  procedure Vector3f.Multiply(const mat : Matrix3f);
  var
    i, j: integer;
    temp : Vector3f;
  begin
    temp := Vector3f.Create(0,0,0);
    for i := 0 to 2 do
      for j := 0 to 2 do
        temp.body[i] := temp.body[i] + Self.body[j] * mat.body[i].body[j];
    Self := temp;
  end;
  procedure Vector3f.Multiply90D;
  var
    temp : val;
  begin
    temp := Self.body[0];
    Self.body[0] := -1 * Self.body[2];
    Self.body[1] := 0;
    Self.body[2] := temp;
  end;
  function GetXRotation(theta: GLfloat) : Matrix3f;
  var
    c, s : GLfloat;
  begin
    c := cos(theta);
    s := sin(theta);
    Result := Matrix3f.Create(Vector3f.Create(0, 0, 0),
                              Vector3f.Create(0, c, -s),
                              Vector3f.Create(0, s, c));
  end;

  function GetYRotation(theta: GLfloat) : Matrix3f;
  var
    c, s : GLfloat;
  begin
    c := cos(theta);
    s := sin(theta);
    Result := Matrix3f.Create(Vector3f.Create(c, 0, s),
                              Vector3f.Create(0, 0, 0),
                              Vector3f.Create(-s, 0, c));
  end;
  procedure Vector3f.GetXRotation(const theta : GLfloat);
  var
    c, s : GlFloat;
    temp : val;
  begin
    c := cos(theta);
    s := sin(theta);
    Self.body[0] := 0;
    temp := Self.body[1];
    Self.body[1] := c * temp + s * Self.body[2];
    Self.body[2] := -s * temp + c * Self.body[2];
  end;
  procedure Vector3f.GetYRotation(const theta : GLfloat);
  var
    c, s : GlFloat;
    temp : val;
  begin
    c := cos(theta);
    s := sin(theta);
    Self.body[1] := 0;
    temp := Self.body[0];
    Self.body[0] := temp * c + Self.body[2] * (-s);
    Self.body[2] := temp * s + Self.body[2] * c;
  end;
  function Cross(const vec1, vec2 : Vector3f) : Vector3f;
  begin
    Result := Vector3f.Create(vec1.body[1] * vec2.body[2] - vec2.body[1] * vec1.body[2],
                              vec1.body[0] * vec2.body[2] - vec2.body[0] * vec1.body[2],
                              vec1.body[0] * vec2.body[1] - vec2.body[0] * vec1.body[1]);
  end;


  function len(const vec : Vector3f) : GLfloat;
  begin
    Result := sqrt(Sqr(vec.body[0]) + Sqr(vec.body[1]) + Sqr(vec.body[2]))
  end;

  function Normalize(const vec : Vector3f) : Vector3f;
  begin
    Result := vec;
    Result.Multiply(1/len(vec));
  end;

  procedure Vector3f.Multiply(const val : val);
  var
    i : integer;
  begin
    for i := Low(Self.body) to High(Self.body) do
      Self.body[i] := Self.body[i] * val;
  end;
  procedure Vector3f.Sum(const vec : Vector3f);
  var
    i : integer;
  begin
    for i := Low(Self.body) to High(Self.body) do
      Self.body[i] := Self.body[i] + vec.body[i];
  end;
  function Vector3f.GetX : val;
  begin
    Result := Self.body[0];
  end;
  function Vector3f.GetY : val;
  begin
    Result := Self.body[1];
  end;
  function Vector3f.GetZ : val;
  begin
    Result := Self.body[2];
  end;
  procedure Vector3f.SetX(const val : val);
  begin
    Self.body[0] := val;
  end;
  procedure Vector3f.SetY(const val : val);
  begin
    Self.body[1] := val;
  end;
  procedure Vector3f.SetZ(const val : val);
  begin
    Self.body[2] := val;
  end;
  procedure Vector3f.Normalize;
  begin
    Self := MyVector3f.Normalize(Self);
  end;
  constructor Matrix3f.Create(const vec1, vec2, vec3: Vector3f);
  begin
    body[0] := vec1;
    body[1] := vec2;
    body[2] := vec3;
  end;
  constructor Matrix3f.Create(const X : val);
  var
    i : integer;
  begin
    for i := Low(body) to High(body) do
      body[i] := Vector3f.Create(X);
  end;
  constructor Matrix3f.Create(const mat : Matrix3f);
  var
    i : integer;
  begin
    for i := Low(body) to High(body) do
      body[i] := mat.body[i];
  end;
end.
