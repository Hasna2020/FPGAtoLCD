module display(
	//inputs
	input clk,
	input rst_n,
	input button_1,
	input [19:0]temp,
	input sign,
	input st,

	//outputs
	output [7:0]led,
	output RS,
	output RW,
	output E,
	output db_4,
	output db_5,
	output db_6,
	output db_7
   );

parameter init = 2'b10;
parameter refresh = 2'b01;
parameter done = 2'b00;

reg [1:0] state = init;
reg [26:0] count;
reg [5:0] code = 6'b0100000000;	//Default state to allow write
reg [19:0] temp_change;

wire [19:0] temp_inv = (~temp_change + 1) + temp;
	
always @( posedge clk )
	begin
		if ( ~button_1 )  begin
			count <= 0;
		end else begin
			count <= count +1;
		end
	end
	
always @( posedge clk )
	begin
		if (temp_inv != 20'b0) begin
			state <= init;
		end
		
		temp_change <= temp;
		
		if ( ~button_1 )  begin
			code <= 6'b010000;
			state <= init;
		end else if ( state == init ) begin
			case (count[23:17])
				2: code <= 6'b000000;
				4: code <= 6'b000001;		//1 then Clear display
				6: code <= 6'b000000;
				8: code <= 6'b001100;		//1 then [2]Display on/off, [1]Cursor on/off, [0]CBlink on/off
				10: code <= 6'b000000;
				12: code <= 6'b000010;		//1 then Return curser to original pos.
				14: code <= 6'b000000;
				16: code <= 6'b000110;		//1 then Set [1]increment/decrement and [0] shift entire disp
				22: state <= refresh;
				default: code <= 6'b010000;
			endcase;			
		end else if ( state == refresh ) begin
			case (count[23:17])
				25: code <= 6'b001000;
				26: code <= 6'b000001;		//DDRAM Addy AC01
				28: code <= 6'b100010;
				30: if ( sign == 1 ) begin //Blank or negative sign
						code <= 6'b101101;
					 end else begin
						code <= 6'b100000;
					 end
				32: code <= 6'b001000;
				34: code <= 6'b000010;		//DDRAM Addy AC02
				36: if (temp[19:16] == 4'b0) begin
						code <= 6'b100010;
					 end else begin
						code <= 6'b100011;
					 end
				38: if (temp[19:16] == 4'b0) begin
						code <= 6'b100000;
					 end else begin
						code <= {6'b10, temp[19:16]};
					 end
				40: if ((temp[19:16] == 4'b0) && (temp[15:12] == 4'b0)) begin
						code <= 6'b100010;
					 end else begin
						code <= 6'b100011;
					 end
				42: if ((temp[19:16] == 4'b0) && (temp[15:12] == 4'b0)) begin
						code <= 6'b100000;
					 end else begin
						code <= {6'b10, temp[15:12]};
					 end
				44: code <= 6'b100011;
				46: code <= {6'b10, temp[11:8]};
				48: code <= 6'b100010;
				50: code <= 6'b101110;
				52: code <= 6'b100011;
				54: code <= {6'b10, temp[7:4]};
				56: if (temp[3:0] == 4'b0) begin
						code <= 6'b100010;
					 end else begin
						code <= 6'b100011;
					 end				
				58: if (temp[3:0] == 4'b0) begin
						code <= 6'b100000;
					 end else begin
						code <= {6'b10, temp[3:0]};
					 end				
				60: code <= 6'b101101;
				62: code <= 6'b101111;		//degree character
				64: code <= 6'b100100;
				66: code <= 6'b100011;		//C
				68: code <= 6'b001010;
				70: code <= 6'b001111;		//DDRAM Addy AC47
				72: code <= 6'b100010;
				74: code <= 6'b101000;		//(
				76: code <= 6'b100100;
				78: code <= 6'b100101;		//E
				80: code <= 6'b100100;
				82: code <= 6'b101100;		//L
				84: code <= 6'b100100;
				86: code <= 6'b101001;		//I
				88: code <= 6'b100101;
				90: code <= 6'b100100;		//T
				92: code <= 6'b100100;
				94: code <= 6'b100101;		//E
				96: code <= 6'b100010;
				98: code <= 6'b101001;		//)
				100: code <= 6'b010000;		//Read
				102: state <= done;
				default: code <= 6'b010000;
			endcase;
		end
	end

assign E = (count[16] ^ count[15]);
assign RS = code[5];
assign RW = code[4];
assign db_4 = code[0];
assign db_5 = code[1];
assign db_6 = code[2];
assign db_7 = code[3];

assign led[6:0] = {E, RS, RW, code};
endmodule
