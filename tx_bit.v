module tx_bit(

input  clk,
input  rst,

input  [20:0] tod_h,
input  [10:0]  tod_l,

input  [31:0] fh_num,           // 跳频数目寄存器

output [9:0] data_ram_addr,     // 发送数据存取器接口
input  [31:0] data_ram_data,

output reg bit_out,             // 比特输出


output reg [31:0] data_reg,     // 数据及数据有效信号输出，用于测试
output data_reg_en
);

assign data_reg_en = (tod_l == 11'd4) ? 1'b1 : 1'b0;     // 产生数据有效信号

assign data_ram_addr = tod_h ; 
//assign data_ram_addr = ((tod_h < fh_num[20:0]) ? (tod_h[9:0]) : 10'd904);			//目前测试版的跳频端发送904个扩频之后的32bit数据
// 发送比特状态机
reg tx_bit_state;
parameter tx_bit_idle = 1'b0;
parameter tx_bit = 1'b1;

reg [5:0] tx_bit_count;
reg [4:0] tx_cnt;

always @(posedge clk or posedge rst)
begin
    if(rst)
        begin
		tx_cnt <= 5'd10;
        bit_out <= 1'b0;
        tx_bit_state <= tx_bit_idle;
        tx_bit_count <= 6'd0;
        end
    else
        begin
        case(tx_bit_state)
        tx_bit_idle:
            begin
			tx_cnt <= 5'd10;
            bit_out <= 1'b0;
            if((tod_h < fh_num[20:0]) && tod_l == 11'd400)      //由于AD9957的频谱加载有一个相应时间，因此在加载数据的过程中要将这部分时延扣除
                data_reg <= data_ram_data;
            else
                data_reg <= data_reg;

            tx_bit_count <= 6'd0;

            if((tod_h < fh_num[20:0]) && (tod_l == 11'd512)) // 每个8us的前4个比特位跳频保护          
                tx_bit_state <= tx_bit;                     // 所以经过延时4*80/5=64个时钟周期后进行比特发送状态            
            else                            				// 由于使用AD9957因此，跳频保护时间要大大加长，以此保证跳频能够将所要的信息调制出去
                tx_bit_state <= tx_bit_idle;
            end
            
        tx_bit:
            begin
            if(tx_cnt == 5'd19)                       //每个码元为200ns，即16*12.5ns，所以用tod_l的低4bit，控制每1bit的发送
                begin
				tx_cnt <= 5'd0;
                bit_out <= data_reg[31];
                data_reg <= {data_reg[30:0], 1'b0};
                
                if(tx_bit_count == 6'd32)                   //每个数据都是32bit，要发送32次
                    begin
                    tx_bit_count <= 5'd0;
                    tx_bit_state <= tx_bit_idle;
                    end
                else
                    begin
                    tx_bit_count <= tx_bit_count + 5'd1;
                    tx_bit_state <= tx_bit;
                    end                    
                end
            else
                begin
				tx_cnt <= tx_cnt + 5'd1;
                bit_out <= bit_out;
                tx_bit_state <= tx_bit;
                end
            end
            
        default:
            begin
			tx_cnt <= 5'd10;
            bit_out <=1'b0;
            tx_bit_state <= tx_bit_idle;
            tx_bit_count <= 5'd0;
            end
        endcase
        end
end



endmodule
