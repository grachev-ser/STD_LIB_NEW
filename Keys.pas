 //**************************************************************************//
 // Данный исходный код является составной частью SimInTech                  //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //                      Щекатуров А.М. (анимация ключей, сентябрь 2014)     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 
 
unit Keys;

 //***************************************************************************//
 //                    Блоки - переключатели (ключи)                          //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts;

type

  //Простой ключ - если u(t) >= K, то y(t)=u(t), иначе y(t)=Y0
  //K,Y0 - векторы, размерность которых равна размерности входного сигнала
  TKey0 = class(TRunObject)
  public
    k:             TExtArray;
    y0:            TExtArray;
    level:         TIntArray; //уровень переключения ключа (0 - выдает подпороговое значение, 1 - ключ замкнут, передаёт вход на выход)
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Ключ - если u(t) >= K, то y1(t)=u(t);y2(t)=Y0, иначе y1(t)=Y0;y2(t)=u(t)
  //K,Y0 - векторы, размерность которых равна размерности входного сигнала
  TKey1 = class(TKey0)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Ключ - если u(t) < K1, то y1(t)=u(t);  y2(t)=Y2(0),  //level = -1
  //       если u(t) > K2, то y2(t)=u(t);  y1(t)=Y1(0),  //level = 1
  //       иначе              y1(t)=Y1(0); y2(t)=Y2(0)   //level = 0
  //K1,K2,Y1(0),Y2(0) - вектора, размерность которых равна размерности входа
  TKey2 = class(TRunObject)
  public
    k1:            TExtArray;
    k2:            TExtArray;
    y01:           TExtArray;
    y02:           TExtArray;
    level:         TIntArray; //уровень переключения ключа (-1 = u(t) < K1, +1 u(t) > K2, 0 если между K1 и K2)
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Ключ - если  u2(t) < K, то y(t)=u1(t)  //level = 0
  //       иначе               y(t)=u3(t)  //level = 1
  TKey3 = class(TRunObject)
  public
    k:             TExtArray;
    fl:            NativeInt;
    level:         TIntArray; //уровень переключения ключа (0 = u2(t) < K, +1 u2(t) >= K)
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Ключ временной -
  //     если  t < T0, то y(t)=Y0  // level = 0
  //     иначе y(t)=u(t)           // level = 1
  //T0,Y0 - вектора, размерность которых равна размерности входа
  TKey4 = class(TKey0)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Ключ временной -
  //     если  t < u(t), то y1(t)=u(t);y2(t)=Y0   //level = 0
  //     иначе              y1(t)=Y0;  y2(t)=u(t) //level = 1
  //Y0 - вектор, размерность которых равна размерности входа
  TKey5 = class(TRunObject)
  public
    y0:            TExtArray;
    level:         TIntArray; //уровень переключения ключа (0 = t < u(t), +1 t >= u(t))
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Ключ временной -
  //     если t < K1, то y1(t)=u(t);y2(t)=Y2(0),
  //     если t > K2, то y2(t)=u(t);y1(t)=Y1(0),
  //     иначе y1(t)=Y1(0);y2(t)=Y2(0)
  //K1,K2,Y1(0),Y2(0) - вектора, размерность которых равна размерности входа
  TKey6 = class(TKey2)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Ключ временной -
  //     если  t < K, то y(j,t)=u1(j,t)
  //     иначе y(j,t)=u2(j,t)
  TKey7 = class(TKey5)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

	//Ключ интегратора

  //Блок реализует функцию управляемого ключа для интегрирующего привода
  //(типа интегратора или инерционно-интегрирующего звена),
  // по следующему алгоритму:
  //	y(t) = x1(t),  если a1 < x2(t) < a2;
  //	y(t) = 0,  если x2(t) <=a1  и  x1(t) <= 0,
  //			или  x2(t) >= a2  и x1(t) >= 0;
  //	y(t) = x1(t),  если x2(t) <=a1  и  x1(t) > 0,
  //			     или  x2(t) >= a2  и x1(t) < 0,
  //гле x1(t) - сигнал на 1-ый вход на Ключ; x2(t) - управляющий сигнал на
  //2-ой вход Ключа с выхода интегратора; y(t) - сигнал на выходе Ключа
  //(на входе в интегратор); коэффициент усиления интегратора К > 0.
  //Для работы блока необходимо задать параметры a1 и a2.

  TKey8 = class(TRunObject)
  public
    ymin:          TExtArray;
    ymax:          TExtArray;
    level:         TIntArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string; var DataType:TDataType; var IsConst: boolean):NativeInt;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

 //Определение первого события (RS-мультитриггер)
  TCommutator = class(TRunObject)
  public
    function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;


implementation

