
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Trigger;

 //***************************************************************************//
 //                          Запоминающие элементы
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts,Logs;

type


 //RS-триггер с приоритетом по сбросу, с изменяемыми н.у.
 //анахронизм от МВТУ-2
 TVarTrigger = class(TCustomLog)
 protected
   N:              integer;
   ax:             array of double;
 public
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   procedure       RestartSave(Stream: TStream);override;
   function        RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

 //RS-триггер с приоритетом по сбросу
 TTrigger_R = class(TVarTrigger)
 public
   y0:             TExtArray;
   r_prior :       Boolean;  //Признак приоритета по сбросу (true) или установке (false)
   constructor     Create(Owner: TObject);override;
   destructor      Destroy;override;
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //RS-триггер с приоритетом по установке
 TTrigger_S = class(TTrigger_R)
 public
   constructor     Create(Owner: TObject);override;
 end;

 //Триггер со счётным входом
 TTrigger_T = class(TTrigger_R)
 public
   clctype:        NativeInt;        //Режим срабатывания счётного входа (0 - по фронту,1 - по спаду, 2 - по фронту и спаду)
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function        GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
 end;

 //Триггер со счётным входом
 TTrigger_TR = class(TTrigger_T)
 public
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //Триггер со счётным входом
 TTrigger_TS = class(TTrigger_TR)
 public
   constructor     Create(Owner: TObject);override;
 end;

 //Определение первого события (RS-мультитриггер)
 TFirstEvent = class(TRunObject)
 public
   RPriority:      boolean;
   N:              integer;
   StateVars:      array of boolean;
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   procedure       RestartSave(Stream: TStream);override;
   function        RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
 end;

 //Триггер со счётным входом
 TTrigger_D = class(TTrigger_R)
 public
   synctype:       NativeInt;        //Режим срабатывания счётного входа (0 - по фронту,1 - по спаду, 2 - по фронту и спаду, 3 - по уровню)
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function        GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
 end;

implementation

{*******************************************************************************
                         Триггер с изменяемыми н.у.
*******************************************************************************}
function       TVarTrigger.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=CU.arr^[0];
                  CU[1]:=CU[0];
                  CU[2]:=CU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TVarTrigger.RunFunc;
var j     : Integer;
    x1,x2 : RealType;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(AX,N);

                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;
                  end;
    f_InitState:  if not NeedRemoteData then begin
                    for j:=0 to N-1 do
                      if U[2].arr^[j] = 0 then begin
                      Y[0].arr^[j]:=false_val;
                      Y[1].arr^[j]:=true_val;
                     end
                     else begin
                      Y[0].arr^[j]:=true_val;
                      Y[1].arr^[j]:=false_val;
                     end;
                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                    if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:     if not NeedRemoteData then begin
                    for j:=0 to N-1 do begin
                     x1:=U[0].arr^[j];
                     x2:=U[1].arr^[j];
                     if (x1 = 0) then begin
                      if x2 = 0 then Y[0].arr^[j]:=AX[j]
                       else Y[0].arr^[j]:=false_val;
                     end
                     else begin
                      if x2 = 0 then Y[0].arr^[j]:=true_val;
                     end;
                     if Y[0].arr^[j] = true_val
                      then Y[1].arr^[j]:=false_val
                       else Y[1].arr^[j]:=true_val;

                     //Запись состояния блока
                     if Action = f_GoodStep then AX[j]:=Y[0].arr^[j];
                    end;
                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                    if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                  end;
  end
end;

procedure  TVarTrigger.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(AX);
  Stream.Write(i,SizeOfInt);
  Stream.Write(AX[0],i*SizeOfDouble);
end;

function   TVarTrigger.RestartLoad;
 var j,c,n: integer;
     Base: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      n:=Length(AX);
      Stream.Read(c,SizeOfInt);
      Base:=Stream.Position;
      j:=min(n,c);
      if j > 0 then Stream.Read(AX[0],j*SizeOfDouble);
      Stream.Position:=Base+c*SizeOfDouble
    finally
    end
end;


{*******************************************************************************
                         RS-триггер с приоритетом по сбросу
*******************************************************************************}
constructor    TTrigger_R.Create;
begin
  inherited;
  r_prior:=true;
  y0:=TExtArray.Create(1);
end;

destructor     TTrigger_R.Destroy;
begin
  inherited;
  y0.Free;
end;

function       TTrigger_R.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function       TTrigger_R.InfoFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  for j:=1 to CU.Count-1 do CU.arr^[j]:=CU.arr^[0];
                  for j:=0 to CY.Count-1 do CY.arr^[j]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TTrigger_R.RunFunc;
