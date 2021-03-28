
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//
 
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Vectors;

 //***************************************************************************//
 //                Блоки выполняющие векторные операции                       //
 //***************************************************************************//

interface

uses {$IFNDEF FPC}Windows,{$ENDIF}
     Classes, MBTYArrays, DataTypes, DataObjts, SysUtils, abstract_im_interface, RunObjts, Math, LinFuncs,
     InterpolFuncs, mbty_std_consts, uExtMath;

type

  //Блок - мультиплексор
  //Выполняет объединение нескольких входов в один векторный выход
  TMultiplexor = class(TRunObject)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Блок - демультиплексор
  //Выполняет разделение одного векторного входа в несколько выходов
  TDemultiplexor = class(TRunObject)
  protected
    a:             TIntArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок - распаковка матрицы
  //Выполняем извлечение из матрицы строк или столбцов
  TUnpackMatrix = class(TRunObject)
  protected
    n:             NativeInt;    //К-во строк
    m:             NativeInt;    //К-во столбцов
    tx:            NativeInt;    //Тип преобразования
    ty:            NativeInt;    //Тип упаковки/распаковки - 0 - по строкам, 1 - по столбцам
    porttype:      NativeInt;    //Тип порта блока (скрытое свойство)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure      EditFunc(Props:TList;
                            SetPortCount:TSetPortCount;
                            SetCondPortCount:TSetCondPortCount;
                            ExecutePropScript:TExecutePropScript
                            );override;
  end;

  //Блок - запаковка матрицы
  //Выполняем запаковку строк или столбцов в матрицу
  TPackMatrix = class(TUnPackMatrix)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    procedure      EditFunc(Props:TList;
                            SetPortCount:TSetPortCount;
                            SetCondPortCount:TSetCondPortCount;
                            ExecutePropScript:TExecutePropScript
                            );override;
  end;

  //Блок выборки значений из векторного сигнала
  TSelectVector = class(TRunObject)
  protected
    tsel:          NativeInt;
    nsel:          TIntArray;
    n:             NativeInt;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок - решатель системы линейных алгебраических уравнений
  TLAE = class(TRunObject)
  protected
    Count:         integer;
    A_:            TExtArray2;
    A:             TExtArray2;
    B:             TExtArray;
    Idn:           TIntArray;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок - умножение матрицы на вектор
  TMatrixMul = class(TRunObject)
  protected
    Count:         integer;
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Блок - транспонирование матрицы
  TTransponse = class(TMatrixMul)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Блок - интерполяция (по Лагранжу или сплайновая с произвольным порядком)
  TInterp = class(TRunObject)
  protected
    SplineArr:     TExtArray2;
    Ind:           array of NativeInt;
    x_tab:         TExtArray2; //Массивы изходных данных
    y_tab:         TExtArray2;
  public
    Met,                       //Переменные, доступные извне
    Order,
    N,
    M,
    Nfun:          NativeInt;
    SplineIsNatural:Boolean;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

  //Блок - МНК аппроксимация функции
  TMNK = class(TRunObject)
  protected
    mma:           integer;    //Размерность вектора к-в
    formfun:       TApproxFunc;//Текущая функция формы для аппроксимации
    a:             TExtArray;  //Вектор к-в аппроксимирующей функции
    u_:            TExtArray2; //результаты SVD-преобразования, матрица U
    v:             TExtArray2; //                матрица V
    w:             TExtArray;  //-                вектор диагональных элементов
    b:             TExtArray;
    afunc:         TExtArray;  // служебные массивы
    x_tab:         TExtArray2; //Массивы изходных данных
    y_tab:         TExtArray2;
  public
    fmType,
    Order,
    N,
    Nfun:          NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
  end;

implementation

{*******************************************************************************
                          Векторный усилитель
*******************************************************************************}

function    TMultiplexor.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   //Размерность выхода = сумма размерностей входов
                   cY[0]:=0;
                   for i:=0 to cU.Count - 1 do cY[0]:=cY[0] + cU[i];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TMultiplexor.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  begin
                   c:=0;
                   for i:=0 to cU.Count - 1 do
                     for j:=0 to U[i].Count - 1 do
                       begin
                         Y[0].Arr^[c]:=U[i].Arr^[j];
                         inc(c);
                       end;
                 end;
  end
