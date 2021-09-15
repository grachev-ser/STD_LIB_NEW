unit uOptimizers;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

interface

 //***************************************************************************//
 //      Блоки для оптимизации параметров модели по зпдпнным критериям        //
 //***************************************************************************//

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts,
     OptType, InterfaceUnit;


const
  {$IFDEF ENG}
    txtOptParametersValue = 'Optimized parameters = ';
    txtOptCriteria = ' , optimization criteries = ';
    txtYMinDefineError = 'Parameter ymin has dimension lower than x0';
    txtYMaxDefineError = 'Parameter ymax has dimension lower than x0';
    txtYAbsErrorDefineError = 'Parameter yabserror has dimension lower than x0';
    txtUMaxErrorDefineError = 'Parameter umax has dimension lower than umin';
    txt_opt_MaxFunEval = 'Exceeded the maximum number of function evaluations';
    txt_Opt_InitVal = 'Error initializing the optimization algorithm';
    txt_opt_Eps = 'Error optimization convergence';
  {$ELSE}
    txtOptParametersValue = 'Параметры = ';
    txtOptCriteria = ' , Критерии = ';
    txtYMinDefineError = 'Параметр ymin имеет размерность меньше чем x0';
    txtYMaxDefineError = 'Параметр ymax имеет размерность меньше чем x0';
    txtYAbsErrorDefineError = 'Параметр yabserror имеет размерность меньше чем x0';
    txtUMaxErrorDefineError = 'Параметр umax имеет размерность меньше чем umin';
    txt_opt_MaxFunEval = 'Превышено максимальное число вычислений функции';
    txt_Opt_InitVal = 'Ошибка инициализации алгоритма оптимизации';
    txt_opt_Eps = 'Ошибка оптимизаци по сходимости';
  {$ENDIF}
//-------------------------------------------------------------------------------------------------
type
  // Оптимизация модели
  TOptimize_new = class(TRunObject)
protected

  // ВХОДНЫЕ ДАННЫЕ
  // Тип суммарного критерия оптимизации (Аддитивный, квадратичный, минимаксный, мультипликативный)
  usumtype            :         integer;

  // Максимальное к-во итераций при оптимизации (задается)
  maxiter             :         NativeInt;

  // Метод оптимизации  (Поиск-2, Поиск-4, Симплекс)
  optmethod           :         NativeInt;

  // Режим оптимизации параметров (по полному перех. проц., в динамике с ост., в динамике непр.)
  optmode             :         NativeInt;

  // Периодичность анализа критериев оптимизации при расчёте в динамике (задается, с)
  optstep             :         double;

  // Начальные приближения выходов блоков (задается)
  x0                  :         TExtArray;

  // Минимальные значения выходов блока (задается)
  ymin                :         TExtArray;

  // Максимальные значения выходов блока (задается)
  ymax                :         TExtArray;

  // Абсолютная точность подбора выходов блока (задается)
  yabserror           :         TExtArray;

  // Начальные приращения выходов блока (задается)
  dparams             :         TExtArray;

  // Минимальные значения входных критериев оптимизации  (задается)
  umin                :         TExtArray;

  // Максимальные значения входных критериев оптимизации  (задается)
  umax                :         TExtArray;

  // ПЕРЕМЕННЫЕ МОДУЛЯ
  // Код ошибки
  ErrorNum            :         NativeInt;

  // Количество выходов блока (параметров оптимизации)
  NParam              :         integer;

  // Количество входов блока (критериев оптимизации)
  NQual               :         integer;

  // Локальное время ???
  localtime           :         double;

  // Массив выходов блока (параметров оптимизации)
  yparams             :         array of realtype;

  // Массив входов блока (критериев оптимизации)
  uinputs             :         array of realtype;

  // Текущее приращение выходов блока (параметров оптимизации)
  dPar                :         array of realtype;

  // Класс метода оптимизации
  OptimizeMethod      :         TOptMethod;


  // Флаг текущего состояния алгоритма оптимизации
  otp_step_position   :         integer;
  // Флаг остановки оптимизации
  StopOpt             :         integer;
  oldstopopt          :         integer;
  oldoldStopOpt       :         NativeInt;

  // Ограничения выходов блока
  PROCEDURE DOSETOUTS(X, FX : PExtArr; var ner : NativeInt);

  // Получаем качество ???
  PROCEDURE DOGETQUAL(X, FX : PExtArr; var ner : NativeInt);

  // Вывод информации о подобранных параметрах оптимизации и текущих значениях критериев оптимизации
  PROCEDURE DOOUT(X, FX : PExtArr; N, M, NFE : integer; var stepout : integer);

  // Сравнение F(X1) и F(X2)
  PROCEDURE DOCOMPQUAL(X, Y, FX, FY : PExtArr; N : integer; M : integer; var IC : integer);

