s.reboot;
(
SynthDef.new(\modpinks, {
	arg out;
	var sig = PinkNoise.ar(0.5);
	Out.ar(out, sig);
}).add;
)
Scale.saba.degreeToFreq(0, 440, 1).postln;

(
MIDIFunc.cc({
	arg val, num, chan, src;
	[src, val, chan, num].postln;
});
)

y = Synth.new(\modpinks, [\out, 2]);

(
MIDIFunc.cc({
	arg val, num, chan, src;
	//[src, val, chan, num].postln;
	var scale = Scale.majorPentatonic;
	var degree = val.linlin(0, 127, 0, scale.size*2).round;
	var frequency = scale.degreeToFreq(degree, 55.0, degree);
	x.set(\freq, frequency);
}, ccNum: 16);
)

s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;
s.reboot;
s.meter;