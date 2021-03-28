
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Func_blocks;

 //***************************************************************************//
 //              Блоки - стандартные математические функции                   //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, math, mbty_std_consts,
     uExtMath;

type

  //Функция вычисления двойного арктангенса с учётом квадранта
  TAtan2Func =  class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Функция вычисления синуса и косинуса сразу от одного аргумента
  TSinCosFunc =  class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Степенная функция  y=x^a
  //Свойства: a - показатель степени (вектор)
  TPowerFunc = class(TRunObject)
  protected
    a:             TExtArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Линейная функция  y=a+b*x
  //Свойства: a - свободный член (вектор)
  //          b - коэффициент при времени (вектор)
  TLinearFunc = class(TPowerFunc)
  public
    b:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Линейное преобразование (Xmin,Xmax)->(0,1)
  TLineConvert = class(TLinearFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Ограничитель входного сигнала
  TLimit = class(TLinearFunc)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Показательная функция y = a^(b*x)
  TPokazFunc = class(TLinearFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Смешанная показательная функция y = a*(u1^(b*u2))
  TVarPokazFunc = class(TLinearFunc)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Периодическая функция (синусоидальная) y = a*sin(w*t + f)
  //Свойства:  a - амплитуда (вектор)
  //           w - частота (вектор)
  //           f - сдвиг фазы (вектор)
  TSinFunc = class(TPowerFunc)
  public
    func_type:     NativeInt;
    w:             TExtArray;
    f:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Обратная периодическая функция - a*arcsin(w*t + f)
  TArcSinFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Обратная периодическая функция - a*arccos(w*t + f)
  TArcCosFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Арктангенс - a*arctg(w*t + f)
  TArcTgFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Арккотангенс - a*arcctg(w*t + f)
  TArcCtgFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Гиперболический синус - a*sh(w*t + f)
  TShFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Гиперболический косинус - a*ch(w*t + f)
  TChFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Гиперболический тангенс - a*th(w*t + f)
  TThFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Гиперболический котангенс - a*cth(w*t + f)
  TCthFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Логарифм натуральный - a*ln(w*t + f)
  TLnFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Логарифм десятичный - a*log(w*t + f)
  TLgFunc = class(TSinFunc)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Логарифм натуральный с защитой 0
  // ln() = a*ln(w*t + f) , если w*t + f > 0
  // ln() = b,              если w*t + f = 0
  TLn0Func = class(TSinFunc)
  public
    DefaultLogValue:double;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
  end;

  //Логарифм десятичный с защитой 0
  // ln() = a*log(w*t + f) , если w*t + f > 0
  // ln() = b,               если w*t + f = 0
  TLg0Func = class(TLn0Func)
  public
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Гиперболическая функция -  k/(x + eps)
  //Свойства:  k - числитель (вектор)
  //           eps - минимальное значение знаменятеля (вектор)
  THyperFunc = class(TRunObject)
  public
    k:             TExtArray;
    eps:           TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Параболическая функция - a0 + a1*x + a2*x^2
  //Свойства:  a0 - свободный член (вектор)
  //           a1 - к-т при первой степени (вектор)
  //           a2 - к-т при второй степени (вектор)
  TParabolaFunc = class(TRunObject)
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

  //Полиноминальная функция произвольной степени  - a[0] + a[1]*x + a[2]*x^2 + ...
  //Свойства:  a - массив векторов коэффициентов полинома (матрица)
  TPolynomFunc = class(TRunObject)
  public
    a:             TExtArray2;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Экспоненциальная функция   - a*exp(b*t + c)
  //Свойства:  a - амплитуда
  //           b - коэффициент при времени
  //           с - слагаемое в аргументе
  TExpFunc = class(TLinearFunc)
  public
    c:             TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Вычисление корня квадратного
  TSQRT = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;


implementation

{*******************************************************************************
                          Показательная функция
*******************************************************************************}
constructor TPowerFunc.Create;
begin
  inherited;
  a:=TExtArray.Create(1);
end;

destructor  TPowerFunc.Destroy;
begin
  inherited;
  a.Free;
end;

function    TPowerFunc.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end
  end
end;

function    TPowerFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=cU[0];
                end;
    i_GetPropErr: if (a.Count <= 0) then begin
                    ErrorEvent(txtANotDefined,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TPowerFunc.RunFunc;
 var i:   integer;
     x,p: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_InitState,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                    x:=U[0].Arr^[i];
                    a.TryGet(i,p);
                    if ((int(p) <> p) and (x < 0)) or
                       ((x = 0) and (p < 0)) then begin
                          //Result:=r_Fail;
                          ErrorEvent(txtPowerError+' time='+FloatToStr(at),msError,VisualObject);
                          Y[0].Arr^[i]:=0;
                    end
                    else
                      Y[0].Arr^[i]:=Power(x,p);
                  end;
  end
end;

{*******************************************************************************
               Линейный сигнал y=a+b*x
*******************************************************************************}
constructor TLinearFunc.Create;
begin
  inherited;
  b:=TExtArray.Create(1);
end;

destructor  TLinearFunc.Destroy;
begin
  inherited;
  b.Free;
end;

function   TLinearFunc.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
    end;
  end
end;

function   TLinearFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: begin
                    Result:=inherited InfoFunc(Action,aParameter);
                    if Result = r_Success then begin
                      if (b.Count <= 0) then begin
                        ErrorEvent(txtBNotDefined,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                    end;
                  end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TLinearFunc.RunFunc;
 var i: integer;
     a_tmp,
     b_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                     a.TryGet(i,a_tmp);
                     b.TryGet(i,b_tmp);
                     Y[0].Arr^[i]:=a_tmp + b_tmp*U[0].Arr^[i];
                  end;
  end
end;

  //Класс - линейный преобразователь
function   TLineConvert.RunFunc;
 var i: integer;
     a_tmp,
     b_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                     a.TryGet(i,a_tmp);
                     b.TryGet(i,b_tmp);
                     if b_tmp <> a_tmp then
                       Y[0].Arr^[i]:=(U[0].Arr^[i] - a_tmp)/(b_tmp - a_tmp)
                     else begin
                       ErrorEvent(txtLineConvertErrorAEqB+' time='+FloatToStr(at),msError,VisualObject);
                       Y[0].Arr^[i]:=0;
                     end;
                  end;
  end
end;

  //Класс - ограничитель
function   TLimit.InfoFunc;
  var i: integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr: begin
                    Result:=inherited InfoFunc(Action,aParameter);
                    if Result = r_Success then begin
                       for i:=0 to Min(a.count,b.Count) - 1 do
                         if a.Arr^[i] > b.Arr^[i] then begin
                            ErrorEvent(txtLowLimitGreatThanHighLimitAtElement+IntToStr(i + 1),msError,VisualObject);
                            Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                         end;
                    end;
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TLimit.RunFunc;
 var i: integer;
     a_tmp, b_tmp, x: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                     a.TryGet(i,a_tmp);
                     b.TryGet(i,b_tmp);

                     //Дополнительная проверка на не-число, чтобы не вылезти за диапазоны !
                     x:=U[0].Arr^[i];
                     if IsNaN(x) then x:=0;

                     if x > b_tmp then
                       Y[0].Arr^[i] := b_tmp
                     else
                       if x < a_tmp then
                         Y[0].Arr^[i] := a_tmp
                       else
                         Y[0].Arr^[i] := x;
                  end;
  end
end;


{*******************************************************************************
                Показательная функция y=a^(bx)
*******************************************************************************}

function   TPokazFunc.RunFunc;
 var i:         integer;
     x,p,b_tmp: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                    a.TryGet(i,x);
                    b.TryGet(i,b_tmp);
                    p:=b_tmp*U[0].Arr^[i];
                    if ((int(p) <> p) and (x < 0)) or
                       ((x = 0) and (p < 0)) then begin
                          //Result:=r_Fail;
                          ErrorEvent(txtPowerError+' time='+FloatToStr(at),msError,VisualObject);
                          Y[0].Arr^[i]:=0;
                    end
                    else
                      Y[0].Arr^[i]:=Power(x,p);
                  end;
  end
end;

{*******************************************************************************
              Смешанная  показательная функция y=a*(u1^(b*u2))
*******************************************************************************}

function    TVarPokazFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  if cU.Count < 2 then begin
                    ErrorEvent(txtBlockNeed2inp,msError,VisualObject);
                    Result:=r_Fail;
                  end else begin
                    cU[1]:=cU[0];
                    cY[0]:=cU[0];
                  end
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TVarPokazFunc.RunFunc;
 var i: integer;
     a_tmp,b_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                    a.TryGet(i,a_tmp);
                    b.TryGet(i,b_tmp);
                    Y[0].Arr^[i]:=a_tmp*Power(U[0].Arr^[i],b_tmp*U[1].Arr^[i]);
                  end;
  end
end;

{*******************************************************************************
                              Синусоида
*******************************************************************************}
constructor TSinFunc.Create;
begin
  inherited;
  w:=TExtArray.Create(1);
  f:=TExtArray.Create(1);
end;

destructor  TSinFunc.Destroy;
begin
  inherited;
  w.Free;
  f.Free;
end;

function    TSinFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: begin
                    Result:=inherited InfoFunc(Action,aParameter);

                    if Result = r_Success then begin

                      if (w.Count <= 0) then begin
                        ErrorEvent(txtWNotDefined,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;

                      if (f.Count <= 0) then begin
                        ErrorEvent(txtFNotDefined,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;

                    end;
    end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TSinFunc.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'w') then begin
      Result:=NativeInt(w);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'f') then begin
      Result:=NativeInt(f);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'func_type') then begin
      Result:=NativeInt(@func_type);
      DataType:=dtInteger;
    end
  end
end;

function   TSinFunc.RunFunc;
 var i: integer;
     x: Double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);
                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    case func_type of
                      1: x:=cos(x);
                      2: x:=tan(x);
                    else
                      x:=sin(x);
                    end;
                    Y[0][i]:=a_tmp*x;
                  end;
  end
end;

{*******************************************************************************
                  Обратная периодическая функция - арксинус
*******************************************************************************}
function    TArcSinFunc.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);
                    x:=w_tmp*U[0].Arr^[i] + f_tmp;

                    if (x >= -1) and (x <= 1) then
                      Y[0][i]:=a_tmp*arcsin(x)
                    else begin
                      Result:=r_Fail;
                      ErrorEvent(txtArgumentNotInOne+' time='+FloatToStr(at),msError,VisualObject);
                      break;
                    end
                  end
  end
end;

{*******************************************************************************
                                Арккосинус
*******************************************************************************}
function    TArcCosFunc.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);
                    x:=w_tmp*U[0].Arr^[i] + f_tmp;

                    if (x >= -1) and (x <= 1) then
                      Y[0][i]:=a_tmp*arccos(x)
                    else begin
                      Result:=r_Fail;
                      ErrorEvent(txtArccosError+' time='+FloatToStr(at),msError,VisualObject);
                      break;
                    end
                  end
  end
