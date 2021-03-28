
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 
 
unit Logs;

 //***************************************************************************//
 //                          Логические блоки                                 //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts;

type

  //Произвольный логический блок
  TCustomLog = class(TRunObject)
  public
    inv_out:       boolean;  //Флаг инверсии выхода блока - если убрать старые блоки, можно выбросить
    T_In     :     double;   //Значение, выше которого входы логических блоков считаются "Истина"
    true_val:      double;
    false_val:     double;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      SetTrueFalse(inv:Boolean);
  end;

  //Произвольная логическая операция
  TBool = class(TCustomLog)
  public
    what:          NativeInt;  //Тип второго входа
    log_type:      NativeInt;  //Тип логической операции
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Оператор логического отрицания
  TNot = class(TCustomLog)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор логического умножение (И)
  TAnd = class(TCustomLog)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор логического сложения (ИЛИ)
  TOr = class(TAnd)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор XOR (поэлементный)
  TXOR = class(TAnd)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор not XOR (поэлементный)
  TNotXOR = class(TXOR)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор векторного ИЛИ (сравнивает все элементы входного вектора)
  TVecOR = class(TAnd)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Оператор векторного И
  TVecAnd = class(TVecOR)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Подтрверждение по количеству логических сигналов (векторное)
  TMN = class(TCustomLog)
  public
    m:             NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Подтверждение по количеству логических сигналов (поэлементное)
  TMNByElement = class(TMN)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

 //Radio-button
 //Блок реализует работу группы логических сигналов по принципу
 //"Один из многих". На вход блока подается векторный логический сигнал
 TOne = class(TCustomLog)
 public
   n:             integer;
   n_:            NativeInt;   //Эта переменная задаётся извне
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   procedure      RestartSave(Stream: TStream);override;
   function       RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

 // Radio-button
 //Блок реализует работу группы логических сигналов по принципу
 //"Один из многих". На вход блока подается номер активного элемента массива
 TOneVar = class(TCustomLog)
 public
   N:             NativeInt;
   function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
 end;

 //Счётчик импульсов
 TCounter = class(TRunObject)
 protected
   N :             Integer;
   AX:             array of double;
 public
   Ymin,Ymax :     TExtArray;
   what :          NativeInt;
   fResetType:     NativeInt;
   constructor     Create(Owner: TObject);override;
   destructor      Destroy;override;
   function        GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
   function        InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
   function        RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
   procedure       RestartSave(Stream: TStream);override;
   function        RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
 end;

  //Произвольная логическая операция
  TBitwizeOperations = class(TRunObject)
  public
    what:          NativeInt;  //Тип второго входа
    log_type:      NativeInt;  //Тип логической операции
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Побитовое логическое отрицание
  TBitwizeNot = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Битовая упаковка в целое число
  TBitPack = class(TRunObject)
  public
    bit_nums:      TIntArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Битовая распаковка
  TBitUnPack = class(TBitPack)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

implementation

function       TCustomLog.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'out_inv') then begin
      Result:=NativeInt(@inv_out);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'true_val') then begin
      Result:=NativeInt(@true_val);
      DataType:=dtDouble;
      exit;
    end;
    if StrEqu(ParamName,'false_val') then begin
      Result:=NativeInt(@false_val);
      DataType:=dtDouble;
    end;
    if StrEqu(ParamName,'t_in') then begin
      Result:=NativeInt(@t_in);
      DataType:=dtDouble;
      exit;
    end;
  end
end;

constructor    TCustomLog.Create(Owner: TObject);
begin
  inherited;
  T_in:=0.5;
  true_val:=1;
  false_val:=0;
end;

destructor   TCustomLog.Destroy;
begin
  u_inv:=nil;
  y_inv:=nil;
  inherited;
end;

procedure TCustomLog.SetTrueFalse(inv:Boolean);
var tmp : Double;
begin
  if inv then begin
    tmp:=true_val;
    true_val:=false_val;
    false_val:=tmp;
  end
end;

{*******************************************************************************
                    Произвольная логическая операция
*******************************************************************************}

