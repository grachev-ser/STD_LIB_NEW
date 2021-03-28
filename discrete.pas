
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

unit discrete;

 //***************************************************************************//
 //                      Дискретные блоки                                     //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts;


type

  //Общие свойства дискретных блоков
  TCustomDis = class(TRunObject)
  protected
    time:          array of double;   //Переменная для хранения времени
    ax:            array of double;   //Вектор состояний блока
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    procedure      RestartSave(Stream: TStream);override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Запаздывание на один временной шаг
  TStepDelay = class(TCustomDis)
  public
    it:            NativeInt;
    y0:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override; // Похоже на правду
  end;

  //Разность нулевого порядка
  TZeroSub = class(TStepDelay)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override; //Проверено с прямым моделированием
  end;

  //Экстраполятор нулевого порядка
  TExtrapolator = class(TCustomDis)
  public
    tau:           TExtArray;                                                            //Шаг дискретизации
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override; //Проверено с прямым моделированием
  end;

  //Фильтр хорошего шага (экстраполятор с нулевой задержкой)
  TGoodStepValue = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Дискретное запаздывание
  TDisDelay = class(TExtrapolator)
  public
    fInitFlag:     Boolean;
    y0,u0:         TExtArray;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Дискретная производная
  TDisDiff = class(TDisDelay)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Дискретная передаточная функция общего вида
  TDisWs = class(TExtrapolator)
  public
    b:             TExtArray2;
    a:             TExtArray2;
    y0:            TExtArray2;
    ftauindex:     array of integer;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Дискретная передаточная функция обратного аргумента
  TInvDisWs = class(TDisWs)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Решение дискретной линейной системы
  TDisStates = class(TExtrapolator)
  public
    xc,uc,yc:      NativeInt;
    A_,B_,C_,D_:   TExtArray2;
    Y0:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Дискретный ПИД-регулятор
  TDisPID = class(TDisDelay)
  public
    Kp,
    Ki,
    Kd,
    Tdif:          TExtArray;
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Дискретный интегратор
  TDisIntegrator = class(TDisDelay)
  public
    reset_port:    boolean;
    Ki:            TExtArray;
    constructor    Create(Owner: TObject);override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Модель апериодического звена 1-го порядка с "точным" решением на
  //шаге интегрирования, возможностью трансляции входа и задания
  //постоянной времени через порты
  TAnalAperiodika = class(TCustomDis)
  private
    fNeedShiftAxs: boolean;
  public
    k,
    T,
    Y0        :    TExtArray;
    Inputs    :    TMultiSelect;
    IniFlag   :    NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;

  //Модель апериодического звена 1-го порядка решением по неявной
  //конечно-разностной схеме, возможностью трансляции входа и задания
  //постоянной времени через порты
  TDisAperiodika = class(TAnalAperiodika)
  public
    constructor    Create(Owner: TObject);override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;override;
  end;


implementation

{*******************************************************************************
                 Базовый класс для дискретных блоков.
*******************************************************************************}
constructor TCustomDis.Create(Owner: TObject);
begin
  inherited;
  SetLength(ax,1);   //Начальное распределение для вектора состояний - надо, чтобы сортировка была правильной
end;

function    TCustomDis.InfoFunc;
begin
  case Action of
    i_GetDisCount:  Result:=cY[0];
  else
     Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function       TCustomDis.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'loctime_') then begin
      Result:=12;
      DataType:=dtDoubleArray;
   end;
   if StrEqu(ParamName,'states_') then begin
      Result:=13;
      DataType:=dtDoubleArray;
   end
  end;
end;

function       TCustomDis.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    12: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=Length(time);
          Move(time[0],TExtArray(DestData).Arr^,SizeOf(double)*TExtArray(DestData).Count);
          Result:=True;
        end;
    //Массив флагов срабатывания
    13: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=Length(AX);
          Move(AX[0],TExtArray(DestData).Arr^,SizeOf(double)*TExtArray(DestData).Count);
          Result:=True;
        end;

   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

procedure   TCustomDis.RestartSave(Stream: TStream);
 var i,j: integer;
begin
  inherited;
  i:=-1;
  Stream.Write(i,SizeOfInt);
  i:=Length(AX);
  Stream.Write(i,SizeOfInt);
  j:=Length(time);
  Stream.Write(j,SizeOfInt);
  if j > 0 then
    Stream.Write(time[0],j*SizeOfDouble);
  if i > 0 then
    Stream.Write(AX[0],i*SizeOfDouble);
end;

function    TCustomDis.RestartLoad;
 var c,n,i,nt,ct,minc,minct: integer;
     Base: int64;
     tmptime: double;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      n:=Length(AX);               //Размерность массива переменных состояния
      nt:=Length(time);            //Размерность массива переменных метки времени

      //Читаем ранее сохранённую размерность вектора состояний
      Stream.Read(c,SizeOfInt);

      if c >= 0 then begin

        minc:=min(n,c);

         //Старый рестарт - до векторизации метки времени
        Stream.Read(tmptime,SizeOfDouble);
        tmptime:=tmptime - TimeShift;
        for I := 0 to Length(time) - 1 do time[i]:=tmptime;

        //Считываем массив переменных состояния
        Base:=Stream.Position;
        if minc > 0 then begin
          Stream.Read(AX[0],minc*SizeOfDouble);
        end;
        Stream.Position:=Base+c*SizeOfDouble;

      end
      else begin

        //Читаем размерности вектора временных меток и переменных состояния
        Stream.Read(c,SizeOfInt);
        minc:=min(n,c);

        Stream.Read(ct,SizeOfInt);
        minct:=min(nt,ct);

        Base:=Stream.Position;       //Считываем массив временных меток с учётом временного сдвига !!!
        if minct > 0 then begin
          Stream.Read(time[0],minct*SizeOfDouble);
          for I := 0 to minct - 1 do time[i]:=time[i] - TimeShift;
        end;
        Stream.Position:=Base+ct*SizeOfDouble;

        Base:=Stream.Position;       //Считываем массив переменных состояния
        if minc > 0 then begin
          Stream.Read(AX[0],minc*SizeOfDouble);
        end;
        Stream.Position:=Base+c*SizeOfDouble;

      end;
    finally
    end
end;


{*******************************************************************************
Запаздывание на один временной шаг
Параметры блока :
 y0 - вектор начальных приближений состояний векторного выхода  Y(0).
*******************************************************************************}
constructor TStepDelay.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
end;

destructor  TStepDelay.Destroy;
begin
  inherited;
  y0.Free;
