module tod(

input  clk,     //100m
input  rst,

input  [31:0] load_data,
input  load_en,

input  [31:0] fh_num,


output reg tod_flag,
output reg [20:0]  tod_h,
output reg [10:0]  tod_l,
output reg time_slot_flag,

input[20:0] reload_tod_h,						//RTT重新注入的tod_h经过计算纠正的
input[10:0] reload_tod_l,						//RTT重新注入的tod_l经过计算纠正的
input rtt_reload_en,     						//RTT校时使能信号
input[20:0] tod_h_cnt,
input[10:0] tod_l_cnt,
//test a
input rtt_reload_cnt_en
);


// 完成对7.8125ms计时。其中tod_l周期为8us，即一个跳频周期。
reg[20:0] num_tod_h;
reg[10:0] num_tod_l;
always @(posedge clk or posedge rst)
begin
    if(rst)
        begin
        tod_h <= 21'd0;
        tod_l <= 11'd0;
		tod_flag <= 1'b0;
		time_slot_flag <= 1'b0;
		num_tod_h <= 21'd976;
		num_tod_l <= 11'd449;
        end
    else
        begin
        if(rtt_reload_en == 1'b1)   //用于精确RTT校时的时候使用
            begin
				tod_h <= reload_tod_h;
				tod_l <= reload_tod_l;
            end
		else if(rtt_reload_cnt_en)
			begin
				num_tod_h <= tod_h_cnt;
				num_tod_l <= tod_l_cnt;
			end
			
        else if(load_en == 1'b1) //在入网时候使用
            begin
            tod_h <= load_data[31:11];
            tod_l <= load_data[10:0];
            end
        else
            begin
			 if((tod_h == num_tod_h) && (tod_l == num_tod_l))  
                begin
                tod_l <= 11'd0;
                tod_h <= 21'd0;
				tod_flag <= 1'b1;
				time_slot_flag <= 1'b1;                 //每时隙产生一个脉冲信号，用于后面寄存器的加载
				num_tod_h <= 21'd976;
				num_tod_l <= 11'd449;
                end
            else
                begin
				time_slot_flag <= 1'b0;
                if(tod_l == 11'd799)
                    begin
				    tod_flag <= 1'b0;					
					tod_l <= 11'd0;
                    tod_h <= tod_h + 21'd1;
                    end
                else
                    begin
                    tod_l <= tod_l +11'd1;
                    tod_h <= tod_h;
                    end
                end
            end
        end
end

endmodule
