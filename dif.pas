
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit dif;

 //***************************************************************************//
 //   Стандартные дифференциальные блоки                                      //
 //                                                                           //
 //***************************************************************************//

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, mbty_std_consts;


type

  //Динамический блок, выходы которого напрямую не зависят от входов
  TCustomIntegrator = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
  end;

  //Интегратор
  TIntegrator = class(TCustomIntegrator)
  public
    k   : TExtArray;//Коэффициенты усиления
    x0  : TExtArray;//Начальные условия
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Интегратор с периодизатором
  TPeriodicIntegrator = class(TIntegrator)
  public
    limits:        TExtArray;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Апериодика 1-го порядка
  TAperiodika1 = class(TIntegrator)
  public
    T:             TExtArray;//Постоянные времени
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Решение линейной системы в матричном виде
  TStates = class(TCustomIntegrator)
  public
    xc,uc,yc:      NativeInt;
    A_,B_,C_,D_:   TExtArray2;
    Y0:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Квадратичный функционал качества
  TFunctional = class(TCustomIntegrator)
  public
    Ai:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Колебательное звено
  TKoleb = class(TAperiodika1)
  public
    dx0:           TExtArray;     //н.у. по производным
    b:             TExtArray;     //к-т демпфирования
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Инерционно-форсирующее звено
  TForceAperiodika = class(TCustomIntegrator)
  public
    x0:            TExtArray;
    T1:            TExtArray;
    T2:            TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Инерционно-дифференцирующее звено
  TDifAperiodika = class(TAperiodika1)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Инерционно-интегрирующее звено
  TIntergAperiodika = class(TAperiodika1)
  public
    dx0:           TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Интегратор с ограничением по выходному значению
  TLimitIntegrator = class(TIntegrator)
  public
    ymin:          TExtArray;
    ymax:          TExtArray;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Интегратор с ограничением по выходному сигналу и сбросом в начальные условия
  TResetLimitIntegrator = class(TLimitIntegrator)
  public
    resettype:     NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       PostFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Интегратор с изменяемыми н.у.
  TVarIntegrator = class(TCustomIntegrator)
  public
    resettype:     NativeInt;
    maxflag:       double;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       PostFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
  end;

  //Передаточная функция общего вида
  TWs = class(TCustomIntegrator)
  public
    b:             TExtArray2;
    a:             TExtArray2;
    y0:            TExtArray2;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок уточнения переходов
  TCrossZero = class(TRunObject)
  public
    x:             TExtArray;
    c:             TExtArray;  //Сдвиг нулевого значения
    d:             TExtArray;  //К-ты d - для (1 - при возрастании функции,-1 - при убывании)
    dtol:          TExtArray;  //Точность по времени
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Блок указатель сходимости решения на проможуточном шаге
  TTolPointer = class(TRunObject)
  public
    a:             TExtArray;  //Точность по времени
    old_u:         TExtArray;
    out_type:      NativeInt;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;


implementation

uses math;

{*******************************************************************************
      Динамический блок, выходы которого напрямую не зависят от входов
*******************************************************************************}
function    TCustomIntegrator.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  case Action of
    i_GetBlockType:  Result:=t_fun;
    i_GetInit:       Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

{*******************************************************************************
                 ИНТЕГРАТОР
*******************************************************************************}
constructor TIntegrator.Create;
begin
  inherited;
  k:=TExtArray.Create(1);
  x0:=TExtArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TIntegrator.Destroy;
begin
  inherited;
  k.Free;
  x0.Free;
end;

function    TIntegrator.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(k);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TIntegrator.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetDifCount:  Result:=X0.Count;
    i_GetCount:     begin
                      cU[0]:=X0.Count;
                      cY[0]:=cU[0];
                    end;
    i_GetPropErr:   if k.Count < X0.Count then begin
                      ErrorEvent(txtKlessX0,msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TIntegrator.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState: if not NeedRemoteData then begin
                    for i:=0 to DifCount-1 do Xdif[i]:=X0[i];
                    for i:=0 to DifCount-1 do Y[0][i]:=Xdif[i]
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   if not NeedRemoteData then for i:=0 to DifCount-1 do Y[0][i]:=Xdif[i];
    f_GetDeri:    if not NeedRemoteData then for i:=0 to DifCount-1 do FDif[i]:=k[i]*U[0][i];
  end
end;

const
  c_2pi = 2*pi;

 //  Интегратор с ограничением 0 ... (заданное значение, по умолчанию 2*pi)
 //  и обрезкой по остатку от деления
constructor    TPeriodicIntegrator.Create(Owner: TObject);
begin
  inherited;
  limits:=TExtArray.Create(0);
end;

destructor     TPeriodicIntegrator.Destroy;
begin
  inherited;
  limits.Free;
end;

function       TPeriodicIntegrator.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'limits') then begin
      Result:=NativeInt(limits);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TPeriodicIntegrator.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
 var
     i: integer;
     tmplimit,
     tmpd: double;
