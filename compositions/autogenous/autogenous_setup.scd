(
// -- Setup ---

if (s.serverRunning.not, {
	"booting server".postln;
	o = Server.default.options;
	o.device = "ASIO : Focusrite USB ASIO";
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
	"setting up".postln;

	// --- Channels ---

	// Master
	SynthDef(\master, {
		arg in;
		var snd;

		snd = In.ar(in, 2);
		snd = Limiter.ar(snd, -6.dbamp);

		Out.ar(\out.kr(0), snd);
	}).add;

	// Reverb
	SynthDef(\reverb, {
		arg in;
		var snd;

		snd = In.ar(in, 2);
		snd = FreeVerb2.ar(snd[0], snd[1], \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5));

		Out.ar(\out.kr(0), snd);
	}).add;

	s.sync;

	~initTree = {
		~bus_master = Bus.audio(s, 2);
		~bus_reverb = Bus.audio(s, 2);
		~mixer = Group(s, \addToTail);
		~synth_master = Synth(\master, [\in, ~bus_master], ~mixer, \addToTail);
		~synth_reverb = Synth(\reverb, [\in, ~bus_reverb, \out, ~bus_master], ~mixer);
	};

	ServerTree.add(~initTree);
	ServerTree.run;

	// --- Synths ---

	// Unison sine
	SynthDef(\sine, {
		var snd, ampEnv, temp, gen, freq;

		// Signal
		freq = \freq.kr(440);
		snd = 0;

		4.do({
			arg i;
			temp = SinOsc.ar(
				freq * LFNoise2.kr(1,\dtune.kr(0.01),1);
			);
			snd = snd + temp;
		});

		// Envelope
		ampEnv = Env.adsr(
			\atk.ir(0.01),
			\dec.ir(0.3),
			\sus.ir(0.5),
			\rel.ir(1),
			\peak.ir(1)
		).ar(Done.freeSelf, \gate.kr(1));

		// Amplitude
		snd = snd * ampEnv * -17.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

		// Pan
		snd = Pan2.ar(snd, \pan.kr(0));

		// Output
		Out.ar(\out.kr(~bus_master), snd);
	}).add;

	// Unison saw
	SynthDef(\saw, {
		var snd, ampEnv, temp, gen, freq;

		// Signal
		freq = \freq.kr(440);
		snd = 0;

		4.do({
			arg i;
			temp = Saw.ar(freq *
				LFNoise2.ar(1,\dtune.kr(0.01),1)
			);
			snd = snd + temp;
		});

		// Filter
		snd = LPF.ar(snd, \cutoff.kr(1000));

		// Envelope
		ampEnv = Env.adsr(
			\atk.ir(0.01),
			\dec.ir(0.3),
			\sus.ir(0.5),
			\rel.ir(0.5),
			\peak.ir(1)
		).ar(Done.freeSelf, \gate.kr(1));

		// Amplitude
		snd = snd * ampEnv * -11.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

		// Pan
		snd = Pan2.ar(snd, \pan.kr(0));

		// Output
		Out.ar(\out.kr(~bus_master), snd);
	}).add;

	// Unison Square
	SynthDef(\square, {
		var snd, ampEnv, temp, gen, freq;

		// Signal
		freq = \freq.kr(440);
		snd = 0;

		4.do({
			arg i;
			temp = Pulse.ar(freq * LFNoise2.ar(1,\dtune.kr(0.01),1), \pwidth.kr(0.5));
			snd = snd + temp;
		});

		// Filter
		snd = LPF.ar(snd, \cutoff.kr(3000));

		// Envelope
		ampEnv = Env.adsr(
			\atk.ir(0.01),
			\dec.ir(0.3),
			\sus.ir(0.5),
			\rel.ir(0.5),
			\peak.ir(1)
		).ar(Done.freeSelf, \gate.kr(1));

		// Amplitude
		snd = snd * ampEnv * -17.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

		// Pan
		snd = Pan2.ar(snd, \pan.kr(0));

		// Output
		Out.ar(\out.kr(~bus_master), snd);
	}).add;

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
		env = Env.perc(\atk.ir(0.01), \rel.ir(0.25)).ar(Done.freeSelf, gate: \gate.kr(1));

		// Amplitude
		snd = snd * env * \amp.kr(1) * -1.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Pan
		snd = Pan2.ar(snd,\pan.kr(0));

		// Output
		Out.ar(\out.kr(~bus_reverb), snd);
	};
	).add;

	"setup complete!".postln;
});
)
