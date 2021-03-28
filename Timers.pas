
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Timers;

 //***************************************************************************//
 //                          Функции формирования таймеров                    //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, Logs,mbty_std_consts;

type
 //************БЛОКИ МВТУ без изменения
 //   Временная задержка логической ИСТИНЫ
 //   На выходе - ИСТИНА, если поступающий на вход сигнал - ИСТИНА в течение
 //   не менее заданного промежутка времени
 TTimeCheck = class(TCustomLog)
 protected
   flag :         array of boolean;
   t    :         TExtArray;
   c_time:        double;
 public
   inp     :      RealType;
   tau     :      TExtArray;
   faction :      NativeInt;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;

   //Это надо, чтобы получить доступ к н.у. из кодогенератора и не пересчитывать их там !!!
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
 end;

 //   Одновибратор
 TOneImpulse = class(TTimeCheck)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
 end;

//************БЛОКИ ТПТС

 //   Временная задержка по включению
 TTimeAccept_On = class(TCustomLog)
 protected
   timer:         array of boolean;
   t    :         TExtArray;
 public
   LoopResolve:   boolean;
   tau     :      TExtArray;
   addport :      NativeInt;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;

   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;

   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

 //   Временная задержка по выключению
 TTimeAccept_Of = class(TTimeAccept_On)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //   Временная задержка по включению и выключению
 TTimeAccept_OnOf = class(TTimeAccept_On)
 protected
   timerof:       array of boolean;
   tof    :       TExtArray;
 public
   tauof     :    TExtArray;
   constructor    Create(Owner: TObject);override;
   destructor     Destroy;override;
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;

   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;

   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

 //   Импульс заданной длительности
 TImpulse = class(TTimeAccept_On)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //   Импульс длительностью не более заданной
 TImpulse_R = class(TImpulse)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //   Импульс c пролонгированием, если входной сигнал - истина
 TImpulse_L = class(TImpulse)
 protected
   trigger:       array of boolean;
 public
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;


 //   Формирование импульса по фронту
 TOneImpulse_on = class(TCustomLog)
 protected
   trigger: array of boolean;
   cnt    : Integer;
 public
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
   function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
 end;

 //   Формирование импульса по срезу
 TOneImpulse_of = class(TOneImpulse_on)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //   Формирование импульса по срезу или фронту
 TOneImpulse_onof = class(TOneImpulse_on)
 public
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

implementation
{*******************************************************************************
                        Временное подтверждение
*******************************************************************************}
constructor TTimeCheck.Create;
begin
  inherited;
  Tau:=TExtArray.Create(1);
  t:=TExtArray.Create(1);
end;

destructor  TTimeCheck.Destroy;
begin
  inherited;
  Tau.Free;
  t.Free;
end;

function    TTimeCheck.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'faction') then begin
      Result:=NativeInt(@faction);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'inp') then begin
      Result:=NativeInt(@inp);
      DataType:=dtDouble;
    end;
  end
end;

function    TTimeCheck.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount     : begin
                       CU.arr^[0]:=tau.Count;
                       CY.arr^[0]:=tau.Count
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TTimeCheck.GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetOutParamID(ParamName, DataType, IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'flagstate_') then begin
      Result:=11;
      DataType:=dtIntArray
    end
    else
    if StrEqu(ParamName,'tstate_') then begin
      Result:=12;
      DataType:=dtDoubleArray
    end
  end;
end;

function       TTimeCheck.ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;
 var i: integer;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
  case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=Length(flag);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=byte(flag[i]);
          Result:=True;
        end;
    //Массив состояний таймеров
    12: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=t.Count;
         for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=c_time - t.Arr^[i];
         Result:=True;
       end;
  end;
end;

