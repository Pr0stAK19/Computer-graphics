unit BGL;

interface

uses
   Display, Floats;

const

   Black    = $000000;
   White    = $FFFFFF;
   Gray     = $7F7F7F;

   Red      = $FF0000;
   Green    = $00FF00;
   Blue     = $0000FF;
   
   Yellow   = $FFFF00;
   Cyan     = $00FFFF;
   Magenta  = $FF00FF;
   
   Brown    = $7F7F00;
   DarkGray = $3F3F3F;
   
   SizeX = Display.SizeX;
   SizeY = Display.SizeY;
   GetMaxX = Display.GetMaxX;
   GetMaxY = Display.GetMaxY;

   
type

   tPoint = record
      x, y : integer;
   end;

   tPoly = array of tPoint;

procedure ClearDevice;

procedure SetColor(C : tPixel);
procedure SetBkColor(C : tPixel);
procedure PutPixel( x, y : integer; C : tPixel );
function GetPixel( x, y : integer ) : tPixel;

{ Алгоритм ЦДА }
procedure Line1(x1, y1, x2, y2 : integer);

{ Алгоритм Брезенхема }
procedure Line2(x1, y1, x2, y2 : integer);

{ Алгоритм Брезенхема с вычислением адреса }
procedure Line(x1, y1, x2, y2 : integer);

procedure HLine( x1, y, x2 : integer );

procedure Circle( xc, yc, R : integer );
//procedure FillCircle( xc, yc, R : integer );

procedure FloodFill0( x, y : integer; bord : tPixel );
procedure FloodFill( x, y : integer; bord : tPixel );

procedure DrawPoly( n : integer; xy: tPoly );
procedure FillPoly( n : integer; xy: tPoly );
procedure FillConvex( n : integer; var xy: tPoly );

procedure SetViewPort( x1, y1, x2, y2 : integer);

procedure SetRGBColor(R, G, B: integer);
function GetRGBColor(R, G, B: integer): tPixel;

procedure SetGammaColor(R, G, B: float);
function GetGammaColor(R, G, B: float): tPixel;

procedure Draw;

{=======================================================================}

implementation

uses
   Floats;
   
const
   nx = 127; { SizeOf(tXList) = 2^k }
   
   MAX = 255;

type

   tXList = record
      m : integer;
      x : array[1..nx] of integer;
   end;
   tYXBuf = array [0..GetmaxY] of tXList;

   tCode = set of 0..3;
   
   tXmm = array[0..GetMaxY] of integer;

var
   CC : tPixel;
   BC : tPixel;
   
   xleft, xright  : integer;
   ytop, ybottom  : integer;
   
   GammaCurve: array [0..MAX] of integer;
   
procedure ClearDevice;

begin
   {$omp parallel for}
   for var i: integer := 0 to Size-1 do
      LB[i] := BC;
end;

procedure PutPixel(x, y : integer; C : tPixel);
begin
  LB[y*SizeX + x] := C;
end;

function GetPixel(x, y : integer) : tPixel;
begin
   GetPixel := LB[y*SizeX + x];
end;

procedure SetColor( C : tPixel );
begin
   CC := C;
end;

procedure SetBkColor( C : tPixel );
begin
   BC := C;
end;

procedure Line1( x1, y1, x2, y2 : integer );
{ Алгоритм ЦДА }
var
   dx, dy      : integer;
   x, y        : integer;
   xend, yend  : integer;
   k, xf, yf   : float;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      k := (y2-y1)/(x2-x1);
      if x1 < x2 then begin
         x := x1; yf := y1; xend := x2;
         end
      else begin
         x := x2; yf := y2; xend := x1;
         end;
      repeat
         PutPixel(x, round(yf), CC);
         x := x+1;
         yf := yf+k;
      until x>xend;
      end
   else if dy <> 0 then begin
      k := (x2-x1)/(y2-y1);
      if y1 < y2 then begin xf := x1; y := y1;  yend := y2; end
      else begin  xf := x2; y := y2; yend := y1; end;
      repeat
         PutPixel( round(xf), y, CC );
         y := y+1;
         xf := xf+k;
      until y>yend;
      end
   else
      PutPixel(x1, y1, CC);
