
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Stat_Blocks;

 //***************************************************************************//
 //        Блоки для вычисления статистик и спектрального анализа             //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, math, tbls,
     TimeWinFuncs, FourierFuncs, fftwgen, mbty_std_consts, uBaseFiltersCalc;

type

    //Общие свойства статистических блоков
  TCustomStat = class(TRunObject)
  protected
    time:          double;                   //Переменная для хранения времени
    FFilters:      array of TBaseDataFilter; //Объекты фильтрации входной величины
    FilteredInps:  TExtArray2;               //Отфильтрованные входы
    f_count_for_sample: Integer;
  public                                     //  ***  Общие свойства статистических блоков  ***

                                             //параметры фильтрации входного сигнала
    filtertype:    NativeInt;                //Тип фильтра
    filterorder:   NativeInt;                //Порядок фильтра
    filterwc:      Double;                   //относительная (от частоты дисктеризации) частота среза

    tau:           double;          //Шаг дискретизации
    size:          NativeInt;         //Размер серии



    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;

    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;

    //Функции предварительной фильтрации потока данных встроенные в блоки статистики
    procedure      PrepareFilters;
    procedure      GetFilteredInputs(atime: Double);
    procedure      IntegrateFilters(atime: Double);
    procedure      ResetFilters(atime: Double);
    procedure      BeginFiltersSample(atime: Double);
  end;

  //Блок - вычисление среднего значения функции
  TStatMean = class(TCustomStat)
  protected
    floadeddim:    integer;
    fnew_ver:      boolean;
    Sum:           array of double;
    InpBuffer:     array of array of double;
    N:             double;
    bufpos:        NativeInt;
  public
    outmode:       NativeInt;         //1 - вывод по сериям ,0 - вывод по всей выборке
    destructor     Destroy;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Блок - вычисление среднеквадратического отклонения (RMS)
  TStatRMS = class(TStatMean)
  protected
    Ntrend:        double;
    SumSqr,CNY,M:  array of double;
    CN2:           double;
  public
    DelTrend:      boolean;         //Удаление линейного тренда 0-не удалять тренд, 1-удалять тренд
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Блок - вычисление коэффициента эксцесса
  TStatM3 = class(TStatRMS)
  protected
    SumCube:       array of double;
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Блок - вычисление фактора сплющиваемости
  TStatM4 = class(TStatM3)
  protected
    Sum4:          array of double;
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Блок - вычисление коэффициента корреляции
  TStatCorCoef = class(TCustomStat)
  protected
    SumX,SumY,
    XX,YY,XY:      array of double;
    N:             double;
  public
    outmode:       NativeInt;         //1 - вывод по сериям ,0 - вывод по всей выборке
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Группа состояний для гистограммы распределения
  THistNumericStates = packed record
    Position:integer;
    DMin,DMax,D0Min,D0Max,
    N,CN2,CNY,M,SmSqr:double;
    Auto:boolean;
  end;

  //Блок - произвольная функция корреляции
  TCustomCorFunc = class(TCustomStat)
  public
    calcmode:      NativeInt; //1-расчёт по сериям , 0-расчёт по всей выборке
    deltrend:      boolean; //Удаление линейного тренда 0-не удалять тренд, 1-удалять тренд
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Вычисление гистограммы распределения входной скалярной величины
  TStatHist = class(TCustomCorFunc)
  protected
    Data,Sum:      array of double;
    NumStates:     THistNumericStates;
  public
    fMin:          double;  //Минимальное значение
    fMax:          double;  //Максимальное значение
    Col:           NativeInt; //Число интервалов
    AutoRange:     NativeInt; //Автоматическая установка границ интервалов в каждой серии 0-вручную, 1-автоматически
    OutMode:       NativeInt; //0-относительная частота попаданий
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h_ : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Блок - базовый блок для спектральных блоков
  TCustomSpectrum = class(TCustomCorFunc)
  public
    outmode:       NativeInt;
    win:           NativeInt;
    TempFFTData:   TMLabTmpDataClass;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    destructor     Destroy;override;
  end;

 //Свойства для обычного спектра
 TSpectrNumericStates = packed record
   Position:integer;
   Num,
   SumSqr,
   Sum,
   SW,
   WSum,
   f0,
   NY,
   N2,
   MT:double;
  end;

  //Блок для вычисления спектральной плотности
  TStatSpectrum = class(TCustomSpectrum)
  protected
    k_ampl:        Double;
    W,Pwr:         array of double;
    NumStates:     TSpectrNumericStates;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h_ : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Свойства для вычисления взаимного спектра
  TDblSpectrNumericStates = packed record
   Position:integer;
   Num,
   SumW,
   WSum,
   SumSqr1,SumSqr2,
   Sum1,Sum2,
   NY1,NY2,
   NN1,
   MT1,MT2,
   f0:double;
  end;

  //Блок для вычисления взаимной спектральной плотности
  TDblSpectrum = class(TCustomSpectrum)
  protected
    k_ampl:        Double;
    X,Y_,GXY:      array of TComplex;
    W:             array of double;
    NumStates:     TDblSpectrNumericStates;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h_ : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Данные для вычисления функции взаимной корреляции
  TDblCorelNumericStates = packed record
   Size2,
   Position:integer;
   SerNum,
   T,
   RXX,
   RYY,
   Sum1,Sum2,
   NY1,NY2,
   NN1:double;
  end;

  //Блок - вычисление взаимной функции корреляции при помощи быстрого преобразования Фурье
  TStatCorFunc = class(TCustomSpectrum)
  protected
   // OutData,Data,
   // X,CfuncOut,
    Y_,
    GXY:      array of TComplex;
    NumStates:     TDblCorelNumericStates;
    RewTempFFTData:TMLabTmpDataClass;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h_ : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    destructor     Destroy;override;
  end;


implementation

uses Info;

{*******************************************************************************
                 Базовый класс для статистических блоков
*******************************************************************************}
function       TCustomStat.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'loctime_') then begin
      Result:=12;
      DataType:=dtDouble;
   end
  end;
end;

function       TCustomStat.ReadParam;
begin
   case ID of
    //Массив флагов срабатывания
    12: begin
          MoveData(@time,dtDouble,DestData,DestDataType);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

function    TCustomStat.InfoFunc;
begin
  //Result:=0;
  case Action of
    i_GetBlockType: Result:=t_fun;
    i_GetInit:      Result:=0;      //Выходы мгновенно зависят от входов
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

procedure   TCustomStat.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(time,SizeOfDouble);
end;

function    TCustomStat.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      Stream.Read(time,SizeOfDouble);
      time:=time - TimeShift;
    finally
    end
end;

function    TCustomStat.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(@tau);
      DataType:=dtDouble;
    end
    else
    if StrEqu(ParamName,'size') then begin
      Result:=NativeInt(@size);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'filtertype') then begin
      Result:=NativeInt(@filtertype);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'filterorder') then begin
      Result:=NativeInt(@filterorder);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'filterwc') then begin
      Result:=NativeInt(@filterwc);
      DataType:=dtDouble;
    end
  end
end;

constructor    TCustomStat.Create(Owner: TObject);
begin
  inherited Create(Owner);
  FilteredInps:=TExtArray2.Create(1,1);
end;

destructor     TCustomStat.Destroy;
 var i: Integer;
begin
  inherited;
  for i := 0 to Length(FFilters) - 1 do FFilters[i].Free;
  SetLength(FFilters,0);
  FilteredInps.Free;
end;

procedure      TCustomStat.PrepareFilters;
  var
    sum_in_dimention,i: Integer;
    FilterPoles: TComplexArray;
    FilterGain:  double;
    FilterA,
    FilterB,
    TempWorkArray:TExtArray;

  label
    not_filter;

