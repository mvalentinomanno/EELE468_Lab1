library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpx_rsqrt is

	generic(W_bits : positive := 32;
		F_bits : positive := 16;
		N_iterations : positive := 3);

	port(x : in std_logic_vector(W_bits-1 downto 0);
	     y : out std_logic_vector(W_bits-1 downto 0));

end entity fpx_rsqrt;

architecture fpx_rsqrt_arch of fpx_rsqrt is

	signal Z : positive := 5;
	signal beta,alpha,temp_int : integer;
	signal beta_slv, xa, xb, temp : std_logic_vector(W_bits-1 downto 0);
	

	begin

	BETA_calc : process(x)
		begin	
			beta <= W_bits - F_bits - Z - 1;
		end process;

	ALPHA_calc : process(x)
		begin
				beta_slv <= std_logic_vector(to_unsigned(beta,W_bits-1));
				temp <= std_logic_vector(to_unsigned(beta,W_bits-1));
				temp <= beta_slv(W_bits-2 downto 0);
				temp <= temp & '0'; 	
				beta_slv <= '0' & beta_slv(W_bits-1 downto 1);
			if(beta mod 2 = 1) then
				alpha <= (1/2) + to_integer(signed(beta_slv)) - to_integer(signed(temp));  
			elsif(beta mod 2 = 0) then
				alpha <= to_integer(signed(beta_slv)) - to_integer(signed(temp));  

			end if;
		end process;

	Xalpha : process(x)
		begin
			--xa <= shift_left(x,alpha);
			--xb <= x sra (std_logic_vector(to_unsigned(beta,W_bits-1)));
		end process;
	

end architecture;