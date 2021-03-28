
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //                      2015 Щекатуров А.М. добавил блок                    //
 //                      "формирование номера активного элемента" (для CASE) //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit operations;

 //***************************************************************************//
 //        Блоки выполняющие стандартные арифметические операции              //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, Math, mbty_std_consts;


type

  //Сумматор (поэлементный)
  //Выполняет поэлементное сумирование нескольких входных векторов
  //с заданными весовыми коэффициентами a (вектор)
  //Размерности входных векторов долны совпадать. Размерность выходного вектора равна размерности входных.
  TSum = class(TRunObject)
  protected
    a:             TExtArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Сумматор (полный)
  //Выполняет сумирование всех элементов всех входных векторов
  //с заданными весовыми коэффициентами a (вектор)
  //Размерности входов - произвольные
  TVecSum = class(TSum)
  public
    nsum:          NativeInt;  //Размерность выхода суммирования
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Перемножитель (поэлементный)
  TMul = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Перемножитель (полный)
  TVecMul = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Умножение вектора на число
  TScalarMul = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Скалярное произведение векторов
  TVectorDotProduct = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Сложение эоементов вектора с числом
  TScalarAdd = class(TRunObject)
  public
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Векторный усилитель
  TVectorAmp = class(TSum)
  public
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Деление числа на вектор
  TScalarDiv = class(TRunObject)
  public
    fdiverror:     boolean;
    fMaxOut:       double;
    fshowdiverr:   boolean;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Деление (поэлементное)
  TDiv = class(TRunObject)
  public
    fdiverror:     boolean;
    fMaxOut:       double;
    fshowdiverr:   boolean;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Вычисление модуля числа
  TAbs = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Пустой блок, размножающий вход на несколько выходов
  TEmpty = class(TRunObject)
  public
    constructor    Create(Owner: TObject);override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Вычисление показателя знака числа
  TSign = class(TAbs)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Выделение целой части числа
  TInt = class(TAbs)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Выделение дробной части числа
  TFrac = class(TAbs)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Размножитель векторный
  TRazm = class(TRunObject)
  protected
    m:             TExtArray2;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Компенсация начальных условий
  TCompensator = class(TAbs)
  public
    x_old:         array of double;
    constructor    Create(Owner: TObject);override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Выборка из второго вектора согласно номерам указанным в первом
  TCase = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Формирование номера первого ненулевого элемента входного вектора
  TFirstActive = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Выборка из второго вектора согласно активным элементам в первом
  TCaseActive = class(TRunObject)
  public
    cnt:           integer;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Вычисление интеграла таблично заданной функции
  TTrap = class(TRunObject)
  public
    n:             NativeInt;
    nfun:          NativeInt;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

implementation


{*******************************************************************************
                         Поэлементный сумматор
*******************************************************************************}

constructor TSum.Create;
begin
  inherited;
  a:=TExtArray.Create(0);
  IsLinearBlock:=True;
end;

destructor  TSum.Destroy;
begin
  inherited;
  a.Free;
end;

function    TSum.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TSum.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtSumErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0];
                   for i:=1 to cU.Count - 1 do cU[i]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TSum.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
    s   : RealType;
    k   : double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do begin
                   s:=0;
                   k:=1;
                   for j:=0 to cU.Count - 1 do begin
                     if j < a.Count then k:=a.Arr^[j];
                     s:=s + U[j].Arr^[i]*k;
                   end;
                   Y[0].Arr^[i]:=s;
                 end
  end
end;

{*******************************************************************************
                         Полный сумматор
*******************************************************************************}
constructor TVecSum.Create(Owner: TObject);
begin
  inherited;
  nsum:=1;
  IsLinearBlock:=True;
end;

function    TVecSum.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'nsum') then begin
      Result:=NativeInt(@nsum);
      DataType:=dtInteger;
    end;
  end
end;

function    TVecSum.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtVecSumErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=nsum;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TVecSum.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,m : Integer;
    s   : RealType;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                   for m := 0 to nsum - 1 do begin
                     s:=0;
                     for i:=0 to cU.count - 1 do
                        for j:=0 to (U[i].Count div nsum) - 1 do
                           s:=s + U[i].Arr^[j*nsum + m]*a.Arr^[i];
                     Y[0].Arr^[m]:=s;
                   end;
                 end
  end