end;

function    TStepDelay.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'it') then begin
      Result:=NativeInt(@it);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TStepDelay.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:      begin
                      cU[0]:=y0.Count;
                      cY[0]:=y0.Count;
                     end;
    i_GetInit:       case it of
                       0: Result:=0;    //нет развязки петель
                     else
                       Result:=1;
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TStepDelay.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j : Integer;
begin
  Result:=0;
  case Action of
  f_InitObjects:    begin
                      SetLength(ax,y0.Count);
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
  f_InitState:      if not NeedRemoteData then begin
                     Move(Y0.arr^,Y[0].arr^,Y0.Count*SOfR);
                     for j:=0 to Y0.Count-1 do AX[j]:=Y[0].arr^[j];
                    end;
  f_UpdateJacoby,
  f_UpdateOuts,
  f_RestoreOuts,
  f_GoodStep      : if not NeedRemoteData then for j:=0 to Y0.Count-1 do Y[0].arr^[j]:=AX[j];
  f_SetState      : if not NeedRemoteData then for j:=0 to Y0.Count-1 do AX[j]:=U[0].arr^[j];
  end;
end;

  //Эта функция используется для обеспечения частотного анализа дискретных блоков
function      TStepDelay.GetDisData;
 var j: integer;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     f_GetDelayTime: x^[0]:=ModelODEVars.Step;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  for j:=0 to Y0.Count-1 do begin
                       x^[j]:=AX[j];
                       fx^[j]:=U[0].arr^[j];
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                     Разность нулевого порядка
*******************************************************************************}
function   TZeroSub.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j : Integer;
begin
  Result:=0;
  case Action of
  f_InitObjects:    SetLength(ax,y0.Count);
  f_InitState:      Move(Y0.arr^,Y[0].arr^,Y0.Count*SOfR);
  f_UpdateJacoby,
  f_UpdateOuts,
  f_RestoreOuts,
  f_GoodStep      : for j:=0 to Y0.Count-1 do Y[0].arr^[j]:=U[0].Arr^[j] - AX[j];
  f_SetState      : for j:=0 to Y0.Count-1 do AX[j]:=U[0].arr^[j];
  end;
end;

  //Эта функция используется для обеспечения частотного анализа дискретных блоков
function      TZeroSub.GetDisData;
 var j: integer;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: x^[0]:=ModelODEVars.Step;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  for j:=0 to Y0.Count-1 do begin
                       x^[j]:=AX[j];
                       fx^[j]:=U[0].arr^[j];
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                   Экстраполятор нулевого порядка
*******************************************************************************}
constructor TExtrapolator.Create(Owner: TObject);
begin
  inherited;
  tau:=TExtArray.Create(1);
end;

destructor  TExtrapolator.Destroy;
begin
  inherited;
  tau.Free;
end;

function    TExtrapolator.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TExtrapolator.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:      cY[0]:=cU[0];
    i_GetBlockType:  Result:=t_ext;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TExtrapolator.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i: integer;
 label precise_step;
begin
  Result:=0;
  case Action of
   f_InitObjects:    begin
                      SetLength(time,Y[0].Count);
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                     end;
   f_InitState:      if not NeedRemoteData then begin
                        Move(U[0].arr^,Y[0].arr^,U[0].Count*SOfR);
                        for I := 0 to Y[0].Count - 1 do
                          time[i]:=at + tau[i];
                        goto precise_step;
                     end;
   f_GoodStep:       if (not NeedRemoteData) then begin
                         for i := 0 to Y[0].Count - 1 do
                           if (time[i]-at <= 0.5*h) then begin
                             Y[0].arr^[i]:=U[0].arr^[i];
                             time[i]:=time[i]+tau[i];
                           end;
                       goto precise_step;
                     end;
   f_UpdateOuts,
   f_RestoreOuts:    if (not NeedRemoteData) then begin
                       precise_step:
                       for i := 0 to Y[0].Count - 1 do
                         if ModelODEVars.fPreciseSrcStep and (tau[i] > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[i] - at,0)),tau[i]);
                         end;
                     end;
  end;
end;

function       TExtrapolator.GetDisData;
begin
  Result:=0;
  case Action of
     f_GetDelayTime: x^[0]:=tau[Index];
  end;
end;

{*******************************************************************************
                       Дискретное запаздывание
*******************************************************************************}
constructor TDisDelay.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
  u0:=TExtArray.Create(1);
  fInitFlag:=False;
end;

destructor  TDisDelay.Destroy;
begin
  inherited;
  y0.Free;
  u0.Free;
end;

function    TDisDelay.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'u0') then begin
      Result:=NativeInt(u0);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'init_by_inputs') then begin
      Result:=NativeInt(@fInitFlag);
      DataType:=dtBool;
    end
  end
end;

function    TDisDelay.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:      begin
                       cY[0]:=cU[0];
                       for i := 1 to cU.Count - 1 do cU[i]:=cY[0];
                     end;
    i_GetBlockType : Result:=t_fun;
    i_GetInit:       if fInitFlag then
                       Result:=0
                     else
                       Result:=1;
    i_GetDisCount:   Result:=cY[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TDisDelay.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var
     j :     Integer;
     tmptau: Double;
 label
     precise_step;
begin
  Result:=0;
  case Action of
  f_InitObjects:    begin
                      SetLength(time, Y[0].Count);
                      SetLength(ax,   2*Y[0].Count);
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
  f_InitState     : if not NeedRemoteData then begin
                      for j := 0 to Y[0].Count - 1 do begin
                        tau.TryGet( j, tmptau);
                        //Инициализация внутреннх состояний
                        if fInitFlag then
                          AX[j]:=U[0].arr^[j]
                        else
                          u0.TryGet( j, AX[j] );
                        //Инициализация выхода блока
                        Y0.TryGet( j, AX[Y[0].Count + j] );
                        Y[0].arr^[j]:=AX[j + Y[0].Count];
                        //Инициализация таймера блока
                        time[j]:=at+tmptau;
                        if ModelODEVars.fPreciseSrcStep and (tmptau > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(ModelODEVars.newstep,tmptau);
                        end;
                      end;
                    end;
  f_SetState      : if not NeedRemoteData then begin
                      for j:=0 to Y[0].Count-1 do begin
                        tau.TryGet( j, tmptau);
                        if time[j]-at <= 0.5*h then begin
                          AX[j + Y[0].Count]:=AX[j];
                          AX[j]:=U[0].arr^[j];
                          time[j]:=time[j]+tmptau;
                        end;
                      end;
                      goto precise_step;
                    end;
  f_GoodStep,
  f_UpdateJacoby,
  f_UpdateOuts,
  f_RestoreOuts:   if not NeedRemoteData then begin

         precise_step:

                       for j:=0 to Y[0].Count-1 do begin
                         //Обновление выхода
                         tau.TryGet( j, tmptau);
                         Y[0].arr^[j]:=AX[j + Y[0].Count];
                         //Уточнение шага
                         if ModelODEVars.fPreciseSrcStep and (tmptau > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[j] - at,0)),tmptau);
                         end;
                       end;
                    end;
  end;
