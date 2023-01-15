// import faust standard library
import("stdfaust.lib");
// hard-coded: change this to match your samplerate
SampleRate = 44100;

//------------------------------------------------ GRANULAR SAMPLING --
grain(L, position, duration, x, trigger) = hann(phase) * 
    buffer(readPtr, x)
with {
    maxLength = L * SampleRate;
    length = L * SampleRate;
    hann(ph) = sin(ma.PI * ph) ^ 2.0;
    lineSegment = loop ~ si.bus(2) : _ , ! , _
    with {
        loop(yState, incrementState) = y , increment , ready
        with {
            ready = ((yState == 0.0) | (yState == 1.0)) & trigger;
            y = ba.if(ready, increment, min(1.0, yState + increment));
            increment = ba.if(ready, ma.T / max(ma.T, duration), 
                incrementState);
        };
    };
    phase = lineSegment : _ , !;
    unlocking = lineSegment : ! , _;
    lock(param) = ba.sAndH(unlocking, param); 
    grainPosition = lock(position);
    grainDuration = lock(duration);
    readPtr = grainPosition * length + phase * grainDuration * ma.SR;
    buffer(readPtr, x) = 
        it.frwtable(3, maxLength, .0, writePtr, x, readPtrWrapped)
    with {
        writePtr = ba.period(length);
        readPtrWrapped = ma.modulo(readPtr, length);
    };
};

// works for N >= 2
triggerArray(N, rate) = loop ~ si.bus(3) : (! , ! , _) <: 
    par(i, N, == (i)) : par(i, N, \(x).(x > x'))
with {
    loop(incrState, phState, counterState) = incr , ph , counter
    with {
        init = 1 - 1';
        trigger = (phState < phState') + init;
        incr = ba.if(trigger, rate * ma.T, incrState);
        ph = ma.frac(incr + phState);
        counter = (trigger + counterState) % N;
    };
};

grainN(voices, L, position, rate, duration, x) = 
    triggerArray(voices, rate) : 
    par(i, voices, grain(L, position, duration, x));

process = os.osc(200) * .5 <: grainN(10, 4, 
    hslider("Grain Position", -1, -1, 1, .001), 
    hslider("Grain Rate", 1, 1, 100, .001),
    hslider("Grain Duration", 0.100, 0, 1, .001)) :> _;

// in the full system this this is the granular sampling function
granular_sampling(var1, timeIndex, memWriteDel, cntrlLev, divDur, x) = 
    grainN(10, var1, position, rate, duration, x) :> _
with {
    rnd = no.noise;
    memPointerJitter = rnd * (1.0 - memWriteDel) * .01;
    position = timeIndex * (1.0 - ((1.0 - memWriteDel) * .01)) + 
        memPointerJitter;
    density = 1.0 - cntrlLev;
    rate = 50 ^ (density * 2.0 - 1.0);
    grainDuration = .023 + (1.0 - memWriteDel) / divDur;
    duration = grainDuration + grainDuration * .1 * rnd;
};
