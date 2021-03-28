
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit src;

 //***************************************************************************//
 //                Блоки - источники сигнала                                  //
 //   Выходы этих блоков зависят только от модельного времени и/или           //
 //   шага расчета                                                            //
 //                                                                           //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, math, mbty_std_consts,
     uExtMath;

type

  //Блок-источник
  TCustomSrc = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Текущий шаг интегрирования y=h
  TTimeStep = class(TCustomSrc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Константа  y=a
  //Свойства: a - значение константы (вектор)
  TConst = class(TTimeStep)
  protected
    a:             TExtArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Линейный сигнал  y=a+b*t
  //Свойства: a - свободный член (вектор)
  //          b - коэффициент при времени (вектор)
  TLinear = class(TConst)
  public
    b:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок модельного времени
  TTimeSource = class(TCustomSrc)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Ступенчатое воздействие
  //Свойства:  t  - время срабатывания (вектор)
  //           y0 - начальное состояние (вектор)
  //           yk - конечное состояние (вектор)
  TStep = class(TCustomSrc)
  public
    t:             TExtArray;
    y0:            TExtArray;
    yk:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Парабола (квадратичное воздействие)
  //Свойства:  a0 - свободный член (вектор)
  //           a1 - к-т при первой степени (вектор)
  //           a2 - к-т при второй степени (вектор)
  TParabola = class(TCustomSrc)
  public
    a0:            TExtArray;
    a1:            TExtArray;
    a2:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Полином произвольной степени
  //Свойства:  a - массив векторов коэффициентов полинома (матрица)
  TPolynom = class(TCustomSrc)
  public
    a:             TExtArray2;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Синусоида
  //Свойства:  a - амплитуда (вектор)
  //           w - частота (вектор)
  //           f - сдвиг фазы (вектор)
  TSin = class(TConst)
  public
    k_period:      double;
    w:             TExtArray;
    f:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Экспонента
  //Свойства:  a - амплитуда
  //           b - коэффициент при времени
  //           с - слагаемое в аргументе
  TExp = class(TLinear)
  public
    c:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Гипербола
  //Свойства:  k - числитель (вектор)
  //           eps - минимальное значение знаменятеля (вектор)
  THyper = class(TCustomSrc)
  public
    k:             TExtArray;
    eps:           TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Пилообразный сигнал
  //Свойства:  y  - размах сигнала (вектор)
  //           t  - период (вектор)
  //           dy - смещение по значению (вектор)
  TPila = class(TCustomSrc)
  public
    k_period:      double;        //Коэффициент дробления шага на период
    y_:            TExtArray;
    t:             TExtArray;
    dy:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Обратный пилообразный сигнал
  //Свойства - те же что у пилообразного сигнала
  TInvPila = class(TPila)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Симметричный треугольный сигнал
  //Свойства - те же что у пилообразного сигнала
  TTriangle = class(TPila)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Меандр
  //Свойства:  y1 - значение 1-го полупериода (вектор)
  //           t1 - период 1-го полупериода (вектор)
  //           y2 - значение 2-го полупериода (вектор)
  //           t2 - период 2-го полупериода (вектор)
  TMeandr = class(TCustomSrc)
  public
    y1:            TExtArray;
    t1:            TExtArray;
    y2:            TExtArray;
    t2:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Кусочно - линейная функция (линейная интерполяция)
  //Свойства:  t - точка по времени (вектор)
  //           y - значение точки (вектор)
  TLom = class(TCustomSrc)
  public
    k_period:      double;
    t:             TExtArray2;
    y_:            TExtArray2;
    i_number:      array of NativeInt;   //Текущий номер временного интервала
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Кусочно - постоянная функция
  //Свойства:  t - временные интервалы (вектор)
  //           y - значение на интервале (вектор)
  TMultiStep = class(TLom)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Кусочно - постоянная циклическая функция
  TStepCycle = class(TLom)
  public
    times_arr:     array of double;
    val_indexes:   array of integer;
    interp_method: NativeInt;
    is_cyclic:     boolean;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Управляемый синусоидальный генератор
  TSinusCycle = class(TRunObject)
  public
    k_period:      double;
    times_arr:     array of double;
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Равномерный шум
  //Свойства:  xmin - левая граница (вектор)
  //           xmax - правая граница (вектор)
  //           qt   - период квантования (вектор)
  TSteady = class(TCustomSrc)
  public
    c_time:        double;
    xmin:          TExtArray;
    xmax:          TExtArray;
    qt:            TExtArray;
    time:          array of double;   //Целевое время
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    procedure      RestartSave(Stream: TStream);override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Гауссовский шум
  //Свойства:  m  - математическое ожидание (вектор)
  //           d  - дисперсия (вектор)
  //           qt - период квантования (вектор)
  TGauss = class(TCustomSrc)
  public
    m:             TExtArray;
    d:             TExtArray;
    qt:            TExtArray;
    time:          array of double;   //Целевое время
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    procedure      RestartSave(Stream: TStream);override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;


implementation

{*******************************************************************************
      Общие свойства блоков-источников
*******************************************************************************}
function    TCustomSrc.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  case Action of
    i_GetBlockType:  Result:=t_src;
    i_GetInit:       Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

constructor TCustomSrc.Create(Owner: TObject);
begin
  inherited;
  fIgnoreControl:=True;     //Для источников - игнорируем получение входных данных !!!
end;


{*******************************************************************************
                Текущее модельное время
*******************************************************************************}

function   TTimeSource.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetCount:  cY[0]:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTimeSource.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:
                   if not (NeedRemoteData and (RemoteDataUnit <> nil) and RemoteDataUnit.GetRemoteTime( Y[0].Arr^[0] )) then
                     Y[0].Arr^[0]:=at;
  end
end;

{*******************************************************************************
      Текущий шаг интегрирования
*******************************************************************************}
function   TTimeStep.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:
                   if NeedRemoteData and (RemoteDataUnit <> nil) then
                     Y[0][0]:=RemoteDataUnit.GetStep
                   else
                     Y[0][0]:=h;
  end
end;

{*******************************************************************************
      Константа
*******************************************************************************}
constructor TConst.Create;
begin
  inherited;
  a:=TExtArray.Create(1);
end;

destructor  TConst.Destroy;
begin
  inherited;
  a.Free;
end;

function    TConst.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TConst.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  cY[0]:=a.Count;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TConst.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       //Добавляем переменную в список считывания данных (считываем константу a)
                       RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix + GetUnikName + '_a',Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:   if not NeedRemoteData then begin
                     for i:=0 to a.count-1 do Y[0][i]:=a[i];
                  end;
  end
end;

{*******************************************************************************
      Линейный сигнал y=a+b*t
*******************************************************************************}
constructor TLinear.Create;
begin
  inherited;
  b:=TExtArray.Create(1);
end;

destructor  TLinear.Destroy;
begin
  inherited;
  b.Free;
end;

function   TLinear.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLinear.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (b.Count <= 0) or (a.Count <= 0) then begin
                    ErrorEvent(txtLinErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:  cY[0]:=Max(a.Count,b.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TLinear.RunFunc;
 var i: integer;
     tmp_a, tmp_b: Double;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:   if not NeedRemoteData then
                    for i:=0 to Y[0].count-1 do begin

                      a.TryGet(i,tmp_a);
                      b.TryGet(i,tmp_b);

                      Y[0][i]:=tmp_a + tmp_b*at;
                    end;
  end
end;

{*******************************************************************************
             Ступенчатое воздействие
*******************************************************************************}
constructor  TStep.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
  t:=TExtArray.Create(1);
  yk:=TExtArray.Create(1);
end;

destructor   TStep.Destroy;
begin
  y0.Free;
  t.Free;
  yk.Free;
  inherited;
end;

function     TStep.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (y0.Count <= 0) or (t.Count <= 0) or (yk.Count <= 0) then begin
                    ErrorEvent(txtStepErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max(Max(t.Count,y0.Count),yk.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TStep.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'t') then begin
      Result:=NativeInt(t);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'yk') then begin
      Result:=NativeInt(yk);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TStep.RunFunc;
 var i: integer;
     tmp_t,tmp_y0,tmp_yk: Double;

 procedure SetPrecStep;
  var tt: double;
      i:  integer;
 begin
   for i:=0 to t.Count - 1 do begin
     tt:=t.Arr^[i] - at;
     if tt >= 0 then begin
        ModelODEVars.fsetstep:=True;
        ModelODEVars.newstep:=min(ModelODEVars.newstep,tt);
     end;
   end;
 end;

begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState     : if not NeedRemoteData then begin
                        for i:=0 to Y[0].Count - 1 do begin
                          y0.TryGet(i,tmp_y0);
                          Y[0].Arr^[i]:=tmp_y0;
                        end;
                        if ModelODEVars.fPreciseSrcStep then SetPrecStep;
                      end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : if not NeedRemoteData then begin
                        for i:=0 to Y[0].Count - 1 do begin

                          y0.TryGet(i,tmp_y0);
                          t.TryGet(i,tmp_t);
                          yk.TryGet(i,tmp_yk);

                          if tmp_t < at then
                            Y[0].Arr^[i]:=tmp_yk
                          else
                            Y[0].Arr^[i]:=tmp_y0;

                        end;
                        if ModelODEVars.fPreciseSrcStep then SetPrecStep;
                      end;
  end
end;

{*******************************************************************************
                 Парабола (квадратичное воздействие)
*******************************************************************************}
constructor  TParabola.Create;
begin
  inherited;
  a0:=TExtArray.Create(1);
  a1:=TExtArray.Create(1);
  a2:=TExtArray.Create(1);
end;

destructor   TParabola.Destroy;
begin
  a0.Free;
  a1.Free;
  a2.Free;
  inherited;
end;

function     TParabola.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (a1.Count <= 0) or (a0.Count <= 0) or (a2.Count <= 0) then begin
                    ErrorEvent(txtParabErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max(Max(a0.Count,a1.Count),a2.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TParabola.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a0') then begin
      Result:=NativeInt(a0);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'a1') then begin
      Result:=NativeInt(a1);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'a2') then begin
      Result:=NativeInt(a2);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TParabola.RunFunc;
 var i: integer;
     tmp_a0,tmp_a1,tmp_a2: Double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to Y[0].Count - 1 do begin

                        a0.TryGet(i,tmp_a0);
                        a1.TryGet(i,tmp_a1);
                        a2.TryGet(i,tmp_a2);

                        Y[0].Arr^[i]:=tmp_a0 + at*tmp_a1 + at*at*tmp_a2;
                      end;
  end
end;

{*******************************************************************************
                 Полином произвольной степени
*******************************************************************************}
constructor  TPolynom.Create;
begin
  inherited;
  a:=TExtArray2.Create(1,1);
end;

destructor   TPolynom.Destroy;
begin
  inherited;
  a.Free;
end;

function     TPolynom.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:   cY[0]:=a.CountX;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function     TPolynom.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtMatrix;
    end;
  end
end;

function    TPolynom.RunFunc;
 var pt:   double;
     i,j:  integer;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      :if not NeedRemoteData then
                      for i:=0 to a.CountX - 1 do begin
                        pt:=1;
                        Y[0].Arr^[i]:=0;
                        for j:=0 to a.Arr^[i].Count - 1 do begin
                          Y[0].Arr^[i]:=Y[0].Arr^[i] + pt*a.Arr^[i].Arr^[j];
                          pt:=pt*at;
                        end;
                       end;
  end;
end;

{*******************************************************************************
                              Синусоида
*******************************************************************************}
constructor TSin.Create;
begin
  inherited;
  k_period   := 0.25*pi;
  w:=TExtArray.Create(1);
  f:=TExtArray.Create(1);
end;

destructor  TSin.Destroy;
begin
  inherited;
  w.Free;
  f.Free;
end;

function    TSin.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (w.Count <= 0) or (a.Count <= 0) or (f.Count <= 0) then begin
                    ErrorEvent(txtSinErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max(Max(a.Count,w.Count),f.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TSin.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k_period') then begin
      Result:=NativeInt(@k_period);
      DataType:=dtDouble;
    end
    else
    if StrEqu(ParamName,'w') then begin
      Result:=NativeInt(w);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'f') then begin
      Result:=NativeInt(f);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TSin.RunFunc;
 var i: integer;
     sin_1: RealType;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_InitObjects: if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       //Добавляем переменную в список считывания данных (считываем константу a)
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:  if not NeedRemoteData then
                   for i:=0 to Y[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    sin_1:=sin(w_tmp*at + f_tmp);
                    Y[0][i]:=a_tmp*sin_1;
                    if ModelODEVars.fPreciseSrcStep and (w_tmp <> 0) then begin
                       ModelODEVars.fsetstep:=True;
                       ModelODEVars.newstep:=min(ModelODEVars.newstep,k_period/abs(w_tmp));
                    end;

                   end;
  end
end;

{*******************************************************************************
                            Экспонента
*******************************************************************************}
constructor  TExp.Create;
begin
  inherited;
  c:=TExtArray.Create(1);
end;

destructor   TExp.Destroy;
begin
  inherited;
  c.Free;
end;

function     TExp.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: begin
                    Result:=inherited InfoFunc(Action,aParameter);
                    if (Result = r_Success) then begin
                      if c.Count <= 0 then begin
                        ErrorEvent(txtExpErr,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                    end;
    end;
    i_GetCount:   Result:=Max(inherited InfoFunc(Action,aParameter),c.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function     TExp.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'c') then begin
      Result:=NativeInt(c);
      DataType:=dtDoubleArray;
    end;
  end
end;

function     TExp.RunFunc;
 var i: integer;
     tmp_a,tmp_b,tmp_c: Double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:   for i:=0 to Y[0].count-1 do begin

                      a.TryGet(i,tmp_a);
                      b.TryGet(i,tmp_b);
                      c.TryGet(i,tmp_c);

                      Y[0][i]:=tmp_a*exp(tmp_b*at + tmp_c);
                  end;
  end
end;

{*******************************************************************************
                         Гипербола
*******************************************************************************}
constructor  THyper.Create;
begin
  inherited;
  k:=TExtArray.Create(1);
  eps:=TExtArray.Create(1);
end;

destructor   THyper.Destroy;
begin
  k.Free;
  eps.Free;
  inherited;
end;

function     THyper.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (eps.Count <= 0) or (k.Count <= 0) then begin
                    ErrorEvent(txtHyperError,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max(k.Count,eps.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    THyper.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'eps') then begin
      Result:=NativeInt(eps);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    THyper.RunFunc;
 var i: integer;
     z,tmp_eps,tmp_k: double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to Y[0].Count - 1 do begin

                        eps.TryGet(i,tmp_eps);
                        k.TryGet(i,tmp_k);

                        z:=at + tmp_eps;
                        if z <> 0 then
                          Y[0].Arr^[i]:=tmp_k/z
                        else begin
                          Result:=r_Fail;
                          ErrorEvent(txtHyperErr1+' time='+FloatToStr(at),msError,VisualObject);
                        end;
                      end;
  end
end;

{*******************************************************************************
                        Пилообразный сигнал
*******************************************************************************}
constructor  TPila.Create;
begin
  inherited;
  k_period:=0.1;
  y_:=TExtArray.Create(1);
  t:=TExtArray.Create(1);
  dy:=TExtArray.Create(1)
end;

destructor   TPila.Destroy;
begin
  y_.Free;
  t.Free;
  dy.Free;
  inherited;
end;

function     TPila.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (t.Count <= 0) or (y_.Count <= 0) or (dy.Count <= 0) then begin
                    ErrorEvent(txtPilaErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max(Max(t.Count,y_.Count),dy.Count);
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TPila.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y') then begin
      Result:=NativeInt(y_);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'t') then begin
      Result:=NativeInt(t);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'dy') then begin
      Result:=NativeInt(dy);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TPila.RunFunc;
 var i: integer;
     tt,tmp_t,tmp_y,tmp_dy: double;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      :if not NeedRemoteData then
                      for i:=0 to Y[0].Count - 1 do begin

                        t.TryGet(i,tmp_t);
                        y_.TryGet(i,tmp_y);
                        dy.TryGet(i,tmp_dy);

                        if tmp_t <= 0.0 then begin
                          ErrorEvent(txtPilaErr1+' time='+FloatToStr(at),msError,VisualObject);
                          Result:=r_Fail;
                          Continue;
                        end;
                        tt:=tmp_t*int(at/tmp_t);
                        Y[0].Arr^[i]:=tmp_y/tmp_t*(at - tt) + tmp_dy;
                        if ModelODEVars.fPreciseSrcStep then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(ModelODEVars.newstep, min( max(tt + tmp_t - 0.5*ModelODEVars.Hmin - at,0), k_period*tmp_t ));
                        end;

                      end;
  end
end;


{*******************************************************************************
                        Обратный пилообразный сигнал
*******************************************************************************}
function  TInvPila.RunFunc;
 var i:  integer;
     tt,tmp_t,tmp_y,tmp_dy: double;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      :if not NeedRemoteData then
                      for i:=0 to Y[0].Count - 1 do begin

                        t.TryGet(i,tmp_t);
                        y_.TryGet(i,tmp_y);
                        dy.TryGet(i,tmp_dy);

                        if tmp_t <= 0.0 then begin
                          ErrorEvent(txtPilaErr1+' time='+FloatToStr(at),msError,VisualObject);
                          Result:=r_Fail;
                          Continue;
                        end;
                        tt:=tmp_t*int(at/tmp_t);
                        Y[0].Arr^[i]:=tmp_y - tmp_y/tmp_t*(at - tt) + tmp_dy;
                        if ModelODEVars.fPreciseSrcStep then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(ModelODEVars.newstep,min( max(tt + tmp_t - 0.5*ModelODEVars.Hmin - at,0), k_period*tmp_t ));
                        end;
                      end;
  end
end;

{*******************************************************************************
                      Симметричный треугольный сигнал
*******************************************************************************}
function  TTriangle.RunFunc;
 var i:  integer;
     tt,dt,tmp_t,tmp_y,tmp_dy: double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to Y[0].Count - 1 do begin

                        t.TryGet(i,tmp_t);
                        y_.TryGet(i,tmp_y);
                        dy.TryGet(i,tmp_dy);

                        if tmp_t <= 0.0 then begin
                          ErrorEvent(txtPilaErr1+' time='+FloatToStr(at),msError,VisualObject);
                          Result:=r_Fail;
                          continue;
                        end;

                        tt:=tmp_t*int(at/tmp_t);
                        dt:=at - tt;
                        if dt > 0.5*tmp_t then
                          Y[0].Arr^[i]:=2*tmp_y*(1 - 1/tmp_t*dt) + tmp_dy
                        else
                          Y[0].Arr^[i]:=2*tmp_y/tmp_t*dt + tmp_dy;

                        if ModelODEVars.fPreciseSrcStep then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(ModelODEVars.newstep, min( max(0.5*tmp_t*(int(2*at/tmp_t + 1) - 0.5*ModelODEVars.Hmin) - at,0), 0.5*k_period*tmp_t) );
                        end;
                      end;
  end
end;

{*******************************************************************************
                                  Меандр
*******************************************************************************}
constructor  TMeandr.Create;
begin
  inherited;
  y1:=TExtArray.Create(1);
  t1:=TExtArray.Create(1);
  y2:=TExtArray.Create(1);
  t2:=TExtArray.Create(1);
end;

destructor   TMeandr.Destroy;
begin
  y1.Free;
  t1.Free;
  y2.Free;
  t2.Free;
  inherited;
end;

function     TMeandr.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (t1.Count <= 0) or (y2.Count <= 0) or (y1.Count <= 0) or (t2.Count <= 0) then begin
                    ErrorEvent(txtMeandrErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   cY[0]:=Max( Max(t1.Count,t2.Count), Max(y1.Count,y2.Count) );
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TMeandr.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y1') then begin
      Result:=NativeInt(y1);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'t1') then begin
      Result:=NativeInt(t1);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'y2') then begin
      Result:=NativeInt(y2);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'t2') then begin
      Result:=NativeInt(t2);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TMeandr.RunFunc;
 var i:  integer;

     tmp_t1,tmp_t2,tmp_y1,tmp_y2,
     tt,
     tfull,
     dt: double;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      :if not NeedRemoteData then
                      for i:=0 to Y[0].Count - 1 do begin

                        t1.TryGet(i, tmp_t1);
                        t2.TryGet(i, tmp_t2);
                        y1.TryGet(i, tmp_y1);
                        y2.TryGet(i, tmp_y2);

                        tfull:=tmp_t1 + tmp_t2;
                        if tfull <= 0.0 then begin
                          ErrorEvent(txtPilaErr1+' time='+FloatToStr(at),msError,VisualObject);
                          Result:=r_Fail;
                          exit
                        end;
                        tt:=tfull*int(at/tfull);
                        dt:=at - tt;
                        if dt > tmp_t1 then begin
                          Y[0].Arr^[i]:=tmp_y2;
                          tt:=tt + tfull;
                        end
                        else begin
                          Y[0].Arr^[i]:=tmp_y1;
                          tt:=tt + tmp_t1;
                        end;

                        if ModelODEVars.fPreciseSrcStep then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(ModelODEVars.newstep,max(tt - 0.5*ModelODEVars.Hmin - at,0));
                        end;
                      end;
  end
end;

{*******************************************************************************
                        Кусочно-линейная функция
*******************************************************************************}
constructor  TLom.Create;
begin
  inherited;
  k_period:=0.2;
  y_:=TExtArray2.Create(1,1);
  t:=TExtArray2.Create(1,1);
end;

destructor   TLom.Destroy;
begin
  y_.Free;
  t.Free;
  inherited;
end;

function     TLom.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (y_.CountX < t.CountX) then begin
                    ErrorEvent(txtLomErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end
                  else
                    SetLength(i_number,t.CountX);
    i_GetCount:   cY[0]:=t.CountX;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TLom.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k_period') then begin
      Result:=NativeInt(@k_period);
      DataType:=dtDouble;
    end
    else
    if StrEqu(ParamName,'y') then begin
      Result:=NativeInt(y_);
      DataType:=dtMatrix;
    end
    else
    if StrEqu(ParamName,'t') then begin
      Result:=NativeInt(t);
      DataType:=dtMatrix;
    end;
  end
end;

function    TLom.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : if not NeedRemoteData then
                        for i:=0 to t.CountX - 1 do
                           Y[0].Arr^[i]:=GetVectorData(at,t.Arr^[i],y_.Arr^[i],t.Arr^[i].Count,i_number[i]);
  end
end;

{*******************************************************************************
                        Кусочно - постоянная функция
*******************************************************************************}
function    TMultiStep.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i,j: integer;
     s:   double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to t.CountX - 1 do begin
		                    s:=0;
                   		  for j:=0 to t.Arr^[i].Count - 1 do begin
		                      s:=s + t.Arr^[i].arr^[j];
                   	 	    if s > at then begin
		                        Y[0].arr^[i]:=y_.Arr^[i].arr^[j];
                            //Предсказание события для более точного определения шага задачи (сколько осталось до перехода)
                            if ModelODEVars.fPreciseSrcStep then begin
                              ModelODEVars.fsetstep:=True;
                              ModelODEVars.newstep:=min(ModelODEVars.newstep,max(s - 0.5*ModelODEVars.Hmin - at,0));
                            end;
                            break;
 		                      end
		                    end;
                      end
  end
end;

{*******************************************************************************
          Кусочно - постоянная функция циклическая функция с управлением
*******************************************************************************}
function    TStepCycle.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i,j,val_index: integer;
     local_time,cycle_end_time,
     modulation,period_time:   double;
 label
     do_process_step;
begin
  Result:=0;
  case Action of
    f_InitObjects:   begin
                       SetLength(times_arr,t.CountX);
                       SetLength(val_indexes,t.CountX);
                       for I := 0 to t.CountX - 1 do begin
                         times_arr[i]:=0;
                         val_indexes[i]:=0;
                       end;
                       //Добавляем выход в список считывания данных
                       if NeedRemoteData then
                         if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                         end;
                     end;
    f_InitState:     if not NeedRemoteData then begin
                       for I := 0 to t.CountX - 1 do begin
                         times_arr[i]:=0;
                         val_indexes[i]:=0;
                         Y[0].arr^[i]:=y_.Arr^[i].Arr^[0];
                         Y[1].arr^[i]:=0;
                         if cY.Count > 2 then Y[2].arr^[i]:=0;
                       end;
                       goto do_process_step;
                     end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : begin

do_process_step:
                      if not NeedRemoteData then

                       for i:=0 to t.CountX - 1 do begin

                        //Для начала мы вычисляем локальное время цикла
                        local_time:=times_arr[i];
                        val_index:=val_indexes[i];

                        //Коэффициент ускорения локального времени блока (частотная модуляция)
                        if cU.Count > 1 then
                          modulation:=U[1].Arr^[i]
                        else
                          modulation:=1;

                        //Второй выход = 0 по умолчанию
                        Y[1].arr^[i]:=0;

                        //Проверяем активность
                        if U[0].Arr^[i] > 0.5 then begin

                           //Инкрементация времени (если не пауза)
                          if U[0].Arr^[i] < 2 then
                             local_time:=local_time + h*modulation;

                          //Потом вычисляем номер интервала
                          while val_index < t.Arr^[i].Count do begin
                            if local_time < t.Arr^[i].Arr^[val_index] then begin
                               //Уточнение события для точного вычисления шага для циклограммы
                               if ModelODEVars.fPreciseSrcStep then begin
                                 ModelODEVars.fsetstep:=True;
                                 //Вычисление времени текущего периода
                                 if val_index > 0 then
                                   period_time:=t.Arr^[i].Arr^[val_index] - t.Arr^[i].Arr^[val_index - 1]
                                 else
                                   period_time:=t.Arr^[i].Arr^[0];
                                 //Установка коэффициента дробления интервала
                                 if interp_method > 0 then
                                   period_time:=period_time*k_period;
                                 //Присвоение шага
                                 ModelODEVars.newstep:=min(ModelODEVars.newstep,
                                    min(max(t.Arr^[i].Arr^[val_index] - local_time - 0.5*ModelODEVars.Hmin,0),
                                    period_time
                                    ));
                               end;
                               //Выход из программы
                               break;
                            end;
                            inc(val_index);
                          end;

                          //Ограничение цикла
                          if val_index >= t.Arr^[i].Count then begin
                            //Флаг сброса цикла = 1
                            Y[1].arr^[i]:=1;
                            //Конечное время
                            cycle_end_time:=t.Arr^[i].Arr^[t.Arr^[i].Count - 1];
                            //Если источник - циклический, то автосброс счётчиков
                            if is_cyclic then begin
                              //Начинаем новый цикл
                              val_index:=0;
                              //Остаток от цикла - для точного подстчёта временного смещения
                              if cycle_end_time > 0 then
                                local_time:=local_time - Int(local_time/cycle_end_time)*cycle_end_time
                              else
                                local_time:=0;
                            end
                            else begin
                              //Иначе просто ограничиваем рост счётчика времени
                              if local_time > cycle_end_time then local_time:=cycle_end_time;
                              //Ограничение индекса
                              val_index:=t.Arr^[i].Count - 1;
                            end;
                          end;

                        end
                        else begin
                          local_time:=0;
                          val_index:=0;
                        end;

                        //Выходное значение
                        case interp_method of
                         1: begin
                              //Линейная интерполяция (с учётом цикличности)
                              if val_index > 0 then
                                 Y[0].arr^[i]:=
                                    y_.Arr^[i].Arr^[val_index] +
                                    (local_time - t.Arr^[i].Arr^[val_index])*(y_.Arr^[i].Arr^[val_index] - y_.Arr^[i].Arr^[val_index-1])/
                                    (t.Arr^[i].Arr^[val_index] - t.Arr^[i].Arr^[val_index-1])
                               else
                                 if t.Arr^[i].Arr^[0] > 0 then
                                   Y[0].arr^[i]:=
                                     y_.Arr^[i].Arr^[t.Arr^[i].Count-1] +
                                     local_time*(y_.Arr^[i].Arr^[0] - y_.Arr^[i].Arr^[t.Arr^[i].Count-1])/t.Arr^[i].Arr^[0]
                                 else
                                   Y[0].arr^[i]:=y_.Arr^[i].Arr^[0];
                            end
                        else
                          //Кусочная интерполяция
                          Y[0].arr^[i]:=y_.Arr^[i].Arr^[val_index];
                        end;

                        //Время цикла (дополнительный выход)
                        if cY.Count > 2 then Y[2].arr^[i]:=local_time;

                        //Запоминание времени цикла
                        if Action = f_GoodStep then begin
                          times_arr[i]:=local_time;
                          val_indexes[i]:=val_index;
                        end;

                      end
    end;
  end
end;

function     TStepCycle.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  //Этот блок - функциональный !!!
  case Action of
    i_GetBlockType:  Result:=t_fun;
    i_GetInit:       Result:=0;
    i_GetCount:      begin
                       for I := 0 to cY.Count - 1 do cY[i]:=t.CountX;
                       for I := 0 to cU.Count - 1 do cU[i]:=t.CountX;
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function    TStepCycle.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'interp_method') then begin
      Result:=NativeInt(@interp_method);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'is_cyclic') then begin
      Result:=NativeInt(@is_cyclic);
      DataType:=dtBool;
    end;
  end
end;

function       TStepCycle.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'times_') then begin
      Result:=11;
      DataType:=dtDoubleArray;
      exit;
   end;
   if StrEqu(ParamName,'indexes_') then begin
      Result:=12;
      DataType:=dtIntArray;
   end
  end;
end;

function       TStepCycle.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив таймеров срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=times_arr[i];
          Result:=True;
        end;
    //Массив индексов
    12: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=cY[0];
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=val_indexes[i];
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

procedure      TStepCycle.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(times_arr);
  Stream.Write(i,SizeOfInt);
  Stream.Write(times_arr[0],i*SizeOfDouble);
  Stream.Write(val_indexes[0],i*SizeOf(integer));
end;

function       TStepCycle.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var n,c,j: integer;
     Base: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      n:=Length(times_arr);
      //Количество
      Stream.Read(c,SizeOfInt);
      //Счётчики времени
      Base:=Stream.Position;
      j:=min(n,c);
      if j > 0 then Stream.Read(times_arr[0],j*SizeOfDouble);
      Stream.Position:=Base+c*SizeOfDouble;
      //Состояния
      Base:=Stream.Position;
      j:=min(n,c);
      if j > 0 then Stream.Read(val_indexes[0],j*SizeOf(integer));
      Stream.Position:=Base+c*SizeOf(integer);
    finally
    end
end;

{*******************************************************************************
          Синусоидальный управляемый источник
*******************************************************************************}
constructor TSinusCycle.Create;
begin
  inherited;
  k_period   := 0.25*pi;
end;

function    TSinusCycle.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i,j: integer;
     local_time,w: double;
     sin_1: double;
 const
     c_2pi = 2*pi;
 label
     do_process_step;
begin
  Result:=0;
  case Action of
    f_InitObjects:   begin
                       SetLength(times_arr,cY[0]);
                       for I := 0 to cY[0] - 1 do begin
                         times_arr[i]:=0;
                       end;
                       //Добавляем выход в список считывания данных
                       if NeedRemoteData then
                         if RemoteDataUnit <> nil then begin
                           RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                         end;
                     end;
    f_InitState:     if not NeedRemoteData then begin
                       for I := 0 to cY[0] - 1 do begin
                         times_arr[i]:=0;
                         //Выходное значение при нулевом времени
                         Y[0].arr^[i]:=sin(U[3].Arr^[i])*U[1].Arr^[i];
                         //Начальное время цикла (дополнительный выход)
                         if cY.Count > 1 then Y[1].arr^[i]:=0;
                       end;
                       goto do_process_step;
                     end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : begin

do_process_step:
                      if not NeedRemoteData then

                       for i:=0 to cY[0] - 1 do begin

                        //Для начала мы вычисляем локальное время цикла
                        local_time:=times_arr[i];

                        //Коэффициент ускорения локального времени блока (частотная модуляция)
                        w:=U[2].Arr^[i];

                        //Проверяем активность
                        if U[0].Arr^[i] > 0.5 then begin

                          if U[0].Arr^[i] < 2 then begin
                            //Инкрементация времени (если не пауза)
                            local_time:=local_time + h*w;
                            //Остаток от цикла - для точного подстчёта временного смещения
                            if local_time > c_2pi then
                              local_time:=local_time - Int(local_time/c_2pi)*c_2pi;
                            //Вычисление синуса
                            sin_1:=sin(local_time + U[3].Arr^[i]);
                            //Уточнение шага интегрирования
                            if ModelODEVars.fPreciseSrcStep and (w <> 0) then begin
                              ModelODEVars.fsetstep:=True;
                              ModelODEVars.newstep:=min(ModelODEVars.newstep,k_period/abs(w));
                            end;

                          end
                          else
                            sin_1:=sin(local_time + U[3].Arr^[i]);

                        end
                        else begin
                          local_time:=0;    //По умолчанию - нулевое время
                          sin_1:=sin(U[3].Arr^[i]);
                        end;

                        //Выходное значение
                        Y[0].arr^[i]:=sin_1*U[1].Arr^[i];

                        //Время (фаза) цикла (дополнительный выход)
                        if cY.Count > 1 then Y[1].arr^[i]:=local_time;

                        //Запоминание времени цикла
                        if Action = f_GoodStep then begin
                          times_arr[i]:=local_time;
                        end;

                      end
    end;
  end
end;

function    TSinusCycle.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k_period') then begin
      Result:=NativeInt(@k_period);
      DataType:=dtDouble;
    end;
  end
end;

function     TSinusCycle.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  //Этот блок - функциональный !!!
  case Action of
    i_GetBlockType:  Result:=t_fun;
    i_GetInit:       Result:=0;
    i_GetCount:      begin
                       for I := 0 to cY.Count - 1 do cY[i]:=cU[0];
                       for I := 1 to cU.Count - 1 do cU[i]:=cU[0];
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function       TSinusCycle.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'times_') then begin
      Result:=11;
      DataType:=dtDoubleArray;
   end;
  end;
end;

function       TSinusCycle.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив таймеров срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=times_arr[i];
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

procedure      TSinusCycle.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(times_arr);
  Stream.Write(i,SizeOfInt);
  Stream.Write(times_arr[0],i*SizeOfDouble);
end;

function       TSinusCycle.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
 var n,c,j: integer;
     Base: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      n:=Length(times_arr);
      //Количество
      Stream.Read(c,SizeOfInt);
      //Счётчики времени
      Base:=Stream.Position;
      j:=min(n,c);
      if j > 0 then Stream.Read(times_arr[0],j*SizeOfDouble);
      Stream.Position:=Base+c*SizeOfDouble;
    finally
    end
end;


{*******************************************************************************
                             Равномерный шум
*******************************************************************************}
constructor  TSteady.Create;
begin
  inherited;
  xmin:=TExtArray.Create(1);
  xmax:=TExtArray.Create(1);
  qt:=TExtArray.Create(1);
end;

destructor   TSteady.Destroy;
begin
  xmin.Free;
  xmax.Free;
  qt.Free;
  inherited;
end;

function     TSteady.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (xmax.Count < xmin.Count) or (qt.Count < xmin.Count) then begin
                    ErrorEvent(txtSteadyErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end
                  else
                    SetLength(time,xmin.Count);
    i_GetCount:   cY[0]:=xmin.Count;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TSteady.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'xmin') then begin
      Result:=NativeInt(xmin);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'xmax') then begin
      Result:=NativeInt(xmax);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'qt') then begin
      Result:=NativeInt(qt);
      DataType:=dtDoubleArray;
    end;
  end
