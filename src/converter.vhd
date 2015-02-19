library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;

entity converter is
  port(
	clk : IN std_ulogic;
	rst : IN std_ulogic;
	opr	: IN std_ulogic;
	enable : IN std_ulogic;
	to_convert : IN std_logic_vector(31 downto 0);
	valid_result : INOUT std_ulogic;
	result : OUT std_logic_vector(31 downto 0)
  );
end converter;

architecture behav of converter is
	--constant max_matissa : integer 16777216;

	type state is (init, wait_data, cvt_to_float, cvt_to_int, cvt_result);
	
	signal float_num : float32;
	signal int_num : integer;

	signal convert_state : state := init; 
	signal in_buf : std_logic_vector(31 downto 0);
	signal out_buf : std_logic_vector(31 downto 0);
begin
  
  process(CLK)
    
    begin
		if(rst = '1') then
			convert_state <= init;
			valid_result <= '0';
			result <= (others => '0');
		elsif(clk'event and clk = '1') then
        
			case convert_state is
				when init =>
					valid_result <= '0';
					result <=(others => '0');
					convert_state <= wait_data;
				
				when wait_data =>
					if(enable = '1') then
						valid_result <= '0';
						out_buf(31 downto 0) <= to_convert(31 downto 0);
						if (opr = '0') then 
						  convert_state <= cvt_to_float;  
						else
						  convert_state <=  cvt_to_int;
						end if;
					end if;
				
				when cvt_to_float =>
					float_num <= to_float(to_integer(signed(in_buf)));
					out_buf <= std_logic_vector(float_num);
					convert_state <= cvt_result;
		 
				when cvt_to_int =>
					int_num <= to_integer(signed(to_float(in_buf)));
					out_buf <= std_logic_vector(to_signed(int_num, 32));
					convert_state <= cvt_result;

				when cvt_result =>
					result <= out_buf;
					valid_result <= '1';
					convert_state <= wait_data;
		
			end case;
        
		end if;
      
    end process;
  
end behav;    
