// Code your design here

import "DPI-C" function void hello();

module sv_pli ();

  initial begin
    hello;
     #10  $finish;
  end

endmodule