end;

  //Эта функция используется для обеспечения частотного анализа дискретных блоков
function      TDisDelay.GetDisData;
 var j: integer;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     f_GetDelayTime: if Index < tau.Count then x^[0]:=tau[Index] else x^[0]:=tau[tau.Count - 1];
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  for j:=0 to Y[0].Count-1 do begin
                       x^[j]:=AX[j + Y[0].Count];
                       fx^[j]:=U[0].arr^[j];
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index + Y[0].Count]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                       Дискретная производная
*******************************************************************************}
function    TDisDiff.InfoFunc;
begin
  case Action of
    i_GetInit:       Result:=0;   //Этот блок мгновенно зависимый от входа (см обработчик f_GoodStep) !!!
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TDisDiff.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var
    j :     Integer;
    tmptau: Double;
 label
    precise_step;
begin
  Result:=0;
  case Action of
  f_InitObjects:    begin
                      SetLength(ax,   Y[0].Count);
                      SetLength(time, Y[0].Count);
                    end;
  f_InitState     : begin
                      for j:=0 to Y[0].Count-1 do begin
                        Y0.TryGet( j, Y[0].arr^[j] );
                        tau.TryGet( j, tmptau);
                        time[j]:=at;
                        if ModelODEVars.fPreciseSrcStep and (tmptau > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,tmptau);
                        end;
                      end;
                    end;
  f_SetState   :    begin
                      for j:=0 to Y[0].Count-1 do begin
                        tau.TryGet( j, tmptau);
                        if (time[j]-at) <= 0.5*h then begin
                          AX[j]:=U[0].arr^[j];
                          time[j]:=time[j]+tmptau;
                        end;
                      end;
                      goto precise_step;
                    end;
  f_RestoreOuts,
  f_UpdateJacoby:   for j:=0 to Y[0].Count-1 do begin
                      tau.TryGet( j, tmptau);
	  	                Y[0].arr^[j]:=(U[0].arr^[j]-AX[j])/tmptau;
                    end;
  f_GoodStep   :    for j:=0 to Y[0].Count-1 do begin
                      tau.TryGet( j, tmptau);
                      if (time[j]-at) <= 0.5*h then
	                      Y[0].arr^[j]:=(U[0].arr^[j]-AX[j])/tmptau;
                    end;
  f_UpdateOuts:     begin
                       precise_step:
                       for j:=0 to Y[0].Count-1 do begin
                         tau.TryGet( j, tmptau);
                         if ModelODEVars.fPreciseSrcStep and (tmptau > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[j] - at,0)),tmptau);
                         end;
                       end;
                    end;
  end;
end;

  //Эта функция используется для обеспечения частотного анализа дискретных блоков
function      TDisDiff.GetDisData;
 var j: integer;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     f_GetDelayTime: if Index < tau.Count then x^[0]:=tau[Index] else x^[0]:=tau[tau.Count - 1];
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  for j:=0 to Y[0].Count-1 do begin
                       x^[j]:=AX[j];
                       fx^[j]:=U[0].arr^[j];
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                    Передаточная функция общего вида
*******************************************************************************}
constructor TDisWs.Create;
begin
  inherited;
  a:=TExtArray2.Create(1,1);
  b:=TExtArray2.Create(1,1);
  y0:=TExtArray2.Create(1,1);
end;

destructor  TDisWs.Destroy;
begin
  inherited;
  a.Free;
  b.Free;
  y0.Free;
end;

function    TDisWs.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtMatrix;
      exit;
    end;
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtMatrix;
      exit;
    end;
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtMatrix;
    end;
  end
end;

