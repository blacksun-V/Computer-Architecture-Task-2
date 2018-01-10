`ifdef mem_sim.v
`else
 `define mem_sim.v
// --------------------------------------------------------------------------------
 `include "defines.v"

module mem_sim
  (
   input wire 		     clk,
   input wire 		     rom_ce,
   input wire 		     mem_ce,
   
   input wire [`InstAddrBus] pc_addr,
   output reg [`InstBus]     inst,

   // About memory
   input wire 		     we,
   input wire [`DataAddrBus] addr,
   input wire [3:0] 	     sel,
   input wire [`DataBus]     data_i,
   output reg [`DataBus]     data_o
   );

   reg[`InstBus]  mem_data[0:`MemNumber];
   
   initial $readmemh("instr.data",mem_data);

   // --------------------------------------------------Fetch Instructions--------------------------------------------------
   always @ (*)
     begin
	if (rom_ce == `ChipDisable) inst <= `ZeroWord;
	else
	  begin
	     inst <= {mem_data[pc_addr>>2][7:0],mem_data[pc_addr>>2][15:8],
		      mem_data[pc_addr>>2][23:16],mem_data[pc_addr>>2][31:24]};
	  end
     end

   // --------------------------------------------------Store--------------------------------------------------
   always @ (posedge clk) 
     begin

	if (mem_ce == `ChipDisable) data_o <= `ZeroWord;
	
	else if(we == `WriteEnable)
	  begin     
	     if (sel[0] == 1'b1) 
	       begin 
		  mem_data[addr>>2][31:24] <= data_i[7:0];
		  // $display("Store %h in %h.",data_i[31:24],((addr>>2)<<2)+3);
		  if ((addr>>2) == (32'h00000104>>2))
		    $display("Print (%c)",data_i[7:0]);
	       end
	     if (sel[1] == 1'b1) 
	       begin
		  mem_data[addr>>2][23:16] <= data_i[15:8];
	     	  // $display("Store %h in %h.",data_i[23:16],((addr>>2)<<2)+2);
	       end
	     if (sel[2] == 1'b1) 
	       begin
		  mem_data[addr>>2][15:8] <= data_i[23:16];
		  // $display("Store %h in %h.",data_i[15:8],((addr>>2)<<2)+1);
	       end
	     if (sel[3] == 1'b1) 
	       begin
		  mem_data[addr>>2][7:0] <= data_i[31:24];
		  // $display("Store %h in %h.",data_i[7:0],((addr>>2)<<2));
	       end
	  end
	
     end

   // --------------------------------------------------Load--------------------------------------------------
   always @ (*) 
     begin
	if (mem_ce == `ChipDisable) data_o <= `ZeroWord;
	else if(we == `WriteDisable)
	  begin
	     data_o <= {mem_data[addr>>2][7:0],mem_data[addr>>2][15:8],
		      mem_data[addr>>2][23:16],mem_data[addr>>2][31:24]};
	     // $display("Load %h at %h.",{mem_data[addr>>2][7:0],mem_data[addr>>2][15:8],
					// mem_data[addr>>2][23:16],mem_data[addr>>2][31:24]},{addr[31:2],2'b00});
	  end
	else data_o <= `ZeroWord;
     end		

   
endmodule // inst_rom

// --------------------------------------------------------------------------------
`endif