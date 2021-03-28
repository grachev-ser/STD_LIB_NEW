
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 
 
unit Info;

  //**************************************************************************//
  //         Здесь находится список объектов и функция для их создания        //
  //**************************************************************************//

interface

uses Classes, InterfaceUnit,DataTypes, DataObjts, abstract_im_interface, RunObjts;

  //Инициализация библиотеки
function  Init:boolean;
  //Процедура создания объекта
function  CreateObject(Owner:Pointer;const Name: string):Pointer;
  //Уничтожение библиотеки
procedure Release;

  //Главная информационая запись библиотеки
  //Она содержит ссылки на процедуры инициализации, завершения библиотеки
  //и функцию создания объектов
const
  DllInfo: TDllInfo =
  (
    Init:         Init;
    Release:      Release;
    CreateObject: CreateObject;
  );

implementation

uses Src, Dif, Operations, Nonlines, Discrete, Vectors, Func_blocks, Keys,
     Logs, Trigger,Timers,Data_blocks, Stat_Blocks, lae_objects, uOptimizers, elec_base;

function  Init:boolean;
begin
  //Если библиотека инициализирована правильно, то функция должна вернуть True
  Result:=True;
  //Присваиваем папку с корневой директорией базы данных программы
  DBRoot:=DllInfo.Main.DataBasePath^;

  //Здесь можно произвести регистрацию дополнительных функций интерпретатора
  //при помощи функции DllInfo.Main.RegisterFuncs
  //для того чтобы подключить функции к оболочке надо внести библиотеку в список плагинов графического редактора.

end;


type
  TClassRecord = packed record
    Name:     string;
    RunClass: TRunClass;
  end;

  //**************************************************************************//
  //    Таблица классов имеющихся в стандартной библиотеке блоков МВТУ        //
  //    в соответствии с этой таблицей создаются соответсвующие run-объекты   //
  //**************************************************************************//
const
  ClassTable:array[0..0] of TClassRecord =
  (
    //Оптимизация выходных параметров под заданные входные критерии
    (Name:'toptimize_new'; RunClass:TOptimize_new)
  );


  //Это процедура создания объектов
  //она возвращает интерфейс на объект-плагин
function  CreateObject(Owner:Pointer;const Name: string):Pointer;
 var i: integer;
begin
  Result:=nil;
  for i:=0 to High(ClassTable) do if StrEqu(Name,ClassTable[i].Name) then begin
    Result:=ClassTable[i].RunClass.Create(Owner);
    exit;
  end;
end;

procedure Release;
begin

end;

end.
