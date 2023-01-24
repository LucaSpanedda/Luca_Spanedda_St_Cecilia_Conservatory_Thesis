// import faust standard library
import("stdfaust.lib");

// Peak Max IIR filter with max comparison and RT60 Decay 
peakenvelope(t, x) = abs(x) <: loop ~ _ * rt60(t)
with{
    loop(y, z) = ( (y, z) : max);
    rt60(t) = 0.001^((1/ma.SR) / t);
};
// process = _ : peakenvelope(decayFactor);

// PeakHolder with Timer
peakHolder(holdTime, x) = loop ~ si.bus(2) : ! , _
with {
    loop(timerState, outState) = timer , output
    with {
        isNewPeak = abs(x) >= outState;
        isTimeOut = timerState >= (holdTime * ma.SR - 1);
        bypass = isNewPeak | isTimeOut;
        timer = ba.if(bypass, 0, timerState + 1);
        output = ba.if(bypass, abs(x), outState);
    };
};
// process = _ : peakHolder(1);

// PeakHold module with an exponential decay curve
peakHoldwDecay(holdSeconds, frequencyCut, decayT60, x) = x : 
    peakHolder(holdSeconds) : LPTPT(frequencyCut) : peakenvelope(decayT60);

// Zavalishin's Onepole TPT Filter
onePoleTPT(cf, x) = loop ~ _ : ! , si.bus(3) // Outs: lp , hp , ap
with {
    g = tan(cf * ma.PI * (1.0/ma.SR));
    G = g / (1.0 + g);
    loop(s) = u , lp , hp , ap
    with {
        v = (x - s) * G; u = v + lp; lp = v + s; hp = x - lp; ap = lp - hp;
    };
};
// Lowpass TPT
LPTPT(cf, x) = onePoleTPT(cf, x) : (_ , ! , !);
// Highpass TPT
HPTPT(cf, x) = onePoleTPT(cf, x) : (! , _ , !);

// Lookahead Limiter
LookaheadLimiter(threshold, x) = ( x : peakHoldwDecay(.1, 500, 10) ) : 
    ( threshold / max(ma.EPSILON, _) : min(1.0) ) *
        ( x @ (ms2samp(1)));
        
process = _ : LookaheadLimiter(1);