
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
 
unit nonlines;

 //***************************************************************************//
 //                      Нелинейные блоки                                     //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math,
     uCircBufferAlgs, mbty_std_consts, InterpolFuncs;


type

  //Решение нелинейного уравнения y=f(y)
  TyFy = class(TRunObject)
  protected
    x0  : TExtArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Решение нелинейного уравнения f(y) = 0
  TFy0 = class(TyFy)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Вычисление численной производной по двум точкам
  TDiff = class(TyFy)
  public
    AX:            TExtArray;  //Вектор внутренних состояний блока
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Идеальное транспортное запаздывание
  TIdealDelay = class(TRunObject)
  protected
    BufPos,
    BufSize,
    Ind,                       //Метка поиска в очереди
    StackCount:       array of NativeInt; //Текущий размер очереди
    Timer:            array of double;
    fcount:           Integer;    //Количество переменных (размерность вектора)
    Stack_t:          TExtArray2; //Очередь для запоминания времени
    Stack_u:          TExtArray2; //Очередь для запоминания значений
    StackInit:        NativeInt;
  public
    Tau:              TExtArray;  //Вектор времён задаздывания
    DiscTau:          TExtArray;  //Дискретность задержки
    PntCnt:           NativeInt;  //Начальное к-во точек стека
    aInterpMethod:    NativeInt;  //Метод интерполяции данных
    aMaxBufferData:   NativeInt;  //Максимальное к-во данных в буфере
    fUseFixedBufSize: boolean;    //Использовать фиксированный размер буфера данных (с пропуском точек)

    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Переменное транспортное запаздывание с расчётом распада
  TVarDelay = class(TRunObject)
  protected
    BufPos,
    BufSize,
    Ind,                        //Метка поиска в очереди
    StackCount:    array of NativeInt; //Текущий размер очереди
    fcount:        Integer;    //Количество переменных (размерность вектора)
    Timer,
    x,                         //Путь на новом шаге
    xold,                      //Путь на предыдущем шаге
    tau0:          array of double; //Начальная задержка
    Stack_t:       TExtArray2; //Очередь для запоминания времени
    Stack_u:       TExtArray2; //Очередь для запоминания значений
    Stack_s:       TExtArray2; //Очередь для запоминания пути
    StackInit:     NativeInt;
  public
    DiscTau:       TExtArray;  //Дискретность задержки
    Lam:           TExtArray;  //Вектор постоянных распада для переменных
    PntCnt:        NativeInt;  //Начальное к-во точек стека
    aInterpMethod: NativeInt;  //Метод интерполяции значений при выборке из буфера
    aMaxBufferData:   NativeInt;  //Максимальное к-во данных в буфере
    fUseFixedBufSize: boolean;    //Использовать фиксированный размер буфера данных (с пропуском точек)
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

 //ЛИНЕЙНОЕ С НАСЫЩЕНИЕМ -
 //Блок реализует нелинейную статическую характеристику типа "насыщение":
 //   y(t) = K*x(t), если a < x(t) < b;
 //   y(t) = y1, если  x(t) <= a;
 //   y(t) = y2, если  x(t) >= b,
 //где К = (y2-y1)/(b-a). Для работы блока необходимо задать параметры a, b, y1, y2.
 TLineLimit = class(TRunObject)
 public
    a:             TExtArray;
    b:             TExtArray;
    y1:            TExtArray;
    y2:            TExtArray;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
 end;

 //Линейное с насыщением и зоной нечувствительности
 //Блок реализует нелинейную статическую характеристику по следующему алгоритму:
 //   y(t) = y1, если  x(t) <= a1;
 //   y(t) = K1*[a - x(t)], если  a1 < x(t) < a;K1=y1/[a-a1]
 //   y(t) = 0, если  a <= x(t) <= b;
 //   y(t) = K2*[x(t) - b], если  b < x(t) < b1;K2=y2/[b1-b]
 //   y(t) = y2, если  x(t) >= b1.
 //Для работы блока необходимо задать параметры a1, a, b, b1, y1, y2.
 TLineLimitInsense = class(TLineLimit)
 public
   a1:            TExtArray;
   b1:            TExtArray;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
 end;


 TCustomRele = class(TRunObject)
 protected
   floadeddim:    integer;
   ax:            array of double;
 public
   y0:            TExtArray;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
 end;

 //Релейное неоднозначное
 //Блок реализует нелинейную статическую характеристикуку типа  "двухпозиционное реле" по следующему алгоритму:
 //Начальное y0 задается как: 0 - выключено (y(0)=y1), 1 - включено (y(0)=y2)
 TRele = class(TCustomRele)
 public
    a:             TExtArray;
    b:             TExtArray;
    y1:            TExtArray;
    y2:            TExtArray;
    f_bad_step:    boolean;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
 end;

 //  Релейная неоднозначная с зоной нечувствительности
 //Блок реализует нелинейную статическую характеристику типа "трехпозиционное реле" по следующему алгоритму:
 //   y(t) = y1, если  x(t) < a1;
 //   y(t) = 0, если  a2 < x(t) < b1;
 //   y(t) = y(t - dt), если a1 <= x(t) <= a2,
 //            или, если  b1 <= x(t) <= b2;
 //   y(t) = y2, если  x(t) > b2;
 //Для работы   блока  необходимо  задать  параметры  нелинейности a1, a2, b1, b2, y1, y2
 //и начальное состояние реле y(0).
 TReleInsense = class(TRele)
 public
    a1:            TExtArray;
    b1:            TExtArray;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
 end;

 //    Линейное с зоной нечувствительности
 //Блок реализует нелинейную статическую характеристику по следующему алгоритму:
 //   y(t) = K*[x(t) - a], если x(t) < a;
 //   y(t) = 0, если a <= x(t) <= b;
 //   y(t) = K*[x(t) - b], если x(t) > b.
 //Для работы блока необходимо задать параметры a, b и К.
 TLineInsense = class(TRunObject)
 public
   a:              TExtArray;
   b:              TExtArray;
   k:              TExtArray;
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   constructor     Create(Owner: TObject);override;
   destructor      Destroy;override;
 end;

 //Производная с ограничением
  TDiffLimit = class(TDiff)
  public
    a:             TExtArray;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Кусочно - статическая характеристика
  //Свойства:  t - точка по времени (вектор)
  //           y - значение точки (вектор)
  TLomStatic = class(TRunObject)
  public
    t:             TExtArray;
    y_:            TExtArray;
    i_number:      NativeInt;    //Текущий номер временного интервала
    extrapolation: boolean;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Минимальное\максимальное текущее значение сигнала
  TMinMax = class(TRunObject)
  public
    ax:            array of double;
    op_type:       NativeInt;   //Тип блока: 0 - минимум, 1 - максимум
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Минимальный или максимальный порт
  TMinMaxU = class(TRunObject)
  public
    op_type:       NativeInt;   //Тип блока: 0 - минимум, 1 - максимум
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Минимальный элемент векторов
  TMinMaxAll = class(TMinMaxU)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Излом
  TIzlom = class(TRunObject)
  public
    k1:            TExtArray;
    k2:            TExtArray;
    x0:            TExtArray;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Квантователь по уровню
  TValueQuant = class(TRunObject)
  public
    step:          TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //  Зазор
  //Блок реализует нелинейную статическую характеристику типа "зазор" по следующему алгоритму:
  //  y(t) = K*[x(t) - b], если x(t) > [y(t - dt)/ K + b];
  //  y(t) = K*[x(t) +b], если x(t) < [y(t - dt)/ K  - b];
  //  y(t) = y(t - dt), если [y(t - dt)/ K  - b] <= x(t) <= [y(t - dt)/ K + b],
  //где dt - предыдущий временной шаг интегрирования. Для работы блока необходимо
  //задать половину  ширины  зазора  b, коэффициент К и начальное состояние выхода  y(0).
  TZazor = class(TCustomRele)
  public
    b:             TExtArray;
    k:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;


  //  Люфт
  //Блок реализует нелинейную статическую характеристику типа  "люфт"  по следующему алгоритму:
  //   y(t) = y1, если  x(t) <= [y1/ K - b];
  //  y(t) = y2, если  x(t) >= [y2/ K + b];
  //  y(t) = K*[x(t) - b], если [y(t - dt)/ K + b] < x(t) < [y2/ K + b];
  //  y(t) = K*[x(t) +b], если [y1/ K - b] < x(t) < [y(t - dt)/ K  - b];
  //  y(t) = y(t - dt),
  //  если [y(t - dt)/ K  - b] <= x(t) <= [y(t - dt)/ K + b],
  //где dt - предыдущий временной шаг интегрирования.
  //Для работы блока необходимо задать половину  ширины  зазора  b,
  //значения параметров насыщения y1 и y2, коэффициент К и
  //начальное состояние выхода  y(0).
  TLuft = class(TZazor)
  public
    y1:            TExtArray;
    y2:            TExtArray;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  // Импульсная функция
  TImpulseFunc = class(TCustomRele)
  protected
    ptau:          array of double;
  public
    tau:           TExtArray;
    tFun:          NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

 // Запоминание входного сигнала при условии ненулевого второго сигнала
 TValueMem = class(TRunObject)
 protected
    ax:            array of double;
 public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

 //Запоминание времени, в течение которого входной сигнал - истина
 TTimeMem = class(TValueMem)
 public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //Блок многомерной линейной интерполяции
 TNDimInterpolation = class(TRunObject)
 public
   tmpxp:         TExtArray2;
   outmode:       NativeInt;
   method:        NativeInt;
   x_:            TExtArray2;
   val_:          TExtArray;
   u_,v_:         TExtArray;
   ad_,k_:        TIntArray;
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
 end;


