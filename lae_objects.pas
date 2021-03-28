
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 
 
unit lae_objects;

 //***************************************************************************//
 //           Блоки для решения глобальной линейной системы                   //
 //               для моделирования узловых задач                             //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, DataObjts, SysUtils, abstract_im_interface, RunObjts, math,
     InterfaceUnit, mbty_std_consts, ext_lae_solver_types, global_lae_solver_register_proc;

const
  {$IFDEF ENG}
    txtMatrixSingular   = 'Matrix of SLAE is singular';
    txtSystemNotDefined = 'SLAE not define';
  {$ELSE}
    txtMatrixSingular   = 'Матрица системы линейных уравнений не определена';
    txtSystemNotDefined = 'Система уравнений не имеет решения';
  {$ENDIF}


type

  //Счётчик к-ва уравнений
  TBaseLAESolveBlock = class(TRunObject)
  protected
    aSolverName:   string;
    LAESolver:     TSolverId;
    LAESolverInterface: PLAESolverAbstractInterface;
    function       RegisterLAESolver:NativeInt;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Счётчик к-ва уравнений
  TEquCounter = class(TBaseLAESolveBlock)
  public
    aEquNumber:    integer;
    aEquCount:     NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Блок записи данных в матрицу коэффициентов уравнения
  TSetLAEKoefs = class(TBaseLAESolveBlock)
  public
    OldKoefs:      array of double;
    IndexArr:      array of integer;
    IJIndex:       integer;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Блок считывания результатов решения СЛАУ
  TGetLAEResult = class(TBaseLAESolveBlock)
  public
    x0:            TExtArray;
    eps:           double;
    mashine_zero:  double;
    f_need_iter:   boolean;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Блока настроек параметров распределённой системы уравнений
  TLAEParamsSetter = class(TBaseLAESolveBlock)
  public
    EInfo:         TElementInfo;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;



implementation

{*******************************************************************************
                    Блок - указатель номера уравнений
*******************************************************************************}
constructor TBaseLAESolveBlock.Create;
begin
  inherited;
  aSolverName:='lae_solver';
end;

destructor  TBaseLAESolveBlock.Destroy;
begin
  inherited;
end;

function    TBaseLAESolveBlock.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'solvername') then begin
      Result:=NativeInt(@aSolverName);
      DataType:=dtString;
    end;
  end
end;

function    TBaseLAESolveBlock.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr:  if aSolverName = '' then begin
       //Проверяем задано ли у нас имя системы
       Result:=r_Fail;
       ErrorEvent(txtSolverNameNotDefined,msError,VisualObject);
    end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function  TBaseLAESolveBlock.RegisterLAESolver;
 var aOldObject: TObject;
     solv_name: ansistring;
begin
  Result:=r_Success;
  LAESolver:=0;
  solv_name:=aSolverName;
  LAESolver:=lae_solver_register(
    ModelODEVars,
    PAnsiChar(solv_name),
    ModelODEVars.DefaultLAESolverLibraryName,
    LAESolverInterface);
  if LAESolver = nil then begin
    Result:=r_Fail;
    ErrorEvent(txtDefineSolverOfOtherType,msError,VisualObject);
  end;
end;

function   TBaseLAESolveBlock.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 //var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
       //Тут мы инициализируем глобальный объект-решатель
       Result:=RegisterLAESolver;
    end;
  end
end;

   //Счётчик уравнений
constructor    TEquCounter.Create(Owner: TObject);
begin
  inherited;
  aEquCount:=1;
  aEquNumber:=0;
end;

function       TEquCounter.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'equcount') then begin
      Result:=NativeInt(@aEquCount);
      DataType:=dtInteger;
    end;
  end
end;

