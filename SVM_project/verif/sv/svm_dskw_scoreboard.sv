/*******************************************************************************
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
 |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

 FILE            svm_dskw_scoreboard.sv

 DESCRIPTION     

 *******************************************************************************/

`ifndef SVM_DSKW_SCOREBOARD_SV
 `define SVM_DSKW_SCOREBOARD_SV
`uvm_analysis_imp_decl(_bram)
`uvm_analysis_imp_decl(_axis)
`uvm_analysis_imp_decl(_axil)
`uvm_analysis_imp_decl(_interrupt)
class svm_dskw_scoreboard extends uvm_scoreboard;
   
   localparam bit[9:0] sv_array[0:9] = {10'd361, 10'd267, 10'd581, 10'd632, 10'd480, 10'd513, 10'd376, 10'd432, 10'd751, 10'd683};
   localparam bit[9:0] IMG_LEN = 10'd784; 
   // control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;
   bit res_ready = 0;
   bit[3:0] result =0;
   int img=0;
   int core=0;
   int sv=0;
   int l=0;
   logic[15 : 0] yQ[$];
   logic[15 : 0] bQ[10];
   logic[15 : 0] ltQ[10][$];
   logic[15 : 0] svQ[10][$];

   int           num_of_assertions = 0;   
   // This TLM port is used to connect the scoreboard to the monitor
   uvm_analysis_imp_bram#(image_transaction, svm_dskw_scoreboard) port_bram;
   uvm_analysis_imp_axis#(axis_frame, svm_dskw_scoreboard) port_axis;
   uvm_analysis_imp_axil#(axil_frame, svm_dskw_scoreboard) port_axil;
   uvm_analysis_imp_interrupt#(interrupt_frame, svm_dskw_scoreboard) port_interrupt;

   int num_of_tr;
   logic [31:0] reference_model_image [784];   
   `uvm_component_utils_begin(svm_dskw_scoreboard)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   function new(string name = "svm_dskw_scoreboard", uvm_component parent = null);
      super.new(name,parent);
      port_bram = new("port_bram", this);
      port_axis = new("port_axis", this);
      port_axil = new("port_axil", this);
      port_interrupt = new("port_interrupt", this);
   endfunction : new
   
   function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("Svm_dskw scoreboard examined: %0d transactions", num_of_tr), UVM_LOW);
      `uvm_info(get_type_name(), $sformatf("Number of mismatch assertions for DUT is: %0d ", num_of_assertions), UVM_NONE);
      
   endfunction : report_phase


   
   function write_bram (image_transaction tr);
      image_transaction tr_clone;
      if(!$cast(tr_clone, tr.clone()))//clone is implemented in image_transaction class
	     `uvm_error(get_type_name(), $sformatf("INVALID CAST"))
      
      if(checks_enable) begin
	      if(!tr_clone.image_deskewed)begin
	         deskew_reference_model(tr_clone, reference_model_image);
            end
	      else begin
	         for(int i  = 0; i < 784; i++)begin
	            assert (tr_clone.image[i] == reference_model_image[i])
               else begin
                  `uvm_error(get_type_name(), $sformatf("pixel mismatch reference modele[%d]: %h \t deskew[%d]: %h",
                  i, reference_model_image[i], i,tr.image[i] ));
                  num_of_assertions++;                  
               end
	         end
	      end
	   end     

   endfunction : write_bram

   function write_axis (axis_frame tr);
      axis_frame tr_clone;
      if(checks_enable) 
      begin
         if(img==0)
         begin
            clear_queues();
            img=1;
            foreach(tr.dataQ[i])
               yQ.push_back(tr.dataQ[i]);
         end
         else if(sv==l)
         begin
            if(sv==sv_array[core])
            begin
              
               bQ[core]=tr.dataQ[0];
               core++;
               sv=0;
               l=0;
               if(core==10)
               begin
                  `uvm_info(get_type_name(), $sformatf("Finished classifying img"), UVM_LOW);
                  calc_res();
                  `uvm_info(get_type_name(), $sformatf("Classified number is: %d",result), UVM_LOW);
                  img=0;
                  core=0;
               end
            end
            else if(sv<sv_array[core])
            begin
               foreach(tr.dataQ[i])
                  svQ[core].push_back(tr.dataQ[i]);
               sv++;
            end
         end
         else if(sv>l)
         begin
            ltQ[core].push_back(tr.dataQ[0]);
            l++;
         end

      end
   endfunction : write_axis

   function write_axil (axil_frame tr);
      axil_frame tr_clone;
      if(checks_enable) begin
         if(tr.address==4 && tr.data==1)
         begin
            res_ready=1;
         end
         else if(tr.address==8 && res_ready)
         begin
            res_ready=0;
            assert(tr.data==result)
            else 
            begin
               `uvm_error(get_type_name(), $sformatf("res mismatch, reference model: %d \t svm: %d",
               result, tr.data));
               num_of_assertions++;               
            end
         end
      end
   endfunction : write_axil

   //write_interrupt function is not needed 
   function write_interrupt (interrupt_frame tr);
      interrupt_frame tr_clone;
      $cast(tr_clone, tr.clone()); 
      if(checks_enable) begin
         // do actual checking here
         // ...
         // ++num_of_tr;
      end
   endfunction : write_interrupt   

   function void deskew_reference_model(image_transaction tr, ref [31:0]new_image [784]);
      bit [15:0] image[784];
      bit [27 : 0] M[3] = {0, 0, 0};
      bit [27 : 0] M2;      
      bit [41 : 0] mu11, mu02 ,temp1, temp2; //61
      bit [41 : 0] xp = 0, yp = 0;
      bit [41 : 0] R2 = 0;
      bit [27 : 0] x1, x2, y2;
      bit [4 : 0]  x, y;
      
      for (int i = 0; i<784; i++)begin
	      image[i] = tr.image[i][15:0];
      end 
      for (x=0; x<28; x++)begin
	      for(y = 0; y<28; y++)begin      
            M[2] = image[x+y*28] + M[2];	
            M[0] += image[x+y*28]*x;            
            M[1] += image[x+y*28]*y;
	      end
      end // for (x=0; x<28; x++)
      M[0] = {M[0][27:10],4'b0}/M[2][27:10];
      M[1] = {M[1][27:10],4'b0}/M[2][27:10];;
      
      for ( x=0; x<28; x++)begin
	      for( y = 0; y<28; y++)begin
            temp1 = ({y,14'b0} - {M[1][17:0], 10'b0}) * ({y,14'b0} - {M[1][17:0], 10'b0});
            temp2 = ({x,14'b0} - {M[0][17:0], 10'b0}) * ({y,14'b0} - {M[1][17:0], 10'b0});
	         mu02 = image[x+28*y] * temp1[41:14] + (mu02);
            mu11 = $signed( image[x+28*y])*$signed(temp2[41:14]) + $signed(mu11);
	      end
      end
      if (mu11[41] == 1)begin
	      temp1 = -mu11;
	      temp1 = {temp1[40:23],5'b0}/(mu02[40:23]);
	      temp2 = {temp1[18:0],9'b0}* $signed({10'b0,4'b1110,14'b0});
	      M[0] = - {temp1[18:0],9'b0};
	      M[1] = temp2[41:14];
      end
      else begin
	      temp1 = mu11;
	      temp1 = {temp1[40:23],5'b0}/(mu02[40:23]);
	      temp2 = {temp1[18:0],9'b0}* $signed({10'b0,4'b1110,14'b0});
	      M[0] =  {temp1[18:0],9'b0};
	      M[1] = -temp2[41:14];
      end
      
      for (x=0; x<28; x++)begin
	      for(y = 0; y<28; y++)begin
	         xp = ({x,28'b0}) + $signed(M[0]) * $signed({9'b0,y,14'b0}) + ({M[1], 14'b0});
            yp = {23'b0, y,28'b0};

            if(xp < {5'b11011,28'b0} && yp <{5'b11011,28'b0} && $signed(xp) >= 0 && $signed(yp) >=0)begin
               
               x1={9'b0 ,xp[32:28], 14'b0};
               x2 = x1 + {13'b0,1'b1,14'b0};
               y2={9'b0 ,yp[32:28], 14'b0} + {13'b0,1'b1,14'b0};
               R2 = ({26'b0, image[x1[18:14]+y2[18:14]*28],14'b0}) - ($signed(xp[41:14]) - $signed(x1)) * $signed(image[x1[18:14]+y2[18:14]*28]);
	            R2 = R2 + ($signed(xp[41:14]) - $signed(x1)) * (image[x2[18:14] + y2[18:14]*28]);
               new_image[x+y*28]=R2[29:14];
	         end
            else	
              new_image[x+y*28]=0;
         end // for (int y = 0; y<28; y++)
      end // for (int x=0; x<28; x++)
      
   endfunction

   function void clear_queues ();
      int c=0;
      yQ={};
      for(int c=0; c<10; c++)
      begin
         bQ[c]=0;
         ltQ[c]={};
         svQ[c]={};   
      end
   endfunction

   function void calc_res ();

      bit [27 : 0] p=0;
      bit [27 : 0] acc=0;
      bit [15 : 0] max_res=0;
      bit [15 : 0] resQ [10];
      bit [3  : 0] cl_num=0;

      bit [31 : 0] i1_tmp=0;		
      bit [31 : 0] i2_tmp=0;		
      bit [84 : 0] i2_tmp1=0;		
      bit [44 : 0] l_tmp=0;		


      for(int j=0; j<10; j++)
         resQ[j]=0;

      for(int core=0; core<10; core++)
      begin
         acc=0;
         for( int sv=0; sv<sv_array[core]; sv++)
         begin
            p=28'h0004000;
            for( int i=0; i<IMG_LEN; i++)
            begin
               i1_tmp=(yQ[i]*svQ[core][sv*IMG_LEN+i]);
               p=p+i1_tmp[29:14];
            end
            //scale
            i2_tmp=p/10;
            i2_tmp1=i2_tmp*i2_tmp*i2_tmp;
            p=i2_tmp1[55:28];
            //lambda
            l_tmp=$signed(p)*$signed(ltQ[core][sv]);
            p=l_tmp[41:14];
            acc=$signed(acc)+$signed(p);
         end
         //bias
         acc=$signed(acc)+$signed(bQ[core]);
         resQ[core]=acc[19:4];
      end

      //find best result
      max_res=resQ[0];
      cl_num=0;
      `uvm_info(get_type_name(), $sformatf("Res for core 0 is: %h",resQ[0]), UVM_MEDIUM);
      for(int i=1; i<10; i++)
      begin
         `uvm_info(get_type_name(), $sformatf("Res for core %d is: %h",i,resQ[i]), UVM_MEDIUM);
         if($signed(max_res)<$signed(resQ[i]))
         begin
            max_res=resQ[i];
            cl_num=i;
	         `uvm_info(get_type_name(), $sformatf("New cl_num: %d",cl_num), UVM_LOW);
         end
      end

      //finished
      result=cl_num;
   endfunction

endclass : svm_dskw_scoreboard

`endif

