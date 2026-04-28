unit Rotator;

interface

uses
   Floats, Space3D;

procedure SetCenterZ( x, y : integer );
procedure SetRadiusXY( r : float );
procedure GetRotation( var df : Vec3D );

{=========================================================================}

implementation

uses
   Mouse;

var
   xc, yc      : integer;
   Rxy         : float;
   Mx0, My0    : integer;

procedure SetCenterZ( x, y : integer );
begin
   xc := x; yc := y;
   GetMouseXY( Mx0, My0 );
end;

procedure SetRadiusXY( r : float );
begin
   Rxy := r;
   GetMouseXY( Mx0, My0 );
end;

procedure GetRotation( var df : Vec3D );
const
   dfzmax = 0.05;
var
   V        : Point3D;
   den      : float;
   Mx, My   : integer;
begin
   GetMouseXY( Mx, My );
   if LeftButtonPressed then begin
      df.y := (Mx-Mx0)/Rxy;
      df.x := (My-My0)/Rxy;
   end;
   if RightButtonPressed then begin
      V.x := Mx-Mx0;
      V.y := My-My0;
      den := (Mx0-xc)*V.y - (My0-yc)*V.x;
      if abs(den) > 1 then
         df.z := -(sqr(V.x) + sqr(V.y))/den
      else
         df.z := 0;
      if abs(df.z) > dfzmax then
         df.z := df.z/abs(df.z)*dfzmax
   end;

   Mx0 := Mx;
   My0 := My;
end;

begin
   Rxy := 100;
   Xc  := 0;
   Yc  := 0;
end.