function    TDisWs.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr:   if (a.CountX < y0.CountX) or (b.CountX < y0.CountX) then begin
                      ErrorEvent(txtArrLessX0,msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end
                    else
                      for i:=0 to y0.CountX - 1 do begin
                        if a[i].count < b[i].count then begin
                           ErrorEvent(txtNumDimError,msError,VisualObject);
                           Result:=r_Fail;
                           exit;
                        end;
                        if (a[i].count < 2) then begin
                           ErrorEvent(txtDeNumDimLess2,msError,VisualObject);
                           Result:=r_Fail;
                           exit;
                        end;
                        if a[i].arr^[a[i].count-1] = 0 then begin
                           ErrorEvent(txtDenumGainEquZero,msError,VisualObject);
                           Result:=r_Fail;
                           exit;
                        end
                      end;
    i_GetInit:        begin
                        Result:=1;
                        for i:=0 to y0.CountX - 1 do
                          if b[i].count >= a[i].count then begin
                             Result:=0;
                             exit;
                          end
                      end;
    i_GetCount:       begin
                        cU[0]:=y0.CountX;
                        cY[0]:=y0.CountX;
                      end;
    i_GetDisCount:    Result:=Length(ax);
    i_GetBlockType:   Result:=t_fun;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TDisWs.RunFunc;
 var i,j,n,m,c : Integer;
     x_,y_    : RealType;
 label 1,precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Подсчитываем к-во переменных состояния
                     c:=0;
                     for j:=0 to y0.CountX - 1 do c:=c + (a[j].Count - 1);
                     SetLength(ax,c);
                     SetLength(ftauindex,c);
                     //Заполнение индекса для определения типа переменной
                     c:=0;
                     for j:=0 to y0.CountX - 1 do
                       for m := 0 to a[j].Count - 2 do begin
                         ftauindex[c]:=j;
                         inc(c);
                       end;
                     SetLength(time,y0.CountX);
                     if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                   end;
  f_InitState:     if not NeedRemoteData then begin
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                       n:=a[i].count-1;
                       for j:=0 to n-2 do AX[c + j]:=0;
                       AX[c + n-1]:=Y0[i].arr^[0];
                       c:=c + y0[i].Count;
                       time[i]:=at;
                       if ModelODEVars.fPreciseSrcStep and (tau[i] > 0) then begin
                         ModelODEVars.fsetstep:=True;
                         ModelODEVars.newstep:=min(ModelODEVars.newstep,tau[i]);
                       end;
                     end;
                     goto 1;
                   end;
  f_UpdateJacoby  : if not NeedRemoteData then begin
1:
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                       n:=a[i].count-1;
                       m:=b[i].count-1;
                       x_:=b[i].arr^[m]/a[i].arr^[n];
                       if n = m then
                         Y[0].arr^[i]:=AX[c + n-1]+x_*U[0].arr^[i]
                       else
                         Y[0].arr^[i]:=AX[c + n-1];
                       c:=c + y0[i].Count;
                     end
                    end;
  f_GoodStep      : if not NeedRemoteData then begin
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                         if time[i]-at <= 0.5*h then begin
                           n:=a[i].count-1;
                           m:=b[i].count-1;
                           x_:=b[i].arr^[m]/a[i].arr^[n];
                           if n = m then
                             Y[0].arr^[i]:=AX[c + n-1]+x_*U[0].arr^[i]
                           else
                             Y[0].arr^[i]:=AX[c + n-1];
                         end;
                         c:=c + y0[i].Count;
                       end
                    end;
  f_SetState      : if not NeedRemoteData then begin
                       c:=0;
                       for i:=0 to y0.CountX - 1 do begin
                         if time[i] - at <= 0.5*h then begin
                           n:=a[i].count-1;
                           m:=b[i].count-1;
                           x_:=a[i].arr^[n];
                           y_:=Y[0].arr^[i];
                           for j:=n-1 downto 1 do AX[c + j]:=AX[c + j-1]-a[i].arr^[j]/x_*y_;
                           AX[c]:=-a[i].arr^[0]/x_*y_;
                           for j:=0 to min(n-1,m) do AX[c + j]:=AX[c + j]+b[i].arr^[j]/x_*U[0].arr^[i];
                           time[i]:=time[i]+tau[i];
                         end;
                         c:=c + y0[i].Count;
                       end;
                       goto precise_step;
                    end;
  f_RestoreOuts,
  f_UpdateOuts:     if not NeedRemoteData then begin
                       precise_step:
                       for i:=0 to y0.CountX - 1 do
                         if ModelODEVars.fPreciseSrcStep and (tau[i] > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[i] - at,0)),tau[i]);
                         end;
                    end;

  end
end;

function       TDisWs.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,j,n,m,c: integer;
     x_,y_: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: begin
                       x^[0]:=tau[ftauindex[Index]];
                     end;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  begin
                       c:=0;
                       for i := 0 to Length(ax) - 1 do x^[i]:=AX[i];
                       for i:=0 to y0.CountX - 1 do begin
                         n:=a[i].count-1;
                         m:=b[i].count-1;
                         x_:=a[i].arr^[n];
                         if n = m then
                           y_:=AX[n-1]+b[i].arr^[m]/x_*U[0].arr^[i]
                         else
                           y_:=AX[n-1];
                         for j:=n-1 downto 1 do fx^[c+j]:=AX[c+j-1]-a[i].arr^[j]/x_*y_;
                         fx^[0]:=-a[i].arr^[0]/x_*y_;
                         for j:=0 to min(n-1,m) do fx^[c+j]:=fx^[c+j]+b[i].arr^[j]/x_*U[0].arr^[i];
                         c:=c + y0[i].Count;
                       end;
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;



{*******************************************************************************
            Дискретная передаточная функция от обратного аргумента
*******************************************************************************}
function    TInvDisWs.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr:   if (a.CountX < y0.CountX) or (b.CountX < y0.CountX) then begin
                      ErrorEvent(txtArrLessX0,msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end
                    else
                      for i:=0 to y0.CountX - 1 do begin
                        if (a[i].count < 2) and (b[i].count < 2) then begin
                           ErrorEvent(txtDeNumDimLess2,msError,VisualObject);
                           Result:=r_Fail;
                           exit;
                        end;
                        if a[i].arr^[0] = 0 then begin
                           ErrorEvent(txtDenumGainEquZero,msError,VisualObject);
                           Result:=r_Fail;
                           exit;
                        end
                      end;
    i_GetInit:        begin
                        Result:=1;
                        for i:=0 to y0.CountX - 1 do
                          if ABS(b[i].arr^[0])/2 + 1 <> 1 then begin
                             Result:=0;
                             exit;
                          end
                      end;
    i_GetCount:       begin
                        cU[0]:=y0.CountX;
                        cY[0]:=y0.CountX;
                      end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TInvDisWs.RunFunc;
 var i,j,n,m,c,l : Integer;
     x_       : RealType;
 label 1,precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Подсчитываем к-во переменных состояния
                     c:=0;
                     for j:=0 to y0.CountX - 1 do c:=c + max(a[j].count-1,b[j].count-1);
                     SetLength(ax,c);
                     SetLength(ftauindex,c);
                     //Заполнение индекса для определения типа переменной
                     c:=0;
                     for j:=0 to y0.CountX - 1 do
                       for m := 0 to max(a[j].count-1,b[j].count-1) - 1 do begin
                         ftauindex[c]:=j;
                         inc(c);
                       end;
                     SetLength(time,y0.CountX);
                     {if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;}
                   end;
  f_InitState:     {if not NeedRemoteData then} begin
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                       n:=max(a[i].count-1,b[i].count-1);
                       for j:=1 to n-1 do AX[c + j]:=0;
                       AX[c]:=Y0[i].arr^[0];
                       c:=c + y0[i].Count;
                       time[i]:=at;
                       if ModelODEVars.fPreciseSrcStep and (tau[i] > 0) then begin
                         ModelODEVars.fsetstep:=True;
                         ModelODEVars.newstep:=min(ModelODEVars.newstep,tau[i]);
                       end;
                     end;
                     goto 1;
                   end;
  f_UpdateJacoby  : {if not NeedRemoteData then} begin
1:
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                       x_:=b[i].arr^[0]/a[i].arr^[0];
                       Y[0].arr^[i]:=AX[c]+x_*U[0].arr^[i];
                       c:=c + y0[i].Count;
                     end
                    end;
  f_GoodStep      : {if not NeedRemoteData then} begin
                     c:=0;
                     for i:=0 to y0.CountX - 1 do begin
                       if time[i]-at <= 0.5*h then begin
                         x_:=b[i].arr^[0]/a[i].arr^[0];
                         Y[0].arr^[i]:=AX[c]+x_*U[0].arr^[i];
                       end;
                       c:=c + y0[i].Count;
                     end
                    end;
  f_SetState      : {if not NeedRemoteData then} begin
                      c:=0;
                      for i:=0 to y0.CountX - 1 do begin
                        if time[i]-at <= 0.5*h then begin
                          l:=a[i].count-1;
                          m:=b[i].count-1;
                          n:=max(l,m);
                          x_:=a[i].arr^[0];
                          for j:=0 to n-2 do AX[c+ j]:=AX[c+j+1];
                          AX[c+n-1]:=0;
                          for j:=0 to l-1 do
                            AX[c+j]:=AX[c+j]-a[i].arr^[j+1]/x_*Y[0].arr^[i];
                          for j:=0 to m-1 do
                            AX[c+j]:=AX[c+j]+b[i].arr^[j+1]/x_*U[0].arr^[i];
                          time[i]:=time[i]+tau[i];
                        end;
                        c:=c + y0[i].Count;
                      end;
                      goto precise_step;
                    end;
  f_RestoreOuts,
  f_UpdateOuts:     {if not NeedRemoteData then} begin
                       precise_step:
                       for i:=0 to y0.CountX - 1 do
                         if ModelODEVars.fPreciseSrcStep and (tau[i] > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[i] - at,0)),tau[i]);
                         end;
                    end;

  end
