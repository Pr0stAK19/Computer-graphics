unit WBuffer;

interface

uses
   Display;

type
   WType = single;
   tWBuffer = array [0..Size-1] of WType;
var
   WB: tWBuffer;
   
procedure ClearWBuffer;   

{===============================================}

implementation

procedure ClearWBuffer;  
var
   i: integer; 
begin
   for i := 0 to Size-1 do
      WB[i] := 0;
end;

end.   