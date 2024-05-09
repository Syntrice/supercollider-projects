// "Autogenous"
// Made with Supercollider 3.13.0

/*
This file contains setup code for the composition "Autogenous". It should not be run directly, but placed in the same folder as autogenous.scd, and will be run automatically when executing the setup code.
*/

(

if (s.serverRunning.not, {
	"booting server".postln;
	o = Server.default.options;
	o.device = ~audio_device;
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

	// Master
	SynthDef(\master, {
		arg in;
		var snd;

		snd = In.ar(in, 2);
		snd = snd * 6.dbamp;
		snd = Limiter.ar(snd, -3.dbamp); // limiter for a clipping failsafe

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

	"setting up sound synths".postln;

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
		snd = snd * ampEnv * -13.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

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
		snd = snd * ampEnv * -7.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

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
		snd = snd * env * \amp.kr(1) * 0.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

		// Pan
		snd = Pan2.ar(snd,\pan.kr(0));

		// Output
		Out.ar(\out.kr(~bus_reverb), snd);
	};
	).add;


	"setting up recording functions".postln;

	// Functions to start and stop recording

	~startRecording = {

			~stereo_recorder = Recorder(s);
			~stereo_recorder.filePrefix = "AUTOGENOUS_";
			~stereo_recorder.record(bus: ~bus_stereo_record, numChannels: 2);
	};

	~stopRecording = {
		~stereo_recorder.stopRecording;
	};

	"initial setup complete!".postln;
});
)