var j          : Integer;
    r,s        : boolean;
    y0_v       : double;

label calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(AX,N);
                    SetTrueFalse(y_inv[0]);     //Устанавливаем значения логической единицы и нуля
                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;
                  end;
    f_InitState:  begin
                    if not NeedRemoteData then
                      y0_v:=0;

                      for j:=0 to N-1 do begin
                        Y0.TryGet(j,y0_v);
                        AX[j]:=y0_v;
                      end;

                      goto calc;
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:
calc:             if not NeedRemoteData then begin
                    for j:=0 to N-1 do begin
                     s:=U[0].arr^[j] >= T_in;
                     r:=U[1].arr^[j] >= T_in;

                     //Инверсия входов
                     if u_inv[0] then s:=not s;
                     if u_inv[1] then r:=not r;

                     if s and r then                         // s = 1, r = 1
                       if r_prior then
                        Y[0].arr^[j]:=false_val              // c приоритетом по сбросу
                         else Y[0].arr^[j]:=true_val         // c приоритетом по установке
                     else begin
                       if s and not r then
                         Y[0].arr^[j]:=true_val              // s = 1, r = 0
                       else
                         if not s and r then
                           Y[0].arr^[j]:=false_val           // s = 0, r = 1
                         else
                           Y[0].arr^[j]:=AX[j];              // s = 0, r = 0  - состояние не меняется
                     end;

                     //Инверсный выход
                     if cY.Count > 1 then Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];

                     //Запись состояния блока
                     if Action = f_GoodStep then AX[j]:=Y[0].arr^[j];
                    end;
                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                     if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                end;
  end
end;

//************RS-триггер с приоритетом по установке**********************
constructor    TTrigger_S.Create;
begin
  inherited;
  r_prior:=false;
end;
  //************* Триггер со счётным входом
function       TTrigger_T.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'clctype') then begin
      Result:=NativeInt(@clctype);
      DataType:=dtInteger;
    end;
  end
end;

function       TTrigger_T.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'flags_') then begin
      Result:=11;
      DataType:=dtIntArray
   end
  end;
end;

function       TTrigger_T.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=N;
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=trunc(AX[i + N]);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;


function       TTrigger_T.RunFunc;
var j          : Integer;
    clc,c1     : boolean;
    y0_v       : double;

label calc;


begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(AX,2*N);
                    SetTrueFalse(y_inv[0]);

                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;

                  end;
    f_InitState:  begin
                    if not NeedRemoteData then
                      y0_v:=0;

                      for j:=0 to N-1 do begin
                        Y0.TryGet(j,y0_v);
                        AX[j]:=y0_v;
                        Y[0].Arr^[j]:=AX[j];
                      end;

                      for j:=N to 2*N - 1 do AX[j]:=0;  //Начальное состояние счётного входа = 0
                      goto calc;
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:
calc:             if not NeedRemoteData then begin
                    for j:=0 to N-1 do begin
                     clc:=U[0].Arr^[j] >= T_In;
                     if u_inv[0] then clc:=not clc;
                     c1:=clc;

                     //Срабатывание счётного входа
                     case clctype of
                         0: clc:=clc and (AX[j + N] = 0);     //Срабатывание по фронту
                         1: clc:=not clc and (AX[j + N] > 0); // по спаду
                         2: clc:=clc <> (AX[j + N] > 0);      // по фронту и спаду
                     end;
                     //Обращение состояния триггера при срабатывании счётного входа
                     if clc then Y[0].Arr^[j]:=true_val - AX[j];

                     //Инверсный выход
                     if cY.Count > 1 then Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];

                     //Запись состояния блока
                     if Action = f_GoodStep then begin
                       AX[j]:=Y[0].arr^[j];
                       //Запоминание счётного входа
                       if c1 then AX[j + N]:=1.0 else AX[j + N]:=0.0;
                     end;
                    end;

                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                    if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                  end;
  end
end;

  //************* Триггер со счётным входом, установкой и сбросом (с приоритетом
  //              по сбросу  ********************************//
function       TTrigger_TR.RunFunc;
var j        : Integer;
    r,s,
    clc,c1   : boolean;
    y0_v     : double;

label calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(AX,2*N);
                    SetTrueFalse(y_inv[0]);

                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;

                  end;
    f_InitState:  begin
                    if not NeedRemoteData then
                      y0_v:=0;

                      for j:=0 to N-1 do begin
                       Y0.TryGet(j,y0_v);
                       AX[j]:=y0_v;
                       Y[0].Arr^[j]:=AX[j];
                      end;

                      for j:=N to 2*N - 1 do AX[j]:=0;  //Начальное состояние счётного входа = 0
                      goto calc;
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:
calc:             if not NeedRemoteData then begin
                    for j:=0 to N-1 do begin
                     s:=U[0].arr^[j] >= T_In;
                     clc:=U[1].Arr^[j] >= T_In;
                     r:=U[2].arr^[j] >= T_In;

                     //Инверсия входов
                     if u_inv[0] then s:=not s;
                     if u_inv[1] then clc:=not clc;
                     if u_inv[2] then r:=not r;
                     c1:=clc;


                     if s or r then
                       //Срабатывание R,S - входов
                       if s and r then                       // s = 1, r = 1
                         if r_prior then Y[0].arr^[j]:=false_val
                          else Y[0].arr^[j]:=true_val
                       else begin
                         if s and not r then
                           Y[0].arr^[j]:=true_val           // s = 1, r = 0
                         else
                           if not s and r then
                             Y[0].arr^[j]:=false_val         // s = 0, r = 1
                           else
                             Y[0].arr^[j]:=AX[j];    // s = 0, r = 0  - состояние не меняется
                       end
                     else begin
                       //Срабатывание счётного входа
                       case clctype of
                         0: clc:=clc and (AX[j + N] = 0);     //Срабатывание по фронту
                         1: clc:=not clc and (AX[j + N] > 0); // по спаду
                         2: clc:=clc <> (AX[j + N] > 0);      // по фронту и спаду
                       end;
                       //Обращение состояния триггера при срабатывании счётного входа
                       if clc then Y[0].Arr^[j]:=true_val - AX[j];
                     end;

                     //Инверсный выход
                     if cY.Count > 1 then Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];

                     //Запись состояния блока
                     if Action = f_GoodStep then begin
                       AX[j]:=Y[0].arr^[j];
                       //Запоминание счётного входа
                       if c1 then AX[j + N]:=1.0 else AX[j + N]:=0.0;
                     end;
                    end;

                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                    if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                  end;
  end
end;
  //************* Триггер со счётным входом, установкой и сбросом (с приоритетом
  //              по установке********************************//

constructor    TTrigger_TS.Create;
begin
  inherited;
  r_prior:=false;
end;


//**********  Блок определения первого события (мультитриггер со сбросом) *****
function       TFirstEvent.GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'rpriority') then begin
      Result:=NativeInt(@RPriority);
      DataType:=dtBool;
    end;
  end
end;

function       TFirstEvent.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  for I := 1 to CU.Count - 1 do CU.arr^[i]:=CU.arr^[0];
                  for I := 0 to CY.Count - 1 do CY.arr^[i]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TFirstEvent.RunFunc;
  var j,i,evnt_count: Integer;
      x1,x2 : RealType;
  label calc,
        next_element;
begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(StateVars,N*CY.Count);
                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        for j:=0 to N-1 do
                          RemoteDataUnit.AddVectorToList(GetPortName(j),Y[j]);
                      end;
                  end;
    f_InitState:  if not NeedRemoteData then begin
                    for j:=0 to (N*CY.Count)-1 do StateVars[j]:=False;
                    goto calc;
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:     if not NeedRemoteData then begin
calc:
                    for j:=0 to N-1 do begin
                       //Восстановление выхода на промежуточном шаге расчёта
                       for I := 0 to CY.Count - 1 do Y[i].Arr^[j]:=byte(StateVars[i*N + j]);
                       //Если первый вход = 0 - то сброс всех выходов
                       if (U[0].Arr^[j] > 0.5) xor u_inv[0] then begin
                          for I := 0 to CY.Count - 1 do Y[i].Arr^[j]:=0;
                       end
                       else begin
                         //Если есть не нулевой выход - то запоминания не делаем !!
                         for I := 0 to CY.Count - 1 do
                           if (Y[i].Arr^[j] > 0.5) then goto next_element;

                         //Если же зафиксировано одновременно несколько событий, то ничего не делаем, ибо нефига !!!
                         if RPriority then begin
                            evnt_count:=0;
                            for I := 1 to CU.Count - 1 do
                              if (U[i].Arr^[j] > 0.5) xor u_inv[i] then inc(evnt_count);
                            if evnt_count > 1 then goto next_element;
                         end;

                         //Иначе - делаем запоминание первого события по входам
                         for I := 0 to CY.Count - 1 do
                           Y[i].Arr^[j]:=byte((U[i+1].Arr^[j] > 0.5) xor u_inv[i+1]);
                       end;
                       //Запись состояния блока
                       if Action = f_GoodStep then
                         for I := 0 to CY.Count - 1 do
                           StateVars[i*N + j]:=Y[i].arr^[j] > 0.5;
