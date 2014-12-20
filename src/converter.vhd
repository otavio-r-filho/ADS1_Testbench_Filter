library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all

entity converter is
  port(
    CLK : IN std_ulogic;
    opr : IN std_ulogic;
    to_convert : IN std_logic_vector(31 downto 0);
    result : OUT std_logic_vector(31 downto 0)
  );
end converter;

architecture behav of converter is
  type state is (init, wait_data, float, int, result);
  
  signal convert_state : state; 
  signal buf std_logic_vector(31 downto 0);
begin
  
  process(CLK)
    
    begin
      if(CLK'event and CLK = '1') then
        
        case convert_state is
          when init =>
            
          when wait_data =>
        end case;
        
      end if;
      
    end process;
  
end behav;    