function       TBool.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'what') then begin
      Result:=NativeInt(@what);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'log_type') then begin
      Result:=NativeInt(@log_type);
      DataType:=dtInteger;
    end
  end
end;

function       TBool.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if what = 0 then CU.arr^[1]:=1 else CU.arr^[1]:=CU.arr^[0];
                  CY.arr^[0]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TBool.RunFunc;
 var j: integer;
     x: RealType;
     u0,u1,f: Boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y[0].Count-1 do begin
                  if what = 0 then x:=U[1].arr^[0] else x:=U[1].arr^[j];
                  case log_type of
                     0:begin
                         u0:=U[0].arr^[j] >= T_In;
                         if u_inv[0] then u0:=not u0;
                         u1:=x >= T_In;
                         if u_inv[1] then u1:=not u1;
                         f:=u0 and u1;
                       end;
                     1:begin
                         u0:=U[0].arr^[j] >= T_In;
                         if u_inv[0] then u0:=not u0;
                         u1:=x >= T_In;
                         if u_inv[1] then u1:=not u1;
                         f:=u0 or u1;
                       end;
                     2:f:=U[0].arr^[j] > x;
                     3:f:=U[0].arr^[j] < x;
                     4:f:=U[0].arr^[j] = x;
                     5:f:=U[0].arr^[j] <> x;
                     6:f:=U[0].arr^[j] >= x;
                     7:f:=U[0].arr^[j] <= x;
                     8:begin
                         u0:=U[0].arr^[j] >= T_In;
                         if u_inv[0] then u0:=not u0;
                         u1:=x >= T_In;
                         if u_inv[1] then u1:=not u1;
                         f:=u0 xor u1;
                       end;
                     9:begin
                         u0:=U[0].arr^[j] >= T_In;
                         if u_inv[0] then u0:=not u0;
                         u1:=x >= T_In;
                         if u_inv[1] then u1:=not u1;
                         f:=not (u0 xor u1);
                       end;
                   else f:=false;
                  end;

		              if f then
                    Y[0].arr^[j]:=true_val
                  else
                    Y[0].arr^[j]:=false_val;
                 end;
  end
end;