implementation

{*******************************************************************************
Блок реализует решение системы НАУ вида Y=F(Y).
В процессе решения вектор выходов Y подбирается таким образом,
чтобы вектор входов в блок U был равным Y.
Параметры блока :
 x0 - вектор начальных приближений состояний векторного выхода  Y(0).
*******************************************************************************}
constructor TyFy.Create;
begin
  inherited;
  x0:=TExtArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TyFy.Destroy;
begin
  inherited;
  x0.Free;
end;

function    TyFy.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TyFy.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:      begin
                      cU[0]:=x0.Count;
                      cY[0]:=cU[0];
                     end;
    i_GetBlockType : Result:=t_fun;
    i_GetAlgCount  : Result:=x0.Count;
    i_GetInit:       Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TyFy.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitAlgState: begin
                      for i:=0 to x0.count-1 do begin
                        Xalg[i]:=x0[i];
                        Y[0][i]:=Xalg[i];
                      end;
                    end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:     if not NeedRemoteData then
                       for i:=0 to x0.count-1 do Y[0][i]:=Xalg[i];
    f_GetAlgFun:    if NeedRemoteData then
                       for i:=0 to x0.count-1 do Falg[i]:=0   //Если внешняя отладки - то НАУ не решаем
                    else
                       for i:=0 to x0.count-1 do Falg[i]:=U[0][i]-Xalg[i];

  end
end;

//Решение нелинейного уравнения f(y) = 0
function   TFy0.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitAlgState: begin
                      for i:=0 to x0.count-1 do begin
                        Xalg[i]:=x0[i];
                        Y[0][i]:=Xalg[i];
                      end;
                    end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:     if not NeedRemoteData then
                      for i:=0 to x0.count-1 do Y[0][i]:=Xalg[i];
    f_GetAlgFun:    if NeedRemoteData then
                      for i:=0 to x0.count-1 do Falg[i]:=0  //Если внешняя отладки - то НАУ не решаем
                    else
                      for i:=0 to x0.count-1 do Falg[i]:=U[0][i];
                    
  end
end;

{*******************************************************************************
                 Вычисление производной сигнала
*******************************************************************************}

constructor TDiff.Create;
begin
  inherited;
  AX:=TExtArray.Create(1);
end;

destructor  TDiff.Destroy;
begin
  inherited;
  AX.Free;
end;

function    TDiff.InfoFunc;
begin
  case Action of
    i_GetBlockType : Result:=t_der;
    i_GetAlgCount  : Result:=0;
    i_GetInit      : Result:=0;
    i_GetCount     : cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TDiff.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'state_') then begin
      Result:=11;
      DataType:=dtDoubleArray
   end
  end;
end;

function       TDiff.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=AX[i];
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

function   TDiff.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j : Integer;
    tmpx: Double;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      AX.Count:=cU[0] + 2;
                      //Добавление отладочных переменных
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
    f_InitState:    begin
                      tmpx:=0;
                      for j:=0 to cU[0]-1 do begin
                        AX[j]:=U[0].arr^[j];
                        if j < x0.Count then
                          tmpx:=x0.Arr^[j];
                        Y[0].Arr^[j]:=tmpx;
                      end;
                      AX[cU[0]]:=at;  //Запоминаем время
                      AX[cU[0]+1]:=0;
                    end;
    //Вот это надо для того, чтобы нормально посчитать аналитически этот блок при частотном анализе
    //f_UpdateJacoby: Move(U[0].arr^,Y[0].arr^,U[0].Count*SizeOfDouble);
    //Расчёт производной
    f_UpdateOuts,
    f_GoodStep:     if not NeedRemoteData then begin
                      //Вывод на промежуточном шаге
                      if (at-AX[cU[0]]) > 0 then begin
                        for j:=0 to cU[0]-1 do
                          Y[0].arr^[j]:=(U[0].arr^[j]-AX[j])/(at-AX[cU[0]]);
                        //Запоминание состояний на хорошем шаге
                        if Action = f_GoodStep then begin
                          for j:=0 to cU[0]-1 do AX[j]:=U[0].arr^[j];
                          AX[cU[0]+1]:=at-AX[cU[0]];
                          AX[cU[0]]:=at;
                        end
                      end;
                    end;
  end
end;

procedure  TDiff.RestartSave(Stream: TStream);
begin
  inherited;
  SaveData(AX,dtDoubleArray,Stream); //Запоминаем массив внутренних состояний блока
end;

function   TDiff.RestartLoad;
 var c: integer;
begin
  c:=0;
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then begin
    if Count > 0 then
      try
        c:=AX.Count;
        LoadData(AX,dtDoubleArray,Stream);
      finally
        AX.Count:=c;   //Это чтобы не менялось к-во переменных состояния
      end;
    //Сдвиг запомненного модельного времени
    AX[x0.Count]:=AX[x0.Count] - TimeShift;
  end;
end;

{*******************************************************************************
                    Идеальное транспортное запаздывание
*******************************************************************************}

constructor TIdealDelay.Create;
begin
  inherited;
  aInterpMethod:=0;
  StackInit:=0;
  PntCnt:=4096;
  Stack_t:=TExtArray2.Create(1,1);
  Stack_u:=TExtArray2.Create(1,1);
  Tau:=TExtArray.Create(1);
  DiscTau:=TExtArray.Create(1);
  fUseFixedBufSize:=False;
  aMaxBufferData:=0;
end;

destructor  TIdealDelay.Destroy;
begin
  inherited;
  Stack_t.Free;
  Stack_u.Free;
  Tau.Free;
  DiscTau.Free;
end;

function    TIdealDelay.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'distau') then begin
      Result:=NativeInt(DiscTau);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'interpmethod') then begin
      Result:=NativeInt(@aInterpMethod);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'stackinit') then begin
      Result:=NativeInt(@StackInit);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'stacksize') then begin
      Result:=NativeInt(@PntCnt);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'maxsize') then begin
      Result:=NativeInt(@aMaxBufferData);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'fixedbuffer') then begin
      Result:=NativeInt(@fUseFixedBufSize);
      DataType:=dtBool;
    end
  end
end;


