`timescale 1ns / 1ps


// interface
interface Conn;

	logic din;
	logic clk;
	logic reset;
	logic switch;
	logic init;
	
	logic dout;
  
  	covergroup cg @(posedge clk);
    		option.per_instance = 1;
    		cp_din: coverpoint din;
    		cp_reset: coverpoint reset;
    		cp_switch: coverpoint switch;
    		cp_init: coverpoint init;
    		
      		cp_dout: coverpoint dout;
      
      		cross_in_1: cross cp_din, cp_init;
      		cross_in_2: cross cp_din, cp_switch;
      		
      
  	endgroup
  
  	cg cg_inst = new();
endinterface




// transcation
class transaction;
  	
  	bit clk;
  	randc bit din;
  	rand bit reset;
  	randc bit switch;
  	rand bit init;
  
  	constraint c1 {init dist {0:=1, 1:=1};}
  constraint c2 {!(init == 0 && switch ==0) ;}
  	
  	bit dout;
  
  	  
  	function transaction copy();
    		copy = new();
    		copy.clk = this.clk;
    		copy.din = this.din;
    		copy.reset = this.reset;
    		copy.switch = this.switch;
    		copy.init = this.init;
    		copy.dout = this.dout;
  	endfunction
  
  	
  	
endclass





//generator
class generator;
 	transaction gen_tr;
 	mailbox #(transaction) mail;
  
 	int count = 200;
  	event next, done;
  
  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
    		gen_tr = new();
  	endfunction
  
  	task run();
    		repeat(count) begin
      			assert(gen_tr.randomize());
              	gen_tr.clk = ~gen_tr.clk;
              	//gen_tr.reset = 0;
      			mail.put(gen_tr.copy);
      			//gen_tr.display("GEN");
      			@next;
    		end
    	->done;
  	endtask
endclass





//driver
class driver;
  	mailbox #(transaction) mail;
  	transaction driv_tr;
  	virtual Conn connect;
  
  	function new(mailbox #(transaction) mail);
  		this.mail = mail;
  	endfunction
  
  	task reset();
  		    connect.clk <= 0;
    		connect.reset <= 0;
    		connect.switch <= 0;
    		connect.din <= 0;
    		connect.init <= 0;
    		#10;
  	endtask
  
  	task run();
    		forever begin
      			mail.get(driv_tr);
      			//driv_tr.display("DRV");
      			connect.clk <= driv_tr.clk;
      			connect.din <= driv_tr.din;
      			connect.reset <= driv_tr.reset;
      			connect.switch <= driv_tr.switch;
      			connect.init <= driv_tr.init;
      			#10;
    		end
  	endtask
endclass





//monitor
class monitor;
  	mailbox #(transaction) mail;
  	transaction mon_tr;
  	virtual Conn connect;

  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
  	endfunction
  
  	task run();
    		mon_tr = new();
    		forever begin
      			#10;
      			mon_tr.clk = connect.clk;
      			mon_tr.din = connect.din;
      			mon_tr.reset = connect.reset;
      			mon_tr.switch = connect.switch;
      			mon_tr.init = connect.init;
      			mon_tr.dout = connect.dout;
      			mail.put(mon_tr);
      			//mon_tr.display("MON");
    		end
  	endtask
endclass




//scoreboard
class scoreboard;
  	mailbox #(transaction) mail;
  	transaction sc_tr;
  	event next;
  
  	int count, runs;
  	
  	
  	bit dout;
  	
task automatic func(
    output bit dout,
    input bit clk,
    input bit din,
    input bit reset,
    input bit switch,
    input bit init
);
    static bit d0, d1, d2, d3, d4, d5, d6, d7;
    static bit df;
    static bit clk_ff = 0; // Initialize clock flip-flop
    bit clkedge;

    // Clock edge detection
    clkedge = clk && (!clk_ff);

    if (clkedge) begin
        if (reset || init) begin
            d0 = 1'b0;
            d1 = 1'b0;
            d2 = 1'b0;
            d3 = 1'b0;
            d4 = 1'b0;
            d5 = 1'b0;
            d6 = 1'b0;
            d7 = 1'b0;
            df = 1'b0; // Reset df as well
        end else begin
            d0 = df;
            d1 = d0;
            d2 = d1;
            d3 = d2;
            d4 = df ^ d3;
            d5 = d4;
            d6 = df ^ d5;
            d7 = df ^ d6;
        end
    end

    // Combinational logic
    if (switch) begin
        df = din ^ d7;
        dout = din;
    end else begin
        df = 1'b0;
        dout = d7;
    end

    clk_ff = clk;
endtask



  	
  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
  	endfunction
  
  	task run();
    		forever begin
      			mail.get(sc_tr);
      			//sc_tr.display("SCR");
              func(dout, sc_tr.clk, sc_tr.din, sc_tr.reset, sc_tr.switch, sc_tr.init);
     
              runs = runs + 1;
              if(sc_tr.dout != dout && sc_tr.clk==1)
        		begin
                  	//	sc_tr.display("SCR");
                 	//	$display("Result we get from task -- %d", dout);
                  	//	$display("Result expected -- %d", sc_tr.dout);
                  	//	$error(" xxxxxxxxxxxxxxxxxxxxxxxxxx Error xxxxxxxxxxxxxxxxxxxxxxxxxxx");
        		end
              else if (sc_tr.clk)
      			begin
                  		count = count + 1;
                  	//sc_tr.display("SCR");
                  	//	$display(" -----------------------Data Match----------------------------");
     	 		end
              if (runs==10000) $display("Successful RUNS = %d",count);
       		->next;
    		end
  	endtask
endclass




//environment
class environment;
  	generator gen;
  	driver drv;
  	mailbox #(transaction) gdmail;
  
  	monitor mon;
  	scoreboard sco;
  	mailbox #(transaction) msmail;
  
  	virtual Conn connect;
  
  	event nextgs;
  
  	function new(virtual Conn connect);
    		gdmail = new();
    		gen = new(gdmail);
    		drv = new(gdmail);
    
    		msmail = new();
    		mon = new(msmail);
    		sco = new(msmail);
    
    		this.connect = connect;
    
    		drv.connect = connect;
    		mon.connect = connect;
    
    		gen.next = nextgs;
    		sco.next = nextgs;
  	endfunction
  
  	task pre_test();
    		drv.reset();
  	endtask
  
  	task test();
    		fork
      			gen.run();
      			drv.run();
      			mon.run();
      			sco.run();
    		join_any
  	endtask
  
  	task post_test();
    		wait(gen.done.triggered);
    		$display("Coverage = %0.2f ", connect.cg_inst.get_inst_coverage());
    		#10;
    		$finish();
  	endtask
  
  
  	task run();
    		pre_test();
    		test();
    		post_test();
  	endtask
endclass





// testbench
module tb;
  	environment env;
  	Conn connect();
  
  	encoder_LFSR dut(connect.dout,connect.din, connect.clk, connect.reset, connect.switch, connect.init);
  
  	initial begin
    		connect.clk = 1;
  	end
  
  	always #10 connect.clk <= ~connect.clk;
  
 
  
  	initial begin
    		env = new(connect);
    		env.gen.count = 10000;
      $display("Inputs RAN = %d \t", (env.gen.count)/2);
    		env.run();
  	end
endmodule