end;

procedure Line2( x1, y1, x2, y2 : integer );
{ Алгоритм Брезенхема }
var
   x, y, xend, yend, s     : integer;
   dx, dy, d, inc1, inc2   : integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      inc1 := 2*dy;
      inc2 := 2*(dy-dx);
      d := 2*dy - dx;
      if x1 < x2 then begin
         x := x1;
         y := y1;
         xend := x2;
         if y1 < y2 then s := 1
         else s := -1;
         end
      else begin
         x := x2;
         y := y2;
         xend := x1;
         if y1 > y2 then s := 1
         else s := -1;
      end;
      PutPixel( x, y, CC );
      while x < xend do begin
         x := x + 1;
         if d>0 then begin
            y := y + s;
            d := d + inc2;
            end
         else
            d := d + inc1;
         PutPixel( x, y, CC );
      end;
      end
   else begin
      inc1 := 2*dx;
      inc2 := 2*(dx-dy);
      d := 2*dx - dy;
      if y1 < y2 then begin
         y := y1;  x := x1; yend := y2;
         if x1 < x2 then s := 1
         else s := -1;
         end
      else begin
         y := y2; x := x2; yend := y1;
         if x2 < x1 then s := 1
         else s := -1;
      end;
      PutPixel( x, y, CC);
      while y < yend do begin
         y := y + 1;
         if d>0 then begin
            x := x + s;
            d := d + inc2;
            end
         else
            d := d + inc1;
         PutPixel( x, y, CC );
      end;
   end;
end;

procedure DrawLine( x1, y1, x2, y2 : integer );
{ Алгоритм Брезенхема с вычислением адреса }
var
   dx, dy, d, inc1, inc2, s   : integer;
   a, a2                      : integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      inc1 := 2*dy;
      inc2 := 2*(dy-dx);
      d := 2*dy - dx;
      if x1 < x2 then begin
         a := SizeX*y1 + x1;
         a2 := SizeX*y2 + x2;
         if y1 < y2 then s := SizeX+1
         else s := -SizeX+1;
         end
      else begin
         a := SizeX*y2 + x2;
         a2 := SizeX*y1 + x1;
         if y1 > y2 then s := SizeX+1
         else s := -SizeX+1;
      end;
      LB[a] := CC;
      while a <> a2 do begin
         if d>0 then begin
            a := a + s;
            d := d + inc2;
            end
         else begin
            a := a + 1;
            d := d + inc1;
         end;
         LB[a] := CC;
      end;
      end
   else begin
      inc1 := 2*dx;
      inc2 := 2*(dx-dy);
      d := 2*dx - dy;
      if y1 < y2 then begin
         a := SizeX*y1 + x1;
         a2 := SizeX*y2 + x2;
         if x1 < x2 then s := SizeX+1
         else s := SizeX+-1;
         end
      else begin
         a := SizeX*y2 + x2;
         a2 := SizeX*y1 + x1;
         if x2 < x1 then s := SizeX+1
         else s := SizeX+-1;
      end;
      LB[a] := CC;
      while a <> a2 do begin
         if d>0 then begin
            a := a + s;
            d := d + inc2;
            end
         else begin
            a := a + SizeX;
            d := d + inc1;
         end;
         LB[a] := CC;
      end;
   end;
end;

procedure HLine( x1, y, x2 : integer );
begin
   if x1<x2 then
      FillLB(y*SizeX + x1, x2-x1+1, CC )
   else
      FillLB(y*SizeX + x2, x1-x2+1, CC );
end;

procedure Pixel8( xc, yc, x, y : integer);
begin
   PutPixel( xc+x, yc+y, CC );
   PutPixel( xc-x, yc+y, CC );
   PutPixel( xc-y, yc+x, CC );
   PutPixel( xc-y, yc-x, CC );
   PutPixel( xc-x, yc-y, CC );
   PutPixel( xc+x, yc-y, CC );
   PutPixel( xc+y, yc-x, CC );
   PutPixel( xc+y, yc+x, CC );
end;