function    TIdealDelay.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetBlockType : Result:=t_del;
    i_GetAlgCount  : Result:=0;
    i_GetCount     : begin
                       CY.arr^[0]:=Tau.Count;
                       CU.arr^[0]:=Tau.Count
                     end;
    i_GetPropErr   : for i:=0 to Tau.Count - 1 do if Tau[i] < 0 then begin
                       ErrorEvent(txtDelayErr,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;

  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

  //Функция расширения буфера
function DoExpandIdealDelayData(aHandle: Pointer;ArrNum,OldBufSize: NativeInt):NativeInt;
begin
  if TIdealDelay(aHandle).fUseFixedBufSize then
    Result:=OldBufSize
  else begin
    Result:=2*OldBufSize;
    if (TIdealDelay(aHandle).aMaxBufferData > 0) and (Result > TIdealDelay(aHandle).aMaxBufferData) then
      Result:=TIdealDelay(aHandle).aMaxBufferData;
    TIdealDelay(aHandle).Stack_t.Arr^[ArrNum].Count:=Result;
    TIdealDelay(aHandle).Stack_u.Arr^[ArrNum].Count:=Result;
  end;
end;

function   TIdealDelay.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j,i :  NativeInt;
    tmpd:  double;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем начальный размер стека блока - чтобы был не менее 1
                      fcount:=Tau.Count;
                      SetLength(Ind,fcount);
                      SetLength(BufPos,fcount);
                      SetLength(BufSize,fcount);
                      SetLength(StackCount,fcount);
                      SetLength(Timer,fcount);
                      Stack_u.CountX:=fcount;
                      Stack_t.CountX:=fcount;
                      //Установка размеров буферов данных задержки BufSize[j]:
                      for j := 0 to fcount - 1 do begin
                         //Рассчитываем требуемый размер буфера исходя из задержки
                         if Tau.Arr^[j] > 0 then begin
                           if DiscTau.Arr^[j] > 0 then
                             i:=trunc(Tau.Arr^[j]/DiscTau.Arr^[j]) + 1            //К-во если задана дискретность
                           else
                             i:=trunc(Tau.Arr^[j]/ModelODEVars.Hmax) + 1;         //К-во для непрерывного блока при максимальном шаге
                         end
                         else
                           i:=1;
                         //Делаем запас для буфера по параметру
                         if (i < PntCnt) or ((PntCnt > 0) and fUseFixedBufSize) then i:=PntCnt;
                         if (aMaxBufferData > 0) and (i > aMaxBufferData) then i:=aMaxBufferData;
                         //Записываем в BufSize[j]
                         BufSize[j]:=i;
                         //Выделяем память
                         Stack_u[j].Count:=i;
                         Stack_t[j].Count:=i;
                      end;
                      //Указываем адрес для удалённой отладки
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
    f_InitState:    begin
                      //Записываем в стек начальное состояние
                      for j:=0 to fcount-1 do begin
                        Ind[j]:=0;
                        BufPos[j]:=1;
                        StackCount[j]:=1;
                        Stack_t[j].Arr^[0]:=at;
                        Timer[j]:=at + DiscTau[j];
                        if StackInit = 1 then
                          tmpd:=0
                        else
                          tmpd:=U[0].Arr^[j];
                        Stack_u[j].Arr^[0]:=tmpd;
                        Y[0].Arr^[j]:=tmpd;
                      end;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if (not NeedRemoteData) then begin

                      for j:=0 to fcount-1 do begin

                         //Интерполяция по кольцевому буферу
                         CircLineInterpol(at - TAU.Arr^[j],
                                          Stack_t.Arr[j].Arr,
                                          [Stack_u.arr^[j].Arr],
                                          StackCount[j],
                                          Ind[j],
                                          BufPos[j],
                                          BufSize[j],
                                          [@Y[0].arr^[j]],
                                          aInterpMethod
                                          );

//         Это добавим потом ...
//                         if ModelODEVars.fPreciseSrcStep and (TAU.Arr^[j] > 0) then begin
//                            ModelODEVars.fsetstep:=True;
//                            ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(Timer[j] - at,0)),TAU.Arr^[j]);
//                         end;

                         if Action = f_GoodStep then begin

                           //Дискретизация задержки - пишем в буфер не каждый шаг, а только то, что нам интересно
                           if (Timer[j] - at <= 0.5*h) then begin
                             //Пересчитываем линейный размер данных, которые нам надо
                             i:=StackCount[j] - Ind[j];
                             //Добавляем новые точки в буфер
                             if CircAddPoint(Self,j,
                                          at,[@U[0].Arr^[j]],
                                          @Stack_t.Arr[j].Arr,[@Stack_u.Arr[j].Arr],
                                          i,
                                          BufPos[j],
                                          BufSize[j],
                                          DoExpandIdealDelayData)
                             then
                               StackCount[j]:=i;

                             //Инкремент времени дискретизации задержки
                             Timer[j]:=Timer[j] + DiscTau[j];
                           end;

                         end;
                      end;

                    end;
  end
end;

procedure  TIdealDelay.RestartSave(Stream: TStream);
 var j:integer;
     emptyd: double;
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  //Размерность блока
  Stream.Write(fcount,SizeOf(integer));

  //Идентификатор версии рестарта блока ( < 0)
  emptyd:=-1;
  Stream.Write(emptyd,SizeOf(double));

  for j:=0 to fcount - 1 do
    Stream.Write(BufSize[j],SizeOf(integer));

  for j:=0 to fcount - 1 do begin
    Stream.Write(Stack_t[j].Arr^[0],SizeOf(double)*BufSize[j]);
    Stream.Write(Stack_u[j].Arr^[0],SizeOf(double)*BufSize[j]);
  end;

  //Дополнительные данные для нового формата - счётчик дискретного времени, указатель и размер кольцевого буфера
  for j:=0 to fcount - 1 do begin
    Stream.Write(BufPos[j],SizeOf(integer));
    Stream.Write(StackCount[j],SizeOf(integer));
    Stream.Write(Timer[j],SizeOf(double));
  end;
end;

function   TIdealDelay.RestartLoad;
 var c,i,j,oldscount,k: integer;
     emptyd: double;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      oldscount:=Length(StackCount);
      //Размерность данных
      Stream.Read(c,SizeOf(integer));

      //Идентификатор версии рестарта  (< 0)
      Stream.Read(emptyd,SizeOf(double));

      //Выделяем память под эту размерность если нам надо
      if oldscount < c then begin
        Stack_t.CountX:=c;
        Stack_u.CountX:=c;
        SetLength(StackCount,c);
        SetLength(BufPos,c);
        SetLength(BufSize,c);
        SetLength(Timer,c);
      end;

      for i:=0 to c - 1 do begin
        StackCount[i]:=0;
        Stream.Read(BufSize[i],SizeOf(integer));
      end;

      for i:=0 to c - 1 do begin
        Stack_t[i].Count:=BufSize[i];
        Stack_u[i].Count:=BufSize[i];
        Stream.Read(Stack_t[i].Arr^[0],SizeOf(double)*BufSize[i]);
        Stream.Read(Stack_u[i].Arr^[0],SizeOf(double)*BufSize[i]);
      end;

      //Считывание дополнительных данных рестарта
      if emptyd < 0 then begin
        for i:=0 to c - 1 do begin
          BufPos[i]:=0;
          Stream.Read(BufPos[i],SizeOf(integer));
          StackCount[i]:=0;
          Stream.Read(StackCount[i],SizeOf(integer));
          Stream.Read(Timer[i],SizeOf(double));
          Timer[i]:=Timer[i] - TimeShift;
        end
      end
      else begin
        for i:=0 to c - 1 do begin
          BufPos[i]:=0;
          BufSize[i]:=StackCount[i];
        end;
      end;

      //Сдвиг модельного времени для блока запаздывания (для рассматриваемого диапазона)
      for i:=0 to c - 1 do begin
        for j:=0 to StackCount[i] - 1 do begin
          k:=GetCircIndex(j,StackCount[i],BufPos[i],BufSize[i]);
          Stack_t[i].Arr^[k]:=Stack_t[i].Arr^[k] - TimeShift;
        end;
      end;

    finally
      //Если новая размерность меньше той, что была в рестарте
      if oldscount < c then begin
        Stack_t.CountX:=oldscount;
        Stack_u.CountX:=oldscount;
        SetLength(StackCount,oldscount);
        SetLength(BufPos,oldscount);
        SetLength(BufSize,oldscount);
        SetLength(Timer,oldscount);
      end;
    end
end;

function      TIdealDelay.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
begin
  Result:=0;
  case Action of
     f_GetDelayTime: if (Index >=0) and (Index < Tau.Count) then x^[0]:=Tau.Arr^[Index] else x^[0]:=0;
  end;
end;

{*******************************************************************************
                    Переменное транспортное запаздывание
*******************************************************************************}

constructor TVarDelay.Create;
begin
  inherited;
  aInterpMethod:=0;
  StackInit:=0;
  PntCnt:=4096;
  Stack_t:=TExtArray2.Create(1,1);
  Stack_u:=TExtArray2.Create(1,1);
  Stack_s:=TExtArray2.Create(1,1);
  DiscTau:=TExtArray.Create(1);
  Lam:=TExtArray.Create(1);
  fUseFixedBufSize:=False;
  aMaxBufferData:=0;
end;

destructor  TVarDelay.Destroy;
begin
  inherited;
  Stack_t.Free;
  Stack_u.Free;
  Stack_s.Free;
  Lam.Free;
  DiscTau.Free;
end;

function    TVarDelay.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'lam') then begin
      Result:=NativeInt(Lam);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'distau') then begin
      Result:=NativeInt(DiscTau);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'interpmethod') then begin
      Result:=NativeInt(@aInterpMethod);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'stackinit') then begin
      Result:=NativeInt(@StackInit);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'stacksize') then begin
      Result:=NativeInt(@PntCnt);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'maxsize') then begin
      Result:=NativeInt(@aMaxBufferData);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'fixedbuffer') then begin
      Result:=NativeInt(@fUseFixedBufSize);
      DataType:=dtBool;
    end
  end
