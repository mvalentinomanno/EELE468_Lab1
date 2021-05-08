--Michael Valentino-Manno
--2/2/21 LAB 1
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity find_y0 is
	generic (W_bits	      : positive := 32; 
		 F_bits       : positive := 16); 
	port 	(clk	      : in std_logic;
		 x 	      : in std_logic_vector(W_bits - 1 downto 0);
		 y0 	      : out std_logic_vector(W_bits - 1 downto 0));
end entity;

architecture find_y0_arch of find_y0 is

constant twoneg12 : unsigned(7 downto 0) := "01011010"; --.71 which is about 2^-.5
signal alpha, beta : signed(5 downto 0);
signal beta1, beta2, beta3, beta4, beta5 : signed(5 downto 0);
signal zeros : std_logic_vector(4 downto 0);
signal xalpha, xbeta : unsigned(W_bits - 1 downto 0);
signal xalpha1,xalpha2, xb3u : unsigned(W_bits - 1 downto 0);
signal x1, x2, x3 : std_logic_vector(W_bits - 1 downto 0);
signal xb32 : std_logic_vector(W_bits - 1 downto 0) := (others => '0');
signal y0_even : unsigned(W_bits*2 - 1 downto 0);
signal y0_odd_temp : unsigned(W_bits*2 + 8 - 1 downto 0);
signal Y0_sig : std_logic_vector(W_bits - 1 downto 0) := (others => '0');
--signal beta_int : integer;

component lzc is
	port(clk	: in std_logic;
	     lzc_vector : in std_logic_vector(31 downto 0);
	     lzc_count  : out std_logic_vector(4 downto 0));
end component;

component ROM is
	port(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

begin

	L_Z : lzc port map(clk => clk, lzc_vector => x, lzc_count => zeros); --find leading zeros


	BETA_CALC : process(clk) --find beta
		begin
			if(rising_edge(clk)) then
				beta <= to_signed(W_bits,beta'length) - to_signed(F_bits,beta'length) - signed(zeros) - 1;
				--beta_int <= to_integer(beta);
			end if;
		end process;

	ALPHA_CALC: process(clk) --find alpha
		begin
			if(rising_edge(clk)) then
				if(beta(0) = '0') then --this would mean that beta is even, so we do -2b + .5b
					alpha <= shift_right(beta, 1) - shift_left(beta,1);
				else --this would mean that beta is odd, so we do -2b + .5b + .5
					alpha <= 1 - shift_left(beta,1) + shift_right(beta,1);	--add 1 instead of .5 because a .5 gets truncated off
				end if;
			end if;
		end process;

	XBETA_CALC : process(clk) --find xbeta
		begin
			if(rising_edge(clk)) then
				xbeta <= shift_right(unsigned(x2),to_integer(beta)); --need storage and diff signals
			end if;
		end process;


	XALPHA_CALC : process(clk) --find xalpha
		begin
			if(rising_edge(clk)) then
				xalpha <= shift_left(unsigned(x3), to_integer(alpha)); --need storage and diff signals
			end if;
		end process;


	BETA_STORAGE : process(clk) --need to store beta, x and xalpha values in order to pipeline
		begin
			if(rising_edge(clk)) then
				beta1 <= beta;
				beta2 <= beta1;
				beta3 <= beta2;
				beta4 <= beta3;
				beta5 <= beta4;

				x1 <= x;
				x2 <= x1;
				x3 <= x2;

				xalpha1 <= xalpha;
				xalpha2 <= xalpha1;
			end if;
		end process; 

	Rom_inst : Rom PORT MAP (
		address	 => std_logic_vector(xbeta(15 downto 0)),
		clock	 => clk,
		q	 => xb32
	);

	XB_32 : process(clk) 
		begin
			if(rising_edge(clk))then
				xb3u <= "000000000000000" & unsigned(xb32(31 downto 15));
			end if;
		end process;

	Y0_CALC_1 : process(clk)
		begin
			if(rising_edge(clk)) then
				if(beta4(0) = '0') then --beta is even
					y0_even <= xalpha2 * xb3u;            --unsigned(("000000000000000" & xb32(31 downto 15)));
				else --beta is odd
					y0_odd_temp <= xalpha2 * xb3u * twoneg12;           --unsigned(("000000000000000" & xb32(31 downto 15))); 
				end if;
			end if;
		end process;


	Y0_CALC_2 : process(clk)  --saves needed bits to output
		begin
			if(rising_edge(clk)) then
				if(beta5(0) = '0') then --beta is even
					Y0_sig <= std_logic_vector(y0_even(47 downto 16));
				else  --beta is odd
					y0_sig <= std_logic_vector(y0_odd_temp(54 downto 23));
				end if;
			end if;
		end process;

	y0 <=  Y0_sig;

end architecture;