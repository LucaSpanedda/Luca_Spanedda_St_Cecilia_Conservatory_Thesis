// import faust standard library
import("stdfaust.lib");

// Peak Max IIR filter with max comparison and RT60 Decay 
peakenvelope(t, x) = abs(x) <: loop ~ _ * rt60(t)
with{
    loop(y, z) = ( (y, z) : max);
    rt60(t) = 0.001^((1/ma.SR) / t);
};

decayFactor = 10;
process = _ : peakenvelope(decayFactor);