{*******************************************************************************
                           Ключ - 0
*******************************************************************************}
constructor TKey0.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
  k:=TExtArray.Create(1);
  level:=TIntArray.Create(1);
end;

destructor  TKey0.Destroy;
begin
  inherited;
  y0.Free;
  k.Free;
  level.Free;
end;

function    TKey0.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end
  end
end;

function    TKey0.GetOutParamID;
begin
  Result:=inherited GetOutParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    DataType:=dtIntArray;
    if StrEqu(ParamName,'_level') then begin
      Result:=11;
      exit;
    end;
  end;
end;

function       TKey0.ReadParam;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив уровня переключения
    11: if DestDataType = dtIntArray then begin
         TIntArray(DestData).Count:=k.count;
         if (k.Count > 0) and (level.Count = k.Count) then
           Move(level.arr^,TIntArray(DestData).Arr^[0],level.Count*SizeOfNativeInt);
         Result:=True;
       end;
  end;
end;

function    TKey0.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cU[0]:=y0.Count;
                  cY[0]:=y0.Count;
                end;
    i_GetPropErr: if (y0.Count < k.Count) then begin
                    ErrorEvent(txtKey0Err,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey0.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=k.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to y0.Count-1 do
	             	    if U[0].arr^[j] >= k.arr^[j]
                      then begin
                        Y[0].arr^[j]:=U[0].arr^[j];
                        level.arr^[j] := 1;
                      end
                      else begin
                        Y[0].arr^[j]:=Y0.arr^[j];
                        level.arr^[j] := 0;
                      end;
  end
end;

{*******************************************************************************
                           Ключ - 1
*******************************************************************************}
function    TKey1.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cU[0]:=y0.Count;
                  cY[0]:=y0.Count;
                  cY[1]:=y0.Count;
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey1.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размер массива
                      level.Count:=k.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to y0.Count-1 do
		               if U[0].arr^[j] >= k.arr^[j] then begin
  		               Y[0].arr^[j]:=U[0].arr^[j];
		                 Y[1].arr^[j]:=Y0.arr^[j];
                     level.arr^[j] := 1;
		               end
		               else begin
		                 Y[1].arr^[j]:=U[0].arr^[j];
		                 Y[0].arr^[j]:=Y0.arr^[j];
                     level.arr^[j] := 0;
		               end;
  end
end;

{*******************************************************************************
                           Ключ - 2
*******************************************************************************}
constructor TKey2.Create;
begin
  inherited;
  y01:=TExtArray.Create(1);
  y02:=TExtArray.Create(1);
  k1:=TExtArray.Create(1);
  k2:=TExtArray.Create(1);
  level:=TIntArray.Create(1);
end;

destructor  TKey2.Destroy;
begin
  inherited;
  y01.Free;
  y02.Free;
  k1.Free;
  k2.Free;
  level.Free;
end;

function    TKey2.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k1') then begin
      Result:=NativeInt(k1);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'k2') then begin
      Result:=NativeInt(k2);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'y02') then begin
      Result:=NativeInt(y02);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'y01') then begin
      Result:=NativeInt(y01);
      DataType:=dtDoubleArray;
    end
  end
end;

function    TKey2.GetOutParamID;
begin
  Result:=inherited GetOutParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    DataType:=dtIntArray;
    if StrEqu(ParamName,'_level') then begin
      Result:=11;
      exit;
    end;
  end;
end;

function       TKey2.ReadParam;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив уровня переключения
    11: if DestDataType = dtIntArray then begin
         TIntArray(DestData).Count:=k1.count;
         if (k1.Count > 0) and (level.Count = k1.Count) then
           Move(level.arr^,TIntArray(DestData).Arr^[0],level.Count*SizeOfNativeInt);
         Result:=True;
       end;
  end;
end;

function    TKey2.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=Y01.Count;
                  CU.arr^[0]:=Y01.Count;
                  CY.arr^[1]:=Y01.Count;
                end;
    i_GetPropErr: if (k1.Count < y01.Count) or (k2.Count < y01.Count) or (y02.Count < y01.Count) then begin
                    ErrorEvent(txtKey2Err,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey2.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=k1.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y01.Count-1 do
		                if U[0].arr^[j] < K1.arr^[j] then begin
		                  Y[0].arr^[j]:=U[0].arr^[j];
		                  Y[1].arr^[j]:=Y02.arr^[j];
                      level[j] := -1;
		                end
		                else if U[0].arr^[j] > K2.arr^[j] then begin
		                  Y[1].arr^[j]:=U[0].arr^[j];
		                  Y[0].arr^[j]:=Y01.arr^[j];
                      level[j] := +1;
		                end
		                else begin
		                  Y[1].arr^[j]:=Y02.arr^[j];
		                  Y[0].arr^[j]:=Y01.arr^[j];
                      level[j] := 0;
		                end;
  end
end;

{*******************************************************************************
                           Ключ - 3
*******************************************************************************}
constructor TKey3.Create;
begin
  inherited;
  k:=TExtArray.Create(1);
  level:=TIntArray.Create(1);
end;

destructor  TKey3.Destroy;
begin
  inherited;
  k.Free;
  level.Free;
end;

function    TKey3.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'fl') then begin
      Result:=NativeInt(@fl);
      DataType:=dtInteger;
    end
  end