end;

function       TInvDisWs.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,j,n,m,c,l: integer;
     x_,y_: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: x^[0]:=tau[ftauindex[Index]];
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  begin
                       c:=0;
                       for i := 0 to Length(ax) - 1 do x^[i]:=AX[i];
                       for i:=0 to y0.CountX - 1 do begin
                         l:=a[i].count-1;
                         m:=b[i].count-1;
                         n:=max(l,m);
                         x_:=a[i].arr^[0];
                         y_:=AX[0]+b[i].arr^[0]/x_*U[0].arr^[i];

                         for j:=0 to n-2 do fx^[c+j]:=AX[c+j+1];
                         fx^[n-1]:=0;

                         for j:=0 to l-1 do
                           fx^[c+j]:=fx^[c+j]-a[i].arr^[j+1]/x_*y_;
                         for j:=0 to m-1 do
                           fx^[c+j]:=fx^[c+j]+b[i].arr^[j+1]/x_*U[0].arr^[i];

                         c:=c + y0[i].Count;
                       end;

                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                 Решение дискретной линейной системы
*******************************************************************************}
constructor TDisStates.Create;
begin
  inherited;
  A_:=TExtArray2.Create(1,1);
  B_:=TExtArray2.Create(1,1);
  C_:=TExtArray2.Create(1,1);
  D_:=TExtArray2.Create(1,1);
  Y0:=TExtArray.Create(1);
end;

destructor  TDisStates.Destroy;
begin
  inherited;
  A_.Free;
  B_.Free;
  C_.Free;
  D_.Free;
  Y0.Free;
end;

function    TDisStates.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'xc') then begin
     Result:=NativeInt(@xc);
     DataType:=dtInteger;
     exit;
   end;
   if StrEqu(ParamName,'yc') then begin
     Result:=NativeInt(@yc);
     DataType:=dtInteger;
     exit;
   end;
   if StrEqu(ParamName,'uc') then begin
     Result:=NativeInt(@uc);
     DataType:=dtInteger;
     exit;
   end;
   if StrEqu(ParamName,'A') then begin
     Result:=NativeInt(A_);
     DataType:=dtMatrix;
     exit;
   end;
   if StrEqu(ParamName,'B') then begin
     Result:=NativeInt(B_);
     DataType:=dtMatrix;
     exit;
   end;
   if StrEqu(ParamName,'C') then begin
     Result:=NativeInt(C_);
     DataType:=dtMatrix;
     exit;
   end;
   if StrEqu(ParamName,'D') then begin
     Result:=NativeInt(D_);
     DataType:=dtMatrix;
     exit;
   end;
   if StrEqu(ParamName,'y0') then begin
     Result:=NativeInt(y0);
     DataType:=dtDoubleArray;
   end;
 end
end;

function    TDisStates.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i,j: integer;
begin
  Result:=0;
  case Action of
    i_GetInit:      begin
                      //Замечание: в случае переменных к-в D этот алгоритм ошибочен !!!
               		    Result:=1;
		                  for i:=0 to D_.countx-1 do
		                    for j:=0 to D_.Arr^[i].count-1 do
		                      if D_[i][j] <> 0 then begin Result:=0; break end
                    end;
    i_GetCount:     begin
		                  CU.arr^[0]:=uc;
		                  CY.arr^[0]:=yc;
                    end;
    i_GetPropErr:  if (xc <> A_.CountX) or
                      (xc <> A_.GetMinCountY) or
                      (uc <> B_.CountX) or
                      (xc <> B_.GetMinCountY) or
                      (yc <> C_.GetMinCountY) or
                      (xc <> C_.CountX) or
                      (uc <> D_.CountX) or
                      (yc <> D_.GetMinCountY) then begin
                        ErrorEvent(txtErrorMatrixDim,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end;
     i_GetDisCount: Result:=xc;
     i_GetBlockType:Result:=t_fun;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TDisStates.RunFunc;
   var  i,j : Integer;
     sum  : RealType;
  label
    precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    SetLength(ax,xc);
                    SetLength(time,1);
                  end;
    f_InitState:  begin
                   for i:=0 to xc-1 do AX[i]:=Y0.arr^[i];
                   for i:=0 to yc-1 do begin
                    Y[0].arr^[i]:=0;
                    for j:=0 to xc-1 do
                    Y[0].arr^[i]:=Y[0].arr^[i] + C_.val(j,i)*AX[j];
                   end;
                   for i:=0 to yc-1 do
                   for j:=0 to uc-1 do
                   Y[0].arr^[i]:=Y[0].arr^[i]+ D_.val(j,i)*U[0].arr^[j];
                   time[0]:=at;
                   if ModelODEVars.fPreciseSrcStep and (tau[0] > 0) then begin
                      ModelODEVars.fsetstep:=True;
                      ModelODEVars.newstep:=min(ModelODEVars.newstep,tau[0]);
                   end;
                  end;
   f_RestoreOuts,
   f_UpdateJacoby:begin
                   for i:=0 to yc-1 do begin
                    Y[0].arr^[i]:=0;
                    for j:=0 to xc-1 do
                    Y[0].arr^[i]:=Y[0].arr^[i] + C_.val(j,i)*AX[j]
                   end;
                   for i:=0 to yc-1 do for j:=0 to uc-1 do
                    Y[0].arr^[i]:=Y[0].arr^[i]+ D_.val(j,i)*U[0].arr^[j]
                  end;
 f_GoodStep  :    if time[0]-at <= 0.5*h then begin
                   for i:=0 to yc-1 do begin
                    Y[0].arr^[i]:=0;
                    for j:=0 to xc-1 do
                     Y[0].arr^[i]:=Y[0].arr^[i] + C_.val(j,i)*AX[j]
                   end;

                   for i:=0 to yc-1 do for j:=0 to uc-1 do
                    Y[0].arr^[i]:=Y[0].arr^[i]+ D_.val(j,i)*U[0].arr^[j]
                  end;
 f_SetState   :   begin
                   if time[0]-at <= 0.5*h then begin
                      for i:=0 to xc-1 do begin
                        sum:=0;
                        for j:=0 to xc-1 do sum:=sum+A_.val(j,i)*AX[j];
                        for j:=0 to uc-1 do sum:=sum+B_.val(j,i)*U[0].arr^[j];

                        //Изменяем переменные состояния x(i+1) = a*x + b*u
                        AX[i]:=sum;
                      end;
                      time[0]:=time[0]+tau[0];
                   end;
                   goto precise_step;
                  end;
  f_UpdateOuts:     begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (tau[0] > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[0] - at,0)),tau[0]);
                       end;
                    end;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