{*******************************************************************************
                     Операция логического отрицания
*******************************************************************************}
function       TNot.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: CY.arr^[0]:=CU.arr^[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TNot.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do
		               if (U[0].arr^[j] < T_In) then
                     Y[0].arr^[j]:=true_val
		               else
                     Y[0].arr^[j]:=false_val;
  end
end;

{*******************************************************************************
                     Операция логического умножения
*******************************************************************************}
function       TAnd.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if CU.Count < 1 then begin
                    ErrorEvent(txtAndErr,msError,VisualObject);
                    Result:=r_Fail;
                    exit;
                  end;
                  CY.arr^[0]:=CU.arr^[0];
                  for i:=1 to CU.Count - 1 do cU[i]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TAnd.RunFunc;
 var j,i : integer;
     f,ui: boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do begin
                   f:=True;
                   for i:=0 to cU.Count - 1 do begin
                    ui:=U[i].Arr^[j] >= T_In;
                    if u_inv[i] then ui:=not ui;
                    f:=f and ui;
                   end;

                   if f then
                     Y[0].Arr^[j]:=true_val
                   else
                     Y[0].Arr^[j]:=false_val;
                 end
  end
end;

{*******************************************************************************
                     Операция
*******************************************************************************}
function       TOr.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if CU.Count < 1 then begin
                    ErrorEvent(txtOrErr,msError,VisualObject);
                    Result:=r_Fail;
                    exit;
                  end;
                  CY.arr^[0]:=CU.arr^[0];
                  for i:=1 to CU.Count - 1 do cU[i]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TOr.RunFunc;
 var j,i  : integer;
     f,ui : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do begin
                   f:=False;
                   for i:=0 to cU.Count - 1 do begin
                    ui:=U[i].Arr^[j] >= T_In;
                    if u_inv[i] then ui:=not ui;
                    f:=f or ui;
                   end;

                   if f then
                     Y[0].Arr^[j]:=true_val
                   else
                     Y[0].Arr^[j]:=false_val;
                 end
  end
end;

{*******************************************************************************
                          XOR
*******************************************************************************}
function       TXOR.RunFunc;
 var i,j    :   integer;
     f,f1,f2:   boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do begin
                   f:=False;
                   f1:=(U[0].arr^[j] >= T_In);
                   if u_inv[0] then f1:=not f1;

                   for i:=1 to cU.Count - 1 do begin
                    f:=false;
                    f2:=U[i].Arr^[j] >= T_In;
                    if u_inv[i] then f2:=not f2;
                    if f1 or f2 then begin
                      f:=true;
                      if f1 and f2 then f:=false
                    end;
                    f1:=f
                   end;

                   if f then
                     Y[0].Arr^[j]:=true_val
                   else
                     Y[0].Arr^[j]:=false_val;
                 end
  end
end;

{*******************************************************************************
                             Векторный OR
*******************************************************************************}
function       TVecOr.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if CU.Count < 1 then begin
                    ErrorEvent(txtOrErr,msError,VisualObject);
                    Result:=r_Fail;
                    exit;
                  end;
                  CY.arr^[0]:=1;  //Размерность выхода = 1
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TVecOr.RunFunc;
 var j,i : integer;
     f,ui: boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:begin
                  f:=False;
                  for I := 0 to cU.Count - 1 do
                    for j := 0 to U[i].Count - 1 do begin
                      ui:=U[i].Arr^[j] >= T_In;
                      if u_inv[i] then ui:=not ui;
                      f:=f or ui;
                    end;
                  if f then
                    Y[0].Arr^[0]:=true_val
                  else
                    Y[0].Arr^[0]:=false_val;
                end;
  end
end;

function       TVecAnd.RunFunc;
 var j,i : integer;
     f,ui: boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:begin
                  f:=True;
                  for I := 0 to cU.Count - 1 do
                    for j := 0 to U[i].Count - 1 do begin
                      ui:=U[i].Arr^[j] >= T_In;
                      if u_inv[i] then ui:=not ui;
                      f:=f and ui;
                    end;
                  if f then
                    Y[0].Arr^[0]:=true_val
                  else
                    Y[0].Arr^[0]:=false_val;
                end;
  end
end;

{*******************************************************************************
                         Векторный not XOR
*******************************************************************************}
function       TNotXOR.RunFunc;
 var i,j    :   integer;
     f,f1,f2:   boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do begin
                   f:=False;
                   f1:=(U[0].arr^[j] >= T_In);
                   if u_inv[0] then f1:=not f1;

                   for i:=1 to cU.Count - 1 do begin
                    f:=false;
                    f2:=U[i].Arr^[j] >= T_In;
                    if u_inv[i] then f2:=not f2;
                    if f1 or f2 then begin
                      f:=true;
                      if f1 and f2 then f:=false
                    end;
                    f:=not f;
                    f1:=f
                   end;

                   if f then
                     Y[0].Arr^[j]:=true_val
                   else
                     Y[0].Arr^[j]:=false_val;
                 end
  end
end;

{*******************************************************************************
                    Подтверждение по количеству сигналов
*******************************************************************************}

function       TMN.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'m') then begin
      Result:=NativeInt(@m);
      DataType:=dtInteger;
      exit;
    end;
  end
end;

function       TMN.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: CY.arr^[0]:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TMN.RunFunc;
 var i,j,k : Integer;
     f:      boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: begin
                  k:=0;
                   for i:=0 to cU.Count-1 do
                    for j:=0 to U[i].Count-1 do begin
                     f:=U[i].arr^[j] >= T_In;
                     if u_inv[i] then f:=not f;
                     if f then inc(k);
                    end;

                  f:= k >= m;

                  if f then
                    Y[0].arr^[0]:=true_val
                  else
                    Y[0].arr^[0]:=false_val;
                 end;

  end
end;

  //Тоже самое, но поэлементно
