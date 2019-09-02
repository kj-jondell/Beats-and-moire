/****
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2.
3.

© Karl Johannes Jondell 2019
*****/
(

//Remove in future
SynthDef.new(\noise, {
	arg out;
	var sig;
	sig = PinkNoise.ar(0.5);
	Out.ar(out, sig);
}).add;


//Allow frequency modulation (and harmonics index modulation? or as array?)
//Output-bus should be selectable
SynthDef.new(\Interference, {
	arg freq = 440, harmonics = 1.0, detune = 1, in_left, in_right;
	var left = In.ar(in_left, 1), right = In.ar(in_right, 1); //instead of left + right, make arbitrary number of sources that can be detuned
	var taps = 8;
	taps.do{|i| left = DelayC.ar(left, 1, (1+i)/(freq), harmonics**i, left);} ;
	taps.do{|i| right= DelayC.ar(right, 1, (1+i)/(freq*detune), harmonics**i, right);} ;
	Out.ar([0,1], [Limiter.ar((left+right)/(500*harmonics))!2]); //TODO: fix amplitude over range of harmonic-modulator
}).add;

)

s.options.numAudioBusChannels;
s.boot;

(
~sourceGroup = Group.new;
~fxGroup = Group.after;

y = Synth.new(\Interference, [\in_left, 6, \in_right, 7], ~fxGroup);
x = Synth.new(\noise, [\out, 6], ~sourceGroup );
z = Synth.new(\noise, [\out, 7], ~sourceGroup );
)

y.set(\freq,57.midicps);
y.set(\detune, 1.01);
y.set(\harmonics, 0.1);