public

  // Конструктор
  constructor Create(Owner : TObject); override;

  // Деструктор
  destructor Destroy; override;

  // Информационная функция блока (Как блок должен сортироваться)
  function InfoFunc(Action : integer; aParameter : NativeInt) : NativeInt; override;

  // Основной алгоритм работы  (Расчет блока)
  function RunFunc(var at, h : RealType; Action : Integer) : NativeInt; override;

  // Привязка параметров на схеме к внутренним переменным блока
  function GetParamID(const ParamName : string; var DataType : TDataType; var IsConst : boolean): NativeInt; override;

  // Чтение точки рестарта блока
  function RestartLoad(Stream : TStream; Count : integer; const TimeShift : double) : boolean; override;

  // Запись точки рестарта блока
  procedure RestartSave(Stream : TStream); override;
end;
//##############################################################################
implementation
//##############################################################################
uses UPoisk2, UPoisk4, USimp, UGradients;
//-------------------------------------------------------------------------------------------------
constructor TOptimize_new.Create;
begin
  inherited;
  x0:=TExtArray.Create(1);
  ymin:=TExtArray.Create(1);
  ymax:=TExtArray.Create(1);
  yabserror:=TExtArray.Create(1);
  dparams:=TExtArray.Create(1);
  umin:=TExtArray.Create(1);
  umax:=TExtArray.Create(1);
end;
//-------------------------------------------------------------------------------------------------
destructor  TOptimize_new.Destroy;
begin
  inherited;
  x0.Free;
  ymin.Free;
  ymax.Free;
  yabserror.Free;
  dparams.Free;
  umin.Free;
  umax.Free;
end;
//-------------------------------------------------------------------------------------------------
function TOptimize_new.GetParamID;
begin
  Result:=inherited GetParamId(ParamName, DataType, IsConst);
  if Result = -1 then begin

    if StrEqu(ParamName,'x0') then begin
      // Начальное приближение выходов блоков
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'ymin') then begin
      // Минимальное значение выходов блока
      Result:=NativeInt(ymin);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'ymax') then begin
      // Максимальное значение выходов блока
      Result:=NativeInt(ymax);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'yabserror') then begin
      // Абсолютная точность подбора значений выходов
      Result:=NativeInt(yabserror);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'dparams') then begin
      // Начальное приращение выходов
      Result:=NativeInt(dparams);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'umin') then begin
      // Минимальные значения входных критериев оптимизации
      Result:=NativeInt(umin);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'umax') then begin
      // Максимальные значения входных критериев оптимизации
      Result:=NativeInt(umax);
      DataType:=dtDoubleArray;
    end
    else if StrEqu(ParamName,'usumtype') then begin
      // Тип суммарного критерия оптимизации
      Result:=NativeInt(@usumtype);
      DataType:=dtInteger;
    end
    else if StrEqu(ParamName,'maxiter') then begin
      // Максимальное количество повторных моделирований при расчёте по полному переходному процессу
      Result:=NativeInt(@maxiter);
      DataType:=dtInteger;
    end
    else if StrEqu(ParamName,'optmethod') then begin
      // Метод оптимизации
      Result:=NativeInt(@optmethod);
      DataType:=dtInteger;
    end
    else if StrEqu(ParamName,'optmode') then begin
      // Режим оптимизации параметров
      Result:=NativeInt(@optmode);
      DataType:=dtInteger;
    end
    else if StrEqu(ParamName,'optstep') then begin
      // Периодичность анализа критериев оптимизации при расчёте в динамике, сек
      Result:=NativeInt(@optstep);
      DataType:=dtDouble;
    end
  end
end;
//-------------------------------------------------------------------------------------------------
function TOptimize_new.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetInit:
      Result:=1;
    i_GetCount:
      begin
        cY[0]:=x0.Count;
        cU[0]:=umin.Count;
      end;
    i_GetBlockType:
      Result := t_fun;  // Функциональный блок
    i_GetPropErr:
      begin
        // Проверка размерностей
        if ymin.Count < x0.Count then begin
          // Ошибка 'Параметр ymin имеет размерность меньше чем x0'
          ErrorEvent(txtYMinDefineError, msError, VisualObject);
          Result:=r_Fail;
        end;
        if ymax.Count < x0.Count then begin
          // Ошибка 'Параметр ymax имеет размерность меньше чем x0'
          ErrorEvent(txtYMaxDefineError, msError, VisualObject);
          Result:=r_Fail;
        end;
        if yabserror.Count < x0.Count then begin
          // Ошибка 'Параметр yabserror имеет размерность меньше чем x0'
          ErrorEvent(txtYAbsErrorDefineError, msError, VisualObject);
          Result:=r_Fail;
        end;
        if umax.Count < umin.Count then begin
          // Ошибка 'Параметр umax имеет размерность меньше чем umin'
          ErrorEvent(txtUMaxErrorDefineError, msError, VisualObject);
          Result:=r_Fail;
        end;
      end;
  else
    Result := inherited InfoFunc(Action, aParameter);
  end;