end;


function    TVarDelay.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType : Result:=t_del;
    i_GetAlgCount  : Result:=0;
    i_GetCount     : begin
                       CY.arr^[0]:=Lam.Count;
                       CY.Arr^[1]:=Lam.Count;
                       CU.arr^[0]:=Lam.Count;
                       CU.Arr^[1]:=Lam.Count;
                     end;

  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

  //Функция расширения буфера
function DoExpandVarDelayData(aHandle: Pointer;ArrNum,OldBufSize: NativeInt):NativeInt;
begin
  if TVarDelay(aHandle).fUseFixedBufSize then
    Result:=OldBufSize
  else begin
    Result:=2*OldBufSize;
    if (TVarDelay(aHandle).aMaxBufferData > 0) and (Result > TVarDelay(aHandle).aMaxBufferData) then
      Result:=TVarDelay(aHandle).aMaxBufferData;
    TVarDelay(aHandle).Stack_t.Arr^[ArrNum].Count:=Result;
    TVarDelay(aHandle).Stack_u.Arr^[ArrNum].Count:=Result;
    TVarDelay(aHandle).Stack_s.Arr^[ArrNum].Count:=Result;
  end;
end;

function   TVarDelay.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j,i :   NativeInt;
    t_tmp,
    u_tmp,
    tt:     double;
const
      x0  = 0.0;   //Начальная координата трубы
      L   = 1;     //Условная транспортная длина
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем начальный размер стека блока - чтобы был не менее 1
                      fcount:=CY.arr^[0];
                      SetLength(Ind,fCount);
                      SetLength(BufPos,fCount);
                      SetLength(BufSize,fCount);
                      SetLength(StackCount,fCount);
                      SetLength(Timer,fCount);
                      SetLength(x,fCount);
                      SetLength(xold,fCount);
                      SetLength(tau0,fCount);
                      Stack_u.CountX:=fCount;
                      Stack_t.CountX:=fCount;
                      Stack_s.CountX:=fCount;
                      //Установка размеров буферов данных задержки BufSize[j]:
                      for j := 0 to fCount - 1 do begin
                         //Рассчитываем требуемый размер буфера исходя из задержки
                         if U[1].Arr^[j] > 0 then begin
                           if DiscTau.Arr^[j] > 0 then
                             i:=trunc(U[1].Arr^[j]/DiscTau.Arr^[j]) + 1            //К-во если задана дискретность
                           else
                             i:=trunc(U[1].Arr^[j]/ModelODEVars.Hmax) + 1;         //К-во для непрерывного блока при максимальном шаге
                         end
                         else
                           i:=1;
                         //Делаем запас для буфера по параметру
                         if (i < PntCnt) or ((PntCnt > 0) and fUseFixedBufSize) then i:=PntCnt;
                         if (aMaxBufferData > 0) and (i > aMaxBufferData) then i:=aMaxBufferData;
                         //Записываем в BufSize[j]
                         BufSize[j]:=i;
                         //Выделяем память
                         Stack_u[j].Count:=i;
                         Stack_t[j].Count:=i;
                         Stack_s[j].Count:=i;
                      end;
                      //Указываем адрес для удалённой отладки
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
    f_InitState:    begin
                      //Записываем в стек начальное состояние
                      for j:=0 to fCount-1 do begin
                        Ind[j]:=0;
                        StackCount[j]:=1;
                        x[j]:=0;
                        xold[j]:=0;
                        tau0[j]:=U[1].arr^[j];
                        BufPos[j]:=1;
                        Timer[j]:=at + DiscTau[j];
                        if StackInit = 1 then
                          tt:=0
                        else
                          tt:=U[0].Arr^[j];
                        Y[0].Arr^[j]:=tt*exp(-Lam.arr^[j]*tau0[j]);
                        Y[1].Arr^[j]:=tau0[j];
                        Stack_t[j].Arr^[Ind[j]]:=at;
                        Stack_u[j].Arr^[Ind[j]]:=tt;
                        Stack_s[j].Arr^[Ind[j]]:=x0;  //Начальный путь = 0
                      end;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if (not NeedRemoteData) then begin

                      //Вычисляем значение пути на текущем шаге интегрирования
                      //путём интегрирования по методу Эйлера
                      for j:=0 to fCount-1 do begin

                        //Сначала рассчитываем текущий путь
                        if U[1].Arr^[j] > 0 then
                          x[j]:=xold[j] + L/U[1].Arr^[j]*h
                        else begin
                          x[j]:=xold[j];
                        end;

                        //Интерполяция по кольцевому буферу
                        CircLineInterpol( x[j] - L,
                                          Stack_s.Arr[j].Arr,
                                         [Stack_t.arr^[j].Arr,Stack_u.arr^[j].Arr],
                                          StackCount[j],
                                          Ind[j],
                                          BufPos[j],
                                          BufSize[j],
                                          [@t_tmp,@u_tmp],
                                          aInterpMethod
                                          );

                        //Вычисляем значение времени запаздывания
                        if x[j] >= L then
                          tt:=at - t_tmp
                        else
                          tt:=at - tau0[j]*(x[j] - L);

                        //Вывод текущего времени запаздывания
                        Y[1].arr^[j]:=tt;

                        //Вычисляем значение величины с учётом распада (распад - экспоненциальный)
                        if Lam.Arr^[j] <> 0 then
                          Y[0].Arr^[j]:=u_tmp*exp(-Lam.Arr^[j]*tt)
                        else
                          Y[0].Arr^[j]:=u_tmp;

                        //Запоминание нового значения в буфер запаздывания
                        if Action = f_GoodStep then begin
                           //Дискретизация задержки - пишем в буфер не каждый шаг, а только то, что нам интересно
                           if (Timer[j] - at <= 0.5*h) then begin
                             //Пересчитываем линейный размер данных, которые нам надо
                             i:=StackCount[j] - Ind[j];
                             //Добавляем новые точки в буфер
                             if CircAddPoint(Self,j,
                                          x[j],[@at,@U[0].Arr^[j]],
                                          @Stack_s.Arr[j].Arr,[@Stack_t.Arr[j].Arr,@Stack_u.Arr[j].Arr],
                                          i,
                                          BufPos[j],
                                          BufSize[j],
                                          DoExpandVarDelayData)
                             then
                               StackCount[j]:=i;

                             //Инкремент времени дискретизации задержки
                             Timer[j]:=Timer[j] + DiscTau[j];
                           end;

                           //Присваиваем старому значению пути новое
                           xold[j]:=x[j];
                        end;

                      end;

                    end;
  end
end;

procedure  TVarDelay.RestartSave(Stream: TStream);
  var j: integer;
      emptyd: double;
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(fcount,SizeOf(integer));

  //Идентификатор версии рестарта
  emptyd:=-1;
  Stream.Write(emptyd,SizeOf(double));

  //Размер буфера
  for j:=0 to fCount - 1 do
    Stream.Write(BufSize[j],SizeOf(integer));

  Stream.Write(xold[0],SizeOf(double)*fCount);
  for j:=0 to fCount - 1 do begin
    Stream.Write(Stack_t[j].Arr^[0],SizeOf(double)*BufSize[j]);
    Stream.Write(Stack_u[j].Arr^[0],SizeOf(double)*BufSize[j]);
    Stream.Write(Stack_s[j].Arr^[0],SizeOf(double)*BufSize[j]);
  end;

  //Дополнительные данные для нового формата - счётчик дискретного времени, указатель и размер кольцевого буфера
  for j:=0 to fCount - 1 do begin
    Stream.Write(BufPos[j],SizeOf(integer));
    Stream.Write(StackCount[j],SizeOf(integer));
    Stream.Write(Timer[j],SizeOf(double));
    Stream.Write(tau0[j],SizeOf(double));
  end;
