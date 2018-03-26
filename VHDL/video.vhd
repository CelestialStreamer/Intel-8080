----------------------------------------------------------------------------------
-- Company:        Weber State University
-- Engineer:       Michael Woodruff
--
-- Create Date:    20:37:50 11/22/2013
-- Design Name:
-- Module Name:    video - Behavioral
-- Project Name:   8080
-- Target Devices: Whatever works
-- Tool versions:
-- Description:    
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Video is
         port (
         clk : in std_logic;
-- Video memory
addressVideo : out std_logic_vector(15 downto 0);
   dataVideo : in std_logic_vector(7 downto 0);
-- VGA timer (subset)
     blank   : in  std_logic;
     hstart  : in std_logic;
     vga_row : in integer range 0 to 805; -- 805 @ 65MHz, 524 @ 25MHz
-- VGA output
       vga_r : out std_logic;
       vga_g : out std_logic;
       vga_b : out std_logic);
end Video;

architecture Behavioral of Video is
   -- 1024x768 (clk=65MHz)     is 1024, 24, 136,    160;    768, 3,  6, 29
   -- 640x480  (clk=25.175MHz) is 640,  16, 92(96), 46(48); 480, 10, 2, 33
   constant SCREEN_WIDTH  : integer := 1024;
   constant SCREEN_HEIGHT : integer := 768;
   
   constant VIDEO_WIDTH   : integer := 256;
   constant VIDEO_HEIGHT  : integer := 224;
   
   constant SCALE         : integer := 3;
   constant DISPLAY_W     : integer := VIDEO_WIDTH * SCALE;
   constant DISPLAY_H     : integer := VIDEO_HEIGHT * SCALE;
   
   constant VIDEO_RAM : unsigned :=  X"2400"; -- Video address starts at 2400h
      
   signal pixel_8 : std_logic_vector(7 downto 0); -- Buffer from video memory
   
   signal vga_col : integer range 0 to 1343; -- 1343 for 65MHz or 792 for 25 MHz
   signal pix : std_logic;
   
   signal sub_pixel_h : integer range 0 to SCALE - 1; -- 0 indicates new pixel, drawn horizontal
   signal sub_pixel_v : integer range 0 to SCALE - 1; -- 0 indicates new pixel, drawn vertical
   signal pixel_bit   : integer range 0 to 7; -- which bit are we currently using in the byte
   signal pixel_byte  : integer range 0 to (VIDEO_WIDTH * VIDEO_HEIGHT / 8) - 1; -- which byte are we reading
   
   -- signal vga_row_vec : std_logic_vector(10 downto 0); -- just for debug
   -- signal vga_col_vec : std_logic_vector(10 downto 0); -- just for debug
   -- signal pixel_bit_vec : std_logic_vector(2 downto 0); -- just for debug
   -- signal pixel_byte_vec : std_logic_vector(12 downto 0); -- just for debug
   
   signal draw : boolean;
   
   signal drawCol : boolean; -- In horizontal range of video?
   signal drawRow : boolean; -- In vertical   range of video
