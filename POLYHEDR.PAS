unit Polyhedr;

interface

uses
   Space3D, Trans2D, Trans3D, Facets, Floats;

type

   tPolyhedr = record
      nv    : integer;
      nf    : integer;
      V     : tVertList;
      F     : array of tFacet;
   end;

procedure MakeCube(var P : tPolyhedr);
procedure MakeTetrahedr(var P : tPolyhedr);
procedure MakeOctahedr(var P : tPolyhedr);

procedure MakePyramid(var P : tPolyhedr; n : integer);
procedure MakeTruncPyramid(var P : tPolyhedr; n : integer; e : float);
procedure MakePrism(var P : tPolyhedr; n : integer );

procedure MakeIcosahedr( var P : tPolyhedr );
procedure MakeDodecahedr( var P : tPolyhedr );
procedure MakeSphere( var P : tPolyhedr; n, m: integer );

procedure MakeTor( var P : tPolyhedr; e : float; n, m : integer );

procedure DrawWirePolyhedr( var P : tPolyhedr );
procedure DrawSolidConvexPolyhedr( var P : tPolyhedr; z0 : float );
procedure DrawSolidConvexColorPolyhedr( var P : tPolyhedr; z0 : float );
procedure DrawPolyhedrW( var P : tPolyhedr; z0 : float );
procedure DrawPolyhedrWGouraud( var P : tPolyhedr; z0 : float );


procedure TransPolyhedr(var P : tPolyhedr; var M : Mat3D);
procedure ToScreen(var P: tPolyhedr; var M : Mat2D; z0 : float);

procedure CalcNormals( var P : tPolyhedr );
procedure RotateNormals( var P : tPolyhedr; var M : Mat3D );

procedure SetPolyhedrColor(var P: tPolyhedr; kR, kG, kB, kS: float);

{=========================================================================}

implementation

uses
   BGL, Display, Utils, Light3D; 
   
procedure MakeCube(var P : tPolyhedr);
const
   a = 0.5;
begin
   with P do begin
      Nv := 8;
      Nf := 6;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);

      V[1].p.x := -a;
      V[1].p.y := -a;
      V[1].p.z := a;

      V[2].p.x := a;
      V[2].p.y := -a;
      V[2].p.z := a;

      V[3].p.x := a;
      V[3].p.y := a;
      V[3].p.z := a;

      V[4].p.x := -a;
      V[4].p.y := a;
      V[4].p.z := a;

      V[5].p.x := -a;
      V[5].p.y := -a;
      V[5].p.z := -a;

      V[6].p.x := -a;
      V[6].p.y := a;
      V[6].p.z := -a;

      V[7].p.x := a;
      V[7].p.y := a;
      V[7].p.z := -a;

      V[8].p.x := a;
      V[8].p.y := -a;
      V[8].p.z := -a;

      F[1].nv := 4;
      SetLength(F[1].v, F[1].nv+1);
      
      F[1].v[1] := 1;
      F[1].v[2] := 2;
      F[1].v[3] := 3;
      F[1].v[4] := 4;

      F[2].nv := 4;
      SetLength(F[2].v, F[2].nv+1);
      
      F[2].v[1] := 5;
      F[2].v[2] := 6;
      F[2].v[3] := 7;
      F[2].v[4] := 8;

      F[3].nv := 4;
      SetLength(F[3].v, F[3].nv+1);
      
      F[3].v[1] := 4;
      F[3].v[2] := 3;
      F[3].v[3] := 7;
      F[3].v[4] := 6;

      F[4].nv := 4;
      SetLength(F[4].v, F[4].nv+1);
      
      F[4].v[1] := 1;
      F[4].v[2] := 5;
      F[4].v[3] := 8;
      F[4].v[4] := 2;

      F[5].nv := 4;
      SetLength(F[5].v, F[5].nv+1);
      
      F[5].v[1] := 2;
      F[5].v[2] := 8;
      F[5].v[3] := 7;
      F[5].v[4] := 3;

      F[6].nv := 4;
      SetLength(F[6].v, F[6].nv+1);
      
      F[6].v[1] := 1;
      F[6].v[2] := 4;
      F[6].v[3] := 6;
      F[6].v[4] := 5;
   end;