begin
  Result:=0;
  case Action of
                  //Добавляем переменную в список считывания данных
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState: if not NeedRemoteData then begin
                    for i:=0 to DifCount-1 do Xdif[i]:=X0[i];
                    for i:=0 to DifCount-1 do Y[0][i]:=Xdif[i]
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   if not NeedRemoteData then begin
                    tmplimit:=c_2pi;
                    for i:=0 to DifCount-1 do begin
                       limits.TryGet(i,tmplimit);
                       tmpd:=Xdif[i];
                       if tmpd > tmplimit then
                         tmpd:=tmpd - tmplimit*Int(tmpd/tmplimit)
                       else
                       if tmpd < 0 then
                         tmpd:=tmplimit*(Int(abs(tmpd)/tmplimit) + 1) + tmpd;
                       Y[0][i]:=tmpd;
                       if Action = f_GoodStep then Xdif[i]:=tmpd;
                    end;
                  end;
    f_GetDeri:    if not NeedRemoteData then for i:=0 to DifCount-1 do FDif[i]:=k[i]*U[0][i];
  end
end;


{*******************************************************************************
                Апериодика 1-го порядка
*******************************************************************************}
constructor TAperiodika1.Create;
begin
  inherited;
  T:=TExtArray.Create(1);
end;

destructor  TAperiodika1.Destroy;
begin
  inherited;
  T.Free;
end;

function   TAperiodika1.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'t') then begin
      Result:=NativeInt(T);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TAperiodika1.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    i_GetPropErr:   begin
                     if (k.Count < X0.Count) or (T.Count < X0.Count) then begin
                       ErrorEvent(txtKTlessX0,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     for i:=0 to X0.Count-1 do if T[i] <= 0 then begin
                       ErrorEvent(txtTimeEqZero,msWarning,VisualObject);
                       exit;
                     end
                    end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TAperiodika1.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_GetDeri: if not NeedRemoteData then for i:=0 to DifCount-1 do FDif[i]:=(k[i]*U[0][i]-Xdif[i])/T[i];
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

{*******************************************************************************
                 Решение произвольной линейной системы
*******************************************************************************}
constructor TStates.Create;
begin
  inherited;
  A_:=TExtArray2.Create(1,1);
  B_:=TExtArray2.Create(1,1);
  C_:=TExtArray2.Create(1,1);
  D_:=TExtArray2.Create(1,1);
  Y0:=TExtArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TStates.Destroy;
begin
  inherited;
  A_.Free;
  B_.Free;
  C_.Free;
  D_.Free;
  Y0.Free;
end;

function    TStates.GetParamID;
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

function    TStates.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
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
    i_GetDifCount:  Result:=xc;
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
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TStates.RunFunc;
 var i,j: integer;
     x:   double;
begin
  Result:=0;
  case Action of
    f_InitState:  begin
        		        for i:=0 to xc-1 do Xdif[i]:=Y0.arr^[i];
		                for i:=0 to yc-1 do begin
		                  x:=0;
		                  for j:=0 to xc-1 do x:=x + C_.val(j,i)*Xdif[j];
                      Y[0].arr^[i]:=x
		                end;
		                for i:=0 to yc-1 do begin
                      x:=Y[0].arr^[i];
		                  for j:=0 to uc-1 do x:=x+ D_.val(j,i)*U[0].arr^[j];
                      Y[0].arr^[i]:=x
                    end;
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   begin
		               for i:=0 to yc-1 do begin
                     x:=0;
		                 for j:=0 to xc-1 do x:=x + C_.val(j,i)*Xdif[j];
                     Y[0].arr^[i]:=x;
		               end;
		               for i:=0 to yc-1 do begin
                     x:=Y[0].arr^[i];
 		                 for j:=0 to uc-1 do x:=x+ D_.val(j,i)*U[0].arr^[j];
                     Y[0].arr^[i]:=x
                   end
                  end;
    f_GetDeri:    begin
		               for i:=0 to xc-1 do begin
		                 x:=0;
		                 for j:=0 to xc-1 do x:=x+A_.val(j,i)*Xdif[j];
                     Fdif[i]:=x
		               end;
          		     for i:=0 to xc-1 do begin
                     x:=Fdif[i];
		                 for j:=0 to uc-1 do x:=x+B_.val(j,i)*U[0].arr^[j];
                     Fdif[i]:=x
                   end
                  end;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

{*******************************************************************************
                  Квадратичный функционал качества
*******************************************************************************}
constructor TFunctional.Create;
begin
  inherited;
  Ai:=TExtArray.Create(1);
end;

destructor  TFunctional.Destroy;
begin
  inherited;
  Ai.Free;
end;

function   TFunctional.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'ai') then begin
      Result:=NativeInt(Ai);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TFunctional.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetCount: begin
                  CY.arr^[0]:=1;
                  CU.arr^[0]:=Ai.Count;
                end;
    i_GetDifCount: Result:=1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TFunctional.RunFunc;
 var j: integer;
     s:   double;