function   TTimeCheck.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j : Integer;
    true_val,false_val:double;
    t_: double;
    flag_: boolean;

 procedure SetOutVals;
 begin
  if inv_out then begin
    true_val:=Self.false_val;
    false_val:=Self.true_val;
  end
  else begin
    true_val:=Self.true_val;
    false_val:=Self.false_val;
  end;
 end;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(flag,tau.Count);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;

                    end;
    f_InitState:    if not NeedRemoteData then begin
                      SetOutVals;
                      c_time:=at;
                      for j:=0 to tau.Count-1 do begin
                       t.Arr^[j]:=0;
                       flag[j]:=False;
                       Y[0].arr^[j]:=false_val;
     		               if (U[0].arr^[j] >= inp) then begin
                         flag[j]:=True;
                         t.Arr^[j]:=at - tau.arr^[j];
                         Y[0].arr^[j]:=true_val;
                         //Уточнение шага интегрирования
                         if ModelODEVars.fPreciseSrcStep then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - 0.5*ModelODEVars.Hmin ));
                         end;
                       end
                       else
                       case faction of
                         1,2: t.Arr^[j]:=at - tau.arr^[j];
                       end;

                     //Уточнение шага интегрирования
                     if ModelODEVars.fPreciseSrcStep and (at - t_ >= 0) and (at - t_ < tau.arr^[j]) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - (at - t_) - 0.5*ModelODEVars.Hmin ));
                     end;
                     end;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if not NeedRemoteData then begin

                  SetOutVals;
                  for j:=0 to U[0].Count-1 do begin

                   t_:=t.Arr^[j];
                   flag_:=flag[j];

                   if (U[0].arr^[j] >= inp) then begin
                     if not flag_ then begin
                       t_:=at;
                       flag_:=True
                     end;
                     if flag_ then
                       case faction of
                        1   : Y[0].arr^[j]:=true_val;
                        0,2 : if (at-t_) >= tau.arr^[j] then
                                Y[0].arr^[j]:=true_val
                              else
                                Y[0].arr^[j]:=false_val;
                       end;

                   end
                   else begin
                       if flag_ then begin
                         t_:=at;
                         flag_:=False;
                       end;
                       if not flag_ then
                          case faction of
                          0   : Y[0].arr^[j]:=false_val;
                          1,2 : if (at-t_) >= tau.arr^[j] then
                                  Y[0].arr^[j]:=false_val
                                else
                                  Y[0].arr^[j]:=true_val;
                          end;
                     end;

                     //Уточнение шага интегрирования
                     if ModelODEVars.fPreciseSrcStep and (at - t_ >= 0) and (at - t_ < tau.arr^[j]) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - (at - t_) - 0.5*ModelODEVars.Hmin));
                     end;

                     //Запоминание состояния
                     if Action = f_GoodStep then begin
                       c_time:=at;
                       t.Arr^[j]:=t_;
                       flag[j]:=flag_;
                     end;

                   end;
                 end;
  end
end;

procedure  TTimeCheck.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(tau.Count,SizeOfInt);
  Stream.Write(flag[0],SizeOf(Boolean)*tau.Count);
  Stream.Write(t.Arr^,SizeOfDouble*tau.Count);
end;

function   TTimeCheck.RestartLoad;
 var c,i: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOfInt);

      spos:=Stream.Position;
      Stream.Read(flag[0],SizeOf(Boolean)*min(c,Length(flag)));
      Stream.Position:=spos + c*SizeOf(Boolean);

      spos:=Stream.Position;
      Stream.Read(t.Arr^,SizeOfDouble*min(c,t.Count));
      Stream.Position:=spos + c*SizeOfDouble;

      for i:=0 to min(t.Count,c) - 1 do t.Arr^[i]:=t.Arr^[i] - TimeShift;
    finally
    end
end;
  //************* Одновибратор **********************************************//
function   TOneImpulse.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j  :      Integer;
    fl,rslt: boolean;
label
    Calc;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(flag,tau.Count);
                      for j:=0 to tau.Count-1 do flag[j]:=False;

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;
                    end;
    f_InitState:    if not NeedRemoteData then begin
                      for j:=0 to tau.Count-1 do begin
                        flag[j]:=False;  //Начальное состояние
                        t.Arr^[j]:=at-tau[j]; //А это чтобы одновибратор не срабатывал сразу
                      end;
                      goto Calc;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if not NeedRemoteData then begin

Calc:                 //Расчёт состояния блока
                      for j:=0 to U[0].Count-1 do begin
                        fl:=(U[0].Arr^[j] >= inp);

                        //Определение срабатывания одновибратора
                        if at - t.Arr^[j] >= tau.Arr^[j] then begin
                          rslt:=fl and not flag[j];  //st = True - есть срабатывание
                          if rslt and (Action = f_GoodStep) then t.Arr^[j]:=at;
                        end
                        else begin
                          rslt:=true;
                        end;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and rslt then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - (at - t.Arr^[j]) - 0.5*ModelODEVars.Hmin ));
                        end;

                        //Выбор выходного значения
                        if inv_out then rslt:=not rslt;
                        if rslt then
                          Y[0].Arr^[j]:=true_val
                        else
                          Y[0].Arr^[j]:=false_val;

                        if Action = f_GoodStep then begin
                          flag[j]:=fl;
                          c_time:=at;
                        end;
                      end;
                 end;
  end
