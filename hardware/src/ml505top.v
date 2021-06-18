module ml505top
(
  input        FPGA_SERIAL_RX,
  output       FPGA_SERIAL_TX,
  input        GPIO_SW_C,
  input        GPIO_SW_S,
  input        USER_CLK,

  // The pins to the DRAM
`ifdef EECS151_CHKPNT_2_OR_3
  output [12:0] DDR2_A,
  output [1:0]  DDR2_BA,
  output        DDR2_CAS_B,
  output        DDR2_CKE,
  output [1:0]  DDR2_CLK_N,
  output [1:0]  DDR2_CLK_P,
  output        DDR2_CS_B,
  inout  [63:0] DDR2_D,
  output [7:0]  DDR2_DM,
  inout  [7:0]  DDR2_DQS_N,
  inout  [7:0]  DDR2_DQS_P,
  output        DDR2_ODT,
  output        DDR2_RAS_B,
  output        DDR2_WE_B,
`endif
  
  // The pins to the DVI chip
`ifdef EECS151_CHKPNT_3
  output [11:0] DVI_D,
  output        DVI_DE,
  output        DVI_H,
  output        DVI_RESET_B,
  output        DVI_V,
  output        DVI_XCLK_N,
  output        DVI_XCLK_P,
  
  inout         IIC_SCL_VIDEO,
  inout         IIC_SDA_VIDEO,
`endif

  output [7:0] GPIO_LED
);

  // Define wires
  reg [3:0]  reset_r = 4'b0;
  reg [25:0] count_r = 26'b0;

  wire [3:0]  next_reset_r;
  wire [25:0] next_count_r;

  wire stall_debounced;

  wire user_clk_g;

  wire cpu_clk;
  wire cpu_clk_g;

  wire clk0;
  wire clk0_g;

  wire clk90;
  wire clk90_g;

  wire clkdiv0;
  wire clkdiv0_g;

  wire clk200;
  wire clk200_g;

  wire pll_lock;

  wire clk50;
  wire clk50_g;

  /* The PLL that generates all the clocks.
   * The global mult/divide ratio is set to 6. The input clk is 100MHz.
   * Therefore, freq of each output = 600MHz / CLKOUTx_DIVIDE
   */
  PLL_BASE
  #(
    .COMPENSATION("SYSTEM_SYNCHRONOUS"),
    .BANDWIDTH("OPTIMIZED"),

    .CLKFBOUT_MULT(6),
    .CLKFBOUT_PHASE(0.0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER(0.100),
    .CLKIN_PERIOD(10.0),

    `ifdef RISCV_CLK_50
        .CLKOUT0_DIVIDE(12),
    `endif `ifdef RISCV_CLK_100
        .CLKOUT0_DIVIDE(6),
    `endif
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),

    .CLKOUT1_DIVIDE(3),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0.0),

    .CLKOUT2_DIVIDE(3),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0.0),

    .CLKOUT3_DIVIDE(3),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(90.0),

    .CLKOUT4_DIVIDE(6),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0.0),

    .CLKOUT5_DIVIDE(12),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0.0)
  )

  /* Output clocks:
   * cpu_clk: 50MHz or 100MHz, depending on configuration
   * clk200: 200MHz
   * clk0: 200MHz
   * clk90: 200MHz, 90 deg phase shift
   * clkdiv0: 100MHz
   * clk50: 50MHz
   *
   * For CP1, only cpu_clk is used. The rest are used for CP2 and CP3.
   */
  user_clk_pll
  (
    .CLKFBOUT(pll_fb),
    .CLKOUT0(cpu_clk),
    .CLKOUT1(clk200),
    .CLKOUT2(clk0),
    .CLKOUT3(clk90),
    .CLKOUT4(clkdiv0),
    .CLKOUT5(clk50),
    .LOCKED(pll_lock),
    .CLKFBIN(pll_fb),
    .CLKIN(user_clk_g),
    .RST(1'b0)
  );

  // The clocks need to be buffered before they can be used
  IBUFG user_clk_buf ( .I(USER_CLK), .O(user_clk_g) );
  BUFG  cpu_clk_buf  ( .I(cpu_clk),  .O(cpu_clk_g)  );
  BUFG  clk200_buf   ( .I(clk200),   .O(clk200_g)   );
  BUFG  clk0_buf     ( .I(clk0),     .O(clk0_g)     );
  BUFG  clkdiv50_buf ( .I(clk50),    .O(clk50_g)    );
  BUFG  clk90_buf    ( .I(clk90),    .O(clk90_g)    );
  BUFG  clkdiv0_buf  ( .I(clkdiv0),  .O(clkdiv0_g)  );

  always @(posedge cpu_clk_g)
  begin
    reset_r <= next_reset_r;
    count_r <= next_count_r;
  end

  // Delay logic for reset button
  assign next_reset_r = {reset_r[2:0], GPIO_SW_C};
  assign rst = (count_r == 26'b1) | ~pll_lock;

  assign next_count_r = (count_r == 26'b0) ?
                    (reset_r[3] ? 26'b1 : 26'b0) :
                    count_r + 1;

  // Shift register that keeps the reset signal high for an extended
  // period of time. It is used for resetting the FIFOs in Memory151.
  // Note that fifo_reset resets fifos, while reset_fifo is a fifo
  // for the reset signal.
  reg [2:0] rst_sr;
  wire fifo_reset; 
  assign fifo_reset = rst | (|rst_sr);
  always @(posedge cpu_clk_g) begin
    rst_sr <= {rst_sr[1:0], rst};
  end

  // Synchronize and debounce the stall button
  ButtonSyncDebounce stallDebounce(
    .button(GPIO_SW_S),
    .clk(cpu_clk_g),
    .rst(rst),
    .debounced(stall_debounced)
    );

  // Create wires for the memories and graphics engines
  wire  [31:0] dcache_addr;
  wire  [31:0] icache_addr;
  wire  [3:0]  dcache_we;
  wire  [3:0]  icache_we;
  wire         dcache_re;
  wire         icache_re;
  wire  [31:0] dcache_din;
  wire  [31:0] icache_din;
  wire [31:0]  dcache_dout;
  wire [31:0]  instruction;
  wire         stall;
  wire         video_ready;
  wire         video_valid;
  wire [23:0]  video;
  wire         dvi_rst;
  wire [23:0]  filler_color;
  wire         filler_ready;
  wire         filler_valid;
  wire         line_ready;
  wire  [31:0] line_color;
  wire  [9:0]  line_point;
  wire         line_color_valid;
  wire         line_x0_valid;
  wire         line_y0_valid;
  wire         line_x1_valid;
  wire         line_y1_valid;
  wire         line_trigger;
  wire [31:0]  bypass_addr;
  wire [31:0]  bypass_din;
  wire [3:0]   bypass_we;

  // For CP1, wire the stall signal to the south switch on the FPGA board
  `ifdef EECS151_CHKPNT_1
  assign stall = stall_debounced;
  assign init_done = 1'b1;
  `endif

  // Only instantiate the caches for CP2 and CP3
  `ifdef EECS151_CHKPNT_2_OR_3
  Memory151 #(.SIM_ONLY(1'b0)) mem_arch
  (
      .cpu_clk_g(cpu_clk_g),
      .clk0_g(clk0_g),
      .clk200_g(clk200_g),
      .clkdiv0_g(clkdiv0_g),
      .clk90_g(clk90_g),
      .clk50_g(clk50_g),
      .rst(fifo_reset),
      .init_done(init_done),
      .DDR2_A(DDR2_A),
      .DDR2_BA(DDR2_BA),
      .DDR2_CAS_B(DDR2_CAS_B),
      .DDR2_CKE(DDR2_CKE),
      .DDR2_CLK_N(DDR2_CLK_N),
      .DDR2_CLK_P(DDR2_CLK_P),
      .DDR2_CS_B(DDR2_CS_B),
      .DDR2_D(DDR2_D),
      .DDR2_DM(DDR2_DM),
      .DDR2_DQS_N(DDR2_DQS_N),
      .DDR2_DQS_P(DDR2_DQS_P),
      .DDR2_ODT(DDR2_ODT),
      .DDR2_RAS_B(DDR2_RAS_B),
      .DDR2_WE_B(DDR2_WE_B),
      .locked(pll_lock),
      .dcache_addr(dcache_addr),     
      .icache_addr(icache_addr),         
      .dcache_we  (dcache_we  ),  
      .icache_we  (icache_we  ),  
      .dcache_re  (dcache_re  ),  
      .icache_re  (icache_re  ),  
      .dcache_din (dcache_din ), 
      .icache_din (icache_din ), 
      .dcache_dout(dcache_dout),
      .icache_dout(instruction),
      .stall      (stall      )

      `ifdef EECS151_CHKPNT_3
      ,
      .bypass_addr(bypass_addr),
      .bypass_we  (bypass_we  ),
      .bypass_din (bypass_din ),
      .video      (video      ),
      .video_ready(video_ready),
      .video_valid(video_valid),
      .filler_color(filler_color),
      .filler_valid(filler_valid),
      .filler_ready(filler_ready),
      .line_ready(line_ready),
      .line_color(line_color),
      .line_point(line_point),
      .line_color_valid(line_color_valid),
      .line_x0_valid(line_x0_valid),
      .line_y0_valid(line_y0_valid),
      .line_x1_valid(line_x1_valid),
      .line_y1_valid(line_y1_valid),
      .line_trigger(line_trigger),
      .dvi_rst(dvi_rst)
      `endif
    );
  `endif
  
  // RISC-V 151 CPU
  Riscv151 CPU(
    .clk(cpu_clk_g),
    .rst(rst || ~init_done),
    .stall(stall),
    .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
    .FPGA_SERIAL_TX(FPGA_SERIAL_TX)

    `ifdef EECS151_CHKPNT_2_OR_3
    ,
    .dcache_addr (dcache_addr ),
    .icache_addr (icache_addr ),
    .dcache_we   (dcache_we   ),
    .icache_we   (icache_we   ),
    .dcache_re   (dcache_re   ),
    .icache_re   (icache_re   ),
    .dcache_din  (dcache_din  ),
    .icache_din  (icache_din  ),
    .dcache_dout (dcache_dout ),
    .instruction (instruction )
    `endif

    `ifdef EECS151_CHKPNT_3
    ,
    .filler_color(filler_color),
    .filler_valid(filler_valid),
    .filler_ready(filler_ready),
    .line_ready(line_ready),
    .line_color(line_color),
    .line_point(line_point),
    .line_color_valid(line_color_valid),
    .line_x0_valid(line_x0_valid),
    .line_y0_valid(line_y0_valid),
    .line_x1_valid(line_x1_valid),
    .line_y1_valid(line_y1_valid),
    .line_trigger(line_trigger),
    .bypass_addr(bypass_addr),
    .bypass_we  (bypass_we  ),
    .bypass_din (bypass_din )
    `endif
  );

  // Instantiate the DVI driver for CP3 only
  `ifdef EECS151_CHKPNT_3
  DVI #(
    .ClockFreq(                 50000000),
    .Width(                     1040),   
    .FrontH(                    56),     
    .PulseH(                    120),    
    .BackH(                     64),    
    .Height(                    666),    
    .FrontV(                    37),      
    .PulseV(                    6),      
    .BackV(                     23)      
  )
  dvi(         
    .Clock(                     clk50_g),
    .Reset(                     dvi_rst || ~init_done),
    .DVI_D(                     DVI_D),
    .DVI_DE(                    DVI_DE),
    .DVI_H(                     DVI_H),
    .DVI_V(                     DVI_V),
    .DVI_RESET_B(               DVI_RESET_B),
    .DVI_XCLK_N(                DVI_XCLK_N),
    .DVI_XCLK_P(                DVI_XCLK_P),
    .I2C_SCL_DVI(               IIC_SCL_VIDEO),
    .I2C_SDA_DVI(               IIC_SDA_VIDEO),
    /* Ready/Valid interface for 24-bit pixel values */
    .Video(                     video),
    .VideoReady(                video_ready),
    .VideoValid(                video_valid)
  );
  `endif

  assign GPIO_LED = {3'b0, line_ready, filler_ready, stall, pll_lock, init_done};

endmodule
