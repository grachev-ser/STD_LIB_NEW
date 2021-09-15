
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

UNIT UPoisk4;

interface

USES Classes, DataTypes, OptType;

type
   TPOISK4 = class(TOptMethod)

public

   // Выполнить шаг оптимизации
   procedure ExecuteStep( X                     : PExtArr;    // Массив выходов (параметров)
                          FX                    : PExtArr;    // Массив входов (критериев)
                          N                     : integer;    // Кол-во выходов (параметров)
                          M                     : integer;    // Кол-во входов (критериев)
                          DX                    : PExtArr;    // Текущее приращение параметра оптимизации
                          DXfinal               : PExtArr;    // Точность подбора выходов (параметров)
                          NFEMAX                : integer;    // Максимальное кол-во итераций
                          MinParam              : PExtArr;    // Минимальные значения выходов (параметров)
                          MaxParam              : PExtArr;    // Максимальные значения выходов (параметров)
                          var ErrorCode         : NativeInt;  // Код ошибки
                          var StopOpt           : integer;    // Флаг конца оптимизации
                          var otp_step_position : integer     // Состояние алгоритма оптимизации
                        ); override;

  // Инициализация памяти
  procedure InitMem(N, M: integer); override;

  // Освобождение памяти
  procedure LeaveMem; override;

  // Чтение точки рестарта блока
  function RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;

  // Запись точки рестарта блока
  procedure RestartSave(Stream: TStream);override;


protected

  // Количество итераций
  IterationNum  : integer;

  // Точка 2
  X2            : array of realtype;

  // Точка 3
  X3            : array of realtype;

  // Значение функции в точке 2
  FX2           : array of realtype;

  // Значение функции в точке 3
  FX3           : array of realtype;

  // TODO-GS: Комментарии
  S,S1             : array of array of realtype;
  A,B,C,D,GAMA,G,
  FN,G1,ALFA,
  ALAM       : realtype;
  i                : integer;

  // Алгоритм при одном оптимизируемом параметре (Алгоритм квадратичной интерполяции)
  procedure StepOneParam( X                     : PExtArr;    // Массив выходов (параметров)
                          FX                    : PExtArr;    // Массив входов (критериев)
                          N                     : integer;    // Кол-во выходов (параметров)
                          M                     : integer;    // Кол-во входов (критериев)
                          DX                    : PExtArr;    // Текущее приращение параметра оптимизации
                          DXfinal               : PExtArr;    // Точность подбора выходов (параметров)
                          NFEMAX                : integer;    // Максимальное кол-во итераций
                          MinParam              : PExtArr;    // Минимальные значения выходов (параметров)
                          MaxParam              : PExtArr;    // Максимальные значения выходов (параметров)
                          var ErrorCode         : NativeInt;  // Код ошибки
                          var StopOpt           : integer;    // Флаг конца оптимизации
                          var otp_step_position : integer     // Состояние алгоритма оптимизации
                          );

  // Алгоритм при нескольких оптимизируемых параметрах (Алгоритм преобразований вращения и растяжения-сжатия)
  procedure StepFewParam( X                     : PExtArr;    // Массив выходов (параметров)
                          FX                    : PExtArr;    // Массив входов (критериев)
                          N                     : integer;    // Кол-во выходов (параметров)
                          M                     : integer;    // Кол-во входов (критериев)
                          DX                    : PExtArr;    // Текущее приращение параметра оптимизации
                          DXfinal               : PExtArr;    // Точность подбора выходов (параметров)
                          NFEMAX                : integer;    // Максимальное кол-во итераций
                          MinParam              : PExtArr;    // Минимальные значения выходов (параметров)
                          MaxParam              : PExtArr;    // Максимальные значения выходов (параметров)
                          var ErrorCode         : NativeInt;  // Код ошибки
                          var StopOpt           : integer;    // Флаг конца оптимизации
                          var otp_step_position : integer     // Состояние алгоритма оптимизации
                          );

end;

