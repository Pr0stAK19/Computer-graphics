unit Facets;

interface

uses
   BGL, Space3D, Floats, Light3D;


const
   MaxVertOnFacet = 1000;

type

   tFacet = record
      nv          : integer;
      v           : array of integer;
      normal      : Vec3D;
      kR, kG, kB  : float;
      kS          : float;
   end;

var
   Pint  : tPoly;

procedure DrawSolidFacet( var F : tFacet; var VL : tVertList; z0 : float );
procedure DrawFacetW(var F : tFacet; var VL : tVertList; z0 : float );
procedure DrawFacetWGouraud(var F : tFacet; var VL : tVertList; z0 : float );

{=========================================================================}

implementation

uses
   Light3D, Utils, Display, WBuffer;
   
type
   tXW = array[0..GetMaxY] of record
      xm: integer;
      w: float;
      Int: float;
   end;

procedure DrawSolidFacet(var F : tFacet; var VL : tVertList; z0 : float );
var
   p           : Point3D;
   V        	: Vec3D;
   cosinus     : float;
   I0          : float;
   j           : integer;
begin
   p := VL[F.v[1]].p;
   V.x := -p.x;
   V.y := -p.y;
   V.z := z0 - p.z;
   if ScalarProduct( V, F.normal ) > 0 then begin
      cosinus := ScalarProduct(F.normal, Light);
      if cosinus < 0 then
         I0 := Iamb
      else
         I0 := Iamb + Idir*cosinus;
//      SetRGBColor(round(I0*F.kR), round(I0*F.kG), round(I0*F.kB));
      SetGammaColor(I0*F.kR, I0*F.kG, I0*F.kB);
      for j := 1 to F.nv do begin
         Pint[j-1].x := VL[F.v[j]].xs;
         Pint[j-1].y := VL[F.v[j]].ys;
      end;
      FillConvex(F.nv, Pint);
   end;
end;

procedure LineW(V1, V2: tVertex; var xmin, xmax: tXW; z0: float);
var
   x1, y1, x2, y2: integer;
   x, y, yend: integer;
   xf, w, dw, k: float;
begin
   x1 := V1.xs; x2 := V2.xs;
   y1 := V1.ys; y2 := V2.ys;
   if y1 < y2 then begin
      y := y1; xf := x1; yend := y2;
      w := 1/(z0 - V1.p.z);
      dw := (1/(z0 - V2.p.z) - w)/(y2 - y1);
      k := (x2-x1)/(y2-y1);
      end
   else begin
      y := y2; xf := x2; yend := y1;
      w := 1/(z0 - V2.p.z);
      if y2 <> y1 then begin
         dw := (1/(z0 - V1.p.z) - w)/(y1 - y2);
         k := (x2-x1)/(y2-y1);
      end;
   end;
      
   x := round(xf);
   
   if x < xmin[y].xm then begin
      xmin[y].xm := x; xmin[y].w := w;
   end;
   if x > xmax[y].xm then begin
      xmax[y].xm := x; xmax[y].w := w;
   end;
   
   while y < yend do begin
      y := y + 1;
      xf := xf + k;
      x := round(xf);
      w := w + dw;
      if x < xmin[y].xm then begin
         xmin[y].xm := x; xmin[y].w := w;
      end;
      if x > xmax[y].xm then begin
         xmax[y].xm := x; xmax[y].w := w;
      end;
   end;         
end;

procedure LineWGouraud(V1, V2: tVertex; var xmin, xmax: tXW; z0: float);
var
   x1, y1, x2, y2: integer;
   x, y, yend: integer;
   xf, w, dw, k: float;
   Int, dInt: float;
