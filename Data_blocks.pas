
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 

unit Data_blocks;

interface

uses Classes, MBTYArrays, DataTypes, SysUtils, abstract_im_interface, RunObjts, math, tbls, mbty_std_consts;

type

  //Блок считывания данных из файла в зависимости от времени
  TFromFile = class(TRunObject)
  protected
    table:         TTable1;
  public
    count:         NativeInt;
    filename:      string;
    k:             double;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Считывание данных из файла в зависимости от входных данных
  TFromTable = class(TFromFile)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;


  //Считывание столбцов таблицы из файла
  TTableAll = class(TFromFile)
  public
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;

  //Двумерная линейная интерполяция по таблице из файла
  TFromTable2D = class(TRunObject)
  protected
    table:         TTable2;
  public
    filename:      string;
    interp_method: NativeInt;
    function       InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function       RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function       GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    constructor    Create(Owner: TObject);override;
    destructor     Destroy;override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  end;

  //Считывание строк из файла
  TReadStrings = class(TRunObject)
  protected
    strnumber:    integer;
    time:         double;
    FS:           TFileStream;
    S:            Ansistring;
    function      ReadNextString(A: TExtArray):boolean; //Функция чтения строки данных
  public
    count:        NativeInt;
    filename:     string;
    tau:          double;
    timeout:      NativeInt;
    wait:         boolean;
    constructor   Create(Owner: TObject);override;
    function      InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function      RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function      GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure     RestartSave(Stream: TStream);override;
    function      RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Последовательная запись результатов расчёта в текстовый файл
  //с неравномерным шагом
  TToFile = class(TRunObject)
  protected
    S:            ansistring;
    FS:           TFileStream;
    time:         double;
    stepindex:    integer;
    procedure     AddFileData(const at:double);
  public
    filename:     string;
    fform:        NativeInt;
    step:         TExtArray;

    StrEndFormat,
    divstyle,
    fnumstyle,
    fnumdigits,
    fnumprecition:NativeInt;

    constructor   Create(Owner: TObject);override;
    destructor    Destroy;override;
    function      InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function      RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function      GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure     RestartSave(Stream: TStream);override;
    function      RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Блок для импорта данных из файла
  TImportFile = class(TRunObject)
  protected
    buffer:       array of double;
    bufferlen:    integer;
    time:         double;
    FS:           TFileStream;
    function      GetData:integer; //Получить данные
  public
    Outs      :   TIntArray;
    Y0        :   TExtArray;
    FileName  :   string;
    exch      :   boolean;
    dt        :   RealType;
    tStop     :   boolean;
    tInit     :   NativeInt;
    timeout   :   NativeInt;
    constructor   Create(Owner: TObject);override;
    destructor    Destroy;override;
    function      InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function      RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function      GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure     RestartSave(Stream: TStream);override;
    function      RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Экспорт данных в файл обмена
  TExportFile = class(TRunObject)
  protected
    time:         double;
    buffer:       array of double;
    bufferlen:    integer;
    FS:           TFileStream;
    function      SetData:integer;virtual;
  public
    FileName  :   String;
    dt        :   RealType;
    tStop     :   boolean;
    function      InfoFunc(Action: integer;aParameter: NativeInt):NativeInt;override;
    function      RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
    function      GetParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    procedure     RestartSave(Stream: TStream);override;
    function      RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;override;
  end;

  //Экспорт ненулевых данных в файл обмена
  //Данные записанные этим блоком могут быть прочитаны блоком TImportFile.
  //Формат файла:
  //   к-во данных N (флаг останова)   =  4 байта
  //   1.  номер значения в буфере     =  8 байт   (номера начинаются с единицы)
  //   2.  значение                    =  8 байт
  //   3.  номер ненулевого значения   =  8 байт
  //        ....
  //   N.  значение
  TExportNozero = class(TExportFile)
  protected
    function      SetData:integer;override;
    function      RunFunc(var at,h : RealType;Action:Integer):NativeInt;override;
  end;


implementation

