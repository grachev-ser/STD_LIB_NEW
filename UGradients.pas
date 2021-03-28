
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
//-------------------------------------------------------------------------------------------------
UNIT UGradients;

interface

USES Classes, DataTypes, OptType;

type
   // Процедура оптимизации ПОИСК-2, переделанная под конечно-автоматный вариант работы
   TGRADIENTS = class(TOptMethod)

public

  // Выполнить шаг оптимизации
  procedure ExecuteStep(  X                     : PExtArr;    // Массив выходов (параметров)
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
                          var otp_step_position : integer     // Состояние алгоритма оптимизации (указатель положения стека)
                        ); override;

  // Инициализация памяти
  procedure InitMem(N, M : integer); override;

  // Освобождение памяти
  procedure LeaveMem; override;

  // Чтение точки рестарта блока
  function RestartLoad(Stream : TStream; Count : integer; const TimeShift : double): boolean; override;

  // Запись точки рестарта блока
  procedure RestartSave(Stream : TStream); override;

protected

  // Количество итераций
  IterationNum  : integer;

  // Точка 2
  X2            : array of realtype;

  // Точка 3
  X3            : array of realtype;

  // Точка N
  XN            : array of realtype;

  // Значение функции в точке 2
  FX2           : array of realtype;

  // Значение функции в точке 3
  FX3           : array of realtype;

  // Значение функции в точке N
  FXN           : array of realtype;


  S             : array of array of realtype;


  S1            : array of array of realtype;


  A             : realtype;


  E             : realtype;


  GAMA          : realtype;


  G             : realtype;


  FN            : realtype;


  G1            : realtype;


  IC            : integer;


  i             : integer;

  // Алгоритм при одном оптимизируемом параметре (Алгоритм деления шага пополам)
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

  // Алгоритм при нескольких оптимизируемых параметрах (Алгоритм преобразования матрицы направлений)
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
function TGRADIENTS.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var j: integer;
begin
  Result:=True;
  Stream.Read(IterationNum, SizeOfInt);
  Stream.Read(IC,SizeOfInt);
  Stream.Read(i,SizeOfInt);
  Stream.Read(A,SizeOfDouble);
  Stream.Read(E,SizeOfDouble);
  Stream.Read(GAMA,SizeOfDouble);
  Stream.Read(G,SizeOfDouble);
  Stream.Read(FN,SizeOfDouble);
  Stream.Read(G1,SizeOfDouble);
  Stream.Read(X2[0],  Length(X2) * SizeOfDouble);
  Stream.Read(X3[0],  Length(X3) * SizeOfDouble);
  Stream.Read(XN[0],  Length(XN) * SizeOfDouble);
  Stream.Read(FX2[0], Length(FX2) * SizeOfDouble);
  Stream.Read(FX3[0], Length(FX3) * SizeOfDouble);
  Stream.Read(FXN[0], Length(FXN) * SizeOfDouble);
  for j := 0 to Length(S) - 1 do
    Stream.Read(S[j][0],Length(S[j])*SizeOfDouble);
  for j := 0 to Length(S1) - 1 do
    Stream.Read(S1[j][0],Length(S1[j])*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS.RestartSave(Stream: TStream);
 var j: integer;
begin
  Stream.Write(IterationNum, SizeOfInt);
  Stream.Write(IC,SizeOfInt);
  Stream.Write(i,SizeOfInt);
  Stream.Write(A,SizeOfDouble);
  Stream.Write(E,SizeOfDouble);
  Stream.Write(GAMA,SizeOfDouble);
  Stream.Write(G,SizeOfDouble);
  Stream.Write(FN,SizeOfDouble);
  Stream.Write(G1,SizeOfDouble);
  Stream.Write(X2[0],   Length(X2) * SizeOfDouble);
  Stream.Write(X3[0],   Length(X3) * SizeOfDouble);
  Stream.Write(XN[0],   Length(XN) * SizeOfDouble);
  Stream.Write(FX2[0],  Length(FX2) * SizeOfDouble);
  Stream.Write(FX3[0],  Length(FX3) * SizeOfDouble);
  Stream.Write(FXN[0],  Length(FXN) * SizeOfDouble);
  for j := 0 to Length(S) - 1 do
    Stream.Write(S[j][0],Length(S[j])*SizeOfDouble);
  for j := 0 to Length(S1) - 1 do
    Stream.Write(S1[j][0],Length(S1[j])*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS.InitMem;
 var j: integer;
begin
  //Перед тем как выделить память - освобождаем ранее выделенную, если она есть где-то
  LeaveMem;
  //Инициализация внутренних переменных по нулевому шагу
  SetLength(S,N);
  for j := 0 to N - 1 do SetLength(S[j],N);
  SetLength(S1,N);
  for j := 0 to N - 1 do SetLength(S1[j],N);
  SetLength(X2, N);
  SetLength(X3, N);
  SetLength(XN, N);
  SetLength(FX2, M + 1);
  SetLength(FX3, M + 1);
  SetLength(FXN, M + 1);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS.LeaveMem;
  var j: integer;
begin
  for j := 0 to Length(S) - 1 do SetLength(S[j],0);
  SetLength(S,0);
  for j := 0 to Length(S1) - 1 do SetLength(S1[j],0);
  SetLength(S1, 0);
  SetLength(X2, 0);
  SetLength(X3, 0);
  SetLength(XN, 0);
  SetLength(FX2, 0);
  SetLength(FX3, 0);
  SetLength(FXN, 0);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS.ExecuteStep;
begin
  if(N > 1) then
    StepFewParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position)
  else
    StepOneParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS.StepOneParam;
  label 3, 6, 8, 10, 12,
        lbl_1,lbl_2,lbl_3,lbl_4,lbl_5;

  // Метка выхода из процедуры
  label lbl_exit;


begin
  // Выбор состояния
  case otp_step_position of
    1: goto lbl_1;
    2: goto lbl_2;
    3: goto lbl_3;
    4: goto lbl_4;
    5: goto lbl_5;
  end;

  ErrorCode := 0;
  // GS: Начальное приближение устанавливается в центр зоны поиска
  X[0] :=  0.5 * (MaxParam[0] + MinParam[0]);
  // GS: Начальный шаг устанавливаем равным половине зоны поиска
  DX[0] :=  0.5 * (MaxParam[0] - MinParam[0]);

  // Состояние 1 (Подставляем X1 = X0)
  SETOUTS(X, FX, ErrorCode);
  otp_step_position := 1;
  exit;
//##############################################################################
  lbl_1:
    // Определяем F(X1)
    GETQUAL(X, FX, ErrorCode);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    IterationNum := 1;
    if StopOpt = -1 then StopOpt:=0;
    // Шаг 2: X2 = X1 + dX
    X2[0] := X^[0] + DX[0];
    // Состояние 2 (Подставляем X2)
    SETOUTS(@X2[0], @FX2[0], ErrorCode);
    otp_step_position := 2;
    exit;
//##############################################################################
  lbl_2:
    // Определяем F(X2)
    GETQUAL(@X2[0], @FX2[0], ErrorCode);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    Inc(IterationNum);
    if StopOpt = 1 then goto lbl_exit;

    if(FX[M] <= FX2[M]) then goto 3;

    A:=X^[0];
    X^[0] := X2[0];
    X2[0] := A;
    i:=0;
    while i < M + 1 do begin
      FX^[i]:=FX2[i];
      inc(i)
    end;

  3:
    // Шаг 3: X3 = X1 - dX
    X3[0] := X^[0] + (X^[0] - X2[0]);
    // Состояние 3 (Подставляем X3)
    SETOUTS(@X3[0], @FX3[0], ErrorCode);
    otp_step_position := 3;
    exit;
//##############################################################################
  lbl_3:
    // Определяем F(X3)
    GETQUAL(@X3[0], @FX3[0], ErrorCode);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    Inc(IterationNum);
    if StopOpt = 1 then goto lbl_exit;

    if(FX[M] <= FX3[M]) then goto 6;

    X^[0] := X3[0];
    i:=0;
    while i < M + 1 do begin
      FX^[i] := FX3[i];
      inc(i);
    end;
    if (IterationNum > NFEMAX) then begin
      ErrorCode := er_opt_MaxFunEval;
      goto lbl_exit
    end;
    goto 3;
  6:
    XN[0] := X^[0] + 0.5*(X2[0] - X^[0]);
    //Состояние 4
    SETOUTS(@XN[0], @FXN[0], ErrorCode);
    otp_step_position := 4;
    exit;
//##############################################################################
  lbl_4:
    // Определяем F(X4)
    GETQUAL(@XN[0], @FXN[0], ErrorCode);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    Inc(IterationNum);
    if StopOpt = 1 then goto lbl_exit;

    if(FX[M] <= FXN[M]) then goto 10;

    X3[0] := X2[0];
  8:
    X2[0] := X^[0];
    X^[0] := XN[0];
    i:=0;
    while i < M + 1 do begin
      FX^[i] := FXN[i];
      inc(i);
    end;
    goto 12;
  10:
    X2[0] := XN[0];
    XN[0] := X^[0] + 0.5*(X3[0] - X^[0]);

    //Состояние 5
    SETOUTS(@XN[0], @FXN[0], ErrorCode);
    otp_step_position := 5;
    exit;
//##############################################################################
  lbl_5:
    GETQUAL(@XN[0], @FXN[0], ErrorCode);
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    Inc(IterationNum);
    if StopOpt = 1 then goto lbl_exit;

    if(FX[M] > FXN[M]) then goto 8;

    X3[0] := XN[0];
  12:
    if(IterationNum > NFEMAX) then begin
      ErrorCode:=er_opt_MaxFunEval;
      goto lbl_exit
    end;
    if (abs(X2[0] - X3[0]) <= abs(DXfinal[0])) then begin
      ErrorCode:=er_opt_Eps;
      goto lbl_exit
    end;
    goto 6;

  lbl_exit:
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    otp_step_position := 0;    //Заново !!!
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS.StepFewParam;

  label 18,25,35,40,45,60,75,100,
        lbl_1,lbl_6,lbl_7,lbl_8;

  // Метка выхода из процедуры
  label lbl_exit;

  var j,k: integer;

begin
    // Выбор состояния
    case otp_step_position of
      1: goto lbl_1;
      6: goto lbl_6;
      7: goto lbl_7;
      8: goto lbl_8;
    end;

    ErrorCode := 0;
    IC:=0;
    i:=0;

    // Состояние 1 (Подставляем X1 = X0)
    SETOUTS(X, FX, ErrorCode);
    otp_step_position := 1;
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
  18:
    i:=0;
    while i < N do BEGIN
      E:=0.0;
      for j:=0 to N-1 do begin
        X2[j] := X^[j] + S[j][i];
        E:=E+abs(X2[j] - X^[j])/(abs(DXfinal[j])+1.0e-30);
      end;
      if((E<=1.0) or (IterationNum >= NFEMAX)) then begin
        if E <=1.0 then
          ErrorCode:=er_opt_Eps
        else
          ErrorCode:=er_opt_MaxFunEval;
        goto lbl_exit
      end;
      //Состояние 6
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position:=6;
      exit;
//##############################################################################
  lbl_6:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(IterationNum);
      GAMA:=1.0;
      COMPQUAL(X, @X2[0], FX, @FX2[0], N, M, IC);

      if (IC=1) then goto 25;
      if (IC=2) then goto 45;
      if (IC=3) then goto lbl_exit;
  25:
      for j:=0 to N-1 do X2[j] := X^[j] - S[j][i];

      //Состояние 7
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position:=7;
      exit;

//##############################################################################
  lbl_7:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(IterationNum);
      GAMA:=-1.0;
      COMPQUAL(X, @X2[0], FX, @FX2[0],N,M,IC);
      if (IC=1) then goto 35;
      if (IC=2) then goto 45;
      if (IC=3) then goto lbl_exit;

  35:
      GAMA:=0.5;
      goto 60;
  40:
      GAMA:=2.0*GAMA;
  45:
      for j:=0 to N-1 do begin
        X^[j]:=X2[j];
        X2[j]:=X^[j] + GAMA*S[j][i];
      end;

      for j:=0 to M do FX^[j] := X2[j];
      if (abs(GAMA)>16) then goto 60;

      //Состояние 8
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position := 8;
      exit;
//##############################################################################
  lbl_8:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(IterationNum);
      COMPQUAL(X, @X2[0], FX, @FX2[0], N, M, IC);
      if (IC=1) then goto 60;         // FX < FX2
      if (IC=2) then goto 40;         // FX > FX2
      if (IC=3) then goto lbl_exit;

  60:
      for j:=0 to N-1 do S[j][i]:=GAMA*S[j][i];
      OUT2(X, FX, N, M, IterationNum, otp_step_position);
      inc(i);
     END;

     FN:=N;
     G:=1.0/sqrt(FN);

     i:=0;
     while i < N do BEGIN
       if (i=0) then goto 75;
       FN:=(N-i+1)*(N-i);
       G:=1.0/sqrt(FN);
       FN:=N-i;
       G1:=FN*G;
  75:
       for j:=0 to N-1 do begin
         A:=0.0;
         for k:=i to N-1 do A:=A+S[j][k];
         A:=G*A;
         if (i<>0) then A:=-G1*S[j][i-1]+A;
         S1[j][i]:=A;
       end;

       inc(i);
     END;

     i:=0;
     while i < N do begin
       for j:=0 to N-1  do
         S[i][j]:=S1[i][j];
       inc(i);
     end;
     goto 18;

lbl_exit:
    OUT2(X, FX, N, M, IterationNum, otp_step_position);
    otp_step_position := 0;    //Заново !!!
end;
//-------------------------------------------------------------------------------------------------
end.