begin
   x1 := V1.xs; x2 := V2.xs;
   y1 := V1.ys; y2 := V2.ys;
   if y1 < y2 then begin
      y := y1; xf := x1; yend := y2;
      w := 1/(z0 - V1.p.z);
      dw := (1/(z0 - V2.p.z) - w)/(y2 - y1);
      Int := V1.Int;
      dInt := (V2.Int - Int)/(y2-y1);
      k := (x2-x1)/(y2-y1);
      end
   else begin
      y := y2; xf := x2; yend := y1;
      w := 1/(z0 - V2.p.z);
      Int := V2.Int;
      if y2 <> y1 then begin
         dw := (1/(z0 - V1.p.z) - w)/(y1 - y2);
         dInt := (V1.Int - Int)/(y1-y2);
         k := (x2-x1)/(y2-y1);
      end;
   end;
      
   x := round(xf);
   
   if x < xmin[y].xm then begin
      xmin[y].xm := x; xmin[y].w := w; xmin[y].Int := Int;
   end;
   if x > xmax[y].xm then begin
      xmax[y].xm := x; xmax[y].w := w; xmax[y].Int := Int;
   end;
   
   while y < yend do begin
      y := y + 1;
      xf := xf + k;
      x := round(xf);
      w := w + dw;
      Int := Int + dInt;
      if x < xmin[y].xm then begin
         xmin[y].xm := x; xmin[y].w := w; xmin[y].Int := Int;
      end;
      if x > xmax[y].xm then begin
         xmax[y].xm := x; xmax[y].w := w; xmax[y].Int := Int;
      end;
   end;         
end;


procedure HLineW(var xmin: tXW; y: integer; var xmax: tXW; C: tPixel);
const
   eps = 1e-7;
var
   x1, x2, dx: integer;
   w, dw: float;
   a, a2: integer;
begin
   x1 := xmin[y].xm; 
   x2 := xmax[y].xm;
   w := xmin[y].w;
   dx := x2 - x1;
   if dx <> 0 then
      dw := (xmax[y].w - w)/dx;
   a := SizeX*y + x1;
   a2 := a + dx;
   if w > WB[a] then begin
      WB[a] := w + eps;
      LB[a] := C;
   end;
   while a < a2 do begin
      a := a + 1;
      w := w + dw;
      if w > WB[a] then begin
         WB[a] := w + eps;
         LB[a] := C;
      end;
   end;

end;

procedure HLineWGouraud(var xmin: tXW; y: integer; var xmax: tXW; var F: tFacet);
const
   eps = 1e-7;
var
   x1, x2, dx: integer;
   w, dw: float;
   a, a2: integer;
   C: tPixel;
   Int, dInt: float;
begin
   x1 := xmin[y].xm; 
   x2 := xmax[y].xm;
   w := xmin[y].w;
   Int := xmin[y].Int;
   dx := x2 - x1;
   if dx <> 0 then begin
      dw := (xmax[y].w - w)/dx;
      dInt := (xmax[y].Int - Int)/dx;
   end;
   a := SizeX*y + x1;
   a2 := a + dx;
   if w > WB[a] then begin
      WB[a] := w + eps;
      C := GetGammaColor(F.kR*Int, F.kG*Int, F.kB*Int);
  //    C := GetRGBColor(round(F.kR*Int), round(F.kG*Int), round(F.kB*Int));
      LB[a] := C;
   end;
   while a < a2 do begin
      a := a + 1;
      w := w + dw;
      Int := Int + dInt;
      if w > WB[a] then begin
         WB[a] := w + eps;
         C := GetGammaColor(F.kR*Int, F.kG*Int, F.kB*Int);
  //       C := GetRGBColor(round(F.kR*Int), round(F.kG*Int), round(F.kB*Int));
         LB[a] := C;
      end;
   end;

end;


procedure FillFacetW(F: tFacet; VL: tVertList; C: tPixel; z0: float);
{ Построчное сканирование с обходом контура. }
{ Выпуклый (по Y) многоугольник }
var
   i, y        : integer;
   ymin, ymax  : integer;
   xmin, xmax  : tXW;
   V1, V2      : tVertex;
