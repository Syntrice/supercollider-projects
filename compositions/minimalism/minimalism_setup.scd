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

	4.do({
		arg i;
		temp = SinOsc.ar(
			freq * 2 *
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
SynthDef(\tap, {
	var snd, env, temp, freq;

	snd = WhiteNoise.ar();

	freq = \freq.kr(3000);

	snd = BPF.ar(snd,freq, 40/freq, 10);
	//snd = BPF.ar(snd, freq, 40/freq, 10);

	env = Env.perc(0.01, 0.25).ar(gate: \gate.kr(1));


	snd = snd * env * \amp.kr(1) * 4.dbamp;

	snd = CombC.ar(snd, 0.01, XLine.kr(0.0001, 0.01, 20), 0.2);

	snd = Pan2.ar(snd,\pan.kr(0));

	//snd = snd + (DelayC.ar(snd, 0.02, 0.02, 1) * 0.5);

	FreeSelf.kr(TDelay.kr(Done.kr(env),0.1));


	Out.ar(\out.kr(0), snd);
};
).add;
)

Synth(\tap);


(
SynthDef(\strings, {
	var send, ampEnv, temp, gen, freq;

	// Signal
	freq = \freq.kr(440);
	send = 0;
	4.do({
		arg i;
		temp = LFSaw.ar(freq *
			LFNoise2.ar(1,\dtune.kr(0.01),1) //*
			//LFTri.kr(LFNoise2.kr(4,0.5,\vib_rate.kr(4)),0.0,\vib_mag.kr(0.01),1)
		);
		send = send + temp;
	});

	// create ADSR envelope
	ampEnv = Env.adsr(
			\atk.ir(0.01),
			\dec.ir(0.3),
			\sus.ir(0.5),
			\rel.ir(0.5),
			\peak.ir(1)
	).ar(Done.freeSelf, \gate.kr(1));

	// Amplitude
	send = send * ampEnv * -12.0.dbamp * AmpComp.kr(freq) * \amp.kr(1);

	// Pan
	send = Pan2.ar(send, \pan.kr(0));

	// Filter
	send = LPF.ar(send, \cutoff.kr(2000));

	// output
	Out.ar(\out.kr(0), send);
}).add;
)

// MIDI Input (for testing)
(
~notes = Array.newClear(128);

MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn, (nn - 60)].postln;
	~notes[nn] = Synth.new(
		\strings,
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


