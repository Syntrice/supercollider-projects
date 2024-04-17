// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
s.options.numAudioBusChannels = 128;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
Server.default.reboot;


s.waitForBoot {
	MIDIClient.init;
	MIDIIn.connectAll;
};
)

(

~mixer.free; ~mixer = Group(s, \addToTail);

// --- Channels ---

// Master
SynthDef(\master, {
	arg in;
	var snd;

	snd = In.ar(in, 2);
	snd = Limiter.ar(snd, -6.dbamp);

	Out.ar(0, snd);
}).add;

~bus_master.free; ~bus_master = Bus.audio(s, 2);
~channel_master = Synth(\master, [\in, ~bus_master], ~mixer, \addToTail);

// Reverb
SynthDef(\reverb, {
	arg in;
	var snd;

	snd = In.ar(in, 2);

	snd = FreeVerb2.ar(snd[0], snd[1], \mix.kr(0.5), \room.kr(0.5), \damp.kr(0.5));

	Out.ar(0, snd);
}).add;

~bus_reverb.free; ~bus_reverb = Bus.audio(s, 2);
~channel_reverb = Synth(\reverb, [\in, ~bus_reverb], ~mixer, \addToHead);

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
	snd = snd * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

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
		temp = LFSaw.ar(freq *
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
	snd = snd * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

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
	snd = snd * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

	// Pan
	snd = Pan2.ar(snd, \pan.kr(0));

	// Output
	Out.ar(\out.kr(~bus_master), snd);
}).add;

(
SynthDef(\perc, {
	var snd, env, temp, freq, band_width;

	// Signal
	snd = WhiteNoise.ar();

	// Filter
	band_width = \band_width.kr(40);

	freq = \freq.kr(3000);
	snd = BPF.ar(snd,freq, band_width / freq, 500 * band_width.reciprocal);
	snd = LPF.ar(snd, freq);

	// Envelope
	env = Env.perc(0.01, 0.25).ar(Done.freeSelf, gate: \gate.kr(1));

	// Amplitude
	snd = snd * env * \amp.kr(1) * 0.dbamp * (100 / band_width.sqrt) * AmpComp.kr(freq);

	// Delay
	//snd = CombC.ar(snd, 0.01, XLine.kr(0.0001, 0.01, 20), 0.2);

	// Pan
	snd = Pan2.ar(snd,\pan.kr(0));

	// Free synth
	//FreeSelf.kr(TDelay.kr(Done.kr(env),1));

	// Output
	Out.ar(\out.kr(~bus_master), snd);
};
).add;
)
)

Synth(\perc, [\out, ~bus_reverb]);


// MIDI Input (for testing)
(
~notes = Array.newClear(128);

MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn, (nn - 60)].postln;
	~notes[nn] = Synth.new(
		\saw,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1,127,0.1,1),
			\gate, 1,
			\atk, 0.5,
			\rel, 0.5,
			\sus, 0.8,
			\out, ~bus_reverb,
		]
	);
}).permanent_(true);

MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn, chan, src;
	[vel, nn, (nn - 60)].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
}).permanent_(true);
)