end;
//-------------------------------------------------------------------------------------------------
function TOptimize_new.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var
     i : Integer;
     tmp_time,tmpx: double;
  label
     do_opt_step,precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      NParam:=cY[0];
                      NQual:=cU[0];
                      SetLength(dPar,NParam);
                      SetLength(yparams, NParam);
                      SetLength(uinputs, NQual + 1);
                      ErrorNum:=0;
                      StopOpt:=0;
                      oldstopopt:=0;
                      oldoldStopOpt:=0;
                      otp_step_position:=0;
                      if OptimizeMethod <> nil then OptimizeMethod.Free;
                      case optmethod of
                        // ПОИСК-2
                        0: OptimizeMethod:=TPOISK2.Create;
                        // ПОИСК-4
                        1: OptimizeMethod:=TPOISK4.Create;
                        // Симплекс
                        2: OptimizeMethod:=TSIMPS.Create;
                        // Метод сопряженных градиентов
                        3: OptimizeMethod:=TGradients.Create;
                      end;
                      OptimizeMethod.SETOUTS:=DOSETOUTS;
                      OptimizeMethod.GETQUAL:=DOGETQUAL;
                      OptimizeMethod.OUT2:=DOOUT;
                      OptimizeMethod.COMPQUAL:=DOCOMPQUAL;
                      OptimizeMethod.InitMem(NParam,NQual);
                    end;
    f_Stop:         begin
                      if OptimizeMethod <> nil then OptimizeMethod.Free;
                      OptimizeMethod:=nil;
                    end;
    f_InitState:    begin
                      tmp_time:=0;
                      // Установка начальных значений параметров оптимизации задачи
                      tmpx:=0;
                      for i:=0 to NParam-1 do begin
                        // Начальные значения
                        yparams[i]:=x0.Arr^[i];
                        Y[0].Arr^[i]:=x0.Arr^[i];
                        // Начальные приращения (по умолчанию = 0.1*допустимый интервал)
                        if i < dparams.Count then tmpx:=dparams.Arr^[i];
                        if tmpx = 0 then
                          dPar[i]:=0.1*(ymax.Arr^[i]-ymin.Arr^[i])
                        else
                          dPar[i]:=tmpx;
                      end;
                      //Начальные критерии качества
                      for i:=0 to NQual-1 do uinputs[i]:=U[0].Arr^[i];
                      //Если стоит режим работы по полной выборке, то выставляем флаг, что нам надо запомнить стартовое состояние
                      if optmode = 0 then begin
                        ModelODEVars.fSaveModelState:=True;
                        goto do_opt_step;
                      end;
                      //Уточнение шага дискретизации
                      if (optmode <> 0) and ModelODEVars.fPreciseSrcStep and (optstep > 0) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(ModelODEVars.newstep,optstep);
                      end;
                    end;
    f_EndTimeTask:  if optmode = 0 then begin
                      //В режиме оптимизации по полному времени процесса, мы делаем следующий вызов конечного автомата оптимизации тут
                      goto do_opt_step;
                    end;
    f_GoodStep:     if optmode <> 0 then begin

                     //Блок срабатывания с заданным шагом
                     tmp_time:=localtime + h;
                     if tmp_time > optstep then begin

                      if optstep > 0 then
                        tmp_time:=tmp_time - Int(tmp_time/optstep)*optstep
                      else
                        tmp_time:=0;
                     // ----
  //##############################################################################
    do_opt_step:
                      // При работе нескольких блоков оптимимизация иногда не завершается
                      if (StopOpt = 1) then exit;

                      //Вызов собственно оптимизации
                      OptimizeMethod.ExecuteStep(
                                    @yparams[0],                  // Массив параметров
                                    @uinputs[0],                  // Массив критериев
                                    NParam,                       // Количество параметров
                                    NQual,                        // Количество критериев
                                    @dPar[0],                     // Текущее приращение параметра оптимизации
                                    yabserror.Arr,                // Точность подбора выходных параметров оптимизации
                                    maxiter,                      // Максимальное к-во итераций при оптимизации
                                    ymin.Arr,                     // Минимальное значение параметра оптимизации
                                    ymax.Arr,                     // Максимальное значение параметра оптимизации
                                    ErrorNum,                     // Код ошибки
                                    StopOpt,                      // Флаг конца оптимизации
                                    otp_step_position);           // Состояние алгоритма оптимизации

                      //Выдаём диагностические сообщения об ошибках оптимизации
                      if ErrorNum <> 0 then
                        case ErrorNum of
                          // Ошибка 'Превышено максимальное число вычислений функции'
                          er_opt_MaxFunEval: ErrorEvent(txt_opt_MaxFunEval + ' (' + IntToStr(maxiter) + ') time='+FloatToStr(at),msError,VisualObject); // превышено максимальное число вычислений функции
                          // Ошибка 'Ошибка инициализации алгоритма оптимизации'
                          er_Opt_InitVal:    ErrorEvent(txt_Opt_InitVal+' time='+FloatToStr(at),msError,VisualObject);    // Ошибка инициализации алгоритма оптимизации
                          // Ошибка 'Ошибка оптимизаци по сходимости'
                          er_opt_Eps:        ErrorEvent(txt_opt_Eps+' time='+FloatToStr(at),msError,VisualObject);        // Ошибка оптимизаци по сходимости
                        end;

                      //В режиме непрерывной динамической оптимизации сбрасываем флаг
                      //остановки оптимизации если мы остановились и сделали ещё один шаг !!!
                      if optmode = 2 then begin
                        if (StopOpt = 1) and (oldstopopt = 1) and (oldoldStopOpt = 1) then
                          StopOpt:=0;
                        oldoldStopOpt:=oldstopopt;
                        oldstopopt:=StopOpt;
                      end
                      else
                      //В полнои режиме оптимизации - выставляем флаг повтора модели, пока она у нас не уложится
                      if optmode = 0 then begin
                        //Если в процессе есть ошибки - то остановка процесса оптимизации, чтобы остановить процесс
                        if ErrorNum <> 0 then StopOpt:=1;
                        //Выставляем флаг остановки
                        ModelODEVars.fStartAgain:=StopOpt = 0;
                        exit;
                      end;

                     end;

                     //Блок срабатывания с заданным шагом
                     //Запоминание счётчика времени
                     localtime:=tmp_time;
                     //--------
                     goto precise_step;
                    end;
  //##############################################################################
                  //Уточнение шага для более точного выставления времени оптимизации
    f_UpdateOuts: if (optmode <> 0) then begin

                     precise_step:

                     if ModelODEVars.fPreciseSrcStep and (optstep > 0) and (optstep > localtime)  then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(min(ModelODEVars.newstep,optstep - localtime),optstep);
                     end;
                  end;
  end
