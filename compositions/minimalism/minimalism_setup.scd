// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
s.options.numAudioBusChannels = 128;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
Server.default.reboot;"D:/Development/Supercollider/wind_modeling.scd";
MIDIClient.init;
MIDIIn.connectAll;
)

// Master Bus Setup

~masterBus = Bus.audio(s, 2);

(
SynthDef(\master, {
	arg in, out=0;
	var sig;
	sig = In.ar(in,2);
	sig = Limiter.ar(sig, -6.dbamp);


	Out.ar(out,sig);
}).add;

m = Synth.new(\master, [\in, ~masterBus], s, \addToTail);
)

// Synths

(
SynthDef(\basic, {
	var snd, env, freq;
	freq = \freq.kr(440);
	snd = Pulse.ar(freq);
	env = Env.adsr().ar(Done.freeSelf, \gate.kr(1));
	snd = snd * env * -3.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

	Out.ar(\out.kr(~masterBus), snd)
}).add;
)

(
SynthDef(\sine, {
	var send, ampEnv, temp, gen, freq;

	// Signal
	freq = \freq.kr(440);
	send = 0;
	4.do({
		arg i;
		temp = SinOsc.ar(
			freq *
			LFNoise2.kr(1,\dtune.kr(0.01),1) //*
			//LFTri.kr(LFNoise2.kr(4,0.5,\vib_rate.kr(4)),0.0,\vib_mag.kr(0.01),1)
		);
		send = send + temp;
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
	send = send * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

	// Pan
	send = Pan2.ar(send, \pan.kr(0));

	// output
	Out.ar(\out.kr(~masterBus), send);
}).add;
)

(
SynthDef(\strings, {
	var send, ampEnv, temp, gen;

	// create ADSR envelope
	ampEnv = Env.adsr(
			\atk.ir(3),
			\dec.ir(3),
			\sus.ir(0.8),
			\rel.ir(5),
			\peak.ir(1)
	).ar(Done.freeSelf, \gate.kr(1));

	// create signal generators
	send = 0;
	4.do({
		arg i;
		temp = LFSaw.ar(\freq.kr(440) *
			LFNoise2.ar(1,\dtune.kr(0.01),1) //*
			//LFTri.kr(LFNoise2.kr(4,0.5,\vib_rate.kr(4)),0.0,\vib_mag.kr(0.01),1)
		);
		send = send + temp;
	});

	// Amplitude
	send = send * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

	// Pan
	send = Pan2.ar(send, \pan.kr(0));

	// Filter
	send = LPF.ar(send, \cutoff.kr(4000));

	// output
	Out.ar(\out.kr(0), send);
}).add;
)

// MIDI Input (for testing)
(
~notes = Array.newClear(128);

MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\sine,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1,127,0.1,1),
			\gate, 1
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