end;

function       TOneImpulse.ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;
 var i: integer;
begin
  case ID of
    //Массив состояний таймеров со скручиванием в обратную сторону
    12: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=t.Count;
         for I := 0 to TExtArray(DestData).Count - 1 do
            TExtArray(DestData).Arr^[i]:=Max(tau.Arr^[i] - (c_time - t.Arr^[i]),0);
         Result:=True;
         exit;
       end;
  else
    Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  end;
end;


{*******************************************************************************
                    Временная задержка по включению
*******************************************************************************}
constructor TTimeAccept_On.Create;
begin
  inherited;
  Tau:=TExtArray.Create(1);
  t:=TExtArray.Create(1);
  LoopResolve:=False;
end;

destructor  TTimeAccept_On.Destroy;
begin
  inherited;
  Tau.Free;
  t.Free;
end;

function    TTimeAccept_On.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'addport') then begin
      Result:=NativeInt(@addport);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'loopresolve') then begin
      Result:=NativeInt(@LoopResolve);
      DataType:=dtBool;
    end
  end
end;

function       TTimeAccept_On.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   DataType:=dtDoubleArray;
   if StrEqu(ParamName,'_tn') then begin
      Result:=11;
   end
   else
   if StrEqu(ParamName,'_dt') then begin
      Result:=12;
   end
   else
   if StrEqu(ParamName,'timerstate_') then begin
      Result:=15;
      DataType:=dtIntArray
   end
  end;
end;


function       TTimeAccept_On.ReadParam;
 var i: integer;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив времен подтверждения
    11: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=tau.count;
         if tau.Count > 0 then
           Move(tau.arr^,TExtArray(DestData).Arr^[0],Tau.Count*SizeOfDouble);
         Result:=True;
       end;
    //Читаем массив времен, оставшихся до срабатывания таймера
    12: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=Tau.Count;
         if (Tau.Count > 0) and (t.Count = Tau.Count) then
            Move(t.Arr^,TExtArray(DestData).Arr^[0],Tau.Count*SizeOfDouble);
         Result:=True;
       end;
    //Массив флагов срабатывания
    15: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=Length(timer);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=byte(timer[i]);
          Result:=True;
        end;
  end;
end;


function    TTimeAccept_On.InfoFunc;
var i : Integer;
begin
  Result:=0;
  case Action of
    i_GetCount     : begin
                       for i:=0 to CU.count-1 do CU.arr^[i]:=tau.Count;
                       CY.arr^[0]:=tau.Count;
                       if CY.Count > 1 then CY.arr^[1]:=CY.arr^[0];
                     end;
    i_GetInit      : Result:=byte(LoopResolve) and 1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTimeAccept_On.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j         : Integer;
    tn        : double;
    b01       : Boolean;
    timer_    : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       t.Arr^[j]:=0
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          if cY.Count > 1 then
                            RemoteDataUnit.AddVectorToList(GetPortName(1),Y[1]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                        end;

                    end;
    f_InitState:    if not NeedRemoteData then begin
                      for j:=0 to tau.Count-1 do begin
                       Y[0].arr^[j]:=false_val;

                       if LoopResolve then
                         b01:=False
                       else
                         b01:=(U[0].arr^[j] >= T_in);

                       if u_inv[0] then b01:=not b01;//Инверсия входа

                       if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j];
                       if b01 then begin     //Установка таймера
                         timer[j]:=True;
                         t.Arr^[j]:=tau.arr^[j];
                       end;

                       //Вывод времени на выходе
                       if cY.Count > 1 then Y[1].Arr^[j]:=tau.arr^[j] - t.Arr^[j];

                       //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                       if ModelODEVars.fPreciseSrcStep and timer[j] then begin
                         ModelODEVars.fsetstep:=True;
                         ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - 0.5*ModelODEVars.Hmin));
                       end;

                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
                      for j:=0 to U[0].Count-1 do begin

                        timer_:=timer[j];

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j];

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        if not b01 then begin                     //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if (not timer_) and b01 then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        if b01 and (tn <= 0.0) then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Вывод текущего значени таймера на второй выход
                        if cY.Count > 1 then Y[1].Arr^[j]:=tau.arr^[j] - tn;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        //Инкрементация
                        if Action = f_GoodStep then begin
                          t.Arr^[j]:=tn;
                          timer[j]:=timer_;
                        end;
                      end;
                 end;
  end
