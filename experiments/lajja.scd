s.boot
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
        arg  
    }).add;
)



(
    ( 
        SynthDef.new(\Modulator, {
            arg mod_bus, bus = 3, mod_index = 500, mod_freq = 220;
            var signal = SinOsc.ar(mod_freq, mul: mod_index);
            Out.ar(bus, signal);
        }).add;
    );

    (
        SynthDef.new(\Carrier, {
            arg mod_bus, out_bus = 0, carrier_freq = 0, mod_index = 1;
            var mod_signal = In.ar(mod_bus);
            var signal = SinOsc.ar(mod_signal, mul: mod_index, add: carrier_freq);
            Out.ar(out_bus, signal!2);
        }).add;
    );
)

( 
    var busnum = 3;
    y = Synth.new(\Modulator, [\bus, busnum]);
    x = Synth.after(y, \Carrier, [\mod_bus, busnum, \out_bus, 4, \mod_index, 320, \carrier_freq, 440]);
    z = Synth.after(x, \Carrier, [\mod_bus, 4])
)
