library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2c_controller_tb_pkg is
  -- Constant List
  constant clk_hz         : integer := 10_000_000;
  constant clk_period     : time    := 1 sec / clk_hz;
  -- I2C
  constant i2c_hz         : integer := 100_000;
  constant i2c_period     : time    :=  1 sec / i2c_hz;
  constant target_addr    : std_logic_vector(6 downto 0)  := "1010101";
  --constant sda_delay_ns   : integer := 400;
  --constant scl_hp_cnt_max : integer := 31;  -- Number of half cycles that the reset process wait until for safetely releasing the bus

end package;