// import faust standard library
    import("stdfaust.lib");
    // hard-coded: change this to match your samplerate
    SampleRate = 44100;
    
    
    sampler(lengthSec, memChunk, ratio, x) = 
    it.frwtable(3, bufferLen, .0, writePtr, x, readPtr) * window
    with {
        memChunkLimited = max(0.100, min(1, memChunk));
        bufferLen = lengthSec * SampleRate;
        writePtr = ba.period(bufferLen);
        grainLen = max(1, ba.if(writePtr > memChunkLimited * bufferLen, 
            memChunkLimited * bufferLen, 1));
        readPtr = y
            letrec {
                'y = (ratio + y) % grainLen;
            };
        window = min(1, abs(((readPtr + grainLen / 2) % grainLen) - 
            grainLen / 2) / 200);
    };
    
    process = sampler(4, hslider("memChunkLimited", 0.100, 0, 1, .001), 
        hslider("ratio", 5, .1, 10, .001), os.osc(100)) <: _, _;