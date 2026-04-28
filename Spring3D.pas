program Spring3D;

uses
   Floats, BGL, Polyhedr, Trans3D, Trans2D, Space3D, Rotator, OutText, Light3D,
   WBuffer;

{ Функция генерации 3D-модели цилиндрической пружины }
procedure MakeSpring( var P : tPolyhedr; R_main, r_wire, H, Turns : float; n, m : integer );
var
   i, j, k     : integer;
   fi, dfi     : float;
   psi, dpsi   : float;
   dy, y0      : float;
   v1, v2, v3, v4 : integer;
begin
   with P do begin
      Nv := (n + 1) * m; 
      Nf := n * m + 2; { Добавляем 2 грани для торцов }
      
      SetLength(V, Nv + 1);
      SetLength(F, Nf + 1);

      dfi := 2 * Pi * Turns / n; 
      dpsi := 2 * Pi / m;        
      dy := H / n;             
      y0 := -H / 2;            

      { Генерация вершин }
      k := 1;
      for i := 0 to n do begin
         fi := i * dfi;
         for j := 0 to m - 1 do begin
            psi := j * dpsi;
            V[k].p.x := (R_main + r_wire * cos(psi)) * cos(fi);
            V[k].p.y := y0 + i * dy + r_wire * sin(psi);
            V[k].p.z := -(R_main + r_wire * cos(psi)) * sin(fi);
            k := k + 1;
         end;
      end;

      { Генерация боковых граней }
      k := 1;
      for i := 0 to n - 1 do begin
         for j := 1 to m do begin
            v1 := i * m + j;
            if j < m then v4 := i * m + j + 1 else v4 := i * m + 1;
            v2 := v1 + m;
            v3 := v4 + m;

            F[k].nv := 4;
            SetLength(F[k].v, F[k].nv + 1);
            F[k].v[1] := v1;
            F[k].v[2] := v2;
            F[k].v[3] := v3;
            F[k].v[4] := v4;
            k := k + 1;
         end;
      end;

      { Заглушка в начале }
      F[k].nv := m;
      SetLength(F[k].v, F[k].nv + 1);
      for j := 1 to m do begin
         F[k].v[j] := j;
      end;
      k := k + 1;

      { Заглушка в конце }
      F[k].nv := m;
      SetLength(F[k].v, F[k].nv + 1);
      for j := 1 to m do begin
         F[k].v[j] := (n + 1) * m - j + 1;
      end;
   end;
end;
const
   a = 100;      { Коэффициент масштабирования }
   z0 = 1600;    { Дистанция до плоскости проекции }
   
var
   Poly        : tPolyhedr;
   M, S        : Mat3D;
   M2D         : Mat2D;
   df          : Vec3D;
   Light       : Vec3D;
   
//procedure OutTextInfo;
//begin
//   OutTextXY(10, 8,  'Визуализация цилиндрической пружины');
//   OutTextXY(10, 16, 'Вращение: Зажми левую или правую кнопку мыши');
//   OutTextXY(10, 24, 'Алгоритм Z(W)-буфера, закраска Гуро');
//end;

begin
   SetTextColor(White);
   SetBkColor(DarkGray);
   SetColor(White);
   
   Light.x := 1;
   Light.y := 1;
   Light.z := 1;
   SetLightDir(Light);
   SetLightInt(50, 205);
   
   { Создаем пружину: 
     R=0.7, r=0.15, Высота=2.5, Витков=5, Шагов спирали=200, Шагов сечения=16 }
   MakeSpring(Poly, 0.7, 0.2, 3.5, 5.0, 200, 16);
   
   Trans3D.MakeS(a, a, a, S);
   TransPolyhedr(Poly, S);
   
   SetPolyhedrColor(Poly, 0.8, 0.8, 0.1, 0); 
   
   Trans2D.MakeS(1, -1, M2D);
   Trans2D.Translate(GetMaxX/2, GetMaxY/2, M2D);
   
   df.x := 0.01;
   df.y := 0.01;
   df.z := 0.00;
   
   SetRadiusXY(a);
   SetCenterZ(GetMaxX div 2, GetMaxY div 2);
   
   CalcNormals(Poly);
   
   repeat
      GetRotation(df);
      
      { Формируем матрицу вращения }
      MakeRx(df.x, M);
      RotateY(df.y, M);
      RotateZ(df.z, M);
      
      { Вращаем саму геометрию и её нормали }
      TransPolyhedr(Poly, M);
      RotateNormals(Poly, M);
      
      { Проецируем вершины на 2D экран }
      ToScreen(Poly, M2D, z0);
      
      ClearDevice;
      ClearWBuffer;
      
      DrawPolyhedrWGouraud(Poly, z0);
      
//      OutTextInfo;      
      
      Draw;
   until false;
end.