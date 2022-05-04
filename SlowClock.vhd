-------------------------------------------------------------------------------------------------------
-- Modulen SlowClock används för att implementera en långsam klocka, som tickar med valfri frekvens
-- mellan 1 Hz, 2 Hz, 4 Hz samt 8 Hz. Insignal frequency avgör den långsamma klockans frekvens.
-- Utsignal slow_clock tickar sedan med vald frekvens. I praktiken utgörs datatypen frequency_t 
-- enbart av ett osignerat heltal, som räknas upp till innan den långsamma klockan tickar. 
--
-- Som exempel, eftersom klockan på FPGA-kortet tickar med en frekvens på 50 MHz, så sker 50 miljoner
-- tickningar med den snabba klockan under en sekund. För att erhålla en långsam klocka med en
-- frekvens på 1 Hz, så måste därmed 50 miljoner snabba klockpulser räknas upp innan den långsamma
-- klockan slår. Genom att variera storleken på insignal frequency kan därmed den långsamma klockans
-- frekvens enkelt uppdateras.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.definitions.all;

entity SlowClock is
   port
   (
      clock      : in std_logic;   -- 50 MHz klocka.
      reset_n    : in std_logic;   -- Asynkron inverterande reset-signal, nollställer den långsamma klockan.
      frequency  : in frequency_t; -- Den långsamma klockans frekvens, realiseras som ett osignerat heltal.
      slow_clock : out std_logic   -- Utsignal från den långsamma klockan, ettställs när klockan tickar.
  );
end entity;

architecture Behaviour of SlowClock is
signal counter_s     : frequency_t; -- Räknare, räknar upp till osignerat heltal för aktuell frekvens.
signal counter_max_s : frequency_t; -- Uppräkningsvärde för vald frekvens, kopplas till insignal frequency.
begin

   ------------------------------------------------------------------------------------------------------------
   -- Vid reset nollställs den långsamma klockan samt räknaren. Annars räknas antalet snabba klockpulser upp.
   -- När tillräckligt antal klockpulser har räknats upp för aktuell frekvens, så ettställs den långsamma
 -- klockan, samtidigt som räknaren nollställs inför nästa uppräkning. När detta sker så tickar den
 -- långsamma klockan. Övrig tid hålls den långsamma klockan låg.
  ------------------------------------------------------------------------------------------------------------
   process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         slow_clock <= '0';
         counter_s <= 0;
      elsif (rising_edge(clock)) then
         counter_s <= counter_s + 1;
         if (counter_s >= counter_max_s) then
            slow_clock <= '1';
            counter_s <= 0;
         else
            slow_clock <= '0';
         end if;
      end if;
   end process;

   counter_max_s <= frequency;
   
end architecture;