end;

function   TVarDelay.RestartLoad;
 var c,i,j,oldscount,k: integer;
     emptyd: double;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOf(integer));

      //Идентификатор формата рестарта
      Stream.Read(emptyd,SizeOf(double));

      oldscount:=Length(StackCount);
      if oldscount < c then begin
        Stack_t.CountX:=c;
        Stack_u.CountX:=c;
        Stack_s.CountX:=c;
        SetLength(StackCount,c);
        SetLength(BufPos,c);
        SetLength(BufSize,c);
        SetLength(Timer,c);
        SetLength(tau0,c);
      end;

      for i:=0 to c - 1 do begin
        BufSize[i]:=0;
        Stream.Read(BufSize[i],SizeOf(integer));
      end;

      Stream.Read(xold[0],SizeOf(double)*c);
      for i:=0 to c - 1 do begin
        Stack_t[i].Count:=BufSize[i];
        Stack_u[i].Count:=BufSize[i];
        Stack_s[i].Count:=BufSize[i];
        Stream.Read(Stack_t[i].Arr^[0],SizeOf(double)*BufSize[i]);
        Stream.Read(Stack_u[i].Arr^[0],SizeOf(double)*BufSize[i]);
        Stream.Read(Stack_s[i].Arr^[0],SizeOf(double)*BufSize[i]);
      end;

      //Считывание дополнительных данных рестарта
      if emptyd < 0 then begin
        for i:=0 to c - 1 do begin
          BufPos[i]:=0;
          Stream.Read(BufPos[i],SizeOf(integer));
          StackCount[i]:=0;
          Stream.Read(StackCount[i],SizeOf(integer));
          Stream.Read(Timer[i],SizeOf(double));
          Timer[i]:=Timer[i] - TimeShift;
          Stream.Read(tau0[i],SizeOf(double));
        end
      end
      else begin
        //Для совместимости со старым вариантом линейного буфера задержки
        for i:=0 to c - 1 do begin
          BufPos[i]:=0;
          StackCount[i]:=BufSize[i];
        end;
      end;

      //Сдвиг модельного времени для блока запаздывания (для рассматриваемого диапазона)
      for i:=0 to c - 1 do begin
        for j:=0 to StackCount[i] - 1 do begin
          k:=GetCircIndex(j,StackCount[i],BufPos[i],BufSize[i]);
          Stack_t[i].Arr^[k]:=Stack_t[i].Arr^[k] - TimeShift;
        end;
      end;

    finally
      if oldscount < c then begin
        Stack_t.CountX:=oldscount;
        Stack_u.CountX:=oldscount;
        Stack_s.CountX:=oldscount;
        SetLength(StackCount,oldscount);
        SetLength(BufPos,oldscount);
        SetLength(BufSize,oldscount);
        SetLength(Timer,oldscount);
        SetLength(tau0,oldscount);
      end;
    end
end;

function      TVarDelay.GetDisData;
begin
  Result:=0;
  case Action of
     f_GetDelayTime: if (Index >=0) and (Index < Y[1].Count) then x^[0]:=Y[1].arr^[Index] else x^[0]:=0;
  end;
end;


{*******************************************************************************
                    Линейное звено с насыщением
*******************************************************************************}
constructor  TLineLimit.Create(Owner: TObject);
begin
  inherited;
  a:=TExtArray.Create(1);
  b:=TExtArray.Create(1);
  y1:=TExtArray.Create(1);
  y2:=TExtArray.Create(1);
end;

destructor   TLineLimit.Destroy;
begin
  inherited;
  a.Free;
  b.Free;
  y1.Free;
  y2.Free;
end;

function    TLineLimit.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TLineLimit.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'y1') then begin
      Result:=NativeInt(y1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'y2') then begin
      Result:=NativeInt(y2);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLineLimit.RunFunc;
 var j: integer;
     a_,b_,y1_,y2_: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for j:=0 to Y[0].Count-1 do begin
                    a.TryGet(j,a_);
                    b.TryGet(j,b_);
                    y1.TryGet(j,y1_);
                    y2.TryGet(j,y2_);
                    if U[0].arr^[j] <= a_ then Y[0].arr^[j]:=y1_
                      else if U[0].arr^[j] >= b_ then Y[0].arr^[j]:=y2_
                        else Y[0].arr^[j]:=y1_+(y2_-y1_)/(b_-a_)*(U[0].arr^[j]-a_);
                  end;
  end
end;

{*******************************************************************************
            Линейное звено с насыщением и зоной нечувствительности
*******************************************************************************}
constructor TLineLimitInsense.Create(Owner: TObject);
begin
  inherited;
  a1:=TExtArray.Create(1);
  b1:=TExtArray.Create(1);
end;

destructor  TLineLimitInsense.Destroy;
begin
  inherited;
  a1.Free;
  b1.Free;
end;

function    TLineLimitInsense.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a1') then begin
      Result:=NativeInt(a1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'b1') then begin
      Result:=NativeInt(b1);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLineLimitInsense.RunFunc;
 var j: integer;
     a_,b_,y1_,y2_,a1_,b1_: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for j:=0 to Y[0].Count-1 do begin

                   a.TryGet(j,a_);
                   b.TryGet(j,b_);
                   a1.TryGet(j,a1_);
                   b1.TryGet(j,b1_);
                   y1.TryGet(j,y1_);
                   y2.TryGet(j,y2_);

                   if U[0].arr^[j] <= a1_ then
                     Y[0].arr^[j]:=y1_
                   else if U[0].arr^[j] >= b1_ then
                     Y[0].arr^[j]:=y2_
                   else if (U[0].arr^[j] > a1_) and (U[0].arr^[j] < a_) then
                     Y[0].arr^[j]:=y1_*(a_-U[0].arr^[j])/(a_-a1_)
                   else if (U[0].arr^[j] > b_) and (U[0].arr^[j] < b1_) then
                     Y[0].arr^[j]:=y2_*(U[0].arr^[j]-b_)/(b1_-b_)
                   else
                     Y[0].arr^[j]:=0;
                  end;

  end
end;

  //Произвольное реле
constructor   TCustomRele.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
end;

destructor    TCustomRele.Destroy;
begin
  inherited;
  y0.Free;
end;

function      TCustomRele.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function       TCustomRele.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'state_') then begin
      Result:=11;
      DataType:=dtDoubleArray
   end
  end;
end;

function       TCustomRele.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=Length(ax);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=ax[i];
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

procedure   TCustomRele.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(y0.Count,SizeOf(integer));
  Stream.Write(ax[0],y0.Count*SizeOfDouble);
end;

function   TCustomRele.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      //Загрузка к-ва данных
      Stream.Read(c,SizeOf(integer));
      floadeddim:=c;
      //Загрузка данных
      spos:=Stream.Position;
      Stream.Read(ax[0],min(Length(ax),c)*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;
    finally
    end
end;

{*******************************************************************************
                       Релейное неоднозначное
*******************************************************************************}
constructor TRele.Create(Owner: TObject);
begin
  inherited;
  f_bad_step:=True;   //По умолчанию реле исполняется на любых шагах
  a:=TExtArray.Create(1);
  b:=TExtArray.Create(1);
  y1:=TExtArray.Create(1);
  y2:=TExtArray.Create(1);
end;

destructor  TRele.Destroy;
begin
  inherited;
  a.Free;
  b.Free;
  y1.Free;
  y2.Free;
end;

function    TRele.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=cU[0];
                end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TRele.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'y1') then begin
      Result:=NativeInt(y1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'y2') then begin
      Result:=NativeInt(y2);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'exec_bad_step') then begin
      Result:=NativeInt(@f_bad_step);
      DataType:=dtBool;
    end;
  end
end;