function       TEquCounter.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetBlockType:  Result:=t_src;     //Блок - источник
    i_GetInit:       Result:=1;
    i_GetCount:      cY[0]:=aEquCount;  //Размерность выхода = к-ву уравнений
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function       TEquCounter.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i: integer;
     eq_counter: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
      Result:=inherited RunFunc(at,h,Action);
      if LAESolver <> nil then begin
        eq_counter:=LAESolverInterface.lae_solver_getlaecount(LAESolver);
        aEquNumber:=eq_counter + 1;
        LAESolverInterface.lae_solver_addlaecount(LAESolver,aEquCount);
      end;
    end;
    f_BeforeInitState: for i:=0 to aEquCount - 1 do
                          Y[0][i]:=aEquNumber + i;
  end
end;


 //Блок записи коэффициентов линейных уравнений
function    TSetLAEKoefs.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  //входы 0 - номера строк (уравнений),1 - номера столбцов,2 - значения коэффициентов, 3 - значение правой части
                  cU[3]:=cU[0];
                  cU[2]:=cU[1];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TSetLAEKoefs.RunFunc;
 var
     i,j,n_col,ner,n_row:   integer;
     f_ch_row: boolean;
 label
     do_good_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
      Result:=inherited RunFunc(at,h,Action);
      if (Result = 0) and (LAESolver <> nil) then begin
         //Тут присваиваем себя, чтобы знать когда нам надо решать систему
         LAESolverInterface.lae_solver_setselfptr(LAESolver,Self);
      end;
      //Указываем к-во коэффициентов
      SetLength(IndexArr,cU[1]);
      SetLength(OldKoefs,cU[2]);
      for I := 0 to cU[2] - 1 do OldKoefs[i]:=0.0;
    end;
    f_BeforeInitState:

                    //Если у нас пока нет указателя на модуль решения СЛАУ - определяем его
                    if (LAESolverInterface.lae_solver_getfirstptr(LAESolver) = Self) then begin

                       //Инициализируем к-во уравнений в системе и выделяем на всё память
                       //Именно тут происходит выделение заданного к-ва уравнений
                       LAESolverInterface.lae_solver_begininit(LAESolver);

                    end;

    f_InitState:  begin

                    //Для каждого из блоков записи к-тов инициализируем максимальный объем памяти для каждой из строчек системы (и начальные номера этих строчек)

                    //К-во столбцов на каждое уравнение
                    n_col:=cU[1] div cU[0];

                    //Цикл по строкам (по уравнениям)
                    for I := 0 to cU[0] - 1 do begin
                      n_row:=trunc(U[0].Arr^[i]) - 1;

                      //Заполняем столбец матрицы указанными коэффициентами (нули FillRow отсеивает сама)
                      for j := 0 to n_col - 1 do begin
                        IndexArr[j] := trunc( U[1].Arr^[j*cU[0] + i] ) - 1;
                      end;

                      //Выставляем к-во столбиков и указатели на начальные номера столбиков для каждой из строк матрицы
                      LAESolverInterface.lae_solver_initrow(LAESolver, n_row, n_col, @IndexArr[0]);
                    end;

                    //Собственно переходим к решению
                    goto do_good_step;

                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   begin