function       TDisStates.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,j: integer;
     sum: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: x^[0]:=tau[0];
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:   for i:=0 to xc-1 do begin
                        sum:=0;
                        for j:=0 to xc-1 do sum:=sum+A_.val(j,i)*AX[j];
                        for j:=0 to uc-1 do sum:=sum+B_.val(j,i)*U[0].arr^[j];
                        //x - дискретная переменная на текущем шаге
                        x^[i]:=AX[i];
                        //fx - дискретная переменная на следующем шаге
                        fx^[i]:=sum;
                      end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;



{*******************************************************************************
                        Дискретный ПИД-регулятор
*******************************************************************************}
constructor TDisPID.Create(Owner: TObject);
begin
  inherited;
  Kp   := TExtArray.Create(1);
  Ki   := TExtArray.Create(1);
  Kd   := TExtArray.Create(1);
  Tdif := TExtArray.Create(1);
end;

function    TDisPID.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'kp') then begin
      Result:=NativeInt(kp);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'ki') then begin
      Result:=NativeInt(ki);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'kd') then begin
      Result:=NativeInt(kd);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'tdif') then begin
      Result:=NativeInt(Tdif);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TDisPID.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:      begin
                       cY[0]:=cU[0];
                     end;
    i_GetBlockType : Result:=t_fun;
    i_GetInit:       Result:=0;
    i_GetDisCount:   Result:=cY[0]*3;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TDisPID.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var j,c : Integer;
      tmp_ki,
      tmp_kp,
      tmp_kd,
      tmpy0,
      tmptau,
      tmptdif: double;

  label precise_step;

  procedure  DoGetPrms;
  begin
    Tdif.TryGet( j , tmptdif);
    tau.TryGet(  j , tmptau);
  end;

  procedure  DoUpdateOut;
   var tdiftmp: Double;

  begin
      //Пересчёт выхода
      if tmptdif > 0 then
        tdiftmp:=(U[0].arr^[j]-AX[c + 2])/tmptdif
      else
        tdiftmp:=(U[0].arr^[j]-AX[c + 2])/tmptau;

      Ki.TryGet(j, tmp_ki);
      Kp.TryGet(j, tmp_kp);
      Kd.TryGet(j, tmp_kd);

      Y[0].arr^[j]:=tmp_ki*(AX[c]+tmptau*U[0].arr^[j])+            //Интегральная
                    tmp_kp*U[0].arr^[j]+                           //Пропорциональная
                    tmp_kd*tdiftmp;                                //Инерционно-дифференцирующая составляющая
  end;

begin
  Result:=0;
  case Action of
  f_InitObjects:    begin
                      SetLength(ax,3*Y[0].Count);
                      SetLength(time,Y[0].Count);
                    end;
  f_InitState     : begin
                      c:=0;
                      for j:=0 to Y[0].Count - 1 do begin
                        y0.TryGet( j, tmpy0);
                        DoGetPrms;
                        AX[c]:=0.0;
                        AX[c]:=tmpy0;
                        AX[c + 1]:=U[0].arr^[j];
                        if (tmptdif > 0) then
                          AX[c + 2]:=-tmptdif*tmpy0
                        else
                          AX[c + 2]:=U[0].arr^[j];
                        DoUpdateOut;
                        time[j]:=at+tmptau;
                        inc(c,3);
                      end;
                      goto precise_step;
                    end;
  f_RestoreOuts,
  f_UpdateJacoby  : begin
                      c:=0;
                      for j:=0 to Y[0].Count - 1 do begin
                        DoGetPrms;
                        DoUpdateOut;
                        inc(c,3);
                      end;
                    end;
  f_GoodStep      : begin
                     c:=0;
                     for j:=0 to Y[0].Count - 1 do begin
                       DoGetPrms;
                       if time[j]-at <= 0.5*h then DoUpdateOut;
                       inc(c,3);
                     end;
                    end;
  f_SetState     : begin
                       c:=0;
                       for j:=0 to Y[0].Count - 1 do begin
                         DoGetPrms;
                         if time[j]-at <= 0.5*h then begin
                           AX[c]:=AX[c] + tmptau*U[0].arr^[j];
                           AX[c + 1]:=U[0].arr^[j];
                           if tmptdif > 0 then
                             AX[c + 2]:=AX[c + 2] + tmptau*(U[0].arr^[j]-AX[c + 2])/tmptdif
                           else
                             AX[c + 2]:=U[0].arr^[j];
                           time[j]:=time[j]+tmptau;
                         end;
                         inc(c,3);
                       end;
                       goto precise_step;
                    end;
  f_UpdateOuts:     begin
                       precise_step:
                       for j:=0 to Y[0].Count - 1 do begin
                         tau.TryGet(  j , tmptau);
                         if ModelODEVars.fPreciseSrcStep and (tmptau > 0) then begin
                            ModelODEVars.fsetstep:=True;
                            ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[j] - at,0)),tau[j]);
                         end;
                       end;
                    end;
  end;
end;

