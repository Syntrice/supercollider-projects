(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;"D:/Development/Supercollider/wind_modeling.scd"
)


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

~tempo = 60;

t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(4)});

Ndef(\band_width, {\val.kr(5)})

(
p = Pbind(
	\instrument, \noise_engine,
	\dur, 2,
	\degree, Pxrand([[0,4,7],[-1,5,8],[-3,1,5]],inf),
	\pan, Pwhite(-0.8,0.8,inf),
	\atk, 3,
	\rel, 3,
	\band_width, Ndef(\band_width)
).play(t, quant: 4);
)

Ndef(\band_width).xset(\val, 5)
Ndef(\band_width).gui;


~control_rate = 8;

(
r = Routine({
	var env, times;
	env = Env([5,50,5], [20, 20]);

	times = env.totalDuration.postln * ~control_rate;
	times.do{ |i|
		i = i + 1;
		env.at(~control_rate.reciprocal * i).postln;
		Ndef(\band_width).xset(\val, env.at(~control_rate.reciprocal * i));
		~control_rate.reciprocal.wait;
	};
});
)

r.play(t, quant:4);

(
r = Routine({
	arg start = 5;
	Ndef(\band_width).fadeTime = ~control_rate.reciprocal;
	Array.interpolation(~control_rate * 32, 5, 200).do({ |n|
		Ndef(\band_width).xset(\val, n);
		~control_rate.reciprocal.wait;
	});
	\done.postln;
});
)

r.play(t, quant:4);