end;

{*******************************************************************************
                         Демультиплексор
*******************************************************************************}

constructor TDemultiplexor.Create;
begin
  inherited;
  a:=TIntArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TDemultiplexor.Destroy;
begin
  inherited;
  a.Free;
end;

function    TDemultiplexor.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'a') then begin
      Result:=NativeInt(a);
      DataType:=dtIntArray;
    end;
  end
end;

function    TDemultiplexor.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   cU[0]:=0;
                   for i:=0 to cY.Count - 1 do begin
                     cY[i]:=a[i];
                     cU[0]:=cU[0] + a[i];
                   end;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TDemultiplexor.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c : Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: begin
                  c:=0;
                  for i:=0 to cY.count - 1 do
                   for j:=0 to Y[i].Count - 1 do begin
                     Y[i].Arr^[j]:=U[0].Arr^[c];
                     inc(c);
                   end
                end
  end
end;

{*******************************************************************************
                          Распаковка матрицы
*******************************************************************************}

function    TUnpackMatrix.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                  CU.arr^[0]:=N*M;
                  for i:=0 to CY.Count-1 do
                   if tY = 0 then CY.arr^[i]:=M else CY.arr^[i]:=N;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TUnpackMatrix.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  if (tX = 0) then begin
                   if tY = 0 then
                     for i:=0 to cY.Count-1 do
   		                 for j:=0 to Y[i].Count-1 do
                         Y[i].arr^[j]:=U[0].arr^[M*i+j]
                   else
                     for i:=0 to cY.Count-1 do
      		             for j:=0 to Y[i].Count-1 do
                         Y[i].arr^[j]:=U[0].arr^[i+M*j]
                 end
                 else begin
                   if tY = 1 then
                     for i:=0 to cY.Count-1 do
		                   for j:=0 to Y[i].Count-1 do
		                      Y[i].arr^[j]:=U[0].arr^[N*i+j]
                   else
                     for i:=0 to cY.Count-1 do
		                   for j:=0 to Y[i].Count-1 do
                          Y[i].arr^[j]:=U[0].arr^[i+N*j]
                 end;

  end
end;

function  TUnpackMatrix.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if StrEqu(ParamName,'nrow') then begin
    Result:=NativeInt(@n);
    DataType:=dtInteger;
  end;
  if StrEqu(ParamName,'ncol') then begin
    Result:=NativeInt(@m);
    DataType:=dtInteger;
  end;
  if StrEqu(ParamName,'tx') then begin
    Result:=NativeInt(@tx);
    DataType:=dtInteger;
  end;
  if StrEqu(ParamName,'ty') then begin
    Result:=NativeInt(@ty);
    DataType:=dtInteger;
  end;
  if StrEqu(ParamName,'porttype') then begin
    Result:=NativeInt(@porttype);
    DataType:=dtInteger;
  end;
end;

procedure TUnpackMatrix.EditFunc;
begin
  case ty of
    0: SetCondPortCount(VisualObject,n,pmOutput,porttype,sdRight,'outport');
    1: SetCondPortCount(VisualObject,m,pmOutput,porttype,sdRight,'outport');
  end;
end;

{*******************************************************************************
                          Распаковка матрицы
*******************************************************************************}

function    TPackMatrix.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                  CY.arr^[0]:=N*M;
                  for i:=0 to CU.Count-1 do
                    if tY = 0 then CU.arr^[i]:=M else CU.arr^[i]:=N;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TPackMatrix.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j: Integer;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep:  if (tX = 0) then begin
                   if tY = 0 then
                     for i:=0 to cU.Count-1 do
   		                 for j:=0 to U[i].Count-1 do
                         Y[0].arr^[M*i+j]:=U[i].arr^[j]
                   else
                     for i:=0 to cU.Count-1 do
      		             for j:=0 to U[i].Count-1 do
                         Y[0].arr^[i+M*j]:=U[i].arr^[j];
                 end
                 else begin
                   if tY = 1 then
                     for i:=0 to cU.Count-1 do
		                   for j:=0 to U[i].Count-1 do
		                     Y[0].arr^[N*i+j]:=U[i].arr^[j]
                   else
                     for i:=0 to cU.Count-1 do
		                   for j:=0 to U[i].Count-1 do
                         Y[0].arr^[i+N*j]:=U[i].arr^[j];
                 end;

  end
