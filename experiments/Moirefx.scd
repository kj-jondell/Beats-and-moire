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
	var left = PinkNoise.ar(0.5), right = PinkNoise.ar(0.5);
	//p = 15;
	var taps = 8;
	taps.do{|i| left = DelayC.ar(left, 4, (1+i)/(freq), harmonics**i, left);} ;
	taps.do{|i| right= DelayC.ar(right, 4, (1+i)/(freq*detune), harmonics**i, right);} ;
	Out.ar([0,1], [Limiter.ar((left+right))!2]);
}).add;
)

(
MIDIFunc.cc({
	arg val, num, chan, src;
	//[src, val, chan, num].postln;
	x.set(\harmonics, val.linlin(0, 127, 0, 1.0));
}, ccNum: 0);
)

(
MIDIFunc.cc({
	arg val, num, chan, src;
	//[src, val, chan, num].postln;
	x.set(\freq, val.midicps);
}, ccNum: 16);
)


(
MIDIFunc.cc({
	arg val, num, chan, src;
	x.set(\detune, val.linlin(0,127, 0.5, 2));
}, ccNum: 17);
)


x = Synth.new(\moir, [\harmonics, 0.5]);


s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;
s.reboot;
s.meter;