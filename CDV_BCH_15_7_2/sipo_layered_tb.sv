// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps


// interface
interface Conn;

	logic sp_in;
	logic clk;
	logic reset;
	logic hold;
	
	logic [0:14] sp_out;
  
  	covergroup cg @(posedge clk);
    		option.per_instance = 1;
    		cp_sp_in: coverpoint sp_in;
    		cp_reset: coverpoint reset;
    		cp_hold: coverpoint hold;
      		cp_out: coverpoint sp_out[0];
      		//cp_sp_out: coverpoint sp_out;
      
      	
      		cross_in: cross cp_sp_in, cp_hold;		
      
  	endgroup
  
  	cg cg_inst = new();
endinterface



// transcation
class transaction;
  	
  	bit clk;
  	rand bit reset;
  	randc bit hold;
  	randc bit  sp_in;
  	
  	bit [0:14] sp_out;
  
  	
  
  	function transaction copy();
    		copy = new();
    		copy.clk = this.clk;
    		copy.hold = this.hold;
    		copy.reset = this.reset;
    		copy.sp_in = this.sp_in;
    		copy.sp_out = this.sp_out;
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
              //	gen_tr.reset = 0;
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
    		connect.hold <= 0;
    		connect.sp_in <= 0;
    		#10;
  	endtask
  
  	task run();
    		forever begin
      			mail.get(driv_tr);
      			//driv_tr.display("DRV");
      			connect.clk <= driv_tr.clk;
      			connect.sp_in <= driv_tr.sp_in;
      			connect.reset <= driv_tr.reset;
      			connect.hold <= driv_tr.hold;
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
      			mon_tr.sp_in = connect.sp_in;
      			mon_tr.reset = connect.reset;
      			mon_tr.hold = connect.hold;
      			mon_tr.sp_out = connect.sp_out;
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
  
    bit [0:14] sp_out;
  	//bit [14:0] r;
  	
  	//bit clk_ff, clkedge;
  	
  	int count;
  	int runs;	
  
 	task automatic func(
    output bit [14:0] sp_out,  // Changed to [14:0] to match SystemVerilog conventions
    input bit clk,
    input bit sp_in,
    input bit reset,
    input bit hold
);
    static bit [14:0] r;  // Changed to [14:0] for consistency
    static bit clk_ff;
    bit clkedge;


    // Clock edge detection
    clkedge = clk && (!clk_ff);

    if (clkedge) begin
        if (reset) begin
            r = 15'b000_0000_0000_0000;
        end else if (hold) begin
            r = r;  // No change
        end else begin
            r = {sp_in, r[14:1]};  // Shift right and insert sp_in at MSB
        end
    end

    sp_out = r;
    clk_ff = clk;
endtask


   	
   	
   	
  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
  	endfunction
  
  	task run();
    		forever begin
      			mail.get(sc_tr);
      			//sc_tr.display("SCR");
              	func(sp_out,sc_tr.clk,sc_tr.sp_in,sc_tr.reset,sc_tr.hold);
     
              	runs = runs + 1;
                if(sc_tr.sp_out == sp_out && sc_tr.clk==1)
        		begin
                  count = count+1;
                  //$display(" -------------------Data Match-----------------------");
                  //$display(count);
                  
        		end
      			else 
      			begin
                  //$error(" xxxxxxxxxxxxxxxxxx Error @ %0t xxxxxxxxxxxxxxxx", $time);
                  
                  //$display(count);
                end
              
              if (runs==1200) $display("Successful RUNS = %d",count);
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
  
  	sipo dut(connect.sp_out, connect.sp_in, connect.clk, connect.reset, connect.hold);
  
  	initial begin
    		connect.clk = 1;
  	end
  
  	always #10 connect.clk <= ~connect.clk;
  
 
  
  	initial begin
    		env = new(connect);
    		env.gen.count = 1200;
      $display("Inputs RAN = %d \t", env.gen.count/2);
    		env.run();
  	end
endmodule