do_good_step:

       //Копируем в целый массив (и вычитаем 1 ! поскольку в TSparce нумерация с нуля)
       for j := 0 to cU[1] - 1 do begin
         i:=trunc(U[1].Arr^[j]) - 1;
         if (Action = f_InitState) or (Action = f_RestoreOuts) or (i <> IndexArr[j]) then begin
           LAESolverInterface.lae_solver_setneedsort(LAESolver);
           IndexArr[j]:=i;
         end;
       end;

       //Проверяем изменение коэффициентов - если есть изменения, то выставляем флаг необходимости сделать разложение заново
       //В начальный момент инициализируем всё и всегда !!!
       for j := 0 to cU[2] - 1 do
         if (Action = f_InitState) or (Action = f_RestoreOuts) or (U[2].Arr^[j] <> OldKoefs[j]) then begin
           //Если изменилось к-во нулей - то надо делать пересортировку модели
           if (OldKoefs[j] = 0) or (U[2].Arr^[j] = 0) then
             LAESolverInterface.lae_solver_setzeroschange(LAESolver);
           OldKoefs[j]:=U[2].Arr^[j];
           f_ch_row:=True;
         end;

       //Установка флага необходимости провести заново разложение
       if f_ch_row then LAESolverInterface.lae_solver_setneedlu(LAESolver);

       //К-во столбцов на каждое уравнение
       n_col:=cU[1] div cU[0];

       //Цикл по строкам (по уравнениям)
       for I := 0 to cU[0] - 1 do begin
           n_row:=trunc(U[0].Arr^[i]) - 1;

           //Правая часть
           LAESolverInterface.lae_solver_setrightcol(LAESolver, n_row, U[3].Arr^[i]);

           //Диагностическая информация о том где именно ошибка - тест !!!
           // if isnan(LAESolver.B.Arr^[i]) or (abs(LAESolver.B.Arr^[i]) > 1e10) then
           // Self.ErrorEvent('Error right part j = '+IntToStr(i+1),msError,VisualObject);

           //Левая часть
           if f_ch_row then begin

             //Сброс - обнуление и если надо реаллокация массива если к-во поменялось
             LAESolverInterface.lae_solver_resetrow(LAESolver, n_row, n_col);

             //Заполняем столбец матрицы указанными коэффициентами (нули FillRow отсеивает сама)
             for j := 0 to n_col - 1 do
               LAESolverInterface.lae_solver_fillitem(LAESolver,
                                   n_row,
                                   IndexArr[j*cU[0] + i],
                                   U[2].Arr^[j*cU[0] + i],
                                   1,
                                   j);
           end;
       end;

       //Если система последняя - решаем её тут !!!
       if (LAESolverInterface.lae_solver_getlastptr(LAESolver) = Self) then begin

          //Инициализируем к-во уравнений в системе и выделяем на всё память
          if Action = f_InitState then  LAESolverInterface.lae_solver_endinit(LAESolver);

          //Вычисляем LU-разложение (флаг необходимости этого мы запоминаем и ссбрасываем внутри решателя СЛАУ)
          //Контроль точности разложения может быть и внутри метода решения матриц
          ner:=LAESolverInterface.lae_solver_ludecomp(LAESolver);

          //Вывод ошибки при сингулярной матрице
          if ner > 0 then begin
            ErrorEvent(txtMatrixSingular + ' time='+FloatToStr(at),msError,VisualObject);
            exit;
          end;

          //При восстановлении состояния решения не делаем, чтобы не сбивать значения потенциалов на следующем шаге
          if Action <> f_RestoreOuts then begin

            //Решение системы
            ner:=LAESolverInterface.lae_solver_solve(LAESolver);

          end;

          //Вывод ошибки если решение кривое
          if ner > 0 then
            ErrorEvent(txtSystemNotDefined+' time='+FloatToStr(at),msError,VisualObject);

       end;
    end;
  end
end;


 //Блок считывания результата
constructor    TGetLAEResult.Create(Owner: TObject);
begin
  inherited;
  x0:=TExtArray.Create(1);
  f_need_iter:=True;
  eps:=1e-4;
  mashine_zero:=0;
end;

destructor     TGetLAEResult.Destroy;
begin
  x0.Free;
  inherited;
end;

function    TGetLAEResult.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:  begin
                       //Блок - источник
                       Result:=t_fun;
                     end;
    i_GetInit:       Result:=0;
    i_GetCount:      cY[0]:=cU[0];
                       //Данный блок должен иметь секцию пост-выполнения, т.к. надо получать данные уже вычисленные !
    i_GetPostSection:Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TGetLAEResult.RunFunc;
 var i,j:   integer;
     xx:    double;
     zz:    double;
