library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity key2ascii is
    Port (
        key_code   : in  std_logic_vector(7 downto 0);
        ascii_code : out std_logic_vector(7 downto 0)
    );
end key2ascii;

architecture Behavioral of key2ascii is
begin
    process(key_code)
    begin
        case key_code is
            -- Dígitos
            when x"45" => ascii_code <= x"30"; -- 0
            when x"16" => ascii_code <= x"31"; -- 1
            when x"1E" => ascii_code <= x"32"; -- 2
            when x"26" => ascii_code <= x"33"; -- 3
            when x"25" => ascii_code <= x"34"; -- 4
            when x"2E" => ascii_code <= x"35"; -- 5
            when x"36" => ascii_code <= x"36"; -- 6
            when x"3D" => ascii_code <= x"37"; -- 7
            when x"3E" => ascii_code <= x"38"; -- 8
            when x"46" => ascii_code <= x"39"; -- 9

            -- Letras A–Z
            when x"1C" => ascii_code <= x"41"; -- A
            when x"32" => ascii_code <= x"42"; -- B
            when x"21" => ascii_code <= x"43"; -- C
            when x"23" => ascii_code <= x"44"; -- D
            when x"24" => ascii_code <= x"45"; -- E
            when x"2B" => ascii_code <= x"46"; -- F
            when x"34" => ascii_code <= x"47"; -- G
            when x"33" => ascii_code <= x"48"; -- H
            when x"43" => ascii_code <= x"49"; -- I
            when x"3B" => ascii_code <= x"4A"; -- J
            when x"42" => ascii_code <= x"4B"; -- K
            when x"4B" => ascii_code <= x"4C"; -- L
            when x"3A" => ascii_code <= x"4D"; -- M
            when x"31" => ascii_code <= x"4E"; -- N
            when x"44" => ascii_code <= x"4F"; -- O
            when x"4D" => ascii_code <= x"50"; -- P
            when x"15" => ascii_code <= x"51"; -- Q
            when x"2D" => ascii_code <= x"52"; -- R
            when x"1B" => ascii_code <= x"53"; -- S
            when x"2C" => ascii_code <= x"54"; -- T
            when x"3C" => ascii_code <= x"55"; -- U
            when x"2A" => ascii_code <= x"56"; -- V
            when x"1D" => ascii_code <= x"57"; -- W
            when x"22" => ascii_code <= x"58"; -- X
            when x"35" => ascii_code <= x"59"; -- Y
            when x"1A" => ascii_code <= x"5A"; -- Z

            -- Espaço
            when x"29" => ascii_code <= x"20"; -- space

            -- Sinais
            when x"4E" => ascii_code <= x"2D"; -- -
            when x"55" => ascii_code <= x"2B"; -- +

            -- Tecla ENTER (caractere de controle '\n')
            when x"5A" => ascii_code <= x"0A";

            when others => ascii_code <= x"2A"; -- '*'
        end case;
    end process;
end Behavioral;
