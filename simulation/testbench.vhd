--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.float_pkg.ALL;
USE ieee.NUMERIC_STD.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Dummy_Module
	 Port ( 
	       CLK			: IN	std_logic;
		    enable		: IN	std_logic;
		    edge		: IN	std_logic;
		    operand		: IN	std_logic_vector(31 downto 0);
		    result		: OUT	std_logic_vector(31 downto 0);
		    valid		: OUT	std_logic
 		);
    END COMPONENT;
    

   --Inputs   
   signal CLK			: std_logic;
	 signal enable		: std_logic;
	 signal edge		: std_logic;
	 signal operand		: std_logic_vector(31 downto 0);
	
	
 	--Outputs
	signal result		: std_logic_vector(31 downto 0);
	signal valid		: std_logic;
	
	--Dummy signals
	signal int : integer;
	signal flt : float32;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Dummy_Module 
		PORT MAP (
        CLK => CLK,
		    enable	=> enable,
		    edge =>	edge,
		    operand => operand,
		    result => result,
		    valid	=> valid
	     );

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
     wait for 100 ns;
      edge <= '0';
      int <= 0;
      flt <= to_float(0);
      operand <= x"00000000";
      
      wait for 100 ns;
     
      edge <= '1';
      int <= 5;
      flt <= to_float(int);
      operand <= to_slv;
      wait for 2 * clk_period;
      enable <= '1';
      wait for 2 * clk_period;
      enable <= '0';
      operand <= x"00000000";
      wait until valid = '1';
      flt <= to_float(result);
      int <= to_integer(flt); 
      
      wait for 100 ns;
           
      wait;	

   end process;


END;