end;

function       TSteady.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'time_') then begin
      Result:=11;
      DataType:=dtDoubleArray
   end
  end;
end;

function       TSteady.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=cY[0];
          for I := 0 to TExtArray(DestData).Count - 1 do
            if qt.Arr^[i] > 0 then
              TExtArray(DestData).Arr^[i]:=(time[i] - c_time)
            else
              TExtArray(DestData).Arr^[i]:=0;
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

function    TSteady.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : if not NeedRemoteData then begin

                        if Action = f_InitState then
                          for i:=0 to xmin.Count - 1 do time[i]:=at;

                        for i:=0 to xmin.Count - 1 do begin
                          if time[i] - at <= 0 {0.5*h} then begin
                            Y[0].Arr^[i]:=xmin.Arr^[i] + (xmax.Arr^[i] - xmin.Arr^[i])*Random;
                            time[i]:=time[i] + qt.Arr^[i];
                          end;

                          //Уточнение шага интегрирования
                          if ModelODEVars.fPreciseSrcStep and (qt.Arr^[i] > 0) then begin
                             ModelODEVars.fsetstep:=True;
                             ModelODEVars.newstep:=min(ModelODEVars.newstep,qt.Arr^[i]);
                          end;

                        end;
                        c_time:=at;
                      end;
  end
