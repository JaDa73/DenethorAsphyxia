Unit GFX;


INTERFACE

USES crt;
CONST VGA = $A000;

TYPE Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

VAR Virscr : VirtPtr;                     { Our first Virtual screen }
    Vaddr  : word;                        { The segment of our virtual screen}

Procedure SetMCGA;
   { This procedure gets you into 320x200x256 mode. }
Procedure SetText;
   { This procedure returns you to text mode.  }
Procedure Cls (Where:word;Col : Byte);
   { This clears the screen to the specified color }
Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
Procedure ShutDown;
   { This frees the memory used by the virtual screen }
procedure flip(source,dest:Word);
   { This copies the entire screen at "source" to destination }
Procedure Pal(Col,R,G,B : Byte);
   { This sets the Red, Green and Blue values of a certain color }
Procedure GetPal(Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
procedure WaitRetrace;
   {  This waits for a vertical retrace to reduce snow on the screen }
Procedure Hline (x1,x2,y:word;col:byte;where:word);
   { This draws a horizontal line from x1 to x2 on line y in color col }
Procedure Line(a,b,c,d:integer;col:byte;where:word);
  { This draws a solid line from a,b to c,d in colour col }
Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
   { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
     in color col }
Function rad (theta : real) : real;
   {  This calculates the degrees of an angle }
Procedure Putpixel (X,Y : Integer; Col : Byte; where:word);
   { This puts a pixel on the screen by writing directly to memory. }
Function Getpixel (X,Y : Integer; where:word) :Byte;
   { This gets the pixel on the screen by reading directly to memory. }


IMPLEMENTATION

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. }
BEGIN
  asm
     mov        ax,0013h
     int        10h
  end;
END;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SetText;  { This procedure returns you to text mode.  }
BEGIN
  asm
     mov        ax,0003h
     int        10h
  end;
END;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Cls (Where:word;Col : Byte); assembler;
   { This clears the screen to the specified color }
asm
   push    es
   mov     cx, 32000;
   mov     es,[where]
   xor     di,di
   mov     al,[col]
   mov     ah,al
   rep     stosw
   pop     es
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);
END;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure ShutDown;
   { This frees the memory used by the virtual screen }
BEGIN
  FreeMem (VirScr,64000);
END;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure flip(source,dest:Word); assembler;
  { This copies the entire screen at "source" to destination }
asm
  push    ds
  mov     ax, [Dest]
  mov     es, ax
  mov     ax, [Source]
  mov     ds, ax
  xor     si, si
  xor     di, di
  mov     cx, 32000
  rep     movsw
  pop     ds
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Pal(Col,R,G,B : Byte); assembler;
  { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure GetPal(Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
Var
   rr,gg,bb : Byte;
Begin
   asm
      mov    dx,3c7h
      mov    al,col
      out    dx,al

      add    dx,2

      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   end;
   r := rr;
   g := gg;
   b := bb;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure WaitRetrace; assembler;
  {  This waits for a vertical retrace to reduce snow on the screen }
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   ax,where
  mov   es,ax
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   al,col
  mov   ah,al
  mov   cx,x2
  sub   cx,x1
  shr   cx,1
  jnc   @start
  stosb
@Start :
  rep   stosw
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Line(a,b,c,d:integer;col:byte;where:word);
  { This draws a solid line from a,b to c,d in colour col }
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     FOR i := 0 TO m DO
     BEGIN
          putpixel(a,b,col,where);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a + d1x;
               b := b + d1y;
          END
          ELSE
          BEGIN
               a := a + d2x;
               b := b + d2y;
          END;
     end;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
var
  x:integer;
  mny,mxy:integer;
  mnx,mxx,yc:integer;
  mul1,div1,
  mul2,div2,
  mul3,div3,
  mul4,div4:integer;

begin
  mny:=y1; mxy:=y1;
  if y2<mny then mny:=y2;
  if y2>mxy then mxy:=y2;
  if y3<mny then mny:=y3;
  if y3>mxy then mxy:=y3;    { Choose the min y mny and max y mxy }
  if y4<mny then mny:=y4;
  if y4>mxy then mxy:=y4;

  if mny<0 then mny:=0;
  if mxy>199 then mxy:=199;
  if mny>199 then exit;
  if mxy<0 then exit;        { Verticle range checking }

  mul1:=x1-x4; div1:=y1-y4;
  mul2:=x2-x1; div2:=y2-y1;
  mul3:=x3-x2; div3:=y3-y2;
  mul4:=x4-x3; div4:=y4-y3;  { Constansts needed for intersection calc }

  for yc:=mny to mxy do
    begin
      mnx:=320;
      mxx:=-1;
      if (y4>=yc) or (y1>=yc) then
        if (y4<=yc) or (y1<=yc) then   { Check that yc is between y1 and y4 }
          if not(y4=y1) then
            begin
              x:=(yc-y4)*mul1 div div1+x4; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y1>=yc) or (y2>=yc) then
        if (y1<=yc) or (y2<=yc) then   { Check that yc is between y1 and y2 }
          if not(y1=y2) then
            begin
              x:=(yc-y1)*mul2 div div2+x1; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y2>=yc) or (y3>=yc) then
        if (y2<=yc) or (y3<=yc) then   { Check that yc is between y2 and y3 }
          if not(y2=y3) then
            begin
              x:=(yc-y2)*mul3 div div3+x2; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y3>=yc) or (y4>=yc) then
        if (y3<=yc) or (y4<=yc) then   { Check that yc is between y3 and y4 }
          if not(y3=y4) then
            begin
              x:=(yc-y3)*mul4 div div4+x3; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if mnx<0 then
        mnx:=0;
      if mxx>319 then
        mxx:=319;          { Range checking on horizontal line }
      if mnx<=mxx then
        hline (mnx,mxx,yc,color,where);   { Draw the horizontal line }
    end;
  end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function rad (theta : real) : real;
  {  This calculates the degrees of an angle }
BEGIN
  rad := theta * pi / 180
END;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler;
  { This puts a pixel on the screen by writing directly to memory. }
Asm
  mov     ax,[where]
  mov     es,ax
  mov     bx,[X]
  mov     dx,[Y]
  mov     di,bx
  mov     bx, dx                  {; bx = dx}
  shl     dx, 8
  shl     bx, 6
  add     dx, bx                  {; dx = dx + bx (ie y*320)}
  add     di, dx                  {; finalise location}
  mov     al, [Col]
  stosb
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Getpixel (X,Y : Integer; where:word):byte; assembler;
  { This puts a pixel on the screen by writing directly to memory. }
Asm
  mov     ax,[where]
  mov     es,ax
  mov     bx,[X]
  mov     dx,[Y]
  mov     di,bx
  mov     bx, dx                  {; bx = dx}
  shl     dx, 8
  shl     bx, 6
  add     dx, bx                  {; dx = dx + bx (ie y*320)}
  add     di, dx                  {; finalise location}
  lodsb
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure LoadCEL (FileName :  string; ScrPtr : pointer);
  { This loads the cel 'filename' into the pointer scrptr }
var
  Fil : file;
  Buf : array [1..1024] of byte;
  BlocksRead, Count : word;
begin
  assign (Fil, FileName);
  reset (Fil, 1);
  BlockRead (Fil, Buf, 800);    { Read and ignore the 800 byte header }
  Count := 0; BlocksRead := $FFFF;
  while (not eof (Fil)) and (BlocksRead <> 0) do begin
    BlockRead (Fil, mem [seg (ScrPtr^): ofs (ScrPtr^) + Count], 1024, BlocksRead);
    Count := Count + 1024;
  end;
  close (Fil);
end;


BEGIN
END.