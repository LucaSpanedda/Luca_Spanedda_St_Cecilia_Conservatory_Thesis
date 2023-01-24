// import faust standard library
import("stdfaust.lib");

localMax(seconds, x) = loop ~ si.bus(4) : _ , ! , ! , !
with {
    loop(yState, timerState, peakState, timeInSamplesState) = 
        y , timer , peak , timeInSamples
    with {
        timeInSamples = ba.if(reset + 1 - 1', seconds * 
            ma.SR, timeInSamplesState);
        reset = timerState >= (timeInSamplesState - 1);
        timer = ba.if(reset, 1, timerState + 1);
        peak = max(abs(x), peakState * (1.0 - reset));
        y = ba.if(reset, peak', yState);
    };
};

process = os.osc(.1245) : localMax(1);