end;
  

procedure MakeTor( var P : tPolyhedr; e : float; n, m : integer );
var
   a           : float;
   r1, r2      : float;
   i, j, k     : integer;
   fi, dfi     : float;
   psi, dpsi   : float;
begin
   a := sqrt(3)/2;
   r2 := a/((e+1)/(1-e)+1);
   r1 := r2*(e+1)/(1-e);
   with P do begin
      Nv := n*m;
      Nf := m*n;
      
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);

      k := 0;
      dfi := 2*Pi/n;
      dpsi := 2*Pi/m;
      fi := 0;
      for i := 1 to n do begin
         psi := 0;
         for j := 1 to m do begin
            k := k+1;
            V[k].p.x := (r1+r2*cos(psi))*cos(fi);
            V[k].p.y := r2*sin(psi);
            V[k].p.z := -(r1+r2*cos(psi))*sin(fi);;
            psi := psi + dpsi;
         end;
         fi := fi + dfi;
      end;

      k := 0;
      for i := 1 to n do begin
         for j := 1 to m do begin
            k := k+1;
            F[k].nv := 4;
            SetLength(F[k].v, F[k].nv+1);
            
            if j < m then begin
               F[k].v[1] := (i-1)*m + j;
               F[k].v[4] := (i-1)*m + j + 1;
               end
            else begin
               F[k].v[1] := (i-1)*m + j;
               F[k].v[4] := (i-1)*m + 1;
            end;
            if i < n then begin
               F[k].v[2] := F[k].v[1] + m;
               F[k].v[3] := F[k].v[4] + m;
               end
            else if j < m then begin
               F[k].v[2] := j;
               F[k].v[3] := j + 1;
               end
            else begin
               F[k].v[2] := m;
               F[k].v[3] := 1;
            end;
         end;
      end;
   end;
end;

procedure MakeTetrahedr( var P : tPolyhedr );
const
   a = 0.5;
begin
   with P do begin
      Nv := 4;
      Nf := 4;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);


      V[1].p.x := a;
      V[1].p.y := a;
      V[1].p.z := a;

      V[2].p.x := -a;
      V[2].p.y := a;
      V[2].p.z := -a;

      V[3].p.x := -a;
      V[3].p.y := -a;
      V[3].p.z := a;

      V[4].p.x := a;
      V[4].p.y := -a;
      V[4].p.z := -a;

      F[1].nv := 3;
      SetLength(F[1].v, F[1].nv+1);
      
      F[1].v[1] := 1;
      F[1].v[2] := 2;
      F[1].v[3] := 3;

      F[2].nv := 3;
      SetLength(F[2].v, F[2].nv+1);
      
      F[2].v[1] := 1;
      F[2].v[2] := 3;
      F[2].v[3] := 4;

      F[3].nv := 3;
      SetLength(F[3].v, F[3].nv+1);
      
      F[3].v[1] := 1;
      F[3].v[2] := 4;
      F[3].v[3] := 2;

      F[4].nv := 3;
      SetLength(F[4].v, F[4].nv+1);
      
      F[4].v[1] := 3;
      F[4].v[2] := 2;
      F[4].v[3] := 4;

   end;
end;


procedure MakeOctahedr( var P : tPolyhedr );
var
   a : float;
