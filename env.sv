define PARAM  DT_WIDTH,RS_WIDTH,RQ_WIDTH
class eye_environment #(
  int DT_WIDTH = 1234,
  int RS_WIDTH = 88,
  int RQ_WIDTH = 183
  )
 extends uvmf_environment_base #(
    .CONFIG_T( eye_env_configuration #(`PARAM)

  ));
  `uvm_component_param_utils( eye_environment #(`PARAM)
)




//tbr   tsv_gio_component#(swx_gio_names)      gio;
    // GIO setup
//tbr    class swx_gio_change_cb extends tsv_gio_cb;
//tbr        eye_environment  env; 
//tbr        function new (eye_environment e);
//tbr            env = e;
//tbr        endfunction
//tbr        function void on_event(string ion);
//tbr            $display("GIO_CB_IOSW in %s for %s EVENT with level %H at %0t",env.get_full_name(), ion, env.gio.get_inp(ion), $time);
//tbr        endfunction
//tbr    endclass
//tbr   swx_gio_change_cb                 gio_cb_event;
//tbr 


  typedef swx_twx_ch_intf_agent #( .DT_WIDTH(DT_WIDTH), .RS_WIDTH(RS_WIDTH), .RQ_WIDTH(RQ_WIDTH)) swx_twx_ch_intf_tx0_agent_t;
  swx_twx_ch_intf_tx0_agent_t swx_twx_ch_intf_agent_i[string];
 
  csr_block_eye_regs                   eye_regmodel_inst;
  


//tbr  typedef eye_predictor #( .DT_WIDTH(DT_WIDTH), .RS_WIDTH(RS_WIDTH), .RQ_WIDTH(RQ_WIDTH), .CONFIG_T(CONFIG_T)) eye_pred_t;
//tbr  eye_pred_t eye_pred;

  eye_intr_agent intr_agt;
  swx_rst_agent  i_swx_rst_agent;
  eye_intf_scoreboard  #(swx_twx_ch_intf_transaction#(`PARAM),`PARAM) eye_scbd;

  typedef aaxi_uvm_agent  axi4_agent_t;
  axi4_agent_t axi_master_intf_agent[string];

//tbr  typedef aaxi_uvm_mem_new  aaxi_uvm_mem_new_t;
//tbr  aaxi_uvm_mem_new_t axi_master_intf_agent_mem[string];

  typedef aaxi_uvm_mem_adapter  axi_master_intf_agent_mem_adapter_t;
  axi_master_intf_agent_mem_adapter_t axi_master_intf_agent_mem_adapter[string];

//tbr  aapb_bridge #(32, 32, 1) apb_brdg;             // VAR: APB bus Bridge agent
//tbr  aapb_uvm_mem_adapter apb_mem_adapter;

  eye_init_sequence #(CONFIG_T,`PARAM) eye_init_seq;

  typedef uvmf_virtual_sequencer_base #(.CONFIG_T(eye_env_configuration#(`PARAM)
)) eye_vsqr_t;
  eye_vsqr_t vsqr;
 
  int tempvar = 0;
  string agent_name;

  // pragma uvmf custom class_item_additional begin
  // pragma uvmf custom class_item_additional end
 
// ****************************************************************************
// FUNCTION : new()
// This function is the standard SystemVerilog constructor.
//
  function new( string name = "", uvm_component parent = null );
    super.new( name, parent );
    uvm_config_db#(eye_environment#(`PARAM))::set(null,UVMF_CONFIGURATIONS, "TOP_ENV",this);
    `uvm_info(get_full_name(), $psprintf(" Environment new DT_WIDTH=%0d RS_WIDTH=%0d RQ_WIDTH=%0d",DT_WIDTH,RS_WIDTH,RQ_WIDTH), UVM_LOW);
    //tbd eye_env_pkg::global_env_ptr = this;
    //tbr gio_cb_event = new(this);
  endfunction

// ****************************************************************************
// FUNCTION: build_phase()
// This function builds all components within this environment.
//
  virtual function void build_phase(uvm_phase phase);
   string agent_str, agent_mem_str, agent_mem_adapter_str, driver_str, agent_cb_str, agent_name;
   bit ok;
   string tmp;

  
//tbr   llc_aaxi_driver_uvm_cb2 cb_axi4_master[string];
// pragma uvmf custom build_phase_pre_super begin
// pragma uvmf custom build_phase_pre_super end
    super.build_phase(phase);
    configuration.set_soc_config();

    foreach(configuration.dv_intf_activities[AXI_MASTER_INTF][agent_name]) 
    begin            
      $sformat(agent_str, "axi_master_intf_agent_%s", agent_name);
      $sformat(driver_str, "%s.driver", agent_str);

      `uvm_info(get_full_name(), $psprintf(" : build agent eye_master_agent_%s", agent_name), UVM_LOW);
      axi_master_intf_agent[agent_name] = axi4_agent_t::type_id::create(agent_str, this);
      axi_master_intf_agent[agent_name].dev_type = AAXI_MASTER;
      uvm_config_db #(int)::set(this, {agent_str}, "port_id", tempvar);
      uvm_config_db #(aaxi_protocol_version)::set(this, driver_str, "vers", AAXI4);
      
