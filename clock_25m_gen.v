module clock_25m_gen(
       input clk,
	   input rst,
	   input time_slot_flag,
	   
	   output reg clk_25m_1
);
reg [2:0] cnt; 
always @(posedge clk or posedge rst)
begin
	if(rst)
		begin
		cnt <= 3'd0;
		end
	else
		begin
//		if(time_slot_flag)
//		    cnt <= 3'd0;
//        else
       	    if(cnt == 3'd3)
                cnt <= 3'd0;
            else
                cnt <= cnt + 3'd1;
		end
end
  
always @(posedge clk or posedge rst)
begin
	if(rst)
		begin
		clk_25m_1 <= 1'b0;
		end
	else
		begin
       	    if(cnt == 3'd1)
                clk_25m_1 <= 1'b1;
            if(cnt == 3'd3)
                clk_25m_1 <= 1'b0;
		end
end  

endmodule