function       TMNByElement.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if CU.Count < 1 then begin
                    ErrorEvent(txtOrErr,msError,VisualObject);
                    Result:=r_Fail;
                    exit;
                  end;
                  CY.arr^[0]:=CU.arr^[0];
                  for i:=1 to CU.Count - 1 do cU[i]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TMNByElement.RunFunc;
 var i,j,k : Integer;
     f:      boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects:SetTrueFalse(y_inv[0]);
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState: for j:=0 to Y[0].Count-1 do begin
                   k:=0;
                   for i:=0 to cU.Count - 1 do begin
                     f:=U[i].Arr^[j] >= T_In;
                     if u_inv[i] then f:=not f;
                     if f then inc(k);
                   end;

                   f:= k >= m;

                   if f then
                     Y[0].Arr^[j]:=true_val
                   else
                     Y[0].Arr^[j]:=false_val;
                 end;

  end
end;


{*******************************************************************************
                    Выбор "один из многих" - радиогруппа
*******************************************************************************}

function       TOne.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'n') then begin
      Result:=NativeInt(@n_);
      DataType:=dtInteger;
    end;
  end
end;

function       TOne.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TOne.RunFunc;
 var j,k : Integer;
begin
  Result:=0;
  case Action of
    f_GoodStep:  begin
                  k:=0;
                  for j:=0 to Y[0].Count-1 do
                   if (U[0].arr^[j] >= T_In) then begin
                      N:=j+1;
                      inc(k)
                    end;
                  if k <> 1 then exit;
                  for j:=0 to Y[0].Count-1 do Y[0].arr^[j]:=false_val;
                  Y[0].arr^[N-1]:=true_val;
                 end;
    f_InitState: begin
                  N:=N_;
                  for j:=0 to Y[0].Count-1 do
                   if j = N-1 then Y[0].arr^[j]:=true_val
                    else Y[0].arr^[j]:=false_val;
                 end;
  end
end;

procedure  TOne.RestartSave(Stream: TStream);
begin
  inherited;
  //Запись состояния для блока идеального запаздывания
  Stream.Write(N,SizeOfInt);
end;

function   TOne.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  //Чтение состояния для блока идеального запаздывания
  if Result then
  if Count > 0 then
    try
      Stream.Read(N,SizeOfInt);
    finally
    end
end;

{*******************************************************************************
                    Выбор "один из многих" с активным из порта
*******************************************************************************}
function       TOneVar.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'n') then begin
      Result:=NativeInt(@n);
      DataType:=dtInteger;
    end;
  end
end;

function       TOneVar.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=N;
                  CU.arr^[0]:=1;
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TOneVar.RunFunc;
 var j,k : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_GoodStep: begin
                   k:=round(U[0].arr^[0]);
                   for j:=0 to N-1 do
                     if (j = k-1) then Y[0].arr^[j]:=true_val
                      else Y[0].arr^[j]:=false_val
                end;
  end
end;


{*******************************************************************************
                              Счётчик импульсов
*******************************************************************************}
constructor TCounter.Create;
begin
  inherited;
  ymin:=TExtArray.Create(1);
  ymax:=TExtArray.Create(1);
  fResetType:=0;                //0 - вход сброса - вектор, 1 - вход сброса - скаляр
end;

destructor  TCounter.Destroy;
begin
  inherited;
  ymin.Free;
  ymax.Free;
end;

function       TCounter.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'what') then begin
      Result:=NativeInt(@what);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'ymin') then begin
      Result:=NativeInt(ymin);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'resettype') then begin
      Result:=NativeInt(@fResetType);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'ymax') then begin
      Result:=NativeInt(ymax);
      DataType:=dtDoubleArray;
    end;
  end
end;

function       TCounter.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=CU.arr^[0];
                  if cU.Count > 1 then
                     if fResetType = 1 then cU.Arr^[1]:=1 else cU.Arr^[1]:=CU.arr^[0];
                end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TCounter.RunFunc;
 var  j : Integer;
      x : RealType;