begin
  //Стираем старые фильтры
  for i := 0 to Length(FFilters) - 1 do FFilters[i].Free;

  //Суммарная размерность входов - определяет к-во создаваемых фильтров
  sum_in_dimention:=0;
  FilteredInps.CountX:=cU.Count;
  for i := 0 to cU.Count - 1 do begin
    sum_in_dimention:=sum_in_dimention + cU.Arr^[i];
    FilteredInps.Arr^[i].Count:=cU.Arr^[i];
  end;

  //Если шаг нулевой то никакой фильтрации не делаем
  if tau <= 0 then goto not_filter;

  //Сохдание фильтров
  case filtertype of

    //Интегрирующий за один отсчёт фильтр
    1: begin
       SetLength(FFilters,sum_in_dimention);
       for i := 0 to sum_in_dimention -1  do begin
         FFilters[i]:=TOneSampleIntegratorFilter.Create;
       end;
    end;

    //Фильтр Баттеворта для отсечения паразитной ВЧ составляющей
    2: begin
        SetLength(FFilters,sum_in_dimention);
        FilterPoles:=TComplexArray.Create(0);
        FilterA:=TExtArray.Create(0);
        FilterB:=TExtArray.Create(1);
        TempWorkArray:=TExtArray.Create(1);
        //Расчёт коэффициентов непрерывно интегрирующего фильтра
        Butterworth_AnalogLowPassBA(
          FilterOrder,
          2*pi*filterwc/tau,
          FilterPoles,
          FilterGain,
          FilterA,
          FilterB,
          TempWorkArray
        );
        for i := 0 to sum_in_dimention -1  do begin
          FFilters[i]:=TCommonTransferFunctionFilter.Create;
          //Допустимый для фильтра шаг интегрирования для обеспечения устойчивости
          TCommonTransferFunctionFilter(FFilters[i]).max_step:=0.25*tau/filterwc;
          //Коэффициенты для каждой передаточной функции
          MoveData(FilterA, dtDoubleArray, TCommonTransferFunctionFilter(FFilters[i]).a, dtDoubleArray );
          MoveData(FilterB, dtDoubleArray, TCommonTransferFunctionFilter(FFilters[i]).b, dtDoubleArray );
        end;
        FilterPoles.Free;
        FilterA.Free;
        FilterB.Free;
        TempWorkArray.Free;
    end;

  else

not_filter:

    SetLength(FFilters,0);
  end;
end;

procedure   TCustomStat.GetFilteredInputs;
  var i,sum_dim,j: Integer;
      PP: TMyPoint;
begin
  if Length(FFilters) > 0 then begin

    //Есть фильтры - делаем фильтрацию входов
    sum_dim:=0;
    for i := 0 to cU.Count - 1 do begin
      for j := 0 to cU.Arr^[i] - 1 do begin
         PP.Y:=U[i].Arr^[j];
         PP.X:=atime;
         if sum_dim >= Length(FFilters) then
           FilteredInps.Arr^[i].Arr^[j]:=PP.Y
         else
           FilteredInps.Arr^[i].Arr^[j]:=FFilters[ sum_dim ].GetResult( f_count_for_sample, PP );
         Inc(f_count_for_sample);
      end;
    end;

  end
  else begin
    //Нет фильтров
    for i := 0 to cU.Count - 1 do begin
      Move( U[i].Arr^, FilteredInps.Arr^[i].Arr^ , cU.Arr^[i]*SizeOfDouble );
    end;
  end;
end;

procedure      TCustomStat.IntegrateFilters(atime: Double);
  var i,sum_dim,j: Integer;
      PP: TMyPoint;
begin
  if Length(FFilters) > 0 then begin

    //Есть фильтры - делаем фильтрацию входов
    sum_dim:=0;
    for i := 0 to cU.Count - 1 do begin
      for j := 0 to cU.Arr^[i] - 1 do begin
         PP.Y:=U[i].Arr^[j];
         PP.X:=atime;
         if sum_dim < Length(FFilters) then
           FFilters[ sum_dim ].Integrate( PP );
         Inc(f_count_for_sample);
      end;
    end;

  end
end;


procedure      TCustomStat.ResetFilters(atime: Double);
  var i,sum_dim,j: Integer;
      PP: TMyPoint;
begin
  if Length(FFilters) > 0 then begin

    //Есть фильтры - делаем фильтрацию входов
    sum_dim:=0;
    for i := 0 to cU.Count - 1 do begin
      for j := 0 to cU.Arr^[i] - 1 do begin
         PP.Y:=U[i].Arr^[j];
         PP.X:=atime;
         if sum_dim < Length(FFilters) then
           FFilters[ sum_dim ].Reset( PP );
         Inc(f_count_for_sample);
      end;
    end;

  end
end;

procedure      TCustomStat.BeginFiltersSample(atime: Double);
  var i,sum_dim,j: Integer;
      PP: TMyPoint;
begin
  if Length(FFilters) > 0 then begin

    //Есть фильтры - делаем фильтрацию входов
    sum_dim:=0;
    for i := 0 to cU.Count - 1 do begin
      for j := 0 to cU.Arr^[i] - 1 do begin
         PP.Y:=U[i].Arr^[j];
         PP.X:=atime;
         if sum_dim < Length(FFilters) then
           FFilters[ sum_dim ].BeginSample( PP );
         Inc(f_count_for_sample);
      end;
    end;

  end
end;

{*******************************************************************************
                    Вычисление среднего значения
*******************************************************************************}
destructor  TStatMean.Destroy;
 var i: integer;
begin
  inherited;
  for i := 0 to Length(InpBuffer) - 1 do
    SetLength(InpBuffer[i],0);
  SetLength(InpBuffer,0);
end;

function    TStatMean.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'outmode') then begin
      Result:=NativeInt(@outmode);
      DataType:=dtInteger;
    end;
  end
end;

function    TStatMean.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: CY[0]:=CU[0];
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TStatMean.RunFunc;
 var i:integer;
     OldBufP: NativeInt;
 label
     precise_step;
begin
 Result:=0;
 case Action of
  f_InitObjects: begin
                   SetLength(Sum,U[0].Count);
                   //В режиме плавающего среднего - копим все отсчёты в буфер
                   if OutMode = 2 then begin
                     SetLength(InpBuffer,U[0].Count);
                     for i := 0 to U[0].Count - 1 do
                       SetLength(InpBuffer[i],Size);
                   end;
                   bufpos:=0;
                   PrepareFilters;
                 end;
  f_InitState:   begin
                   N:=1;
                   bufpos:=0;
                   ResetFilters(at);
                   Move(FilteredInps[0].arr^,Sum[0],U[0].Count*SOfR);
                   Move(FilteredInps[0].arr^,Y[0].arr^,U[0].Count*SOfR);
                   time:=at + tau;
                   goto precise_step;
                 end;
  f_GoodStep:    begin
                  IntegrateFilters(at);

                  if time-at <= h/2 then begin

                   GetFilteredInputs(at);

                   N:=N+1;
                   for i:=0 to FilteredInps[0].Count-1 do begin
                     Sum[i]:=Sum[i]+FilteredInps[0].arr^[i];
                     //В режиме 2 - копим всё в буфер
                     if OutMode = 2 then begin
                       InpBuffer[i][bufpos]:=FilteredInps[0].arr^[i];
                     end;
                   end;
                   //В режиме плавающего - сброс буфера в 0 при накоплении
                   if (OutMode = 2) then begin
                     inc(bufpos);
                     if (bufpos >= Size) then bufpos:=0;
                   end;
                   //Вывод данных наружу
                   if (OutMode <> 1) or (N = Size) then begin
                     for i:=0 to FilteredInps[0].Count-1 do
                       Y[0].arr^[i]:=Sum[i]/N;
                   end;
                   if (N >= Size) then begin
                     case OutMode of
                       1: begin
                            //Среднее по сериям - после каждой серии обнуляем
                            N:=0;
                            for i:=0 to FilteredInps[0].Count-1 do Sum[i]:=0;
                          end;
                       2: begin
                            //Плавающее среднее по - вычитаем первые данные из выборки как ненужные
                            N:=Size;
                            OldBufP:=bufpos mod Size;
                            for i:=0 to FilteredInps[0].Count-1 do Sum[i]:=Sum[i] - InpBuffer[i][OldBufP];
                          end;
                     end;
                   end;
                   time:=time + Tau;

                   BeginFiltersSample(at);
                  end;


                  goto precise_step;
                 end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
  end
end;

function       TStatMean.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'n_') then begin
      Result:=13;
      DataType:=dtDouble;
   end
   else
   if StrEqu(ParamName,'sum_') then begin
      Result:=14;
      DataType:=dtDoubleArray;
   end
   else
   if StrEqu(ParamName,'bufindex_') then begin
      Result:=19;
      DataType:=dtInteger;
   end
   else
   if StrEqu(ParamName,'bufsum_') then begin
      Result:=20;
      DataType:=dtMatrix;
   end
  end;
end;

function       TStatMean.ReadParam;
 var i,j: integer;