{*******************************************************************************
                      Считывание данных их файла
*******************************************************************************}
constructor  TFromFile.Create;
begin
  inherited;
  table:=TTable1.Create('');
  k:=1;
  count:=1;
end;

destructor   TFromFile.Destroy;
begin
  inherited;
  table.Free;
end;

function    TFromFile.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'count') then begin
      Result:=NativeInt(@count);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'k') then begin
      Result:=NativeInt(@k);
      DataType:=dtDouble;
      exit;
    end;
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
    end;
  end
end;

function     TFromFile.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_src;
    i_GetInit:   Result:=1;
    i_GetCount:  begin
                   cY[0]:=Count;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TFromFile.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Загрузка данных из файла с таблицей
                     table.OpenFromFile(FileName);
                     if (table.px.Count = 0) or (table.py.CountX = 0) then begin
                       ErrorEvent(txtErrorReadTable,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     if table.py.CountX < Count then begin
                       ErrorEvent(txtFuncCountLessDefined,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                     end;
                   end;
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   for i:=0 to Count - 1 do
                    Y[0].Arr^[i]:=table.GetFunValue(at/k,i); //В качестве аргумента - время
  end
end;

function       TFromFile.GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetOutParamID(ParamName, DataType, IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'py_') then begin
      Result:=11;
      DataType:=dtMatrix;
    end
    else
    if StrEqu(ParamName,'px_') then begin
      Result:=12;
      DataType:=dtDoubleArray;
    end
  end;
end;

function       TFromFile.ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;
 var i: integer;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
  case ID of
    11: if table <> nil then begin
          MoveData(table.py,dtMatrix,DestData,DestDataType);
          Result:=True;
        end;
    12: if table <> nil then begin
          MoveData(table.px,dtDoubleArray,DestData,DestDataType);
          Result:=True;
        end;
  end;
end;

{*******************************************************************************
               Считывание данных их файла в зависимости от входа
*******************************************************************************}
function     TFromTable.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_fun;
    i_GetInit:   Result:=0;
    i_GetCount:  begin
                    //В качестве аргумента - входные данные
                   cY[0]:=Count*cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TFromTable.RunFunc;
 var i,j: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Загрузка данных из файла с таблицей
                     table.OpenFromFile(FileName);
                     if (table.px.Count = 0) or (table.py.CountX = 0) then begin
                       ErrorEvent(txtErrorReadTable,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     if table.py.CountX < Count then begin
                       ErrorEvent(txtFuncCountLessDefined,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                     end;
                   end;
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   begin
                    for j:=0 to U[0].Count - 1 do
                      for i:=0 to Count - 1 do
                        Y[0].Arr^[j*Count + i]:=table.GetFunValue(U[0].Arr^[j]/k,i);
                  end;
  end
end;

{*******************************************************************************
                   Считывание столбцов таблицы из файла
*******************************************************************************}
function     TTableAll.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_src;
    i_GetInit:   Result:=1;
    i_GetCount:  begin
                    //В качестве аргумента - входные данные
                   for i:=0 to cY.Count - 1 do cY[i]:=table.ArgCount;
                 end;
    i_GetPropErr:begin
                   //Здесь пытаемся загрузить данные из таблицы (до сортировки)
                   if (not table.OpenFromFile(FileName)) then begin
                     ErrorEvent(txtErrorOpenTable,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                     exit;
                   end;
                   if (table.px.Count = 0) then begin
                     ErrorEvent(txtErrorReadTable,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                     exit;
                   end;
                   if table.py.CountX + 1 < Count then begin
                     ErrorEvent(txtColCountLessDefined,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
                end
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TTableAll.RunFunc;
 var i,j: integer;
begin
  Result:=0;
  case Action of
    f_RestoreOuts,
    f_UpdateJacoby,
    f_InitState:  if cY.Count >= 1 then begin
                    //Для этого блока достаточно прочитать данные только один раз
                    for i:=0 to Y[0].Count - 1 do
                      Y[0].Arr^[i]:=table.px.Arr^[i];
                    for i:=1 to cY.Count - 1 do
                      for j:=0 to Y[i].Count - 1 do
                        Y[i].Arr^[j]:=table.py[i - 1].Arr^[j];
                  end;
  end
end;

{*******************************************************************************
            Двумерная линейная интерполяция по таблице из файла
*******************************************************************************}
constructor  TFromTable2D.Create;
begin
  inherited;
  table:=TTable2.Create('');
  interp_method:=0;
end;

destructor   TFromTable2D.Destroy;
begin
  inherited;
  table.Free;
end;

function    TFromTable2D.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'interp_method') then begin
      Result:=NativeInt(@interp_method);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
    end;
  end
end;

function     TFromTable2D.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetInit:   Result:=1;
    i_GetCount:  begin
                   cY[0]:=cU[0];
                   cU[1]:=cU[0];
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TFromTable2D.RunFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: begin
                     //Загрузка данных из файла с таблицей
                     table.OpenFromFile(FileName);
                     if (table.px1.Count = 0) or (table.px2.Count = 0) then begin
                       ErrorEvent(txtErrorReadTable,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                     end;
                   end;
    f_UpdateJacoby,
    f_InitState,
    f_UpdateOuts,
    f_RestoreOuts,
    f_GoodStep:   case interp_method of
                    1: begin
                         for i:=0 to U[0].Count - 1 do
                           Y[0].Arr^[i]:=table.GetFunValueWithoutExtrapolation(U[0].Arr^[i],U[1].Arr^[i]);
                       end;
                    2: begin
                         for i:=0 to U[0].Count - 1 do
                           Y[0].Arr^[i]:=table.GetFunValueWithoutInterpolation(U[0].Arr^[i],U[1].Arr^[i]);
                       end;
                  else
                    for i:=0 to U[0].Count - 1 do
                      Y[0].Arr^[i]:=table.GetFunValue(U[0].Arr^[i],U[1].Arr^[i]);
                  end;

  end
end;

function       TFromTable2D.GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetOutParamID(ParamName, DataType, IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'py_') then begin
      Result:=11;
      DataType:=dtMatrix;
    end
    else
    if StrEqu(ParamName,'px1_') then begin
      Result:=12;
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'px2_') then begin
      Result:=13;
      DataType:=dtDoubleArray;
    end
  end;
end;

function       TFromTable2D.ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;
 var i: integer;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
  if not Result then
  case ID of
    11: if table <> nil then begin
          MoveData(table.py,dtMatrix,DestData,DestDataType);
          Result:=True;
        end;
    12: if table <> nil then begin
          MoveData(table.px1,dtDoubleArray,DestData,DestDataType);
          Result:=True;
        end;
    13: if table <> nil then begin
          MoveData(table.px2,dtDoubleArray,DestData,DestDataType);
          Result:=True;
        end;
  end;
end;



{*******************************************************************************
                 Последовательное чтение строк из файла
*******************************************************************************}
constructor TReadStrings.Create(Owner: TObject);
begin
  inherited;
  timeout:=1;
  wait:=True;
end;

function    TReadStrings.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
      exit;
    end;
    if StrEqu(ParamName,'count') then begin
      Result:=NativeInt(@count);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'timeout') then begin
      Result:=NativeInt(@timeout);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'wait') then begin
      Result:=NativeInt(@wait);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'tau') then begin
      Result:=NativeInt(@tau);
      DataType:=dtDouble;
    end;
  end
end;

function     TReadStrings.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_src;
    i_GetInit:   Result:=1;
    i_GetCount:  begin
                   cY[0]:=Count;
                 end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TReadStrings.ReadNextString;
  var ch:     ansichar;
      i,j,k:  int64;
      //Sz:     int64;
      V:      double;
      Code:   integer;
  label
     Next;
begin
  Result:=(FS <> nil);
  if Result then begin

     //Считываем длину файла
     //Sz:=FS.Size;

     //Ожидание добавления новых данных в файл
     if Wait then begin
       while (pf_Running in PrjState^) and (FS.Position >= FS.Size) do
         sleep(timeout);
     end;

Next:
     if FS.Position >= FS.Size then begin
       if not Wait then Result:=False;
       exit;
     end;

     //Считываем очередную строку из файла
     i:=FS.Position;
     j:=i;
     repeat
       if j >= FS.Size then break;
       FS.Read(ch,SizeOf(ch));
       inc(j);
     until (ch = #13);

     //Доводим строку до конечного символа
     while FS.Position < FS.Size do begin
       FS.Read(ch,SizeOf(ansichar));
       if ch <> #10 then break;
     end;

     //Считываем строку из файла
     SetLength(S,j - i - 1);
     FS.Position:=i;
     FS.Read(S[1],j - i - 1);
     FS.Position:=FS.Position + 1;  //Устанавливаем указатель чтения на новую позицию

     //Здесь собственно выполняем операции со строкой
     S:=Trim(S);
     //Если строка является комментарием или пустой - то делаем ещё одну попытку
     if (S = '') or (S[1] = '$') or (S[1] = '/') or (S[1] = '{') then
       goto Next;

     //Если строка не является комментарием, то вытаскиваем из неё выражение
     i:=1;
     k:=0;
     while i <= Length(S) do begin
       //Ищем конец строки
       j:=i;
       while (j <= Length(S)) and not (S[j] in [' ',';',':',#9]) do inc(j);
       //Извлекаем из строки число
       Val(Copy(S,i,j - i),V,Code);
       if Code <> 0 then begin
         Result:=False;
         exit;
       end;
       if k < A.Count then A.Arr^[k]:=V;
       i:=j + 1;
       //Доходим до следующей цифры
       while (i <= Length(S)) and (S[i] in [' ']) do inc(i);
       inc(k);
     end;

  end;
end;

function    TReadStrings.RunFunc;
 var
    i: integer;
 label
    precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     //Загрузка данных из файла с таблицей
                     FS:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
                   except
                     FS:=nil;
                     ErrorEvent(txtNotOpenDataFile,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    f_Stop:        if FS <> nil then begin
                     FS.Free;
                     FS:=nil;
                   end;
    f_InitState:   begin
                     strnumber:=0;
                     if not ReadNextString(Y[0]) then begin
                       ErrorEvent(txtNotReadTableString,msError,VisualObject);
                       Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                       exit;
                     end;
                     strnumber:=1;
                     time:=at;
                     if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(ModelODEVars.newstep,tau);
                     end;
                  end;
    f_RestoreOuts:begin
                    i:=0;
                    while i < strnumber do begin
                      if not ReadNextString(Y[0]) then begin
                        ErrorEvent(txtNotReadTableString,msError,VisualObject);
                        Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                        exit;
                      end;
                      inc(i);
                    end;
                  end;
    f_GoodStep:   if time-at <= 0.5*h then begin
                    if not ReadNextString(Y[0]) then begin
                      ErrorEvent(txtNotReadTableString+' time='+FloatToStr(at),msError,VisualObject);
                      Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                      exit;
                    end;
                    inc(strnumber);
                    time:=time + tau;
                    goto precise_step;
                  end;
    f_UpdateOuts: begin
                     precise_step:
                     if ModelODEVars.fPreciseSrcStep and (tau > 0) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),tau);
                     end;
                  end;
  end
end;

procedure  TReadStrings.RestartSave;
begin
  inherited;
  Stream.Write(time,SizeOf(double));
  Stream.Write(strnumber,SizeOfInt);
end;

function   TReadStrings.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result and (Count > 0) then try
    Stream.Read(time,SizeOf(double));
    time:=time - TimeShift;
    Stream.Read(strnumber,SizeOfInt);
  except
    Result:=False;
  end;
end;


{*******************************************************************************
                 Запись (архивация) результатов в файл
*******************************************************************************}
constructor TToFile.Create;
begin
  inherited;
  step:=TExtArray.Create(1);
  fnumstyle:=Byte(ffGeneral);
  fnumdigits:=2;
  fnumprecition:=15;
end;

destructor  TToFile.Destroy;
begin
  inherited;
  step.Free;
end;

function    TToFile.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
    end
    else
    if StrEqu(ParamName,'fform') then begin
      Result:=NativeInt(@fform);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'step') then begin
      Result:=NativeInt(step);
      DataType:=dtDoubleArray;
    end
    else
    if StrEqu(ParamName,'digits') then begin
      Result:=NativeInt(@fnumdigits);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'precition') then begin
      Result:=NativeInt(@fnumprecition);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'style') then begin
      Result:=NativeInt(@fnumstyle);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'divstyle') then begin
      Result:=NativeInt(@divstyle);
      DataType:=dtInteger;
    end
    else
    if StrEqu(ParamName,'strendformat') then begin
      Result:=NativeInt(@StrEndFormat);
      DataType:=dtInteger;
    end

  end
end;

function     TToFile.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_dst;
    i_GetInit:     Result:=0;
    i_GetPropErr:  if step.Count < 1 then begin
                     ErrorEvent(txtStepCountNotBeZero,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    i_GetCount:    begin end;         //Размерность входа - произвольная      
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

const
  StrDivWindows:ansistring = #13#10;
  StrDivUNIX:   ansistring = #10;
  StrDivMAC:    ansistring = #13;
  WhiteSpace:   ansichar   = ' ';

procedure   TToFile.AddFileData;
 var i,j: integer;

 procedure GetStrVal(const d: double;aNeedDivider: boolean);
  var i,k: integer;
      S1:  ansistring;
 begin
   case fform of
     0: S:=FloatToStrF(d,ffExponent,4,2);
     1: S:=FloatToStrF(d,ffExponent,7,2);
     2: S:=FloatToStrF(d,ffExponent,10,2);
     3: S:=FloatToStrF(d,ffExponent,13,2);
     5: begin
          //С настраиваемыми параметрами точности
          S:=FloatToStrF(d,TFloatFormat(fnumstyle),fnumprecition,fnumdigits);
        end
   else
     S:=FloatToStr(d);
   end;

   case divstyle of

       //Таблица разделённая символами табуляции
     1:if aNeedDivider then S:=#9 + S;

       //Таблица разделённая символами ;
     2:if aNeedDivider then S:=';' + S;

   else

     //Выровненная таблицы разделённая пробелами - вариант по умолчанию
     //Делаем выравнивае столбцов на ширину 20 символов
     k:=Length(S);
     if k < 20 then begin
       SetLength(S1,20 - k);
       for i:=1 to 20 - k do S1[i]:=WhiteSpace;
     end;

     if aNeedDivider then
       S:=WhiteSpace + S + S1
     else
       S:=S + S1;

   end;

   FS.Write(S[1],Length(S));
 end;

begin
  GetStrVal(at,False);
  for i:=0 to cU.Count - 1 do
    for j:=0 to U[i].Count - 1 do begin
      GetStrVal(U[i].Arr^[j],True);
    end;

  //Добавляем разделитель строк #13#10
  case StrEndFormat of
    1: FS.Write(StrDivUNIX[1],Length(StrDivUNIX));
    2: FS.Write(StrDivMAC[1],Length(StrDivMAC));
  else
    FS.Write(StrDivWindows[1],Length(StrDivWindows));
  end;
end;

function    TToFile.RunFunc;
 label precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     //Загрузка данных из файла с таблицей
                     try
                       FS:=TFileStream.Create(FileName,fmCreate);
                       FS.Free;
                     except
                     end;
                     FS:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
                   except
                     FS:=nil;
                     ErrorEvent(txtNotCreateDataFile,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    f_Stop:        if FS <> nil then begin
                      FS.Free;    //Закрываем файл, когда расчёт будет окончен
                      FS:=nil;
                   end;
    f_InitState:   begin
                     stepindex:=0;
                     time:=at + step[stepindex]; //Устанавливаем целевое время
                     AddFileData(at);
                     goto precise_step;
                  end;
    f_GoodStep:   if time - at <= 0.5*h then begin
                    AddFileData(at);
                    inc(stepindex);
                    if stepindex >= step.Count then stepindex:=0;
                    time:=time + step[stepindex];
                    goto precise_step;
                  end;
    f_UpdateOuts: begin
                     precise_step:
                     if stepindex >= step.Count then stepindex:=0;
                     if ModelODEVars.fPreciseSrcStep and (step[stepindex] > 0) then begin
                        ModelODEVars.fsetstep:=True;
                        ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),step[stepindex]);
                     end;
                  end;
  end
end;

procedure  TToFile.RestartSave;
begin
  inherited;
  Stream.Write(time,SizeOf(double));
  Stream.Write(stepindex,SizeOfInt);
end;

function   TToFile.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result and (Count > 0) then try
    Stream.Read(time,SizeOf(double));
    time:=time - TimeShift;
    Stream.Read(stepindex,SizeOfInt);
  except
    Result:=False;
  end;
end;


{*******************************************************************************
                    Импорт данных из файла обмена
*******************************************************************************}
constructor TImportFile.Create;
begin
  inherited;
  timeout:=10;
  y0:=TExtArray.Create(1);
  Outs:=TIntArray.Create(1);
end;

destructor  TImportFile.Destroy;
begin
  inherited;
  y0.Free;
  Outs.Free;
end;

function    TImportFile.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
      exit;
    end;
    if StrEqu(ParamName,'y0') then begin
      Result:=NativeInt(y0);
      DataType:=dtDoubleArray;
      exit;
    end;
    if StrEqu(ParamName,'outs') then begin
      Result:=NativeInt(outs);
      DataType:=dtIntArray;
      exit;
    end;
    if StrEqu(ParamName,'exch') then begin
      Result:=NativeInt(@exch);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'tstop') then begin
      Result:=NativeInt(@tstop);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'tinit') then begin
      Result:=NativeInt(@tinit);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'timeout') then begin
      Result:=NativeInt(@timeout);
      DataType:=dtInteger;
      exit;
    end;
    if StrEqu(ParamName,'dt') then begin
      Result:=NativeInt(@dt);
      DataType:=dtDouble;
    end;
  end
