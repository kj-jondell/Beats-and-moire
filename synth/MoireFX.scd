/*****
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2.
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
	arg freq = 440, harmonics = 1.0, detune = 1, in_left, in_right;
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

)

s.options.numAudioBusChannels;
s.boot;
s.options.memSize = 65536; //Must be run before playing


(
~sourceGroup = Group.new;
~fxGroup = Group.after;

y = Synth.new(\Interference, [\harmonics, 0.0, \in_left, 3, \in_right, 4], ~fxGroup);
x = Synth.new(\noise, [\out, 6], ~sourceGroup );
z = Synth.new(\noise, [\out, 7], ~sourceGroup );
)

(
MIDIFunc.cc({
    arg val, num, chan, src;
    if(val==127, {Synth.before(y,\Envelopper, [\rel, 1, \in_left, 6, \in_right, 7], ~fxGroup);});

}, ccNum: 32)
)
s.queryAllNodes() //Post node tree
s.boot
TempoClock.default.tempo = 120/60
(
Pbindef(\noisedef, \instrument, \Envelopper,
\rel, Pseq([0.1], inf),
\dur, Pseq([0.25,0.25,0.25/3],inf),
\in_left, 6,
\in_right, 7,
\group, ~fxGroup
).play;
)

y.set(\freq,37.midicps);
y.set(\detune, 1.01);
y.set(\harmonics, 0.9);
y.set(\scale, Scale.majorPentatonic);
(
MIDIFunc.cc({
	arg val, num, chan, src;
	y.set(\harmonics, val.linlin(0,127, 0.0, 1));
}, ccNum: 0);

MIDIFunc.cc({
	arg val, num, chan, src;
	y.set(\freq, val.linlin(0,127, 24, 64).midicps);
//    x.set(\freq,6+val.linlin(0,127, 10, 64).midicps);
//   z.set(\freq,6+val.linlin(0,127, 10, 64).midicps);
}, ccNum: 16);

)

