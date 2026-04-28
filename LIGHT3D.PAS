unit Light3D;

interface

uses
   Space3D, Floats;

var
   Light: Vec3D;
   Idir : float;
   Iamb : float;

procedure SetLightDir(L : Vec3D);
procedure SetLightInt(Ia, Id : float);

{=========================================================================}

implementation

uses
   Utils;

procedure SetLightDir(L : Vec3D);
begin
   //Assert('Light3D.SetLightDir');
   Light := L;
   Normalize(Light);
end;

procedure SetLightInt(Ia, Id : float);
begin
   Iamb := Ia;
   Idir := Id;
end;

begin
   Idir := 200;
   Iamb := 55;
end.