begin
  Result:=0;
  case Action of
    f_InitState: begin
                   Xdif[0]:=0;
                   Y[0].arr^[0]:=0;
                 end;
    f_GetDeri:  begin
             		  s:=0;
		              for j:=0 to Ai.Count-1 do s:=s+SQR(U[0].arr^[j]*Ai.arr^[j]);
                  Fdif[0]:=s;
                end;
    f_UpdateOuts,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_GoodStep: if at > 0 then Y[0].arr^[0]:=Xdif[0]/at;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

{*******************************************************************************
                          Колебательное звено
*******************************************************************************}
constructor TKoleb.Create;
begin
  inherited;
  b:=TExtArray.Create(1);
  dx0:=TExtArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TKoleb.Destroy;
begin
  inherited;
  b.Free;
  dx0.Free;
end;

function    TKoleb.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'b') then begin
      Result:=NativeInt(b);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'dx0') then begin
      Result:=NativeInt(dx0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TKoleb.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetDifCount:  Result:=2*X0.Count;//Блок - векторный
    i_GetCount:     begin
                      cU[0]:=X0.Count;
                      cY[0]:=cU[0];
                    end;
    i_GetPropErr:   begin
                      if (k.Count < X0.Count) or (dx0.Count < X0.Count) or (T.Count < X0.Count) or (b.Count < X0.Count) then begin
                        ErrorEvent(txtArrLessX0,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                      for i:=0 to X0.Count-1 do if T[i] <= 0 then begin
                        ErrorEvent(txtTimeEqZero,msWarning,VisualObject);
                        exit;
                      end
                    end;


  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TKoleb.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitState:  begin
                    for i:=0 to X0.Count - 1 do begin
                      Y[0][i]:=X0[i];
                      Xdif[2*i]:=X0[i];
                      Xdif[2*i + 1]:=dx0[i];
                    end;
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   for i:=0 to X0.Count - 1 do Y[0][i]:=Xdif[2*i];
    f_GetDeri:    for i:=0 to X0.Count - 1 do begin
                     if T.Arr^[i] = 0.0 then begin
                       Result:=r_Fail;
                       ErrorEvent(txtTimeEqZero+' time='+FloatToStr(at),msError,VisualObject);
                       break;
                     end;
                     Fdif[2*i + 1]:=(K.Arr^[i]*U[0].arr^[i]-2*b.Arr^[i]*T.Arr^[i]*Xdif[2*i + 1]-Xdif[2*i])/sqr(T.Arr^[i]);
                     FDif[2*i]:=Xdif[2*i + 1];
                  end
  end
end;

{*******************************************************************************
                      Инерционно-форсирующее звено
*******************************************************************************}
constructor TForceAperiodika.Create;
begin
  inherited;
  T1:=TExtArray.Create(1);
  T2:=TExtArray.Create(1);
  x0:=TExtArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TForceAperiodika.Destroy;
begin
  inherited;
  T1.Free;
  T2.Free;
  x0.Free;
end;

function    TForceAperiodika.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'t1') then begin
      Result:=NativeInt(T1);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'x0') then begin
      Result:=NativeInt(x0);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'t2') then begin
      Result:=NativeInt(T2);
      DataType:=dtDoubleArray;
    end;
  end  
end;

