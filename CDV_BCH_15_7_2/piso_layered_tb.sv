// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps



// interface
interface Conn;

	logic [6:0] ps_in;
	logic clk;
	logic reset;
	logic load;
	
	logic ps_out;
  
  	covergroup cg @(posedge clk);
    		option.per_instance = 1;
    		cp_ps_in: coverpoint ps_in {bins ps_in_bin[] = {[0:127]};}
		cp_reset: coverpoint reset;
    		cp_load: coverpoint load;
    		cp_ps_out: coverpoint ps_out;

      	
      		cross_in_1: cross cp_ps_in, cp_load;
      		
      
  	endgroup
  
  	cg cg_inst = new();
endinterface



// transcation
class transaction;
  	
  	bit clk;
  	rand bit reset;
  	randc bit load;
  	randc bit [6:0] ps_in;
  	
  	bit ps_out;
  
  	  
  	function transaction copy();
    		copy = new();
    		copy.clk = this.clk;
    		copy.load = this.load;
    		copy.reset = this.reset;
    		copy.ps_in = this.ps_in;
    		copy.ps_out = this.ps_out;
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
    		connect.load <= 0;
    		connect.ps_in <= 0;
    		#10;
  	endtask
  
  	task run();
    		forever begin
      			mail.get(driv_tr);
      			//driv_tr.display("DRV");
      			connect.clk <= driv_tr.clk;
      			connect.ps_in <= driv_tr.ps_in;
      			connect.reset <= driv_tr.reset;
      			connect.load <= driv_tr.load;
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
      			mon_tr.ps_in = connect.ps_in;
      			mon_tr.reset = connect.reset;
      			mon_tr.load = connect.load;
      			mon_tr.ps_out = connect.ps_out;
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
  
    bit ps_out;
  	//bit [6:0] temp;
  	int count, runs;
  	
  //bit clk_ff, clkedge;
  //bit ps_temp;
  	
  	task automatic func(
    output bit ps_out,
    input bit clk,
    input bit [6:0] ps_in,
    input bit reset,
    input bit load
);
    static bit [6:0] temp;
    static bit ps_temp;
    static bit clk_ff;
    bit clkedge;

    

    // Clock edge detection
    clkedge = clk && (!clk_ff);

    if (clkedge) begin
        if (reset) begin
            temp = 7'b0;
            ps_temp = temp[6];
        end else begin
            if (load) begin
                temp = ps_in;
                ps_temp = temp[6];
            end else begin
                temp = {temp[5:0], 1'b0};
                ps_temp = temp[6];
            end
        end
    end

    ps_out = ps_temp;
    clk_ff = clk;
endtask



      
      
  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
  	endfunction
  
  	task run();
    		forever begin
      			mail.get(sc_tr);
      			//sc_tr.display("SCR");
             
              	func(ps_out,sc_tr.clk,sc_tr.ps_in,sc_tr.reset,sc_tr.load);
     
              runs = runs +1;
              if(sc_tr.ps_out == ps_out && sc_tr.clk==1)
        		begin
                  count = count+1;
                   //$display("%1b ", ps_out);
                   //$display("%1b ", sc_tr.ps_out);
                  //$display(" -------------------------Data Match----------------------------");
                  
        		end
      			else 
      			begin
                 
                  
                  // $error("%1b ", ps_out);
                  // $error("%1b ", sc_tr.ps_out);
                 // $error(" xxxxxxxxxxxxxxxxxxxxxxxxx Error @ %0t xxxxxxxxxxxxxxxxxxxxxxxxxxx", $time);
                end  
     	 		
              
              if (runs == 8000) $display("Successful RUNS = %d",count);
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
  
  	piso dut(connect.ps_out, connect.ps_in, connect.clk, connect.reset, connect.load);
  
  	initial begin
    		connect.clk = 1;
  	end
  
  	always #10 connect.clk <= ~connect.clk;
  
 
  
  	initial begin
    		env = new(connect);
    		env.gen.count = 8000;
      $display("Inputs RAN = %d \t", env.gen.count/2);
    		env.run();
  	end
endmodule





