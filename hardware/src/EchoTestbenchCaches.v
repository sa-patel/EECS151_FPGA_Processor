`timescale 1ns/1ps

module EchoTestbenchCaches();

    reg Clock, Reset;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    reg   [7:0] DataIn;
    reg         DataInValid;
    wire        DataInReady;
    wire  [7:0] DataOut;
    wire        DataOutValid;
    reg         DataOutReady;

    // This clock is the 100MHz on-board crystal oscillator, not the CPU clock.
    parameter HalfCycle = 5;
    parameter Cycle = 2*HalfCycle;
    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;

    // DDR 2 wires
    wire [12:0] DDR2_A;
    wire [1:0] DDR2_BA;
    wire DDR2_CAS_B;
    wire DDR2_CKE;
    wire [1:0] DDR2_CLK_N;
    wire [1:0] DDR2_CLK_P;
    wire DDR2_CS_B;
    wire [63:0]  DDR2_D;
    wire [7:0]   DDR2_DM;
    wire [7:0]   DDR2_DQS_N;
    wire [7:0]   DDR2_DQS_P;
    wire DDR2_ODT;
    wire DDR2_RAS_B;
    wire DDR2_WE_B;

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
    IBUFG user_clk_buf ( .I(Clock),    .O(user_clk_g) );
    BUFG  cpu_clk_buf  ( .I(cpu_clk),  .O(cpu_clk_g)  );
    BUFG  clk200_buf   ( .I(clk200),   .O(clk200_g)   );
    BUFG  clk0_buf     ( .I(clk0),     .O(clk0_g)     );
    BUFG  clkdiv50_buf ( .I(clk50),    .O(clk50_g)    );
    BUFG  clk90_buf    ( .I(clk90),    .O(clk90_g)    );
    BUFG  clkdiv0_buf  ( .I(clkdiv0),  .O(clkdiv0_g)  );

    // Shift register that keeps the reset signal high for an extended
    // period of time. It is used for resetting the FIFOs in Memory151.
    // Note that fifo_reset resets fifos, while reset_fifo is a fifo
    // for the reset signal.
    reg [9:0] rst_sr;
    wire fifo_reset; 
    assign fifo_reset = Reset | (|rst_sr);
    always @(posedge cpu_clk_g) begin
        rst_sr <= {rst_sr[8:0], Reset};
    end

    mt4htf3264hy ddr2(
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
        .DDR2_WE_B(DDR2_WE_B));

    Memory151 #(.SIM_ONLY(1'b1)) mem_arch(
        .cpu_clk_g(cpu_clk_g),
        .clk0_g(clk0_g),
        .clk200_g(clk200_g),
        .clkdiv0_g(clkdiv0_g),
        .clk90_g(clk90_g),
        .clk50_g(clk50_g),
        .rst(Reset),
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
        .locked     (pll_lock),
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
    );

    Riscv151 DUT(
        .clk(cpu_clk_g),
        .rst(Reset || ~init_done),
        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX),
        .dcache_addr (dcache_addr ),
        .icache_addr (icache_addr ),
        .dcache_we   (dcache_we   ),
        .icache_we   (icache_we   ),
        .dcache_re   (dcache_re   ),
        .icache_re   (icache_re   ),
        .dcache_din  (dcache_din  ),
        .icache_din  (icache_din  ),
        .dcache_dout (dcache_dout ),
        .instruction (instruction ),
        .stall(stall)
    );

    UART          uart( .Clock(           cpu_clk_g),
                        .Reset(           Reset || ~init_done),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));

    initial begin
      // Reset. Has to be long enough to not be eaten by the debouncer.
      Reset = 0;
      DataIn = 8'h7a;//'
      DataInValid = 0;
      DataOutReady = 0;

      Reset = 1;
      repeat (30) @( posedge cpu_clk_g );
      Reset = 0;

      // Wait until transmit is ready
      @( posedge init_done ) ; // wait for ddr init done
      repeat (5) @( posedge cpu_clk_g ) ;
      DataInValid = 1'b1;
      @( posedge cpu_clk_g ) ;
      DataInValid = 1'b0;

      // Wait for something to come back
      @( posedge DataOutValid ) ;
      @( posedge cpu_clk_g ) ;
      $display("Got %h", DataOut);

      DataIn = 8'h80;
      DataInValid = 1'b1;
      @( posedge cpu_clk_g ) ;
      DataInValid = 1'b0; //'
      repeat (100) @( posedge cpu_clk_g );

      // Wait for something to come back
      @( posedge DataOutValid ) ;
      @( posedge cpu_clk_g ) ;
      $display("Got %h", DataOut);

      // Add more test cases!

      $finish();
  end

endmodule
