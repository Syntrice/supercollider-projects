// These are two useful functions which schedule tempo and parameter changes on a TempoClock relative to an envelope. Duration is given in beats, and parameterChange can be used while also changing tempo (it will align). Control rate is given in control updates per second.

(
~tempoChange = {

	// Uses an envelope to define continous tempo variation over a period of beats:
	arg env, clock = TempoClock.default, control_rate = 8;
	var duration, i;

	i = 0.0;
	duration = env.totalDuration;
	clock.schedAbs(clock.nextBar, {
		clock.tempo_(env.at(i + (clock.tempo / control_rate))/60);
		i = i + (clock.tempo / control_rate);
		//i.postln;
		//env.at(i).postln;
		if(i < duration) {clock.tempo / control_rate} {
			\done.postln
		};
	});
};
)

(
~parameterChange = {

	// Uses an envelope over a period of time to change an Ndef parameter
	// 1 update per 64 samples, at a sample rate of 44100
	arg parameter, env, clock = TempoClock.default, control_rate = 44100 / 64;
	var duration, i;

	i = 0.0;
	duration = env.totalDuration;
	clock.schedAbs(clock.nextBar, {
		parameter.set(\val, env.at(i));
		i = i + (clock.tempo / control_rate);
		//i.postln;
		//env.at(i).postln;
		if(i < duration) {clock.tempo / (control_rate)} {
			\done.postln; parameter.set(\val, env.at(env.totalDuration));
		};
	});
};
)

// Play a simple pattern
(
Ndef(\freq, {\val.kr(440)});

Pdef(\test_pattern,
	Pbind(
		\dur, 1/4,
		\degree, 0,
		\freq, Ndef(\freq),
		\legato, 0.25,
	);
);

~bpm = 60;
~signiture = 4;
t = TempoClock.new(~bpm/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
Pdef(\test_pattern).play(t, quant:4);
)


// Automate frequency and tempo simultaneously
(
~parameterChange.(Ndef(\freq), Env([440,880,440],[4,4]), t,41000/64);
~tempoChange.(Env([60,120,60],[4,4]),t,8);
)
