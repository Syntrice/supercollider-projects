// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
s.options.numAudioBusChannels = 128;
s.options.numOutputBusChannels = 9; // 8 plus subwoofer
s.options.numInputBusChannels = 2;
Server.default.reboot;
)

(
// Parameters

~stereo_mixdown = false; // toggle to enable a stereo mixdown
~numChannels = 8; // number of mixing channels
~numLFE = 1; // number of LFE channels

~mixer.free; ~mixer = Group(s, \addToTail);

// --- Channels ---

// Master
SynthDef(\master, {
	arg in;
	var snd;
	var l, r, c, lfe, ls, rs, bsl, bsr, bc;

	snd = In.ar(in, ~numChannels + ~numLFE);

	#l, c, r, rs, bsr, bc, bsl, ls, lfe = snd;


	if (~stereo_mixdown) {
		r = Mix([c,r,rs,bsr,bc]);
		l = Mix([c,l,ls,bsl,bc]);
		snd = [l,r];
	} {
		// Reorder output to match speaker arrangement
		snd = [l, r, c, lfe, ls, rs, bsl, bsr, bc];
	};

	// Limiter
	snd = Limiter.ar(snd, -32.dbamp);

	Out.ar(0, snd);
}
).add;

~bus_master.free; ~bus_master = Bus.audio(s, 8);
~channel_master.free; ~channel_master = Synth(\master, [\in, ~bus_master], ~mixer, \addToTail);

// Reverb
SynthDef(\reverb, {
	arg in;
	var snd, input;

	input = In.ar(in, ~numChannels);
	snd = Array(~numChannels);

	~numChannels.do { |i|
		snd.add(FreeVerb.ar(input[i]));
	};

	snd.postln;

	Out.ar(~bus_master, snd);
}
).add;

~bus_reverb.free; ~bus_reverb = Bus.audio(s, 8);
~channel_reverb.free; ~channel_reverb = Synth(\reverb, [\in, ~bus_reverb], ~mixer);

// --- Synths ---

// Noise engine
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

// Percussion
SynthDef.new(\tap) {
	var noise, freq, amp_env, send, atk, rel;

	// Generate noise signal
	noise = WhiteNoise.ar();

	freq = \freq.kr(5000);

	atk = \atk.ir(0.005);
	rel = \rel.ir(1);

	// Filter noise signal
	noise = LPF.ar(noise, freq * Env([1,0.5],rel,-16).kr());

	// Amplitude Envelope
	amp_env = Env([0,1,0],[atk,rel],[1,-16]).ar(Done.freeSelf);

	// Amp signal
	send = noise * amp_env * AmpCompA.kr(freq) * \amp.kr(1);

	// Pan signal
	send = Pan2.ar(send, \pan.kr(0));


	// Output
	Out.ar(\out.kr(0), send)
}.add;

// --- Functions --

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
			\done.postln;
		};
	});
	duration;
};

~scheduleFunc = {

	// Uses an envelope over a period of time, passing the control steps to a function
	arg func, env, clock = TempoClock.default, control_rate = 44100 / 64;
	var duration, i;

	i = 0.0;
	duration = env.totalDuration;
	clock.schedAbs(clock.nextBar, {
		func.(env.at(i));
		i = i + (clock.tempo / control_rate);
		//i.postln;
		//env.at(i).postln;
		if(i < duration) {clock.tempo / (control_rate)} {
			func.(env.at(env.totalDuration)); \done.postln;
		};
	});
	duration;
};

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
			parameter.set(\val, env.at(env.totalDuration)); \done.postln;
		};
	});
	duration;
};

// Binds an Ndef to a pattern parameter and modulates it
~modulatePattern = {
	arg pattern, parameter, env, t, control_rate = 44100 / 64;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;

	Ndef(ndef_name.asSymbol, {\val.kr(env.at(0))});
	Pbindef(pattern.asSymbol, parameter.asSymbol, Ndef(ndef_name.asSymbol));
	~parameterChange.(Ndef(ndef_name.asSymbol), env, t, control_rate);

};

// Binds an Ndef to a pattern parameter with the specified function
~bindFunc = {
	arg pattern, parameter, func;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;

	Ndef(ndef_name.asSymbol, func);
	Pbindef(pattern.asSymbol, parameter.asSymbol, Ndef(ndef_name.asSymbol));
};

// Frees a bound Ndef from a pattern, replacing the parameter with specified value
~freeNdef = {
	arg pattern, parameter, value;
	var ndef_name;

	ndef_name = pattern ++ "_" ++ parameter;
	Pbindef(pattern.asSymbol, parameter.asSymbol, value);
	Ndef(ndef_name.asSymbol).clear;
}
)