begin
   case ID of
    //Массив флагов срабатывания
    13: begin
          MoveData(@N,dtDouble,DestData,DestDataType);
          Result:=True;
        end;
    14: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=Sum[i];
          Result:=True;
        end;
    19: begin
          MoveData(@bufpos,dtInteger,DestData,DestDataType);
          Result:=True;
        end;
    20: if DestDataType = dtMatrix then begin
          TExtArray2(DestData).CountX:=cY[0];
          for I := 0 to TExtArray2(DestData).CountX - 1 do begin
            TExtArray2(DestData).Arr^[i].Count:=Size;
            for j := 0 to TExtArray2(DestData).Arr^[i].Count - 1 do
              TExtArray2(DestData).Arr^[i].Arr^[j]:=InpBuffer[i][j];
          end;
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

procedure   TStatMean.RestartSave(Stream: TStream);
 var i,cnt: cardinal;
begin
  inherited;
  i:=Length(Sum);
  cnt:=i or $80000000;
  Stream.Write(cnt,SizeOfInt);                    //Вот сюда пишем ещё лишний бит !!!
  Stream.Write(N,SizeOfDouble);
  Stream.Write(Sum[0],i*SizeOfDouble);
  //Новые дополнительные данные для блока
  Stream.Write(Size,SizeOfInt);
  Stream.Write(OutMode,SizeOfInt);
  Stream.Write(bufpos,SizeOfInt);
  if OutMode = 2 then
    for i := 0 to Length(Sum) - 1 do
      Stream.Write(InpBuffer[i][0],SizeOfDouble*Size);
end;

function    TStatMean.RestartLoad;
 var aSize,aOutMode,i: integer;
     c: cardinal;
     bpos,
     old_p,
     old_bufp,
     spos: int64;

begin
  bpos:=Stream.Position;
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(c,SizeOfInt);
      fnew_ver:=(c and $80000000) <> 0;
      floadeddim:=c and (not $80000000);
      Stream.Read(N,SizeOfDouble);
      spos:=Stream.Position;
      Stream.Read(Sum[0],min(floadeddim,Length(Sum))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;

      //Считывание данных для нового режима работы блока !!!
      if fnew_ver and (Stream.Position - bpos < Count) then begin
         Stream.Read(aSize,SizeOfInt);
         Stream.Read(aOutMode,SizeOfInt);
         bufpos:=0;
         Stream.Read(bufpos,SizeOfInt);
         if (aOutMode = 2) then begin
           old_bufp:=Stream.Position;
           if OutMode = 2 then
             for i := 0 to floadeddim - 1 do
               if i < Length(InpBuffer) then begin
                  old_p:=Stream.Position;
                  Stream.Read(InpBuffer[i][0],min(aSize,Length(InpBuffer[i]))*SizeOfDouble);
                  Stream.Position:=old_p + aSize*SizeOfDouble;
               end;
           Stream.Position:=old_bufp + floadeddim*aSize*SizeOfDouble;
         end;
      end;

    finally
    end
end;


{*******************************************************************************
               Вычисление среднеквадратического отклонения (RMS)
*******************************************************************************}
function    TStatRMS.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'deltrend') then begin
      Result:=NativeInt(@DelTrend);
      DataType:=dtBool;
    end;
  end
end;

function   TStatRMS.RunFunc;
 var i,OldBufP: integer;
     tmp,a,b,tmpcny: double;
 label precise_step;
begin
 Result:=0;
 case Action of
  f_InitObjects:  begin
                    SetLength(Sum,U[0].Count);
                    SetLength(SumSqr,U[0].Count);
                    SetLength(CNY,U[0].Count);
                    SetLength(M,U[0].Count);
                    bufpos:=0;
                    if OutMode = 2 then begin
                      SetLength(InpBuffer,U[0].Count);
                      for i := 0 to U[0].Count - 1 do
                        SetLength(InpBuffer[i],Size);
                    end;
                    PrepareFilters;
                  end;
  f_InitState:    begin
                    N:=0;
                    Ntrend:=0;
                    CN2:=0;
                    bufpos:=0;
                    ResetFilters(at);
                    for i:=0 to U[0].Count - 1 do begin
                      CNY[i]:=0;
                      M[i]:=0;
                      Sum[i]:=0;
                      SumSqr[i]:=0;
                    end;
                    Y[0].FillArray(0);
                    time:=at;
                  end;
  f_GoodStep:     begin

                   IntegrateFilters(at);

                   if time-at <= 0.5*h then begin

                    GetFilteredInputs(at);

                    N:=N+1;

                    if DelTrend then begin
                      Ntrend:=Ntrend + 1;
                      CN2:=CN2+Ntrend*Ntrend;
                    end;
                    for i:=0 to U[0].Count-1 do begin
                      if DelTrend then begin
                        tmpcny:=Ntrend*FilteredInps[0].arr^[i];
                        CNY[i]:=CNY[i]+tmpcny;
                        M[i]:=M[i]+FilteredInps[0].arr^[i];
                        b:=(CNY[i]-0.5*M[i]*Ntrend)/(CN2-Ntrend*sqr(0.5*Ntrend));
                        a:=M[i]/Ntrend-b*0.5*Ntrend;
                        tmp:=FilteredInps[0].arr^[i] - (b*Ntrend+a);
                      end
                      else
                        tmp:=FilteredInps[0].arr^[i];
                      Sum[i]:=Sum[i] + tmp;
                      SumSqr[i]:=SumSqr[i] + tmp*tmp;
                      if OutMode = 2 then
                        InpBuffer[i][bufpos]:=tmp;
                    end;
                    if (OutMode = 2) then begin
                      inc(bufpos);
                      if (bufpos >= Size) then bufpos:=0;
                    end;
                    if ((OutMode <> 1) or (N = Size)) and (N > 1) then begin
                      for i:=0 to FilteredInps[0].Count-1 do
                        Y[0].arr^[i]:=sqrt((SumSqr[i]-sqr(Sum[i])/N)/(N-1));
                    end;

                    if (N >= Size) then begin

                      case OutMode of
                        //Серийный режим
                        1: begin
                             N:=0;
                             for i:=0 to FilteredInps[0].Count - 1 do begin
                               Sum[i]:=0;
                               SumSqr[i]:=0;
                             end;
                           end;
                        //Плавающий режим
                        2: begin
                             N:=Size;
                             OldBufP:=bufpos mod Size;
                             for i:=0 to U[0].Count - 1 do begin
                               tmp:=InpBuffer[i][OldBufP];
                               Sum[i]:=Sum[i] - tmp;
                               SumSqr[i]:=SumSqr[i] - tmp*tmp;
                             end;
                           end;
                      end;

                    end;
                    time:=time + Tau;
                    BeginFiltersSample(at);
                   end;
                   goto precise_step;
                  end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;

  end;
end;

procedure   TStatRMS.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(Sum);
  Stream.Write(CN2,SizeOfDouble);
  Stream.Write(SumSqr[0],i*SizeOfDouble);
  Stream.Write(CNY[0],i*SizeOfDouble);
  Stream.Write(M[0],i*SizeOfDouble);
  Stream.Write(Ntrend,SizeOfDouble);
end;

function    TStatRMS.RestartLoad;
 var spos,bpos,old_bufp,old_p: int64;
     aDelTrend: boolean;
     i,
     aSize,
     aOutMode: integer;
