unit Trans2D;
{ Преобразования на плоскости }

interface

uses
   Floats, BGL;

type

   fPoint = record
      x, y: float;
   end;
   
   fPoly = array of fPoint;

   Mat2D = array [1..3, 1..2] of float;

procedure MakeT(dx, dy: float; var T: Mat2D );
procedure MakeR(t : float; var R: Mat2D );
procedure MakeS(sx, sy: float; var S: Mat2D );

procedure Mult2D( a, b : Mat2D; var c : Mat2D );
procedure TransPoly(n: integer; Pf: fPoly; M: Mat2D; var Pi: tPoly);

procedure Translate( dx, dy : float; var A : Mat2D );
procedure Rotate( t : float; var A : Mat2D );
procedure Scale( sx, sy : float; var A : Mat2D );

{=============================================================}

implementation

procedure MakeT(dx, dy: float; var T: Mat2D);
begin
   T[1,1] := 1;   T[1,2] := 0;
   T[2,1] := 0;   T[2,2] := 1;
   T[3,1] := dx;  T[3,2] := dy;
end;

procedure MakeS(sx, sy: float; var S: Mat2D);
begin
   S[1,1] := sx;  S[1,2] := 0;
   S[2,1] := 0;   S[2,2] := sy;
   S[3,1] := 0;   S[3,2] := 0;
end;

procedure MakeR(t : float; var R : Mat2D);
var
   s, c : float;
begin
   c := cos(t);   
   s := sin(t);
   
   R[1,1] := c;   R[1,2] := s;
   R[2,1] := -s;  R[2,2] := c;
   R[3,1] := 0;   R[3,2] := 0;
end;

procedure Mult2D(a, b : Mat2D; var c : Mat2D);
begin
   c[1,1] :=  a[1,1]*b[1,1] + a[1,2]*b[2,1];
   c[1,2] :=  a[1,1]*b[1,2] + a[1,2]*b[2,2];
   c[2,1] :=  a[2,1]*b[1,1] + a[2,2]*b[2,1];
   c[2,2] :=  a[2,1]*b[1,2] + a[2,2]*b[2,2];
   c[3,1] :=  a[3,1]*b[1,1] + a[3,2]*b[2,1] + b[3,1];
   c[3,2] :=  a[3,1]*b[1,2] + a[3,2]*b[2,2] + b[3,2];
end;

procedure Translate(dx, dy: float; var A: Mat2D);
begin
   A[3,1] :=  A[3,1] + dx;
   A[3,2] :=  A[3,2] + dy;
end;

procedure Rotate(t: float; var A: Mat2D);
var
   s, c  : float;
   B     : Mat2D;
begin
   c := cos(t);
   s := sin(t);
   B := A;
   A[1,1] :=  B[1,1]*c - B[1,2]*s;
   A[1,2] :=  B[1,1]*s + B[1,2]*c;
   A[2,1] :=  B[2,1]*c - B[2,2]*s;
   A[2,2] :=  B[2,1]*s + B[2,2]*c;
   A[3,1] :=  B[3,1]*c - B[3,2]*s;
   A[3,2] :=  B[3,1]*s + B[3,2]*c;
end;

procedure Scale(sx, sy : float; var A : Mat2D);
var
   a31 : float;
begin
   A[1,1] :=  A[1,1]*sx;
   A[1,2] :=  A[1,2]*sy;
   A[2,1] :=  A[2,1]*sx;
   A[2,2] :=  A[2,2]*sy;
   a31 := A[3,1];
   A[3,1] :=  a31*sx;
   A[3,2] :=  a31*sx + A[3,2]*sy;
end;

procedure TransPoly(n: integer; Pf: fPoly; M: Mat2D; var Pi: tPoly);
var
   i     : integer;
   x, y  : float;
begin
   for i := 0 to n-1 do begin
      x := Pf[i].x;
      y := Pf[i].y;
      Pi[i].x := round(x*M[1,1] + y*M[2,1] + M[3,1]);
      Pi[i].y := round(x*M[1,2] + y*M[2,2] + M[3,2]);
   end;
end;

end.