function    TForceAperiodika.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetInit:      Result:=0;         //Инерционно форсирующее звено зависит от входа напрямую !!!
    i_GetDifCount:  Result:=X0.Count;
    i_GetCount:     begin
                      cU[0]:=X0.Count;
                      cY[0]:=cU[0];
                    end;
    i_GetPropErr:   begin
                      if (T1.Count < X0.Count) or (T2.Count < X0.Count) then begin
                        ErrorEvent(txtT1T2LessX0,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      end;
                      for i:=0 to X0.Count-1 do if T2[i] <= 0 then begin
                        ErrorEvent(txtT2LessZero,msWarning,VisualObject);
                        exit;
                      end
                    end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TForceAperiodika.RunFunc;
 var i: integer;

 function  CheckT:boolean;
 begin
   Result:=False;
   if T2.Arr^[i] = 0 then begin
     ErrorEvent(txtT2LessZero,msError,VisualObject);
     RunFunc:=r_Fail;
     Result:=True;
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
    f_InitState:  if not NeedRemoteData then for i:=0 to X0.Count - 1 do begin
                    if CheckT then exit;
                    if T1.Arr^[i] <> T2.Arr^[i] then Xdif[i]:=x0.arr^[i]/(1-T1.Arr^[i]/T2.Arr^[i]) else Xdif[i]:=0;
                    Y[0].arr^[i]:=x0.arr^[i]+U[0].arr^[i]*T1.Arr^[i]/T2.Arr^[i];
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   if not NeedRemoteData then for i:=0 to X0.Count - 1 do begin
                    if CheckT then exit;
                    Y[0].arr^[i]:=Xdif[i]+T1.Arr^[i]*(U[0].arr^[i]-Xdif[i])/T2.Arr^[i];
                  end;
    f_GetDeri:    if not NeedRemoteData then for i:=0 to X0.Count - 1 do begin
                    if CheckT then exit;
                    Fdif[i]:=(U[0].arr^[i]-Xdif[i])/T2.Arr^[i];
                  end;
  end
end;


{*******************************************************************************
                      Инерционно-дифференцирующее звено
*******************************************************************************}

function    TDifAperiodika.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  //Result:=0; //это не нужно больше
  case Action of
    i_GetInit:      Result:=0;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TDifAperiodika.RunFunc;
 var i: integer;

 function  CheckT:boolean;
 begin
   Result:=False;
   if (T.Arr^[i] = 0) or (k.Arr^[i] = 0) then begin
     ErrorEvent(txtTKLessZero,msError,VisualObject);
     RunFunc:=r_Fail;
     Result:=True;
   end;
 end;

begin
  Result:=0;
  case Action of
    f_InitState: if not NeedRemoteData then
                   for i:=0 to X0.Count - 1 do begin
                     if CheckT then exit;
                     Xdif[i]:=-T.Arr^[i]/k.Arr^[i]*x0.arr^[i];
                     Y[0].arr^[i]:=x0.arr^[i]+U[0].arr^[i]*k.Arr^[i]/T.Arr^[i];
                   end;
    f_GetDeri:   if not NeedRemoteData then for i:=0 to X0.Count - 1 do begin
                    if CheckT then exit;
                    Fdif[i]:=(U[0].arr^[i]-Xdif[i])/T.Arr^[i];
                  end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_GoodStep,
    f_UpdateOuts: if not NeedRemoteData then
                    for i:=0 to X0.Count - 1 do begin
                      if CheckT then exit;
                      Y[0].arr^[i]:=k.Arr^[i]*(U[0].arr^[i]-Xdif[i])/T.Arr^[i];
                    end;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

{*******************************************************************************
                     Инерционно-интегрирующее звено
*******************************************************************************}
constructor TIntergAperiodika.Create;
begin
  inherited;
  dx0:=TExtArray.Create(1);
end;

destructor  TIntergAperiodika.Destroy;
begin
  inherited;
  dx0.Free;
end;

function   TIntergAperiodika.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'dx0') then begin
      Result:=NativeInt(dx0);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TIntergAperiodika.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
