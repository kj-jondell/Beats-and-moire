s.boot;
(
SynthDef.new(\help, {
	 arg out=0;
    Out.ar(out, PinkNoise.ar(0.1));
}).add;
)

(
SynthDef.new(\morehelp, { arg out=0, in=0;
	   var input;
        input = In.ar(in, 1);
        Out.ar(out, input);
}).add;
)

//play noise on the right channel
x = Synth.new(\help, [\out, 1]);
y = Synth.new(\morehelp, [\out, 0, \in, 1]);
//read the input and play it out on the left channel
Synth.after(x, \morehelp, [\out, 0, \in, 1]);