end;

procedure TPackMatrix.EditFunc;
begin
  case ty of
    0: SetCondPortCount(VisualObject,n,pmInput,porttype,sdLeft,'inport');
    1: SetCondPortCount(VisualObject,m,pmInput,porttype,sdLeft,'inport');
  end;
end;

{*******************************************************************************
                         Выборка из вектора
*******************************************************************************}

constructor TSelectVector.Create;
begin
  inherited;
  nsel:=TIntArray.Create(1);
  IsLinearBlock:=True;
end;

destructor  TSelectVector.Destroy;
begin
  inherited;
  nsel.Free;
end;

function    TSelectVector.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'nsel') then begin
      Result:=NativeInt(nsel);
      DataType:=dtIntArray;
    end;
    if StrEqu(ParamName,'n') then begin
      Result:=NativeInt(@n);
      DataType:=dtInteger;
    end;
    if StrEqu(ParamName,'tsel') then begin
      Result:=NativeInt(@tsel);
      DataType:=dtInteger;
    end;
  end;
end;

function    TSelectVector.InfoFunc;
 var i,k: integer;
begin
  Result:=0;
  case Action of
    i_GetCount:   case tSel of
                   0:begin
                      k:=0;
                      for i:=0 to nSel.Count-1 do k:=max(k,nSel.arr^[i]);
                      if CU.arr^[0] < k then CU.arr^[0]:=k;
                      CY.arr^[0]:=nSel.Count
                     end;
                   1:CY.arr^[0]:=CU.arr^[0] div 2;
                   2:begin
                      if (CU.arr^[0] mod 2) = 0 then k:=0 else k:=1;
                      CY.arr^[0]:=CU.arr^[0] div 2+k
                     end;
                   3,4:begin
                      if CU.arr^[0] < N then CU.arr^[0]:=N;
                      CY.arr^[0]:=N
                     end;
                   5:begin
                      if (CU.arr^[0] mod N) = 0 then k:=0 else k:=1;
                      CY.arr^[0]:=CU.arr^[0] div N+k;
                     end;
                   6,7,8:CY.arr^[0]:=CU.arr^[0];
		end;

  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TSelectVector.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,k : Integer;
    P:    Pointer;
    x:    RealType;
begin
  Result:=0;
  case Action of
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: case tSel of
                 0:for i:=0 to nSel.Count-1 do
                    Y[0].arr^[i]:=U[0].arr^[nSel.arr^[i]-1];
                 1:begin
                    k:=1;
                    for i:=0 to Y[0].Count-1 do begin
                     Y[0].arr^[i]:=U[0].arr^[k];
                     Inc(k,2)
                    end
                   end;
                 2:begin
                    k:=0;
                    for i:=0 to Y[0].Count-1 do begin
                     Y[0].arr^[i]:=U[0].arr^[k];
                     Inc(k,2)
                    end
                   end;
                 3:Move(U[0].arr^,Y[0].arr^,N*SOfR);
                 4:begin
                    p:=@U[0].arr^[U[0].Count-N];
                    Move(p^,Y[0].arr^,N*SOfR)
                   end;
                 5:begin
                    k:=0;
                    for i:=0 to Y[0].Count-1 do begin
                     Y[0].arr^[i]:=U[0].arr^[k];
                     Inc(k,N)
                    end
                   end;
                 6:for i:=0 to Y[0].Count-1 do
                     Y[0].arr^[i]:=U[0].arr^[U[0].Count-i-1];
                 7:begin
                    Move(U[0].arr^,Y[0].arr^,U[0].Count*SOfR);
                    rQuickSort(Y[0].arr^,0,Y[0].Count-1);
                   end;
                 8:begin
                    Move(U[0].arr^,Y[0].arr^,U[0].Count*SOfR);
                    rQuickSort(Y[0].arr^,0,Y[0].Count-1);
                    for i:=0 to Y[0].Count div 2-1 do begin
                     x:=Y[0].arr^[Y[0].Count-i-1];
                     Y[0].arr^[Y[0].Count-i-1]:=Y[0].arr^[i];
                     Y[0].arr^[i]:=x
                    end
                   end;
		end;
  end
