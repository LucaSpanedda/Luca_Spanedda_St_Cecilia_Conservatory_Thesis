// import faust standard library
import("stdfaust.lib");

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

process = _ : peakHolder(1);