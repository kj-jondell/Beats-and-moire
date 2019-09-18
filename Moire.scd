/*
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2. Sound in from Soundflower.......!
3. Buses...

© Karl Johannes Jondell 2019
***/
MIDIIn.connectAll;
s.boot;
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
	arg freq_bus = 1, harmonics = 1.0, in_left, in_right;
    var freq = In.kr(freq_bus);
	var left = In.ar(in_left, 1), right = In.ar(in_right, 1); //instead of left + right, make arbitrary number of sources that can be detuned
	var taps = 12;
    taps.do{|i| left = (DelayC.ar(left, 1, delaytime: (1+i)/(freq), mul: harmonics, add: left));} ;
    taps.do{|i| right = (DelayC.ar(right, 1, delaytime: (1+i)/(freq+\detune.kr(1)), mul: harmonics, add: right));} ;
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
x = Synth.new(\noise, [\out, 3], ~sourceGroup );
z = Synth.new(\noise, [\out, 4], ~sourceGroup );
p = Synth.new(\fm, ~sourceGroup);
)

s.meter;
TempoClock.default.tempo = 60/60;
p.set(\modfreq, 0.1);
p.set(\modindex, 0);
p.set(\freq, 30.midicps);
s.boot;
s.options.memSize = 64000;

y.set(\detune, 2.5);
y.set(\harmonics, 1);
y.set(\scale, Scale.majorPentatonic);


var r;
r = Routine {
    {
        p.set(\freq, (25.rand+35).midicps);
        1.wait;
    }.loop;
}.play;
r.stop;

(
    var midi, dur;
    midi = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67]-24, 5).asStream;
    dur = Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 5).asStream;
    r = Task({
        var delta;
        while {
            delta = dur.next;
            delta.notNil;
        } {
            p.set(\freq, midi.next.midicps);
            delta.yield;
        }
    }).play(quant: TempoClock.default.beats + 1.0);
)
r.stop;
