// FM-synth for learning Sc for RLE
// TODO: move to git-folder
s.boot
//Volume fader as Bus effect
(
    SynthDef.new(\Fm_synth_ensemble, {
        arg freq = 440, mod_freq = 232, mod_index = 220, env_attack = 0.01, env_decay = 0.5, out_bus = 3;
        var env = EnvGen.kr(Env.perc(env_attack, env_decay),  doneAction: Done.freeSelf);
        var signal = SinOsc.ar(SinOsc.ar(mod_freq, mul: mod_index, add: freq));
        Out.ar(out_bus, (env*signal)!2);
    }).add;
)

(
    SynthDef.new(\VolumeFader, {
        arg volume = 1.0, in_bus = 3;
        var signal = In.ar(in_bus);
        Out.ar(0, (volume*signal)!2);
    }).add;
)
x = Synth.new(\Fm_synth_ensemble);
y = Synth.new(\VolumeFader, [\volume, ~volume]);
~volume.postln
(
    ~modfreq = 200;
    ~modindex = 100; 
    ~attack = 0.01;
    ~decay = 0.5;
    ~volume = 1.0;
    y.set(\volume, ~volume);
    TempoClock.default.tempo = 240/60
)
~sequence.play;
(
    ~sequence = Pbindef.new(\sequencer, 
        \instrument, \Fm_synth_ensemble,
        \scale, Scale.minor,
        \degree, Pseq.new([4,3,4,2], inf),
        \octave, 5,
        \dur, Pgauss.new(mean:1,dev:0.1,length:inf),
        \mod_freq, Pfunc.new({~modfreq}),
        \mod_index, Pfunc.new({~modindex}),
        \env_attack, Pfunc.new({~attack}),
        \env_decay, Pfunc.new({~decay}),
        \volume, Pfunc.new({~volume})
    );
)

MIDIIn.connectAll;

//TODO: change if statements to Switch-case
(
MIDIdef.cc(\midi, {
    arg val, cc, chan, src;
    if(cc == 16, {~modfreq = LinLin.kr(val, 0, 127, 200, 800);});
    if(cc == 17, {TempoClock.default.tempo = LinLin.kr(val, 0, 127, 45, 400)/60;});
    if(cc == 0, {~modindex = LinLin.kr(val, 0, 127, 25, 500);});
    if(cc == 1, {~attack = LinLin.kr(val, 0, 127, 0.01, 1.5);});
    if(cc == 2, {~decay = LinLin.kr(val, 0, 127, 0.25, 15.0);});
    if(cc == 3, {y.set(\volume, LinLin.kr(val, 0, 127, 0.0, 1.0);)});
    if(cc == 41 && val == 127, {
        if(~sequence.isPlaying(), {~sequence.stop;}, {~sequence.play;});
    });
    if(cc == 32, {
        y.set(\volume, LinLin.kr(val, 0, 127, 0.0, 1.0)); 
    });
})
)
~attack.postln;
~modfreq.postln;
~attack.postln;
~attack.postln;
~decay.postln;
MIDIdef.freeAll;
s.meter

