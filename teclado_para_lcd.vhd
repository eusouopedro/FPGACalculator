library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration for the top-level module that connects a PS/2 keyboard to an LCD
entity teclado_para_lcd is
    Port (
        clk     : in std_logic;                        -- System clock
        reset   : in std_logic;                        -- Reset signal
        ps2d    : in std_logic;                        -- PS/2 data line
        ps2c    : in std_logic;                        -- PS/2 clock line
        RS, RW  : out std_logic;                       -- LCD control signals: Register Select and Read/Write
        E       : out std_logic;                       -- LCD Enable signal
        DB      : out std_logic_vector(7 downto 0)     -- LCD data bus
    );
end teclado_para_lcd;

architecture Behavioral of teclado_para_lcd is

    -- Keyboard PS/2 receiver component declaration
    component kb_code
        port(
            clk           : in std_logic;
            reset         : in std_logic;
            ps2d          : in std_logic;
            ps2c          : in std_logic;
            rd_key_code   : in std_logic;               -- Read command to fetch the next key code
            key_code      : out std_logic_vector(7 downto 0); -- Key scan code from keyboard
            kb_buf_empty  : out std_logic               -- Indicates if the keyboard buffer is empty
        );
    end component;

    -- Component to convert scan codes to ASCII
    component key2ascii
        port(
            key_code   : in std_logic_vector(7 downto 0);  -- Scan code
            ascii_code : out std_logic_vector(7 downto 0)  -- Corresponding ASCII character
        );
    end component;

    -- State machine states for LCD initialization and character display
    type state_type is (init1, init2, init3, clear, set_cursor, wait_key, show_key);
    signal state : state_type := init1;

    signal key_code     : std_logic_vector(7 downto 0); -- Holds the scan code from the keyboard
    signal ascii_code   : std_logic_vector(7 downto 0); -- Converted ASCII character
    signal kb_buf_empty : std_logic := '1';             -- Indicates whether a key is available
    signal rd_key_code  : std_logic := '0';             -- Command to read a key from keyboard

    signal E_clk : std_logic := '0';                    -- LCD Enable clock (slow clock)
    signal count : integer := 0;                        -- Counter to generate E_clk

begin

    -- Process to generate the LCD Enable clock (e.g., around 200 Hz if clk = 50 MHz)
    process(clk)
    begin
        if rising_edge(clk) then
            count <= count + 1;
            if count = 250_000 then  -- 250000 clock cycles ≈ 5ms at 50 MHz
                E_clk <= not E_clk;  -- Toggle E signal every 5 ms
                count <= 0;
            end if;
        end if;
    end process;

    E <= E_clk;  -- Connect internal E_clk signal to LCD's Enable pin

    -- Instantiation of keyboard input module
    teclado: kb_code
        port map (
            clk => clk,
            reset => reset,
            ps2d => ps2d,
            ps2c => ps2c,
            rd_key_code => rd_key_code,
            key_code => key_code,
            kb_buf_empty => kb_buf_empty
        );

    -- Instantiation of scan code to ASCII converter
    conversao: key2ascii
        port map (
            key_code => key_code,
            ascii_code => ascii_code
        );

    -- Main Finite State Machine controlling LCD behavior
    process(E_clk)
    begin
        if rising_edge(E_clk) then
            rd_key_code <= '0'; -- Default: don't read a new key unless required

            case state is
                when init1 =>
                    -- Function Set: 8-bit, 2 lines, 5x8 dots
                    RS <= '0'; RW <= '0'; DB <= "00111000";
                    state <= init2;

                when init2 =>
                    -- Display ON, cursor OFF, no blink
                    RS <= '0'; RW <= '0'; DB <= "00001100";
                    state <= init3;

                when init3 =>
                    -- Entry Mode: increment cursor, no shift
                    RS <= '0'; RW <= '0'; DB <= "00000110";
                    state <= clear;

                when clear =>
                    -- Clear the LCD display
                    RS <= '0'; RW <= '0'; DB <= "00000001";
                    state <= set_cursor;

                when set_cursor =>
                    -- Set DDRAM address to 0 (start of line 1)
                    RS <= '0'; RW <= '0'; DB <= "10000000";
                    state <= wait_key;

                when wait_key =>
                    -- Wait for a key to be available in buffer
                    if kb_buf_empty = '0' then
                        rd_key_code <= '1';  -- Request key code from keyboard buffer
                        state <= show_key;
                    end if;

                when show_key =>
                    -- Write the ASCII character to the LCD
                    RS <= '1'; RW <= '0'; DB <= ascii_code;
                    state <= wait_key;

            end case;
        end if;
    end process;

end Behavioral;