begin
   -- vga_row_vec    <= std_logic_vector(to_unsigned(vga_row,    vga_row_vec'length));
   -- vga_col_vec    <= std_logic_vector(to_unsigned(vga_col,    vga_col_vec'length));
   -- pixel_bit_vec  <= std_logic_vector(to_unsigned(pixel_bit,  pixel_bit_vec'length));
   -- pixel_byte_vec <= std_logic_vector(to_unsigned(pixel_byte, pixel_byte_vec'length));

   -- current screen column (0, 1, ... 799)
   VGA_COUNTER:
   process(clk)
   begin
      if rising_edge(clk) then
         if hstart = '1' then vga_col <= 0;
         else                 vga_col <= vga_col + 1;
         end if;
      end if;
   end process;
   
   process(clk)
      constant UPDATE_START : integer := (SCREEN_WIDTH - DISPLAY_W) / 2; -- 64
      constant UPDATE_END   : integer := SCREEN_WIDTH - UPDATE_START; -- 576
   begin
      if rising_edge(clk) then
         if    vga_col = (UPDATE_START - 1) - 1 then drawCol <= true;  -- The double -1 is to account for two registers updating
         elsif vga_col = (UPDATE_END   - 1) - 1 then drawCol <= false; -- The double -1 is to account for two registers updating
         end if;
      end if;
   end process;
   
   process(clk)
      constant UPDATE_START : integer := (SCREEN_HEIGHT - DISPLAY_H) / 2; -- 16
      constant UPDATE_END   : integer := SCREEN_HEIGHT - UPDATE_START; -- 464
   begin
      if rising_edge(clk) then
         if    vga_row = (UPDATE_START - 1) - 1 then drawRow <= true;  -- The double -1 is to account for two registers updating
         elsif vga_row = (UPDATE_END   - 1) - 1 then drawRow <= false; -- The double -1 is to account for two registers updating
         end if;
      end if;
   end process;
   
   draw <= drawCol and drawRow; -- Inside video frame, commence drawing
   
   SUBPIXELH: -- 0 1 loop sequence when draw=true
   process(clk)
   begin
      if rising_edge(clk) then
         if hstart = '1' then sub_pixel_h <= 0;
         elsif draw then -- . . . 0 1 0 1 . . .
            if sub_pixel_h = SCALE - 1 then
               sub_pixel_h <= 0;
            else
               sub_pixel_h <= sub_pixel_h + 1;
            end if;
         end if;
      end if;
   end process;
   
   SUBPIXELV:
   process(clk)
   begin
      if rising_edge(clk) then
         if hstart = '1' then
            if vga_row = 0 then
               sub_pixel_v <= 2; -- 2 for 65MHz and 0 for 25 MHz
            else
               if sub_pixel_v = SCALE - 1 then
                  sub_pixel_v <= 0;
               else
                  sub_pixel_v <= sub_pixel_v + 1;
               end if;
            end if;
         end if;
      end if;
   end process;
   
   PIXELBIT: -- 0 1 2 3 4 5 6 7 loop sequence when UPDATE_START < vga_col < UPDATE_END
   process(clk)
   begin
      if rising_edge(clk) then
         if    hstart = '1' then pixel_bit <= 0;
         elsif draw then -- . . . 0 1 2 3 4 5 6 7 0 1 . . .
            if sub_pixel_h = SCALE - 1 then -- Move to next pixel only if it's time
               if pixel_bit = 7 then pixel_bit <= 0;
               else                  pixel_bit <= pixel_bit + 1;
               end if;
               -- if pixel_bit = 0 then pixel_bit <= 7;
               -- else                  pixel_bit <= pixel_bit - 1;
               -- end if;
            end if;
         end if;
      end if;
   end process;
   
   PIXELBYTE: -- increments pixelbyte when finished drawing current byte
   process(clk)
   begin
      if rising_edge(clk) then
         if hstart = '1' then
            if vga_row = 0 then
               pixel_byte <= 0;
            elsif sub_pixel_v /= SCALE - 1 then -- redraw same row
               if drawRow then
                  pixel_byte <= pixel_byte - VIDEO_WIDTH / 8;
               end if;
            end if;
         elsif draw then -- . . . 0 1 2 3 4 5 6 7 0 1 . . .
            if pixel_bit = 0 and sub_pixel_h = SCALE - 1 then
               pixel_byte <= pixel_byte + 1;
            end if;
         end if;
      end if;
   end process;
   
   process(draw, pixel_bit, sub_pixel_h, dataVideo, pixel_8, pixel_bit)
   begin
      if draw then
         if pixel_bit = 0 and sub_pixel_h = 0 then
            pix <= dataVideo(pixel_bit); -- write through register
         else
            pix <= pixel_8(pixel_bit);
         end if;
      else
         pix <= '0';
      end if;
   end process;
   
   vga_r <= pix and blank; -- turn off red channel when drawing green pixels
   vga_g <= pix and blank;
   vga_b <= pix and blank; -- turn off blue channel when drawing green pixels
   
   -- Video memory access
   process(pixel_byte)
   begin
      addressVideo <= std_logic_vector(VIDEO_RAM + to_unsigned(pixel_byte,addressVideo'length));
   end process;
   
   VIDEO_MEM_ACCESS:
   process(clk)
   begin
      if rising_edge(clk) then
         if pixel_bit = 0 and sub_pixel_h = 0 then -- This may be off by one clock period
            pixel_8 <= dataVideo;
         end if;
      end if;
   end process;

end Behavioral;