begin
  Result:=0;
  case Action of
  f_InitObjects:begin
                  N:=U[0].Count;
                  SetLength(AX,2*N);

                  //Добавляем переменную в список считывания данных
                  if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
                end;

  f_InitState:  if not NeedRemoteData then
                for j:=0 to N-1 do begin
                 AX[j]:=0;
                 AX[j+N]:=1;
                 x:=U[0].arr^[j];
                 case what of
                 0: if (x >= Ymin.arr^[j]) and (x <= Ymax.arr^[j]) then begin
                     if AX[j+N] = 1.0 then begin
                       AX[j]:=AX[j]+1.0;
                       AX[j+N]:=0.0;
                     end
                    end else AX[j+N]:=1.0;
                 1: if (x <= Ymin.arr^[j]) or (x >= Ymax.arr^[j]) then begin
                     if AX[j+N] = 1.0 then begin
                       AX[j]:=AX[j]+1.0;
                       AX[j+N]:=0.0
                     end
                    end else AX[j+N]:=1.0;
                 end;
                 //Сброс по второму входу
                 if (cU.Count > 1) and (U[1].Arr^[min(j,U[1].Count - 1)] > 0.5) then AX[j]:=0;
                 Y[0].arr^[j]:=AX[j];
                end;

 f_RestoreOuts: if not NeedRemoteData then
                    for j:=0 to N-1 do Y[0].arr^[j]:=AX[j];

                //ПРомежуточные шаги - не запоминаем состояние !!!
 f_UpdateOuts : if not NeedRemoteData then
                  for j:=0 to N-1 do begin
                    x:=U[0].arr^[j];
                    case what of
                    0: if (x >= Ymin.arr^[j]) and (x <= Ymax.arr^[j]) and (AX[j+N] = 1.0) then
                        Y[0].arr^[j]:=AX[j]+1.0;
                    1: if (x <= Ymin.arr^[j]) or (x >= Ymax.arr^[j]) and (AX[j+N] = 1.0) then
                        Y[0].arr^[j]:=AX[j]+1.0;
                   end;
                   //Сброс по второму входу
                   if (cU.Count > 1) and (U[1].Arr^[min(j,U[1].Count - 1)] > 0.5) then Y[0].arr^[j]:=0;
                  end;

 f_GoodStep   : if not NeedRemoteData then
                for j:=0 to N-1 do begin
                 x:=U[0].arr^[j];
                 case what of
                 0: if (x >= Ymin.arr^[j]) and (x <= Ymax.arr^[j]) then begin
                     if AX[j+N] = 1.0 then begin
                       AX[j]:=AX[j]+1.0;
                       AX[j+N]:=0.0
                     end
                     end
                     else
                       AX[j+N]:=1.0;
                 1: if (x <= Ymin.arr^[j]) or (x >= Ymax.arr^[j]) then begin
                     if AX[j+N] = 1.0 then begin
                       AX[j]:=AX[j]+1.0;
                       AX[j+N]:=0.0
                     end
                     end
                     else
                       AX[j+N]:=1.0;
                 end;
                 //Сброс по второму входу
                 if (cU.Count > 1) and (U[1].Arr^[min(j,U[1].Count - 1)] > 0.5) then AX[j]:=0;
                 Y[0].arr^[j]:=AX[j];
                end;
  end
end;

procedure  TCounter.RestartSave(Stream: TStream);
begin
  inherited;
  Stream.Write(N,SizeOfInt);
  Stream.Write(AX[0],N*2*SizeOfDouble);
end;

function   TCounter.RestartLoad;
 var c: integer;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result then
  if Count > 0 then
    try
      Stream.Read(c,SizeOfInt);
      Stream.Read(AX[0],min(N,c)*2*SizeOfDouble);
    finally
    end
end;



{*******************************************************************************
                  Целочисленные логические операции
*******************************************************************************}

function       TBitwizeOperations.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'what') then begin
      Result:=NativeInt(@what);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'log_type') then begin
      Result:=NativeInt(@log_type);
      DataType:=dtInteger;
    end
  end
end;

