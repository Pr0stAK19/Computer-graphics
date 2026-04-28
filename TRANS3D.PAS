unit Trans3D;
{ Преобразования в пространстве }

interface

uses
   Floats, Space3D, Trans2D;

type
   Mat3D = array [1..4, 1..3] of float;

procedure MakeT( dx, dy, dz : float; var T : Mat3D );
procedure MakeS( sx, sy, sz : float; var S : Mat3D );
procedure MakeRx(  t : float; var R : Mat3D );
procedure MakeRy(  t : float; var R : Mat3D );
procedure MakeRz(  t : float; var R : Mat3D );

procedure RotateZ( fi : float; var a : Mat3D );
procedure RotateX( fi : float; var a : Mat3D );
procedure RotateY( fi : float; var a : Mat3D );

procedure TranslateX( d : float; var a : Mat3D );
procedure TranslateY( d : float; var a : Mat3D );
procedure TranslateZ( d : float; var a : Mat3D );

procedure Mult3D( a, b : Mat3D; var c : Mat3D );
procedure Transform( var P : Point3D; var M : Mat3D );

procedure RotateVector( var V : Vec3D; var M : Mat3D );

{=============================================================}

implementation

procedure MakeT( dx, dy, dz : float; var T : Mat3D );
begin
   T[1,1] := 1;
   T[1,2] := 0;
   T[1,3] := 0;

   T[2,1] := 0;
   T[2,2] := 1;
   T[2,3] := 0;

   T[3,1] := 0;
   T[3,2] := 0;
   T[3,3] := 1;

   T[4,1] := dx;
   T[4,2] := dy;
   T[4,3] := dz;
end;

procedure MakeS( sx, sy, sz : float; var S : Mat3D );
begin
   S[1,1] := sx;
   S[1,2] := 0;
   S[1,3] := 0;

   S[2,1] := 0;
   S[2,2] := sy;
   S[2,3] := 0;

   S[3,1] := 0;
   S[3,2] := 0;
   S[3,3] := sz;

   S[4,1] := 0;
   S[4,2] := 0;
   S[4,3] := 0;

end;

procedure MakeRx(  t : float; var R : Mat3D );
var
   s, c : float;
begin
   c := cos(t);
   s := sin(t);
   R[1,1] := 1;
   R[1,2] := 0;
   R[1,3] := 0;

   R[2,1] := 0;
   R[2,2] := c;
   R[2,3] := s;

   R[3,1] := 0;
   R[3,2] := -s;
   R[3,3] := c;

   R[4,1] := 0;
   R[4,2] := 0;
   R[4,3] := 0;

end;

procedure MakeRy(  t : float; var R : Mat3D );
var
   s, c : float;
begin
   c := cos(t);
   s := sin(t);
   R[1,1] := c;
   R[1,2] := 0;
   R[1,3] := -s;

   R[2,1] := 0;
   R[2,2] := 1;
   R[2,3] := 0;

   R[3,1] := s;
   R[3,2] := 0;
   R[3,3] := c;

   R[4,1] := 0;
   R[4,2] := 0;
   R[4,3] := 0;

end;

procedure MakeRz(  t : float; var R : Mat3D );
var
   s, c : float;
begin
   c := cos(t);
   s := sin(t);
   R[1,1] := c;
   R[1,2] := s;
   R[1,3] := 0;

   R[2,1] := -s;
   R[2,2] := c;
   R[2,3] := 0;

   R[3,1] := 0;
   R[3,2] := 0;
   R[3,3] := 1;

   R[4,1] := 0;
   R[4,2] := 0;
   R[4,3] := 0;

end;