end;

{*******************************************************************************
               Решение системы линейных алгебраических уравнений
*******************************************************************************}

constructor TLAE.Create;
begin
  inherited;
  Idn:=TIntArray.Create(1);
  A:=TExtArray2.Create(1,1);
  A_:=TExtArray2.Create(1,1);
  B:=TExtArray.Create(1);
end;

destructor  TLAE.Destroy;
begin
  inherited;
  Idn.Free;
  A.Free;
  B.Free;
  A_.Free;
end;


function    TLAE.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                  Count:=CU.arr^[1];
                  CU.arr^[0]:=Count*Count;
                  CY.arr^[0]:=Count;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TLAE.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c : Integer;
    fLU:    boolean;
    d:      double;
begin
  Result:=0;
  case Action of
  f_InitObjects: begin
                   //Инициализация матриц и массивов
                   A.ChangeCount(Count,Count);
                   A_.ChangeCount(Count,Count);
                   B.ChangeCount(Count);
                   Idn.ChangeCount(Count)
                 end;
  f_InitState,
  f_UpdateJacoby,
  f_RestoreOuts,
  f_UpdateOuts,
  f_GoodStep : begin
                fLU:=false;
                //Проверяем изменилась ли матрица и определяем необходимость нового LU-разложения
                c:=0;
                for i:=0 to A_.CountX - 1 do
                  for j:=0 to A_.Arr^[i].Count - 1 do begin
                    fLU:=fLU or (A_.Arr^[i].Arr^[j] <> U[0].Arr^[c]);
                    A_.Arr^[i].Arr^[j]:=U[0].Arr^[c];
                    inc(c);
                  end;
                //Если матрица изменилась, то делаём LU-декомпозицию
                if fLU then begin
                  //Перенос входной матрицы во внутреннюю (переупорядочиваемую)
                  for i:=0 to A_.CountX - 1 do
                    for j:=0 to A_.Arr^[i].Count - 1 do
                      A.Arr^[i].Arr^[j]:= A_.Arr^[i].Arr^[j];
                  //Примечание ! После прогона этой функции матрица A переупорядочивается !!!
                  Result:=ludcmp(A.arr,A.CountX,idn.arr,d,B.Arr);
                  if Result > 0 then exit;
                end;
                //После вычисления матрицы - делаем обратный ход
                Move(U[1].arr^,Y[0].arr^,Count*SOfR);
                lubksb(a.arr,Count,idn.arr,Y[0].Arr);
               end;

  end
end;

{*******************************************************************************
                         Умножение матрицы на вектор
*******************************************************************************}
function    TMatrixMul.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   Count:=CU.arr^[1];
                   CY.arr^[0]:=Count;
                   CU.arr^[0]:=Count*Count;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TMatrixMul.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
    sum : Double;
begin
  Result:=0;
  case Action of
  f_InitState,
  f_UpdateJacoby,
  f_RestoreOuts,
  f_UpdateOuts,
  f_GoodStep : for i:=0 to Count - 1 do begin
                 sum:=0;
                 for j:=0 to Count - 1 do sum:=sum + U[0].arr^[i*Count+j]*U[1].arr^[j];
                 Y[0].arr^[i]:=sum;
               end;
  end
end;

{*******************************************************************************
                         Транспонирование матрицы
*******************************************************************************}

function    TTransponse.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   CY.arr^[0]:=CU.arr^[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TTransponse.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j : Integer;
begin
  Result:=0;
  case Action of
  f_InitObjects: begin
                   //Размерность = корень от размерности вх. вектора
                   Count:=trunc(sqrt(CU.arr^[0]) + 0.5);
                   //Проверка на корректность расчёта размерности
                   if Count*Count > CU.arr^[0] then begin
                     Self.ErrorEvent(txtInputMatrixError,msError,VisualObject);
                     Result:=r_Fail;
                   end;
                 end;
  f_InitState,
  f_UpdateJacoby,
  f_RestoreOuts,
  f_UpdateOuts,
  f_GoodStep : for i:=0 to Count - 1 do
                 for j:=0 to Count - 1 do
                   Y[0].arr^[i*Count + j]:=U[0].arr^[j*Count + i];
  end
end;

{*******************************************************************************
                            Интерполяция
*******************************************************************************}

constructor TInterp.Create;
begin
  inherited;
  SplineArr:=TExtArray2.Create(1,1);
  x_tab:=TExtArray2.Create(1,1);
  y_tab:=TExtArray2.Create(1,1);
  SplineIsNatural:=True;
end;

destructor  TInterp.Destroy;
begin
  inherited;
  SplineArr.Free;
  x_tab.Free;
  y_tab.Free;
end;

function    TInterp.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'met') then begin
      Result:=NativeInt(@met);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'m') then begin
      Result:=NativeInt(@m);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'n') then begin
      Result:=NativeInt(@n);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'nfun') then begin
      Result:=NativeInt(@nfun);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'order') then begin
      Result:=NativeInt(@order);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'isnatural') then begin
      Result:=NativeInt(@SplineIsNatural);
      DataType:=dtBool;
    end
  end