end;

{*******************************************************************************
                                Арктангенс
*******************************************************************************}
function    TArcTgFunc.RunFunc;
 var i: integer;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    Y[0][i]:=a_tmp*arctan(w_tmp*U[0].Arr^[i] + f_tmp);
    end;
  end
end;

{*******************************************************************************
                                Арккотангенс
*******************************************************************************}
function    TArcCtgFunc.RunFunc;
 var i: integer;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    Y[0][i]:=a_tmp*(pi05  -  arctan(w_tmp*U[0].Arr^[i] + f_tmp));
    end;
  end
end;

{*******************************************************************************
                            Гиперболический синус
*******************************************************************************}
function    TShFunc.RunFunc;
 var i: integer;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    Y[0][i]:=a_tmp*Sinh(w_tmp*U[0].Arr^[i] + f_tmp);
    end;
  end
end;

{*******************************************************************************
                            Гиперболический косинус
*******************************************************************************}
function    TChFunc.RunFunc;
 var i: integer;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    Y[0][i]:=a_tmp*Cosh(w_tmp*U[0].Arr^[i] + f_tmp);
    end;
  end
end;

{*******************************************************************************
                            Гиперболический тангенс
*******************************************************************************}
function    TThFunc.RunFunc;
 var i: integer;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    Y[0][i]:=a_tmp*Tanh(w_tmp*U[0].Arr^[i] + f_tmp);
    end;
  end