procedure Circle( xc, yc, R : integer );
{ Для квадратных пикселов }
var
   d, x, y : integer;
begin
   x := 0; y := R;
   d := 3-2*R;
   Pixel8( xc, yc, 0, R );
   while x<y do begin
      if d<=0 then
         d := d + 4*x + 6
      else begin
         d := d + 4*(x-y) + 10;
         y := y-1;
      end;
      x := x+1;
      Pixel8(xc, yc, x, y);
   end;
end;

procedure FloodFill0( x, y : integer; bord : tPixel );
{ Простейший рекурсивный вариант }
begin
   if (GetPixel(x,y) <> bord) and (GetPixel(x,y) <> CC) then begin
      PutPixel(x,y, CC);
      FloodFill( x+1, y, bord );
      FloodFill( x-1, y, bord );
      FloodFill( x, y+1, bord );
      FloodFill( x, y-1, bord );
   end;
end;

procedure FloodFill( x, y : integer; bord : tPixel );
{ Построчное заполнение }
var
   xl, xr   : integer;
   y2       : integer;
begin
   xl := x;
   while GetPixel(xl,y) <> bord do
      xl := xl - 1;
   xl := xl + 1; 

   xr := x;
   while GetPixel(xr,y) <> bord do 
      xr := xr + 1;
   xr := xr - 1;

   if xl <= xr then
      HLine(xl, y, xr);
   
   y2 := y+1;
   y := y-1;
   repeat
      x := xr;
      while x >= xl do begin
         while (x>=xl) and 
            ((GetPixel(x,y) = bord) or (GetPixel(x,y) = CC)) 
         do
            x := x - 1;      
         if x >= xl then
            FloodFill(x, y, bord);
      end;
      y := y+2;
   until y>y2;
end;

procedure DrawPoly(n : integer; xy : tPoly);
var
   i  : integer;
begin
   for i:=0 to n-2 do
      Line(xy[i].x, xy[i].y, xy[i+1].x, xy[i+1].y);
end;

procedure Bresenham( x1, y1, x2, y2 : integer; var xbuf : tYXBuf );
var
   x, y, xend, yend, s     : integer;
   dx, dy, d, inc1, inc2   : integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      inc1 := 2*dy;
      inc2 := 2*(dy-dx);
      d := 2*dy - dx;
      if x1 < x2 then begin
         x := x1; y := y1; xend := x2;
         if y1 < y2 then s := 1
         else s := -1;
         end
      else begin
         x := x2; y := y2; xend := x1;
         if y1 > y2 then s := 1
         else s := -1;
      end;
      if s < 0 then begin
         INC(xbuf[y].m);
         xbuf[y].x[xbuf[y].m] := x;
      end;
      while x < xend do begin
         x := x + 1;
         if d>0 then begin
            y := y + s;
            d := d + inc2;
            INC(xbuf[y].m);
            xbuf[y].x[xbuf[y].m] := x;
            end
         else
            d := d + inc1;
      end;
      if s < 0 then DEC(xbuf[y].m);
      end
   else begin
      inc1 := 2*dx;
      inc2 := 2*(dx-dy);
      d := 2*dx - dy;
      if y1 < y2 then begin
         y := y1;  x := x1; yend := y2;
         if x1 < x2 then s := 1
         else s := -1;
         end
      else begin
         y := y2; x := x2; yend := y1;
         if x2 < x1 then s := 1
         else s := -1;
      end;
      while y < yend do begin
         y := y + 1;
         if d>0 then begin
            x := x + s;
            d := d + inc2;
            end
         else
            d := d + inc1;
         INC(xbuf[y].m);
         xbuf[y].x[xbuf[y].m] := x;
      end;
   end;
end;

procedure Sort( var a : tXList );
{ Сортировка вставками }
var
   i, j, y  : integer;
begin
   for i := 2 to a.m do begin
      y := a.x[i];
      j := i-1;
      while ( j>0 ) and ( y < a.x[j] ) do begin
         a.x[j+1] := a.x[j];
         j := j-1;
      end;
      a.x[j+1] := y;
   end;
end;