begin
   a := sqrt(3)/2;
   with P do begin
      Nv := 6;
      Nf := 8;

      SetLength(V, Nv+1);
      SetLength(F, Nf+1);

      V[1].p.x := 0;
      V[1].p.y := 0;
      V[1].p.z := a;

      V[2].p.x := a;
      V[2].p.y := 0;
      V[2].p.z := 0;

      V[3].p.x := 0;
      V[3].p.y := a;
      V[3].p.z := 0;

      V[4].p.x := -a;
      V[4].p.y := 0;
      V[4].p.z := 0;

      V[5].p.x := 0;
      V[5].p.y := 0;
      V[5].p.z := -a;

      V[6].p.x := 0;
      V[6].p.y := -a;
      V[6].p.z := 0;

      F[1].nv := 3;
      SetLength(F[1].v, F[1].nv+1);
      
      F[1].v[1] := 1;
      F[1].v[2] := 2;
      F[1].v[3] := 3;

      F[2].nv := 3;
      SetLength(F[2].v, F[2].nv+1);
      
      F[2].v[1] := 1;
      F[2].v[2] := 3;
      F[2].v[3] := 4;

      F[3].nv := 3;
      SetLength(F[3].v, F[3].nv+1);
      
      F[3].v[1] := 4;
      F[3].v[2] := 3;
      F[3].v[3] := 5;

      F[4].nv := 3;
      SetLength(F[4].v, F[4].nv+1);
      
      F[4].v[1] := 3;
      F[4].v[2] := 2;
      F[4].v[3] := 5;

      F[5].nv := 3;
      SetLength(F[5].v, F[5].nv+1);
      
      F[5].v[1] := 1;
      F[5].v[2] := 6;
      F[5].v[3] := 2;

      F[6].nv := 3;
      SetLength(F[6].v, F[6].nv+1);
      
      F[6].v[1] := 1;
      F[6].v[2] := 4;
      F[6].v[3] := 6;

      F[7].nv := 3;
      SetLength(F[7].v, F[7].nv+1);
      
      F[7].v[1] := 6;
      F[7].v[2] := 4;
      F[7].v[3] := 5;

      F[8].nv := 3;
      SetLength(F[8].v, F[8].nv+1);
      
      F[8].v[1] := 6;
      F[8].v[2] := 5;
      F[8].v[3] := 2;

   end;
end;

procedure MakePyramid( var P : tPolyhedr; n : integer );
const
   r = 0.5;
   h = 1;
var
   i        : integer;
   df, fi   : float;
begin
   with P do begin
      Nv := n+1;
      Nf := n+1;

      SetLength(V, Nv+1);
      SetLength(F, Nf+1);
      
      { Вершины на основании }
         df := 2*Pi/n;
         fi := 0;
         for i := 1 to n do begin
            V[i].p.x := r*cos(fi);
            V[i].p.z := r*sin(fi);
            V[i].p.y := -h/3;
            fi := fi+df;
         end;

      { Вершина }
         V[n+1].p.x := 0;
         V[n+1].p.y := 2*h/3;
         V[n+1].p.z := 0;

      { Донышко }
         F[n+1].nv := n;
         SetLength(F[n+1].v, F[n+1].nv+1);
         

      { Боковые грани }
         for i := 1 to n do begin
            F[i].nv := 3;
            SetLength(F[i].v, F[i].nv + 1);
            if i < n then
               F[i].v[1] := i+1
            else
               F[i].v[1] := 1;
            F[i].v[2] := i;
            F[i].v[3] := n+1;
         end;

   end;
end;

procedure MakeTruncPyramid( var P : tPolyhedr; n : integer; e : float );
const
   r = 0.5;
   h = 1;
var
   i        : integer;
   df, fi   : float;