end;

procedure  TTimeAccept_On.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(tau.Count,SizeOfInt);
  Stream.Write(timer[0],SizeOf(Boolean)*tau.Count);
  Stream.Write(t.Arr^,SizeOfDouble*tau.Count);
end;

function   TTimeAccept_On.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOfInt);

      spos:=Stream.Position;
      Stream.Read(timer[0],SizeOf(Boolean)*min(c,Length(timer)));
      Stream.Position:=spos + c*SizeOf(Boolean);

      spos:=Stream.Position;
      Stream.Read(t.Arr^,SizeOfDouble*min(c,t.Count));
      Stream.Position:=spos + c*SizeOfDouble;

    finally
    end
end;
{*******************************************************************************
                     Временная задержка по выключению
*******************************************************************************}
function   TTimeAccept_Of.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j         : Integer;
    tn        : double;
    b01       : Boolean;
    timer_    : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       t.Arr^[j]:=0;
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          if cY.Count > 1 then
                            RemoteDataUnit.AddVectorToList(GetPortName(1),Y[1]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                        end;

                    end;
    f_InitState:    if not NeedRemoteData then begin
                      for j:=0 to tau.Count-1 do begin

                       if LoopResolve then
                         b01:=False                    //При развязке петли для этого блока его состояние = False !!!
                       else
                         b01:=(U[0].arr^[j] >= T_in);

                       if u_inv[0] then b01:=not b01;  //Инверсия входа
                       if b01 then begin
                         Y[0].arr^[j]:=true_val;
                         timer[j]:=False;
                       end else begin
                         Y[0].arr^[j]:=false_val;
                         timer[j]:=true
                       end;
                       //Вывод времени на выходе
                       if cY.Count > 1 then Y[1].Arr^[j]:=tau.arr^[j] - t.Arr^[j];

                       //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                       if ModelODEVars.fPreciseSrcStep and timer[j] then begin
                         ModelODEVars.fsetstep:=True;
                         ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - 0.5*ModelODEVars.Hmin));
                       end;

                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
                      for j:=0 to U[0].Count-1 do begin

                        timer_:=timer[j];

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j]; //Если длительность - через порт

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        b01:=(U[0].arr^[j] >= T_in);        //Признак истины для входа
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        if b01 then begin                   //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if (not timer_) and (not b01) then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        if b01 or (tn > 0.0) then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Вывод текущего значени таймера на второй выход
                        if cY.Count > 1 then Y[1].Arr^[j]:=tau.arr^[j] - tn;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        if Action = f_GoodStep then begin
                          t.Arr^[j]:=tn;
                          timer[j]:=timer_;
                        end;
                      end;

                 end;
end;
end;
{*******************************************************************************
                     Временная задержка по включению и выключению
*******************************************************************************}
constructor TTimeAccept_OnOf.Create;
begin
  inherited;
  TauOf:=TExtArray.Create(1);
  tof:=TExtArray.Create(1);
end;

destructor  TTimeAccept_OnOf.Destroy;
begin
  inherited;
  TauOf.Free;
  tof.Free;
end;

function    TTimeAccept_OnOf.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'tau_on') then begin
      Result:=NativeInt(tau);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'tau_of') then begin
      Result:=NativeInt(tauof);
      DataType:=dtDoubleArray;
      exit;
    end;
  end
end;

function       TTimeAccept_OnOf.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   DataType:=dtDoubleArray;
   if StrEqu(ParamName,'_tn_on') then begin
      Result:=11;
   end
   else
   if StrEqu(ParamName,'_dt_on') then begin
      Result:=12;
   end
   else
   if StrEqu(ParamName,'_tn_of') then begin
      Result:=13;
   end
   else
   if StrEqu(ParamName,'_dt_of') then begin
      Result:=14;
   end
   else
   if StrEqu(ParamName,'timerofstate_') then begin
      Result:=16;
      DataType:=dtIntArray
   end
  end;
end;


