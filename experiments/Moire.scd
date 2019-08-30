s.boot;
s.options.memSize = 65536; //måste köras annars vill inte noiser spela

(
SynthDef.new(\delayfilter, {
	| rel = 1, freq = 440 |
	var sig = WhiteNoise.ar;
	var env = EnvGen.ar(Env.perc(0.05, rel), doneAction: Done.freeSelf);
	var del = DelayN.ar(sig, 1/freq, 0.2, 1, sig);

	var filt = BBandPass.ar(sig+del, freq, bw: 5);
	Out.ar(0, env*(Balance2.ar(filt,filt,0,1)));
}
).add;
)

v = Synth.new(\delayfilter, [\freq, 110]);

(
{
	z = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: Done.freeSelf)*BrownNoise.ar;
	90.do{|i| z = DelayN.ar(z, (i+1)/440, 1.5, 0.5, z);} ;
	z;
}.play
)

(
{
	z = SinOsc.ar(440);
	30.do{|i| z = SinOsc.ar(i*440, 0, 1/(i+1), z);};
	z;
}.play;
)