end;

function     TImportFile.InfoFunc;
 var i: integer;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_src;
    i_GetInit:     Result:=1;
    i_GetCount:    begin
                     for i:=0 to Outs.Count - 1 do cY[i]:=Outs[i];
                   end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TImportFile.GetData;
 var i,j,cnt: integer;
 label Next;
begin
  Result:=0;
  if FS <> nil then
    try
      //Выполняем ожидание, до тех пор пока файл не будет выставлено ненулевое значение

Next:

      //Считываем количество данных
      FS.Position:=0;
      FS.ReadBuffer(cnt,SizeOfInt);

      //Автоматический останов при count < 0
      if tStop and (cnt < 0) then begin
        Result:=r_Fail;
        exit;
      end;

      //Если к-во = 0 и установлен флаг синхронизации и режим - исполнение - ждём
      if exch and (pf_Running in PrjState^) and (cnt = 0) then begin
         sleep(timeout);
         goto Next;
      end;

      //Производим считывание данных из файла
      if bufferlen > 0 then begin
        FS.ReadBuffer(buffer[0],Min(bufferlen,cnt)*SizeOfDouble);
        //Выводим данные в порты блока
        cnt:=0;
        for i:=0 to cY.Count - 1 do
          for j:=0 to Y[i].Count - 1 do begin
             Y[i].Arr^[j]:=buffer[cnt];
             inc(cnt);
          end
      end;

      //Устанавливаем флаг считывания данных
      cnt:=0;
      FS.Position:=0;
      FS.WriteBuffer(cnt,SizeOfInt);

    except
      FS.Free;
      FS:=nil;
      ErrorEvent(txtErrorAccessExchangeFile,msError,VisualObject);
      Result:=r_Fail;
    end
  else begin
    ErrorEvent(txtExchangeFileNotCreate,msError,VisualObject);
    Result:=r_Fail;
  end;
