/*******************************************************************************
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
 |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

 FILE            svm_dskw_frame.sv

 DESCRIPTION     

 *******************************************************************************/

`ifndef AXIL_FRAME_SV
 `define AXIL_FRAME_SV
parameter integer C_S00_AXI_DATA_WIDTH	= 32;
parameter integer C_S00_AXI_ADDR_WIDTH	= 4;

class axil_frame extends uvm_sequence_item;
   
   rand bit [C_S00_AXI_ADDR_WIDTH-1 : 0] address;
   rand bit [C_S00_AXI_DATA_WIDTH-1 : 0] data;
   rand bit avalid;
   rand bit dvalid;
   rand bit read_write;

   //constraint address_constraint{address inside {0,4};};
   
   
   `uvm_object_utils_begin(axil_frame)
      `uvm_field_int(address, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(read_write, UVM_ALL_ON)
      `uvm_field_int(avalid, UVM_ALL_ON)
      `uvm_field_int(dvalid, UVM_ALL_ON)
   `uvm_object_utils_end
   constraint address_constraint {address inside {0, 4, 8};}
   constraint data_constraint {data <= 1;}
   function new(string name = "axil_frame");
      super.new(name);
   endfunction 

endclass : axil_frame

`endif

