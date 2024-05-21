// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps


// interface
interface Conn;

	// Inputs
  logic [50:0] msg;
	logic clk;
	logic reset;
	logic active_encoder;

	// Outputs
  logic [0:62] out;
  
  	covergroup cg @(posedge clk);
    		option.per_instance = 1;
    		cp_msg: coverpoint msg;
    		cp_reset: coverpoint reset;
    		cp_active_encoder: coverpoint active_encoder;
    		
      		cp_cross_1 : cross cp_msg, cp_active_encoder;
      
    		cp_out: coverpoint out;
      		
  	endgroup
  
  	cg cg_inst = new();
endinterface




// transcation
class transaction;
  	
  	bit clk;
  rand bit[50:0] msg;
  	rand bit  reset;
  	randc bit active_encoder;
  	
  bit [0:62] out;
  
  	
  
  	function transaction copy();
    		copy = new();
    		copy.clk = this.clk;
    		copy.msg = this.msg;
    		copy.reset = this.reset;
    		copy.active_encoder = this.active_encoder;
    		copy.out = this.out;
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
              	gen_tr.clk = ~gen_tr.clk;
              //	gen_tr.reset = 0;
      			assert(gen_tr.randomize());
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
    		connect.msg <= 0;
    		connect.reset <= 0;
    		connect.active_encoder <= 0;
    		#10;
  	endtask
  
  	task run();
    		forever begin
      			mail.get(driv_tr);
      			//driv_tr.display("DRV");
      			connect.clk <= driv_tr.clk;
      			connect.msg <= driv_tr.msg;
      			connect.reset <= driv_tr.reset;
      			connect.active_encoder <= driv_tr.active_encoder;
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
      			mon_tr.msg = connect.msg;
      			mon_tr.reset = connect.reset;
      			mon_tr.active_encoder = connect.active_encoder;
      			mon_tr.out = connect.out;
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
  
  bit [0:62] out;
 	
  	int count, runs;
  	
task automatic func(
  output bit [0:62] out, 
    input bit clk, 
  input bit [50:0] msg, 
    input bit reset, 
    input bit active_encoder
);
    static bit en_out, ps_out;
  static bit [6:0] ctrl = 7'b0;
    static bit init, hold, load, switch;

    static bit clk_ff = 0;
    bit clkedge;
        
    clkedge = clk && (!clk_ff);
        
    if (clkedge) begin
        if (active_encoder) begin
            ctrl = ctrl + 1;
        end else begin
            ctrl = 7'b0;
        end
    end
    
    clk_ff = clk;
        
    if (clkedge) begin
        if (reset) begin
            init = 0;
            load = 0;
            hold = 0;
            switch = 0;
        end else begin
            case (ctrl)
                7'b0000000: begin
                    init = 1;
                    load = 1;
                    hold = 0;
                    switch = 0;
                end
                7'b0000001: begin
                    init = 0;
                    load = 1;
                    hold = 0;
                    switch = 0;
                end
                7'b0000010: begin
                    init = 0;
                    load = 0;
                    hold = 0;
                    switch = 1;
                end
                7'b0110101: begin
                    init = 0;
                    load = 0;
                    hold = 0;
                    switch = 0;
                end
                7'b1000001: begin
                    init = 0;
                    load = 0;
                    hold = 1;
                    switch = 0;
                end
                default: begin
                    // Default case to avoid latches
                end
            endcase
        end
    end
    
    // Call the piso, encoder_LFSR, and sipo tasks
    piso(ps_out, clkedge, msg, reset, load);    
  	encoder(en_out, ps_out, clkedge, reset, switch, init);
    sipo(out, clkedge, en_out, reset, hold);
endtask

  
task automatic piso(
    output bit ps_out,
    input bit clkedge,
  input bit [50:0] ps_in,
    input bit reset,
    input bit load
);
  static bit [50:0] temp_in;
    
    if (clkedge) begin
        if (reset) begin
            temp_in = 50'b0;
        end else if (load) begin
            temp_in = ps_in;
        end else begin
          temp_in = {temp_in[49:0], 1'b0};
        end
    end

    ps_out = temp_in[6];
endtask


task automatic encoder(
    output bit dout,
    input bit din,
    input bit clkedge,
    input bit reset,
    input bit switch,
    input bit init
);
  static bit [11:0] d;
    static bit df;

    if (clkedge) begin
        if (reset || init) begin
            d = 12'b0;
        end else begin
          d = {df, d[11:1]};
        end
    end

    if (switch) begin
      df = din ^ d[11];
        dout = din;
    end else begin
        df = 1'b0;
      dout = d[11];
    end
endtask


task automatic sipo(
  output bit [0:62] sp_out,
    input bit clkedge,
    input bit sp_in,
    input bit reset,
    input bit hold
);
  static bit [62:0] r;

    if (clkedge) begin
        if (reset) begin
            r = 63'b0;
        end else if (!hold) begin
          r = {sp_in, r[62:1]};
        end
    end

    sp_out = r;
endtask

   	
   	
  	function new(mailbox #(transaction) mail);
    		this.mail = mail;
  	endfunction
  
  	task run();
    		forever begin
      			mail.get(sc_tr);
      		//	sc_tr.display("SCR");
              if(sc_tr.clk)	func(out, sc_tr.clk, sc_tr.msg, sc_tr.reset, sc_tr.active_encoder);
     			runs = runs  + 1;
              if(sc_tr.out != sc_tr.out && sc_tr.clk)
        		begin
//                   sc_tr.display("SCR");
//                   $display("obtained by task %15b",out);
//                   $display("expected result %15b",sc_tr.out);
//                   $error(" xxxxxxxxxxxxxxxxxxxxxxxxx Error @ %0t xxxxxxxxxxxxxxxxxxxxxxxxxxx", $time);
        		end
              else if(sc_tr.clk)
      			begin
                  count = count + 1;
//                   sc_tr.display("SCR");
//                   $display("%15b",out);
//                   $display("%15b",sc_tr.out);
//                   $display(" ------------------Data Match---------------------------------");
     	 		end
              if(runs == 4200000) $display("Successful RUNS %d", count);
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
  
  	BCHEncoder dut(connect.out, connect.msg, connect.clk, connect.reset, connect.active_encoder);
  
  	initial begin
    		connect.clk = 1;
  	end
  
  	always #10 connect.clk <= ~connect.clk;
  
 
  
  	initial begin
    		env = new(connect);
    		env.gen.count = 4200000;
      $display("Inputs RAN = %d \t", (env.gen.count/2));
    		env.run();
  	end
endmodule