begin
   with P do begin
      Nv := 2*n;
      Nf := n+2;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);
      
      { Вершины }
         df := 2*Pi/n;
         fi := 0;
         for i := 1 to n do begin
            V[i].p.x := r*cos(fi);
            V[i].p.z := r*sin(fi);
            V[i].p.y := -h/2;
            V[i+n].p.x := e*V[i].p.x;
            V[i+n].p.z := e*V[i].p.z;
            V[i+n].p.y := h/2;
            fi := fi+df;
         end;

      { Донышки }
         F[n+1].nv := n;
         SetLength(F[n+1].v, F[n+1].nv + 1);
         
         F[n+2].nv := n;
         SetLength(F[n+2].v, F[n+2].nv + 1);

         for i := 1 to n do begin
            F[n+1].v[i] := i;       { нижнее  }
            F[n+2].v[i] := 2*n-i+1;   { верхнее }
         end;

      { Боковые грани }
         for i := 1 to n do begin
            F[i].nv := 4;
            SetLength(F[i].v, F[i].nv + 1);
            

            F[i].v[1] := i;
            F[i].v[2] := i+n;

            if i < n then begin
               F[i].v[3] := i+n+1;
               F[i].v[4] := i+1;
               end
            else begin
               F[i].v[3] := n+1;
               F[i].v[4] := 1
            end;
         end;

   end;
end;

procedure MakePrism( var P : tPolyhedr; n : integer );
const
   r = 0.5;
   h = 1;
var
   i        : integer;
   df, fi   : float;
begin
   with P do begin
      Nv := 2*n;
      Nf := n+2;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);
      
      { Вершины }
         df := 2*Pi/n;
         fi := 0;
         for i := 1 to n do begin
            V[i].p.x := r*cos(fi);
            V[i].p.z := r*sin(fi);
            V[i].p.y := -h/2;
            V[i+n].p.x := V[i].p.x;
            V[i+n].p.z := V[i].p.z;
            V[i+n].p.y := h/2;
            fi := fi+df;
         end;

      { Донышки }
         F[n+1].nv := n;
         SetLength(F[n+1].v, F[n+1].nv + 1);
         
         F[n+2].nv := n;
         SetLength(F[n+2].v, F[n+2].nv + 1);
         
         for i := 1 to n do begin
            F[n+1].v[i] := i;       { нижнее  }
            F[n+2].v[i] := 2*n-i+1;   { верхнее }
         end;

      { Боковые грани }
         for i := 1 to n do begin
            F[i].nv := 4;
            SetLength(F[i].v, F[i].nv + 1);
            

            F[i].v[1] := i;
            F[i].v[2] := i+n;

            if i < n then begin
               F[i].v[3] := i+n+1;
               F[i].v[4] := i+1;
               end
            else begin
               F[i].v[3] := n+1;
               F[i].v[4] := 1
            end;
         end;

   end;
end;

procedure MakeIcosahedr( var P : tPolyhedr );
var
   i           : integer;
   df, f1, f2  : float;
   a           : float;
begin
   a := sqrt(3/5);
   with P do begin
      Nv := 12;
      Nf := 20;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);
      
      { Вершины }
         df := 2*Pi/5;
         f1 := 0;
         f2 := df/2;
         for i := 1 to 5 do begin
            V[2*i-1].p.z := a*cos(f1);
            V[2*i-1].p.x := a*sin(f1);
            V[2*i-1].p.y := a/2;

            V[2*i].p.z := a*cos(f2);
            V[2*i].p.x := a*sin(f2);
            V[2*i].p.y := -a/2;

            f1 := f1+df;
            f2 := f2+df;
         end;

         V[11].p.x := 0;
         V[11].p.z := 0;
         V[11].p.y := a*sqrt(5)/2;

         V[12].p.x := 0;
         V[12].p.z := 0;
         V[12].p.y := -a*sqrt(5)/2;

      { Боковые грани }
         for i := 1 to 8 do begin
            F[i].nv := 3;
            SetLength(F[i].v, F[i].nv + 1);
            
            if odd(i) then begin
               F[i].v[1] := i;
               F[i].v[2] := i+1;
               F[i].v[3] := i+2;
               end
            else begin
               F[i].v[1] := i;
               F[i].v[2] := i+2;
               F[i].v[3] := i+1;
            end
         end;
         F[9].nv := 3;
         SetLength(F[9].v, F[9].nv + 1);
         
         F[9].v[1] := 9;
         F[9].v[2] := 10;
         F[9].v[3] := 1;

         F[10].nv := 3;
         SetLength(F[10].v, F[10].nv + 1);
         
         F[10].v[1] := 10;
         F[10].v[2] := 2;
         F[10].v[3] := 1;

      { Крышки }
         for i := 11 to 14 do begin
            F[i].nv := 3;
            SetLength(F[i].v, F[i].nv + 1);
            
            F[i].v[1] := 2*(i-10)-1;
            F[i].v[2] := 2*(i-10)+1;
            F[i].v[3] := 11;
         end;
         F[15].nv := 3;
         SetLength(F[15].v, F[15].nv + 1);
         
         F[15].v[1] := 9;
         F[15].v[2] := 1;
         F[15].v[3] := 11;

         for i := 16 to 19 do begin
            F[i].nv := 3;
            SetLength(F[i].v, F[i].nv + 1);
            
            F[i].v[1] := 2*(i-15);
            F[i].v[2] := 12;
            F[i].v[3] := 2*(i-15)+2;
         end;
         F[20].nv := 3;
         SetLength(F[20].v, F[20].nv + 1);
         
         F[20].v[1] := 10;
         F[20].v[2] := 12;
         F[20].v[3] := 2;
   end;