function   TRele.RunFunc;
 var
    j: integer;
    y0_,y2_,y1_,a_,b_,tmp: double;
 label
    g_step;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                   SetLength(ax,cY[0]);
                   //Добавляем вектор выхода для блока
                   if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
                 end;
    f_InitState: if not NeedRemoteData then begin
                   //Выводим начальное состояние
                   for j:=0 to Y[0].Count - 1 do begin
                     //Получаем параметры реле если они есть
                     Y0.TryGet(j,y0_);
                     y2.TryGet(j,y2_);
                     y1.TryGet(j,y1_);
                     //Инициализируем начальное состояние
                     ax[j]:=y0_;
                     if ax[j] >= 1 then
                        Y[0].Arr^[j]:=y2_
                     else
                        Y[0].Arr^[j]:=y1_;
                   end;
                   //Начальный расчёт реле
                   goto g_step;
                 end;
    f_UpdateJacoby,
    f_UpdateOuts:if f_bad_step then goto g_step;
    f_RestoreOuts,
    f_GoodStep:  begin

g_step:

                   if not NeedRemoteData then
                    for j:=0 to Y[0].Count - 1 do begin
                     //Получаем параметры реле если они есть
                     y2.TryGet(j,y2_);
                     y1.TryGet(j,y1_);
                     a.TryGet(j,a_);
                     b.TryGet(j,b_);
                     //Вычисляем блок
                     tmp:=ax[j];
                     //Если реле было выключено
                     if ax[j] >= 1 then begin
                        if U[0].Arr^[j] <= a_ then tmp:=0
                     end
                     //Если реле было включено
                     else begin
                        if U[0].Arr^[j] >= b_ then tmp:=1;
                     end;
                     if Action = f_GoodStep then ax[j]:=tmp;
                     if tmp > 0.5 then
                       Y[0].Arr^[j]:=y2_
                     else
                       Y[0].Arr^[j]:=y1_;
                    end;
                 end;
  end
end;

{*******************************************************************************
                       Релейное неоднозначное
*******************************************************************************}
constructor TReleInsense.Create(Owner: TObject);
begin
  inherited;
  f_bad_step:=True;   //По умолчанию реле исполняется на любых шагах
  a1:=TExtArray.Create(1);
  b1:=TExtArray.Create(1);
end;

destructor  TReleInsense.Destroy;
begin
  inherited;
  a1.Free;
  b1.Free;
end;

function    TReleInsense.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a1') then begin
      Result:=NativeInt(a1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'b1') then begin
      Result:=NativeInt(b1);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TReleInsense.RunFunc;
 var j:  integer;
     a_,b_,a1_,b1_,y1_,y2_,y0_,uu,st: RealType;
label
    g_step;

   procedure SetY;
   begin
      y1.TryGet(j,y1_);
      y2.TryGet(j,y2_);
      if st > 0 then
        Y[0].arr^[j]:=y2_
      else
      if st < 0 then
        Y[0].arr^[j]:=y1_
      else
        Y[0].arr^[j]:=0;
   end;

begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    SetLength(ax,cY[0]);
                    //Добавляем вектор выхода для блока
                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;
                  end;
    f_InitState: begin
                   //Инициализация состоний
                   for j:=0 to Y[0].Count - 1 do begin
                     Y0.TryGet(j,y0_);
                     AX[j]:=y0_;
                     st:=AX[j];
                     SetY;
                   end;
                   //Расчёт выходов
                   goto g_step;
                  end;
    f_UpdateJacoby,
    f_UpdateOuts: if f_bad_step then goto g_step;
    f_RestoreOuts,
    f_GoodStep: begin

g_step:

                 if not NeedRemoteData then
                  for j:=0 to Y[0].Count-1 do begin
                    //Получаем значение из массива по индексу, если оно там есть вообще
                    a.TryGet(j,a_);
                    b.TryGet(j,b_);
                    a1.TryGet(j,a1_);
                    b1.TryGet(j,b1_);
                    //Вычисляем значение блока
                    uu:=U[0].arr^[j];
                    st:=AX[j];
                    if uu < a1_ then st:=-1
                     else if uu > b1_ then st:=1
                       else if ((st < 0) and (uu > a_)) or
                               ((st > 0) and (uu < b_)) then st:=0;
                    SetY;
                    if Action = f_GoodStep then AX[j]:=st;
                  end;
                 end;
  end
end;

{*******************************************************************************
                    Линейное звено с насыщением
*******************************************************************************}
constructor TLineInsense.Create(Owner: TObject);
begin
  inherited;
  a:=TExtArray.Create(1);
  b:=TExtArray.Create(1);
  k:=TExtArray.Create(1);
end;

destructor  TLineInsense.Destroy;
begin
  inherited;
  a.Free;
  b.Free;
  k.Free;
end;

function    TLineInsense.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TLineInsense.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLineInsense.RunFunc;
 var j: integer;
     a_,b_,k_: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:    for j:=0 to Y[0].Count-1 do begin

                     a.TryGet(j,a_);
                     b.TryGet(j,b_);
                     k.TryGet(j,k_);

                     if U[0].arr^[j] < a_ then
                       Y[0].arr^[j]:=k_*(U[0].arr^[j]-a_)
                     else if U[0].arr^[j] > b_ then
                       Y[0].arr^[j]:=k_*(U[0].arr^[j]-b_)
                     else Y[0].arr^[j]:=0;
                   end;
  end
end;

{*******************************************************************************
                 Вычисление производной сигнала
*******************************************************************************}
constructor TDiffLimit.Create;
begin
  inherited;
  a:=TExtArray.Create(1);
end;

destructor  TDiffLimit.Destroy;
begin
  inherited;
  a.Free;
end;

function    TDiffLimit.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end;
  end
end;


function    TDiffLimit.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j : Integer;
    d : double;
    tmpa: Double;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      AX.Count:=cU[0] + 2;
                    end;
    f_InitState:    begin
                      d:=0;
                      tmpa:=1e300;
                      for j:=0 to cU[0]-1 do begin
                        AX[j]:=U[0].arr^[j];
                        if j < x0.Count then
                           d:=x0.Arr^[j];
                        if j < a.Count then
                           tmpa:=a.Arr^[j];
                        if abs(d) <= tmpa then
                          Y[0].Arr^[j]:=d
                        else
                          Y[0].Arr^[j]:=sign(d)*tmpa;
                      end;
                      AX[cU[0]]:=at;  //Запоминаем время
                      AX[cU[0]+1]:=0;
                    end;
    //f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:
                      //Вывод на промежуточном шаге
                      if (at-AX[cU[0]]) > 0 then begin
                        tmpa:=1e300;
                        for j:=0 to cU[0]-1 do begin
                          d:=(U[0].arr^[j]-AX[j]);
                          if j < a.Count then
                            tmpa:=a.Arr^[j];
                          if abs(d) > tmpa*(at-AX[cU[0]]) then
                            Y[0].Arr^[j]:=Sign(d)*tmpa
                          else
                            Y[0].Arr^[j]:=d/(at-AX[cU[0]]);
                        end;
                        //Запоминание состояний на хорошем шаге
                        if Action = f_GoodStep then begin
                          for j:=0 to cU[0]-1 do AX[j]:=U[0].arr^[j];
                          AX[cU[0]+1]:=at-AX[cU[0]];
                          AX[cU[0]]:=at;
                        end
                      end;
  end
end;

{*******************************************************************************
                        Кусочно-линейная функция
*******************************************************************************}
constructor  TLomStatic.Create;
begin
  inherited;
  y_:=TExtArray.Create(1);
  t:=TExtArray.Create(1);
  extrapolation:=False;
end;

destructor   TLomStatic.Destroy;
begin
  y_.Free;
  t.Free;
  inherited;
end;

function     TLomStatic.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (y_.Count <> t.Count) then begin
                    ErrorEvent(txtLomErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   begin
                    cY[0]:=cU[0];
                  end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TLomStatic.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'extrapolation') then begin
      Result:=NativeInt(@extrapolation);
      DataType:=dtBool;
    end
    else
    if StrEqu(ParamName,'y') then begin
      Result:=NativeInt(y_);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'t') then begin
      Result:=NativeInt(t);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TLomStatic.RunFunc;
 var
    i: integer;
 label
    a_do_run;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_InitState:      begin
                        //Счётчик - сбрасываем !!!
                        i_number:=0;
                        goto a_do_run;
                      end;
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : begin
a_do_run:
                        for i:=0 to Y[0].Count - 1 do
                          Y[0].Arr^[i]:=GetVectorData(u[0].Arr^[i],t,y_,t.Count,i_number,extrapolation);
                      end;
  end
end;