function       TTimeAccept_OnOf.ReadParam;
 var i: integer;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив времен подтверждения
    11: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=tau.count;
         if tau.Count > 0 then
           Move(tau.arr^,TExtArray(DestData).Arr^[0],Tau.Count*SizeOfDouble);
         Result:=True;
       end;
    //Читаем массив времен, оставшихся до срабатывания таймера
    12: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=Tau.Count;
         if (Tau.Count > 0) and (t.Count = Tau.Count) then
           Move(t.Arr^,TExtArray(DestData).Arr^[0],Tau.Count*SizeOfDouble);
         Result:=True;
       end;
    //Читаем массив времен подтверждения
    13: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=tauof.count;
         if tauof.Count > 0 then Move(tauof.arr^,TExtArray(DestData).Arr^[0],Tauof.Count*SizeOfDouble);
         Result:=True;
       end;
    //Читаем массив времен, оставшихся до срабатывания таймера
    14: if DestDataType = dtDoubleArray then begin
         TExtArray(DestData).Count:=Tauof.Count;
         if (Tauof.Count > 0) and (tof.Count = Tauof.Count) then
           Move(tof.Arr^,TExtArray(DestData).Arr^[0],Tauof.Count*SizeOfDouble);
         Result:=True;
       end;
    //Массив флагов срабатывания
    16: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=Length(timerof);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=byte(timerof[i]);
          Result:=True;
        end;
  end;
end;

procedure  TTimeAccept_OnOf.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(tauof.Count,SizeOfInt);
  Stream.Write(timerof[0],SizeOf(Boolean)*tauof.Count);
  Stream.Write(tof.Arr^,SizeOfDouble*tauof.Count);
end;

function   TTimeAccept_OnOf.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOfInt);

      spos:=Stream.Position;
      Stream.Read(timerof[0],SizeOf(Boolean)*min(c,Length(timerof)));
      Stream.Position:=spos + c*SizeOf(Boolean);

      spos:=Stream.Position;
      Stream.Read(tof.Arr^,SizeOfDouble*min(c,tof.Count));
      Stream.Position:=spos + c*SizeOfDouble;

    finally
    end
end;

function    TTimeAccept_OnOf.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr   : begin
                      if tau.count <> tauof.count then begin
                        ErrorEvent(txtTimeAcceptErr,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                     end;
    i_GetCount     : begin
                       for i:=0 to CU.count-1 do CU.arr^[i]:=tau.Count;
                       CY.arr^[0]:=tau.Count
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTimeAccept_OnOf.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j         : Integer;
    tn        : double;
    b01,b02   : Boolean;
    timer_    : boolean;
    timerof_  : boolean;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      tof.Count:=tau.Count;
                      SetLength(timerof,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       timerof[j]:=False;
                       t.Arr^[j]:=0;
                       tof.Arr^[j]:=0;
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tof',tof);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tauof',tauof);
                        end;

                    end;
    f_InitState:    if not NeedRemoteData then begin
                      for j:=0 to tau.Count-1 do begin
                        //В н.п. выход = 0 !!!
                        Y[0].arr^[j]:=false_val;
                        timerof[j]:=True;

                        if LoopResolve then
                          b01:=False
                        else
                          b01:=(U[0].arr^[j] >= T_in);

                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j];
                        if b01 then begin     //Установка таймера
                          timer[j]:=True;
                          t.Arr^[j]:=tau.arr^[j];
                        end;

                       //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                       if ModelODEVars.fPreciseSrcStep and timer[j] then begin
                         ModelODEVars.fsetstep:=True;
                         ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tau.arr^[j] - 0.5*ModelODEVars.Hmin));
                       end;

                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
                      for j:=0 to U[0].Count-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);                     //Признак истины для входа
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        timer_:=timer[j];
                        timerof_:=timerof[j];

//*********************Задержка по включению******************************

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j]; //Если длительность - через порт

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        if not b01 then begin                     //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if (not timer_) and b01 then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        b02:= b01 and (tn <= 0.0);
                        if Action = f_GoodStep then t.Arr^[j]:=tn;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

//*********************Задержка по выключению******************************
                        if cU.Count > 2 then tauof.arr^[j]:=U[2].arr^[j]; //Если длительность - через порт

                        if timerof_ then
                          tn:=tof.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tauof.arr^[j] then tn:=tauof.arr^[j];

                        if b02 then begin                   //Сброс таймера
                         timerof_:=False;
                         tn:=0;
                        end;

                        if (not timerof_) and (not b02) then begin     //Установка таймера
                         timerof_:=True;
                         tn:=tauof.arr^[j];
                        end;

                        if Action = f_GoodStep then tof.Arr^[j]:=tn;
