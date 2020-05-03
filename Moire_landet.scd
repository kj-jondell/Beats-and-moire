/***
Interference/Moiré/Beats midi controller

TODO: 1. Ampltiude equalization (first, plot amplitude over modulation index)
2. Sound in from Soundflower.......!
3. Buses...

© Karl Johannes Jondell 2019
***/
(
    s.options.device = "Soundflower (64ch)";
    s.options.memSize = 8192*64;
    s.options.numOutputBusChannels = 4;

    MIDIClient.init;
    MIDIIn.connectAll;

    s.waitForBoot({
        var leftNoise, rightNoise, moireSynth, moireBassSynth;
        var sourceGroup, fxGroup;
        //var harmonics = 1;
        var justScale = Scale.chromatic(\just);
        var keys, releaseTime = 7, attackTime = 1, detune = 1.01, harmonics = 1;
        var customScale = {
            arg note, root = 29, tuning = 45;
            var ratios = [1, 19/18, 10/9, 6/5, 5/4, 47/36, 25/18, 53/36, 55/36, 5/3, 67/36, 23/12]; //TODO: FIX RATIOS!
            ratios[(note-root)%ratios.size]*tuning*((note-root)/ratios.size+1).floor;
        };

        SynthDef.new(\Interference, {
            arg harmonics = 1.0, freq = 440, detune = 1, outBus = 0, velocity = 64, attackTime = 2, releaseTime = 2, sustainLevel = 1, gate = 1;

            var left = Moire.ar(freq: freq, harmonics: harmonics, mul: 0.4)+Moire.ar(freq: freq*detune, harmonics: harmonics, mul: 0.4);
            var right = Moire.ar(freq: freq, harmonics: harmonics, mul: 0.4)+Moire.ar(freq: freq*(detune-0.01), harmonics: harmonics, mul: 0.4);

            var filterLeft = BLowPass4.ar(left, freq*Lag2.kr(velocity.linlin(0,127,2.0,20.0)), Lag2.kr(velocity.linlin(0,127,2.0,4.0)));
            var filterRight = BLowPass4.ar(right, detune*freq*Lag2.kr(velocity.linlin(0,127,2.0,20.0)), Lag2.kr(velocity.linlin(0,127,1.9,3.9)));
            var stretch = velocity.linlin(0,127,1,1.5);
            //(1-SpecFlatness.kr(FFT(LocalBuf(2048), [left, right]))).poll;
            var env = EnvGen.ar(Env.asr(attackTime: attackTime * stretch, sustainLevel: sustainLevel, releaseTime: releaseTime * stretch, curve: -4.0), gate: gate, doneAction: Done.freeSelf);

            var output = env*[filterLeft, filterRight]*velocity.linlin(0,127,-15,-6).dbamp;

            Out.ar(outBus, LeakDC.ar(output)); 
        }).add;

        s.sync; 

        keys = nil!128;

        //moireSynth = Synth.new(\Interference, [\harmonics, 0.95, \detune, 1, \freq, 87.307]);
        //moireBassSynth = Synth.new(\Interference, [\harmonics, 0.96, \detune, 1.03, \freq, 43.654, \outBus, 2]);

        //r = Routine.new({
        //    loop {
        //        if(harmonics > 0.01){harmonics = harmonics-0.01;};
        //        moireSynth.set(\harmonics, harmonics);
        //        moireBassSynth.set(\harmonics, harmonics);
        //        moireBassSynth.set(\freq, 30.rand+87);
        //        0.5.yield;
        //    }
        //});
        //r.play;

        MIDIFunc.noteOn({
            arg vel, note;
            //moireBassSynth.set(\freq, note.midicps);
            //moireBassSynth.set(\freq, note.keyToDegree(justScale, 12).degreeToKey(justScale).midicps);
            //moireBassSynth.set(\freq, customScale.value(note));
        }, chan: 5);

        MIDIFunc.noteOff({
            arg vel, note;
            if(keys[note].notNil,
            {
                keys[note].release;
                keys[note] = nil;
            }
        );}, chan: 4);

        MIDIFunc.cc({
            arg vel, num;
            switch(num,
                16, {
                    keys.do({
                        arg key;
                        detune = vel.linlin(0.0,127.0, 1.0, 1.2);
                        key.set(\detune, detune);
                    });
                },
                17, {
                    keys.do({
                        arg key;
                        releaseTime = vel.linlin(0.0,127.0, 1, 10);
                        key.set(\releaseTime, releaseTime);
                    });
                },
                18, {
                    keys.do({
                        arg key;
                        attackTime = vel.linlin(0.0,127.0,0.001, 2.5);
                        key.set(\attackTime, attackTime);
                    });
                },
                0, {
                    keys.do({
                        arg key;
                        harmonics = vel.linexp(0.0,127.0, 0.6, 1.2);
                        key.set(\harmonics, harmonics);
                    });
                }

            );
        });

        MIDIFunc.noteOn({
            arg vel, note;
            if(keys[note].isNil,
            {
                keys[note] = Synth.new(\Interference, [\harmonics, harmonics, \releaseTime, releaseTime, \attackTime, attackTime, \detune, detune, \velocity, vel, \freq, note.keyToDegree(justScale, 12).degreeToKey(justScale).midicps]);
            });}, chan: 4);
        }
    );
)

Scale.
//SERVER FUNCTIONS
s.boot;
s.reboot;
s.quit;
s.options.numInputBusChannels = 64;
s.meter;

OSCFunc.trace(false);
MIDIdef.freeAll;

Scale.chromatic('just').degreeToFreq(60,60,midicps, 1);
s.queryAllNodes()
