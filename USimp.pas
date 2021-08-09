
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
//-------------------------------------------------------------------------------------------------
UNIT Usimp;

interface

USES Classes, DataTypes, OptType;

type

   TSIMPS = class(TOptMethod)
   protected
      SUM,
      XREZ,
      FXREZ : array of realtype;
      A,
      X1,
      FX1   : array of array of realtype;
      K1,K2,K3,K4,INN,I,
      L,IVS,
      INDEX,KOUNT,
      NCIKL,
      KODOUT,
      NFE,stepout,iout    : Integer;
      ALFA,BETA,GAMA,
      XNX,
      SUMH,SUM2,SUMS,
      DIFER,FXMax,
      DIFERold,DIFERnew,
      SUML,STEP,EPS,
      VN,VN1,DXMMi,
      STEP1,STEP2         : RealType;
   public
     procedure InitMem(N,M: integer);override;
     procedure ExecuteStep(X,FX:PExtArr;
                 N:integer; M:integer;
                 DX:  PExtArr;
                 DXfinal:PExtArr;
                 NFEMAX: integer;
                 MinParam,MaxParam: PExtArr;
                 var NER: NativeInt;
                 var StopOpt: integer;
                 var otp_step_position: integer
                 );override;
    function    RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    procedure   RestartSave(Stream: TStream);override;
    procedure   LeaveMem;override;
   end;

//##############################################################################
implementation
//##############################################################################
function    TSIMPS.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
  var j: integer;