end;

{*******************************************************************************
                         Поэлементный перемножитель
*******************************************************************************}

function    TMul.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtMulErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0];
                   for i:=1 to cU.Count - 1 do cU[i]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TMul.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
    p   : RealType;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do begin
                   p:=1;
                   for j:=0 to cU.Count - 1 do p:=p * U[j].Arr^[i];
                   Y[0].Arr^[i]:=p;
                 end
  end
end;

{*******************************************************************************
                         Полный перемножитель
*******************************************************************************}
function    TVecMul.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtVecMulErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=1;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TVecMul.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
    p   : RealType;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                   p:=1;
                   for i:=0 to cU.count - 1 do
                     for j:=0 to U[i].Count - 1 do p:=p * U[i].Arr^[j];
                   Y[0].Arr^[0]:=p;
                 end
  end
end;

{*******************************************************************************
                         Умножение вектора на число
*******************************************************************************}

function    TScalarMul.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count < 2 then begin
                     ErrorEvent(txtScalarMulErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0];
                   cU[1]:=1;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TScalarMul.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                    Y[0].Arr^[i]:=U[0].Arr^[i]*U[1].Arr^[0];
  end
end;

{*******************************************************************************
                   Сложение элементов вектора с числом
*******************************************************************************}

constructor TScalarAdd.Create(Owner: TObject);
begin
  inherited;
  IsLinearBlock:=True;
end;

function    TScalarAdd.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count < 2 then begin
                     ErrorEvent(txtScalarAddErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0]*cU[1];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TScalarAdd.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: begin
                  for i:=0 to U[0].count - 1 do
                     for j := 0 to U[1].count - 1 do
                        Y[0].Arr^[i*U[1].count + j]:=U[0].Arr^[i] + U[1].Arr^[j];
                end;
  end
end;

{*******************************************************************************
                          Векторный усилитель
*******************************************************************************}

constructor TVectorAmp.Create(Owner: TObject);
begin
  inherited;
  IsLinearBlock:=True;
end;

function    TVectorAmp.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtAmpErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=a.Count;
                   cU[0]:=cY[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TVectorAmp.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=U[0].Arr^[i]*a.Arr^[i];

  end
end;

{*******************************************************************************
                         Поэлементный перемножитель
*******************************************************************************}

function    TDiv.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 2 then begin
                     ErrorEvent(txtDividerErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0];
                   cU[1]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

constructor TDiv.Create(Owner: TObject);
begin
  inherited;
  fMaxOut:=1e100;
  fshowdiverr:=True;
end;

function    TDiv.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'fshowdiverr') then begin
      Result:=NativeInt(@fshowdiverr);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'fMaxOut') then begin
      Result:=NativeInt(@fMaxOut);
      DataType:=dtDouble;
    end;
  end
end;

function   TDiv.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var i     : Integer;
      x1,x2 : double;
label
      do_run;
begin
  Result:=0;
   case Action of
    f_InitState: begin
                   fdiverror:=False;
                   goto do_run;
                 end;
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: begin

do_run:

                 for i:=0 to Y[0].count - 1 do begin
                   x1:=U[0].Arr^[i];
                   x2:=U[1].Arr^[i];
                   if x2 <> 0 then begin
                     Y[0].Arr^[i]:=x1/x2;
                     //Ограничение результата деления
                     if abs(Y[0].Arr^[i]) > fMaxOut then
                         Y[0].Arr^[i]:=fMaxOut*sign(Y[0].Arr^[i]);
                   end
                   else begin
                     //Вычисление результата деления на 0
                     Y[0].Arr^[i]:=fMaxOut*sign(x1);
                     if (not fdiverror) and fshowdiverr then begin
                       ErrorEvent(txtDivByZero+' time='+FloatToStr(at),msError,VisualObject);
                       fdiverror:=True;
                     end;
                   end;
                 end;
                end;

   end
end;

{*******************************************************************************
                         Деление числа на вектор
*******************************************************************************}