end;

function    TImportFile.RunFunc;
 var
     i,j,c: integer;
 label
     precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     //Открываем файл без ограничений доступа
                     FS:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
                     //Устанавливаем размер буфера данных
                     c:=0;
                     for i:=0 to cY.Count - 1 do c:=c + cY[i];
                     bufferlen:=c;
                     SetLength(buffer,bufferlen);
                     for i:=0 to c - 1 do buffer[i]:=0;
                   except
                     FS:=nil;
                     ErrorEvent(txtNotOpenExchangeFile,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    f_Stop:        if FS <> nil then begin
                      FS.Free;    //Закрываем файл, когда расчёт будет окончен
                      FS:=nil;
                   end;
    f_InitState:   begin
                     time:=at + dt;
                     if tInit = 1 then begin
                       c:=0;
                       for i:=0 to cY.Count - 1 do
                         for j:=0 to Y[i].Count - 1 do
                           if c < y0.Count then begin
                             Y[i].Arr^[j]:=y0[c];
                             inc(c);
                           end
                     end
                     else
                       Result:=GetData;
                     goto precise_step;
                   end;
    f_GoodStep:    if at >= time then begin
                     Result:=GetData;
                     time:=time+dt;
                     goto precise_step;
                   end;
    f_UpdateOuts:  begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (dt > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),dt);
                       end;
                   end;
  end
