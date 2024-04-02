// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;"D:/Development/Supercollider/wind_modeling.scd"
)

// SynthDefs
(
SynthDef.new(\noise_engine) {
	var noise, partials, band_width, freq, temp, amp_env, send, dtune;

	// Generate noise signal
	noise = WhiteNoise.ar();

	send = 0;

	// Number of partials including fundamental
	partials = 8;
	band_width = \band_width.kr(5);
	freq = \freq.kr(440);
	dtune = \dtune.kr(0.01);

	partials.do{ | i |
		var f, bw;
		i = i + 1;

		// detune partial frequency
		f = freq * i * LFNoise2.kr(1,dtune,1.00);

		// randomize partial band_width TODO:
		bw = band_width;

		// first band pass
		//temp = BPF.ar(noise, f, bw / f, 100 * bw.reciprocal);
		temp = BPF.ar(noise, f, bw / f, 100 * bw.reciprocal);


		// second band pass
		temp = BPF.ar(temp, f, bw / f, 1);

		// higher partials have a lower amplitude
		temp = temp * 1 / (i**3);

		send = send + temp;
	};

	// Amplitude Envelope
	amp_env = Env.adsr(
		\atk.ir(0.5),
		\dec.ir(0.3),
		\sus.ir(0.5),
		\rel.ir(0.5),
	).ar(Done.freeSelf, \gate.kr(1));

	// Amp signal
	send = send * amp_env * \amp.kr(1);

	// Limit signal

	// Pan signal
	send = Splay.ar(send, \spread.kr(0), 1, \pan.kr(0));

	// Output
	Out.ar(\bus.kr(0), send)
}.add;
)

// functions

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
	duration.postln;
	duration;
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
		env.at(i).postln;
		if(i < duration) {clock.tempo / (control_rate)} {
			\done.postln; parameter.set(\val, env.at(env.totalDuration));
		};
	});
	duration.postln;
	duration;
};
)


Pbindef(\pattern1,
	\instrument, \noise_engine,
	\dur, 1,
	\degree, Pxrand([[0,4,7],[-1,5,8],[-3,1,5]],inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 0.05,
	\rel, 4,
	\amp, Pwhite(0.3,0.75),
	\band_width, Ndef(\band_width),
)


// Patterns

// Piece

// Piece Arguments
(
~tempo = 60;
~signiture = 4;
)

(
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});

r = Routine({
	Pbindef(\pattern1).clear;

	Ndef(\band_width, {LFNoise1.kr(4.reciprocal).range(5,20)});

	Pbindef.new(\pattern1,
	\instrument, \noise_engine,
	\dur, 1,
	\degree, Pxrand([[0,4,7],[-1,5,8],[-3,1,5]],inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 0.05,
	\rel, 4,
	\amp, Pwhite(0.3,0.75),
	\band_width, Ndef(\band_width););

	Pbindef(\pattern1).play(t, quant:4);

	8.wait;

	~tempoChange.(Env([60,180],[8]),t,8).wait;

	8.wait;

	// todo - make wrapper function
	// ~modulatePattern.(\pattern1, \atk, env, t)
	// ~wrapFunction.(\pattern, \atk, func)

	Ndef(\atk, {\val.kr(0.05)});
	Pbindef(\pattern1, \atk, Ndef(\atk));
	~parameterChange.(Ndef(\atk), Env([0.05,1,0.05],[10]), t).wait;

	8.wait;

	Ndef(\dtune, {\val.kr(0.01)});
	Pbindef(\pattern1, \dtune, Ndef(\dtune));
	~parameterChange.(Ndef(\dtune), Env([0.01,5,0.01],[20],6), t).wait;

	~tempoChange.(Env([180,60],[8]),t,8).wait;
	Ndef(\band_width, {SinOsc.kr(4).range(5,20)});
	16.wait;
	Pbindef(\pattern1).stop;
});

r.play(t, quant:4);
)