{*******************************************************************************
                       Минимум\максимум по входам
*******************************************************************************}
function      TMinMax.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'op_type') then begin
      Result:=NativeInt(@op_type);
      DataType:=dtInteger;
    end;
  end
end;

procedure   TMinMax.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  i:=Length(ax);
  Stream.Write(i,SizeOf(integer));
  Stream.Write(ax[0],i*SizeOfDouble);
end;

function    TMinMax.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      //Чтение к-ва данных
      Stream.Read(c,SizeOf(integer));
      //Чтение данных
      spos:=Stream.Position;
      Stream.Read(ax[0],min(c,Length(ax))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;
    finally
    end
end;

function     TMinMax.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TMinMax.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: SetLength(ax,U[0].Count);
    f_InitState:   for i:=0 to U[0].Count - 1 do begin
                     ax[i]:=U[0].Arr^[i];
                     Y[0].Arr^[i]:=ax[i];
                   end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:  for i:=0 to U[0].Count - 1 do begin
                   case op_type of
                     0: if U[0].Arr^[i] < ax[i] then Y[0].Arr^[i]:=U[0].Arr^[i] else Y[0].Arr^[i]:=ax[i];
                     1: if U[0].Arr^[i] > ax[i] then Y[0].Arr^[i]:=U[0].Arr^[i] else Y[0].Arr^[i]:=ax[i];
                   end;
                   if Action = f_GoodStep then ax[i]:=Y[0].Arr^[i];
                 end;
  end
end;

{*******************************************************************************
                       Минимум\максимум по входам
*******************************************************************************}
function      TMinMaxU.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'op_type') then begin
      Result:=NativeInt(@op_type);
      DataType:=dtInteger;
    end;
  end
end;

function     TMinMaxU.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  if cU.Count < 2 then begin
                    ErrorEvent(txtMinMaxUErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                 end
                 else begin
                   cY[0]:=cU[0];
                   for i:=1 to cU.Count - 1 do cU[i]:=cU[0];
                 end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TMinMaxU.RunFunc;
 var i,j: integer;
     d:   double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:  for i:=0 to U[0].Count - 1 do
                   case op_type of
                     0: begin
                          d:=U[0].Arr^[i];
                          for j:=1 to cU.Count - 1 do if U[j].Arr^[i] < d then d:=U[j].Arr^[i];
                          Y[0].Arr^[i]:=d;
                        end;
                     1: begin
                          d:=U[0].Arr^[i];
                          for j:=1 to cU.Count - 1 do if U[j].Arr^[i] > d then d:=U[j].Arr^[i];
                          Y[0].Arr^[i]:=d;
                        end
                   end;
  end
end;

{*******************************************************************************
                       Минимум\максимум по входам
*******************************************************************************}
function     TMinMaxAll.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  cY[0]:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TMinMaxAll.RunFunc;
 var i,j: integer;
     d:   double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:  if (cU.Count > 0) and (U[0].Count > 0) then begin
                   d:=U[0].Arr^[0];
                   for i:=0 to cU.Count - 1 do
                     for j:=0 to U[i].Count - 1 do
                       case op_type of
                         0: if U[i].Arr^[j] < d then d:=U[i].Arr^[j];
                         1: if U[i].Arr^[j] > d then d:=U[i].Arr^[j];
                       end;
                   Y[0].Arr^[0]:=d;
                 end;
  end
end;

{*******************************************************************************
                                Излом
*******************************************************************************}
constructor TIzlom.Create(Owner: TObject);
begin
  inherited;
  k1:=TExtArray.Create(1);
  k2:=TExtArray.Create(1);
  x0:=TExtArray.Create(1);
end;

destructor  TIzlom.Destroy;
begin
  inherited;
  k1.Free;
  k2.Free;
  x0.Free;
end;

function    TIzlom.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TIzlom.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k1') then begin
      Result:=NativeInt(k1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'k2') then begin
      Result:=NativeInt(k2);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TIzlom.RunFunc;
 var j: integer;
     k1_,k2_,x0_: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for j:=0 to Y[0].Count-1 do begin

                    k1.TryGet(j,k1_);
                    k2.TryGet(j,k2_);
                    x0.TryGet(j,x0_);

                    if U[0].Arr^[j] < x0_ then
                      Y[0].Arr^[j]:=k1_*(U[0].Arr^[j] - x0_)
                    else
                      Y[0].Arr^[j]:=k2_*(U[0].Arr^[j] - x0_);
                  end;
  end
end;

{*******************************************************************************
                        Квантователь по уровню
*******************************************************************************}
constructor  TValueQuant.Create;
begin
  inherited;
  step:=TExtArray.Create(1);
end;

destructor   TValueQuant.Destroy;
begin
  step.Free;
  inherited;
end;

function     TValueQuant.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TValueQuant.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'step') then begin
      Result:=NativeInt(step);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TValueQuant.RunFunc;
 var j : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep: for j:=0 to U[0].Count-1 do
                  if step.Arr^[j] = 0 then
                    Y[0].Arr^[j]:=U[0].Arr^[j]
                  else
                   Y[0].arr^[j]:=step.arr^[j]*sign(U[0].arr^[j])*trunc(abs(U[0].arr^[j]/step.arr^[j])+0.5);

  end
end;

{*******************************************************************************
                       Зазор
*******************************************************************************}
constructor TZazor.Create(Owner: TObject);
begin
  inherited;
  k:=TExtArray.Create(1);
  b:=TExtArray.Create(1);
end;

destructor  TZazor.Destroy;
begin
  inherited;
  k.Free;
  b.Free;
end;

function    TZazor.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=cU[0];
                end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TZazor.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TZazor.RunFunc;
 var j: integer;
     k_,b_,y0_: double;
 label
     do_calculate;

begin
  Result:=0;
  case Action of
    f_InitObjects: SetLength(ax,cY[0]);
    f_InitState: begin
                   for j:=0 to Y[0].Count-1 do begin
                     Y0.TryGet(j,y0_);
                     AX[j]:=y0_;
                   end;
                   goto do_calculate;
                 end;
    f_UpdateJacoby,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   begin

do_calculate:
                   for j:=0 to Y[0].Count-1 do begin

                    k.TryGet(j,k_);
                    b.TryGet(j,b_);

                    if U[0].arr^[j] > (AX[j]/k_ + b_) then
                      Y[0].arr^[j]:=k_*(U[0].arr^[j]-b_)
                    else if U[0].arr^[j] < (AX[j]/k_-b_) then
                      Y[0].arr^[j]:=k_*(U[0].arr^[j]+b_)
                    else Y[0].arr^[j]:=AX[j];
                    //Запоминаем состояние на хорошем шаге
                    if Action = f_GoodStep then AX[j]:=Y[0].Arr^[j];
                  end;
    end;
  end
end;

{*******************************************************************************
                       Люфт
*******************************************************************************}
constructor TLuft.Create(Owner: TObject);
begin
  inherited;
  y1:=TExtArray.Create(1);
  y2:=TExtArray.Create(1);
end;

destructor  TLuft.Destroy;
begin
  inherited;
  y1.Free;
  y2.Free;
end;

function    TLuft.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y1') then begin
      Result:=NativeInt(y1);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'y2') then begin
      Result:=NativeInt(y2);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLuft.RunFunc;
 var j: integer;
     b_,k_,y1_,y2_,y0_: double;
 label
     do_calculate;
begin
  Result:=0;
  case Action of
    f_InitObjects: SetLength(ax,cY[0]);
    f_InitState: begin
                   for j:=0 to Y[0].Count-1 do begin
                     Y0.TryGet(j,y0_);
                     AX[j]:=y0_;
                   end;
                   goto do_calculate;
                 end;
    f_UpdateJacoby,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep: begin

do_calculate:
                  for j:=0 to Y[0].Count-1 do begin

                   k.TryGet(j,k_);
                   b.TryGet(j,b_);
                   y1.TryGet(j,y1_);
                   y2.TryGet(j,y2_);

                   if U[0].arr^[j] <= (y1_/k_-b_) then
                     Y[0].arr^[j]:=y1_
                   else if U[0].arr^[j] >= (y2_/k_+b_) then
                     Y[0].arr^[j]:=y2_
                   else if (U[0].arr^[j] < (y2_/k_+b_))
                     and (U[0].arr^[j] > (AX[j]/k_+b_)) then
                     Y[0].arr^[j]:=k_*(U[0].arr^[j]-b_)
                   else if (U[0].arr^[j] > (y1_/k_-b_))
                     and (U[0].arr^[j] < (AX[j]/k_-b_)) then
                     Y[0].arr^[j]:=k_*(U[0].arr^[j]+b_)
                   else Y[0].arr^[j]:=AX[j];
                   if Action = f_GoodStep then AX[j]:=Y[0].Arr^[j];
                 end;
                end;
  end