end;

procedure  TImportFile.RestartSave;
begin
  inherited;
  Stream.Write(time,SizeOf(double));
end;

function   TImportFile.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result and (Count > 0) then try
    Stream.Read(time,SizeOf(double));
    time:=time - TimeShift;
  except
    Result:=False;
  end;
end;

{*******************************************************************************
                      Экспорт данных в файл обмена
*******************************************************************************}
function    TExportFile.GetParamID;
begin
  Result:=inherited GetParamID(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'filename') then begin
      Result:=NativeInt(@filename);
      DataType:=dtString;
      exit;
    end;
    if StrEqu(ParamName,'tstop') then begin
      Result:=NativeInt(@tstop);
      DataType:=dtBool;
      exit;
    end;
    if StrEqu(ParamName,'dt') then begin
      Result:=NativeInt(@dt);
      DataType:=dtDouble;
    end;
  end
end;

function     TExportFile.InfoFunc;
begin
  Result:=0;
  case Action of
    i_GetBlockType:Result:=t_dst;
    i_GetInit:     Result:=0;
    i_GetCount:    begin end;
  else
    Result:=inherited InfoFunc(Action,aParameter);
  end;
end;

function    TExportFile.SetData;
 var i,j,cnt: integer;
 label Next;
begin
  Result:=0;
  if FS <> nil then
    try
      //Заносим данные в буфер
      cnt:=0;
      for i:=0 to cU.Count - 1 do
        for j:=0 to U[i].Count - 1 do begin
          buffer[cnt]:=U[i].Arr^[j];
          inc(cnt);
        end;

      //Записываем данные в файл обмена
      FS.Position:=0;
      FS.WriteBuffer(bufferlen,SizeOfInt);
      if bufferlen > 0 then
        FS.WriteBuffer(buffer[0],bufferlen*SizeOfDouble);

    except
      FS.Free;
      FS:=nil;
      ErrorEvent(txtErrorAccessExchangeFile,msError,VisualObject);
      Result:=r_Fail;
    end
  else begin
    ErrorEvent(txtExchangeFileNotCreate,msError,VisualObject);
    Result:=r_Fail;
  end;
