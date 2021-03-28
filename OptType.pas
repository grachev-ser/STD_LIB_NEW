
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
//-------------------------------------------------------------------------------------------------
unit OptType;

interface

uses Classes, DataTypes;

const
   er_opt_MaxFunEval = 1;      // превышено максимальное число вычислений функции
   er_Opt_InitVal    = 2;      // ќшибка инициализации алгоритма оптимизации
   er_opt_Eps        = 3;      // ќшибка оптимизаци по сходимости

type
   // Функция присвоения выходов модели оптимизации
   SetOutsFunc = procedure(X, FX : PExtArr; var ner : NativeInt) of object;
   // Функция получения качества
   GetQualFunc = procedure(X, FX : PExtArr; var ner : NativeInt) of object;
   // Функция возврата результата от алгоритма оптимизации
   OutOptFunc = procedure(X, FX: PExtArr; N, M, NFE : integer; var stepout : integer) of object;
   // Функция сравнения результатов
   CompQualFunc = procedure(X, Y, FX, FY : PExtArr; N : integer; M : integer; var IC : integer) of object;

   // Базовый класс метода оптимизации
   TOptMethod = class
   public
     SETOUTS:  SetOutsFunc;
     GETQUAL:  GetQualFunc;
     OUT2:     OutOptFunc;
     COMPQUAL: CompQualFunc;
     procedure InitMem(N,M: integer);virtual;abstract;
     procedure LeaveMem;virtual;abstract;
     procedure ExecuteStep(X,FX:PExtArr;
                 N:integer; M:integer;
                 DX:  PExtArr;
                 DXfinal:PExtArr;
                 NFEMAX: integer;
                 MinParam,MaxParam: PExtArr;
                 var NER: NativeInt;
                 var StopOpt: integer;
                 var otp_step_position: integer
                 );virtual;abstract;
    function    RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;virtual;
    procedure   RestartSave(Stream: TStream);virtual;
    destructor  Destroy;override;
   end;

//##############################################################################
implementation
//##############################################################################
destructor TOptMethod.Destroy;
begin
  LeaveMem;
  inherited;
end;
//-------------------------------------------------------------------------------------------------
function TOptMethod.RestartLoad(Stream: TStream;Count: integer;const TimeShift:double):boolean;
begin
  Result:=True;
end;
//-------------------------------------------------------------------------------------------------
procedure TOptMethod.RestartSave(Stream: TStream);
begin

end;
//-------------------------------------------------------------------------------------------------
end.