end;
//-------------------------------------------------------------------------------------------------
function TOptimize_new.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var oldoptmode,
     oldoptmethod,
     oldUCount,
     oldYCount: integer;
begin
  //Для режима работы 0 (с циклическим перезапуском модели) не загружаем рестарт !!!
  if optmode = 0 then begin
    Result:=True;
    exit;
  end
  else begin
    //Загружаем входы-выходы
    Result:=inherited  RestartLoad(Stream,Count,TimeShift);
    //Загружаем состояние алгоритма оптимизации
    Stream.Read(oldoptmode,SizeOfInt);
    Stream.Read(oldoptmethod,SizeOfInt);
    Stream.Read(oldUCount,SizeOfInt);
    Stream.Read(oldYCount,SizeOfInt);
    Stream.Read(StopOpt,SizeOfInt);
    Stream.Read(localtime,SizeOfDouble);

    //Проверяем не изменились ли настройки так, что состояние алгоритма оптимизации нельзя загрузить
    if (oldoptmode = optmode) and
       (oldoptmethod = optmethod) and
       (oldUCount = U[0].Count) and
       (oldYCount = Y[0].Count) then begin
          Stream.Read(otp_step_position,SizeOfInt);
          Stream.Read(yparams[0],Length(yparams)*SizeOfDouble);
          Stream.Read(uinputs[0],Length(uinputs)*SizeOfDouble);
          Stream.Read(dPar[0],Length(dPar)*SizeOfDouble);
          Result:=OptimizeMethod.RestartLoad(Stream,Count,TimeShift);
       end;
  end;
