library verilog;
use verilog.vl_types.all;
entity n20_divider is
    generic(
        WIDTH           : integer := 22
    );
    port(
        clk             : in     vl_logic;
        sign            : in     vl_logic;
        start           : in     vl_logic;
        dividend        : in     vl_logic_vector;
        divisor         : in     vl_logic_vector;
        quotient        : out    vl_logic_vector;
        remainder       : out    vl_logic_vector;
        ready           : out    vl_logic
    );
end n20_divider;