begin
  Result:=0;
  xx:=0;
  case Action of

    f_InitObjects:
    if NeedRemoteData then begin
      if RemoteDataUnit <> nil then
         RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
    end
    else
    begin
      //Делаем всё остальное
      Result:=inherited RunFunc(at,h,Action);
      //Для блока выставляем флаг необходимости делать предварительный шаг обязательно
      if f_need_iter then begin
         ModelODEVars.fNeedUpdateOutsBeforeGoodStep:=True;
      end;
    end;

    //Пересылаем в метод н.у. если это надо
    f_InitState: if not NeedRemoteData then begin
       for I := 0 to cY[0] - 1 do begin
         if i < x0.Count then xx:=x0.Arr^[i];
         Y[0].Arr^[i]:=xx;
         j:=trunc(U[0].Arr^[i]) - 1;
         LAESolverInterface.lae_solver_setinitresult(LAESolver,j,xx);
       end;
    end;

    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: if not NeedRemoteData then begin
       //
       for I := 0 to cU[0] - 1 do begin
         j:=trunc(U[0].Arr^[i]) - 1;

         //Результат расчёта системы
         zz:=LAESolverInterface.lae_solver_getresult(LAESolver, j);

         // Если для блока надо анализировать сходимость
         if f_need_iter and (Action = f_UpdateOuts) and (ModelODEVars.NLocalIter <= ModelODEVars.MaxLoopIt) then

            //Если эта итерация не нулевая,  то значит мы можем вычислить точность
            if (ModelODEVars.NLocalIter > 0) then begin

              //Рассчитываем точность вычисления переменной
              xx:=zz;
              if abs(xx) > mashine_zero then
                xx:=abs((Y[0].Arr^[i] - xx)/xx)
              else
                xx:=abs(Y[0].Arr^[i] - xx);

              //Если нам надо сделать повтор расчёта - то выставляем соотвествующий флаг
              if xx > eps then ModelODEVars.fNeedIter:=True;
            end
            else
              ModelODEVars.fNeedIter:=True;     //На первом тестовом шаге - обязательный повтор !!!

         //Данные - на выход блока !!!
         Y[0].Arr^[i]:=zz;
       end;

    end;

  end
end;

function       TGetLAEResult.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'eps') then begin
      Result:=NativeInt(@eps);
      DataType:=dtDouble;
    end
    else
    if StrEqu(ParamName,'mashine_zero') then begin
      Result:=NativeInt(@mashine_zero);
      DataType:=dtDouble;
    end
    else
    if StrEqu(ParamName,'f_need_iter') then begin
      Result:=NativeInt(@f_need_iter);
      DataType:=dtBool;
    end
  end
end;

  //Блок установки параметров решателя разреженной СЛАУ
function       TLAEParamsSetter.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetBlockType:  Result:=t_src;     //Блок - источник
    i_GetInit:       Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function       TLAEParamsSetter.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
begin
  Result:=0;
  case Action of
    f_InitObjects: Result:=inherited RunFunc(at,h,Action);
    f_InitState:   if LAESolver <> nil then begin
                     //Присвоение настроек решателя матрицы
                     IElementPlugin(Plugin).GetElementInfo(EInfo);
           {          with TGlobalLAESolver(LAESolver).SP do begin
                       Iter_flag    := AsBoolean(EInfo.Props,'iter_flag',Iter_flag);       // Использовать итерационный метод уточнения
                       TB           := AsDouble(EInfo.Props,'tb',TB);                      // барьер
                       TU           := AsDouble(EInfo.Props,'tu',TU);                      // коэффициент численной устойчивости
                       Rows         := AsInteger(EInfo.Props,'rows',Rows);                 // число просматриваемых строк
                       sp_eps       := AsDouble(EInfo.Props,'sp_eps',sp_eps);              // допустимая относительная ошибка итераций
                       sp_abserr    := AsDouble(EInfo.Props,'sp_abserr',sp_abserr);        // допустимая абсолютная ошибка
                       sp_maxiter   := AsInteger(EInfo.Props,'sp_maxiter',sp_maxiter);     // максималльное к-во итераций для SparceIter
                       sp_errdxstart:= AsDouble(EInfo.Props,'sp_errdxstart',sp_errdxstart);// максимальная начальная ошибка
                     end;    }
                   end;
  end
end;


end.
