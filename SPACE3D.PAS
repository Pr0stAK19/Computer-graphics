unit Space3D;

interface

uses
   Floats;

type

   Point3D = record
      x, y, z : float;
   end;

   Vec3D = Point3D;

   tRay = record
      P0, delta  : Vec3D;
   end;

   tVertex = record
      p        : Point3D;
      xs, ys   : integer;
      normal   : Vec3D;
      xsf, ysf : float;
      Int      : float;
   end;

   tVertList = array of tVertex;

procedure Vector( x, y, z : float; var V : Vec3D );
procedure VAdd( a, b : Vec3D; var c : Vec3D );
procedure VSub( a, b : Vec3D; var c : Vec3D );
function ScalarProduct( a, b : Vec3D ) : float;
procedure VectorProduct( a, b : Vec3D; var c : Vec3D );
function Modul( V : Vec3D ) : float;
procedure Normalize( var V : Vec3D );
procedure Normal( var p1, p2, p3 : Point3D; var N : Vec3D );
procedure GetPoint( ray : tRay; t : float; var P : Point3D );

{=========================================================================}

implementation

procedure Vector( x, y, z : float; var V : Vec3D );
begin
   V.x := x; V.y := y; V.z := z;
end;

procedure VAdd( a, b : Vec3D; var c : Vec3D );
begin
   c.x := a.x + b.x;
   c.y := a.y + b.y;
   c.z := a.z + b.z;
end;

procedure VSub( a, b : Vec3D; var c : Vec3D );
begin
   c.x := a.x - b.x;
   c.y := a.y - b.y;
   c.z := a.z - b.z;
end;

function ScalarProduct( a, b : Vec3D ) : float;
begin
   ScalarProduct := a.x*b.x + a.y*b.y + a.z*b.z;
end;

procedure VectorProduct( a, b : Vec3D; var c : Vec3D );
begin
   c.x := a.y*b.z - a.z*b.y;
   c.y := a.z*b.x - a.x*b.z;
   c.z := a.x*b.y - a.y*b.x;
end;

function Modul( V : Vec3D ) : float;
begin
   Modul := sqrt( sqr(V.x)+sqr(V.y)+sqr(V.z));
end;

procedure Normalize( var V : Vec3D );
var
   d : float;
begin
   d := Modul(V);
   if d > 0 then begin
      V.x := V.x/d;
      V.y := V.y/d;
      V.z := V.z/d;
   end;
end;

procedure Normal( var p1, p2, p3 : Point3D; var N : Vec3D );
var
   V12, V13    : Vec3D;
begin
   VSub( p2, p1, V12 );
   VSub( p3, p1, V13 );
   VectorProduct( V12, V13, N );
end;

procedure GetPoint( ray : tRay; t : float; var P : Point3D );
begin
   p.x := ray.p0.x + t*ray.delta.x;
   p.y := ray.p0.y + t*ray.delta.y;
   p.z := ray.p0.z + t*ray.delta.z;
end;


end.
