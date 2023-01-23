// import faust standard library
import("stdfaust.lib");

movingAverage(seconds, x) = x - (x @ N) : fi.pole(1.0) / N
    with {
        N = seconds * ma.SR;
    };

movingAverageRMS(seconds, x) = sqrt(max(0, movingAverage(seconds, x * x)));

process = movingAverageRMS(1);