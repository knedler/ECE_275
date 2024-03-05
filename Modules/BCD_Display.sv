module BCD_DisplayO(
input BCDValue3, BCDValue2, BCDValue1, BCDValue0,
output LEDSegment0, LEDSegment1, LEDSegment2, LEDSegment3, LEDSegment4, LEDSegment5, LEDSegment6
);
	assign LEDSegment0 = ~(BCDValue3 | BCDValue1 | BCDValue2 & BCDValue0 | ~BCDValue2 & ~BCDValue0);
	assign LEDSegment1 = ~(~BCDValue2 | ~BCDValue1 & ~BCDValue0 | BCDValue1 & BCDValue0);
	assign LEDSegment2 = ~(BCDValue2 | ~BCDValue1 | BCDValue0);
	assign LEDSegment3 = ~(~BCDValue2 & ~BCDValue0 | BCDValue1 & ~BCDValue0 | BCDValue2 & ~BCDValue1 & BCDValue0 | ~BCDValue2 & BCDValue1 | BCDValue3);
	assign LEDSegment4 = ~(~BCDValue2 & ~BCDValue0 | BCDValue1 & ~BCDValue0);
	assign LEDSegment5 = ~(BCDValue3 | ~BCDValue1 & ~BCDValue0 | BCDValue2 & ~BCDValue1 | BCDValue2 & ~BCDValue0);
	assign LEDSegment6 = ~(BCDValue3 | BCDValue2 & ~BCDValue1 | ~BCDValue2 & BCDValue1 | BCDValue1 & ~BCDValue0);
endmodule