var i : Integer;
begin
  Result:=0;
  case Action of
    i_GetDifCount:  Result:=2*X0.Count;//Блок - векторный
    i_GetPropErr:   begin
                     if (k.Count < X0.Count) or (T.Count < X0.Count) or (dx0.Count < X0.Count) then begin
                       ErrorEvent(txtArrLessX0,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     for i:=0 to X0.Count-1 do if T[i] <= 0 then begin
                       ErrorEvent(txtTimeEqZero,msWarning,VisualObject);
                       exit;
                     end
                    end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TIntergAperiodika.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitState: if not NeedRemoteData then
                   for i:=0 to X0.Count - 1 do begin
             		     Xdif[2*i]:=x0.arr^[i];
		                 Xdif[2*i + 1]:=dx0.arr^[i];
		                 Y[0].arr^[i]:=Xdif[2*i];
                   end;
    f_UpdateJacoby,
    f_RestoreOuts,
    f_UpdateOuts,
    f_GoodStep:   if not NeedRemoteData then
                     for i:=0 to X0.Count - 1 do Y[0][i]:=Xdif[2*i];
    f_GetDeri:  if not NeedRemoteData then
                  for i:=0 to X0.Count - 1 do begin
                    if T.Arr^[i] = 0.0 then begin
                      Result:=r_Fail;
                      ErrorEvent(txtTimeEqZero,msError,VisualObject);
                      break;
                    end;
		                Fdif[2*i + 1]:=(K.Arr^[i]*U[0].arr^[i]-Xdif[2*i + 1])/T.Arr^[i];
		                Fdif[2*i]:=Xdif[2*i + 1];
		              end;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

{*******************************************************************************
                     ИНТЕГРАТОР с ограничением
*******************************************************************************}
constructor TLimitIntegrator.Create;
begin
  inherited;
  ymin:=TExtArray.Create(1);
  ymax:=TExtArray.Create(1);
  IsLinearBlock:=False;
end;

destructor  TLimitIntegrator.Destroy;
begin
  inherited;
  ymin.Free;
  ymax.Free;
end;

function    TLimitIntegrator.GetParamID;
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
    end;
  end
end;

function    TLimitIntegrator.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetPropErr:   if (k.Count < X0.Count) or (ymin.Count < X0.Count) or (ymax.Count < X0.Count) then begin
                      ErrorEvent(txtArrLessX0,msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                    end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TLimitIntegrator.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState:  if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
		                Xdif[i]:=x0.arr^[i];
		                Y[0].arr^[i]:=Xdif[i]
		              end;
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts: if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
		                Y[0].arr^[i]:=Xdif[i];
		                if (Xdif[i] >= Ymax.arr^[i]) then Y[0].arr^[i]:=Ymax.arr^[i];
		                if (Xdif[i] <= Ymin.arr^[i]) then Y[0].arr^[i]:=Ymin.arr^[i]
		              end;
    f_GoodStep:   if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
     		            if (Xdif[i] >= Ymax.arr^[i]) then Xdif[i]:=Ymax.arr^[i];
	 	                if (Xdif[i] <= Ymin.arr^[i]) then Xdif[i]:=Ymin.arr^[i];
       		          Y[0].arr^[i]:=Xdif[i];
	 	              end;
    f_GetDeri:    if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
		                Fdif[i]:=K.arr^[i]*U[0].arr^[i];
		                if ((Xdif[i] >= Ymax.arr^[i]) and (Fdif[i] > 0)) or
                       ((Xdif[i] <= Ymin.arr^[i]) and (Fdif[i] < 0)) then Fdif[i]:=0
		              end;
  end
end;


{*******************************************************************************
                     ИНТЕГРАТОР с ограничением
*******************************************************************************}

function    TVarIntegrator.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'resettype') then begin
      Result:=NativeInt(@resettype);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'maxflag') then begin
      Result:=NativeInt(@maxflag);
      DataType:=dtDouble;
      exit;
    end;
  end
end;

function    TVarIntegrator.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetCount:       begin
		                    CY.arr^[0]:=CU.arr^[0];
                        CU.arr^[2]:=CU.arr^[0];
                        CU.arr^[1]:=CU.arr^[0];
                      end;
    i_GetInit:        Result:=resettype;
    i_GetDifCount:    Result:=CU.arr^[0];
    i_GetPostSection: Result:=resettype;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TVarIntegrator.RunFunc;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects:if NeedRemoteData then
                     if RemoteDataUnit <> nil then begin
                       RemoteDataUnit.AddVectorToList(GetPortName(0),Y[0]);
                     end;
    f_InitState:  if not NeedRemoteData then
                    for j:=0 to CU.arr^[0]-1 do begin
                      Xdif[j]:=U[2].arr^[j];
		                  Y[0].arr^[j]:=Xdif[j];
                    end;
    f_GoodStep:   if not NeedRemoteData then
                    for j:=0 to CU.arr^[0]-1 do begin
                      if (resettype = 0) and (U[1].arr^[j] >= maxflag) then Xdif[j]:=U[2].arr^[j];
                      Y[0].arr^[j]:=Xdif[j];
                    end;
    f_UpdateJacoby,
    f_UpdateOuts: if not NeedRemoteData then
                     for j:=0 to CU.arr^[0]-1 do begin
                       if (resettype = 0) and (U[1].arr^[j] >= maxflag) then
                          Y[0].arr^[j]:=U[2].arr^[j]       //Сброс
                       else
                          Y[0].arr^[j]:=Xdif[j];           //Обычное состояние
                     end;
    f_GetDeri:    if not NeedRemoteData then
                     for j:=0 to CU.arr^[0]-1 do begin
                        Fdif[j]:=U[0].arr^[j];
                        //Это надо делать, т.к. если блок сброшен, то на его выходе константа на первом шаге !
                        //Иначе неявные методы не обрабатывают разрывы функций переменных состояния
		                    if (U[1].arr^[j] >= maxflag) then Fdif[j]:=0
                     end;
  end
