//---------------------------------------------------------- FAUST CODE
import("stdfaust.lib");

// LAR with Peak Max - IIR filter and max comparison
peakmax = loop
with{
    loop(x) = \(y).((y , abs(x)) : max)~_;
};

LARpeakmax = _ <: (_ * (1 - (_ : peakmax)));
process = _ : LARpeakmax;
//---------------------------------------------------------------------