end;

{*******************************************************************************
                       Импульсная функция
*******************************************************************************}
constructor TImpulseFunc.Create;
begin
  inherited;
  tau:=TExtArray.Create(1);
end;

destructor  TImpulseFunc.Destroy;
begin
  inherited;
  tau.Free;
end;

function    TImpulseFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=y0.Count;
                  cU[0]:=y0.Count;
                end;
    i_GetPropErr:if (tau.Count < y0.Count) then begin
                   ErrorEvent(txtImpulseErr,msError,VisualObject);
                   Result:=r_Fail;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TImpulseFunc.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tfun') then begin
      Result:=NativeInt(@tfun);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TImpulseFunc.RunFunc;
var j  : Integer;
    fl : Boolean;
    pp : double;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     SetLength(ptau,y0.Count);
                     SetLength(ax,y0.Count);
                   end;
    f_InitState:  begin
                    Move(Y0.arr^,Y[0].arr^,Y0.Count*SOfR);
                    for j:=0 to Y0.Count-1 do AX[j]:=U[0].arr^[j];
                    for j:=0 to Y0.Count-1 do ptau[j]:=at-tau.arr^[j];
                  end;
    f_UpdateJacoby,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:  for j:=0 to Y0.Count-1 do begin
                   fl:=false;
                   pp:=ptau[j];

                   case tFun of
                     0: fl:=U[0].arr^[j] <> AX[j];
                     1: fl:=U[0].arr^[j] > AX[j];
                     2: fl:=U[0].arr^[j] < AX[j];
                     3: fl:=U[0].arr^[j] <> 0;
                   end;

                   if fl and ((at-ptau[j]) > tau.arr^[j]) then begin
                     pp:=at;
                     Y[0].arr^[j]:=U[0].arr^[j];
                   end;

                   if (at-pp) > tau.arr^[j] then Y[0].arr^[j]:=Y0.arr^[j];

                   //т.к. блок - функциональный, то запоминать состояние можно и здесь
                   if Action = f_GoodStep then begin
                      AX[j]:=U[0].arr^[j];
                      ptau[j]:=pp;
                   end
                 end;
  end
end;

procedure   TImpulseFunc.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(ptau[0],y0.Count*SizeOfDouble);
end;

function   TImpulseFunc.RestartLoad;
 var i: integer;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(ptau[0],min(floadeddim,Length(ptau))*SizeOfDouble);
      for i:=0 to min(floadeddim,Length(ptau)) - 1 do ptau[i]:=ptau[i] - TimeShift;
    finally
    end
end;

{*******************************************************************************
                       Запоминание значения
*******************************************************************************}
procedure   TValueMem.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  i:=Length(ax);
  Stream.Write(i,SizeOf(integer));
  Stream.Write(ax[0],i*SizeOfDouble);
end;

function   TValueMem.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      //Загрузка количества
      Stream.Read(c,SizeOf(integer));
      //Загрузка данных
      spos:=Stream.Position;
      Stream.Read(ax[0],Min(c,Length(ax))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;
    finally
    end
end;

function    TValueMem.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cU[1]:=cU[0];
                  cY[0]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TValueMem.RunFunc;
 var j: integer;
     d: double;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     SetLength(ax,U[0].Count);
                     if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                  end;
    f_InitState:  for j:=0 to U[0].Count-1 do begin
                     AX[j]:=U[0].arr^[j];
                     Y[0].arr^[j]:=AX[j]
                  end;
    f_UpdateJacoby,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep: if not NeedRemoteData then
                 for j:=0 to U[0].Count - 1 do begin
                   d:=AX[j];
                   //На пробном шаге - если на втором выходе <> 0, то это означает срабатывание
                   //без задержки на шаг интегрирования
                   if U[1].Arr^[j] <> 0 then d:=U[0].Arr^[j];
                   Y[0].Arr^[j]:=d;
                   //Запоминаем состояние при условии что изменён выход
                   if (Action = f_GoodStep) then AX[j]:=d;
                 end;
  end
end;

{*******************************************************************************
           Запоминание времени в течение которого сигнал - истина
*******************************************************************************}
function    TTimeMem.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTimeMem.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    SetLength(ax,U[0].Count);
                    if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                  end;
    f_InitState: for j:=0 to U[0].Count-1 do begin
                   AX[j]:=at;
                   Y[0].arr^[j]:=0;
                 end;
    f_UpdateJacoby,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:  if not NeedRemoteData then
                 for j:=0 to U[0].Count-1 do begin
                   if U[0].arr^[j] <> 0.0 then
                     Y[0].arr^[j]:=at-AX[j]
                   else Y[0].arr^[j]:=0;
                   //Запоминание времени сброса
                   if Action = f_GoodStep then
                     if U[0].arr^[j] = 0.0 then AX[j]:=at;
                 end
  end
end;


{*******************************************************************************
                       Многомерная линейная интерполяция
*******************************************************************************}
constructor  TNDimInterpolation.Create;
begin
  inherited;
  method:=0;
  outmode:=0;
  tmpxp:=TExtArray2.Create(0,0);
  x_:=TExtArray2.Create(0,0);
  val_:=TExtArray.Create(0);
  u_:=TExtArray.Create(0);
  v_:=TExtArray.Create(0);
  ad_:=TIntArray.Create(0);
  k_:=TIntArray.Create(0);
end;

destructor   TNDimInterpolation.Destroy;
begin
  tmpxp.Free;
  x_.Free;
  val_.Free;
  u_.Free;
  v_.Free;
  ad_.Free;
  k_.Free;
  inherited;
end;

function     TNDimInterpolation.InfoFunc;
 var p,i: NativeInt;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (x_.CountX > 0) then begin

                    //Вычисляем суммарную размерность
                    p:=x_[0].Count;
                    for I := 1 to x_.CountX - 1 do p:=p*x_[i].Count;

                    //Проверяем всё ли задано в массиве val_
                    if val_.Count > 0 then begin
                      if val_.Count < p then begin
                         ErrorEvent(txtOrdinatesDefineIncomplete+IntToStr(p),msWarning,VisualObject);
                      end;
                    end
                    else begin
                      ErrorEvent(txtOrdinatesNotDefinedError,msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end;

                  end
                  else begin
                    ErrorEvent(txtDimensionsNotDefined,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   begin
                    //Размерность выхода = размерность входа делённая на размерность матрицы абсцисс
                    cY[0]:=cU[0] div x_.CountX;
                    cU[0]:=cY[0]*x_.CountX;     //Условие кратности рзмерности
                  end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TNDimInterpolation.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'outmode') then begin
      Result:=NativeInt(@outmode);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'method') then begin
      Result:=NativeInt(@method);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'x') then begin
      Result:=NativeInt(x_);
      DataType:=dtMatrix;
    end
    else
    if StrEqu(ParamName,'values') then begin
      Result:=NativeInt(val_);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TNDimInterpolation.RunFunc;
 var
    i,j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:    begin
                        //Подчитываем к-во точек по размерности входа
                        tmpxp.ChangeCount(cU[0] div x_.CountX,x_.CountX);
                        //Инициализируем временные массивы
                        u_.Count  := x_.CountX;
                        v_.Count  := 1 shl (x_.CountX);
                        ad_.Count := 1 shl (x_.CountX);
                        k_.Count  := x_.CountX;
                      end;
    f_RestoreOuts,
    f_InitState,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : begin
                        j:=0;
                        for i := 0 to tmpxp.CountX - 1 do begin
                          Move(U[0].Arr^[j],tmpxp[i].Arr^[0],tmpxp[i].Count*SizeOfDouble);
                          inc(j,tmpxp[i].Count);
                        end;

                        case method of
                          1: nstep_interp(x_,val_,tmpxp,Y[0],outmode,k_);
                        else
                          nlinear_interp(x_,val_,tmpxp,Y[0],outmode,u_,v_,ad_,k_);
                        end;

                      end;
  end
end;

end.