end;

{*******************************************************************************
                        Гиперболический котангенс
*******************************************************************************}
function    TCthFunc.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    if x <> 1.0 then
                      Y[0][i]:={$IFDEF FPC}a_tmp/TanH(x){$ELSE}a_tmp*CotH(x){$ENDIF}
                    else begin
                       Result:=r_Fail;
                       ErrorEvent(txtHypCtgError+' time='+FloatToStr(at),msError,VisualObject);
                       break;
                    end;
                  end

  end
end;

{*******************************************************************************
                        Логарифм натуральный
*******************************************************************************}
function    TLnFunc.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    if x > 0 then
                      Y[0][i]:=a_tmp*Ln(x)
                    else begin
                       Result:=r_Fail;
                       ErrorEvent(txtLogError+' time='+FloatToStr(at),msError,VisualObject);
                       break;
                    end;
                  end

  end
end;

{*******************************************************************************
                          Логарифм десятичный
*******************************************************************************}
function    TLgFunc.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    if x > 0 then
                      Y[0][i]:=a_tmp*Log10(x)
                    else begin
                       Result:=r_Fail;
                       ErrorEvent(txtLogError+' time='+FloatToStr(at),msError,VisualObject);
                       break;
                    end;
                  end

  end
end;

{*******************************************************************************
                        Логарифм натуральный c защитой 0
*******************************************************************************}
constructor TLn0Func.Create;
begin
  inherited;
  DefaultLogValue:=-1e19;