begin
  bpos:=Stream.Position;
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(CN2,SizeOfDouble);
      spos:=Stream.Position;
      Stream.Read(SumSqr[0],min(floadeddim,Length(SumSqr))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(CNY[0],min(floadeddim,Length(CNY))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(M[0],min(floadeddim,Length(CNY))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;

      //Отдельный счётчик для удаления линейного тренда !!! С общим счётчиком результат кривой
      if fnew_ver and (Stream.Position - bpos < Count) then
        Stream.Read(Ntrend,SizeOfDouble);

    finally
    end
end;

function       TStatRMS.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'cn2_') then begin
      Result:=15;
      DataType:=dtDouble;
   end
   else
   if StrEqu(ParamName,'sumsqr_') then begin
      Result:=16;
      DataType:=dtDoubleArray;
   end
   else
   if StrEqu(ParamName,'cny_') then begin
      Result:=17;
      DataType:=dtDoubleArray;
   end
   else
   if StrEqu(ParamName,'m_') then begin
      Result:=18;
      DataType:=dtDoubleArray;
   end
   else
   if StrEqu(ParamName,'ntrend_') then begin
      Result:=21;
      DataType:=dtDouble;
   end
  end;
end;

function       TStatRMS.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    15: begin
          MoveData(@CN2,dtDouble,DestData,DestDataType);
          Result:=True;
        end;
    16: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=SumSqr[i];
          Result:=True;
        end;
    17: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=CNY[i];
          Result:=True;
        end;
    18: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=M[i];
          Result:=True;
        end;
    21: begin
          MoveData(@Ntrend,dtDouble,DestData,DestDataType);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;


{*******************************************************************************
                Блок - вычисление коэффициента эксцесса
*******************************************************************************}
procedure   TStatM3.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(Sum);
  Stream.Write(SumCube[0],i*SizeOfDouble);
end;

function    TStatM3.RestartLoad;
 var spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      spos:=Stream.Position;
      Stream.Read(SumCube[0],min(floadeddim,Length(SumCube))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;
    finally
    end
end;

function   TStatM3.RunFunc;
 var i:     integer;
     tmp,a,b,subx:  double;
     OldBufP: NativeInt;
 label precise_step;
begin
 Result:=0;
 case Action of
  f_InitObjects:  begin
                    SetLength(Sum,U[0].Count);
                    SetLength(SumSqr,U[0].Count);
                    SetLength(SumCube,U[0].Count);
                    SetLength(CNY,U[0].Count);
                    SetLength(M,U[0].Count);
                    bufpos:=0;
                    if OutMode = 2 then begin
                      SetLength(InpBuffer,U[0].Count);
                      for i := 0 to U[0].Count - 1 do
                        SetLength(InpBuffer[i],Size);
                    end;
                    PrepareFilters;
                  end;
  f_InitState:    begin
                    N:=0;
                    CN2:=0;
                    Ntrend:=0;
                    bufpos:=0;
                    for i:=0 to U[0].Count - 1 do begin
                      CNY[i]:=0;
                      M[i]:=0;
                      Y[0].Arr^[i]:=0;
                      Sum[i]:=0;
                      SumSqr[i]:=0;
                      SumCube[i]:=0;
                    end;
                    time:=at;
                    ResetFilters(at);
                  end;
  f_GoodStep   :begin
                 IntegrateFilters(at);

                 if time-at <= 0.5*h then begin

                  GetFilteredInputs(at);

                  N:=N+1;
                  if DelTrend then begin
                    Ntrend:=Ntrend + 1;
                    CN2:=CN2+Ntrend*Ntrend;
                  end;
                  for i:=0 to U[0].Count-1 do begin
                    if DelTrend then begin
                      CNY[i]:=CNY[i]+Ntrend*FilteredInps[0].arr^[i];
                      M[i]:=M[i]+FilteredInps[0].arr^[i];
                      b:=(CNY[i]-0.5*M[i]*Ntrend)/(CN2-Ntrend*sqr(0.5*Ntrend));
                      a:=M[i]/Ntrend-b*0.5*Ntrend;
                      tmp:=FilteredInps[0].arr^[i]-(b*Ntrend+a);
                    end
                    else
                      tmp:=FilteredInps[0].arr^[i];
                    Sum[i]:=Sum[i]+tmp;
                    subx:=tmp*tmp;
                    SumSqr[i]:=SumSqr[i]+subx;
                    subx:=subx*tmp;
                    SumCube[i]:=SumCube[i]+subx;
                    if OutMode = 2 then
                      InpBuffer[i][bufpos]:=tmp;
                  end;
                  if (OutMode = 2) then begin
                    inc(bufpos);
                    if (bufpos >= Size) then bufpos:=0;
                  end;
                  if ((OutMode<>1) or (N=Size)) and (N>1) then begin
                    for i:=0 to U[0].Count-1 do begin
                      tmp:=(SumSqr[i]-sqr(Sum[i])/N)/(N-1);
                      if tmp <> 0 then
                        Y[0].arr^[i]:=((SumCube[i]*N-3*Sum[i]*SumSqr[i])*N+2*IntPower(Sum[i],3))/IntPower(N*sqrt(tmp),3)
                      else
                        Y[0].arr^[i]:=0;
                    end;
                  end;
                  if (N >= Size) then begin

                    case OutMode of
                      //Посерийный режим
                      1: begin
                           N:=0;
                           for i:=0 to U[0].Count - 1 do begin
                             Sum[i]:=0;
                             SumSqr[i]:=0;
                             SumCube[i]:=0;
                           end;
                         end;
                        //Плавающий режим
                        2: begin
                             N:=Size;
                             OldBufP:=bufpos mod Size;
                             for i:=0 to U[0].Count - 1 do begin
                               tmp:=InpBuffer[i][OldBufP];
                               Sum[i]:=Sum[i] - tmp;
                               subx:=tmp*tmp;
                               SumSqr[i]:=SumSqr[i] - subx;
                               subx:=subx*tmp;
                               SumCube[i]:=SumCube[i] - subx;
                             end;
                           end;
                    end;

                  end;
                  time:=time+Tau;

                  BeginFiltersSample(at);
                 end;
                 goto precise_step;
                end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
  end;
end;

{*******************************************************************************
                Блок - вычисление фактора сплющиваемости
*******************************************************************************}
procedure   TStatM4.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(Sum);
  Stream.Write(Sum4[0],i*SizeOfDouble);
end;

function    TStatM4.RestartLoad;
 var spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      spos:=Stream.Position;
      Stream.Read(Sum4[0],min(floadeddim,Length(Sum4))*SizeOfDouble);
      Stream.Position:=spos + floadeddim*SizeOfDouble;
    finally
    end
end;

function   TStatM4.RunFunc;
 var i:           integer;
     tmp,a,b,subx:double;
     OldBufP: NativeInt;
 label precise_step;
begin
 Result:=0;
 case Action of
  f_InitObjects:  begin
                    SetLength(Sum,U[0].Count);
                    SetLength(SumSqr,U[0].Count);
                    SetLength(SumCube,U[0].Count);
                    SetLength(CNY,U[0].Count);
                    SetLength(M,U[0].Count);
                    SetLength(Sum4,U[0].Count);
                    bufpos:=0;
                    if OutMode = 2 then begin
                      SetLength(InpBuffer,U[0].Count);
                      for i := 0 to U[0].Count - 1 do
                        SetLength(InpBuffer[i],Size);
                    end;
                    PrepareFilters;
                  end;
  f_InitState:    begin
                    N:=0;
                    CN2:=0;
                    bufpos:=0;
                    Ntrend:=0;
                    for i:=0 to U[0].Count - 1 do begin
                      CNY[i]:=0;
                      M[i]:=0;
                      Y[0].Arr^[i]:=0;
                      Sum[i]:=0;
                      SumSqr[i]:=0;
                      SumCube[i]:=0;
                      Sum4[i]:=0;
                    end;
                    time:=at;
                    ResetFilters(at);
                  end;
  f_GoodStep   :begin
                 IntegrateFilters(at);

                 if time-at <= 0.5*h then begin

                  GetFilteredInputs(at);

                  N:=N+1;
                  if DelTrend then begin
                    Ntrend:=Ntrend + 1;
                    CN2:=CN2+Ntrend*Ntrend;
                  end;
                  for i:=0 to U[0].Count-1 do begin
                    if DelTrend then begin
                      CNY[i]:=CNY[i]+Ntrend*FilteredInps[0].arr^[i];
                      M[i]:=M[i]+FilteredInps[0].arr^[i];
                      b:=(CNY[i]-0.5*M[i]*Ntrend)/(CN2-Ntrend*sqr(0.5*Ntrend));
                      a:=M[i]/Ntrend-b*0.5*Ntrend;
                      tmp:=FilteredInps[0].arr^[i]-(b*Ntrend+a);
                    end
                    else
                      tmp:=FilteredInps[0].arr^[i];
                    Sum[i]:=Sum[i]+tmp;
                    subx:=tmp*tmp;
                    SumSqr[i]:=SumSqr[i]+subx;
                    subx:=subx*tmp;
                    SumCube[i]:=SumCube[i]+subx;
                    subx:=subx*tmp;
                    Sum4[i]:=Sum4[i] + subx;
                    if OutMode = 2 then
                      InpBuffer[i][bufpos]:=tmp;
                  end;
                  if (OutMode = 2) then begin
                    inc(bufpos);
                    if (bufpos >= Size) then bufpos:=0;
                  end;
                  if ((OutMode<>1) or (N=Size)) and (N>1) then begin
                    for i:=0 to U[0].Count-1 do begin
                      tmp:=SumSqr[i]-sqr(Sum[i])/N;
                      if tmp<>0 then
                        Y[0].arr^[i]:=(N-1)*(Sum4[i]-4*Sum[i]*SumCube[i]/N+6*SumSqr[i]*sqr(Sum[i])/sqr(N)-3*IntPower(Sum[i],4)/(N*sqr(N)))/sqr(tmp)  -3
                      else
                        Y[0].arr^[i]:=0;
                    end;
                  end;
                  if (N >= Size) then begin
                    case OutMode of
                      1: begin
                           N:=0;
                           for i:=0 to U[0].Count - 1 do begin
                             Sum[i]:=0;
                             SumSqr[i]:=0;
                             SumCube[i]:=0;
                             Sum4[i]:=0;
                           end;
                         end;
                      2: begin
                             N:=Size;
                             OldBufP:=bufpos mod Size;
                             for i:=0 to U[0].Count - 1 do begin
                               tmp:=InpBuffer[i][OldBufP];
                               Sum[i]:=Sum[i] - tmp;
                               subx:=tmp*tmp;
                               SumSqr[i]:=SumSqr[i] - subx;
                               subx:=subx*tmp;
                               SumCube[i]:=SumCube[i] - subx;
                               subx:=subx*tmp;
                               Sum4[i]:=Sum4[i] - subx;
                             end;
                         end;
                    end;
                  end;
                  time:=time+Tau;

                  BeginFiltersSample(at);
                 end;
                 goto precise_step;
                end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;

  end;
end;

{*******************************************************************************
               Блок - вычисление коэффициента корреляции
*******************************************************************************}
function    TStatCorCoef.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'outmode') then begin
      Result:=NativeInt(@outmode);
      DataType:=dtInteger;
    end;
  end
end;

function    TStatCorCoef.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CU[1]:=CU[0];
                  CY[0]:=CU[0];
                end;
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TStatCorCoef.RunFunc;
 var i:integer;
 label precise_step;
begin
 Result:=0;
 case Action of
  f_InitObjects:  begin
                    SetLength(XX,U[0].Count);
                    SetLength(YY,U[0].Count);
                    SetLength(XY,U[0].Count);
                    SetLength(SumX,U[0].Count);
                    SetLength(SumY,U[0].Count);
                    PrepareFilters;
                  end;
  f_InitState:    begin
                    N:=0;
                    for i:=0 to U[0].Count - 1 do begin
                      Y[0].Arr^[i]:=0;
                      XX[i]:=0;
                      YY[i]:=0;
                      XY[i]:=0;
                      SumX[i]:=0;
                      SumY[i]:=0;
                    end;
                    time:=at;
                    ResetFilters(at);
                  end;
  f_GoodStep   :begin
                 IntegrateFilters(at);

                 if time-at <= 0.5*h then begin

                  GetFilteredInputs(at);

                  N:=N+1;
                  for i:=0 to U[0].Count-1 do begin
                    SumX[i]:=SumX[i]+FilteredInps[0].arr^[i];
                    SumY[i]:=SumY[i]+FilteredInps[1].arr^[i];
                    XX[i]:=XX[i]+sqr(FilteredInps[0].arr^[i]);
                    YY[i]:=YY[i]+sqr(FilteredInps[1].arr^[i]);
                    XY[i]:=XY[i]+FilteredInps[0].arr^[i]*FilteredInps[1].arr^[i]
                  end;
                  if ((OutMode<>1) or (N=Size)) and (N>1) then begin
                    for i:=0 to U[0].Count-1 do begin
                      Y[0].arr^[i]:=sqrt((XX[i]-sqr(SumX[i])/N)*(YY[i]-sqr(SumY[i])/N));
                      if Y[0].arr^[i] > 0 then
                        Y[0].arr^[i]:=(XY[i]-SumX[i]*SumY[i]/N)/Y[0].arr^[i]
                      else
                        Y[0].arr[i]:=1;
                    end;
                 end;
                 if (N=Size) and (OutMode=1) then begin
                    N:=0;
                    for i:=0 to U[0].Count - 1 do begin
                      SumX[i]:=0;
                      SumY[i]:=0;
                      XX[i]:=0;
                      YY[i]:=0;
                      XY[i]:=0;
                    end;
                 end;
                 time:=time+Tau;

                 BeginFiltersSample(at);
                end;
                goto precise_step;
               end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;

  end;
end;

procedure   TStatCorCoef.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(SumX);
  Stream.Write(i,SizeOfInt);
  Stream.Write(N,SizeOfDouble);
  Stream.Write(SumX[0],i*SizeOfDouble);
  Stream.Write(SumY[0],i*SizeOfDouble);
  Stream.Write(XX[0],i*SizeOfDouble);
  Stream.Write(XY[0],i*SizeOfDouble);
  Stream.Write(YY[0],i*SizeOfDouble);
end;

function    TStatCorCoef.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(c,SizeOfInt);
      Stream.Read(N,SizeOfDouble);

      spos:=Stream.Position;
      Stream.Read(SumX[0],min(c,Length(SumX))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(SumY[0],min(c,Length(SumX))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(XX[0],min(c,Length(SumX))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(XY[0],min(c,Length(SumX))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(YY[0],min(c,Length(SumX))*SizeOfDouble);
      Stream.Position:=spos + c*SizeOfDouble;
    finally
    end
end;

  //Базовый класс для гистограммы и спектральных блоков
function    TCustomCorFunc.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'calcmode') then begin
      Result:=NativeInt(@calcmode);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'deltrend') then begin
      Result:=NativeInt(@deltrend);
      DataType:=dtBool;
    end;
  end
end;


{*******************************************************************************
                    Гисторгамма распределения
*******************************************************************************}
function    TStatHist.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   CU[0]:=1;
                   CY[0]:=Col;
                   CY[1]:=Col;
                 end;
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

procedure   TStatHist.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(Size,SizeOfInt);
  Stream.Write(Col,SizeOfInt);
  Stream.Write(NumStates,SizeOf(NumStates));
  Stream.Write(Data[0],Size*SizeOfDouble);
  Stream.Write(Sum[0],Col*SizeOfDouble);
end;

function    TStatHist.RestartLoad;
 var isize,icol: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(isize,SizeOfInt);
      Stream.Read(icol,SizeOfInt);
      Stream.Read(NumStates,SizeOf(NumStates));

      spos:=Stream.Position;
      Stream.Read(Data[0],min(isize,Size)*SizeOfDouble);
      Stream.Position:=spos + isize*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(Sum[0],min(icol,Col)*SizeOfDouble);
      Stream.Position:=spos + icol*SizeOfDouble;
    finally
    end
end;

function    TStatHist.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'autorange') then begin
      Result:=NativeInt(@autorange);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'outmode') then begin
      Result:=NativeInt(@outmode);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'col') then begin
      Result:=NativeInt(@col);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'min') then begin
      Result:=NativeInt(@fMin);
      DataType:=dtDouble;
      exit;
    end;
    if StrEqu(ParamName,'max') then begin
      Result:=NativeInt(@fMax);
      DataType:=dtDouble;
    end;
  end
