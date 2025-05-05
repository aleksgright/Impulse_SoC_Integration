// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module testbench;


    //---------------------------------
    // Сигналы
    //---------------------------------

    logic        clk;
    logic        rst;

    logic [31:0] a_in;
    logic [31:0] b_in;
    logic [31:0] c_in;
    logic [31:0] d_in;
    logic        arg_vld;

    logic        res_vld;
    logic [31:0] res;

    localparam WIDTH = 32;
  
  	int f;

    //---------------------------------
    // Модуль для тестирования
    //---------------------------------

    foo #(.width(WIDTH)) DUT (
        .clk      ( clk       ),
        .rst  ( rst   ),

        .arg_vld ( arg_vld  ),
        .a_in ( a_in  ),
        .b_in  ( b_in   ),
        .c_in    ( c_in     ),
        .d_in  ( d_in   ),

        .res ( res  ),
        .res_vld ( res_vld  )
    );


    //---------------------------------
    // Переменные тестирования
    //---------------------------------

   // Период тактового сигнала
    parameter CLK_PERIOD = 10;

    // Пакет и mailbox'ы
    typedef struct {
        rand int          delay;
        rand logic [31:0] a;
        rand logic [31:0] b;
        rand logic [31:0] c;
        rand logic [31:0] d;
        logic [31:0] res;
    } packet;

    mailbox#(packet) gen2drv = new();
    mailbox#(packet) in_mbx  = new();
    mailbox#(packet) out_mbx = new();


    //---------------------------------
    // Методы
    //---------------------------------

    task stop();
        $fclose(f);
        $stop();
    endtask    

    // Генерация сигнала сброса
    task reset();
        rst <= 1;
        #(CLK_PERIOD);
        rst <= 0;
    endtask

    // Таймаут теста
    task timeout(int timeout_cycles = 100000);
        repeat(timeout_cycles) @(posedge clk);
        $display("Testbench stopped due to timeout");
        $stop();
    endtask

    // Генерация входных данных
    task gen_input(
        int data_min   = -1*(2**(WIDTH/2)),
        int data_max   = 2**(WIDTH/2),
        int delay_min  = 0,
        int delay_max  = 10
    );
        packet p;
        int a,b,c,d;
        p.delay = $urandom_range(delay_max,delay_min);
        p.a = $urandom_range(data_max, data_min) - (data_max + data_min)/2;
        p.b = $urandom_range(data_max, data_min) - (data_max + data_min)/2;
        p.c = $urandom_range(data_max, data_min) - (data_max + data_min)/2;
        p.d = $urandom_range(data_max, data_min) - (data_max + data_min)/2;
        gen2drv.put(p);
    endtask

    task do_gen_input(
        int pkt_amount = 100,
        int data_min   = -1*(2**(WIDTH/2)),
        int data_max   = 2**(WIDTH/2),
        int delay_min  = 0,
        int delay_max  = 10
    );
        repeat(pkt_amount) begin
          gen_input(data_min, data_max, delay_min, delay_max);
        end
    endtask

    task reset_tb();
        wait(rst);
        arg_vld <= 0;
        wait(!rst);
    endtask

    task drive_input(packet p);
        repeat(p.delay) @(posedge clk);
        arg_vld <= 1;
        a_in  <= p.a;
        b_in  <= p.b;
        c_in  <= p.c;
        d_in  <= p.d;
        @(posedge clk);
        arg_vld <= 0;
    endtask

    task do_input_drive();
        packet p;
        reset_tb();
        @(posedge clk);
        forever begin
            gen2drv.get(p);
            drive_input(p);
        end
    endtask

    task monitor_input();
        packet p;
        @(posedge clk);
        if( arg_vld ) begin
            p.a  = a_in;
            p.b  = b_in;
            p.c  = c_in;
            p.d  = d_in;
            in_mbx.put(p);
        end
    endtask

    task do_monitor_input();
        wait(rst);
        forever begin
            monitor_input();
        end
    endtask

    // Input
    task in(        
        int gen_pkt_amount = 100,
        int gen_data_min   = -1*(2**(WIDTH/2)),
        int gen_data_max   = 2**(WIDTH/2),
        int gen_delay_min  = 0,
        int gen_delay_max  = 10
    );
        fork
            do_gen_input(gen_pkt_amount, gen_data_min, gen_data_max, gen_delay_min, gen_delay_max);
            do_input_drive();
            do_monitor_input();
        join
    endtask

    task monitor_output();
        packet p;
        @(posedge clk);
        if( res_vld ) begin
            p.res  = res;
            out_mbx.put(p);
        end
    endtask

    task do_monitor_output();
        wait(rst);
        forever begin
            monitor_output();
        end
    endtask

    // Output
    task out();
        do_monitor_output();
    endtask

    // Проверка
    task check(packet in, packet out);
        int expected;
        $fdisplay(f, "%d %d %d %d %d", $signed(in.a), $signed(in.b), $signed(in.c), $signed(in.d), $signed(out.res));
      	expected = $signed((in.a - in.b) * (1 + 3 * in.c) - 4 * in.d) >>> 1;
        if (expected < 0)
            expected = expected + 1;
        if( out.res !== expected) begin
            $error("%0t Invalid Res: Real: %0d, Expected: %0d",
                $time(), $signed(out.res), $signed(expected));
        end
    endtask

    task do_check(int pkt_amount = 1);
        int cnt;
        packet in_p, out_p;
        forever begin
            in_mbx.get(in_p);
            out_mbx.get(out_p);
            check(in_p, out_p);
            cnt = cnt + 1;
            if( cnt == pkt_amount ) begin
                break;
            end
        end
        stop();
    endtask

    task error_checker(int pkt_amount = 1);
        do_check(pkt_amount);
    endtask


    //---------------------------------
    // Выполнение
    //---------------------------------

    // Файл для записи аргyметов и резyльтатов
    initial begin
        f = $fopen("E:/Impulse/rtl_fpga/log.txt", "w");
    end

    // Генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk <= ~clk;
        end
    end

    task test(
        int gen_pkt_amount   = 100,    
        int gen_data_min     = -1*(2**(WIDTH/2)),
        int gen_data_max     = 2**(WIDTH/2),    
        int gen_delay_min    = 0,   
        int gen_delay_max    = 10,  
        int timeout_cycles   = 100000 
    );
        fork
            in    (gen_pkt_amount, gen_data_min, gen_data_max, gen_delay_min, gen_delay_max);
            out       ();
            error_checker(gen_pkt_amount);
            timeout      (timeout_cycles);
        join
    endtask

    initial begin
        fork
            reset();
        join_none
        test(
            .gen_pkt_amount (    10000),
            .gen_data_min   (    0),
            .gen_data_max   (    10000),
            .gen_delay_min  (     0),
            .gen_delay_max  (     5),
            .timeout_cycles (10000000)
        );
    end

endmodule