end;

function    TLn0Func.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(@DefaultLogValue);
      DataType:=dtDouble;
      exit;
    end;
  end
end;

function    TLn0Func.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    if x > 0 then begin
                      Y[0][i]:=a_tmp*Ln(x);
                      if Y[0][i] < DefaultLogValue then Y[0][i]:=DefaultLogValue;
                    end
                    else begin
                      Y[0][i]:=DefaultLogValue;
                    end;
                  end

  end;
end;

{*******************************************************************************
                          Логарифм десятичный c защитой 0
*******************************************************************************}
function    TLg0Func.RunFunc;
 var i: integer;
     x: double;
     a_tmp,w_tmp,f_tmp: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin

                    a.TryGet(i,a_tmp);
                    w.TryGet(i,w_tmp);
                    f.TryGet(i,f_tmp);

                    x:=w_tmp*U[0].Arr^[i] + f_tmp;
                    if x > 0 then begin
                      Y[0][i]:=a_tmp*Log10(x);
                      if Y[0][i] < DefaultLogValue then Y[0][i]:=DefaultLogValue;
                    end
                    else begin
                      Y[0][i]:=DefaultLogValue;
                    end;
                  end

  end;
end;

{*******************************************************************************
                         Гиперболическая функция
*******************************************************************************}
constructor  THyperFunc.Create;
begin
  inherited;
  k:=TExtArray.Create(1);
  eps:=TExtArray.Create(1);
end;

destructor   THyperFunc.Destroy;
begin
  k.Free;
  eps.Free;
  inherited;
end;

