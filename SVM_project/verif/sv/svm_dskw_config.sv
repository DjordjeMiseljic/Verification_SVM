/*******************************************************************************
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
 |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

 FILE           svm_dskw_config.sv

 DESCRIPTION     

 *******************************************************************************/

`define SVM_DSKW
`ifndef SVM_DSKW_CONFIG_SV
 `define SVM_DSKW_CONFIG_SV
typedef enum {WITH_BRAM, WITHOUT_BRAM} bram_cfg;
typedef enum {WITH_AXIS, WITHOUT_AXIS} axis_cfg;
class svm_dskw_config extends uvm_object;

   uvm_active_passive_enum is_active = UVM_ACTIVE;
   
   `ifdef SVM_DSKW
   bram_cfg is_bram = WITHOUT_BRAM;
   axis_cfg is_axis = WITH_AXIS;   
   `else
   bram_cfg is_bram = WITH_BRAM;
   axis_cfg is_axis = WITHOUT_AXIS;   
   `endif
  
   `uvm_object_utils_begin (svm_dskw_config)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
      `uvm_field_enum(axis_cfg,  is_axis, is_axis);
      `uvm_field_enum(bram_cfg,  is_bram, is_bram);
      
   `uvm_object_utils_end

   function new(string name = "svm_dskw_config");
      super.new(name);
   endfunction

endclass : svm_dskw_config

`endif