end;

function    TInterp.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   CU.arr^[0]:=N;
                   CU.arr^[1]:=N*Nfun;
                   CY.arr^[0]:=CU.arr^[2]*Nfun;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function   TInterp.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c   : Integer;
    py      : PExtArr;
    px      : PExtArr;

 function  CheckChanges:boolean;
  var j: integer;
 begin
   Result:=False;
   for j:=0 to N - 1 do
     if (x_tab[i].Arr^[j] <> px[j]) or (y_tab[i].Arr^[j] <> py[j]) then begin
       x_tab[i].Arr^[j]:=px[j];
       y_tab[i].Arr^[j]:=py[j];
       Result:=True;
     end;
 end;

begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Здесь устанавливаем нужные размерности вспомогательных
                     SetLength(Ind,cU[2]);
                     ZeroMemory(Pointer(Ind),cU[2]);
                     SplineArr.ChangeCount(5,N);
                     x_tab.ChangeCount(Nfun,N);
                     y_tab.ChangeCount(Nfun,N);
                   end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: begin
                  px:=U[0].Arr;
                  py:=U[1].arr;
                  c:=0;
                  for i:=0 to Nfun - 1 do begin
                   case Met of
                   0: for j:=0 to U[2].Count - 1 do begin
                         Y[0].arr^[i*U[2].Count+j]:=Lagrange(px^,py^,U[2].arr^[j],Order,M);
                         inc(c);
                      end;
                   1: begin
                       //Вычисление натурального кубического сплайна
                       if CheckChanges or (Action = f_InitState) then NaturalSplineCalc(px,py,SplineArr.Arr,N,SplineIsNatural);
                       for j:=0 to U[2].Count - 1 do begin
                         Y[0].arr^[c] :=Interpol(U[2].Arr^[j],SplineArr.Arr,5,Ind[j]);
                         inc(c);
                       end
                      end;
                   2: begin
                       if CheckChanges or (Action = f_InitState) then LInterpCalc(px,py,SplineArr.Arr,N);
                       for j:=0 to U[2].Count - 1 do begin
                         Y[0].arr^[c] :=Interpol(U[2].Arr^[j],SplineArr.Arr,3,Ind[j]);
                         inc(c);
                       end
                      end;
                   end;
                   py:=@py^[N];

		              end
                 end;
  end
end;

{*******************************************************************************
                            МНК-аппроксимация
*******************************************************************************}

constructor TMNK.Create;
begin
 inherited;
 a:=TExtArray.Create(1);
 u_:=TExtArray2.Create(1,1);
 v:=TExtArray2.Create(1,1);
 w:=TExtArray.Create(1);
 b:=TExtArray.Create(1);
 afunc:=TExtArray.Create(1);
 x_tab:=TExtArray2.Create(1,1);
 y_tab:=TExtArray2.Create(1,1);
end;

destructor  TMNK.Destroy;
begin
  inherited;
  a.Free;
  u_.Free;
  v.Free;
  w.Free;
  b.Free;
  afunc.Free;
  x_tab.Free;
  y_tab.Free;
end;

function    TMNK.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'fmtype') then begin
      Result:=NativeInt(@fmtype);
      DataType:=dtInteger;
    end;
    if StrEqu(ParamName,'n') then begin
      Result:=NativeInt(@n);
      DataType:=dtInteger;
    end;
    if StrEqu(ParamName,'nfun') then begin
      Result:=NativeInt(@nfun);
      DataType:=dtInteger;
    end;
    if StrEqu(ParamName,'order') then begin
      Result:=NativeInt(@order);
      DataType:=dtInteger;
    end;
  end
