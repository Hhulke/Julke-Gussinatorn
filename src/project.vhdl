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

    type rom_type is array(31 downto 0) of std_logic_vector(7 downto 0);
    signal ROM_Mrse : rom_type := (
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
            "00000000",
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
    signal I_ROM_Mrse : integer range 0 to 31 := 0;
    
    signal TIME_Mrse : integer range 0 to 16383 := 0;
    signal STATE_Mrse : std_logic_vector(1 downto 0) := "00";

    begin
        --uo_out <= std_logic_vector(unsigned(ui_in) + unsigned(uio_in));
        --uo_out <= not (ui_in and uio_in);
        uio_out <= "00000000";
        uio_oe <= "00000000";

        ui_in_sync <= ui_in(3 downto 0) and not ui_in_old;

        process(ui_in_sync, FLUSH_SR_Mrse) begin
            --Tilldela morsekod-värde;
            if ((ui_in_sync(0) = '1') or (ui_in_sync(1) = '1')) and (not (FLUSH_SR_Mrse = '1')) then
                CELL_Mrse <= ui_in_sync(1 downto 0);
            else
                CELL_Mrse <= "00";
            end if;
        end process;
        

        process(clk, rst_n) begin
            --Läs och skifta till rom;
            if (rst_n = '1') then
                ROM_Mrse <= (
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000",
                                "00000000"
                            );
                I_ROM_Mrse <= 0;
                I_SR_Mrse <= 0;
            elsif rising_edge(clk) then

                ui_in_old <= ui_in(3 downto 0);

                if STATE_Mrse = "00" then
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

                if ui_in_sync(3) = '1' then
                    I_ROM_Mrse <= 0;
                    I_SR_Mrse <= 0;
                    STATE_Mrse <= "01";
                end if;

                if STATE_Mrse = "01" then
                    if I_ROM_Mrse = 31 then
                        I_ROM_Mrse <= 0;
                        I_SR_Mrse <= 0;
                        STATE_Mrse <= "00";
                    else
                        STATE_Mrse <= "11";
                    end if;

                    if I_SR_Mrse = 3 then
                        I_SR_Mrse <= 0;
                        I_ROM_Mrse <= I_ROM_Mrse + 1;
                    end if;
  
                    SR_Mrse <= ROM_Mrse(I_ROM_Mrse);
                    
                    case I_SR_Mrse is 
                        when 0 =>
                            CELL_Mrse <= SR_Mrse(7 downto 6);
                        when 1 =>
                            CELL_Mrse <= SR_Mrse(5 downto 4);
                        when 2 =>
                            CELL_Mrse <= SR_Mrse(3 downto 2);
                        when 3 =>
                            CELL_Mrse <= SR_Mrse(1 downto 0);
                        when others =>
                            null;
                    end case;

                elsif STATE_Mrse = "10" then
                    if TIME_Mrse > 1000 then
                        TIME_Mrse <= TIME_Mrse - 1;
                        uo_out(0) <= '1';
                    elsif TIME_Mrse > 1 then
                        uo_out(0) <= '0';
                        TIME_Mrse <= TIME_Mrse - 1;
                    else 
                        I_SR_Mrse <= I_SR_Mrse + 1;
                        STATE_Mrse <= "01";
                    end if;
                elsif STATE_Mrse = "11" then
                    case CELL_Mrse is
                        when "00" =>
                            SR_Mrse <= ROM_Mrse(I_ROM_Mrse);
                            STATE_Mrse <= "01";
                            if SR_Mrse = "00000000" then
                                I_SR_Mrse <= I_SR_Mrse + 1;
                            end if; 
                            
                        when "01" =>
                            TIME_Mrse <= 3000;
                            STATE_Mrse <= "10";
                        when "10" =>
                            TIME_Mrse <= 6000;
                            STATE_Mrse <= "10";
                        when others =>
                            null;
                    end case;
                end if;
            end if;  

        end process;
end Roxen;