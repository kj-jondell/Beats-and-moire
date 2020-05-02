/***
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2. Sound in from Soundflower.......!
3. Buses...

© Karl Johannes Jondell 2019
***/
(
    s.options.device = "Soundflower (64ch)";
    s.options.memSize = 8192*4;
    MIDIClient.init;
    MIDIIn.connectAll;

    s.waitForBoot({
        var leftNoise, rightNoise, moireSynth, moireBassSynth;
        var sourceGroup, fxGroup;
        var customScale = {
            arg note, root = 29, tuning = 45;
            var ratios = [1, 19/18, 10/9, 6/5, 5/4, 47/36, 25/18, 53/36, 55/36, 5/3, 67/36, 23/12]; //TODO: FIX RATIOS!
            ratios[(note-root)%ratios.size]*tuning*((note-root)/ratios.size+1).floor;
        };

        //Remove in future
        SynthDef.new(\noise, {
            arg out;
            var sig;
            sig = WhiteNoise.ar(mul: 0.5);
            Out.ar(out, sig);
        }).add;

        //Output-bus should be selectable
        SynthDef.new(\Interference, {
            arg freq_bus = 1, harmonics = 1.0, in_left = 3, in_right = 4, freq = 440, out_left = 0, out_right = 1;
            //var freq = In.kr(freq_bus);
            var left = In.ar(in_left), right = In.ar(in_right); //instead of left + right, make arbitrary number of sources that can be detuned
            var taps = 12;
            taps.do{|i| left = (DelayC.ar(left, 1, delaytime: (1+i)/(freq), mul: harmonics**(1/(1+i)), add: left));} ;
            taps.do{|i| right = (DelayC.ar(right, 1, delaytime: (1+i)/(freq+\detune.kr(1)), mul: harmonics**(1/(1+i)), add: right));} ;
            Out.ar([out_left,out_right], [0.5*Limiter.ar(0.5*((left)/(1+(harmonics**1.35)*2.45))),0.5*Limiter.ar(0.5*((right)/(1+(harmonics**1.35)*2.45)))]); 
        }).add;

        s.sync; 

        sourceGroup = Group.new;
        fxGroup = Group.after;

        leftNoise = Synth.new(\noise, [\out, 3], sourceGroup);
        rightNoise = Synth.new(\noise, [\out, 4], sourceGroup);
        moireSynth = Synth.new(\Interference, [\harmonics, 0.1, \detune, 1, \in_left, 3, \in_right, 4, \freq, 87.307, \out_left, 6, \out_right, 7], fxGroup);
        moireBassSynth = Synth.new(\Interference, [\harmonics, 0.1, \detune, 1, \in_left, 3, \in_right, 4, \freq, 43.654, \out_left, 8, \out_right, 9], fxGroup);

        MIDIFunc.noteOn({
            arg vel, note;
            moireBassSynth.set(\freq, customScale.value(note));
        }, chan: 5);

        MIDIFunc.noteOn({
            arg vel, note;
            moireSynth.set(\freq, customScale.value(note));
        }, chan: 4);

    });
)


//SERVER FUNCTIONS
s.boot;
s.reboot;
s.quit;
s.options.numInputBusChannels=64;
s.meter;

OSCFunc.trace(false);
MIDIdef.freeAll;