//##############################################################################
implementation
//##############################################################################
function    TPOISK4.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var j: integer;
begin
  Result:=True;
  Stream.Read(IterationNum, SizeOfInt);
  Stream.Read(i,SizeOfInt);
  Stream.Read(A,SizeOfDouble);
  Stream.Read(B,SizeOfDouble);
  Stream.Read(C,SizeOfDouble);
  Stream.Read(D,SizeOfDouble);
  Stream.Read(GAMA,SizeOfDouble);
  Stream.Read(G,SizeOfDouble);
  Stream.Read(FN,SizeOfDouble);
  Stream.Read(G1,SizeOfDouble);
  Stream.Read(ALFA,SizeOfDouble);
  Stream.Read(ALAM,SizeOfDouble);
  Stream.Read(X2[0],Length(X2)*SizeOfDouble);
  Stream.Read(FX2[0], Length(FX2)*SizeOfDouble);
  Stream.Read(FX3[0], Length(FX3)*SizeOfDouble);
  for j := 0 to Length(S) - 1 do
    Stream.Read(S[j][0],Length(S[j])*SizeOfDouble);
  for j := 0 to Length(S1) - 1 do
    Stream.Read(S1[j][0],Length(S1[j])*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure   TPOISK4.RestartSave(Stream: TStream);
 var j: integer;
begin
  Stream.Write(IterationNum, SizeOfInt);
  Stream.Write(i,SizeOfInt);
  Stream.Write(A,SizeOfDouble);
  Stream.Write(B,SizeOfDouble);
  Stream.Write(C,SizeOfDouble);
  Stream.Write(D,SizeOfDouble);
  Stream.Write(GAMA,SizeOfDouble);
  Stream.Write(G,SizeOfDouble);
  Stream.Write(FN,SizeOfDouble);
  Stream.Write(G1,SizeOfDouble);
  Stream.Write(ALFA,SizeOfDouble);
  Stream.Write(ALAM,SizeOfDouble);
  Stream.Write(X2[0], Length(X2)*SizeOfDouble);
  Stream.Write(X3[0], Length(X3)*SizeOfDouble);
  Stream.Write(FX2[0], Length(FX2)*SizeOfDouble);
  Stream.Write(FX3[0], Length(FX3)*SizeOfDouble);
  for j := 0 to Length(S) - 1 do
    Stream.Write(S[j][0],Length(S[j])*SizeOfDouble);
  for j := 0 to Length(S1) - 1 do
    Stream.Write(S1[j][0],Length(S1[j])*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TPOISK4.InitMem(N,M: integer);
 var j: integer;
begin
  LeaveMem;
  SetLength(S,N);
  for j := 0 to N - 1 do SetLength(S[j],N);
  SetLength(S1,N);
  for j := 0 to N - 1 do SetLength(S1[j],N);
  SetLength(X2, N);
  SetLength(X3, N);
  SetLength(FX2, M + 1);
  SetLength(FX3, M + 1);
end;
//-------------------------------------------------------------------------------------------------
procedure  TPOISK4.LeaveMem;
  var j: integer;
begin
  for j := 0 to Length(S) - 1 do SetLength(S[j],0);
  SetLength(S,0);
  for j := 0 to Length(S1) - 1 do SetLength(S1[j],0);
  SetLength(S1,0);
  SetLength(X2, 0);
  SetLength(X3, 0);
  SetLength(FX2, 0);
  SetLength(FX3, 0);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TPOISK4.ExecuteStep;
begin
  if(N > 1) then
    StepFewParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position)
  else
    StepOneParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TPOISK4.StepOneParam;

  // Метки состояния
  Label lbl_1, lbl_2, lbl_3;

  // Метки возврата к состоянию
  Label lbl_1R, lbl_2R; //5, 10, 15;

  // Метка выхода из процедуры
  label lbl_exit;

  var
  // Промежуточная переменная (параметр оптимизации)
  Dummy         : realtype;

begin
    // Выбор состояния
  case otp_step_position of
    1: goto lbl_1;
    2: goto lbl_2;
    3: goto lbl_3;
  end;

  ErrorCode := 0;
  IterationNum := 0;
  X[0] :=  0.5 * (MaxParam[0] + MinParam[0]);
  DX[0] :=  0.5 * (MaxParam[0] - MinParam[0]);

  //Состояние 1
  SETOUTS(X, FX, ErrorCode);
  otp_step_position := 1;
  exit;
//##############################################################################
  lbl_1:
    // Определяем F(X1)
    GETQUAL(X, FX, ErrorCode);
    Inc(IterationNum);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    // Расчет точки X2
    X2[0] := X^[0] + DX[0];
  lbl_1R:
    //Состояние 2
    SETOUTS(@X2[0], @FX2[0], ErrorCode);
    otp_step_position := 2;
    exit;
//##############################################################################
  lbl_2:
    // Определяем F(X2)
    GETQUAL(@X2[0], @FX2[0], ErrorCode);
    Inc(IterationNum);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    // Функция уменьшается
    if(FX[M] > FX2[M]) then begin
      Dummy:=X^[0];
      X^[0]:=X2[0];
      X2[0]:=Dummy;
      Dummy:=FX[M];
      FX[M] := FX2[M];
      FX2[M] := Dummy;
    end;

  lbl_2R:
    // Расчет точки X3
    X3[0] := X^[0] + (X^[0] - X2[0]);
    //Состояние 3
    SETOUTS(@X3[0], @FX3[0], ErrorCode);
    otp_step_position := 3;
    exit;
//##############################################################################
  lbl_3:
    // Определяем F(X3)
    GETQUAL(@X3[0], @FX3[0], ErrorCode);
    Inc(IterationNum);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    // Найден оптимум !!!
    if (FX3[M] <= 0) then begin
      X^[0] := X3[0];
      FX[M] := FX3[M];
      StopOpt := 1;
      goto lbl_exit
    end;
    // Превышено количество итераций
    if (IterationNum > NFEMAX) then begin
      ErrorCode := er_opt_MaxFunEval;
      goto lbl_exit
    end;
    // Слишком маленький шаг - считаем новый градиент
    if (abs(X3[0] - X^[0]) <= abs(DXfinal[0])) then begin
      goto lbl_1;
    end;
    // Функция уменьшается - движемся дальше
    if(FX[M] > FX3[M]) then begin
      X^[0] := X3[0];
      FX[M] := FX3[M];
      goto lbl_2R;
    end;
    // TODO-GS:
    D:=(FX2[M] - FX[M]) + (FX3[M] - FX[M]);
    if (D<=0) then  goto lbl_exit;{?????????}
    // TODO-GS:
    GAMA:=(FX2[M] - FX3[M]) / (2.0 * D);
    if (abs(GAMA) < 0.02)  then begin;
      if (GAMA >= 0) then  GAMA := 0.02;
      if (GAMA <= 0) then  GAMA :=- 0.02;
    end;
    // Расчет точки X2
    X2[0] := X^[0] + GAMA*(X^[0] - X2[0]);
    goto lbl_1R;

  lbl_exit:
    otp_step_position := 0;
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TPOISK4.StepFewParam;
  // Метки состояния
  Label lbl_1, lbl_2, lbl_3, lbl_4;

  // Промежуточные Метки состояния
  Label 40, 55, 70, 90, 100;

  // Метка выхода из процедуры
  label lbl_exit;


  var
  // Обобщенная точность подбора параметров
  EpsSum        : realtype;

  // Счетчики
  j,k           : integer;

begin
  // Выбор состояния
  case otp_step_position of
    1: goto lbl_1;
    2: goto lbl_2;
    3: goto lbl_3;
    4: goto lbl_4;
  end;

  ErrorCode := 0;

  i := 0;
  while i < N do begin
    X[i] :=  0.5 * (MaxParam[i] + MinParam[i]);
    DX[i] :=  0.5 * (MaxParam[i] - MinParam[i]);
    inc(i);
  end;

  //Состояние 1
  SETOUTS(X, FX, ErrorCode);
  otp_step_position:=1;
  exit;
//##############################################################################
  lbl_1:
    // Определяем F(X1)
    GETQUAL(X, FX, ErrorCode);
    IterationNum := 1;
    if StopOpt = -1 then StopOpt:=0;
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    i:=0;
    while i < N do begin
      for j:=0 to N-1 do S[i][j]:=0.0;
      S[i][i]:=DX[i];
      inc(i);
    end;
    ALFA:=1.0;

  40:
    i:=0;
    while I < N DO BEGIN
      A:=0.0;
      B:=1.0;
      EpsSum := 0.0;
      for j:=0 to N-1 do begin
        X2[j] := X^[j] + ALFA * S[j][i];
        EpsSum := EpsSum + abs(X2[j] - X^[j]) / (abs(DXfinal[j]) + 1.0e-30);
      end;
      // Завершение по нормированной точности
      if(EpsSum <= 1) then begin
        ErrorCode := er_opt_Eps;
        goto lbl_exit
      end;
      // Завершение по количеству итераций
      if(IterationNum >= NFEMAX) then begin
        ErrorCode := er_opt_MaxFunEval;
        goto lbl_exit
      end;
      // Завершение по
      if(FX[M] <= 0) then begin
        StopOpt := 1;
        goto lbl_exit
      end;
      //Состояние 4
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position := 2;
      exit;
//##############################################################################
  lbl_2:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(IterationNum);
      OUT2(@X2, @FX2, N, M, IterationNum, otp_step_position);

      if (FX[M] <= FX2[M]) then goto 55;
      for j:=0 to N-1 do begin
        G:=X^[j];
        X^[j]:=X2[j];
        X2[j]:=G;
      end;
      G:=FX[M];
      FX[M]:=FX2[M];
      FX2[M]:=G;
      G:=A;
      A:=B;
      B:=G;
      if StopOpt = 1 then goto lbl_exit;
  55:
      for j := 0 to N - 1 do X3[j] := X^[j] + (X^[j] - X2[j]);
      C := A + (A - B);

      //Состояние 5
      SETOUTS(@X3[0], @FX3[0], ErrorCode);
      otp_step_position := 3;
      exit;
//##############################################################################
  lbl_3:
      GETQUAL(@X3[0], @FX3[0], ErrorCode);
      Inc(IterationNum);
      OUT2(@X3, @FX3, N, M, IterationNum, otp_step_position);

      if  ((FX[M] <= FX3[M]) or (FX[M] <= 0) or (IterationNum>=NFEMAX)) then goto 70;
      for j:=0 to N-1 do X^[j]:=X3[j];
      FX[M] := FX3[M];
      A:=C;
      if StopOpt = 1 then goto lbl_exit;
      goto 55;
  70:
      // TODO-GS:
      D:=(FX2[M] - FX[M]) + (FX3[M] - FX[M]);
      if (D <= 0) then goto 90;
      // TODO-GS:
      GAMA:=(FX2[M] - FX3[M]) / (2.0 * D);
      for j:=0 to N-1 do X2[j]:=X^[j]+GAMA*(X^[j]-X2[j]);

      //Состояние 6
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position:=4;
      exit;
//##############################################################################
  lbl_4:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(IterationNum);
      OUT2(@X2, @FX2, N, M, IterationNum, otp_step_position);

      B:=A+GAMA*(A-B);
      ALAM:=ALFA*abs(A-C)/sqrt(D);
      if (ALAM<0.25) then ALAM:=0.25;
      if (ALAM>4) then ALAM:=4;
      if (B<0) then ALAM:=-ALAM;
      for j:=0 to N-1 do S[j][i]:=ALAM*S[j][i];
      if (FX[M] <= FX2[M]) then goto 90;
      for j:=0 to N-1 do X^[j]:=X2[j];
      FX[M] := FX2[M];
      A:=B;
      if StopOpt = 1 then goto lbl_exit;
  90:
      if (abs(A)>(1.0*abs(ALAM))) then ALFA:=2.0*ALFA;
      if (abs(A)<(0.25*abs(ALAM))) then ALFA:=0.5*ALFA;
      if StopOpt = 1 then goto lbl_exit;

      inc(i);
    END;
//##############################################################################
     FN:=N;
     G:=1.0/sqrt(FN);

     i:=0;
     while I < N DO BEGIN
       if (i=0) then goto 100;
       FN:=(N-i+1)*(N-i);
       G:=1.0/sqrt(FN);
       FN:=N-i;
       G1:=FN*G;
  100:
       for j:=0 to N-1 do begin
         A:=0.0;
         for k:=i to N-1 do A:=A+S[j][k];
         A:=G*A;
         if (i<>0) then A:=G1*S[j][i-1]-A;
         S1[j][i]:=A;
       end;
       inc(i);
     END;

     i:=0;
     while i < N do begin
       for j:=0 to N-1 do
         S[i][j]:=S1[i][j];
       inc(i);
     end;
     goto 40;

  lbl_exit:
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    otp_step_position := 0;
end;
//-------------------------------------------------------------------------------------------------
END.