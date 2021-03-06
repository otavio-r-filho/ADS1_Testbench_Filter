--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE ieee.MATH_REAL.ALL;



ENTITY testbench IS
END testbench;



ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Dummy_Module
	 Port ( 
	       CLK			: IN	std_logic;
		    enable		: IN	std_logic;
		    edge		: IN	std_logic;
		    operand	: IN	std_logic_vector(31 downto 0);
		    result		: OUT	std_logic_vector(31 downto 0);
		    valid		: OUT	std_logic
 		);
    END COMPONENT;    
    
    FUNCTION exponent (X : real) return real is   -- returns the real exponent value
	BEGIN
	    if abs(X) < 1.0 or (integer(X) rem 2) /= 0  then
			return floor(log2(abs(X))); 
		else
			return log2(abs(X));-- if exponent == integer number then we don't need to use floor()
		end if;

	END exponent;
	
	
   --Inputs   
	 signal CLK			: std_logic;
	 signal enable		: std_logic;
	 signal edge		: std_logic;
	 signal operand		: std_logic_vector(31 downto 0);
	 	
 	--Outputs
	signal result		: std_logic_vector(31 downto 0);
	signal valid		: std_logic;
	
	--Dummy signals
	signal to_convert : std_logic_vector(31 downto 0);
	signal t_result   : std_logic_vector(31 downto 0);
	signal converted  : real;		

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   --Constant defitions for limits with normalized and denormalized numbers.
   constant NaN : real := 2.0**130;					--max_n_m : real := 1.9999998807907104; --(2.0)**(128);
   constant neg_zero : real := -(2.0**(-150));  		--min_n_m : real := 1.0000001192092896; --(-2.0)**(128);
   constant max_d_m : real := (2.0)**(-126); 		--0.9999998807907104;
   constant min_d_m : real := -(2.0**(-126)); 		--0.0000001192092896;
   constant neg_inf : real := -(2.0**128);
   constant pos_inf : real := 2.0**128;
   --variable to be converted:  
   signal dec : real := 1.257;
   signal cnt : integer := 1;
   
   -- signal powi : integer;
   -- signal powr : real;
   -- signal pre_mantissa : real;
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
		enable <= '0';
		edge <= '1';
		wait for clk_period;
        
		-- if abs(dec) > max_d_m then --/= 0.0 then
			-- pre_mantissa <= abs(8.0)/(2.0**integer(floor(log2(abs(8.0)))));
			-- powi <= integer(exponent(8.0));
			
		-- else
			-- pre_mantissa <= abs(dec)/max_d_m;
		-- end if;
		-- wait for clk_period ;
		
      -- Real to IEEE 754 format conversion 
		--sign bit:
		if dec < 0.0 then
			to_convert(31) <= '1';
		else
			to_convert(31) <= '0';
		end if;
		-- This case deals with negative zero, we have used the constant neg_zero = -(2.0**150), to signal -0
		if (dec = neg_zero) then
			to_convert(30 downto 0) <= (others => '0');
		-- This case deals with NaN-s, we have used the constant NaN = (2.0)**(130), which is out of range, to signal a NaN
	    elsif(dec = NaN) then 
			to_convert(30 downto 23) <= (others => '1');
			to_convert(22 downto 0) <= (others => '1');
		-- This case deals with the denormalized numbers that absolute value is too large. > ±2^128
		elsif(dec >= pos_inf or dec <= neg_inf) then--  if(dec > (real(2**127) * max_n_m) or dec < (real(-2**-126) * min_d_m)) then
			to_convert(30 downto 23) <= (others => '1');
			to_convert(22 downto 0) <= (others => '0');
		-- This case deals with the denormalized numbers that absolute value is too small. < ±2^-126.
		elsif(dec = 0.0 or abs(dec) <= max_d_m) then
			to_convert(30 downto 23) <= (others => '0');
			to_convert(22 downto 0) <= std_logic_vector(to_unsigned(integer(abs(dec)/max_d_m*(2.0**23)), 23));
			
		-- This case deals with the normalized numbers.
		else
			to_convert(30 downto 23) <= std_logic_vector(to_unsigned((integer(exponent(dec)) + 127), 8));
			to_convert(22 downto 0) <= std_logic_vector(to_unsigned(integer(((abs(dec)/(2.0**integer(exponent(dec)))) - 1.0)*(2.0**23)), 23));
			
		end if;
		


      -- pass the converted value to the dummy module:
      wait for 1*clk_period;
      operand <= to_convert;     
      wait for 1 * clk_period;
      enable <= '1';
      wait for 1 * clk_period;
      enable <= '0';
      operand <= x"00000000";

      -- Conversion from IEEE 754 to real
      wait until valid = '1';
      t_result <= result;
		wait for clk_period;
		
		if(t_result(30 downto 23) = x"FF") then
			if(t_result(22 downto 0) = ("000" & x"00000")) then
				--if infinity:
				if(t_result(31) = '1') then
					converted <= neg_inf;
				else
					converted <= pos_inf;
				end if;
			else
				-- This represents the "Not a Number" representation
				converted <= (2.0)**(130);
			end if;
		elsif(t_result(30 downto 23)= x"00") then
		-- if format is for denormal nr.:                 
			converted <=((-1.0)**(to_integer(unsigned(t_result(31 downto 31))))) * ((2.0)**(-149)) * real(to_integer( unsigned( t_result( 22 downto 0)))) ;
		else
	   -- if format is for normal nr.:
			converted <=((-1.0)**(to_integer(unsigned(t_result(31 downto 31))))) * ((2.0)**(to_integer(unsigned(t_result(30 downto 23)))-127)) * ((real(to_integer( unsigned( t_result( 22 downto 0)))) * ((2.0)**(-23)))+1.0) ;
		end if;
      wait for clk_period;
      
     --Changing the stimulus 
	  case cnt is
			when 1 =>  dec<= -1.275;
			-- values near normalised range border:
			when 2 =>  dec<= pos_inf;
			when 3 =>  dec<= neg_inf;
            -- other cases:
			when 4 =>  dec<= 0.1;
			when 5 =>  dec<= -0.1;
            -- zero:
			when 6 =>  dec<= 0.0;
			-- denormalized nr:
			when 7 =>  dec<= -0.17 * ((2.0)**(-126));
			when 8 =>  dec<= 0.17 * ((2.0)**(-126)); 
            when 9 =>  dec<= (2.0)**(-149); --upper limit
			when 10 =>  dec<= -((2.0)**(-149)); -- lower limit
            -- other random nr.
			when 11 =>  dec<= 31.31;
			when 12 =>  dec<= -64.2558;
			when 13 =>  dec<= 128.0;
            -- signaling NaN
            when 14 =>  dec<= NaN;
			-- values for both infinities for number which abs(nr) > 2**128 :
            when 15 =>  dec<= 1.1 * (2.0**128);
            when 16 =>  dec<= -1.1 * (2.0**128);
			-- negative zero:
			when 17 =>  dec<= neg_zero;
		   when others => wait;
		end case ;
  
		cnt<=cnt+1;
    
   end process;


END;