function    TScalarDiv.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 2 then begin
                     ErrorEvent(txtDividerErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[1];
                   cU[0]:=1;     //Первый вход - скаляр
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TScalarDiv.GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'fshowdiverr') then begin
      Result:=NativeInt(@fshowdiverr);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'fMaxOut') then begin
      Result:=NativeInt(@fMaxOut);
      DataType:=dtDouble;
    end;
  end;
end;

constructor TScalarDiv.Create(Owner: TObject);
begin
  inherited;
  fMaxOut:=1e100;
  fshowdiverr:=True;
end;

function    TScalarDiv.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var i     : Integer;
      x1,x2 : double;
  label
      do_run;
begin
  Result:=0;
  case Action of
    f_InitState: begin
                   fdiverror:=False;
                   goto do_run;
                 end;
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin

do_run:
                 for i:=0 to Y[0].count - 1 do begin
                   x1:=U[0].Arr^[0];
                   x2:=U[1].Arr^[i];
                   if x2 <> 0 then begin
                     Y[0].Arr^[i]:=x1/x2;
                     //Ограничение результата деления
                     if abs(Y[0].Arr^[i]) > fMaxOut then
                         Y[0].Arr^[i]:=fMaxOut*sign(Y[0].Arr^[i]);
                   end else begin
                     Y[0].Arr^[i]:=fMaxOut*sign(x1);
                     if (not fdiverror) and fshowdiverr then begin
                       ErrorEvent(txtDivByZero+' time='+FloatToStr(at),msError,VisualObject);
                       fdiverror:=True;
                     end;
                   end;
                 end;
    end;
  end;
end;

{*******************************************************************************
                          Вычисление модуля числа
*******************************************************************************}

function    TAbs.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtAbsErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TAbs.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=abs(U[0].Arr^[i]);

  end
end;

{*******************************************************************************
                          Вычисление модуля числа
*******************************************************************************}
function   TSign.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=Sign(U[0].Arr^[i]);

  end
end;

{*******************************************************************************
                          Вычисление целой части
*******************************************************************************}
function   TInt.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=Int(U[0].Arr^[i]);

  end
end;

{*******************************************************************************
                          Вычисление дробной части
*******************************************************************************}
function   TFrac.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=Frac(U[0].Arr^[i]);

  end
end;

{*******************************************************************************
                         Векторный размножитель
*******************************************************************************}

constructor TRazm.Create;
begin
  inherited;
  m:=TExtArray2.Create(1,1);
  IsLinearBlock:=True;
end;

destructor  TRazm.Destroy;
begin
  inherited;
  m.Free;
end;

function    TRazm.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'m') then begin
      Result:=NativeInt(m);
      DataType:=dtMatrix;
    end;
  end
end;

