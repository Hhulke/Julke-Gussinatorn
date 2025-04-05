library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Julke_Gussinatorn is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end Julke_Gussinatorn;

architecture Roxen of Julke_Gussinatorn is

    type rom_type is array(7 downto 0) of std_logic_vector(7 downto 0);
    signal ROM_Mrse : rom_type := (
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000"
        );

    signal CELL_Mrse : std_logic_vector(1 downto 0) := "00";
    signal ui_in_old : std_logic_vector(3 downto 0) := "0000";
    signal ui_in_sync : std_logic_vector(3 downto 0) := "0000";
    signal SR_Mrse : std_logic_vector(7 downto 0) := "00000000";
    signal I_SR_Mrse : integer range 0 to 3 := 0;
    signal FLUSH_SR_Mrse : std_logic := "0";
    signal I_ROM_Mrse : integer range 0 to 63 := 0;

    begin

        --uo_out <= std_logic_vector(unsigned(ui_in) + unsigned(uio_in));
        uo_out <= not (ui_in and uio_in);
        uio_out <= "00000000";
        uio_oe <= "00000000";

        process(clk, rst_n) begin
            #RESET
        end process;

        process(ui_in(2 downto 0), clk) begin

            if rising_edge(clk) then
                ui_in_old <= ui_in(3 downto 0);
                ui_in_sync <= ui_in(3 downto 0) and not ui_in_old;

                if (ui_in_sync(2) = "1") then
                    FLUSH_SR_Mrse <= "1";
                end if;

                if (ui_in_sync(0) = "1") or (ui_in_sync(1) = "1") and not (FLUSH_SR_Mrse = "1") then
                    CELL_Mrse <= ui_in_sync(1 downto 0);
                else if (FLUSH_SR_Mrse = "1") then
                    CELL_Mrse <= "00";
                end if;

                if (I_SR_Mrse = 3) then
                    I_SR_Mrse <= 0;
                    FLUSH_SR_Mrse <= "0";

                else if (FLUSH_SR_Mrse = "1")  or (ui_in_sync(0) = "1") or (ui_in_sync(1) = "1") then
                        SR_Mrse <= SR_Mrse(SR_Mrse'high - 2 downto SR_Mrse'low) & CELL_Mrse;
                        I_SR_Mrse <= I_SR_Mrse + 1;
                end if;     
            end if;       
        end process;
end Roxen;