begin
  Result:=True;
  Stream.Read(SUM[0],Length(SUM)*SizeOfDouble);
  Stream.Read(XREZ[0],Length(XREZ)*SizeOfDouble);
  Stream.Read(FXREZ[0],Length(FXREZ)*SizeOfDouble);
  for j := 0 to Length(A) - 1 do
    Stream.Read(A[j][0],Length(A[j])*SizeOfDouble);
  for j := 0 to Length(X1) - 1 do
    Stream.Read(X1[j][0],Length(X1[j])*SizeOfDouble);
  for j := 0 to Length(FX1) - 1 do
    Stream.Read(FX1[j][0],Length(FX1[j])*SizeOfDouble);
  Stream.Read(K1,SizeOfInt);
  Stream.Read(K2,SizeOfInt);
  Stream.Read(K3,SizeOfInt);
  Stream.Read(K4,SizeOfInt);
  Stream.Read(INN,SizeOfInt);
  Stream.Read(I,SizeOfInt);
  Stream.Read(L,SizeOfInt);
  Stream.Read(IVS,SizeOfInt);
  Stream.Read(INDEX,SizeOfInt);
  Stream.Read(KOUNT,SizeOfInt);
  Stream.Read(NCIKL,SizeOfInt);
  Stream.Read(KODOUT,SizeOfInt);
  Stream.Read(NFE,SizeOfInt);
  Stream.Read(stepout,SizeOfInt);
  Stream.Read(iout,SizeOfInt);
  Stream.Read(ALFA,SizeOfDouble);
  Stream.Read(BETA,SizeOfDouble);
  Stream.Read(GAMA,SizeOfDouble);
  Stream.Read(XNX,SizeOfDouble);
  Stream.Read(SUMH,SizeOfDouble);
  Stream.Read(SUM2,SizeOfDouble);
  Stream.Read(SUMS,SizeOfDouble);
  Stream.Read(DIFER,SizeOfDouble);
  Stream.Read(FXMax,SizeOfDouble);
  Stream.Read(DIFERold,SizeOfDouble);
  Stream.Read(DIFERnew,SizeOfDouble);
  Stream.Read(SUML,SizeOfDouble);
  Stream.Read(STEP,SizeOfDouble);
  Stream.Read(EPS,SizeOfDouble);
  Stream.Read(VN,SizeOfDouble);
  Stream.Read(VN1,SizeOfDouble);
  Stream.Read(DXMMi,SizeOfDouble);
  Stream.Read(STEP1,SizeOfDouble);
  Stream.Read(STEP2,SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure   TSIMPS.RestartSave(Stream: TStream);
  var j: integer;
begin
  Stream.Write(SUM[0],Length(SUM)*SizeOfDouble);
  Stream.Write(XREZ[0],Length(XREZ)*SizeOfDouble);
  Stream.Write(FXREZ[0],Length(FXREZ)*SizeOfDouble);
  for j := 0 to Length(A) - 1 do
    Stream.Write(A[j][0],Length(A[j])*SizeOfDouble);
  for j := 0 to Length(X1) - 1 do
    Stream.Write(X1[j][0],Length(X1[j])*SizeOfDouble);
  for j := 0 to Length(FX1) - 1 do
    Stream.Write(FX1[j][0],Length(FX1[j])*SizeOfDouble);
  Stream.Write(K1,SizeOfInt);
  Stream.Write(K2,SizeOfInt);
  Stream.Write(K3,SizeOfInt);
  Stream.Write(K4,SizeOfInt);
  Stream.Write(INN,SizeOfInt);
  Stream.Write(I,SizeOfInt);
  Stream.Write(L,SizeOfInt);
  Stream.Write(IVS,SizeOfInt);
  Stream.Write(INDEX,SizeOfInt);
  Stream.Write(KOUNT,SizeOfInt);
  Stream.Write(NCIKL,SizeOfInt);
  Stream.Write(KODOUT,SizeOfInt);
  Stream.Write(NFE,SizeOfInt);
  Stream.Write(stepout,SizeOfInt);
  Stream.Write(iout,SizeOfInt);
  Stream.Write(ALFA,SizeOfDouble);
  Stream.Write(BETA,SizeOfDouble);
  Stream.Write(GAMA,SizeOfDouble);
  Stream.Write(XNX,SizeOfDouble);
  Stream.Write(SUMH,SizeOfDouble);
  Stream.Write(SUM2,SizeOfDouble);
  Stream.Write(SUMS,SizeOfDouble);
  Stream.Write(DIFER,SizeOfDouble);
  Stream.Write(FXMax,SizeOfDouble);
  Stream.Write(DIFERold,SizeOfDouble);
  Stream.Write(DIFERnew,SizeOfDouble);
  Stream.Write(SUML,SizeOfDouble);
  Stream.Write(STEP,SizeOfDouble);
  Stream.Write(EPS,SizeOfDouble);
  Stream.Write(VN,SizeOfDouble);
  Stream.Write(VN1,SizeOfDouble);
  Stream.Write(DXMMi,SizeOfDouble);
  Stream.Write(STEP1,SizeOfDouble);
  Stream.Write(STEP2,SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TSIMPS.InitMem(N,M: integer);
 var j: integer;
begin
  SetLength(X1,N + 4);
  for j := 0 to Length(X1) - 1 do SetLength(X1[j],N + 1);
  SetLength(A,N + 1);
  for j := 0 to Length(A) - 1 do SetLength(A[j],N + 1);
  SetLength(XREZ,N);
  SetLength(FXREZ,M+1);
  SetLength(FX1,N + 5);
  SetLength(SUM,N + 5);
  for j := 0 to N + 4 do SetLength(FX1[j],M + 1);
end;
//-------------------------------------------------------------------------------------------------
procedure  TSIMPS.LeaveMem;
  var j: integer;
begin
  for j := 0 to Length(X1) - 1 do SetLength(X1[j],0);
  SetLength(X1,0);
  for j := 0 to Length(A) - 1 do SetLength(A[j],0);
  SetLength(A,0);
  for j := 0 to Length(FX1) - 1 do SetLength(FX1[j],0);
  SetLength(FX1,0);
  SetLength(XREZ,0);
  SetLength(FXREZ,0);
  SetLength(SUM,0);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE  TSIMPS.ExecuteStep;

  label 25,28,38,39,11,13,17,16,14,26,100,l_exit,
        lbl_1,lbl_2,lbl_3,lbl_4,lbl_5,lbl_6,lbl_7,lbl_8,lbl_9;

  var J,K: integer;

  PROCEDURE RestrictParams(var X: array of RealType);
    var i    : integer;
  begin
    for i:=0 to N - 1 do begin
      if (X[i]<MinParam[i]) then X[i]:=MinParam[i];
      if (X[i]>MaxParam[i]) then X[i]:=MaxParam[i];
    end;
  end;

  PROCEDURE COMPPSIMP(var FX:array of RealType; NX,M,NFE,
                      NFEMAX: integer; var IEF: NativeInt);
  begin
    IEF:=0;
    if (NFE > NFEMAX) then IEF:=er_opt_MaxFunEval;
    if (FX[M]=0) or (IEF <> 0) then StopOpt:=1
  end;

begin
      //Выбор состояния перехода для функции
      case otp_step_position of
        1:  goto lbl_1;
        2:  goto lbl_2;
        3:  goto lbl_3;
        4:  goto lbl_4;
        5:  goto lbl_5;
        6:  goto lbl_6;
        7:  goto lbl_7;
        8:  goto lbl_8;
        9:  goto lbl_9;
      end;

      NCIKL:=1;
      NFE:=0;
      EPS:=1e-6;
      ALFA:=1.0;
      BETA:=0.5;
      GAMA:=2.0;
      DIFER:=0.0;
      DIFEROLD:=0.0;
      DIFERNEW:=0.0;
      iout:=0;

      XNX:=N;
      INN:=1;
      KOUNT:=0;
      SUML:=-999;

      VN:=0;
      VN1:=1e10;

      i:=0;
      while i < N do begin
        //X[i] :=  0.5 * (MaxParam[i] + MinParam[i]);
        DXMMi:=MaxParam[i]-MinParam[i];
        VN:=VN+DXMMi;
        if  VN1< DXMMi then VN1:= DXMMi;
        inc(i);
      end;
      VN:=0.2*VN/N;
      STEP:=VN;
      if VN>VN1 then  STEP:=VN1;

      stepout:=0;

      RestrictParams(X^);

      //Состояние 1
      SETOUTS(X,FX,NER);
      otp_step_position:=1;
      exit;
//##############################################################################
  lbl_1:
       GETQUAL(X,FX,NER);    { if NER<>0 then exit;}

      if StopOpt = -1 then StopOpt:=0;
      SUM[INN-1]:=FX^[M];
      FXMax:=FX^[M];
      for j:=0 to M do FX1[INN-1][j]:=FX^[j];
      Inc(NFE);
{ NEW !!!!!__________________}
    {  ’ Є в®«мЄ® ®¤Ё­ а § ЇаЁ NFE=1 }
      for j:=0 to N-1 do XREZ[j]:=X^[j];
      for j:=0 to M do FXREZ[j]:=FX^[j];
      OUT2(@XREZ[0],@FXREZ[0],N,M,NFE,stepout);
      if StopOpt = 1 then goto l_exit;
      iout:=0;
      COMPPSIMP(FXREZ,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto l_exit;
 (*  ў¬Ґбв® NCIKL ‚›‚Ћ„€’‘џ NFE !!! зЁб«® ўлзЁб«Ґ­Ё© дг­ЄжЁЁ  *)
      K1:=N+1;
      K2:=N+2;
      K3:=N+3;
      K4:=N+4;
{ NEW !!!!!__________________}
  { ‚Њ…‘’Ћ STARTSIMP(STEP,N,K1,X,X1) }
      VN:=N;
      STEP1:=STEP/(VN*sqrt(2.0))*(sqrt(VN+1.0)+VN-1.0);
      STEP2:=STEP/(VN*sqrt(2.0))*(sqrt(VN+1.0)-1.0);
      for J:=0 to N-1 do
      A[0][J]:=0;

      i:=1;
      while I < K1 do begin
         for J:=0 to N-1 do A[I][J]:=STEP2;
         L:=I-1;
         A[I][L]:=STEP1;
         inc(i);
      end;
      i:=0;
      while I < K1 do begin
         for J:=0 to N-1 do
           X1[I][J]:=X^[J]+A[I][J];
         inc(i);
      end;

  (*----------------------------------------------*)

  25:
     i:=0;
     while I < K1 do begin
      for J:=0 to N-1 do X^[J]:=X1[I][J];
      INN:=I+1;

      //Состояние 2
      SETOUTS(X,FX,NER);
      otp_step_position:=2;exit;
      lbl_2: GETQUAL(X,FX,NER);

      SUM[INN-1]:=FX^[M];
      for k:=0 to M do FX1[INN-1][k]:=FX^[k];
      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;
      inc(i);
     end;
     iout:=1;

 (* ‚›ЃЋђ ЌЂ€ЃЋ‹њ…ѓЋ ‡ЌЂ—…Ќ€џ SUM(I) B C€ЊЏ‹…Љ‘… *)
  28:
      iout:=1;
      SUMH:=SUM[0];
      INDEX:=0;
      for j:=1 to K1 - 1 do begin
         if (SUM[j]<=SUMH) then continue;
         SUMH:=SUM[j];
         INDEX:=j;
      end;
 (* ‚›ЃЋђ Њ€Ќ€ЊЂ‹њЌЋѓЋ ‡ЌЂ—…Ќ€џ  SUM(I) B C€ЊЏ‹…Љ‘… *)
      SUML:=SUM[0];
      KOUNT:=0;
      for j := 1 to K1 - 1 do begin
         if (SUML<= SUM[j]) then continue;
         SUML:=SUM[j];
         KOUNT:=j;
      end;

{ NEW !!!!!__________________}
   (*   €‘ЏЋ‹њ‡Ћ‚ЂЌ€…  DXfinal  *)
   (*  ЏђЋ‚…ђЉЂ ЌЂ ’Ћ—ЌЋ‘’њ ЋЏђ…„…‹…Ќ€џ ЏЂђЂЊ…’ђЋ‚ *)
     VN:=0;
     for J:=0 to N-1 do
      VN:=VN+abs(X1[INDEX][J]-X1[KOUNT][J])/(abs(DXfinal[J])+1.0e-30);
   (* Ґб«Ё ЇаЁа йҐ­Ёп ¬ «л, ®Є®­зЁвм Ї®ЁбЄ *)
     if  (VN<=0.01)  then begin
      NER:=er_opt_eps;
      goto l_exit;
     end;

 (* ЌЂ•Ћ†„Ќ€… –…Ќ’ђЂ ’џ†…‘’€ TO—EK C €Ќ„…Љ‘ЂЊ€,Ћ’‹€—Ќ›Њ€ Ћ’ INDEX *)
      for J:=0 to N-1 do begin
       SUM2:=0.0;
       i:=0;
       while I < K1 do begin
         SUM2:=SUM2+X1[I][J];
         inc(i);
       end;
       X1[K2-1][J]:=1.0/XNX*(SUM2-X1[INDEX][J]);
 (* ЌЂ•Ћ†„…Ќ€… Ћ’ЋЃђЂ†…Ќ€џ ’Ћ—Љ€ C ЌЂ€ЃЋ‹њ€Њ ‡ЌЂ—…Ќ€…Њ —…ђ…‡ –…Ќ’ђ *)
       X1[K3-1][J]:=(1.0+ALFA)*X1[K2-1][J]-ALFA*X1[INDEX][J];
       X^[J]:=X1[K3-1][J]
      end;

      INN:=K3;

      //Состояние 3
      SETOUTS(X,FX,NER);
      otp_step_position:=3;exit;
      lbl_3: GETQUAL(X,FX,NER);    { if NER<>0 then exit;}

      SUM[INN-1]:=FX^[M];

      i:=0;
      while i < M + 1 do begin
        FX1[INN-1][i]:=FX^[i];
        inc(i);
      end;

      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;

      if (SUM[K3-1]<SUML) then goto 11;
 (* ‚›ЃЋђ ‚’ЋђЋѓЋ ЌЂ€ЃЋ‹њ…ѓЋ ‡ЌЂ—…Ќ€џ ‚ ‘€ЊЏ‹…Љ‘… *)
      if (INDEX=0) then goto 38;
      SUMS:=SUM[0];
      goto 39;
   38:SUMS:=SUM[1];
   39:
      for j:=0 to K1-1 do begin
          if ((INDEX-j)=0) then continue;
          if (SUM[j]<=SUMS)  then continue;
          SUMS:=SUM[j]
      end;
      if (SUM[K3-1]>SUMS) then goto 13;
      goto 14;
 (* ђЂ‘’џ†…Ќ€… ”ЋђЊ› ЌЋ‚ЋѓЋ Њ€Ќ€Њ“ЊЂ, EC‹€ OTPA†…€… „Ђ‹Ћ E™E M€Ќ€ЊЊ *)
 11:  for J:=0 to N-1  do begin
       X1[K4-1][J]:=(1-GAMA)*X1[K2-1][J]+GAMA*X1[K3-1][J];
       X^[J]:=X1[K4-1][J]
      end;
      INN:=K4;

      //Состояние 4
      SETOUTS(X,FX,NER);
      otp_step_position:=4;exit;
      lbl_4: GETQUAL(X,FX,NER);

      SUM[INN-1]:=FX^[M];
      for j:=0 to M do  FX1[INN-1][j]:=FX^[j];
      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;

      if (SUM[K4-1]<SUML) then goto 16;
      goto 14;
  13: if(SUM[K3-1]>SUMH) then goto 17;
      for J:=0 to N-1 do X1[INDEX][J]:=X1[K3-1][J];
  17: for J:=0 to N-1 do begin
       X1[K4-1][J]:=BETA*X1[INDEX][J]+(1.0-BETA)*X1[K2-1][J];
       X^[J]:=X1[K4-1][J]
      end;
      INN:=K4;

      //Состояние 5
      SETOUTS(X,FX,NER);
      otp_step_position:=5;exit;
      lbl_5: GETQUAL(X,FX,NER);

      SUM[INN-1]:=FX^[M];
      for j:=0 to M do FX1[INN-1][j]:=FX^[j];
      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;

      if (SUMH>SUM[K4-1]) then goto 16;
(*  ‘†Ђ’€… ‘€ЊЏ‹…Љ‘Ђ ‚„‚Ћ… …‘‹€ Ћ’ђЂ†…Ќ€… Џђ€‚…‹Ћ Љ ’Ћ—Љ… ‘ ЃЋ‹њ€Њ
    ‡ЌЂ—…Ќ€…Њ —…Њ ЊЂЉ‘€Њ“Њ *)
      iout:=0;
      for J:=0 to N-1 do
       for k:=0 to K1-1 do
        X1[k][J]:=0.5*(X1[k][J]+X1[KOUNT][J]);
      i:=0;
      while I < K1 do begin
         for J:=0 to N-1 do X^[J]:=X1[I][J];
         INN:=I+1;

         //Состояние 6
         SETOUTS(X,FX,NER);
         otp_step_position:=6;exit;
         lbl_6: GETQUAL(X,FX,NER);

         SUM[INN-1]:=FX^[M];
         for k:=0 to M do FX1[INN-1][k]:=FX^[k];
         Inc(NFE);
         COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;
         inc(i);
     end;
     iout:=1;
     goto 26;
 16: for J:=0 to N-1 do begin
      X1[INDEX][J]:=X1[K4-1][J];
      X^[J]:=X1[INDEX][J]
     end;
     INN:=INDEX+1;

     //Состояние 7
     SETOUTS(X,FX,NER);
     otp_step_position:=7;exit;
     lbl_7: GETQUAL(X,FX,NER);

     SUM[INN-1]:=FX^[M];
     for j:=0 to M do FX1[INN-1][j]:=FX^[j];
     Inc(NFE);
     COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;
     goto 26;
  14: for J:=0 to N-1 do begin
       X1[INDEX][J]:=X1[K3-1][J];
       X^[J]:=X1[INDEX][J]
      end;
      INN:=INDEX+1;

      //Состояние 8
      SETOUTS(X,FX,NER);
      otp_step_position:=8;exit;
      lbl_8: GETQUAL(X,FX,NER);

      SUM[INN-1]:=FX^[M];
      for j:=0 to M do FX1[INN-1][j]:=FX^[j];
      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;
 26:  for J:=0 to N-1 do X^[J]:=X1[K2-1][J];
      INN:=K2;

      //Состояние 9
      SETOUTS(X,FX,NER);
      otp_step_position:=9;exit;
      lbl_9: GETQUAL(X,FX,NER);

      SUM[INN-1]:=FX^[M];
      for j:=0 to M do FX1[INN-1][j]:=FX^[j];
      Inc(NFE);
      COMPPSIMP(FX^,N,M,NFE,NFEMAX,NER);if StopOpt = 1 then goto 100;
      DIFER:=0.0;
      for j:=0 to K1-1 do DIFER:=DIFER+SQR(SUM[j]-SUM[K2-1]);
      DIFER:=1.0/XNX*sqrt(DIFER);
      DIFERold:=DIFERnew;
      DIFERnew:=DIFER;
      if (DIFERold>DIFERnew) then begin
        for j:=0 to N-1 do XREZ[j]:=X1[KOUNT][j];
        for j:=0 to M do FXREZ[j]:=FX1[KOUNT][j];
        RestrictParams(XREZ);
        if FXMax > (1+1.0e-6)*FXREZ[M] then begin
         OUT2(@XREZ[0],@FXREZ[0],N,M,NFE,stepout);
         FXMax:=FXREZ[M]
        end;
        iout:=0;
      end;
      if (DIFER<EPS) then begin
       NER:=er_opt_Eps;
       StopOpt:=1;
      end;
     Inc(NCIKL);
     goto 28;
  100:
     if (iout = 1) then begin
      SUML:=SUM[0];
      KOUNT:=0;
      for j:=1 to K4-1 do begin
         if (SUML<= SUM[j]) then continue;
         SUML:=SUM[j];
         KOUNT:=j
      end;
      for j:=0 to N-1 do XREZ[j]:=X1[KOUNT][j];
      for j:=0 to M do FXREZ[j]:=FX1[KOUNT][j];
      RestrictParams(XREZ);
      OUT2(@XREZ[0],@FXREZ[0],N,M,NFE,stepout)
     end;

   l_exit:                  //Аварийный выход из подпрограммы

     otp_step_position:=0;  //Сброс флага состояния метода оптимизации
end;
//-------------------------------------------------------------------------------------------------
END.