function       TDisPID.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,c: integer;
     tmptau,
     tmptdif: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: begin
                       i:=Index div 3;
                       if i < tau.Count then x^[0]:=tau[i] else x^[0]:=tau[ tau.Count - 1 ];
                     end;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  begin
                       c:=0;
                       for i:=0 to Y[0].Count - 1 do begin
                         Tdif.TryGet( i , tmptdif);
                         tau.TryGet(  i , tmptau);
                         fx^[c]:=AX[c]+tmptau*U[0].arr^[i];
                         fx^[c + 1]:=U[0].arr^[i];
                         if tmptdif > 0 then
                           fx^[c + 2]:=AX[c + 2] + tmptau*(U[0].arr^[i]-AX[c + 2])/tmptdif
                         else
                           fx^[c + 2]:=U[0].arr^[i];
                         x^[c]:=AX[c];
                         x^[c + 1]:=AX[c + 1];
                         x^[c + 2]:=AX[c + 2];
                         inc(c,3);
                       end;
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;



{*******************************************************************************
                     Аналитическая апериодика
*******************************************************************************}
constructor TAnalAperiodika.Create;
begin
  inherited;
  fNeedShiftAxs:=True;
  k:=TExtArray.Create(1);
  y0:=TExtArray.Create(1);
  T:=TExtArray.Create(1);
  Inputs:=TMultiSelect.Create;
end;

destructor  TAnalAperiodika.Destroy;
begin
  inherited;
  y0.Free;
  k.Free;
  T.Free;
  inputs.Free;
end;

function    TAnalAperiodika.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'iniflag') then begin
      Result:=NativeInt(@iniflag);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'T') then begin
      Result:=NativeInt(T);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'inputs') then begin
      Result:=NativeInt(inputs);
      DataType:=dtMultiSelect;
    end;
  end
end;

function    TAnalAperiodika.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr:   begin
                     if (k.Count < y0.Count) or (T.Count < y0.Count) then begin
                       ErrorEvent(txtkTlessY0,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     for i:=0 to y0.Count-1 do if T[i] <= 0 then begin
                       ErrorEvent(txtTimeEqZero,msWarning,VisualObject);
                       exit;
                     end
                    end;
    i_GetCount:     begin
                      for i:=0 to CU.Count-1 do CU.arr^[0]:=Y0.Count;
                      CY.arr^[0]:=Y0.Count;
                    end;
    //Тут должно быть всегда 0, т.к. иначе возникают гнилые ошибки со сгенерированным кодом !!!
    i_GetInit:      {if IniFlag = 0 then Result:=1 else }Result:=0;
    //Возвращаем к-во дискретных переменных
    i_GetDisCount: Result:=Y0.Count;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TAnalAperiodika.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j   : Integer;
    x,tau : RealType;
    flag  : Boolean;
begin
  Result:=0;
  case Action of
  f_InitObjects: begin
                   SetLength(ax,2*y0.Count);
                   if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
                 end;
  f_InitState  : if not NeedRemoteData then
                   for i:=0 to Y0.Count-1 do begin
                     if IniFlag = 0 then
                        Y[0].arr^[i]:=Y0.arr^[i]
                     else
                        Y[0].arr^[i]:=U[0].arr^[i]*k.arr^[i];
                     AX[i]:=Y[0].arr^[i]
                   end;
  f_SetState:   if not NeedRemoteData then
                  for i:=0 to Y0.Count-1 do begin
                    AX[i+Y0.Count]:=at;
                    AX[i]:=Y[0].arr^[i]
                  end;
  f_RestoreOuts:if not NeedRemoteData then
                   for i:=0 to Y0.Count-1 do begin
                     Y[0].arr^[i]:=AX[i];
                     AX[i+Y0.Count]:=at;
                   end;
  f_UpdateJacoby,
  f_UpdateOuts,
  f_GoodStep:  if not NeedRemoteData then
                 for i:=0 to Y0.Count-1 do begin
                   x:=k.arr^[i]*U[0].arr^[i];
                   tau:=T.arr^[i];
                   flag:=false;

                   //Обрабатываем дополнительные входы
                   with Inputs do
                    for j:=0 to Length(Selection) - 1 do
                      case selection[j] of
                        0: flag:=U[j+1].arr^[i] > 0.5;
                        1: tau:=U[j+1].arr^[i];
                      end;

                   if flag or (tau <= 0.0) then
                     Y[0].arr^[i]:=x
                   else
                     Y[0].arr^[i]:=(AX[i]-x)*exp(-(at-AX[i+Y0.Count])/tau)+x;
                end;
  end;
end;

function       TAnalAperiodika.RestartLoad;
 var i: integer;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Если блок - аналитическая апериодика, то делаем сдвиг времени для второй половины AX
  if fNeedShiftAxs then
    for i:=0 to Y0.Count-1 do
      AX[i+Y0.Count]:=AX[i+Y0.Count] - TimeShift;
end;

function       TAnalAperiodika.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'state_') then begin
      Result:=11;
      DataType:=dtDoubleArray
   end
  end;
end;

function       TAnalAperiodika.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtDoubleArray then begin
          TExtArray(DestData).Count:=Y[0].Count;
          for I := 0 to TIntArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=ax[i];
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

function       TAnalAperiodika.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,j: integer;
     flag: boolean;
     tau: double;
     x_: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: x^[0]:=ModelODEVars.Step;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  begin
                      for i:=0 to Y0.Count-1 do begin
                        x_:=k.arr^[i]*U[0].arr^[i];
                        tau:=T.arr^[i];
                        flag:=false;

                        //Обрабатываем дополнительные входы
                        with Inputs do
                         for j:=0 to Length(Selection) - 1 do
                           case selection[j] of
                             0: flag:=U[j+1].arr^[i] > 0.5;
                             1: tau:=U[j+1].arr^[i];
                          end;

                        //Возврат дискретных состояний
                        //N + 1
                        if flag or (tau <= 0.0) then
                          fx^[i]:=AX[i]
                        else
                          fx^[i]:=(AX[i]-x_)*exp(-ModelODEVars.Step/tau) + x_;
                        //N
                        x^[i]:=AX[i];
                      end;

                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


{*******************************************************************************
                     Дискретная апериодика
*******************************************************************************}
constructor    TDisAperiodika.Create;
begin
  inherited;
  fNeedShiftAxs:=False;
end;

function   TDisAperiodika.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j      : Integer;
    u_,tau   : RealType;
    flag     : Boolean;