end;

function    TMNK.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetCount:  begin
                   CU.arr^[0]:=N;
                   CU.arr^[1]:=N*Nfun;
                   CY.arr^[0]:=Nfun*CU.arr^[2];
                   CY.arr^[1]:=mma*Nfun;
                 end;
    i_GetPropErr:mma:=Order + 1;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;


function   TMNK.RunFunc(var at,h : RealType;Action:Integer):NativeInt;
var i,j,c,k : Integer;
    py      : PExtArr;
    px      : PExtArr;
    xx      : double;
    yy      : double;
    p       : double;
    s       : double;
    fChange : boolean;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Здесь устанавливаем нужные размерности вспомогательных
                     a.ChangeCount(mma);
                     u_.ChangeCount(N,mma);
                     v.ChangeCount(mma,mma);
                     w.ChangeCount(mma);
                     b.ChangeCount(N);
                     afunc.ChangeCount(mma);
                     x_tab.ChangeCount(Nfun,N);
                     y_tab.ChangeCount(Nfun,N);
                   end;
    f_InitState,
    f_RestoreOuts,
    f_UpdateJacoby,
    f_UpdateOuts,
    f_GoodStep: begin
                  px:=U[0].Arr;
                  py:=U[1].arr;
                  c:=0;
                  for i:=0 to Nfun - 1 do begin

                   //Производим анализ изменений таблицы значений
                   fChange:=False;
                   for j:=0 to N - 1 do
                     if (x_tab[i].Arr^[j] <> px[j]) or (y_tab[i].Arr^[j] <> py[j]) then begin
                        x_tab[i].Arr^[j]:=px[j];
                        y_tab[i].Arr^[j]:=py[j];
                        fChange:=True;
                     end;

                   //Если изменилась таблица значений или шаг-начальный, то выполняем выч-е коэффициентов
                   if fChange or (Action = f_InitState) then begin

                     //Устанавливаем нужную функцию формы
                     formfun:=fPoly;
                     case fmtype of
                       1: formfun:=fSin;
                       2: formfun:=fPower;
                     end;

                     //Собственно вычисление коэффициентов аппроксимации a
                     //Вычисление делаем при помощи сингулярного матричного преобразования
                     //аналогично алгоритму, используемому в языке программирования
                     svdfit_even(px,py,N,formfun,a.Arr,mma,u_.Arr,v.Arr,w.Arr,b.Arr,afunc.Arr,xx);

                     //На второй выход записываем массив к-в аппроксимации функции
                     Move(a.Arr^,Y[1].Arr^[i*Nfun*mma],mma*SizeOf(double));

                   end;

                   //Выполняем вычисление функции по ранее рассчитанным коэффициентам
                   for j:=0 to U[2].Count - 1 do
                     case fmType of
                       //Вычисление полинома по схеме Горнера
                       0: begin
                            p:=1;
                            s:=0;
                            xx:=U[2].Arr^[j];
                            for k:=0 to mma - 1 do begin
                              s:=s + a.Arr^[k]*p;
                              p:=p*xx;
                            end;
                            Y[0].arr^[c]:=s;
                            inc(c);
                          end;
                       //Вычисление периодической функции
                       1: begin
                            s:=a.Arr^[0];
                            xx:=U[2].Arr^[j];
                            for k:=1 to mma - 1 do s:=s + a.Arr^[k]*sin(k*pi*xx);
                            Y[0].arr^[c]:=s;
                            inc(c);
                          end;
                       //Вычисление полинома с (1-x)
                       2: begin
                            p:=1;
                            s:=0;
                            xx:=U[2].Arr^[j];
                            yy:=(1-xx);
                            for k:=0 to mma - 1 do begin
                              s:=s + a.Arr^[k]*p*yy;
                              p:=p*xx;
                            end;
                            Y[0].arr^[c]:=s;
                            inc(c);
                          end;
                   end;

                   //Переходим к сл. функции
                   py:=@py^[N];
		              end
                 end;
  end
end;


end.