end;

procedure MakeDodecahedr( var P : tPolyhedr );
var
   i, j        : integer;
   Ico         : tPolyhedr;
   Sx, Sy, Sz  : float;
   a           : float;
begin
   with P do begin
      MakeIcosahedr( Ico );
      Nv := 20;
      Nf := 12;
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);
      
      { Вершины }
         for i := 1 to 20 do begin
            Sx := 0;
            Sy := 0;
            Sz := 0;
            for j := 1 to 3 do begin
               Sx := Sx + Ico.V[Ico.F[i].v[j]].p.x;
               Sy := Sy + Ico.V[Ico.F[i].v[j]].p.y;
               Sz := Sz + Ico.V[Ico.F[i].v[j]].p.z;
            end;
            V[i].p.x := Sx/3;
            V[i].p.y := Sy/3;
            V[i].p.z := Sz/3;
         end;

         a := sqrt(3)/2/sqrt( sqr(V[1].p.x) + sqr(V[1].p.y) + sqr(V[1].p.z) );
         for i := 1 to 20 do begin
            V[i].p.x := a*V[i].p.x;
            V[i].p.y := a*V[i].p.y;
            V[i].p.z := a*V[i].p.z;
         end;

      { Боковые грани }
         for i := 1 to 12 do begin
            F[i].nv := 5;
            SetLength(F[i].v, F[i].nv + 1);
         end;            

         F[1].v[1] := 1;
         F[1].v[2] := 11;
         F[1].v[3] := 15;
         F[1].v[4] := 9;
         F[1].v[5] := 10;

         F[2].v[1] := 1;
         F[2].v[2] := 10;
         F[2].v[3] := 20;
         F[2].v[4] := 16;
         F[2].v[5] := 2;

         F[3].v[1] := 1;
         F[3].v[2] := 2;
         F[3].v[3] := 3;
         F[3].v[4] := 12;
         F[3].v[5] := 11;

         F[4].v[1] := 2;
         F[4].v[2] := 16;
         F[4].v[3] := 17;
         F[4].v[4] := 4;
         F[4].v[5] := 3;

         F[5].v[1] := 3;
         F[5].v[2] := 4;
         F[5].v[3] := 5;
         F[5].v[4] := 13;
         F[5].v[5] := 12;

         F[6].v[1] := 4;
         F[6].v[2] := 17;
         F[6].v[3] := 18;
         F[6].v[4] := 6;
         F[6].v[5] := 5;

         F[7].v[1] := 7;
         F[7].v[2] := 14;
         F[7].v[3] := 13;
         F[7].v[4] := 5;
         F[7].v[5] := 6;

         F[8].v[1] := 7;
         F[8].v[2] := 6;
         F[8].v[3] := 18;
         F[8].v[4] := 19;
         F[8].v[5] := 8;

         F[9].v[1] := 15;
         F[9].v[2] := 14;
         F[9].v[3] := 7;
         F[9].v[4] := 8;
         F[9].v[5] := 9;

         F[10].v[1] := 20;
         F[10].v[2] := 10;
         F[10].v[3] := 9;
         F[10].v[4] := 8;
         F[10].v[5] := 19;

         F[11].v[1] := 11;
         F[11].v[2] := 12;
         F[11].v[3] := 13;
         F[11].v[4] := 14;
         F[11].v[5] := 15;

         F[12].v[1] := 20;
         F[12].v[2] := 19;
         F[12].v[3] := 18;
         F[12].v[4] := 17;
         F[12].v[5] := 16;

   end;