procedure DrawFillPoly(n : integer; xy: tPoly);
{ Построчное сканирование с обходом контура }
{ YX-алгоритм Ньюмена и Спрула }
var
   i, j, y     : integer; 
   i1, i2      : integer;
   ymin, ymax  : integer;
   xbuf        : tYXBuf;
   m           : integer;
   y1, y2      : integer;
begin
   { Поиск верхней и нижней строки }
      ymin := xy[0].y;
      ymax := ymin;
      for i := 1 to n-1 do
         if xy[i].y < ymin then
            ymin := xy[i].y
         else if xy[i].y > ymax then
            ymax := xy[i].y;
      
   for y := ymin to ymax do
      xbuf[y].m := 0;

   { Обход контура по Брезенхему }
      i1 := n-1;
      y1 := xy[i1].y;
      for i2 := 0 to n-1 do begin
         y2 := xy[i2].y;
         if  y1 <> y2 then
            Bresenham( xy[i1].x, y1, xy[i2].x, y2, xbuf );
         i1 := i2;
         y1 := y2;
      end;

   { Построчное заполнение }
      for y := ymin to ymax do begin
         Sort( xbuf[y] );
         j := 1;
         m := xbuf[y].m;
         while j < m do begin
            HLine( xbuf[y].x[j], y, xbuf[y].x[j+1] );
            j := j + 2;
         end;
      end;
   { Обрисовка контура }
      DrawPoly( n, xy );
      Line( xy[0].x, xy[0].y, xy[n-1].x, xy[n-1].y );
end;

procedure SetViewPort( x1, y1, x2, y2 : integer);
begin
   xleft := x1;
   xright := x2;
   ytop := y1;
   ybottom := y2;
end;

procedure Coding( x, y : integer; var code : tCode );
begin
   code := [];
   if x < xleft then
      code := code + [0]
   else if x > xright then
      code := code + [1];
   if y < ytop then
      code := code + [2]
   else if y > ybottom then
      code := code + [3];
end;

procedure Line( x1, y1, x2, y2 : integer );
{ Вывод отрезка с отсечением по границам поля вывода
по алгоритму Сазерленда - Коэна }
var
   code1, code2   : tCode;
   inside         : Boolean;
   x, y           : integer;
   code           : tCode;
begin
   x1 := x1 + xleft;
   x2 := x2 + xleft;
   y1 := y1 + ytop;
   y2 := y2 + ytop;
   Coding( x1, y1, code1 );
   Coding( x2, y2, code2 );
   inside := code1+code2=[];
   while not inside and ( code1*code2=[] ) do begin
      if code1 = [] then begin
         x := x1; x1 := x2; x2 := x;
         y := y1; y1 := y2; y2 := y;
         code := code1; code1 := code2; code2 := code;
      end;
      { Теперь x1, y1 - снаружи }
      if x1 < xleft then begin
         y1 := y1 + round((y2-y1)/(x2-x1)*(xleft-x1));
         x1 := xleft;
         end
      else if x1 > xright then begin
         y1 := y1 + round((y2-y1)/(x2-x1)*(xright-x1));
         x1 := xright;
         end
      else if y1 < ytop then begin
         x1 := x1 + round((x2-x1)/(y2-y1)*(ytop-y1));
         y1 := ytop;
         end
      else { y1 > ybottom } begin
         x1 := x1 + round((x2-x1)/(y2-y1)*(ybottom-y1));
         y1 := ybottom;
      end;
      Coding( x1, y1, code1 );
      inside := code1+code2 = [];
   end;
   if inside then
      DrawLine( x1, y1, x2, y2 )
end;

