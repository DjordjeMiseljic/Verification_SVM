/*******************************************************************************
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
 |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

 FILE            svm_dskw_interrupt_monitor.sv

 DESCRIPTION     

 *******************************************************************************/

`ifndef SVM_DSKW_INTERRUPT_MONITOR_SV
 `define SVM_DSKW_INTERRUPT_MONITOR_SV

class svm_dskw_interrupt_monitor extends uvm_monitor;

   // control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;

   uvm_analysis_port #(interrupt_frame) item_collected_port;

   `uvm_component_utils_begin(svm_dskw_interrupt_monitor)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   // The virtual interface used to drive and view HDL signals.
   virtual interface interrupt_if vif;//only use sugnals for bram communication!!!!

   // current transaction
   interrupt_frame current_frame;//here you will need dskw_frame insteade of svm_dskw_frame

   // coverage can go here
   covergroup interrupt_cg;
      option.per_instance = 1;
      interrupt_cpt: coverpoint vif.done_interrupt{
         bins interrupt_happened = {1};
      }      
   endgroup
   // ...

   function new(string name = "svm_dskw_interrupt_monitor", uvm_component parent = null);
      super.new(name,parent);
      item_collected_port = new("item_collected_port", this);
      interrupt_cg = new();      
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(virtual interrupt_if)::get(this, "*", "interrupt_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   endfunction : connect_phase

   task run_phase(uvm_phase phase);
      forever begin
	 current_frame = interrupt_frame::type_id::create("current_frame", this);
	 // ...
	 // collect transactions
	 // ...
	 @(posedge vif.clk)begin
	    if(vif.done_interrupt)begin
	       `uvm_info(get_type_name(),
			 $sformatf("INTERRUPT HAPPENED"),
			 UVM_FULL)
	       interrupt_cg.sample();          
	       item_collected_port.write(current_frame);
	    end
	 end
      end
   endtask : run_phase

endclass : svm_dskw_interrupt_monitor

`endif