end;
//-------------------------------------------------------------------------------------------------
procedure TOptimize_new.RestartSave(Stream: TStream);
begin
  //Для режима работы 0 (с циклическим перезапуском модели) не сохраняем рестарт !!!
  if optmode <> 0 then begin
    //Сохраняем входы-выходы
    inherited  RestartSave(Stream);
    //Сохраняем состояние алгоритма оптимизации
    Stream.Write(optmode,SizeOfInt);
    Stream.Write(optmethod,SizeOfInt);
    Stream.Write(U[0].Count,SizeOfInt);
    Stream.Write(Y[0].Count,SizeOfInt);
    Stream.Write(StopOpt,SizeOfInt);
    Stream.Write(otp_step_position,SizeOfInt);
    Stream.Write(yparams[0],Length(yparams)*SizeOfDouble);
    Stream.Write(uinputs[0],Length(uinputs)*SizeOfDouble);
    Stream.Write(dPar[0],Length(dPar)*SizeOfDouble);
    Stream.Write(localtime,SizeOfDouble);

    //Сохраняем внутреннее состояние алгоритма оптимизации
    OptimizeMethod.RestartSave(Stream);
  end;
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TOptimize_new.DOSETOUTS;
 var i: integer;
begin
  //Выставляем выходы
  for i:=0 to NParam-1 do begin
    if (X[i] < ymin.Arr^[i]) then X[i]:=ymin.Arr^[i];
    if (X[i] > ymax.Arr^[i]) then X[i]:=ymax.Arr^[i];
    Y[0].Arr^[i]:=X[i];
  end;
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TOptimize_new.DOGETQUAL;
const
  fmax=1.0e30;
var
  // Номер параметра
  i : integer;
  // Суммарное качество
  s : realtype;
  // Качество
  q : realtype;
label
  finish;
begin
  //Получаем качество

  if StopOpt = 1 then begin
   FX[NQual]:=0; ///fmax;  -  вообще странная это цифра... С ней алгоритм ПОИСК-2 не останавливается в принципе...
   exit
  end;
  ner:=0;
  if ner > 0 then goto finish;

  // Процедура сворачивания векторного критерия в скалярный (FX[NParam])  }
  for i:=0 to NQual-1 do
    FX[i]:=U[0].Arr^[i];

  s:=0;
  for i:=0 to NQual-1 do begin
    if FX[i]>umax.Arr^[i] then
      q:=(FX[i]-umax.Arr^[i])/(umax.Arr^[i]-umin.Arr^[i])
    else if FX[i] < umin.Arr^[i] then
      q:=(umin.Arr^[i]-FX[i])/(umax.Arr^[i]-umin.Arr^[i])
    else q:=0;

    case usumtype of
     0: s:=s+q;           // Аддитивный
     1: s:=s+q*q;         // Квадратичный
     2: if q>s then s:=q; // Минимаксный
     3: s:=s+ln(q+1);     // Мультипликативный
    end;
  end;

  case usumtype of
    0: FX[NQual]:=s/NQual;        // Аддитивный
    1: FX[NQual]:=sqrt(s/NQual);  // Квадратичный
    2: FX[NQual]:=s;              // Минимаксный
    3: FX[NQual]:=exp(s/NQual)-1; // Мультипликативный
  end;

finish:

  if (ner>0) and (ner<1000) then begin
    FX[NQual] := 0; /// fmax;   Это работает странно ... поэтому поставил 0 тут
    if (StopOpt = -1) then
      StopOpt:=1
  end;

{  else if tOptAlg = 3 then SHTRAF(X,FX); // Это я не знаю откуда осталось. В 3.7 оно было забанено }
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TOptimize_new.DOOUT;
begin
  //Выводим информацию о подобранных параметрах оптимизации и текущих значениях критериев оптимизации
  ErrorEvent(txtOptParametersValue  + GetStrValue(Y[0], dtDoubleArray) +
             txtOptCriteria         + GetStrValue(U[0], dtDoubleArray) +
             ' Состояние: '          + IntToStr(stepout) +
             ' Итерация: '           + IntToStr(NFE), msInfo, VisualObject);
end;
//-------------------------------------------------------------------------------------------------
PROCEDURE TOptimize_new.DOCOMPQUAL;
begin
  if (StopOpt = 1) then
    IC:=3
  else if FY[NQual] < FX[NQual] then
    IC:=2   // F(X2) < F(X1)
  else
    IC:=1;  // F(X2) >= F(X1)

  // TODO: Никогда не сработает???
  if (FY[NQual]=0) then
    StopOpt := 1;
end;
//-------------------------------------------------------------------------------------------------
end.