end;

function   TStatHist.RunFunc;
 var
  i,j:integer;
  h,S,K,a,b:double;
 label L1,L2,L3,L4,precise_step;
begin
 Result:=0;
 with NumStates do case Action of
  f_InitState  :  begin
                    Position:=0;
                    DMin:=fMin;
                    DMAx:=fMax;
                    Auto:=(AutoRange=1) and (CalcMode=0);
                    Y[0].FillArray(0);
                    Y[1].FillArray(0);
                    for i:=0 to Col - 1 do Sum[i]:=0;
                    N:=0;CN2:=0;CNY:=0;M:=0;SmSqr:=0;
                    time:=at;
                    ResetFilters(at);
                    goto L1
                  end;
  f_InitObjects:  begin
                    SetLength(Data,Size);
                    SetLength(Sum,Col);
                    PrepareFilters;
                  end;
  f_GoodStep   : begin
                  IntegrateFilters(at);

                  if time-at <= 0.5*h_ then begin
 L1:
                   GetFilteredInputs(at);

                   if CalcMode=0 then begin
                     if Auto then goto L2;
                     N:=N+1;
                     CN2:=CN2+N*N;
                     CNY:=CNY+N*FilteredInps[0].arr^[0];
                     M:=M+FilteredInps[0].arr^[0];
                     if DelTrend or (OutMode=3) then begin
                     if DelTrend then
                       b:=(CNY-0.5*M*N)/(CN2-N*sqr(0.5*N))
                     else
                       b:=0;
                     a:=M/N-b*0.5*N;
                     S:=FilteredInps[0].arr^[0]-(b*N+a);
                   end
                   else
                     S:=FilteredInps[0].arr^[0];
                   h:=(DMax-DMin)/Col;
                   case OutMode of
                     0: K:=1/N;
                     2: K:=1/(N*h);
                     3: begin
                          SmSqr:=SmSqr+S*S;
                          if N=1 then exit;
                          K:=sqrt(SmSqr/(N-1));
                          a:=1/K;
                          K:=K/(N*h);
                          for i:=0 to Col-1 do Y[0].arr^[i]:=(DMin+h*(i+0.5))*a;
                          goto L3;
                        end;
                   else
                     K:=1
                   end;
                   for i:=0 to Col-1 do Y[0].arr^[i]:=DMin+h*(i+0.5);
