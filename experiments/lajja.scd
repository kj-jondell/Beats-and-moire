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
        arg freq = 320, mod_index = 100, modulation_array = #[110,320,220];
        var modulator = SinOsc.ar(freq: 246.0,  mul: mod_index,  add: modulation_array[0]);
        var carrier;
        20.do({
            arg i; 
            modulator = SinOsc.ar(modulator, mul: mod_index, add: modulation_array[i+1]);
        });
        carrier = SinOsc.ar(SinOsc.ar(modulator, mul: mod_index, add: freq))*EnvGen.kr(Env.perc, doneAction: Done.freeSelf);
        Out.ar(0, carrier!2);
    }).add;
)

(
Pbindef.new(\sequencer, 
    \instrument, \FM_synth,
    \dur, Pseq([0.25, 0.25, 0.15], inf),
    \scale, Scale.majorPentatonic,
    \degree, Pseq([1,2,3,4], inf)
).play;
)

