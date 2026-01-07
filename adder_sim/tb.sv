module tb();

logic a,b,sum,carry;



adder dut(.a,.b,.s(sum),.c(carry));
initial begin

	$monitor(" a= %b, b= %b, sum= %b carry= %b",a,b,sum,carry);
a=0;b=0; #10
a=0;b=1; #10
a=1;b=0; #10
a=1;b=1; #10

$display("done");

$finish;

end
endmodule

