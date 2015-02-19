--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.float_pkg.all;
USE ieee.numeric_std.all;
 
ENTITY testbench_cvt IS
END testbench_cvt;
 
ARCHITECTURE behavior OF testbench_cvt IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    
    COMPONENT converter
	 Port ( 
	      clk : IN std_ulogic;
			rst : IN std_ulogic;
			opr	: IN std_ulogic;
			enable : IN std_ulogic;
			to_convert : IN std_logic_vector(31 downto 0);
			valid_result : INOUT std_ulogic;
			result : OUT std_logic_vector(31 downto 0)
 		);
    END COMPONENT;
    

   --Inputs   
	 signal CLK			: std_logic;
	 signal enable		: std_logic;
	 --signal operand		: std_logic_vector(31 downto 0);
	 	
 	--Outputs
	signal result		: std_logic_vector(31 downto 0);
	signal valid		: std_logic;
	
	--Dummy signals
	--signal int : integer;
	--signal flt : float32;
	signal rst : std_logic;
	signal opr : std_logic;
	signal to_convert : std_logic_vector(31 downto 0);
	signal valid_result : std_logic;
	
	signal float_result : float32;
	signal integer_result : integer;
	
		

   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
   -- Instantiate converter unit
    uut: converter
	   PORT MAP (
	   CLK => clk,
	   rst => rst,	   
	   opr => opr,
	   enable => enable,
	   to_convert => to_convert,
	   valid_result => valid_result,
	   result => result);
	   
	  
	   
   -- Clock process definitions
   clk_process :process
   begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
    enable <= '0';
	  result	<= (others => '0');
   	valid	<= '0';
	  rst <= '0';
	  opr <= '0';
	  to_convert <= (others => '0');
   	valid_result <= '0';
		wait for 100 ns;
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		wait for 5*clk_period;
		integer_result <= 50;
		to_convert <= std_logic_vector(to_signed(55, 32)); 
		opr <= '0';
		enable <= '1';
		wait for clk_period;
		enable <= '0';
		wait until valid_result = '1';
	--	report "Converted to float" & image(result);
		valid_result <= '0';
		wait for clk_period;
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		wait for 5*clk_period;
		to_convert <= std_logic_vector(to_float(5.2));
		opr <= '1';
		enable <= '1';
		wait until valid_result = '1';
		--report "Converted to integer" & integer'image(result);
		valid_result <= '0';	
      wait for 100 ns;
   end process;


END;