end;

function       TVarIntegrator.PostFunc(var at,h : RealType;Action:Integer):NativeInt;
 var j: integer;
begin
  Result:=0;
  case Action of
    f_GoodStep:   if (not NeedRemoteData) and (resettype = 1) then
                    for j:=0 to CU.arr^[0]-1 do
                      if (U[1].arr^[j] >= maxflag) then Xdif[j]:=U[2].arr^[j];
  end
end;

{*******************************************************************************
                    Передаточная функция общего вида
*******************************************************************************}
constructor TWs.Create;
begin
  inherited;
  a:=TExtArray2.Create(1,1);
  b:=TExtArray2.Create(1,1);
  y0:=TExtArray2.Create(1,1);
  IsLinearBlock:=True;
end;

destructor  TWs.Destroy;
begin
  inherited;
  a.Free;
  b.Free;
  y0.Free;
end;

function    TWs.GetParamID;
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

function    TWs.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
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
    i_GetDifCount:    begin
                        Result:=0;
                        for i:=0 to y0.CountX - 1 do Result:=Result + (a[i].Count - 1);
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
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TWs.RunFunc;
 var i:   integer;
     x:   double;
     j,c: integer;
begin
  Result:=0;
  case Action of
    f_InitState: begin
                   c:=0;
                   for j:=0 to y0.CountX - 1 do begin

                     for i:=1 to a[j].count-2 do Xdif[c + i]:=0;
                     i:=a[j].count-1;

                     if (Y0[j].arr^[0]=0.0) or (b[j].arr^[0]=0.0) or
                       (b[j].arr^[0]-a[j].arr^[0]*b[j].arr^[i]/a[j].arr^[i] = 0.0) then Xdif[c]:=0.0
                     else if b[j].count = a[j].count then
                       Xdif[c]:=Y0[j].arr^[0]/(b[j].arr^[0]-a[j].arr^[0]*b[j].arr^[i]/a[j].arr^[i])
                     else Xdif[c]:=Y0[j].arr^[0]/b[j].arr^[0];

                     if b[j].count = a[j].count then
                       Y[0].arr^[j]:=Y0[j].arr^[0]+U[0].arr^[j]*b[j].arr^[i]/a[j].arr^[i]
                     else
                       Y[0].arr^[j]:=Y0[j].arr^[0];

                     //Новое смещение в массиве динамических переменных
                     c:=c + a[j].Count - 1;
                   end;
                 end;
 f_GoodStep,
 f_RestoreOuts,
 f_UpdateJacoby,
 f_UpdateOuts :   begin
                   c:=0;
                   for j:=0 to y0.CountX - 1 do begin
                     x:=0;
                     for i:=0 to b[j].count-2 do x:=x+b[j].arr^[i]*Xdif[c + i];

                     if b[j].count < a[j].count then
                      Y[0].arr^[j]:=x+b[j].arr^[b[j].count-1]*Xdif[c + b[j].count-1]
                     else begin
                      Y[0].arr^[j]:=x;
                      x:=U[0].arr^[j];
                      for i:=0 to a[j].count-2 do x:=x-a[j].arr^[i]*Xdif[c + i];
                      x:=x/a[j].arr^[a[j].count-1];
                      Y[0].arr^[j]:=Y[0].arr^[j]+b[j].arr^[b[j].count-1]*x
                     end;

                     c:=c + a[j].Count - 1;
                   end
                  end;
 f_GetDeri    :   begin
                   c:=0;
                   for j:=0 to y0.CountX - 1 do begin

                     for i:=0 to a[j].count-3 do Fdif[c + i]:=Xdif[c + i + 1];
                       Fdif[c + a[j].count-2]:=U[0].arr^[j];
                     for i:=0 to a[j].count-2 do
                       Fdif[c + a[j].count-2]:=Fdif[c + a[j].count-2]-a[j].arr^[i]*Xdif[c + i];
                     Fdif[c + a[j].count-2]:=Fdif[c + a[j].count-2]/a[j].arr^[a[j].count-1];

                     c:=c + a[j].Count - 1;
                   end
                  end;
  end