//tbr      $sformat(agent_mem_str , "%0s_axi_master_intf_agent_mem_%s", this.get_name(), agent_name);
//tbr      `uvm_info(get_full_name(), $psprintf(" : build agent %s", agent_mem_str), UVM_LOW);
//tbr      axi_master_intf_agent_mem[agent_name] = aaxi_uvm_mem_new_t::type_id::create(agent_mem_str, this);
//tbr      axi_master_intf_agent_mem[agent_name].base_addr    = configuration.axi4_mem_base_addr;
//tbr      axi_master_intf_agent_mem[agent_name].num_location = configuration.axi4_num_location;
//tbr      axi_master_intf_agent_mem[agent_name].build_phase(phase);
//tbr      axi_master_intf_agent_mem[agent_name].lock_model();
//tbr      //axi_master_intf_agent_mem[agent_name].is_active == configuration.dv_intf_activities[AXI_MASTER_INTF][agent_name]==ACTIVE?UVM_ACTIVE?UVM_PASSIVE;
//tbr      
//tbr      uvm_config_db #(aaxi_uvm_mem_new_t)::set(uvm_root::get(), "*", agent_mem_str, axi_master_intf_agent_mem[agent_name]);      
//tbr      
//tbr      if(agent_name=="axi_in") begin
//tbr        $sformat(agent_cb_str , "cb_axi4_master_%s",agent_name);
//tbr        cb_axi4_master[agent_name] = llc_aaxi_driver_uvm_cb2::type_id::create(agent_cb_str, this);
//tbr        //cb_axi4_master.mem_model = axi_master_intf_agent_mem;
//tbr        uvm_callbacks#(aaxi_device_class, aaxi_callbacks)::add(axi_master_intf_agent["axi_in"].driver, cb_axi4_master[agent_name]);
//tbr        
//tbr        cb_axi4_master[agent_name].c_done_event = this.c_done_event;
//tbr        cb_axi4_master[agent_name].c_config_done_event = this.c_config_done_event;
//tbr      end
      
      $sformat(agent_mem_adapter_str , "%0s_axi_master_intf_agent_mem_adapter_%s", this.get_name(), agent_name);
      `uvm_info(get_full_name(), $psprintf("%m: build agent %s", agent_mem_adapter_str), UVM_LOW);
      axi_master_intf_agent_mem_adapter[agent_name] = axi_master_intf_agent_mem_adapter_t::type_id::create(agent_mem_adapter_str, this);
    end
    
    uvm_config_db #(aaxi_protocol_version)::set(uvm_root::get(), "*", "vers", AAXI4);
    

//tbr    // APB
//tbr    apb_brdg = aapb_bridge#(32, 32, 1)::type_id::create("apb_brdg", this);
//tbr    uvm_config_db#(aapb_device_mode_e)::set(this, "apb_brdg", "dev_mode", AAPB_DEV_ACTIVE);
//tbr    apb_mem_adapter = aapb_uvm_mem_adapter::type_id::create("apb_mem_adapter", this);
//tbr    uvm_config_db #(aapb_uvm_mem_adapter)::set(this, "*", "apb_mem_adapter", apb_mem_adapter);
    // register model
//tbr    if (!configuration.is_top) begin
      eye_regmodel_inst = csr_block_eye_regs::type_id::create($psprintf("%0s.eye_regmodel_inst", configuration.env_path), this);
      eye_regmodel_inst.build();
      eye_regmodel_inst.set_hdl_path_root($psprintf("%0s",configuration.my_hdl_root));
      begin
        string hdl_p;
        bit[7:0] rd_val;

        hdl_p = $psprintf("%0s.eye_nic_ba_strap",configuration.my_hdl_root);
        if(!uvm_hdl_read(hdl_p, rd_val))
        begin `uvm_fatal (get_name(), $psprintf("eye_nic_ba_strap:Read from %0s failed",hdl_p)) end
        eye_regmodel_inst.default_map.set_base_addr(rd_val << 24);
        `uvm_info(get_name(), $psprintf("regmodel base_addr=%0h",rd_val), UVM_LOW);
      end
      //tbr eye_regmodel_inst.default_map.set_base_addr(32'h00000000);
      eye_regmodel_inst.lock_model();
      configuration.my_reg_blk = eye_regmodel_inst;
      populate_reg_blk(eye_regmodel_inst);
//tbr    end else begin
//tbr      if (!configuration.eye_regmodel_inst)
//tbr      `uvm_fatal(get_full_name(), $psprintf("In is_top mode top level did not provide reference to regmodel in side configuration"));
//tbr      eye_regmodel_inst = configuration.eye_regmodel_inst;
//tbr    end    
    uvm_config_db #(csr_block_eye_regs)::set(uvm_root::get(), "*", $psprintf("%0s.eye_regmodel_inst", configuration.env_path), eye_regmodel_inst);
    foreach(configuration.agt_cfgs[p,m,r,c,po,tx_rx])
    begin
      string tmp;
      tmp = configuration.agt_cfgs[p][m][r][c][po][tx_rx].concat_ids("portid_txrx");
      agent_str = $sformatf("%0s.swx_twx_ch_intf_%0s_agent", configuration.env_path,tmp);
      swx_twx_ch_intf_agent_i[tmp] = swx_twx_ch_intf_tx0_agent_t::type_id::create(agent_str, this);
      swx_twx_ch_intf_agent_i[tmp].set_config(configuration.agt_cfgs[p][m][r][c][po][tx_rx]);
    end

     intr_agt = eye_intr_agent::type_id::create("eye_intr_agent",this);
     intr_agt.my_reg_blk = configuration.my_reg_blk;
     intr_agt.my_hdl_root = configuration.my_hdl_root;
     intr_agt.my_env = this;
 
    i_swx_rst_agent = swx_rst_agent::type_id::create($psprintf("%0s_rst_agt",configuration.get_inst_name()),this);
    i_swx_rst_agent.my_reg_blk = configuration.my_reg_blk;
    i_swx_rst_agent.my_hdl_root = configuration.my_hdl_root;
    i_swx_rst_agent.my_env = this;