L3:                if (S>=DMin)and(S<=DMax) then begin
                     if S=DMax then i:=Col-1 else i:=trunc((S-DMin)/h);
                     Sum[i]:=Sum[i]+1;
                   end;
                   for j:=0 to Col-1 do Y[1].arr^[j]:=Sum[j]*K;
                   time:=at+Tau
                 end else begin  //Расчёт по отдельным сериям
L2:                Data[Position]:=FilteredInps[0].arr^[0];
                   if Position=Size - 1 then begin
                     //Вычисление коэффициентов линии регрессии и удаление линейного тренда
                     N:=0;CN2:=0;CNY:=0;M:=0;SmSqr:=0;
                     for i:=0 to Size-1 do begin
                       N:=i+1;
                       CN2:=CN2+N*N;
                       CNY:=CNY+N*Data[i];
                       M:=M+Data[i];
                     end;
                     if DelTrend or (OutMode=3) then begin
                       if DelTrend then
                         b:=(CNY-0.5*M*N)/(CN2-N*sqr(0.5*N))
                       else
                         b:=0;
                       a:=M/N-b*0.5*N;
                     end
                     else begin
                       b:=0;
                       a:=0
                     end;
                    //Расчёт границ интервалов
                    if AutoRange = 1 then begin
                      DMin:=MaxDouble;
                      DMax:=-MaxDouble;
                      for i:=0 to Size-1 do begin
                        Data[i]:=Data[i]-(b*(i+1)+a);
                        h:=Data[i];
                        if h>DMax then DMax:=h;
                        if h<DMin then DMin:=h;
                      end;
                    end
                    else begin
                      DMin:=fMin;
                      DMax:=fMax;
                    end;
                   //Ширина интервала гистограммы
                   h:=(DMax-DMin)/Col;
                   if h=0 then h:=0.000001;
                   //Расчёт гистограммы
                   case OutMode of
                     0: K:=1/Size;
                     2: K:=1/(Size*h);
                     3: begin
                          for i:=0 to Size-1 do SmSqr:=SmSqr+sqr(Data[i]);
                          K:=sqrt(SmSqr/(Size-1));
                          a:=1/K;
                          K:=K/(Size*h);
                          for i:=0 to Col-1 do Y[0].arr^[i]:=(DMin+h*(i+0.5))*a;
                          goto L4;
                        end;
                   else
                     K:=1
                   end;
                   for i:=0 to Col-1 do Y[0].arr^[i]:=DMin+h*(i+0.5);
L4:                Y[1].FillArray(0);
                   for i:=0 to Size-1 do
                     if (Data[i]>=Dmin)and(Data[i]<=DMax) then begin
                       if Data[i]>=DMax then j:=Col-1 else j:=trunc((Data[i]-DMin)/h);
                       if Auto then Sum[j]:=Sum[j]+1;
                       Y[1].arr^[j]:=Y[1].arr^[j]+K
                     end;
                 end;
                 //Переустановка стека
                 if Position>=Size-1 then
                   if Auto then
                     Auto:=false
                   else
                     Position:=0
                 else
                   inc(Position);
                 time:=time+Tau;
                 end;

                 BeginFiltersSample(at);
                end;   //END Case
                goto precise_step;
               end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
 end
end;

  //Базовый класс для спектральных блоков
function    TCustomSpectrum.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'outmode') then begin
      Result:=NativeInt(@outmode);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'win') then begin
      Result:=NativeInt(@win);
      DataType:=dtInteger;
    end;
  end
end;

destructor     TCustomSpectrum.Destroy;
begin
  inherited;
  if TempFFTData <> nil then TempFFTData.Free;
end;

{*******************************************************************************
                  Блок для вычисления спектральной плотности
*******************************************************************************}
function    TStatSpectrum.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CU[0]:=1;
                  CY[0]:=Size div 2 -1;
                  CY[1]:=Size div 2 -1;
                end;
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

const
  pi2 = 2*pi;
  cpNull: TComplex = (Re:0;Im:0);

function   TStatSpectrum.RunFunc;
 label L0,precise_step;
 var M,N,D,U_,SumW,K,CNY,CN2,b,CM,a,htmp:double;
  i:integer;
begin
 Result:=0;
 with NumStates do
 case Action of
   f_InitObjects: begin
                    SetLength(W,Size);
                    SetLength(Pwr,Y[0].Count);

                    //Инициализируем FFT
                    if TempFFTData = nil then
                      TempFFTData := TMLabTmpDataClass.Create( Size, FFTW_FORWARD )
                    else
                      TempFFTData.CheckDimAndDir( Size, FFTW_FORWARD );

                    PrepareFilters;
                  end;
  f_InitState    :begin
                    Position:=0;
                    Num:=0;
                    Sum:=0;
                    SumSqr:=0;
                    SW:=0;
                    WSum:=0;
                    NY:=0;
                    N2:=0;
                    MT:=0;
                    for i:=0 to Size - 1 do begin
                      U_:=winfunc(i,Size,Win);
                      W[i]:=U_;
                      WSum:=WSum+U_*U_;
                    end;
                    k_ampl:=WinFuncBeta(Win);
                    for i:=0 to Y[0].Count - 1 do Pwr[i]:=0;
                    Y[0].FillArray(0);
                    Y[1].FillArray(0);
                    time:=at;
                    ResetFilters(at);
                    goto L0;
                  end;
  f_GoodStep:     begin
                   IntegrateFilters(at);

                   if time-at <= 0.5*h_ then begin

L0:
                    GetFilteredInputs(at);

                    TempFFTData.pIn^[Position].Re:=FilteredInps[0].arr^[0];
                    TempFFTData.pIn^[Position].Im:=0;
                    if Position=Size-1 then begin
                      M:=Sum;
                      D:=SumSqr;
                      N:=Num+Size;
                      CNY:=NY;
                      CN2:=N2;
                      CM:=MT;
                      for i:=0 to Size-1 do begin
                        U_:=TempFFTData.pIn^[i].Re;
                        M:=M+U_;
                        K:=Num+i+1;
                        CNY:=CNY+K*U_;
                        CN2:=CN2+sqr(K);
                      end;
                      SumW:=SW+WSum;
                      if DelTrend then begin
                        b:=(CNY-0.5*M*N)/(CN2-N*sqr(0.5*N));
                        a:=M/N-b*0.5*N
                      end else begin
                        b:=0;
                        a:=M/N
                      end;
                      for i:=0 to Size-1 do begin
                        U_:=(TempFFTData.pIn^[i].Re-(b*(Num+i+1)+a));
                        D:=D+U_*U_;
                        CM:=CM+U_;
                        TempFFTData.pIn^[i].Re:=U_*W[i]
                      end;

                      TempFFTData.Exec;

                      for i:=0 to Y[0].Count-1 do begin
                        case OutMode of
                          0,1:  Y[1].arr^[i]:=Pwr[i]+sqr(TempFFTData.pOut^[i+1].Re)+sqr(TempFFTData.pOut^[i+1].Im);
                            2,
                            3:  Y[1].arr^[i]:=Pwr[i]+k_ampl*sqrt(sqr(TempFFTData.pOut^[i+1].Re)+sqr(TempFFTData.pOut^[i+1].Im));
                        end;
                      end;
                      if (CalcMode=0) then begin
                        Sum:=M;SumSqr:=D;Num:=N;SW:=SumW;NY:=CNY;N2:=CN2;MT:=CM;
                        Move(Y[1].arr^,Pwr[0],Y[1].Count*SOfR);
                      end;
                      if Tau<=0 then htmp:=h_ else htmp:=Tau;
                      //Частота в Герцах - умножено на 2*pi
                      f0:=1/(Size*htmp);
                      //Множитель осреднения
                      case OutMode of
                        0: K:=2*htmp/SumW;
                        1: K:=2*htmp/SumW*(N-1)/(D-sqr(CM)/N);
                        3: K:=2/N;
                      else
                        if (CalcMode=0) then
                          K:=Size/N
                        else
                          K:=1;
                      end;
                      for i:=0 to Y[0].Count-1 do begin
                        Y[0].arr^[i]:=(i+1)*f0;
                        Y[1].arr^[i]:=Y[1].arr^[i]*K;
                      end;
                    end;
                    if (Position = Size-1) then Position:=0 else inc(Position);
                    time:=time+Tau;

                    BeginFiltersSample(at);

                  end;
                  goto precise_step;
                 end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
  end; //END Case