begin
  Result:=0;
  case Action of
  f_InitObjects: begin
                   SetLength(ax,y0.Count);
                   if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
                 end;
  f_InitState:  if not NeedRemoteData then
                for i:=0 to Y0.Count-1 do begin
                  if IniFlag = 0 then
                    Y[0].arr^[i]:=Y0.arr^[i]
                  else
                    Y[0].arr^[i]:=U[0].arr^[i]*k.arr^[i];
                  AX[i]:=Y[0].arr^[i]
                end;
  f_SetState   :if not NeedRemoteData then
                  for i:=0 to Y0.Count-1 do AX[i]:=Y[0].arr^[i];
  f_RestoreOuts:if not NeedRemoteData then
                  for i:=0 to Y0.Count-1 do Y[0].arr^[i]:=AX[i];
  f_UpdateJacoby,                
  f_UpdateOuts,
  f_GoodStep: if not NeedRemoteData then
               for i:=0 to Y0.Count-1 do begin
                 u_:=U[0].arr^[i]*k.arr^[i];
                 tau:=T.arr^[i];
                 flag:=false;

                 with Inputs do
                  for j:=0 to Length(Selection) - 1 do
                   case selection[j] of
                    0: flag:=U[j+1].arr^[i] > 0.5;
                    1: tau:=U[j+1].arr^[i];
                   end;

                 if flag then
                   Y[0].arr^[i]:=u_
                 else
                   Y[0].arr^[i]:=(h*u_+tau*AX[i])/(h+tau);

                end;
  end;
end;

function       TDisAperiodika.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i,j: integer;
     flag: boolean;
     tau: double;
     x_: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: x^[0]:=ModelODEVars.Step;
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  begin
                      for i:=0 to Y0.Count-1 do begin
                        x_:=k.arr^[i]*U[0].arr^[i];
                        tau:=T.arr^[i];
                        flag:=false;

                        //Обрабатываем дополнительные входы
                        with Inputs do
                         for j:=0 to Length(Selection) - 1 do
                           case selection[j] of
                             0: flag:=U[j+1].arr^[i] > 0.5;
                             1: tau:=U[j+1].arr^[i];
                          end;

                        //Возврат дискретных состояний
                        //Состояние N + 1
                        if flag or (tau <= 0.0) then
                          fx^[i]:=AX[i]
                        else
                          fx^[i]:=(ModelODEVars.Step*x_+tau*AX[i])/(ModelODEVars.Step+tau);

                        //Состояние N
                        x^[i]:=AX[i];
                      end;

                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;

{*******************************************************************************
                        Дискретный ПИД-регулятор
*******************************************************************************}
constructor TDisIntegrator.Create(Owner: TObject);
begin
  inherited;
  Ki   := TExtArray.Create(1);
end;

function    TDisIntegrator.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(ki);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'reset_port') then begin
      Result:=NativeInt(@reset_port);
      DataType:=dtBool;
    end
  end
end;

function   TDisIntegrator.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var
     j : Integer;
     ki_tmp: double;
     tau_tmp: double;

  label
     precise_step;

begin
  Result:=0;
  case Action of
  f_InitObjects:    begin
                      SetLength(ax,  Y[0].Count);
                      SetLength(time,Y[0].Count);
                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
  f_InitState     : if not NeedRemoteData then begin
                      for j:=0 to Y[0].Count - 1 do begin
                        tau.TryGet(j,tau_tmp);
                        Y0.TryGet(j, AX[j]);
                        Y[0].arr^[j]:=AX[j];
                        time[j]:=at+tau_tmp;
                      end;
                      goto precise_step;
                    end;
  f_GoodStep,
  f_RestoreOuts,
  f_UpdateJacoby  : if not NeedRemoteData then
                     for j:=0 to Y[0].Count - 1 do
                        Y[0].arr^[j]:=AX[j];
  f_SetState     :  if not NeedRemoteData then begin
                       for j:=0 to Y[0].Count - 1 do begin
                         Ki.TryGet(j,ki_tmp);
                         tau.TryGet(j,tau_tmp);
                         if time[j]-at <= 0.5*h then begin
                           if reset_port and (U[1][j] > 0.5) then
                             AX[j]:=U[2][j]
                           else
                             AX[j]:=AX[j] + tau_tmp*ki_tmp*U[0].arr^[j];
                           time[j]:=time[j]+tau_tmp;
                         end;
                       end;
                       goto precise_step;
                    end;
  f_UpdateOuts:     if not NeedRemoteData then begin
                       precise_step:
                       for j:=0 to Y[0].Count - 1 do begin
                         tau.TryGet(j,tau_tmp);
                         if ModelODEVars.fPreciseSrcStep and (tau_tmp > 0) then begin
                            ModelODEVars.fsetstep:=True;
                            ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time[j] - at,0)),tau_tmp);
                         end;
                       end;
                    end;
  end;
end;

function       TDisIntegrator.GetDisData(Index,Action: NativeInt;x,fx: PExtArr):NativeInt;
 var i: integer;
     ki_tmp,tau_tmp: double;
begin
  Result:=0;
  case Action of
     //Время задержки при задержке на шаг = текущему шагу интегрирования !
     //Хотя по идее можно его приравнять нулю.
     f_GetDelayTime: if Index < tau.Count then x^[0]:=tau[Index] else x^[0]:=tau[tau.Count - 1];
     //Получение возмущения дискретной переменной состояния и дискретной производной по возмущению входа
     f_GetDisState:  for i:=0 to Y[0].Count - 1 do begin
                       Ki.TryGet(i,ki_tmp);
                       tau.TryGet(i,tau_tmp);
                       if reset_port and (U[1][i] > 0.5) then
                         fx^[i]:=U[2][i]
                       else
                         fx^[i]:=AX[i]+ki_tmp*tau_tmp*U[0].arr^[i];
                       x^[i]:=AX[i];
                     end;
     //Передача возмущения дискретной переменной внутрь блока, для обновления выходов блока по f_UpdateJacoby
     f_SetDisState:  begin
                       AX[Index]:=x^[0];
                     end;
  end;
end;


  //Фильтр хорошего шага интегрирования
function    TGoodStepValue.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:      cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TGoodStepValue.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i: integer;
 label precise_step;
begin
  Result:=0;
  case Action of
   f_InitState,
   f_RestoreOuts,
   f_GoodStep:         begin
                         Move(U[0].arr^[0], Y[0].arr^[0], Y[0].Count*SizeOfDouble );
                       end;
  end;
end;

end.
