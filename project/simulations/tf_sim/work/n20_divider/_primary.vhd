library verilog;
use verilog.vl_types.all;
entity n20_divider is
    port(
        dividend        : in     vl_logic_vector(21 downto 0);
        divisor         : in     vl_logic_vector(12 downto 0);
        quot            : out    vl_logic_vector(21 downto 0);
        remd            : out    vl_logic_vector(12 downto 0);
        clk             : in     vl_logic;
        rfd             : out    vl_logic
    );
end n20_divider;
