library verilog;
use verilog.vl_types.all;
entity transform is
    generic(
        HEIGHT          : integer := 525;
        WIDTH           : integer := 525
    );
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        t_height        : in     vl_logic_vector(9 downto 0);
        t_width         : in     vl_logic_vector(10 downto 0);
        x               : in     vl_logic_vector(10 downto 0);
        y               : in     vl_logic_vector(9 downto 0);
        cv_x            : out    vl_logic_vector(12 downto 0);
        cv_y            : out    vl_logic_vector(12 downto 0)
    );
end transform;
