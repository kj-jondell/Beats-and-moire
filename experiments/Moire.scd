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
	p = 20;
	~mult = 650;
	p.do{|i| z = DelayN.ar(z, 3, (1+i)/(440+SinOsc.kr(1000 + XLine.kr(1, 1000, 60, 1), mul:~mult)), 1, z);} ;
	p.do{|i| q = DelayN.ar(q, 3, (1+i)/(439+SinOsc.kr(1000 + XLine.kr(1, 1000, 60, 1), mul:~mult)), 1, q);} ;
	(z+q)!2;
	[z,q];
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