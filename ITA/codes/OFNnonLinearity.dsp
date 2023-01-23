nonLinearity(exponent, refPeriod, y) = y : lowFreqNoise <: 
    (nonlinearsig(exponent, ma.tanh(_ * normRMS)))
with{
    lowFreqNoise(x) = x : seq(i, 4, LPTPT(1.0 / refPeriod));
    noiseRMS(x) = x * x : LPTPT(1.0 / (10.0 * refPeriod)) : sqrt;
    normRMS(x) = 1.0 / max(ma.EPSILON, noiseRMS(x));
    nonlinearsig(exponent, x) = ma.signum(x) * pow(abs(x), exponent);
};

process = no.noise : nonLinearity(1, 1);

// Zavalishin's Onepole TPT Filter
// reference : (by Will Pirkle)
// http://www.willpirkle.com/Downloads/AN-4VirtualAnalogFilters.2.0.pdf
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