//tbr    eye_pred = eye_pred_t::type_id::create("eye_pred",this);
//tbr    eye_pred.configuration = configuration;

    eye_scbd   = eye_intf_scoreboard#(swx_twx_ch_intf_transaction#( DT_WIDTH, RS_WIDTH, RQ_WIDTH),DT_WIDTH,RS_WIDTH,RQ_WIDTH)::type_id::create("eye_scbd",this);

    foreach(configuration.swx_agt_cfg[i])
    begin
      if(configuration.swx_agt_cfg[i].initiator_responder == INITIATOR) //Since scoreboard needs to know the available ports. not tx/rx
        eye_scbd.dut_pmrcp_q.push_back(configuration.swx_agt_cfg[i].my_id);
      tmp = i ;
    end

    eye_scbd.rx_only_flit[$psprintf("%0s_00_rq_00",configuration.swx_agt_cfg[tmp].concat_ids("nodeid"))] = 1;
    eye_scbd.rx_only_flit[$psprintf("%0s_00_dt_01",configuration.swx_agt_cfg[tmp].concat_ids("nodeid"))] = 1;
//tbr /*    if ($test$plusargs("SWX_SIMULATE_ALL_DEST"))
//tbr     begin
//tbr       int limit_arr[string][2];
//tbr       limit_arr["PKG"]      = '{0,0};
//tbr       limit_arr["MESH"]     = '{0,15};
//tbr       limit_arr["ROW"]      = '{0,15};
//tbr       limit_arr["COL"]      = '{0,15};
//tbr       limit_arr["EXITPORT"] = '{0,15};
//tbr 
//tbr       foreach(limit_arr[j])
//tbr       begin
//tbr         void'($value$plusargs($psprintf("SWX_%0s_START=%%0d",j),limit_arr[j][0]));
//tbr         void'($value$plusargs($psprintf("SWX_%0s_END=%%0d"  ,j),limit_arr[j][1]));
//tbr       end
//tbr 
//tbr       for(int p=limit_arr["PKG"][0];p<limit_arr["PKG"][1];p++) 
//tbr         for(int m=limit_arr["MESH"][0];m<limit_arr["MESH"][1];m++) 
//tbr           for(int r=limit_arr["ROW"][0];r<limit_arr["ROW"][1];r++) 
//tbr             for(int c=limit_arr["COL"][0];c<limit_arr["COL"][1];c++) 
//tbr               for(int po=limit_arr["EXITPORT"][0];po<limit_arr["EXITPORT"][1];po++) 
//tbr               begin
//tbr                 string tmp;
//tbr                 tmp = $psprintf("%0s%0d",(p<10 ? "0": ""),p);
//tbr                 tmp = $psprintf("%0s_%0s%0d",tmp,(m<10 ? "0": ""),m);
//tbr                 tmp = $psprintf("%0s_%0s%0d",tmp,(r<10 ? "0": ""),r);
//tbr                 tmp = $psprintf("%0s_%0s%0d",tmp,(c<10 ? "0": ""),c);
//tbr                 tmp = $psprintf("%0s_%0s%0d",tmp,(po<10 ? "0": ""),po);
//tbr                 swx_scbd.dut_pmrcp_q.push_back(tmp);
//tbr               end
//tbr     end
//tbr */
    vsqr = eye_vsqr_t::type_id::create("vsqr", this);
    //tbrvsqr.set_config(configuration);
    //tbrconfiguration.set_vsqr(vsqr);

    // pragma uvmf custom build_phase begin
    // pragma uvmf custom build_phase end

