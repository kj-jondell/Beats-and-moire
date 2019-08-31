(
SynthDef.new(\modpinks, {
	arg out = 6;
	var outL = PinkNoise.ar(0.5);
	var outR = PinkNoise.ar(0.5);
	Out.ar(out, Balance2.ar(outL,outR,0,1))
}).add;
)
(
SynthDef.new(\moirebeats, {
	arg in;
	var sig = In.ar(in, 2);

}).add;
)

y = Synth.new(\modpink, []);
x = Synth.new(\moirebeats, []);


s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;
s.reboot;
s.meter;