end;

function       TSteady.RestartLoad;
 var cnt,oldcnt,i: integer;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  oldcnt:=Length(time);
  Stream.Read(cnt,SizeOf(cnt));                //К-во элементов
  SetLength(time,cnt);
  Stream.Read(time[0],cnt*SizeOf(double));     //Данные
  for i := 0 to cnt - 1 do time[i]:=time[i] - TimeShift;
  SetLength(time,oldcnt);
end;

procedure    TSteady.RestartSave;
 var cnt: integer;
begin
  inherited;
  cnt:=Length(time);
  Stream.Write(cnt,SizeOf(cnt));
  Stream.Write(time[0],cnt*SizeOf(double));
end;

{*******************************************************************************
                              Нормальный шум
*******************************************************************************}
constructor  TGauss.Create;
begin
  inherited;
  m:=TExtArray.Create(1);
  d:=TExtArray.Create(1);
  qt:=TExtArray.Create(1);
end;

destructor   TGauss.Destroy;
begin
  m.Free;
  d.Free;
  qt.Free;
  inherited;
end;

function     TGauss.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (d.Count < m.Count) or (qt.Count < m.Count) then begin
                    ErrorEvent(txtGaussErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end
                  else
                    SetLength(time,m.Count);
    i_GetCount:   cY[0]:=m.Count;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TGauss.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'m') then begin
      Result:=NativeInt(m);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'d') then begin
      Result:=NativeInt(d);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'qt') then begin
      Result:=NativeInt(qt);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TGauss.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      :if not NeedRemoteData then
                       begin
                        if Action = f_InitState then
                          for i:=0 to m.Count - 1 do time[i]:=at;
                        for i:=0 to m.Count - 1 do begin
                          if time[i] - at <= 0.5*h then begin
                            Y[0].Arr^[i]:=math.RandG(m.Arr^[i],d.Arr^[i]);
                            time[i]:=time[i] + qt.Arr^[i];
                          end;
                          //Уточнение шага интегрирования
                          if ModelODEVars.fPreciseSrcStep and (qt.Arr^[i] > 0) then begin
                             ModelODEVars.fsetstep:=True;
                             ModelODEVars.newstep:=min(ModelODEVars.newstep,qt.Arr^[i]);
                          end;
                        end;
                      end;
  end
end;

function       TGauss.RestartLoad;
 var cnt,oldcnt,i: integer;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  oldcnt:=Length(time);
  Stream.Read(cnt,SizeOf(cnt));                //К-во элементов
  SetLength(time,cnt);
  Stream.Read(time[0],cnt*SizeOf(double));     //Данные
  for i := 0 to cnt - 1 do time[i]:=time[i] - TimeShift;
  SetLength(time,oldcnt);
end;

procedure    TGauss.RestartSave;
 var cnt: integer;
begin
  inherited;
  cnt:=Length(time);
  Stream.Write(cnt,SizeOf(cnt));
  Stream.Write(time[0],cnt*SizeOf(double));
end;


end.