//tbr    gio = tsv_gio_component#(swx_gio_names)::type_id::create("gio_swx", this);
//tbr    if (!configuration.is_top) 
//tbr        gio.set_alias_name("swx_00");  
//tbr    else
//tbr        gio.set_alias_name(this.get_name());  
//tbr    gio.set_cb(gio_cb_event, "pwr_up");
//tbr    gio.set_cb(gio_cb_event, "hw_rst");
//tbr    //gio.set_cb(gio_cb_event, "sw_rst");
    
  endfunction : build_phase
  

// ****************************************************************************
// FUNCTION: connect_phase()
// This function makes all connections within this environment.  Connections
// typically inclue agent to predictor, predictor to scoreboard and scoreboard
// to agent.
//
  virtual function void connect_phase(uvm_phase phase);
    

    string agent_str, agent_name;
    bit ok;
//tbr    virtual aapb_intf#(32, 32, 1)  brdg_intf;
//tbr    uvm_reg_addr_t base2, limit2;  //Need to assign. Irrelvant if apb bridge is used as master for csr rd/wr master

    super.connect_phase(phase);

//tbr    gio.assign_if(configuration.get_gio_if());

//tbr    if (configuration.is_top==0) begin //is_top will be 0 at ip level but will be set by chiplet level
//tbr      ok = uvm_config_db#(virtual aapb_intf#(32, 32, 1))::get(uvm_root::get(), "*", "apb_intf_brdg", brdg_intf);
//tbr      if (!ok || brdg_intf == null)
//tbr		  `uvm_fatal(get_full_name(), $psprintf("Testbench module shall pass in apb_intf_brdg"));
//tbr      apb_brdg.assign_vi(brdg_intf);
//tbr      base2 = 0;
//tbr      limit2 = 'h1000_0000;
//tbr      apb_brdg.mgr.slv_infos[0].add_blk(apb_brdg.log, base2, limit2);
//tbr      eye_regmodel_inst.default_map.set_sequencer(apb_brdg.sequencer,apb_mem_adapter);
//tbr      //init_seq.env = this;
//tbr    end
    if(configuration.dv_intf_activities[AXI_MASTER_INTF].exists("axi_in")) 
      eye_regmodel_inst.default_map.set_sequencer(axi_master_intf_agent["axi_in"].sequencer, axi_master_intf_agent_mem_adapter["axi_in"]);    
    
    foreach(configuration.dv_intf_activities[AXI_MASTER_INTF][agent_name]) begin
      agent_str = $psprintf("%s.axi_master_intf_agent_%s.sequencer", configuration.env_path, agent_name);
      uvm_config_db #(aaxi_uvm_sequencer)::set( null,UVMF_SEQUENCERS, agent_str, axi_master_intf_agent[agent_name].sequencer);
      if(axi_master_intf_agent[agent_name].sequencer != null)
      `uvm_info(get_full_name(), $psprintf(" : axi_master_intf_agent_%s.sequencer setting", agent_name), UVM_LOW);
      $display("tbr i am sequencer n ame=%0s agent_name", axi_master_intf_agent[agent_name].sequencer.get_full_name());
    end


    eye_init_seq = eye_init_sequence#(eye_env_configuration#(`PARAM),`PARAM)::type_id::create($psprintf("eye_init_seq_%0s",configuration.env_inst_name));
    eye_init_seq.configuration = configuration;
    void'(tsv_common_pkg::tsv_init_seq_stage::add_init_seq(eye_init_seq));

// pragma uvmf custom connect_phase_pre_super begin
// pragma uvmf custom connect_phase_pre_super end
  
    // uvmf_gen_intf_TODO TODO: //DV INSTR TODO: figure out analysis port name arrays //TODO: create swx scoreboard
    //foreach(configuration.dv_intf_activities[TWX_TX_INTF][agent_name]) begin
    // atb_out_agent[agent_name].monitored_ap.connect(swx_sb.atb_intf_agent_128_bk_ae_0);
    //end
    // uvmf_gen_intf_TODO TODO: //DV INSTR TODO: figure out analysis port name arrays //TODO: create swx scoreboard
    //foreach(configuration.dv_intf_activities[TWX_RX_INTF][agent_name]) begin
    // atb_out_agent[agent_name].monitored_ap.connect(swx_sb.atb_intf_agent_128_bk_ae_0);
    //end
    foreach(configuration.agt_cfgs[p,m,r,c,po,tx_rx])
    begin
      string tmp;
      tmp = configuration.agt_cfgs[p][m][r][c][po][tx_rx].concat_ids("portid_txrx");
//tbr      swx_twx_ch_intf_agent_i[tmp].monitored_ap.connect(eye_pred.swx_twx_ch_intf_ae[tmp]);
    end

    // pragma uvmf custom reg_model_connect_phase begin
    // pragma uvmf custom reg_model_connect_phase end
  endfunction

// ****************************************************************************
// FUNCTION: end_of_simulation_phase()
// This function is executed just prior to executing run_phase.  This function
// was added to the environment to sample environment configuration settings
// just before the simulation exits time 0.  The configuration structure is 
// randomized in the build phase before the environment structure is constructed.
// Configuration variables can be customized after randomization in the build_phase
// of the extended test.
// If a sequence modifies values in the configuration structure then the sequence is
// responsible for sampling the covergroup in the configuration if required.
//
  virtual function void start_of_simulation_phase(uvm_phase phase);
     configuration.configuration_cg.sample();
//tbr     `uvm_info("AAPB_INF", $psprintf("start bfm"), UVM_LOW);
//tbr     apb_brdg.set("start_bfm");
  endfunction


   
                            
   
    /////////////////////////////////////////////////////
    //  Find and remove my ral.
    function void find_and_get_ral (ref uvm_reg_block blks[$]);
    endfunction;


  virtual function void final_phase(uvm_phase phase);
    string reg_name[$] = '{ "link_buf_flit","delay_buf_flit","dt_data_buf_flit","in_process_flit","data_out_hdr_buf_flit" };
    bit[31:0] data;
    super.final_phase(phase);
    
    fork
    begin
      foreach(reg_name[r])
      begin
        for(int i=0;i<8;i++)
        begin
          string tmp;
          tmp = $psprintf("eye_socclk_regs.cyp.cyp_config.link_buf_flit[%0d]",i);
          do_reg_rw(get_name(),"READ",get_reg(get_name(),get_reg_blk(get_full_name()),,tmp),data,UVM_BACKDOOR);
          if(data == 0)
            `uvm_info(get_name(), $sformatf("%0s_match passed.exp_val=0 rcvd_val=%0h",tmp,data),UVM_DEBUG)
          else
            `uvm_error(get_name(), $psprintf("%0s_match failure.exp_val=0 rcvd_val=%0h",tmp,data))
        end
      end
    end
    join_none
  endfunction



  endclass
// pragma uvmf custom external begin
// pragma uvmf custom external end
