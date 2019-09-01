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
SynthDef.new(\moir, {
	arg freq = 440, harmonics = 0.7, detune = 1;//, taps = 15;
	var left = PinkNoise.ar(0.8), right = PinkNoise.ar(0.8);
	//p = 15;
	var taps = 8;
	taps.do{|i| left = DelayC.ar(left, 1, (1+i)/(freq), harmonics**i, left);} ;
	taps.do{|i| right= DelayC.ar(right, 1, (1+i)/(freq*detune), harmonics**i, right);} ;
	Out.ar([0,1], [Limiter.ar((left+right)/(500*harmonics))!2]);
	//TODO: fix scaling of amplitude, normalizing
}).add;
)

(


MIDIFunc.cc({
	arg val, num, chan, src;
	//[src, val, chan, num].postln;
	x.set(\harmonics, val.linexp(0, 127, 0.1, 1.0));
}, ccNum: 0);



MIDIFunc.cc({
	arg val, num, chan, src;
	//[src, val, chan, num].postln;
	var scale = Scale.majorPentatonic;
	var degree = val.linlin(0, 127, 0, scale.size*3).round;
	var frequency = scale.degreeToFreq(degree, 55.0, -1);
	x.set(\freq, frequency);
}, ccNum: 16);



MIDIFunc.cc({
	arg val, num, chan, src;
	x.set(\detune, val.linlin(0,127, 0.5, 2));
}, ccNum: 17);

)

x = Synth.new(\moir, [\harmonics, 1, \freq, 55]);


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