end;

function    TKey3.GetOutParamID;
begin
  Result:=inherited GetOutParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    DataType:=dtIntArray;
    if StrEqu(ParamName,'_level') then begin
      Result:=11;
      exit;
    end;
  end;
end;

function    TKey3.ReadParam;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив уровня переключения
    11: if DestDataType = dtIntArray then begin
         TIntArray(DestData).Count:=level.count;
         Move(level.arr^,TIntArray(DestData).Arr^[0],level.Count*SizeOfNativeInt);
         Result:=True;
       end;
  end;
end;

function    TKey3.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:    if fl = 1 then begin
                     CY.arr^[0]:=CU.arr^[0];
                     CU.arr^[1]:=CU.arr^[0];
                     CU.arr^[2]:=CU.arr^[0]
                   end
                   else begin
                     CY.arr^[0]:=CU.arr^[0];
                     CU.arr^[1]:=1;           //Требуемая размерность для скаляра = 1
                     CU.arr^[2]:=CU.arr^[0]
                   end;

  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey3.RunFunc;
 var j,ustj: integer;
     ust: double;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов - индикатор состояния ключей
                      level.Count:=CU[1];
                      for j:=0 to level.Count-1 do begin
                        level.Arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:begin
                  //Определяем уставку срабатывания для скаляра
                  if k.Count > 0 then
                    ust:=k.arr^[0]
                  else
                    ust:=0.5;
                  //Индекс уставки для скаляра
                  ustj:=0;
                  for j:=0 to U[0].Count-1 do begin
                    //Если уставка - вектор
                    if (fl = 1) then begin
                      if (j < k.Count) then ust:=k.arr^[j];
                      if (j < CU[1]) then ustj:=j;
                    end;
                    //Переключение выхода по уставке
                    if U[1].arr^[ustj] < ust then begin
                      Y[0].arr^[j]:=U[0].arr^[j];
                      level[ustj]:=0;
                    end else begin
                      Y[0].arr^[j]:=U[2].arr^[j];
                      level[ustj]:=1;
                    end;
                  end;
                end;
  end;
end;

{*******************************************************************************
                           Ключ - 4(t)
*******************************************************************************}
function    TKey4.InfoFunc;
begin
  Result:=inherited InfoFunc(Action,aParameter);
end;

function   TKey4.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размер массива
                      level.Count:=k.Count;
                      for j:=0 to level.Count-1 do begin
                       level.arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y0.Count-1 do
		                if (at <= K.arr^[j]) then begin
                      Y[0].arr^[j]:=Y0.arr^[j];
                      level.arr^[j] := 0;
                    end else begin
                      Y[0].arr^[j]:=U[0].arr^[j];
                      level.arr^[j] := 1;
                    end;
  end
end;

{*******************************************************************************
                           Ключ - 5(t)
*******************************************************************************}
constructor TKey5.Create;
begin
  inherited;
  y0:=TExtArray.Create(1);
  level:=TIntArray.Create(1);
end;

destructor  TKey5.Destroy;
begin
  inherited;
  y0.Free;
  level.Free;
end;

function    TKey5.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
    end
  end
end;

function    TKey5.GetOutParamID;
begin
  Result:=inherited GetOutParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    DataType:=dtIntArray;
    if StrEqu(ParamName,'_level') then begin
      Result:=11;
      exit;
    end;
  end;
end;

function    TKey5.ReadParam;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив уровня переключения
    11: if DestDataType = dtIntArray then begin
         TIntArray(DestData).Count:=y0.count;
         if (y0.Count > 0) and (level.Count = y0.Count) then
           Move(level.arr^,TIntArray(DestData).Arr^[0],level.Count*SizeOfNativeInt);
         Result:=True;
       end;
  end;
end;