procedure Mult3D( a, b : Mat3D; var c : Mat3D );
begin

   c[1,1] :=  a[1,1]*b[1,1] + a[1,2]*b[2,1] + a[1,3]*b[3,1];
   c[1,2] :=  a[1,1]*b[1,2] + a[1,2]*b[2,2] + a[1,3]*b[3,2];
   c[1,3] :=  a[1,1]*b[1,3] + a[1,2]*b[2,3] + a[1,3]*b[3,3];

   c[2,1] :=  a[2,1]*b[1,1] + a[2,2]*b[2,1] + a[2,3]*b[3,1];
   c[2,2] :=  a[2,1]*b[1,2] + a[2,2]*b[2,2] + a[2,3]*b[3,2];
   c[2,3] :=  a[2,1]*b[1,3] + a[2,2]*b[2,3] + a[2,3]*b[3,3];

   c[3,1] :=  a[3,1]*b[1,1] + a[3,2]*b[2,1] + a[3,3]*b[3,1];
   c[3,2] :=  a[3,1]*b[1,2] + a[3,2]*b[2,2] + a[3,3]*b[3,2];
   c[3,3] :=  a[3,1]*b[1,3] + a[3,2]*b[2,3] + a[3,3]*b[3,3];

   c[4,1] :=  a[4,1]*b[1,1] + a[4,2]*b[2,1] + a[4,3]*b[3,1] + b[4,1];
   c[4,2] :=  a[4,1]*b[1,2] + a[4,2]*b[2,2] + a[4,3]*b[3,2] + b[4,2];
   c[4,3] :=  a[4,1]*b[1,3] + a[4,2]*b[2,3] + a[4,3]*b[3,3] + b[4,3];

end;

procedure Transform( var P : Point3D; var M : Mat3D );
var
   xnew, ynew : float;
begin
   with P do begin
      xnew := x*m[1,1] + y*m[2,1] + z*m[3,1] + m[4,1];
      ynew := x*m[1,2] + y*m[2,2] + z*m[3,2] + m[4,2];
      z := x*m[1,3] + y*m[2,3] + z*m[3,3] + m[4,3];
      x := xnew;
      y := ynew;
   end;
end;

procedure RotateZ( fi : float; var a : Mat3D );
var
   si, co : float;
   x      : float;
begin
   si := sin(fi);
   co := cos(fi);
   x := a[1,1];
   a[1,1] :=  x*co - a[1,2]*si;
   a[1,2] :=  x*si + a[1,2]*co;

   x := a[2,1];
   a[2,1] :=  x*co - a[2,2]*si;
   a[2,2] :=  x*si + a[2,2]*co;

   x := a[3,1];
   a[3,1] :=  x*co - a[3,2]*si;
   a[3,2] :=  x*si + a[3,2]*co;

   x := a[4,1];
   a[4,1] :=  x*co - a[4,2]*si;
   a[4,2] :=  x*si + a[4,2]*co;
end;

procedure RotateX( fi : float; var a : Mat3D );
var
   si, co : float;
   x      : float;
begin
   si := sin(fi);
   co := cos(fi);
   x := a[1,2];
   a[1,2] :=  x*co - a[1,3]*si;
   a[1,3] :=  x*si + a[1,3]*co;

   x := a[2,2];
   a[2,2] :=  x*co - a[2,3]*si;
   a[2,3] :=  x*si + a[2,3]*co;

   x := a[3,2];
   a[3,2] :=  x*co - a[3,3]*si;
   a[3,3] :=  x*si + a[3,3]*co;

   x := a[4,2];
   a[4,2] :=  x*co - a[4,3]*si;
   a[4,3] :=  x*si + a[4,3]*co;

end;

procedure RotateY( fi : float; var a : Mat3D );
var
   si, co : float;
   x      : float;
begin
   si := sin(fi);
   co := cos(fi);

   x := a[1,1];
   a[1,1] :=  x*co + a[1,3]*si;
   a[1,3] :=  a[1,3]*co - x*si;

   x := a[2,1];
   a[2,1] :=  x*co + a[2,3]*si;
   a[2,3] :=  a[2,3]*co - x*si;

   x := a[3,1];
   a[3,1] :=  x*co + a[3,3]*si;
   a[3,3] :=  a[3,3]*co - x*si;

   x := a[4,1];
   a[4,1] :=  x*co + a[4,3]*si;
   a[4,3] :=  a[4,3]*co - x*si;
end;

procedure TranslateX( d : float; var a : Mat3D );
begin
   a[4,1] := a[4,1] + d;
end;

procedure TranslateY( d : float; var a : Mat3D );
begin
   a[4,2] := a[4,2] + d;
end;

procedure TranslateZ( d : float; var a : Mat3D );
begin
   a[4,3] := a[4,3] + d;
end;

procedure RotateVector(var V: Vec3D; var M: Mat3D);
var
   xnew, ynew : float;
begin
   with V do begin
      xnew := x*m[1,1] + y*m[2,1] + z*m[3,1];
      ynew := x*m[1,2] + y*m[2,2] + z*m[3,2];
      z := x*m[1,3] + y*m[2,3] + z*m[3,3];
      x := xnew;
      y := ynew;
   end;
end;

end.
