module tx_fh(

input  clk,
input  rst,

input  [31:0] fh_num,           // 跳频数目寄存器

input  [20:0] tod_h,
input  [10:0]  tod_l,

output [9:0]  freq_ram_addr,    // 输出频率表地址
input  [31:0] freq_ram_data,    // 频率控制字输入
 
output reg [31:0] freq_factor,  // 频率控制字输出
output reg freq_en              // 频率控制字有效信号

);
  
  
assign freq_ram_addr = tod_h[9:0];
  
//assign freq_ram_addr = (tod_h < fh_num[20:0]) ? tod_h[9:0] : 10'd0;      // 产生频率表地址，tod_h是对跳频数的计数
//assign freq_ram_addr = (tod_h[9:0] < 10'd32) ? 10'd0 : ((tod_h[9:0] < 10'd40 && tod_h[9:0] >= 10'd32) ? 10'd32 : 10'd40);
//assign freq_ram_addr = (tod_h[9:0] < 10'd100) ? 10'd0 : ((tod_h[9:0] < 10'd250 && tod_h[9:0] >= 10'd100) ? 10'd32 : 10'd40);
//慢跳系统（同时兼容快跳系统的设计），当粗同步的时候采用频率表的第一个频点，精同步即第32跳采用第33个频点，数据部分整个采用40号频点
//这样设计的目的是为了兼容快跳
//assign freq_ram_addr =  10'd0;
always @(posedge clk or posedge rst)
begin
    if(rst)
        begin
        freq_factor <= 32'd0;
        freq_en <= 1'b0; 		
        end
    else
        begin                                                   //当使用AD9957作为调制器使用的时候，要给AD9957加载跳频频率，要考虑几个时钟周期的读取频率表的时间														
         if((tod_h < fh_num[20:0]) && (tod_l == 11'd12))        //并且有一点需要注意，加载的使能信号要超过100ns，因为后面的spi串口传送数据     
            begin											    //的时钟为10M
            freq_factor <= freq_ram_data;						//调整跳频保护时间增加为10个12.5ns
            freq_en <= 1'b0;//频率控制字加载使能信号，至少要保证此信号有效100ns即10MHZ
            end
		
		 else if((tod_h < fh_num[20:0]) && (tod_l == 11'd16))          
            begin											   
            freq_factor <= freq_factor;
            freq_en <= 1'b1;
            end
			
		 else if((tod_h < fh_num[20:0]) && (tod_l == 11'd28))          
            begin											   
            freq_factor <= freq_factor;
            freq_en <= 1'b0;
            end	
			
//当发送大于限定的跳数的时候发送全0频点，将载频变为0          
		 // else if((tod_h == fh_num[20:0]) && (tod_l == 11'd13))							         
            // begin											   
				// freq_factor <= 32'd0;
				// freq_en <= 1'b1;
            // end
		 // else if((tod_h == fh_num[20:0]) && (tod_l == 11'd22))							        
            // begin											   
				// freq_factor <= 32'd0;
				// freq_en <= 1'b0;
            // end
		 else
            begin
            freq_factor <= freq_factor;
            freq_en <= freq_en;
            end
        end
end


endmodule