end;

{*******************************************************************************
                    Уточнение переходов
*******************************************************************************}
constructor TCrossZero.Create;
begin
  inherited;
  x:=TExtArray.Create(0);
  c:=TExtArray.Create(0);
  d:=TExtArray.Create(0);
  dtol:=TExtArray.Create(0);
end;

destructor  TCrossZero.Destroy;
begin
  inherited;
  x.Free;
  c.Free;
  d.Free;
  dtol.Free;
end;

function    TCrossZero.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'c') then begin
      Result:=NativeInt(c);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'d') then begin
      Result:=NativeInt(d);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'dtol') then begin
      Result:=NativeInt(dtol);
      DataType:=dtDoubleArray;
    end;
  end
end;

function    TCrossZero.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetPropErr:     if (d.Count <> dtol.Count) or (c.Count <> dtol.Count) then begin
                        ErrorEvent(txtArraysCountNotEqu,msError,VisualObject);
                        Result:=r_Fail;
                      end;
    i_GetCount:       begin
                        CU.arr^[0]:=dtol.Count;
                        CY.arr^[0]:=CU.arr^[0]
                      end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TCrossZero.RunFunc;
 var i:   integer;
     dt,xi,di,v,h1  : double;
begin
  Result:=0;
  case Action of
    f_InitObjects:x.ChangeCount(dtol.Count);
    f_InitState:  for i:=0 to dtol.Count-1 do begin
                      x.Arr^[i]:=U[0].Arr^[i] - c.Arr^[i];
        	            Y[0].Arr^[i]:=0;
      		        end;
    f_GetDeri,
    f_RestoreOuts,
    f_GoodStep,
    f_UpdateJacoby,
    f_UpdateOuts:for i:=0 to dtol.Count - 1 do begin
                    //Точность отработки переходов по времени может быть установлена индивидуально !!!
                    dt:=ModelODEVars.Hmin;
                    if dt < dtol.Arr^[i] then dt:=dtol.Arr^[i];
                    xi:=x.Arr^[i];
                    di:=d.Arr^[i];
                    v:=U[0].Arr^[i] - c.Arr^[i];
                    Y[0].Arr^[i]:=0;
                    if Action = f_GoodStep then begin
                       //пересечение
                      if (xi*v<=0) and (xi<>0) and (di*xi<=0) then
                         Y[0].Arr^[i]:=1
                      else
                         if ((xi*v>0) and ((di*xi<0) or (di=0)) ) and (abs(xi)>abs(v)) then begin
                            //прогноз длины следующего шага
                            h1:=h*v/(xi-v);
                            if h1<3*dt then
                               h1:=h1+dt/2
                            else
                               if h1>4*dt then
                                 h1:=h1-dt/2
                               else
                                 h1:=3.5*dt;
                            if h1 < dt then h1:=dt;
                            //Собственно принудительное присвоение шага интегрирования
                            if h1 < ModelODEVars.newstep then begin
                               ModelODEVars.newstep:=h1;
                               ModelODEVars.fsetstep:=True;
                            end
                         end;
                         x.Arr^[i]:=v;
                    end
                    //else
                    //  if (xi*v <= 0) and (xi <> 0) and (di*xi <= 0) and (h > 8*dt) then
                    //    Result:=er_AccuracyError;
                  end;
  end
end;

{*******************************************************************************
                    Указатель сходимости
*******************************************************************************}
constructor TTolPointer.Create;
begin
  inherited;
  a:=TExtArray.Create(1);
  old_u:=TExtArray.Create(1);
  out_type:=0;
end;

destructor  TTolPointer.Destroy;
begin
  inherited;
  a.Free;
  old_u.Free;
end;

function    TTolPointer.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'old_u') then begin
      Result:=NativeInt(old_u);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'out_type') then begin
      Result:=NativeInt(@out_type);
      DataType:=dtInteger;
    end
  end
end;

function    TTolPointer.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
begin
  Result:=0;
  case Action of
    i_GetInit:        Result:=1;
    i_GetCount:       cY[0]:=cU[0];
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TTolPointer.RunFunc;
 var i:   integer;
     max_tol  : double;