function    TKey5.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=y0.Count;
                  CY.arr^[1]:=y0.Count;
                  CU.arr^[0]:=y0.Count;
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey5.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=y0.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0;
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to y0.Count-1 do
 		               if at < U[0].arr^[j] then begin
		                 Y[0].arr^[j] := U[0].arr^[j];
		                 Y[1].arr^[j] := y0.arr^[j];
                     level[j] := 0;
		               end
		               else begin
		                 Y[1].arr^[j] := U[0].arr^[j];
		                 Y[0].arr^[j] := y0.arr^[j];
                     level[j] := 1;
		               end;
  end
end;


{*******************************************************************************
                           Ключ - 6(t)
*******************************************************************************}

function   TKey6.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=k1.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y01.Count-1 do
		              if at < K1.arr^[j] then begin
		                Y[0].arr^[j]:=U[0].arr^[j];
		                Y[1].arr^[j]:=Y02.arr^[j];
                    level[j]:=-1;
		              end
		              else if at > K2.arr^[j] then begin
		                Y[1].arr^[j]:=U[0].arr^[j];
		                Y[0].arr^[j]:=Y01.arr^[j];
                    level[j]:= 1;
		              end
		              else begin
          		      Y[1].arr^[j]:=Y02.arr^[j];
		                Y[0].arr^[j]:=Y01.arr^[j];
                    level[j]:= 0;
		              end;
  end
end;

{*******************************************************************************
                           Ключ - 7(t)
*******************************************************************************}
function    TKey7.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=y0.Count;
                  CU.arr^[0]:=y0.Count;
                  CU.arr^[1]:=y0.Count;
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey7.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=y0.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0;
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to y0.Count-1 do
		                if at < y0.arr^[j] then begin
                       Y[0].arr^[j]:=U[0].arr^[j];
                       level[j] := 0;
                    end else begin
                       Y[0].arr^[j]:=U[1].arr^[j];
                       level[j] := 1;
                    end;
  end
end;


{*******************************************************************************
                           Ключ интегратора
*******************************************************************************}
constructor TKey8.Create;
begin
  inherited;
  ymin:=TExtArray.Create(1);
  ymax:=TExtArray.Create(1);
  level:=TIntArray.Create(1);
end;

destructor  TKey8.Destroy;
begin
  inherited;
  ymin.Free;
  ymax.Free;
  level.Free;
end;

function    TKey8.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'ymin') then begin
      Result:=NativeInt(ymin);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'ymax') then begin
      Result:=NativeInt(ymax);
      DataType:=dtDoubleArray;
    end
  end
end;

function    TKey8.GetOutParamID;
begin
  Result:=inherited GetOutParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    DataType:=dtIntArray;
    if StrEqu(ParamName,'_level') then begin
      Result:=11;
      exit;
    end;
  end;
end;

function    TKey8.ReadParam;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
   case ID of
    //Читаем массив уровня переключения
    11: if DestDataType = dtIntArray then begin
         TIntArray(DestData).Count:=ymax.count;
         if (ymax.Count > 0) and (level.Count = ymax.Count) then
           Move(level.arr^,TIntArray(DestData).Arr^[0],level.Count*SizeOfNativeInt);
         Result:=True;
       end;
  end;
end;

function    TKey8.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                   CY.arr^[0]:=ymax.Count;
                   CU.arr^[0]:=ymax.Count;
                   CU.arr^[1]:=ymax.Count;
                end;
    i_GetPropErr: if (ymin.Count < ymax.Count) then begin
                    ErrorEvent(txtKey8Err,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;

  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TKey8.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:  begin
                      //Устанавливаем размеры массивов
                      level.Count:=ymax.Count;
                      for j:=0 to level.Count-1 do begin
                       level.Arr^[j]:=0;
                      end;
                    end;
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to ymax.Count-1 do
	             	    if ((U[1].arr^[j] <= ymin.Arr^[j]) and (U[0].arr^[j] <= 0)) or
                       ((U[1].arr^[j] >= ymax.Arr^[j]) and (U[0].arr^[j] >= 0)) then begin
                      Y[0].arr^[j]:=0;
                      level[j] := 0;
                    end else begin
		                  Y[0].arr^[j]:=U[0].arr^[j];
                      level[j] := 1;
                    end;
  end
end;

{*******************************************************************************
                           Коммутатор входных сигналов
*******************************************************************************}
function       TCommutator.InfoFunc;
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

function       TCommutator.RunFunc;
  var j,i   : Integer;
  label next_element;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep:
                      for j:=0 to CY.Arr^[0] - 1 do begin
                        Y[0].Arr^[j]:=0;
                        for i := 0 to CU.Count div 2 - 1 do
                           if (U[i + (CU.Count div 2)].Arr^[j] > 0.5) xor u_inv[i + (CU.Count div 2)] then begin
                             Y[0].Arr^[j]:=U[i].Arr^[j];
                             goto next_element;
                           end;
next_element:
                      end;
  end
end;


end.
 
