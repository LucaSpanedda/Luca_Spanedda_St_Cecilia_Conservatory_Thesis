// import faust standard library
import("stdfaust.lib");

// Peak Max with IIR filter and max comparison
peakmax = loop
    with{
        loop(x) = \(y).((y , abs(x)) : max) ~ _ ;
    };
    
process = _ : peakmax;