next_element:
                       for I := 0 to CY.Count - 1 do
                         if y_inv[i] then Y[i].Arr^[j]:=byte(not (Y[i].Arr^[j] > 0.5));

                    end;
                  end
  end
end;

procedure  TFirstEvent.RestartSave(Stream: TStream);
 var i: integer;
begin
  inherited;
  i:=Length(StateVars);
  Stream.Write(i,SizeOfInt);
  Stream.Write(StateVars[0],i*SizeOfBoolean);
end;

function   TFirstEvent.RestartLoad;
 var j,c,n: integer;
     Base: int64;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      n:=Length(StateVars);
      Stream.Read(c,SizeOfInt);
      Base:=Stream.Position;
      j:=min(n,c);
      if j > 0 then Stream.Read(StateVars[0],j*SizeOfBoolean);
      Stream.Position:=Base+c*SizeOfBoolean
    finally
    end
end;


  //************* Синхронный D-триггер
function       TTrigger_D.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'synctype') then begin
      Result:=NativeInt(@synctype);
      DataType:=dtInteger;
    end;
  end
end;

function       TTrigger_D.GetOutParamID;
begin
  Result:=inherited GetOutParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
   if StrEqu(ParamName,'flags_') then begin
      Result:=11;
      DataType:=dtIntArray
   end
  end;
end;

function       TTrigger_D.ReadParam;
 var i: integer;
begin
   case ID of
    //Массив флагов срабатывания
    11: if DestDataType = dtIntArray then begin
          TIntArray(DestData).Count:=N;
          for I := 0 to TIntArray(DestData).Count - 1 do
            TIntArray(DestData).Arr^[i]:=trunc(AX[i + N]);
          Result:=True;
        end;
   else
     Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
   end;
end;

function       TTrigger_D.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var j: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  //Размерность выхода = размерности первого входа, второй может быть произвольной размерности
                  for j:=0 to CY.Count-1 do CY.arr^[j]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TTrigger_D.RunFunc;
var j          : Integer;
    clc,c1     : boolean;
    clc_v      : double;

label calc;

begin
  Result:=0;
  case Action of
    f_InitObjects:begin
                    N:=U[0].Count;
                    SetLength(AX,2*N);
                    SetTrueFalse(y_inv[0]);

                    if NeedRemoteData then
                      if RemoteDataUnit <> nil then begin
                        RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                      end;

                  end;
    f_InitState:  begin
                    if not NeedRemoteData then
                      clc_v:=0;

                      for j:=0 to N-1 do begin
                        Y0.TryGet(j,clc_v);
                        AX[j]:=clc_v;
                        Y[0].Arr^[j]:=AX[j];
                      end;

                      for j:=N to 2*N - 1 do AX[j]:=0;  //Начальное состояние счётного входа = 0
                      goto calc;
                  end;
  f_RestoreOuts,
  f_UpdateOuts,
  f_UpdateJacoby,
  f_GoodStep:
calc:             if not NeedRemoteData then begin
                    clc_v:=0;
                    for j:=0 to N-1 do begin

                     //Получить вход синхронизации
                     U[1].TryGet(j,clc_v);
                     clc:=clc_v >= T_In;
                     if u_inv[1] then clc:=not clc;
                     c1:=clc;

                     //Срабатывание счётного входа
                     case synctype of
                         0: clc:=clc and (AX[j + N] = 0);     //Срабатывание по фронту
                         1: clc:=not clc and (AX[j + N] > 0); // по спаду
                         2: clc:=clc <> (AX[j + N] > 0);      // по фронту и спаду
                     end;

                     //Запоминание состояния триггера при входа синхронизации
                     if clc then Y[0].Arr^[j]:= byte((U[0].Arr^[j] > 0) xor u_inv[0]);

                     //Инверсный выход
                     if cY.Count > 1 then Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];

                     //Запись состояния блока
                     if Action = f_GoodStep then begin
                       AX[j]:=Y[0].arr^[j];
                       //Запоминание счётного входа
                       if c1 then AX[j + N]:=1.0 else AX[j + N]:=0.0;
                     end;
                    end;

                  end
                  else begin
                    //В режиме удалённой отладки - рассчитываем только инверсный выход
                    if cY.Count > 1 then
                      for j:=0 to N-1 do Y[1].Arr^[j]:=true_val-Y[0].Arr^[j];
                  end;
  end
end;


end.
