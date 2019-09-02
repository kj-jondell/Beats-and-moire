(

SynthDef.new(\noise, {
	arg out;
	var sig;
	sig = PinkNoise.ar(0.5);
	Out.ar(out, sig);
}).add;

SynthDef.new(\interferer, {
	arg freq = 440, harmonics = 0.7, detune = 1, in_left, in_right;//, taps = 15;
	var left = In.ar(in_left, 1), right = In.ar(in_right, 1);
	var taps = 8;
	taps.do{|i| left = DelayC.ar(left, 1, (1+i)/(freq), harmonics**i, left);} ;
	taps.do{|i| right= DelayC.ar(right, 1, (1+i)/(freq*detune), harmonics**i, right);} ;
	Out.ar([0,1], [Limiter.ar((left+right)/(500*harmonics))!2]); //TODO: fix amplitude over range of harmonic-modulator
}).add;

)

s.options.numAudioBusChannels;

s.reboot;

y = Synth.new(\interferer, [\in_left, 6, \in_right, 7]);
(
x = Synth.new(\noise, [\out, 6]);
z = Synth.new(\noise, [\out, 7]);
)
y.set(\freq, 110);
