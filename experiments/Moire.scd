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
SynthDef.new(\moirebeats, {
	|num = 15, inL, inR, freq =440|
	var outL = PinkNoise.ar(0.5);
	var outR = PinkNoise.ar(0.5);
	p = 15;
	p.do{|i| outL = DelayC.ar(outL, 3, (1+i)/(freq), 0.7**i, outL);} ;
	p.do{|i| outR = DelayC.ar(outR, 3, (1+i)/(freq), 0.7**i, outR);} ;
	Out.ar(0, (Balance2.ar(outL,outR,0,1)));
}).add;
)

x = Synth.new(\moirebeats, [\inL,0,\inR,0]);


(
{
	z = PinkNoise.ar(0.25);
	q = PinkNoise.ar(0.25);
	p = 15;
	~mult = 550;
	//SinOsc.kr(XLine.kr(550, 1700, 60, 1), mul:~mult)
	p.do{|i| z = DelayC.ar(z, 3, (1+i)/(XLine.kr(150, 1700, 60, 1)), 0.98**i, z);} ;
	p.do{|i| q = DelayC.ar(q, 3, (1+i)/(XLine.kr(450, 1700, 60, 1)), 0.98**i, q);} ;
	(z+q)!2;
	[Normalizer.ar(z),Normalizer.ar(q)];
//	[z,z];
}.play
)

(
{
	b = Buffer.alloc(s, s.sampleRate);
	q = WhiteNoise.ar(0.5);
	z = q + MultiTap.ar([1/(440+SinOsc.kr(2500, mul: 22)), 2/(440+SinOsc.kr(2500, mul: 22)), 3/(440+SinOsc.kr(2500, mul: 22)), 4/(440+SinOsc.kr(2500, mul: 22)), 5/(440+SinOsc.kr(2500, mul: 22)), 6/(440+SinOsc.kr(2500, mul: 22))], [1, 1, 1, 1, 1, 1], q, bufnum: b.bufnum);
	[z, z];
}.play;
)


(
{
	z = WhiteNoise.ar(0.5);
	q =  WhiteNoise.ar(0.5);
	p = 7;
	p.do{|i| z = BufDelayN.ar(z, 3, (1+i)/(390), 0.45, z);} ;
	p.do{|i| q = BufDelayN.ar(q, 3, (1+i)/(385), 0.45, q);} ;
	[z, q];
}.play
)

(
{
	z = Saw.ar(100,mul:0.5);
	q =  Saw.ar(100,mul:0.5);
	p = 10;
	p.do{|i| z = DelayN.ar(z, 3, (1+i)/(55+SinOsc.kr(20, mul:30)), 0.95**(i*2), z);} ;
	p.do{|i| q = DelayN.ar(q, 3, (1+i)/(54.75+SinOsc.kr(20, mul:30)), 0.95**(i*2), q);} ;
	(z+q)!2;
	[z,q];
//	[z,z];
}.play
)