end;

procedure MakeSphere( var P : tPolyhedr; n, m: integer );
var
   R           : float;
   i, j, k     : integer;
   fi, dfi     : float;
   psi, dpsi   : float;
begin
   R := sqrt(3)/2;
   with P do begin
      Nv := (n+1)*m;
      Nf := m*n;
      
      SetLength(V, Nv+1);
      SetLength(F, Nf+1);

      k := 0;
      dfi := Pi/n;
      dpsi := 2*Pi/m;
      fi := Pi/2;
      for i := 1 to n+1 do begin
         psi := 0;
         for j := 1 to m do begin
            k := k+1;
            V[k].p.x := R*cos(fi)*sin(psi);
            V[k].p.y := R*sin(fi);
            V[k].p.z := R*cos(fi)*cos(psi);
            psi := psi + dpsi;
         end;
         fi := fi - dfi;
      end;

      k := 0;
      for i := 1 to n do begin
         for j := 1 to m do begin
            k := k+1;
            F[k].nv := 4;
            SetLength(F[k].v, F[k].nv+1);
            
            if j < m then begin
               F[k].v[1] := (i-1)*m + j;
               F[k].v[4] := (i-1)*m + j + 1;
               end
            else begin
               F[k].v[1] := (i-1)*m + j;
               F[k].v[4] := (i-1)*m + 1;
            end;
            if i <= n then begin
               F[k].v[2] := F[k].v[1] + m;
               F[k].v[3] := F[k].v[4] + m;
               end
            else if j < m then begin
               F[k].v[2] := j;
               F[k].v[3] := j + 1;
               end
            else begin
               F[k].v[2] := m;
               F[k].v[3] := 1;
            end;
         end;
      end;
   end;
end;

procedure TransPolyhedr(var P : tPolyhedr; var M : Mat3D);
var
   xnew, ynew: float;
   i: integer;
begin
   for i := 1 to P.nv do 
      with P.V[i].p do begin
         xnew := x*m[1,1] + y*m[2,1] + z*m[3,1] + m[4,1];
         ynew := x*m[1,2] + y*m[2,2] + z*m[3,2] + m[4,2];
         z := x*m[1,3] + y*m[2,3] + z*m[3,3] + m[4,3];
         x := xnew;
         y := ynew;
      end;
end;

procedure DrawWirePolyhedr(var P : tPolyhedr );
var
   i, j  : integer;
begin
   for i := 1 to P.nf do begin
      for j := 1 to P.F[i].nv do begin
         pint[j-1].x := P.V[P.F[i].v[j]].xs;
         pint[j-1].y := P.V[P.F[i].v[j]].ys;
      end;
      DrawPoly(P.F[i].nv, pint);
      Line( P.V[P.F[i].v[1]].xs, P.V[P.F[i].v[1]].ys, 
            P.V[P.F[i].v[P.F[i].nv]].xs, P.V[P.F[i].v[P.F[i].nv]].ys);
   end;
   
end;

