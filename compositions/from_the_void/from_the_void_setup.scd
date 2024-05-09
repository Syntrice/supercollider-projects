// "From the Void"
// Made with Supercollider 3.13.0

/*
This file contains setup code for the composition "From the Void". It should not be run directly, but placed in the same folder as from_the_void_setup.scd, and will be run automatically when executing the setup code.
*/

(

if (s.serverRunning.not, {
	"booting server".postln;
	s.boot;
	o = Server.default.options;
	o.device = ~audio_device;
	s.options.numOutputBusChannels = ~numOutputBusChannels;
	s.options.numInputBusChannels = ~numInputBusChannels;
	Server.default.reboot;
	"booting complete".postln;
});

~cleanup = {
	"cleaning up".postln;
	s.freeAll;
	ServerTree.remove(~initTree);
	ServerQuit.remove(~cleanup);
};

~cleanup.();
ServerQuit.add(~cleanup);

s.newAllocators;

s.waitForBoot({
	"setting up master / effects synths".postln;

	// --- Master / Effect Synths ---

	SynthDef(\master, {
		arg in;
		var snd, l, r, c, lfe, ls, rs, bsl, bsr, bc, r_mix, l_mix, mix;

		// 8.1 channels
		snd = In.ar(in, 9);

		// unpack input audio
		#c, r, rs, bsr, bc, bsl, ls, l, lfe = snd;

		// Low pass on LFE channel
		lfe = LPF.ar(lfe,120);

		// Produce stereo-mixdown
		r_mix = Mix([c * 0.5, l * 0.5, ls * 0.5, bsl * 0.5, bc * 0.5]);
		l_mix = Mix([c * 0.5, r * 0.5, rs * 0.5, bsr * 0.5, bc * 0.5]);

		if(~stereoOut.not, {
			// reorder output to match speaker arrangement
			snd = [l, r, c, lfe, ls, rs, bsl, bsr, bc];
		}, {
			// for stereo out, l_mix and r_mix to output bus 0 and 1.
			snd = [l_mix, r_mix];
		});

		// Limiter
		//snd = snd * 3.dbamp;
		snd = Limiter.ar(snd, -3.dbamp);

		mix = [l_mix, r_mix];
		mix = Limiter.ar(mix, -3.dbamp);


		Out.ar(\srec.kr(0), mix);
		Out.ar(\out.kr(0), snd);
	}
	).add;

	// Reverb
	SynthDef(\reverb, {
		arg in;
		var snd, input, leak;

		// 8.1 channels
		input = In.ar(in, 9);

		// new output array
		snd = Array(9);

		// leak factor
		leak = input.sum * 0.01;

		// create reverb ugens
		8.do { |i|
			snd.add(FreeVerb.ar(input[i],0.66,0.8));
			snd[i] = snd[i] + FreeVerb.ar(leak,1,0.8);
		};

		// create LFE reverb
		snd.add(FreeVerb.ar(input[8],0.66,0.8));

		Out.ar(\out.kr(0), snd);
	}
	).add;

	s.sync;

	~initTree = {
		~bus_master = Bus.audio(s, 9);
		~bus_reverb = Bus.audio(s, 9);
		~bus_stereo_record = Bus.audio(s, 2);

		~mixer = Group(s, \addToTail);
		~synth_master = Synth(\master, [\in, ~bus_master, \srec, ~bus_stereo_record], ~mixer, \addToTail);
		~synth_reverb = Synth(\reverb, [\in, ~bus_reverb, \out, ~bus_master], ~mixer);
	};

	ServerTree.add(~initTree);
	ServerTree.run;

	// --- Synths ---

	"setting up sound synths".postln;

	// Noise engine
	SynthDef.new(\noise_engine) {
		var noise, partials, band_width, freq, temp, amp_env, send, dtune, pamp, pdrift, pan, output;

		// Generate noise signal
		noise = WhiteNoise.ar();

		send = 0;

		pamp = \pamp.kr(3);
		pdrift = \pdrift.kr(1.01);
		pan = \pan.kr(0);
		band_width = \band_width.kr(5);
		freq = \freq.kr(440);
		dtune = \dtune.kr(0.01);

		// Number of partials including fundamental
		partials = 8;

		partials.do{ | i |
			var f;
			i = i + 1;

			// detune partial frequency
			f = freq * i * LFNoise2.kr(1,dtune,1.00);


			// first band pass
			//temp = BPF.ar(noise, f, bw / f, 100 * bw.reciprocal);
			temp = BPF.ar(noise, f, band_width / f);

			// second band pass
			temp = BPF.ar(temp, f, band_width / f);

			// higher partials have a lower amplitude
			temp = temp * (1 / (i**pamp));

			//temp = PanAz.ar(~numChannels, temp, pan * LFNoise2.kr(1,pdrift,1.00), orientation: 0);

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
		send = send * amp_env * \amp.kr(1) * -8.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Pan signal
		output = PanAz.ar(8, send, \pan.kr(0), orientation: 0);

		output = [output[0],output[1],output[2],output[3],output[4],output[5],output[6],output[7],
			send * \subamp.kr(0) * 5.dbamp;
		];

		// Output
		Out.ar(\out.kr(~bus_master), output)
	}.add;

	// Impulse
	SynthDef.new(\impulse) {
		var noise, partials, band_width, freq, temp, amp_env, send, dtune, pamp, pdrift, pan, output;

		// Generate noise signal
		noise = WhiteNoise.ar();

		send = 0;

		pamp = \pamp.kr(3);
		pdrift = \pdrift.kr(1.01);
		pan = \pan.kr(0);
		band_width = \band_width.kr(5);
		freq = \freq.kr(440);
		dtune = \dtune.kr(0.01);

		// Number of partials including fundamental
		partials = 24;

		partials.do{ | i |
			var f;
			i = i + 1;

			// detune partial frequency
			f = freq * i * LFNoise2.kr(1,dtune,1.00);


			// first band pass
			//temp = BPF.ar(noise, f, bw / f, 100 * bw.reciprocal);
			temp = BPF.ar(noise, f, band_width / f);

			// second band pass
			temp = BPF.ar(temp, f, band_width / f);

			// higher partials have a lower amplitude
			temp = temp * (1 / (i**pamp));

			//temp = PanAz.ar(~numChannels, temp, pan * LFNoise2.kr(1,pdrift,1.00), orientation: 0);

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
		send = send * amp_env * \amp.kr(1) * -10.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Pan signal
		output = PanAz.ar(8, send, \pan.kr(0), orientation: 0);

		output = [output[0],output[1],output[2],output[3],output[4],output[5],output[6],output[7],
			send * \subamp.kr(0) * 5.dbamp;
		];

		// Output
		Out.ar(\out.kr(~bus_master), output)
	}.add;

	// Percussion
	SynthDef(\perc, {
		var snd, env, temp, freq, band_width, output;

		// Signal
		snd = WhiteNoise.ar();

		// Filter
		band_width = \band_width.kr(40);

		freq = \freq.kr(3000);
		snd = BPF.ar(snd,freq, band_width / freq);
		snd = LPF.ar(snd, freq);

		// Envelope
		env = Env.perc(\atk.ir(0.01), \rel.ir(0.25)).ar(Done.freeSelf, gate: \gate.kr(1));

		// Amplitude
		snd = snd * env * \amp.kr(1) * -1.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Delay
		//snd = CombC.ar(snd, 0.01, XLine.kr(0.0001, 0.01, 20), 0.2);


		// Pan signal
		output = PanAz.ar(8, snd, \pan.kr(0), orientation: 0);

		output = [output[0],output[1],output[2],output[3],output[4],output[5],output[6],output[7],
			snd * \subamp.kr(0) * 5.dbamp;
		];

		// Output
		Out.ar(\out.kr(~bus_reverb), output);
	};
	).add;

	s.sync;

	// --- Helper Functions ---


	"setting up helper functions".postln;

	// Ndef modulation function
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

			//env.at(i).postln;
			if(i < duration) {clock.tempo / (control_rate)} {
				parameter.set(\val, env.at(env.totalDuration)); \done.postln;
			};
		});
		duration;
	};


	// Tintinnabuli function
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

	// Functions to start and stop recording


	"setting up recording functions".postln;

	~startRecording = {
		if(~stereoOut, {
			~stereo_recorder = Recorder(s);
			~stereo_recorder.filePrefix = "FROM_THE_VOID_STEREO_";
			~stereo_recorder.record(bus: ~bus_stereo_record, numChannels: 2);
		}, {
			~stereo_recorder = Recorder(s);
			~stereo_recorder.filePrefix = "FROM_THE_VOID_STEREO_";
			~surround_recorder = Recorder(s);
			~surround_recorder.filePrefix = "FROM_THE_VOID_SURROUND_";

			~surround_recorder.record(bus: 0, numChannels: 9);
			~stereo_recorder.record(bus: ~bus_stereo_record, numChannels: 2);
		});
	};

	~stopRecording = {
		if(~stereoOut, {
			~stereo_recorder.stopRecording;
		}, {
			~stereo_recorder.stopRecording;
			~surround_recorder.stopRecording;
		});
	};

	"initial setup complete!".postln;
});
)