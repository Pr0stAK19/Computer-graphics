unit Display;

interface

const

   SizeX = 640;
   SizeY = 480;

{
   SizeX = 900;
   SizeY = 600;
}
   Size = SizeX*SizeY;
   GetmaxX = SizeX-1;
   GetmaxY = SizeY-1;

type
   tPixel   = integer;
   tLBuffer = array [0..Size-1] of tPixel; 

var
   LB: tLBuffer;

procedure Draw;
procedure FillLB(start: integer; count: integer; value: tPixel);

{====================================================================}

implementation

uses
   GraphABC;
   
var
   gr:  System.Drawing.Graphics;
   bmp: System.Drawing.Bitmap;
   ptr: System.IntPtr;

procedure FillLB(start: integer; count: integer; value: tPixel);
begin
   {$omp parallel for}
   for var i := start to start+count-1 do
      LB[i] := value;
end;   

procedure Draw;
begin
   //LockDrawing;
   gr.DrawImage(bmp, 0, 0);   
end;

begin
   SetWindowSize(SizeX, SizeY);
   Window.CenterOnScreen;
   SetWindowIsFixedSize(true);
   gr := GraphWindowGraphics;   
   ptr := new System.IntPtr(@LB[0]);
   bmp := new System.Drawing.Bitmap(SizeX, SizeY, SizeX*4, System.Drawing.Imaging.PixelFormat.Format32bppRgb, ptr);  
   OnResize := Draw;
   RedrawProc := Draw;
end.