procedure DrawSolidConvexPolyhedr( var P : tPolyhedr; z0 : float );
var
   i, j  : integer;
   p1    : Point3D;
   Vis   : Vec3D;
begin
   with P do begin
      for i := 1 to nf do begin
         p1 := V[F[i].v[1]].p;
         Vis.x := -p1.x;
         Vis.y := -p1.y;
         Vis.z := z0 - p1.z;
         if ScalarProduct(Vis, F[i].normal) > 0 then begin
            for j := 1 to P.F[i].nv do begin
               pint[j-1].x := P.V[P.F[i].v[j]].xs;
               pint[j-1].y := P.V[P.F[i].v[j]].ys;
            end;
            DrawPoly(P.F[i].nv, pint); 
            Line( V[F[i].v[1]].xs, V[F[i].v[1]].ys, 
               V[F[i].v[F[i].nv]].xs, V[F[i].v[F[i].nv]].ys);
         end;
      end
   end;
end;

procedure ToScreen( var P: tPolyhedr; var M: Mat2D; z0: float );
var
   i     : integer;
   scale : float;
begin
   for i := 1 to P.nv do 
      with P.V[i] do begin
         scale := z0/(z0 - p.z);
         xsf := p.x*scale;
         ysf := p.y*scale;
         xs := round(xsf*m[1,1] + ysf*m[2,1] + m[3,1]);
         ys := round(xsf*m[1,2] + ysf*m[2,2] + m[3,2]);
      end;
end;

procedure CalcNormals( var P : tPolyhedr );
var
   i, j  : integer;
begin
   with P do begin
      for i := 1 to P.nv do
         Vector(0, 0, 0, P.V[i].normal);
      for i := 1 to Nf do begin
         Normal( V[F[i].v[1]].p, V[F[i].v[2]].p, V[F[i].v[3]].p, F[i].normal );
         Normalize(F[i].normal);
         for j := 1 to F[i].nv do 
            VAdd(P.V[F[i].v[j]].normal, F[i].normal, P.V[F[i].v[j]].normal); 
      end;
      for i := 1 to P.nv do
         Normalize(P.V[i].normal);
   end;
end;

procedure RotateNormals( var P : tPolyhedr; var M : Mat3D );
var
   i : integer;
begin
   for i := 1 to P.Nf do
      RotateVector( P.F[i].normal, M );
   for i := 1 to P.Nv do
      RotateVector( P.V[i].normal, M );
end;

procedure DrawSolidConvexColorPolyhedr( var P : tPolyhedr; z0 : float );
var
   i : integer;
begin
   for i := 1 to P.Nf do
      DrawSolidFacet(P.F[i], P.V, z0);
end;

procedure DrawPolyhedrW( var P : tPolyhedr; z0 : float );
var
   i : integer;
begin
   for i := 1 to P.Nf do
      DrawFacetW(P.F[i], P.V, z0);
end;

procedure DrawPolyhedrWGouraud( var P : tPolyhedr; z0 : float );
var
   i : integer;
   cosinus: float;
begin
   for i := 1 to P.nv do begin
      cosinus := ScalarProduct(P.V[i].normal, Light);
      if cosinus < 0 then
         P.V[i].Int := Iamb
      else
         P.V[i].Int := Iamb + Idir*cosinus;
   end;   
   for i := 1 to P.Nf do
      DrawFacetWGouraud(P.F[i], P.V, z0);
end;


procedure SetPolyhedrColor(var P: tPolyhedr; kR, kG, kB, kS: float);
var
   i: integer;
begin

   for i := 1 to P.nf do begin
      p.F[i].kR := kR;
      p.F[i].kG := kG;
      p.F[i].kB := kB;
      p.F[i].kS := kS;
   end;
      
//   for i := 1 to P.nf do begin
//      p.F[i].kR := random;
//      p.F[i].kG := random;
//      p.F[i].kB := random;
//      p.F[i].kS := kS;
//   end;
   
     
end;

end.
