
/*****
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2. Sound in from Soundflower.......!
3.

© Karl Johannes Jondell 2019
******/
MIDIIn.connectAll;

(
//Remove in future
SynthDef.new(\noise, {
	arg out, freq=52;
	var sig;
	sig = WhiteNoise.ar(mul: 1.0);
	Out.ar(out, sig);
}).add;

//Allow frequency modulation (and harmonics index modulation? or as array?)
//Output-bus should be selectable
SynthDef.new(\Interference, {
	arg freq_mod = 1, harmonics = 1.0, detune = 1, in_left, in_right;
    var freq = In.kr(freq_mod, 1);
	var left = In.ar(in_left, 1), right = In.ar(in_right, 1); //instead of left + right, make arbitrary number of sources that can be detuned
	var taps = 12;
    taps.do{|i| left = (DelayC.ar(left, 1, delaytime: (1+i)/(freq), mul: harmonics, add: left));} ;
    taps.do{|i| right = (DelayC.ar(right, 1, delaytime: (1+i)/(freq+detune), mul: harmonics, add: right));} ;
	Out.ar([0,1], [Limiter.ar(0.5*((left)/(1+(harmonics**1.35)*2.45))),Limiter.ar(0.5*((right)/(1+(harmonics**1.35)*2.45)))]); 
}).add;

SynthDef.new(\Envelopper, {
    arg rel = 0.5, in_left=6, in_right = 7;
    var left = In.ar(in_left, 1);
    var right = In.ar(in_right, 1);

    var envsig = EnvGen.kr(Env.perc(releaseTime:rel), doneAction: Done.freeSelf);
    Out.ar([3,4], [left*envsig, right*envsig])
}).add;

SynthDef.new(\fm, {
    arg modfreq=100, modindex=100, freq = 440;
    Out.kr(1, SinOsc.kr(modfreq, mul:modindex, add:freq));
}).add;

)

(
~sourceGroup = Group.new;
~fxGroup = Group.after;

y = Synth.new(\Interference, [\harmonics, 0.0, \in_left, 3, \in_right, 4], ~fxGroup);
x = Synth.new(\noise, [\out, 6], ~sourceGroup );
z = Synth.new(\noise, [\out, 7], ~sourceGroup );
p = Synth.new(\fm, ~sourceGroup);
)

s.meter;
TempoClock.default.tempo = 120/60;
p.set(\modfreq, 0.03;
p.set(\modindex, 60);
p.set(\freq, 43.midicps);
s.boot;
s.options.memSize = 64000;

(
Pbindef(\noisedef, \instrument, \Envelopper,
\rel, Pseq.new([1.5], inf),
\dur, Pseq.new([1,0.5,2,1/3],inf),
\in_left, 6,
\in_right, 7,
\group, ~fxGroup
).play;
)

y.set(\detune, 1.9);
y.set(\harmonics, 0.95);
y.set(\scale, Scale.majorPentatonic);


(
    var r;
    r = Routine {
    {
        p.set(\freq, (25.rand+15).midicps);
        1.wait;
    }.loop;
    }.play;
)
