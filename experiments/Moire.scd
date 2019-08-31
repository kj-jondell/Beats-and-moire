s.boot;
s.quit;
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

(
{
	z = WhiteNoise.ar(0.5);
	q =  WhiteNoise.ar(0.5);
	l = DelayN.ar(z, 3, 1/(390), 0.45);
	30.do{|i| l = DelayN.ar(z, 3, (i+1)/(390), 0.15, l);} ;
	15.do{|i| q = DelayN.ar(q, 3, (i+1)/(385), 0.45, q);} ;
	//[l, q];
	l;
}.play
)

(
{
	z = WhiteNoise.ar(0.5);
	q =  WhiteNoise.ar(0.5);
	p = 7;
	p.do{|i| z = DelayN.ar(z, 3, (1+i)/(390), 0.45, z);} ;
	p.do{|i| q = DelayN.ar(q, 3, (1+i)/(385), 0.45, q);} ;
	[z, q];
}.play
)