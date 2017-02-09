library verilog;
use verilog.vl_types.all;
entity sqrt is
    port(
        x_in            : in     vl_logic_vector(21 downto 0);
        clk             : in     vl_logic;
        x_out           : out    vl_logic_vector(11 downto 0);
        rdy             : out    vl_logic
    );
end sqrt;
