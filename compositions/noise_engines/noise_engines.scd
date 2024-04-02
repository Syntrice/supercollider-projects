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

// Binds an Ndef to a pattern parameter and modulates it
(
~modulatePattern = {
	arg pattern, parameter, env, t, control_rate = 44100 / 64;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;

	Ndef(ndef_name.asSymbol, {\val.kr(env.at(0))});
	Pbindef(pattern.asSymbol, parameter.asSymbol, Ndef(ndef_name.asSymbol));
	~parameterChange.(Ndef(ndef_name.asSymbol), env, t, control_rate);

};
)

// Binds an Ndef to a pattern parameter with the specified function
(
~bindFunc = {
	arg pattern, parameter, func;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;

	Ndef(ndef_name.asSymbol, func);
	Pbindef(pattern.asSymbol, parameter.asSymbol, Ndef(ndef_name.asSymbol));
};
)

// Frees a bound Ndef from a pattern, replacing the parameter with specified value
(
~freeNdef = {
	arg pattern, parameter, value;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;
	Pbindef(pattern.asSymbol, parameter.asSymbol, value);
	Ndef(ndef_name.asSymbol).clear;
}
)


// Tempo Arguments
(
~tempo = 60;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)



Pbindef.clear;

(
Pbindef(\pattern1,
	\instrument, \noise_engine,
	\dur, Pwhite(1,3, inf),
	\freq, Pexprand(220,880, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 6,
	\rel, 6,
	\amp, Pwhite(0.3,0.75),
	\band_width, 100,
)
)

(
Pbindef(\pattern2,
	\instrument, \noise_engine,
	\dur, Pwhite(3,4, inf),
	\freq, Pexprand(40,120, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 3,
	\rel, 3,
	\amp, Pwhite(0.3,0.75),
	\band_width, 100,
)
)

Pbindef(\pattern1).play(t, quant:4);

~modulatePattern.(\pattern1, \band_width, Env([100,50],[20]), t);

(
~modulatePattern.(\pattern1, \rel, Env([6,3],[20]), t);
~modulatePattern.(\pattern1, \atk, Env([6,3],[20]), t);
)

~modulatePattern.(\pattern1, \band_width, Env([50,20],[20]), t);

Pbindef(\pattern2).play(t, quant:4);

(
~bindFunc.(\pattern1, \band_width, {LFNoise1.kr(3.reciprocal).range(10,30)});
~bindFunc.(\pattern1, \dtune, {LFNoise1.kr(3.reciprocal).range(0.01,0.05)});
)

(
Pbindef(\pattern1, \dur, Pwhite(2,3,inf));
)

(
Pbindef(\pattern1a,
	\instrument, \noise_engine,
	\dur, Pwhite(1,3, inf),
	\freq, Pexprand(120,240, inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 2,
	\rel, 3,
	\amp, Pwhite(0.3,0.75),
	\band_width, 15,
)
)

Pbindef(\pattern1a).play;
~modulatePattern.(\pattern1a, \band_width, Env([100,50],[20]), t);
~modulatePattern.(\pattern1a, \band_width, Env([100,15],[10]), t);