//*********************Формирование выхода******************************

                        if b02 or (tn > 0.0) then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        if Action = f_GoodStep then begin
                          timer[j]:=timer_;
                          timerof[j]:=timerof_;
                        end;
                      end;

                 end;
  end
end;

  //************* Импульс заданной длительности**********************************************//
function   TImpulse.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      :      Integer;
    tn     : Double;
    b01    : Boolean;
    timer_ : boolean;
label
    Calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       t.Arr^[j]:=0
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                        end;
                    end;
    f_InitState:    if not NeedRemoteData then begin
                      goto calc;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if not NeedRemoteData then begin
Calc:
                      for j:=0 to U[0].Count-1 do begin

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j]; //Если длительность - через порт

                        timer_:=timer[j];

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        b01:=(U[0].arr^[j] >= T_in);        //Признак истины для входа
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        if (not b01)and(tn <= 0.0) then begin                   //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if (not timer_) and (b01) then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        if tn > 0.0 then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        if (Action = f_GoodStep) or (Action = f_InitState) then begin
                          t.Arr^[j]:=tn;
                          timer[j]:=timer_;
                        end;
                      end;
                    end;
  end
end;

  //************* Импульс длительности не более заданной **********************************************//
function   TImpulse_R.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      : Integer;
    tn     : Double;
    b01    : Boolean;
    timer_ : boolean;
label
    Calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       t.Arr^[j]:=0
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                        end;
                    end;
    f_InitState:    if not NeedRemoteData then begin
                      goto calc;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if not NeedRemoteData then begin
Calc:
                      for j:=0 to U[0].Count-1 do begin

                        timer_:=timer[j];

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j]; //Если длительность - через порт

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        b01:=(U[0].arr^[j] >= T_in);        //Признак истины для входа
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        if (not b01) then begin                   //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if (not timer_) and (b01) then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        if tn > 0.0 then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        if (Action = f_GoodStep)or(Action = f_InitState) then begin
                          t.Arr^[j]:=tn;
                          timer[j]:=timer_;
                        end;
                      end;
                    end;
  end
end;

  //************* Импульс c пролонгированием, если входной сигнал - истина **********************************************//
function   TImpulse_L.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      : Integer;
    tn     : Double;
    b0,b01 : Boolean;
    timer_ : boolean;
    trigger_:boolean;
label
    Calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      t.Count:=tau.Count;
                      SetLength(timer,tau.Count);
                      SetLength(trigger,tau.Count);
                      for j:=0 to tau.Count-1 do begin
                       timer[j]:=False;
                       trigger[j]:=false;
                       t.Arr^[j]:=0
                      end;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_t',t);
                          RemoteDataUnit.AddVectorToList(RemoteDataUnit.prefix+GetUnikName+'_tau',tau);
                        end;
                    end;
    f_InitState:    if not NeedRemoteData then begin
                      goto calc;
                    end;
    f_GoodStep,
    f_UpdateOuts:   if not NeedRemoteData then begin
Calc:
                      for j:=0 to U[0].Count-1 do begin

                        timer_:=timer[j];
                        trigger_:=trigger[j];

                        if cU.Count > 1 then tau.arr^[j]:=U[1].arr^[j]; //Если длительность - через порт

                        if timer_ then
                          tn:=t.Arr^[j] - h     //Скрутка таймера
                        else
                          tn:=0.0;         //Если таймер не идёт - то и не скручиваем его !!!

                        //Ограничение таймера
                        if tn < 0.0 then tn:=0.0 else
                        if tn > tau.arr^[j] then tn:=tau.arr^[j];

                        b01:=(U[0].arr^[j] >= T_in);        //Признак истины для входа
                        if u_inv[0] then b01:=not b01;//Инверсия входа

                        b0:=tn > 0.0;                           //Признак работы таймера

                        if (not b01) then trigger_:=false;
                        if b01 and b0 then
                         if not trigger_ then begin
                           trigger_:=true;
                           timer_:=false;
                         end;

                        if (not b01) and (not b0) then begin                   //Сброс таймера
                         timer_:=False;
                         tn:=0;
                        end;

                        if b01 and (not timer_) then begin     //Установка таймера
                         timer_:=True;
                         tn:=tau.arr^[j];
                        end;

                        if (tn > 0.0) then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        //Уточнение шага интегрирования (чтобы шаг не превышал длительности импульса)
                        if ModelODEVars.fPreciseSrcStep and (tn > 0) then begin
                           ModelODEVars.fsetstep:=True;
                           ModelODEVars.newstep:=min(ModelODEVars.newstep,max(0,tn - 0.5*ModelODEVars.Hmin));
                        end;

                        if (Action = f_GoodStep) or (Action = f_InitState) then begin
                          t.Arr^[j]:=tn;
                          timer[j]:=timer_;
                          trigger[j]:=trigger_;
                        end;
                      end;
                    end;
  end
