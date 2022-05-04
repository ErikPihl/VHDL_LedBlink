-------------------------------------------------------------------------------------------------------
-- Modulen LedBlink används för att blinka en lysdiod med en frekvens som kan väljas mellan 1 Hz,
-- 2 Hz, 4 Hz samt 8Hz. Modulens insignaler utgörs av en 50 Mhz klocka, en asynkron inverterande
-- reset-signal samt tre slide-switchar för kontroll av blinkfrekvens och enable-signal för lysdioden.
-- Utsignal led utgörs av lysdioden i fråga.
--
-- För styrsignalerna gäller följande:
--
-- switch[2:0]       Utsignal
--    0xx         led alltid släckt
--    100         led blinkar med en frekvens på 1 Hz
--    101         led blinkar med en frekvens på 2 Hz
--    110         led blinkar med en frekvens på 4 Hz
--    111         led blinkar med en frekvens på 8 Hz
--
-- Notera ovan att switch[2] används som enable-signal för lysdioden. När denna signal är låg så 
-- hålls lysdioden alltid släckt. switch[1:0] används enbart för val av klockfrekvens.
--
-- För att styra lysdioden används en signal av den egenskapade typen led_t, vars medlem output
-- kopplas till utsignal led för att tända/släcka lysdioden, medan medlemmen enabled kopplas till 
-- insignal switch[2] så att denna slide-switch kontrollerar ifall lysdioden kan tändas eller inte.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.definitions.all;

entity LedBlink is 
   port
   (
     clock   : in std_logic;                    -- 50 MHz klocka.
     reset_n : in std_logic;                    -- Asynkron inverterande reset-signal, släcker lysdioden.
     switch  : in std_logic_vector(2 downto 0); -- Kontrollsignaler för blinkfrekvens samt lysdiodens utsignal.
     led     : out std_logic                    -- Lysdiod, blinkas med en viss frekvens.
   );
end entity;

architecture Behaviour of LedBlink is
signal frequency_s        : frequency_t;                  -- Aktuell blinkfrekvens.
signal frequency_select_s : std_logic_vector(1 downto 0); -- Signal för val av frekvens, kopplas till switch[1:0].
signal led_s              : led_t;                        -- Kontrollsignaler för lysdioden.
signal slow_clock_s       : std_logic;                    -- Långsam klocka, tickar med aktuell blinkfrekvens.
begin

   ------------------------------------------------------------------------------------------------------------
   -- Vid reset sätts klockfrekvensen till 1 Hz. Annars kontrolleras insignaler switch[1:0], anslutna via 
   -- signalen frequency_select_s, för att uppdaterablinkfrekvensen.
  ------------------------------------------------------------------------------------------------------------
   process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         frequency_s <= FREQUENCY_1HZ;
      elsif (rising_edge(clock)) then
         case (frequency_select_s) is
            when "00"   => frequency_s <= FREQUENCY_1HZ;
            when "01"   => frequency_s <= FREQUENCY_2HZ;
            when "10"   => frequency_s <= FREQUENCY_4HZ;
            when "11"   => frequency_s <= FREQUENCY_8HZ;
            when others => frequency_s <= FREQUENCY_1HZ;    
         end case;
      end if;
   end process;
   
   ------------------------------------------------------------------------------------------------------------
   -- Vid reset släcks lysdioden. Annars togglas lysdioden när den långsamma klockan slår, förutsatt att
  -- lysdiodens enable-signal switch[2], ansluten via signalen led_s.enabled, är ettställd. Ifall
   -- enable-signalen är låg så hålls lysdioden låg.
   ------------------------------------------------------------------------------------------------------------
   process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         led_s.output <= '0';
      elsif (rising_edge(clock)) then
         if (led_s.enabled = '1') then
            if (slow_clock_s = '1') then
               led_s.output <= not led_s.output;
            end if;
         else
            led_s.output <= '0';
         end if;
      end if;
   end process;
   
   ------------------------------------------------------------------------------------------------------------
   -- Skapar en instans av modulen SlowClock för att realisera en långsam klocka, som ansluts till signalen
  -- slow_clock_s. Signalen frequency_s, används för att ställa in den långsamma klockans frekvens.
 ------------------------------------------------------------------------------------------------------------
   slowClock1: SlowClock port map
   (
      clock      => clock,
      reset_n    => reset_n,
      frequency  => frequency_s,
      slow_clock => slow_clock_s
   );
   
   led <= led_s.output;
   led_s.enabled <= switch(2);
   frequency_select_s <= switch(1 downto 0);
   
end architecture;