end;   //END Procedure

procedure   TStatSpectrum.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(Size,SizeOfInt);
  Stream.Write(Y[0].Count,SizeOfInt);
  Stream.Write(NumStates,SizeOf(NumStates));
  Stream.Write(TempFFTData.pIn^[0],Size*SizeOfTComplex);
  Stream.Write(W[0],Size*SizeOfDouble);
  Stream.Write(Pwr[0],Length(Pwr)*SizeOfDouble);
end;

function    TStatSpectrum.RestartLoad;
 var i,pwrcount: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(i,SizeOfInt);
      Stream.Read(pwrcount,SizeOfInt);
      Stream.Read(NumStates,SizeOf(NumStates));

      spos:=Stream.Position;
      Stream.Read(TempFFTData.pIn^[0],min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(W[0],min(i,Size)*SizeOfDouble);
      Stream.Position:=spos + i*SizeOfDouble;

      spos:=Stream.Position;
      Stream.Read(Pwr[0],min(pwrcount,Length(Pwr))*SizeOfDouble);
      Stream.Position:=spos + pwrcount*SizeOfDouble;

    finally
    end
end;


{*******************************************************************************
               Блок для вычисления взаимной спектральной плотности
*******************************************************************************}
function    TDblSpectrum.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CU[0]:=1;
                  CU[1]:=CU[0];
                  CY[0]:=Size div 2 -1;
                  CY[1]:=Size div 2 -1;
                end;
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TDblSpectrum.RunFunc;
 label L0,precise_step;
 var K,N,SW,M1,M2,D1,D2,CNY1,CNY2,CNN1,CM1,CM2,a1,a2,b1,b2,U_:double;
  i:integer;
begin
 Result:=0;
 with NumStates do
 case Action of
  f_InitObjects:begin
                  SetLength(X,Size);
                  SetLength(Y_,Size);
                  SetLength(GXY,Size);
                  SetLength(W,Size);

                  //Инициализируем FFT
                  if TempFFTData = nil then
                    TempFFTData := TMLabTmpDataClass.Create( Size, FFTW_FORWARD )
                  else
                    TempFFTData.CheckDimAndDir( Size, FFTW_FORWARD );

                  PrepareFilters;
                end;
  f_InitState:  begin
                  Position:=0;
                  Num:=0;
                  WSum:=0;
                  SumW:=0;
                  Sum1:=0;Sum2:=0;
                  SumSqr1:=0;SumSqr2:=0;
                  MT1:=0;MT2:=0;
                  NY1:=0;NY2:=0;
                  NN1:=0;
                  for i:=0 to Size-1 do begin
                    GXY[i]:=cpNull;
                    K:=winfunc(i,Size,Win);
                    W[i]:=K;
                    WSum:=WSum+K*K
                  end;
                  k_ampl:=WinFuncBeta(Win);
                  Y[0].FillArray(0);
                  Y[1].FillArray(0);
                  time:=at;
                  ResetFilters(at);
                  goto L0
                end;
  f_GoodStep:   begin
                 IntegrateFilters(at);

                 if time-at <= 0.5*h_ then begin

L0:
                  GetFilteredInputs(at);

                  TempFFTData.pIn^[Position].Re:=FilteredInps[0].arr^[0];
                  TempFFTData.pIn^[Position].Im:=FilteredInps[1].arr^[0];
                  if Position = Size-1 then begin
                    N:=Num+Size;
                    SW:=SumW+WSum;
                    M1:=Sum1;M2:=Sum2;
                    D1:=SumSqr1;D2:=SumSqr2;
                    CNY1:=NY1;CNY2:=NY2;
                    CNN1:=NN1;
                    CM1:=MT1;CM2:=MT2;
                    //Предварительная подготовка данных
                    for i:=0 to Size-1 do begin
                      K:=Num+i+1;
                      U_:=TempFFTData.pIn^[i].Re;
                      M1:=M1+U_;
                      CNY1:=CNY1+K*U_;
                      CNN1:=CNN1+sqr(K);
                      U_:=TempFFTData.pIn^[i].Im;
                      M2:=M2+U_;
                      CNY2:=CNY2+K*U_;
                    end;
                    if DelTrend then begin
                      b1:=(CNY1-0.5*M1*N)/(CNN1-N*sqr(0.5*N));
                      a1:=M1/N-b1*0.5*N;
                      b2:=(CNY2-0.5*M2*N)/(CNN1-N*sqr(0.5*N));
                      a2:=M2/N-b2*0.5*N;
                    end else begin
                      b1:=0;
                      b2:=0;
                      a1:=M1/N;
                      a2:=M2/N
                    end;
                    for i:=0 to Size-1 do begin
                      U_:=(TempFFTData.pIn^[i].Re-(b1*(Num+i+1)+a1));
                      D1:=D1+U_*U_;
                      CM1:=CM1+U_;
                      TempFFTData.pIn^[i].Re:=U_*W[i];
                      U_:=(TempFFTData.pIn^[i].Im-(b2*(Num+i+1)+a2));
                      D2:=D2+U_*U_;
                      CM2:=CM2+U_;
                      TempFFTData.pIn^[i].Im:=U_*W[i]
                    end;

                    //Вычисление взаимного спектра
                    TempFFTData.Exec;

                    //Разделение данных
                    FFT_separate_XY(TempFFTData.pOut,@X[0],@Y_[0],Size);

                    for i:=0 to Size-1 do begin
                      K:=GXY[i].Re+X[i].Re*Y_[i].Re+X[i].Im*Y_[i].Im;
                      X[i].Im:=GXY[i].Im+X[i].Re*Y_[i].Im-Y_[i].Re*X[i].Im;
                      X[i].Re:=K // Х - взаимный спектр
                    end;
                    //Сохранение внутренних переменных в режиме усреднения по выборке
                    if CalcMode=0 then begin
                      Num:=N;
                      SumW:=SW;
                      Sum1:=M1;Sum2:=M2;
                      SumSqr1:=D1;SumSqr2:=D2;
                      NY1:=CNY1;NY2:=CNY2;
                      NN1:=CNN1;
                      MT1:=CM1;MT2:=CM2;
                      Move(X[0],GXY[0],Size*SizeOfTComplex);
                    end;

                   //Вывод взаимной спектральной плотности
                   if Tau=0 then begin
                     K:=2*h_/SumW;
                     f0:=1/(Size*h_)  //Частота - в Герцах
                   end else begin
                     K:=2*Tau/SumW;
                     f0:=1/(Size*Tau)
                   end;

                   if OutMode=2 then
                    for i:=0 to Size div 2 -2 do begin
                     Y[0].arr^[i]:=f0*i;
                     //Угол сдвига фаз вычисляем с учётом квадранта
                     Y[1].arr^[i]:=arctan2(X[i].Im,X[i].Re);
                    end
                   else begin
                      if OutMode=1 then K:=K*(N-1)/sqrt((D1-sqr(CM1)/N)*(D2-sqr(CM2)/N));
                      for i:=0 to Y[0].Count-1 do begin
                        Y[0].arr^[i]:=f0*(i+1);
                        Y[1].arr^[i]:=K*sqrt(sqr(X[i+1].Re)+sqr(X[i+1].Im));
                      end;
                    end;

                 end;
                 if (Position=Size-1) then Position:=0 else inc(Position);
                 time:=time + Tau;

                 BeginFiltersSample(at);
                end;
                goto precise_step;
              end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
  end; //END Case
end;   //END Procedure

procedure   TDblSpectrum.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(Size,SizeOfInt);
  Stream.Write(NumStates,SizeOf(NumStates));
  Stream.Write(TempFFTData.pIn^[0],Size*SizeOfTComplex);
  Stream.Write(X[0],Size*SizeOfTComplex);
  Stream.Write(Y_[0],Size*SizeOfTComplex);
  Stream.Write(GXY[0],Size*SizeOfTComplex);
  Stream.Write(W[0],Size*SizeOfDouble);
end;

function    TDblSpectrum.RestartLoad;
 var i: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(i,SizeOfInt);
      Stream.Read(NumStates,SizeOf(NumStates));

      spos:=Stream.Position;
      Stream.Read(TempFFTData.pIn^[0],min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(X[0],min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(Y_[0],min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(GXY[0],min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(W[0],min(i,Size)*SizeOfDouble);
      Stream.Position:=spos + i*SizeOfDouble;
    finally
    end
end;

{*******************************************************************************
              Блок для вычисления функции взаимной корреляции
*******************************************************************************}
function    TStatCorFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CU[0]:=1;
                  CU[1]:=1;
                  CY[0]:=Size;
                  CY[1]:=Size;
                end;
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TStatCorFunc.RunFunc;
 label L0,precise_step;
 var K,XX,SN,Num,YY,M1,M2,CNY1,CNY2,CNN1,U_,a1,b1,a2,b2,N:double;
  i:integer;
begin
 Result:=0;
 with NumStates do
 case Action of
  f_InitObjects: begin
                    Size2:=2*Size;

                    //Промехуточные массивы
                    SetLength(Y_,Size2);
                    SetLength(GXY,Size2);

                    //Инициализируем FFT
                    // X
                    if TempFFTData = nil then
                      TempFFTData := TMLabTmpDataClass.Create( Size2, FFTW_FORWARD )
                    else
                      TempFFTData.CheckDimAndDir( Size2, FFTW_FORWARD );

                    // iXY
                    if RewTempFFTData = nil then
                      RewTempFFTData := TMLabTmpDataClass.Create( Size2, FFTW_BACKWARD )
                    else
                      RewTempFFTData.CheckDimAndDir( Size2, FFTW_BACKWARD );

                    PrepareFilters;
                 end;
  f_InitState:   begin
                    Position:=0;
                    SerNum:=0;
                    RXX:=0;
                    RYY:=0;
                    Sum1:=0;Sum2:=0;
                    NY1:=0;NY2:=0;
                    NN1:=0;
                    for i:=0 to Size2 - 1 do GXY[i]:=cpNull;
                    Y[0].FillArray(0);
                    Y[1].FillArray(0);
                    time:=at;
                    ResetFilters(at);
                    goto L0;
                 end;
  f_GoodStep:    begin
                  IntegrateFilters(at);

                  if time-at <= 0.5*h_ then begin

L0:
                    GetFilteredInputs(at);

                    TempFFTData.pIn^[Position].Re:=FilteredInps[0].arr^[0];
                    TempFFTData.pIn^[Position].Im:=FilteredInps[1].arr^[0];
                    if Position = Size-1 then begin
                      SN:=SerNum+1;
                      Num:=SerNum*Size;
                      N:=SN*Size;
                      XX:=RXX;YY:=RYY;
                      M1:=Sum1;M2:=Sum2;
                      CNY1:=NY1;CNY2:=NY2;
                      CNN1:=NN1;
                      for i:=0 to Size-1 do begin
                        K:=Num+i+1;
                        U_:=TempFFTData.pIn^[i].Re;
                        M1:=M1+U_;
                        CNY1:=CNY1+K*U_;
                        CNN1:=CNN1+sqr(K);
                        U_:=TempFFTData.pIn^[i].Im;
                        M2:=M2+U_;
                        CNY2:=CNY2+K*U_;
                      end;
                      if DelTrend then begin
                        b1:=(CNY1-0.5*M1*N)/(CNN1-N*sqr(0.5*N));
                        a1:=M1/N-b1*0.5*N;
                        b2:=(CNY2-0.5*M2*N)/(CNN1-N*sqr(0.5*N));
                        a2:=M2/N-b2*0.5*N;
                      end else begin
                        b1:=0;
                        b2:=0;
                        a1:=M1/N;
                        a2:=M2/N
                      end;
                      for i:=0 to Size-1 do begin
                        U_:=(TempFFTData.pIn^[i].Re-(b1*(Num+i+1)+a1));
                        XX:=XX+U_*U_;
                        TempFFTData.pIn^[i].Re:=U_;
                        U_:=(TempFFTData.pIn^[i].Im-(b2*(Num+i+1)+a2));
                        YY:=YY+U_*U_;
                        TempFFTData.pIn^[i].Im:=U_;
                      end;
                      for i:=Size to Size2-1 do TempFFTData.pIn^[i]:=cpNull;

                      //FFT forward
                      TempFFTData.Exec;

                      //Split
                      FFT_separate_XY(TempFFTData.pOut,@RewTempFFTData.pIn^[0],@Y_[0],Size2);

                      if Tau = 0 then T:=h_ else T:=Tau;
                      for i:=0 to Size2-1 do begin
                        K:=GXY[i].Re+RewTempFFTData.pIn^[i].Re*Y_[i].Re+RewTempFFTData.pIn^[i].Im*Y_[i].Im;
                        RewTempFFTData.pIn^[i].Im:=GXY[i].Im+RewTempFFTData.pIn^[i].Re*Y_[i].Im-Y_[i].Re*RewTempFFTData.pIn^[i].Im;
                        RewTempFFTData.pIn^[i].Re:=K
                      end;
                      if CalcMode=0 then begin
                        SerNum:=SN;
                        RXX:=XX;
                        RYY:=YY;
                        Sum1:=M1;Sum2:=M2;
                        NY1:=CNY1;NY2:=CNY2;
                        NN1:=CNN1;
                        Move(RewTempFFTData.pIn^[0],GXY[0],Size2*SizeOfTComplex);
                      end;

                      // FFT rewind
                      RewTempFFTData.Exec;

                      for i:=0 to Size-1 do Y[0].arr^[i]:=T*i;
                      if (XX > 0) and (YY > 0) then begin
                        K:=1/(sqrt(XX*YY))/Size2;
                        for i:=0 to Size-1 do Y[1].arr^[i]:=K*RewTempFFTData.pOut^[i].Re;
                      end
                      else
                        Y[1].FillArray(1);
                    end;

                    if (Position=Size-1) then Position:=0 else inc(Position);
                    time:=time + Tau;

                    BeginFiltersSample(at);
                   end;
                   goto precise_step;
                  end;
  f_RestoreOuts,
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                       end;
                    end;
  end; //END Case
end;   //END Procedure


procedure   TStatCorFunc.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(Size,SizeOfInt);
  Stream.Write(NumStates,SizeOf(NumStates));
  Stream.Write(TempFFTData.pIn^[0],Size*2*SizeOfTComplex);
  Stream.Write(RewTempFFTData.pIn^[0],Size*2*SizeOfTComplex);
  Stream.Write(Y_[0],Size*2*SizeOfTComplex);
  Stream.Write(GXY[0],Size*2*SizeOfTComplex);
end;

function    TStatCorFunc.RestartLoad;
 var i: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
    try
      Stream.Read(i,SizeOfInt);
      Stream.Read(NumStates,SizeOf(NumStates));

      spos:=Stream.Position;
      Stream.Read(TempFFTData.pIn^[0],2*min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + 2*i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(RewTempFFTData.pIn^[0],2*min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + 2*i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(Y_[0],2*min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + 2*i*SizeOfTComplex;

      spos:=Stream.Position;
      Stream.Read(GXY[0],2*min(i,Size)*SizeOfTComplex);
      Stream.Position:=spos + 2*i*SizeOfTComplex;
    finally
    end
end;

destructor  TStatCorFunc.Destroy;
begin
  inherited;
  if RewTempFFTData <> nil then RewTempFFTData.Free;
end;

end.