end;

function       TImpulse_L.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'triggerstate_') then begin
      Result:=17;
      DataType:=dtIntArray
   end
  end;
end;

function       TImpulse_L.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    17: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=Length(trigger);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=byte(trigger[i]);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

{*******************************************************************************
              Формирование импульса по фронту
*******************************************************************************}

function    TOneImpulse_On.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount     : begin
                       cnt:=CU.arr^[0];
                       CY.arr^[0]:=CU.arr^[0]
                     end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

procedure  TOneImpulse_On.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(cnt,SizeOfInt);
  Stream.Write(trigger[0],SizeOf(Boolean)*cnt);
end;

function   TOneImpulse_On.RestartLoad;
 var c: integer;
     spos: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOfInt);

      spos:=Stream.Position;
      Stream.Read(trigger[0],SizeOf(Boolean)*min(c,Length(trigger)));
      Stream.Position:=spos + SizeOf(Boolean)*c;
    finally
    end
end;


function   TOneImpulse_On.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      : Integer;
    b01    : Boolean;
    fl     : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      SetLength(trigger,cnt);
                      for j:=0 to cnt-1 do trigger[j]:=false;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;

                    end;
    f_InitState : if not NeedRemoteData then begin
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;

                        trigger[j]:=b01;
                        Y[0].arr^[j]:=false_val;
                      end;
                 end;
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;

                        fl:=trigger[j];

                        if not b01 then fl:=False;

                        if b01 and (not fl) then begin
                          Y[0].arr^[j]:=true_val;
                          fl:=true;
                        end
                        else
                          Y[0].arr^[j]:=false_val;

                        if Action = f_GoodStep then trigger[j]:=fl;
                      end;

                 end;
  end
end;

function       TOneImpulse_On.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'triggerstate_') then begin
      Result:=17;
      DataType:=dtIntArray
   end
  end;
end;

function       TOneImpulse_On.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    17: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=Length(trigger);
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=byte(trigger[i]);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

{*******************************************************************************
              Формирование импульса по срезу
*******************************************************************************}

function   TOneImpulse_Of.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      : Integer;
    b01    : Boolean;
    fl     : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      SetLength(trigger,cnt);
                      for j:=0 to cnt-1 do trigger[j]:=false;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;

                    end;
    f_InitState : if not NeedRemoteData then begin
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;
                        trigger[j]:=b01;
                        Y[0].arr^[j]:=false_val;
                      end;
                 end;
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;

                        fl:=trigger[j];

                        if b01 then fl:=True;

                        if (not b01) and (fl) then begin
                          Y[0].arr^[j]:=true_val;
                          fl:=false
                        end
                        else
                          Y[0].arr^[j]:=false_val;

                        if Action = f_GoodStep then trigger[j]:=fl;
                      end;

                 end;
  end
end;
{*******************************************************************************
              Формирование импульса по фронту или срезу
*******************************************************************************}

function   TOneImpulse_OnOf.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var j      : Integer;
    b01    : Boolean;

label calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      SetLength(trigger,cnt);
                      for j:=0 to cnt-1 do trigger[j]:=false;

                      SetTrueFalse(y_inv[0]);

                      if NeedRemoteData then
                        if RemoteDataUnit <> nil then begin
                          RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                        end;

                    end;
    f_InitState : if not NeedRemoteData then begin
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;
                        trigger[j]:=b01
                      end;
                      goto calc
                 end;
    f_UpdateOuts,
    f_GoodStep : if not NeedRemoteData then begin
calc:
                      for j:=0 to cnt-1 do begin
                        b01:=(U[0].arr^[j] >= T_in);
                        if u_inv[0] then b01:=not b01;

                        if b01 <> trigger[j] then
                          Y[0].arr^[j]:=true_val
                        else
                          Y[0].arr^[j]:=false_val;

                        if Action = f_GoodStep then trigger[j]:=b01;
                      end;

                 end;
  end
end;

end.