begin
   { Поиск верхней и нижней строки }
      ymin := VL[F.v[1]].ys;
      ymax := ymin;
      for i := 2 to F.nv do
         if VL[F.v[i]].ys < ymin then
            ymin := VL[F.v[i]].ys
         else if VL[F.v[i]].ys > ymax then
            ymax := VL[F.v[i]].ys;

      if ymin < ymax then begin

         for y := ymin to ymax do begin
            xmin[y].xm := GetMaxX;
            xmax[y].xm := 0;
         end;

      { Обход контура }
      
         V1 := VL[F.v[F.nv]];
         for i := 1 to F.nv do begin
            V2 := VL[F.v[i]];
            if  V1.ys <> V2.ys then
               LineW(V1, V2, xmin, xmax, z0);
            V1 := V2;
         end;
         
      { Построчное заполнение }
         { $omp parallel for}
         for var line := ymin to ymax do
            HLineW(xmin, line, xmax, C);

   end;
end;

procedure FillFacetWGouraud(var F: tFacet; var VL: tVertList; z0: float);
{ Построчное сканирование с обходом контура. }
{ Выпуклый (по Y) многоугольник }
var
   i, y        : integer;
   ymin, ymax  : integer;
   xmin, xmax  : tXW;
   y1, y2      : integer;
   //line        : integer;
begin
   { Поиск верхней и нижней строки }
      ymin := VL[F.v[1]].ys;
      ymax := ymin;
      for i := 2 to F.nv do
         if VL[F.v[i]].ys < ymin then
            ymin := VL[F.v[i]].ys
         else if VL[F.v[i]].ys > ymax then
            ymax := VL[F.v[i]].ys;

      if ymin < ymax then begin

         for y := ymin to ymax do begin
            xmin[y].xm := GetMaxX;
            xmax[y].xm := 0;
         end;

      { Обход контура, алгоритм ЦДА }
         for i := 1 to F.nv-1 do begin
            y1 := VL[F.v[i]].ys;
            y2 := VL[F.v[i+1]].ys;
            if  y1 <> y2 then
               LineWGouraud(VL[F.v[i]],VL[F.v[i+1]], xmin, xmax, z0);
         end;
         if VL[F.v[1]].ys <> VL[F.v[F.nv]].ys then
            LineWGouraud(VL[F.v[1]], VL[F.v[F.nv]], xmin, xmax, z0);

      { Построчное заполнение }
         { $omp parallel for}
         for var line := ymin to ymax do
            HLineWGouraud(xmin, line, xmax, F);

   end;
end;

procedure DrawFacetW(var F : tFacet; var VL : tVertList; z0 : float );
var
   p           : Point3D;
   V        	: Vec3D;
   cosinus     : float;
   I0          : float;
   C           : tPixel;
begin
   p := VL[F.v[1]].p;
   V.x := -p.x;
   V.y := -p.y;
   V.z := z0 - p.z;
   if ScalarProduct( V, F.normal ) > 0 then begin
      cosinus := ScalarProduct(F.normal, Light);
      if cosinus < 0 then
         I0 := Iamb
      else
         I0 := Iamb + Idir*cosinus;
         
      C := GetGammaColor(I0*F.kR, I0*F.kG, I0*F.kB);
//      C := GetRGBColor(round(I0*F.kR), round(I0*F.kG), round(I0*F.kB));
            
      FillFacetW(F, VL, C, z0);
   end;
end;

procedure DrawFacetWGouraud(var F : tFacet; var VL : tVertList; z0 : float );
var
   p           : Point3D;
   V        	: Vec3D;
begin
   p := VL[F.v[1]].p;
   V.x := -p.x;
   V.y := -p.y;
   V.z := z0 - p.z;
   if ScalarProduct( V, F.normal ) > 0 then begin
      FillFacetWGouraud(F, VL, z0);
   end;
end;


begin
   SetLength(Pint, MaxVertOnFacet);
end.
