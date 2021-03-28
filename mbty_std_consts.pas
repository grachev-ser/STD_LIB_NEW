 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программисты:        Тимофеев К.А., Ходаковский В.В.                     //
 //**************************************************************************//

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF} 
 
unit mbty_std_consts;

interface

const
  {$IFNDEF ENG}
  txtOrdinatesDefineIncomplete = 'Массив значений задан не полностью, требуется размерность не менее ';
  txtOrdinatesNotDefinedError = 'Массив значений не задан';
  txtDimensionsNotDefined = 'Матрица абсцисс не задана';
  txtInputMatrixError = 'Входная матрица не является квадратной';
  txtDefineSolverOfOtherType = 'Задан решатель системы другого типа';
  txtSolverNameNotDefined = 'Не задано имя линейной системы';
  txtErrorOpenTable = 'Не удалось открыть таблицу';
  txtErrorReadTable = 'Не удалось получить данные из таблицы';
  txtFuncCountLessDefined = 'К-во функций в файле меньше заданного в параметрах блока';
  txtColCountLessDefined = 'К-во столбцов в файле меньше заданного в параметрах блока';
  txtNotOpenDataFile = 'Не удалось открыть файл с данными';
  txtNotReadTableString = 'Не удалось прочитать строку таблицы';
  txtStepCountNotBeZero = 'Количество шагов должно быть ненулевым';
  txtNotCreateDataFile = 'Не создать файл для записи данных';
  txtErrorAccessExchangeFile = 'Ошибка доступа к файлу обмена';
  txtExchangeFileNotCreate = 'Файл обмена не создан';
  txtNotOpenExchangeFile = 'Не удалось открыть файл обмена';
  txtKlessX0 = 'Размерность массива k меньше чем у массива x0';
  txtKTlessX0 = 'Размерность массива k или массива T меньше чем у массива x0';
  txtTimeEqZero = 'Постоянная времени блока равна или меньше нуля';
  txtErrorMatrixDim = 'Размерность матриц не соответсвует указанным количествам переменных';
  txtArrLessX0 = 'Размерность одного из массивов меньше чем у массива x0';
  txtT1T2LessX0 = 'Размерность массива k или массивов T1,T2 меньше чем у массива x0';
  txtT2LessZero = 'Постоянная времени T2 блока равна или меньше нуля';
  txtTKLessZero = 'T и k должны быть больше нуля';
  txtNumDimError = 'Порядок знаменателя меньше чем числителя';
  txtDeNumDimLess2 = 'Порядок знаменателя меньше 2';
  txtDenumGainEquZero = 'Коэффциент в знаменателе равен нулю';
  txtNumDimLess2 = 'Порядок числителя меньше 2';
  txtkTlessY0 =  'Размерность массива k или массива T меньше чем у массива y0';
  txtBNotDefined = 'Не задан массив B';
  txtANotDefined = 'Не задан массив A';
  txtWNotDefined = 'Не задан массив W';
  txtFNotDefined = 'Не задан массив F';
  txtCNotDefined = 'Не задан массив C';
  txtLineConvertErrorAEqB = 'Ошибка при вычислении линейного преобразования A = B';
  txtLowLimitGreatThanHighLimitAtElement = 'Значение нижнего предела больше чем верхнего в элементе номер ';
  txtBlockNeed2inp = 'Блок должен иметь 2 входа';
  txtAWlesF = 'Размерность массива w или массива f меньше чем у массива a';
  txtArgumentNotInOne = 'Аргумент арксинуса выходит за границы интервала [-1,1]';
  txtArccosError = 'Аргумент арксинуса выходит за границы интервала [-1,1]';
  txtHypCtgError = 'Аргумент гиперболического котангенса не может быть равен 1';
  txtLogError = 'Аргумент логарифма должен быть больше нуля';
  txtLog0Error = 'Аргумент логарифма c защитой нуля должен быть больше или равен нулю';
  txtLog0Warn = 'Аргумент логарифма равен 0, расчет продолжен, но выход блока -> к минус бесконечности';
  txtPowerError = 'Ошибка при возведении числа в заданную степень';
  txtHyperError = 'Размерность одного из параметров блока равна нулю';
  txtHyperErr1 = 'Произошло деление на ноль - введите ненулевое значение eps';
  txtParabErr = 'Размерность одного из параметров блока равна нулю';
  txtExpErr = 'Размерность массива c равна нулю';
  txtKey0Err = 'Размерность массива k меньше чем у массива y0';
  txtKey2Err = 'Размерность одного из массивов меньше чем у массива y01';
  txtKey8Err = 'Размерность массива ymin меньше чем у массива ymax';
  txtAndErr = 'Блок должен иметь не менее двух входов';
  txtOrErr  = 'Блок должен иметь не менее одного входа';
  txtDelayErr = 'Время запаздывания не может быть отрицательным';
  txtVarDelayErr = 'Время запаздывания должно быть БОЛЬШЕ НУЛЯ, т.к. скорость не бесконечна';
  txtDiffLimitErr = 'Размерность массива a меньше чем у массива x0';
  txtLomErr = 'Размерность векторов времён и значений не совпадают';
  txtMinMaxUErr = 'У этого блока должно быть не менее двух портов';
  txtImpulseErr = 'Размерность tau меньше чем y0';
  txtSumErr = 'Сумматор должен иметь хотя бы один вход';
  txtVecSumErr = 'Сумматор должен иметь хотя бы один вход';
  txtMulErr = 'Перемножитель должен иметь хотя бы один вход';
  txtVecMulErr = 'Перемножитель должен иметь хотя бы один вход';
  txtScalarMulErr = 'Перемножитель должен иметь два входа';
  txtScalarAddErr = 'Сумматор должен иметь два входа';
  txtAmpErr = 'Усилитель должен иметь хотя бы один вход';
  txtDividerErr = 'Делитель должен иметь два входа';
  txtDivByZero = 'Произошло деление на ноль';
  txtAbsErr = 'Блок должен иметь хотя бы один вход';
  txtRazmErr = 'Размножитель должен иметь один вход';
  txtErrorRazmDimensionMatrix = 'Матрица размножения должна иметь минимум одну строку';
  txtCaseErr = 'Блок должен иметь два входа';
  txtFirstActiveNumberErr = 'Блок должен иметь один входной порт';
  txtLinErr = 'Размерноть одного из параметров линейного источника равна нулю';
  txtStepErr = 'Размерность дного из параметров ступенчатого источника равна нулю';
  txtSinErr = 'Размерноть одного из параметров синусоидального источника равна нулю';
  txtPilaErr = 'Размерность одного из параметров пилообразного источника равна нулю';
  txtPilaErr1 = 'Период сигнала должен быть больше нуля';
  txtMeandrErr = 'Размерность одного из массивов равна нулю';
  txtSteadyErr = 'Размерность массива xmax или qt меньше чем у массива xmin';
  txtGaussErr = 'Размерность массива d или qt меньше чем у массива m';
  txtTimeAcceptErr = 'Размерности массивов tau_on и tau_of должны быть одинаковыми';
  txtArraysCountNotEqu = 'Размерности массивов параметров не совпадают';

  {$ELSE}

    // Не переведено !!!
  txtOrdinatesDefineIncomplete = 'Values array defined partially, need dimension great than ';
  txtOrdinatesNotDefinedError = 'Values array not defined';
  txtDimensionsNotDefined = 'Abscisses matrix not defined';
  txtInputMatrixError = 'Input matrix is not square';
  txtDefineSolverOfOtherType = 'Define solver of other type';
  txtSolverNameNotDefined = 'LAE system name not defined';
  txtErrorOpenTable = 'Error open table';
  txtErrorReadTable = 'Error read table';
  txtFuncCountLessDefined = 'Function count in file less defined';
  txtColCountLessDefined = 'Column count in file less defined';
  txtNotOpenDataFile = 'Error open data file';
  txtNotReadTableString = 'Error string read';
  txtStepCountNotBeZero = 'Step count must be nozero';
  txtNotCreateDataFile = 'Unable create data file';
  txtErrorAccessExchangeFile = 'Error exchange file access';
  txtExchangeFileNotCreate = 'Exchange file not created';
  txtNotOpenExchangeFile = 'Exchange file not opened';
  txtKlessX0 = 'Dimension of array k less than x0';
  txtKTlessX0 = 'Dimension of array k or T less than x0';
  txtTimeEqZero = 'Time constant equal or less zero';
  txtErrorMatrixDim = 'Matrix dimension error';
  txtArrLessX0 = 'Dimension of one of arrays less than array x0';
  txtT1T2LessX0 = 'Dimension of array k or T1,T2 less than x0';
  txtT2LessZero = 'Time constant T2 equal or less zero';
  txtTKLessZero = 'T and k must be great zero';
  txtNumDimError = 'Denominator order less than nominator';
  txtDeNumDimLess2 = 'Denominator order less 2';
  txtDenumGainEquZero = 'Coefficient in denominator equal zero';
  txtNumDimLess2 = 'Nominator order less 2';
  txtkTlessY0 =  'Dimension of array k or T less than y0';
  txtBNotDefined = 'B array is not defined';
  txtANotDefined = 'A array is not defined';
  txtWNotDefined = 'W array is not defined';
  txtFNotDefined = 'F array is not defined';
  txtCNotDefined = 'C array is not defined';
  txtLineConvertErrorAEqB = 'Error calculate linear convertor A = B';
  txtLowLimitGreatThanHighLimitAtElement = 'Value of low limit great than high limit at element ';
  txtBlockNeed2inp = 'Block must have 2 inputs';
  txtAWlesF = 'Dimension of array w or f less than a';
  txtArgumentNotInOne = 'Arcsinus argument not belong to [-1,1]';
  txtArccosError = 'Arccosinus argument not belong to [-1,1]';
  txtHypCtgError = 'Hyperbolic cotangens not be equal 1';
  txtLogError = 'Logarithm argument must be great zero';
  txtPowerError = 'Error in Power function';
  txtHyperError = 'Dimension of one of properties equal zero';
  txtHyperErr1 = 'Division by zero - enter nozero eps';
  txtParabErr = 'Dimension of one of properties equal zero';
  txtExpErr = 'Dimension of array c less than zero';
  txtKey0Err = 'Dimension of array k less than y0';
  txtKey2Err = 'Dimension of one of arrays less than y01';
  txtKey8Err = 'Dimension of array ymin less than ymax';
  txtAndErr = 'Block must have no less than two inputs';
  txtOrErr  = 'Block must have no less than one input';
  txtDelayErr = 'Delay time not be negative';
  txtVarDelayErr = 'Delay time must be great zero, becose speen not be infinite';
  txtDiffLimitErr = 'Dimension of array a less than x0';
  txtLomErr = 'Dimensions of time array and value array not equal';
  txtMinMaxUErr = 'Block must have no less than two inputs';
  txtImpulseErr = 'Dimension of array tau less than y0';
  txtSumErr = 'Adder must have not less than one inputs';
  txtVecSumErr = 'Adder must have not less than one inputs';
  txtMulErr = 'Multiplier must have not less than one inputs';
  txtVecMulErr = 'Multiplier must have not less than one inputs';
  txtScalarMulErr = 'Multiplier must have two inputs';
  txtScalarAddErr = 'Adder must have two inputs';
  txtAmpErr = 'Aplifier must have not less than one inputs';
  txtDividerErr = 'Divisor must have two inputs';
  txtDivByZero = 'Division by zero';
  txtAbsErr = 'Block must have not less than one input';
  txtRazmErr = 'Multiplicator must have not less than one inputs';
  txtErrorRazmDimensionMatrix = 'Multiplicator must have minimum one row';
  txtCaseErr = 'Block must have two inputs';
  txtLinErr = 'Dimension of one of properties equal zero';
  txtStepErr = 'Dimension of one of properties equal zero';
  txtSinErr = 'Dimension of one of properties equal zero';
  txtPilaErr = 'Dimension of one of properties equal zero';
  txtPilaErr1 = 'Period must be great zero';
  txtMeandrErr = 'Dimension of one of arrays equal zero';
  txtSteadyErr = 'Dimension of array xmax or qt less than xmin';
  txtGaussErr = 'Dimension of array d or qt less than m';
  txtTimeAcceptErr = 'Dimensions of arrays tau_on and tau_of must be equal';
  txtArraysCountNotEqu = 'Dimensions not equal';
  txtFirstActiveNumberErr = 'Block may be have a input port';

  {$ENDIF}


implementation

end.