function     THyperFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (eps.Count <= 0) or (k.Count <= 0) then begin
                    ErrorEvent(txtHyperError,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   begin
                    cY[0]:=cU[0];
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    THyperFunc.GetParamID;
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

function    THyperFunc.RunFunc;
 var i: integer;
     x: double;
     tmp_k,tmp_eps: Double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to U[0].Count - 1 do begin

                        eps.TryGet(i,tmp_eps);
                        k.TryGet(i,tmp_k);

                        x:=U[0].Arr^[i] + tmp_eps;
                        if x <> 0 then
                          Y[0].Arr^[i]:=tmp_k/x
                        else begin
                          Result:=r_Fail;
                          ErrorEvent(txtHyperErr1+' time='+FloatToStr(at),msError,VisualObject);
                        end;

                      end;
  end
end;

{*******************************************************************************
                                 Парабола
*******************************************************************************}
constructor  TParabolaFunc.Create;
begin
  inherited;
  a0:=TExtArray.Create(1);
  a1:=TExtArray.Create(1);
  a2:=TExtArray.Create(1);
end;

destructor   TParabolaFunc.Destroy;
begin
  a0.Free;
  a1.Free;
  a2.Free;
  inherited;
end;

function     TParabolaFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: if (a1.Count <= 0) or (a0.Count <= 0) or (a2.Count <= 0) then begin
                    ErrorEvent(txtParabErr,msError,VisualObject);
                    Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                  end;
    i_GetCount:   begin
                    cY[0]:=cU[0];
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TParabolaFunc.GetParamID;
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

function    TParabolaFunc.RunFunc;
 var i: integer;
     x: double;
     tmp_a0,tmp_a1,tmp_a2: Double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to U[0].Count - 1 do begin

                        a0.TryGet(i,tmp_a0);
                        a1.TryGet(i,tmp_a1);
                        a2.TryGet(i,tmp_a2);

                        x:=U[0].Arr^[i];
                        Y[0].Arr^[i]:=tmp_a0 + x*tmp_a1 + x*x*tmp_a2;
                      end;
  end
end;

{*******************************************************************************
                 Полином произвольной степени
*******************************************************************************}
constructor  TPolynomFunc.Create;
begin
  inherited;
  a:=TExtArray2.Create(1,1);
end;

destructor   TPolynomFunc.Destroy;
begin
  inherited;
  a.Free;
end;

function     TPolynomFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:   begin
                    cY[0]:=cU[0];
                  end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function     TPolynomFunc.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtMatrix;
    end;
  end
end;

function    TPolynomFunc.RunFunc;
 var pt:     double;
     x:      double;
     i,j:    integer;
     ai_arr: TExtArray;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateOuts,
    f_UpdateJacoby,
    f_GoodStep      : for i:=0 to U[0].Count - 1 do begin
                        if i < a.CountX then ai_arr:=a.Arr^[i];
                        pt:=1;
                        Y[0].Arr^[i]:=0;
                        x:=U[0].Arr^[i];
                        for j:=0 to ai_arr.Count - 1 do begin
                          Y[0].Arr^[i]:=Y[0].Arr^[i] + pt*ai_arr.Arr^[j];
                          pt:=pt*x;
                        end;
                      end;
  end;
end;

{*******************************************************************************
                            Экспонента
*******************************************************************************}
constructor  TExpFunc.Create;
begin
  inherited;
  c:=TExtArray.Create(1);
end;

destructor   TExpFunc.Destroy;
begin
  inherited;
  c.Free;
end;

function     TExpFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetPropErr: begin
                    Result:=inherited InfoFunc(Action,aParameter);
                    if Result = r_Success then begin
                      if (c.Count <= 0) then begin
                        ErrorEvent(txtCNotDefined,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                    end;
    end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function     TExpFunc.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'c') then begin
      Result:=NativeInt(c);
      DataType:=dtDoubleArray;
    end;
  end
end;

function     TExpFunc.RunFunc;
 var i: integer;
     tmp_a,tmp_b,tmp_c: Double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to U[0].count-1 do begin
                     a.TryGet(i,tmp_a);
                     b.TryGet(i,tmp_b);
                     c.TryGet(i,tmp_c);
                     Y[0][i]:=tmp_a*exp(tmp_b*U[0].Arr^[i] + tmp_c);
    end;
  end
end;

{*******************************************************************************
                          Вычисление корня квадратного
*******************************************************************************}

function    TSQRT.InfoFunc;
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

function   TSQRT.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i: Integer;
    x: double;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  for i:=0 to Y[0].count - 1 do begin
                   x:=U[0].Arr^[i];
                   if x > 0 then
                     Y[0].Arr^[i]:=sqrt(x)
                   else
                     Y[0].Arr^[i]:=0;
                 end;
  end
end;

 //Функция вычисления арктангенса двойного аргумента

function    TAtan2Func.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=cU[0];
                  cU[1]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TAtan2Func.RunFunc;
 var i:   integer;
     x,p: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_InitState,
    f_GoodStep:   for i:=0 to cU[0] - 1 do
                    Y[0].Arr^[i]:=arctan2(U[0].Arr^[i],U[1].Arr^[i]);
  end
end;


 //Функция вычисления арктангенса двойного аргумента

function    TSinCosFunc.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  cY[0]:=cU[0];
                  cY[1]:=cU[0];
                end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TSinCosFunc.RunFunc;
 var i:   integer;
     x,p: double;
begin
  Result:=0;
  case Action of
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_InitState,
    f_GoodStep:   for i:=0 to cU[0] - 1 do
                    MySinCos(U[0].Arr^[i],Y[0].Arr^[i],Y[1].Arr^[i]);
  end
end;


end.
