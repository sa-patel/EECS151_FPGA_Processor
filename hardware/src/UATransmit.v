module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output   reg  SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------

  wire                             SymbolEdge;
  
  reg     [3:0]                    BitCounter;
  reg     [ClockCounterWidth-1:0]  ClockCounter;
    
  reg     [7:0]                    DataInStored;
  reg                              Start;
    
  // Counts cycles until a single symbol is done
  
  always @(posedge Clock) begin
    ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end

  // Goes high at every symbol edge
  assign SymbolEdge = ClockCounter == SymbolEdgeTime - 1;


  always @(posedge Clock) begin
    Start = 1'b0;
    if (Reset) begin
        BitCounter <= 0;
    end else if (BitCounter == 4'd0 && DataInValid ) begin
        BitCounter <= 10;
        DataInStored <= DataIn;
        Start = 1'b1;
    end else if ((SymbolEdge) && (BitCounter != 4'd0)) begin
        BitCounter <= BitCounter - 1;
        if (BitCounter != 4'd10) begin 
            DataInStored <= DataInStored >> 1;
        end    
    end
  end

assign DataInReady = (BitCounter == 4'd0);

  //--Send high bit, then data, then  ----------------------------
    always @(*) begin
        if (BitCounter != 4'd0) begin
            if (BitCounter == 10) begin
                SOut = 1'b0;
            end else if (BitCounter == 1) begin
                SOut = 1'b1;
            end else begin
                SOut = DataInStored[0];
            end
        end else begin //idle
            SOut = 1'b1;
        end
  end




    
endmodule