function       TBitwizeOperations.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if what = 0 then CU.arr^[1]:=1 else CU.arr^[1]:=CU.arr^[0];
                  CY.arr^[0]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TBitwizeOperations.RunFunc;
 var j: integer;
     u0,u1,res: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y[0].Count-1 do begin
                    //1-й операнд
                    u0:=Trunc(U[0].arr^[j]);
                    if u_inv[0] then u0:=not u0;
                    //2-й операнд
                    if what = 0 then u1:=Trunc(U[1].arr^[0]) else u1:=Trunc(U[1].arr^[j]);
                    if u_inv[1] then u1:=not u1;
                    case log_type of
                      // &   (И)
                      0: res:=u0 and u1;
                      //1   (ИЛИ)
                      1: res:=u0 or u1;
                      //    (ИСКЛЮЧАЮЩЕЕ ИЛИ, XOR)
                      2: res:=u0 xor u1;
                      // << (Битовый сдвиг влево)
                      3: res:=u0 shl u1;
                      // >> (Битовый сдвиг вправо)
                      4: res:=u0 shr u1;
                      // +   (Сложение)
                      5: res:=u0 + u1;
                      // -    (Вычитание)
                      6: res:=u0 - u1;
                      // *    (Умножение)
                      7: res:=u0*u1;
                      //  /     (Деление)
                      8: res:=u0 div u1;
                      //  %  (Остаток от деления)
                      9: res:=u0 mod u1;
                  else
                    res:=0;
                  end;
                  //Инверсия выхода если надо
                  if y_inv[0] then res:=not res;
                  Y[0].arr^[j]:=res;
                 end;
  end
end;


 //Упаковка битов в число
constructor    TBitPack.Create(Owner: TObject);
begin
  bit_nums:=TIntArray.Create(0);
  inherited;
end;

destructor     TBitPack.Destroy;
begin
  inherited;
  bit_nums.Free;
end;

function       TBitPack.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'bit_nums') then begin
      Result:=NativeInt(bit_nums);
      DataType:=dtIntArray;
    end
  end
end;

function       TBitPack.InfoFunc;
 var i: Integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if CU.Count > 0 then begin
                    cY[0]:=cU[0];
                    for i := 1 to CU.Count - 1 do cU[i]:=cU[0];
                  end
                  else
                    cY[0]:=0;
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TBitPack.RunFunc;
 var i,j,res,inp_data: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y[0].Count-1 do begin
                    res:=0;

                    for i := 0 to bit_nums.Count - 1 do begin
                      inp_data:=Byte( ( U[i].Arr^[j] > 0.5 ) xor u_inv[i] );
                      res:=res or (inp_data shl bit_nums.Arr^[i]);
                    end;

                    //Инверсия выхода если надо
                    if y_inv[0] then
                      Y[0].arr^[j]:=not res
                    else
                      Y[0].arr^[j]:=res;
                  end;
  end
end;

//Битовая распаковка
function       TBitUnPack.InfoFunc;
 var i: Integer;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  for i := 0 to CY.Count - 1 do cY[i]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TBitUnPack.RunFunc;
 var i,j,inp_data: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to U[0].Count-1 do begin
                    //Получение входа и инверсия если надо
                    inp_data:=Trunc(U[0].Arr^[j]);
                    if u_inv[0] then inp_data:=not inp_data;
                    //Расстановка нужных битов выходов
                    for i := 0 to bit_nums.Count - 1 do begin
                      Y[i].arr^[j]:=Byte( ((inp_data and (1 shl bit_nums.Arr^[i])) <> 0) xor y_inv[i]);
                    end;
                  end;
  end
end;

    // Побитовое логическое отрицание
function       TBitwizeNot.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=CU.arr^[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function       TBitwizeNot.RunFunc;
 var j: integer;
     u0,res: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep,
    f_InitState:  for j:=0 to Y[0].Count-1 do begin
                    u0:=Trunc(U[0].arr^[j]);
                    if u_inv[0] then u0:=not u0;
                    if y_inv[0] then
                      res:=u0
                    else
                      res:=not u0;
                    Y[0].arr^[j]:=res;
                 end;
  end
end;

end.
