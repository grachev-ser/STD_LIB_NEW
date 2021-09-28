
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
//-------------------------------------------------------------------------------------------------
UNIT UGradients2;

interface

USES Classes, DataTypes, OptType;

type
   // Процедура оптимизации реализующая метод сопряженных градиентов
   // переделанная под конечно-автоматный вариант работы
   TGRADIENTS2 = class(TOptMethod)

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
  iIterationNum : integer;

  // Номер текущего параметра
  iParamNum     : integer;

  // Корректирующий коэффициент шага оценки градиента
  rAlfa         : realtype;

  // Корректирующий коэффициент длины шага
  GAMA          : realtype;

  // Градиент
  Gradient      : realtype;

  // Массив градиентов (при нескольких оптимизируемых параметрах)
  aGradients    : array of realtype;

  // Массив градиентов с предыдуюего шага (при нескольких оптимизируемых параметрах)
  aGradientsOld : array of realtype;

  // Массив шагов (при нескольких оптимизируемых параметрах)
  aSteps        : array of realtype;

  // Точка 2
  X2            : array of realtype;

  // Точка 3
  X3            : array of realtype;

  // Значение функции в точке 2
  FX2           : array of realtype;

  // Значение функции в точке 3
  FX3           : array of realtype;

  // Алгоритм при одном оптимизируемом параметре (Алгоритм квадратичной интерполяции)
  procedure StepOneParam( X                     : PExtArr;    // Массив выходов (параметров)
                          FX                    : PExtArr;    // Массив входов (критериев)
                          N                     : integer;    // Кол-во выходов (параметров)
                          M                     : integer;    // Кол-во входов (критериев)
                          DX                    : PExtArr;    // Текущее приращение параметра оптимизации
                          DXfinal               : PExtArr;    // Точность подбора выходов (параметров)
                          iIterationMax         : integer;    // Максимальное кол-во итераций
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
                          iIterationMax         : integer;    // Максимальное кол-во итераций
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
function TGRADIENTS2.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var j: integer;
begin
  Result:=True;
  Stream.Read(iIterationNum, SizeOfInt);
  Stream.Read(iParamNum, SizeOfInt);
  Stream.Read(rAlfa, SizeOfDouble);
  Stream.Read(GAMA, SizeOfDouble);
  Stream.Read(X2[0],Length(X2)*SizeOfDouble);
  Stream.Read(X3[0], Length(X3)*SizeOfDouble);
  Stream.Read(FX2[0], Length(FX2)*SizeOfDouble);
  Stream.Read(FX3[0], Length(FX3)*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS2.RestartSave(Stream: TStream);
 var j: integer;
begin
  Stream.Write(iIterationNum, SizeOfInt);
  Stream.Write(iParamNum, SizeOfInt);
  Stream.Write(rAlfa,SizeOfDouble);
  Stream.Write(GAMA,SizeOfDouble);
  Stream.Write(X2[0], Length(X2)*SizeOfDouble);
  Stream.Write(X3[0], Length(X3)*SizeOfDouble);
  Stream.Write(FX2[0], Length(FX2)*SizeOfDouble);
  Stream.Write(FX3[0], Length(FX3)*SizeOfDouble);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS2.InitMem;
 var j: integer;
begin
  LeaveMem;
  SetLength(aGradients, N);
  SetLength(aGradientsOld, N);
  SetLength(aSteps, N);
  SetLength(X2, N);
  SetLength(X3, N);
  SetLength(FX2, M + 1);
  SetLength(FX3, M + 1);
end;
//-------------------------------------------------------------------------------------------------
procedure TGRADIENTS2.LeaveMem;
  var j: integer;
begin
  SetLength(aGradients, 0);
  SetLength(aGradientsOld, 0);
  SetLength(aSteps, 0);
  SetLength(X2, 0);
  SetLength(X3, 0);
  SetLength(FX2, 0);
  SetLength(FX3, 0);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS2.ExecuteStep;
begin
  if(N > 1) then
    StepFewParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position)
  else
    StepOneParam(X, FX, N, M, DX, DXfinal, NFEMAX, MinParam, MaxParam, ErrorCode, StopOpt, otp_step_position);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS2.StepOneParam;

  // Метки состояния
  Label lbl_1, lbl_2, lbl_3, lbl_4;

  // Метки возврата к состоянию
  Label lbl_1R, lbl_3R;

  // Метка выхода из процедуры
  label lbl_exit;

begin
    // Выбор состояния
  case otp_step_position of
    1: goto lbl_1;
    2: goto lbl_2;
    3: goto lbl_3;
    4: goto lbl_4;
  end;

  ErrorCode := 0;
  iIterationNum := 0;
  rAlfa := 1.0;
  X^[0] :=  0.5 * (MaxParam^[0] + MinParam^[0]);
  DX^[0] :=  0.2 * (MaxParam^[0] - MinParam^[0]);

  // Состояние 1
  SETOUTS(X, FX, ErrorCode);
  otp_step_position := 1;
  exit;
//##############################################################################
  lbl_1:
    // Определяем F(X1)
    GETQUAL(X, FX, ErrorCode);
    Inc(iIterationNum);
    OUT2(X, FX, N, M, iIterationNum, otp_step_position);

  lbl_1R:
    GAMA := 1.0;
    // Расчет точки X2
    X2[0] := X^[0] + rAlfa * DX^[0];
    // Состояние 2
    SETOUTS(@X2[0], @FX2[0], ErrorCode);
    otp_step_position := 2;
    exit;
//##############################################################################
  lbl_2:
    // Определяем F(X2)
    GETQUAL(@X2[0], @FX2[0], ErrorCode);
    Inc(iIterationNum);
    OUT2(@X2[0], @FX2[0], N, M, iIterationNum, otp_step_position);
    // Расчет точки X3
    X3[0] := X^[0] - rAlfa * DX^[0];
    // Состояние 3
    SETOUTS(@X3[0], @FX3[0], ErrorCode);
    otp_step_position := 3;
    exit;
//##############################################################################
  lbl_3:
    // Определяем F(X3)
    GETQUAL(@X3[0], @FX3[0], ErrorCode);
    Inc(iIterationNum);
    OUT2(@X3[0], @FX3[0], N, M, iIterationNum, otp_step_position);
    // Найден оптимум !!!
    if (FX3[M] <= 0.001) then begin
      X^[0] := X3[0];
      FX^[M] := FX3[M];
      StopOpt := 1;
      goto lbl_exit
    end;
    // Градиент
    Gradient := (FX3[M] - FX2[M]) / (X3[0] - X2[0]);
  lbl_3R:
    // Расчет точки X3
    X3[0] := X^[0] - GAMA * Gradient;
    // Состояние 4
    SETOUTS(@X3[0], @FX3[0], ErrorCode);
    otp_step_position := 4;
    exit;
  //##############################################################################
  lbl_4:
    // Определяем F(X3)
    GETQUAL(@X3[0], @FX3[0], ErrorCode);
    Inc(iIterationNum);
    OUT2(@X3[0], @FX3[0], N, M, iIterationNum, otp_step_position);
    // Найден оптимум !!!
    if (FX3[M] <= 0.001) then begin
      X^[0] := X3[0];
      FX^[M] := FX3[M];
      StopOpt := 1;
      goto lbl_exit
    end;
    // Превышено количество итераций
    if (iIterationNum > iIterationMax) then begin
      ErrorCode := er_opt_MaxFunEval;
      goto lbl_exit
    end;
    // Слишком маленький шаг - считаем новый градиент
    if (abs(X3[0] - X^[0]) <= abs(DXfinal[0])) then begin
      rAlfa := 0.5 * rAlfa;
      if(rAlfa < 0.1) then
        ErrorCode := er_opt_Eps
      else
        goto lbl_1R
    end;
    // Функция уменьшается - считаем новый градиент
    if (FX^[M] > FX3[M]) then begin
      X^[0] := X3[0];
      FX^[M] := FX3[M];
      goto lbl_1R;
    end;
    // Корректируем коэффициент
    GAMA := 0.5 * GAMA;
    goto lbl_3R;

  lbl_exit:
    otp_step_position := 0;;
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TGRADIENTS2.StepFewParam;
  // Метки состояния
  Label lbl_1, lbl_2, lbl_3, lbl_4;

  // Промежуточные метки состояния
  Label lbl_1R, lbl_3R;

  // Метка выхода из процедуры
  label lbl_exit;

  var
  // Счетчики
  j,k           : integer;

  // Обобщенная точность подбора параметров
  EpsSum        : realtype;

  // Текущая длина градиента
  LenghtCur     : realtype;

  // Предыдущая длина градиента
  LenghtOld     : realtype;

begin
  // Выбор состояния
  case otp_step_position of
    1: goto lbl_1;
    2: goto lbl_2;
    3: goto lbl_3;
    4: goto lbl_4;
  end;

  ErrorCode := 0;
  iIterationNum := 0;
  rAlfa := 1.0;
  GAMA := 2.0;

  j := 0;
  while j < N do begin
    X^[j] :=  0.5 * (MaxParam^[j] + MinParam^[j]);
    DX^[j] :=  0.2 * (MaxParam^[j] - MinParam^[j]);
    inc(j);
  end;

  // Состояние 1
  SETOUTS(X, FX, ErrorCode);
  otp_step_position := 1;
  exit;
//##############################################################################
  lbl_1:
    // Определяем F(X1)
    GETQUAL(X, FX, ErrorCode);
    Inc(iIterationNum);
    OUT2(X, FX, N, M, iIterationNum, otp_step_position);

  lbl_1R:
    GAMA := 2.0;
    iParamNum := 0;
    while iParamNum < N DO BEGIN
      // Расчет точки X2
      for j := 0 to N - 1 do begin
        if(j = iParamNum) then
          X2[j] := X^[j] + rAlfa * DX^[iParamNum]
        else
          X2[j] := X^[j];
      end;
      // Состояние 2
      SETOUTS(@X2[0], @FX2[0], ErrorCode);
      otp_step_position := 2;
      exit;
//##############################################################################
  lbl_2:
      GETQUAL(@X2[0], @FX2[0], ErrorCode);
      Inc(iIterationNum);
      OUT2(@X2[0], @FX2[0], N, M, iIterationNum, otp_step_position);
      // Расчет точки X3
      for j := 0 to N - 1 do begin
        if(j = iParamNum) then
          X3[j] := X^[j] - rAlfa * DX^[iParamNum]
        else
          X3[j] := X^[j];
      end;
      // Состояние 3
      SETOUTS(@X3[0], @FX3[0], ErrorCode);
      otp_step_position := 3;
      exit;
//##############################################################################
  lbl_3:
      GETQUAL(@X3[0], @FX3[0], ErrorCode);
      Inc(iIterationNum);
      OUT2(@X3[0], @FX3[0], N, M, iIterationNum, otp_step_position);
      // Градиент
      aGradients[iParamNum] := (FX3[M] - FX2[M]) / (X3[iParamNum] - X2[iParamNum]);
      inc(iParamNum);
  END;

  // Определение ..
  for j := 0 to N - 1 do begin
    LenghtCur := LenghtCur + aGradients[j]*aGradients[j];
    LenghtOld := LenghtOld + aGradientsOld[j]*aGradientsOld[j];
  end;
  // Шаг в направление сопряженного градиента
  for j := 0 to N - 1 do begin
    if(LenghtOld < 0.001) then
      aSteps[j] := aGradients[j]
    else
      aSteps[j] := aGradients[j] + LenghtCur / LenghtOld * aSteps[j];
  end;

  for j := 0 to N - 1 do begin
    aGradientsOld[j] := aGradients[j];
  end;

  lbl_3R:
      // Расчет точки X3
      for j := 0 to N - 1 do begin
        X3[j] := X^[j] - GAMA * aSteps[j];
      end;
      // Состояние 4
      SETOUTS(@X3[0], @FX3[0], ErrorCode);
      otp_step_position := 4;
      exit;
//##############################################################################
  lbl_4:
      GETQUAL(@X3[0], @FX3[0], ErrorCode);
      Inc(iIterationNum);
      OUT2(@X3[0], @FX3[0], N, M, iIterationNum, otp_step_position);
      // Превышено количество итераций
      if (iIterationNum > iIterationMax) then begin
        ErrorCode := er_opt_MaxFunEval;
        goto lbl_exit
      end;
      // Найден оптимум !!!
      if (FX3[M] <= 0.001) then begin
        for j:=0 to N - 1 do begin
          X^[j] := X3[j];
          FX^[j] := FX3[j];
        end;
        FX^[M] := FX3[M];
        StopOpt := 1;
        goto lbl_exit
      end;
      // Функция уменьшается - считаем новый градиент
      if (FX^[M] > FX3[M]) then begin
        for j:=0 to N - 1 do begin
          X^[j] := X3[j];
          FX^[j] := FX3[j];
        end;
        FX^[M] := FX3[M];
        goto lbl_1R;
      end;
      // Расчет нормированной точности
      EpsSum := 0.0;
      for j:=0 to N - 1 do begin
        EpsSum := EpsSum + abs(X3[j] - X^[j]) / (abs(DXfinal[j]) + 1.0e-30);
      end;
      // Завершение по нормированной точности
      if(EpsSum <= 1.0) then begin
        rAlfa := 0.5 * rAlfa;
        if(rAlfa < 0.1) then
          ErrorCode := er_opt_Eps
        else
          goto lbl_1R
      end;
      // Корректируем коэффициент
      GAMA := 0.5 * GAMA;
      goto lbl_3R;
//##############################################################################
  lbl_exit:
    otp_step_position := 0;
end;
//-------------------------------------------------------------------------------------------------
end.