function    TRazm.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 1 then begin
                     ErrorEvent(txtRazmErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   if m.CountX < 1 then begin
                     ErrorEvent(txtErrorRazmDimensionMatrix,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   //Размерность выхода = размерность входа*число столбцов матрицы
                   cY[0]:=m.GetMinCountY*cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TRazm.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c:   Integer;
    ArTemp:  TExtArray;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                    c:=0;
                    for i:=0 to m.GetMinCountY - 1 do
                     for j:=0 to U[0].count - 1 do begin
                       if j < m.CountX then ArTemp:=m.Arr^[j];
                       Y[0].Arr^[c]:=U[0].Arr^[j]*ArTemp.Arr^[i];
                       inc(c);
                     end
                 end;
  end
end;

{*******************************************************************************
                      Блок компенсации начальных условий
*******************************************************************************}
constructor TCompensator.Create(Owner: TObject);
begin
  inherited;
  IsLinearBlock:=True;
end;

function   TCompensator.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitState: begin
                   SetLength(x_old,Y[0].Count);
                   for i:=0 to U[0].Count - 1 do begin
                     x_old[i]:=U[0].Arr^[i];
                     Y[0].Arr^[i]:=0;
                   end;
                 end;
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do
                   Y[0].Arr^[i]:=U[0].Arr^[i] - x_old[i];

  end
end;

{*******************************************************************************
                   Динамическая выборка элементов вектора
*******************************************************************************}

function    TCase.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 2 then begin
                     ErrorEvent(txtCaseErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=cU[0]; //размерность выхода равна размерности первого входа - сколько там элементов, столько и выбираем из второго вектора
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TCase.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
    k: integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do begin
                   k:=trunc(U[0].Arr^[i]);
                   if k < 1 then k:=1;                    //ограничение номера до [1...U[1].Count], т.е. до размерности второго входа
                   if k > U[1].Count then k:=U[1].Count;
                   Y[0].Arr^[i]:=U[1].Arr^[k - 1];
                 end;

  end
end;

{*******************************************************************************
       Формирование номера первого ненулевого элемента входного вектора
*******************************************************************************}

function TFirstActive.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 1 then begin
                     ErrorEvent(txtFirstActiveNumberErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=1; //выход всегда скалярный, т.к. пишем просто номер первого найденного ненулевого элемента
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function TFirstActive.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
    k: integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to U[0].Count - 1 do begin//проходим по всем элементам входного вектора
                   if (trunc(U[0].Arr^[i]) > 0) then begin
                     Y[0].Arr^[0]:=i+1; //для работы совместно с CASE надо считать элементы с единицы
                     exit; // нашли ненулевой, выходим
                   end;
                   Y[0].Arr^[0]:=0; //если ненулевого не нашли то пишем ноль
                 end;

  end
end;

{*******************************************************************************
            Динамическая выборка элементов вектора по активным элементам
*******************************************************************************}

function    TCaseActive.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 2 then begin
                     ErrorEvent(txtCaseErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   //Размерность выхода = 1 (всегда скаляр)
                   cY[0]:=1;
                   //Размерности входов должны совпадать !!!
                   cU[1]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TCaseActive.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: cnt:=min(U[0].Count,U[1].Count);
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:    begin
                     Y[0].Arr^[0]:=0;
                     for I := 0 to cnt - 1 do
                       if U[0].Arr^[i] > 0.5 then begin
                         Y[0].Arr^[0]:=U[1].Arr^[i];
                         exit;
                       end;
                   end;
  end
end;

{*******************************************************************************
             Вычисление интеграла табличных функций методом трапеций
*******************************************************************************}

function    TTrap.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = - 1 then begin
    if StrEqu(ParamName,'npoint') then begin
      Result:=NativeInt(@n);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'nfun') then begin
      Result:=NativeInt(@nfun);
      DataType:=dtInteger;
    end;
  end
end;

function    TTrap.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count <> 2 then begin
                     ErrorEvent(txtCaseErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cU[0]:=n;
                   cU[1]:=n*nfun;
                   cY[0]:=nfun;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTrap.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
  var i,j:    Integer;
      sum:    double;
      px,py : PExtArr;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                   px:=U[0].arr;
                   py:=U[1].arr;
                   for i:=0 to nfun - 1 do begin
                     sum:=0;
                     if i > 0 then py:=@py^[n];
                     for j:=1 to N - 1 do sum:=sum+(px^[j]-px^[j-1])*(py^[j]+py^[j-1])/2;
                     Y[0].arr^[i]:=sum;
                   end
                 end;
  end
end;


{*******************************************************************************
             Пустой блок, размножающий вход на несколько выходов
*******************************************************************************}

constructor TEmpty.Create(Owner: TObject);
begin
  inherited;
  IsLinearBlock:=True;
end;

function    TEmpty.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count = 0 then begin
                     ErrorEvent(txtAbsErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   for I := 0 to cY.Count - 1 do cY[i]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TEmpty.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: for j := 0 to cY.Count - 1 do
                   for i:=0 to Y[0].count - 1 do
                      Y[j].Arr^[i]:=U[0].Arr^[i];
  end
end;


{*******************************************************************************
                         Скалярное произведение двух векторов
*******************************************************************************}

function    TVectorDotProduct.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   if cU.Count < 2 then begin
                     ErrorEvent(txtScalarMulErr,msError,VisualObject);
                     Result:=r_Fail;
                     exit;
                   end;
                   cY[0]:=1;
                   cU[1]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TVectorDotProduct.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                    Y[0].Arr^[0]:=0;
                    for i:=0 to cU[0] - 1 do
                      Y[0].Arr^[0]:=Y[0].Arr^[0] + U[0].Arr^[i]*U[1].Arr^[i];
                 end;
  end
end;


end.
