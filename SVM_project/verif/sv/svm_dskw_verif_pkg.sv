/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            svm_dskw_verif_pkg.sv

    DESCRIPTION     package

*******************************************************************************/

`ifndef SVM_DSKW_VERIF_PKG_SV
`define SVM_DSKW_VERIF_PKG_SV

package svm_dskw_verif_pkg;

    import uvm_pkg::*;            // import the UVM library
    `include "uvm_macros.svh"     // Include the UVM macros

    `include "svm_dskw_config.sv"
    `include "svm_dskw_frame.sv"
    `include "svm_dskw_driver.sv"
    `include "svm_dskw_sequencer.sv"
    `include "svm_dskw_monitor.sv"
    `include "svm_dskw_agent.sv"

    `include "svm_dskw_scoreboard.sv"
    `include "svm_dskw_env.sv"

    `include "sequences/svm_dskw_seq_lib.sv"
    `include "tests/test_lib.sv"

endpackage : svm_dskw_verif_pkg

`include "svm_dskw_if.sv"

`endif

