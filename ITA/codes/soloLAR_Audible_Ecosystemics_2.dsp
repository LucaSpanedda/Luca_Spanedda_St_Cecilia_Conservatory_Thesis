// import faust standard library
    import("stdfaust.lib");
    
    LARmechanismAE2(mic1, mic2) = sig1, sig2
    with{
        Mic_1B_1 = hgroup("Mixer", hgroup("Signal Flow 1B", 
            gainMic_1B_1(mic1)));
        Mic_1B_2 = hgroup("Mixer", hgroup("Signal Flow 1B", 
            gainMic_1B_2(mic2)));
    
        // cntrlMic - original version
        cntrlMic(x) = x : HP1(50) : LP1(6000) : 
            integrator(.01) : delayfb(.01, .995) : LP5(.5);
        cntrlMic1 = Mic_1B_1 : cntrlMic;
        cntrlMic2 = Mic_1B_2 : cntrlMic;
    
        // from Signal Flow 2a
        Mic_2A_1 = hgroup("Mixer", hgroup("Signal Flow 2A", 
            gainMic_2A_1(mic1)));
        Mic_2A_2 = hgroup("Mixer", hgroup("Signal Flow 2A", 
            gainMic_2A_2(mic2)));
        micIN1 = Mic_2A_1 : HP1(50) : LP1(6000) * 
            (1 - cntrlMic1);
        micIN2 = Mic_2A_2 : HP1(50) : LP1(6000) * 
            (1 - cntrlMic2);
        // in the full system this this is a secondary counterbalance
        directLevel = 1;
        sig1 = micIN1 * directLevel;
        sig2 = micIN2 * directLevel;
    };
    
    process = LARmechanismAE2;
    
    
    //------- ------------- ----- -----------
    //-- LIBRARY ----------------------------------------------------------
    //------- --------
    // selected objects from "aelibrary.lib"
    
    //-------------------------------------------------------- UTILITIES --
    // limit function for library and system
    limit(maxl,minl,x) = x : max(minl, min(maxl));
    
    //---------------------------------------------------------- FILTERS --
    onePoleTPT(cf, x) = loop ~ _ : ! , si.bus(3)
    with {
        g = tan(cf * ma.PI * (1/ma.SR));
        G = g / (1.0 + g);
        loop(s) = u , lp , hp , ap
        with {
            v = (x - s) * G;
            u = v + lp;
            lp = v + s;
            hp = x - lp;
            ap = lp - hp;
        };
    };
    
    LPTPT(cf, x) = onePoleTPT(limit(20000,ma.EPSILON,cf), x) : (_, !, !);
    HPTPT(cf, x) = onePoleTPT(limit(20000,ma.EPSILON,cf), x) : (!, _, !);
    
    // Order Aproximations filters - Outs
    LP1(CF, x) = x :LPTPT(CF);
    HP1(CF, x) = x :HPTPT(CF);
    LP2(CF, x) = x :LPTPT(CF) :LPTPT(CF);
    HP2(CF, x) = x :HPTPT(CF) :HPTPT(CF);
    LP3(CF, x) = x :LPTPT(CF) :LPTPT(CF) :LPTPT(CF);
    HP3(CF, x) = x :HPTPT(CF) :HPTPT(CF) :HPTPT(CF);
    LP4(CF, x) = x :LPTPT(CF) :LPTPT(CF) :LPTPT(CF) :LPTPT(CF);
    HP4(CF, x) = x :HPTPT(CF) :HPTPT(CF) :HPTPT(CF) :HPTPT(CF);
    LP5(CF, x) = x :LPTPT(CF) :LPTPT(CF) :LPTPT(CF) :LPTPT(CF) :LPTPT(CF);
    HP5(CF, x) = x :HPTPT(CF) :HPTPT(CF) :HPTPT(CF) :HPTPT(CF) :HPTPT(CF);
    
    //------------------------------------------------------- INTEGRATOR --
    integrator(sec, x) = an.abs_envelope_tau(limit(1000,.001, sec), x);
    
    //----------------------------------------------------------- DELAYS --
    delayfb(delSec,fb,x) = loop ~ _ : mem
    with{ 
        loop(z) = ( (z * fb + x) @(ba.sec2samp(delSec)-1) );
    };
    
    //--------------------------------------------- INPUTS/OUTPUTS MIXER --
    gainMic_1B_1(x) = x *    
        si.smoo( ba.db2linear(
                vslider("SF_1B_1 [unit:db]", 0, -80, 80, .001) ) ) <:
                    attach(_, VHmetersEnvelope(_) :
                        vbargraph("VM1B1 [unit:dB]", -80, 80));
    gainMic_1B_2(x) = x * 
        si.smoo( ba.db2linear(
                vslider("SF_1B_2 [unit:db]", 0, -80, 80, .001) ) ) <:
                    attach(_, VHmetersEnvelope(_) :
                        vbargraph("VM1B2 [unit:dB]", -80, 80));
    gainMic_2A_1(x) = x * 
        si.smoo( ba.db2linear(
                vslider("SF_2A_1 [unit:db]", 0, -80, 80, .001) ) ) <:
                    attach(_, VHmetersEnvelope(_) :
                        vbargraph("VM2A1 [unit:dB]", -80, 80));
    gainMic_2A_2(x) = x * 
        si.smoo( ba.db2linear(
                vslider("SF_2A_2 [unit:db]", 0, -80, 80, .001) ) ) <:
                    attach(_, VHmetersEnvelope(_) :
                        vbargraph("VM2A2 [unit:dB]", -80, 80));
    
    VHmetersEnvelope = abs : max ~ -(1.0/ma.SR) : 
        max(ba.db2linear(-70)) : ba.linear2db;