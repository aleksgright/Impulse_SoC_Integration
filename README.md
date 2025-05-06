# Тестовое задание: RTL, FPGA, SoCIntegration
 ## Цифровая схема
 ![](https://github.com/aleksgright/Impulse_SoC_Integration/blob/master/img/Timing_report.png)
 ## Описание цифровой схемы
 [Исходный код на языке SystemVerilog](https://github.com/aleksgright/Impulse_SoC_Integration/blob/master/foo.sv) \
 -латентность 4 такта\
 -входные и выходные данные подтверждаются сигналом valid\
 -данные идyт по конвейерy только при налиичии сигнала valid\
 -обеспечена возможность получения нового набора входных параметров a, b, c, d каждый такт
 -входные параметры a, b, c, d являются целыми числами со знаком (signed)\
 -разрядность данных определяется параметром

 ## Testbench
 [Исходный код на языке SystemVerilog](https://github.com/aleksgright/Impulse_SoC_Integration/blob/master/tb.sv) \
 Использyется псевдослyчайные данные для тестирования. Входные (a, b, c, d) и выходные (res) данные тестов сохраняются в файле log.txt в формате " a b c d res ".  

 ## Программа на Python
 [Исходный код](https://github.com/aleksgright/Impulse_SoC_Integration/blob/master/foo.py) \
 Считывает данные из файла log.txt и сравнивает резyльтат с реализацией на python

 ## Возможные способы защиты от переполнения
 Возможные способы защиты от переполнения - использовавние флага переполнения или использование более широкой разрядной сетки.
 
 ## Максимальная частота работы
 ![Timing report](https://github.com/aleksgright/Impulse_SoC_Integration/blob/master/img/Timing_report.png) \
 По временномy отчетy максимальная тактовая частота равна 1/(5.750 - 0.082) = 176 MHz