procedure ClipLeft(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x; y1 := p1[n-1].y;
   inside1 := x1 >= xleft;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := x2 >= xleft;
      if inside1 <> inside2 then begin
         p2[m].y := y2 + round((y1-y2)/(x1-x2)*(xleft-x2));
         p2[m].x := xleft;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m:=m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipRight(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x; y1 := p1[n-1].y;
   inside1 := x1 <= xright;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := x2 <= xright;
      if inside1 <> inside2 then begin
         p2[m].y := y2 + round((y1-y2)/(x1-x2)*(xright-x2));
         p2[m].x := xright;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m:=m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipTop(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x; y1 := p1[n-1].y;
   inside1 := y1 >= ytop;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := y2 >= ytop;
      if inside1 <> inside2 then begin
         p2[m].x := x1 + round((x2-x1)/(y2-y1)*(ytop-y1));
         p2[m].y := ytop;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m:=m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipBottom(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x;
   y1 := p1[n-1].y;
   inside1 := y1 <= ybottom;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := y2 <= ybottom;
      if inside1 <> inside2 then begin
         p2[m].x := x1 + round((x2-x1)/(y2-y1)*(ybottom-y1));
         p2[m].y := ybottom;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m := m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure FillPoly(n : integer; xy: tPoly);
{ Отсечение по алгоритму Сазерленда - Ходжмена }
{ Sutherland Ivan, E., Hodgman Gary W., Reentrant Polygon Clipping }
{ CACM, Vol 17, pp 32-42, 1974 }
var
   i        : integer;
   p1, p2   : tPoly;
   m1, m2   : integer;
begin
   p1 := new tPoint[2*n];
   p2 := new tPoint[2*n];
   for i := 0 to n-1 do begin
      p1[i].x := xy[i].x + xleft;
      p1[i].y := xy[i].y + ytop;
   end;
   ClipLeft( n, p1, m2, p2 );
   if m2 > 0 then begin
      ClipRight( m2, p2, m1, p1 );
      if m1 > 0 then begin
         ClipTop( m1, p1, m2, p2 );
         if m2 > 0 then begin
            ClipBottom( m2, p2, m1, p1 );
            if m1 > 0 then
               DrawFillPoly( m1, p1 );
         end;
      end;
   end;
end;

procedure BresenhamX(x1, y1, x2, y2: integer; var xmin, xmax: tXmm);
{ Алгоритм Брезенхема }
var
   x, y, xend, yend, s     : integer;
   dx, dy, d, inc1, inc2   : integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      inc1 := 2*dy;
      inc2 := 2*(dy-dx);
      d := 2*dy - dx;
      if x1 < x2 then begin
         x := x1;
         y := y1;
         xend := x2;
         if y1 < y2 then s := 1
         else s := -1;
         end
      else begin
         x := x2;
         y := y2;
         xend := x1;
         if y1 > y2 then s := 1
         else s := -1;
      end;
      if x < xmin[y] then xmin[y] := x;
      if x > xmax[y] then xmax[y] := x;
      while x < xend do begin
         x := x + 1;
         if d>0 then begin
            y := y + s;
            d := d + inc2;
            end
         else
            d := d + inc1;
         if x < xmin[y] then xmin[y] := x;
         if x > xmax[y] then xmax[y] := x;
      end;
      end
   else begin
      inc1 := 2*dx;
      inc2 := 2*(dx-dy);
      d := 2*dx - dy;
      if y1 < y2 then begin
         y := y1;  x := x1; yend := y2;
         if x1 < x2 then s := 1
         else s := -1;
         end
      else begin
         y := y2; x := x2; yend := y1;
         if x2 < x1 then s := 1
         else s := -1;
      end;
      if x < xmin[y] then xmin[y] := x;
      if x > xmax[y] then xmax[y] := x;
      while y < yend do begin
         y := y + 1;
         if d>0 then begin
            x := x + s;
            d := d + inc2;
            end
         else
            d := d + inc1;
         if x < xmin[y] then xmin[y] := x;
         if x > xmax[y] then xmax[y] := x;
      end;
   end;
end;

procedure DrawFillConvex( n : integer; xy: tPoly );
{ Построчное сканирование с обходом контура. }
{ Выпуклый (по Y) многоугольник }
var
   i, y        : integer;
   ymin, ymax  : integer;
   xmin, xmax  : tXmm;
   y1, y2      : integer;
begin
   { Поиск верхней и нижней строки }
      ymin := xy[0].y;
      ymax := ymin;
      for i := 1 to n-1 do
         if xy[i].y < ymin then
            ymin := xy[i].y
         else if xy[i].y > ymax then
            ymax := xy[i].y;

      if ymin < ymax then begin

         for y := ymin to ymax do begin
            xmin[y] := GetMaxX;
            xmax[y] := 0;
         end;

      { Обход контура по Брезенхему }
         for i := 0 to n-2 do begin
            y1 := xy[i].y;
            y2 := xy[i+1].y;
            if  y1 <> y2 then
               BresenhamX(xy[i].x, y1, xy[i+1].x, y2, xmin, xmax);
         end;
         if xy[0].y <> xy[n-1].y then
            BresenhamX(xy[0].x, xy[0].y, xy[n-1].x, xy[n-1].y, xmin, xmax);

      { Построчное заполнение }
         {$omp parallel for}
         for var line := ymin to ymax do
            HLine( xmin[line], line, xmax[line] );

   end;
end;

procedure FillConvex( n : integer; var xy: tPoly );
{ Отсечение по алгоритму Сазерленда - Ходжмена }
{ Sutherland Ivan, E., Hodgman Gary W., Reentrant Polygon Clipping }
{ CACM, Vol 17, pp 32-42, 1974 }
var
   i        : integer;
   p1, p2   : tPoly;
   m1, m2   : integer;
begin
   p1 := new tPoint[2*n];
   p2 := new tPoint[2*n];
   for i := 0 to n-1 do begin
      p1[i].x := xy[i].x + xleft;
      p1[i].y := xy[i].y + ytop;
   end;
   ClipLeft( n, p1, m2, p2 );
   if m2 > 0 then begin
      ClipRight( m2, p2, m1, p1 );
      if m1 > 0 then begin
         ClipTop( m1, p1, m2, p2 );
         if m2 > 0 then begin
            ClipBottom( m2, p2, m1, p1 );
            if m1 > 0 then
               DrawFillConvex( m1, p1 );
         end;
      end;
   end;
end;

procedure SetRGBColor(R, G, B: integer);
begin
   if R > 255 then R := 255;
   if G > 255 then G := 255;
   if B > 255 then B := 255;
   SetColor(R*256*256 + G*256 + B);
end;

function GetRGBColor(R, G, B: integer): tPixel;
begin
   if R > 255 then R := 255;
   if G > 255 then G := 255;
   if B > 255 then B := 255;
   GetRGBColor := R*256*256 + G*256 + B;
end;


procedure SetGammaColor(R, G, B: float);
{
const
   gamma = 2.2;
var
   Ri, Gi, Bi: integer;   
}
begin
{
   if R > 255 then R := 255;
   if G > 255 then G := 255;
   if B > 255 then B := 255;
   
   Ri := round(255*Power(R/255, 1/gamma));
   Gi := round(255*Power(G/255, 1/gamma));
   Bi := round(255*Power(B/255, 1/gamma));
}   
   SetColor(GetGammaColor(R, G, B));
end;

function GetGammaColor(R, G, B: float): tPixel;
const
   gamma = 2.2;
var
   Ri, Gi, Bi: integer;   
begin
   Ri := round(R);
   Gi := round(G);
   Bi := round(B);
   if Ri > 255 then Ri := 255;
   if Gi > 255 then Gi := 255;
   if Bi > 255 then Bi := 255;
   

//   Ri := round(255*Power(R/255, 1/gamma));
//   Gi := round(255*Power(G/255, 1/gamma));
//   Bi := round(255*Power(B/255, 1/gamma));


   Ri := GammaCurve[Ri];
   Gi := GammaCurve[Gi];
   Bi := GammaCurve[Bi];
   
   GetGammaColor := Ri*256*256+Gi*256+Bi;
end;

procedure InitGammaCurve;
const
   gamma = 2.2;
var
   i: integer;
begin
   for i := 0 to MAX do
      GammaCurve[i] := round(power(i/MAX, 1/gamma)*MAX);
end;

procedure Draw;
begin
   Display.Draw;
end;

begin
   SetColor(Black);
   SetBkColor(White);
   SetViewPort(0, 0, GetMaxX, GetMaxY);
   InitGammaCurve;
end.
