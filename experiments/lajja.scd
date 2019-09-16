s.reboot
s.options.memSize = 65536; //måste köras annars vill inte noiser spela
s.options.numInputBusChannels = 12;
s.options.numOutputBusChannels = 12;
s.meter;
s.queryAllNodes();

MIDIIn.connectAll;

(
MIDIdef.cc(\test1, {
    arg val, ch, id, num;
    val.postln;
})
)

(
    SynthDef.new(\FM_synth, {
        arg args;
        var modulator = SinOsc.ar(freq: 440.0,  mul: 20,  add: 220.0);
        var carrier;
        25.do({
            arg i; 
            modulator = SinOsc.ar(modulator, mul: 15*(1/i), add: 110);
        });
        carrier = SinOsc.ar(modulator)*EnvGen.kr(Env.perc, doneAction: Done.freeSelf);
        Out.ar(0, carrier!2);
    }).add;
)

(
Pbindef.new(\sequencer, 
    \instrument, \FM_synth,
    \dur, Pseq([0.25, 0.25, 0.15], inf)
).play;
)

