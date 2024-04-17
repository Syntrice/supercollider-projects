// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
//o.hardwareBufferSize = 1024;
//s.latency = 0.3;
s.options.numAudioBusChannels = 128;
s.options.numOutputBusChannels = 9; // 8 plus subwoofer
s.options.numInputBusChannels = 2;
Server.default.reboot;
)

(
Routine {

	// --- Parameters ---

	~stereo_mixdown = true; // toggle to enable a stereo mixdown
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

		#c, r, rs, bsr, bc, bsl, ls, l, lfe = snd;


		if (~stereo_mixdown) {
			l = Mix([c * 0.707, l * 1, ls * 0.707, bsl * 0.707, bc * 0.707]);
			r = Mix([c * 0.707, r * 1, rs * 0.707, bsr * 0.707, bc * 0.707]);
			snd = [l,r];
		} {
			// Reorder output to match speaker arrangement
			snd = [l, r, c, lfe, ls, rs, bsl, bsr, bc];
		};

		// Limiter
		snd = Limiter.ar(snd, -3.dbamp);

		Out.ar(0, snd);
	}
	).add;

	0.1.wait;

	~bus_master.free; ~bus_master = Bus.audio(s, 9);
	~channel_master.free; ~channel_master = Synth(\master, [\in, ~bus_master], ~mixer, \addToTail);

	// Reverb
	SynthDef(\reverb, {
		arg in;
		var snd, input, leak;

		input = In.ar(in, 8);
		snd = Array(8);

		leak = input.sum * 0.05;

		~numChannels.do { |i|
			snd.add(FreeVerb.ar(input[i],0.66,0.8));
			snd[i] = snd[i] + FreeVerb.ar(leak,1,0.8);
		};

		Out.ar(~bus_master, snd);
	}
	).add;

	0.1.wait;

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
			temp = BPF.ar(noise, f, bw / f);

			// second band pass
			temp = BPF.ar(temp, f, bw / f);

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
		send = send * amp_env * \amp.kr(1) * -6.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Pan signal
		send = PanAz.ar(~numChannels, send, \pan.kr(0), orientation: 0);

		// Output
		Out.ar(\out.kr(~bus_master), send)
	}.add;

	// Percussion
	SynthDef(\perc, {
		var snd, env, temp, freq, band_width;

		// Signal
		snd = WhiteNoise.ar();

		// Filter
		band_width = \band_width.kr(40);

		freq = \freq.kr(3000);
		snd = BPF.ar(snd,freq, band_width / freq);
		snd = LPF.ar(snd, freq);

		// Envelope
		env = Env.perc(0.01, 0.25).ar(Done.freeSelf, gate: \gate.kr(1));

		// Amplitude
		snd = snd * env * \amp.kr(1) * 0.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Delay
		//snd = CombC.ar(snd, 0.01, XLine.kr(0.0001, 0.01, 20), 0.2);


		// Pan signal
		snd = PanAz.ar(~numChannels, snd, \pan.kr(0), orientation: 0);

		// Free synth
		//FreeSelf.kr(TDelay.kr(Done.kr(env),1));

		// Output
		Out.ar(\out.kr(~bus_reverb), snd);
	};
	).add;

	// --- Functions ---

	~tempoChange = {

		// Uses an envelope to define continous tempo variation over a period of beats:
		arg env, clock = TempoClock.default, control_rate = 8;
		var duration, i;

		i = 0.0;
		duration = env.totalDuration;
		clock.schedAbs(clock.nextBar, {
			clock.tempo_(env.at(i + (clock.tempo / control_rate))/60);
			i = i + (clock.tempo / control_rate);

			env.at(i).postln;
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

			env.at(i).postln;
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

	// Frees a bound Ndef from a pattern, replacing the parameter with specified value
	~freeNdef = {
		arg pattern, parameter, value;
		var ndef_name;

		ndef_name = pattern ++ "_" ++ parameter;
		Pbindef(pattern.asSymbol, parameter.asSymbol, value);
		Ndef(ndef_name.asSymbol).clear;
	};

	// Binds an Ndef to a pattern parameter with the specified function
	~bindFunc = {
		arg pattern, parameter, func;
		var ndef_name;

		ndef_name = pattern ++ "_" ++ parameter;

		Ndef(ndef_name.asSymbol, func);
		Pbindef(pattern.asSymbol, parameter.asSymbol, Ndef(ndef_name.asSymbol));
	};

	~t_pitch = {
		arg m_pitch, chord, order, octave_steps = 8;
		var m_oct, oct, direction, magnitude, value, i;

		// calculate pitch class and octave
		m_oct = m_pitch.div(octave_steps);
		m_pitch = m_pitch % octave_steps;

		// calculate direction and magnitude
		direction = order.abs / order;
		magnitude = order - direction;

		// which direction to calculate t_pitch

		if (direction > 0, {
			i = 0;
			oct = 0;
			value = chord[0];
			while {(value + (octave_steps * oct)) <= m_pitch} {
				value = chord[i % chord.size];
				oct = i.div(chord.size);
				i = i + 1;
			};

			if (magnitude > 0) {
				value = chord[(i + magnitude - 1) % chord.size];
				oct = oct + (i + magnitude - 1).div(chord.size);
			};

			value = value + (octave_steps * (oct + m_oct));

		},
		{
			i = -1;
			oct = 0;

			value = chord[-1 % chord.size];

			while {(value + (octave_steps * oct)) >= m_pitch} {
				value = chord[i % chord.size];
				oct = i.div(chord.size) + 1;

				i = i - 1;
			};

			if (magnitude < 0) {
				value = chord[(i + magnitude + 1) % chord.size];
				oct = (i + magnitude + 1).div(chord.size) + 1;
			};

			value = value + (octave_steps * oct) + (octave_steps * m_oct);
		});
		value;
	};

	// -- MIDI --

	MIDIClient.init;
	MIDIIn.connectAll;

	~notes = Array.newClear(128);
	~t = Array.newClear(128);

	// chord to use
	~chord = [0,4,9];
	~order = -1;
	~orbit = true;

	MIDIdef.noteOn(\noteOnTest, {
		arg vel, nn, chan, src;
		[vel, nn, chan].postln;
		~notes[nn] = Synth.new(
			\noise_engine,
			[
				\freq, (nn).midicps,
				\amp, vel.linexp(1,127,0.01,0.3),
				\gate, 1,
				//\cutoff, 2000,
				\band_width, 50,
				//\atk, 1,
				\rel, 2,
				\pan,
				\pan, [0,0.25,0.5,0.75,1.00,1.25,1.5,1.75].choose;

			],
		);
		~t[nn] = Synth.new(
			\noise_engine,
			[
				//\freq, (~t_pitch.((nn - 60), ~chord, ~order, 12) + 60).midicps,
				\freq, (nn).midicps,
				\amp, vel.linexp(1,127,0.01,0.3),
				\gate, 1,
				//\cutoff, 2000,
				\band_width, 50,
				//\atk, 1,
				\rel, 2,
				\pan, 0,
				\pan, [0,0.25,0.5,0.75,1.00,1.25,1.5,1.75].choose;
			],
		);

		// inverts direction every note
		if (~orbit) {
			~order = ~order * -1;
			~order.postln;
		};
	});

	MIDIdef.noteOff(\noteOffTest, {
		arg vel, nn, chan, src;
		[vel, nn].postln;
		~notes[nn].set(\gate, 0);
		~notes[nn] = nil;
		~t[nn].set(\gate, 0);
		~t[nn] = nil;


	});

	\setup_complete.postln;

}.play;
)
