library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_julke_gussinatorn is
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
end tt_um_julke_gussinatorn;

architecture Roxen of tt_um_julke_gussinatorn is

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
    signal FLUSH_SR_Mrse : std_logic := '0';
    signal I_ROM_Mrse : integer range 0 to 7 := 0;

    begin
        --uo_out <= std_logic_vector(unsigned(ui_in) + unsigned(uio_in));
        uo_out <= not (ui_in and uio_in);
        uio_out <= "00000000";
        uio_oe <= "00000000";

        ui_in_sync <= ui_in(3 downto 0) and not ui_in_old;

        process(ui_in_sync, FLUSH_SR_Mrse) begin
            #Tilldela morsekod-värde
            if ((ui_in_sync(0) = '1') or (ui_in_sync(1) = '1')) and (not (FLUSH_SR_Mrse = '1')) then
                CELL_Mrse <= ui_in_sync(1 downto 0);
            elsif (FLUSH_SR_Mrse = '1') then
                CELL_Mrse <= "00";
            end if;
        end process;
        

        process(clk, rst_n) begin
            #Läs och skifta till rom
            if rising_edge(clk) then
                if (rst_n = '1') then
                    ROM_Mrse <= (
                        "00000000",
                        "00000000",
                        "00000000",
                        "00000000",
                        "00000000",
                        "00000000",
                        "00000000",
                        "00000000"
                    );
                    SR_Mrse <= "00000000";
                    I_SR_Mrse <= 0;
                    FLUSH_SR_Mrse <= '0';
                    I_ROM_Mrse <= 0;
                end if;

                ui_in_old <= ui_in(3 downto 0);

                if (ui_in_sync(2) = '1') then
                    FLUSH_SR_Mrse <= '1';
                end if;

                if (I_SR_Mrse = 4) then
                    I_SR_Mrse <= 0;
                    FLUSH_SR_Mrse <= '0';

                    ROM_Mrse(I_ROM_Mrse) <= SR_Mrse;
                    I_ROM_Mrse <= I_ROM_Mrse + 1;

                    SR_Mrse <= "00000000";


                elsif (FLUSH_SR_Mrse = '1')  or (ui_in_sync(0) = '1') or (ui_in_sync(1) = '1') then
                        SR_Mrse <= SR_Mrse(5 downto 0) & CELL_Mrse;
                        I_SR_Mrse <= I_SR_Mrse + 1;
                end if;     
            end if;  

        end process;
end Roxen;