end;

function    TExportFile.RunFunc;
 var
     i,c: integer;
 label
     precise_step;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     //Если файла нет - создаём его
                     if not FileExists(FileName) then begin
                       FS:=TFileStream.Create(FileName,fmCreate);
                       FS.Free;
                     end;
                     //Открываем файл без ограничений доступа
                     FS:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
                     //Устанавливаем размер буфера данных
                     c:=0;
                     for i:=0 to cU.Count - 1 do c:=c + cU[i];
                     bufferlen:=c;
                     SetLength(buffer,bufferlen);
                     for i:=0 to bufferlen - 1 do buffer[i]:=0;
                   except
                     FS:=nil;
                     ErrorEvent(txtNotOpenExchangeFile,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    f_Stop:        if FS <> nil then begin
                      //Даём команду на остановку расчёта
                      if tStop then begin
                        FS.Position:=0;
                        i:=-1;
                        FS.WriteBuffer(i,SizeOfInt);
                      end;
                      FS.Free;    //Закрываем файл, когда расчёт будет окончен
                      FS:=nil;
                   end;
    f_InitState:   begin
                     time:=at + dt;
                     Result:=SetData;
                     goto precise_step;
                   end;
    f_GoodStep:    if at >= time then begin
                     Result:=SetData;
                     time:=time+dt;
                     goto precise_step;
                   end;
    f_UpdateOuts:  begin
                       precise_step:
                       if ModelODEVars.fPreciseSrcStep and (dt > 0) then begin
                          ModelODEVars.fsetstep:=True;
                          ModelODEVars.newstep:=min(min(ModelODEVars.newstep,max(time - at,0)),dt);
                       end;
                   end;
  end
end;

procedure  TExportFile.RestartSave;
begin
  inherited;
  Stream.Write(time,SizeOf(double));
end;

function   TExportFile.RestartLoad;
begin
  Result:=inherited RestartLoad(Stream,Count,TimeShift);
  if Result and (Count > 0) then try
    Stream.Read(time,SizeOf(double));
    time:=time - TimeShift;
  except
    Result:=False;
  end;
end;


{*******************************************************************************
                  Экспорт ненулевых данных в файл обмена
*******************************************************************************}
function    TExportNozero.SetData;
 var i,j,cnt,k: integer;
 label Next;
begin
  Result:=0;
  if FS <> nil then
    try
      //Заносим данные в буфер
      cnt:=0;
      k:=0;
      for i:=0 to cU.Count - 1 do
        for j:=0 to U[i].Count - 1 do begin
           inc(k);
           if U[0].Arr^[j] <> 0 then begin
             buffer[cnt]:=k;
             inc(cnt);
             buffer[cnt]:=U[i].Arr^[j];
             inc(cnt);
           end;
        end;

      //Записываем данные в файл обмена
      FS.Position:=0;
      FS.WriteBuffer(cnt,SizeOfInt);
      if bufferlen > 0 then
        FS.WriteBuffer(buffer[0],cnt*SizeOfDouble);

    except
      FS.Free;
      FS:=nil;
      ErrorEvent(txtErrorAccessExchangeFile,msError,VisualObject);
      Result:=r_Fail;
    end
  else begin
    ErrorEvent(txtExchangeFileNotCreate,msError,VisualObject);
    Result:=r_Fail;
  end;
end;

function    TExportNozero.RunFunc;
 var i,c: integer;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     //Если файла нет - создаём его
                     if not FileExists(FileName) then begin
                       FS:=TFileStream.Create(FileName,fmCreate);
                       FS.Free;
                     end;
                     //Открываем файл без ограничений доступа
                     FS:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
                     //Устанавливаем размер буфера данных
                     c:=0;
                     for i:=0 to cU.Count - 1 do c:=c + cU[i];
                     bufferlen:=2*c;  //Буфер - в 2 раза больше, т.к. данных в нём записываются индексы
                     SetLength(buffer,bufferlen);
                     for i:=0 to bufferlen - 1 do buffer[i]:=0;
                   except
                     FS:=nil;
                     ErrorEvent(txtNotOpenExchangeFile,msError,VisualObject);
                     Result:=r_Fail;  //Если возвращаем > 0 - то значит произошла ошибка
                   end;
    f_Stop:        if FS <> nil then begin
                      //Даём команду на остановку расчёта
                      if tStop then begin
                        FS.Position:=0;
                        i:=-1;
                        FS.WriteBuffer(i,SizeOfInt);
                      end;
                      FS.Free;    //Закрываем файл, когда расчёт будет окончен
                      FS:=nil;
                   end;
    f_InitState:   begin
                     time:=at + dt;
                     Result:=SetData;
                   end;
    f_GoodStep:    if at >= time then begin
                     Result:=SetData;
                     time:=time+dt;
                   end;
  end
end;


end.
