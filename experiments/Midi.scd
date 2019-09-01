MIDIClient.init;
MIDIClient.sources;
MIDIIn.connect(1);
MIDIIn.connectAll;

(
MIDIdef.cc(\slider, {
	arg val, chan, src;
	[src, val, chan].postln;
	x.set(\freq, val.midicps);
}, chan:0);
)

MIDIdef(\slider).enable;

(
SynthDef.new(\tone, {
	arg freq = 440, amp = 0.3;
	var sig = SinOsc.ar(freq);
	Out.ar(0, sig!2);
}).add;
)

~tonefreq = 440;
x = Synth.new(\tone, [\freq, ~tonefreq]);