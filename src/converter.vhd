library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all

entity converter is
  port(
	clk : IN std_ulogic;
	rst : IN std_ulogic;
	opr	: IN std_ulogic;
	enable : IN std_ulogic;
	to_convert : IN std_logic_vector(31 downto 0);
	valid_result : OUT std_ulogic;
	result : OUT std_logic_vector(31 downto 0)
  );
end converter;

architecture behav of converter is
	constant max_matissa : integer 16777216;

	type state is (init, wait_data, to_float, to_int, result);

	signal convert_state : state := init; 
	signal buf std_logic_vector(31 downto 0);
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
						buf(31 downto 0) <= to_convert(31 downto 0);ttd
					end if;
				
				when to_float =>
		 
				when to_int =>

				when result =>
		
			end case;
        
		end if;
      
    end process;
  
end behav;    