begin
  Result:=0;
  case Action of
    f_InitObjects:old_u.Count:=cU[0];
    f_InitState:  begin
                    if out_type = 1 then
                      Y[0].FillArray(0)
                    else
                      Move(old_u.Arr^,Y[0].Arr^,cU[0]*SizeOfDouble);
                  end;
//    f_UpdateJacoby,
    f_UpdateOuts:for i:=0 to cU[0] - 1 do begin
                   max_tol:=0;
                   if i < a.Count then max_tol:=a.Arr^[i];
                   if abs(U[0].Arr^[i] - Y[0].Arr^[i]) > max_tol then
                      ModelODEVars.fNeedIter:=True;
                   //Что выдаём на выход = значение входа или невязку
                   if out_type = 1 then
                     Y[0].Arr^[i]:=U[0].Arr^[i] - old_u.Arr^[i]
                   else
                     Y[0].Arr^[i]:=U[0].Arr^[i];
                   //Запоминание выхода
                   old_u.Arr^[i]:=U[0].Arr^[i];
                 end;
  end
end;

  //Интегратор с ограничением и сбросом начальных условий
function    TResetLimitIntegrator.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'resettype') then begin
      Result:=NativeInt(@resettype);
      DataType:=dtInteger;
    end;
  end
end;

function    TResetLimitIntegrator.InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:       begin
                        Result:=inherited InfoFunc(Action,aParameter);
                        for I := 1 to cU.Count - 1 do cU[i]:=cU[0];
                      end;
    i_GetInit:        Result:=resettype;            //Сбросной вход для этого блока - мгновенный !!!
    i_GetPostSection: Result:=resettype;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end
end;

function   TResetLimitIntegrator.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitState:  if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
                    if cU.Count > 2 then
		                  Xdif[i]:=U[2].Arr^[i]
                    else
                      Xdif[i]:=x0.arr^[i];
		                Y[0].arr^[i]:=Xdif[i]
		              end;
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts: if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
		                Y[0].arr^[i]:=Xdif[i];
                    if resettype = 0 then begin
   		                if (Xdif[i] >= Ymax.arr^[i]) then Y[0].arr^[i]:=Ymax.arr^[i];
	  	                if (Xdif[i] <= Ymin.arr^[i]) then Y[0].arr^[i]:=Ymin.arr^[i];
                      if U[1].Arr^[i] > 0.5 then
                        if cU.Count > 2 then
                          Y[0].arr^[i]:=U[2].Arr^[i]
                        else
                          Y[0].arr^[i]:=x0.arr^[i];
                    end;
		              end;
    f_GoodStep:   if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
                    if resettype = 0 then begin
       		            if (Xdif[i] >= Ymax.arr^[i]) then Xdif[i]:=Ymax.arr^[i];
   	 	                if (Xdif[i] <= Ymin.arr^[i]) then Xdif[i]:=Ymin.arr^[i];
                      if U[1].Arr^[i] > 0.5 then
                        if cU.Count > 2 then
                          Xdif[i]:=U[2].Arr^[i]
                        else
                          Xdif[i]:=x0.arr^[i];
                    end;
       		          Y[0].arr^[i]:=Xdif[i];
	 	              end;
    f_GetDeri:    if not NeedRemoteData then for i:=0 to X0.Count-1 do begin
		                Fdif[i]:=K.arr^[i]*U[0].arr^[i];
                    //Это надо делать, т.к. если блок сброшен, то на его выходе константа на первом шаге !
		                if  (U[1].Arr^[i] > 0.5) or
                        ((Xdif[i] >= Ymax.arr^[i]) and (Fdif[i] > 0)) or
                        ((Xdif[i] <= Ymin.arr^[i]) and (Fdif[i] < 0)) then
                          Fdif[i]:=0
		              end;
  else
    Result:=inherited RunFunc(at,h,Action);
  end
end;

function     TResetLimitIntegrator.PostFunc(var at,h : RealType;Action:Integer):NativeInt;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_GoodStep:   if (not NeedRemoteData) and (resettype = 1) then
                    for i:=0 to X0.Count-1 do begin
       		            if (Xdif[i] >= Ymax.arr^[i]) then Xdif[i]:=Ymax.arr^[i];
   	 	                if (Xdif[i] <= Ymin.arr^[i]) then Xdif[i]:=Ymin.arr^[i];
                      if U[1].Arr^[i] > 0.5 then
                        if cU.Count > 2 then
                          Xdif[i]:=U[2].Arr^[i]
                        else
                          Xdif[i]:=x0.arr^[i];
	 	                end;
  end;
end;



end.
