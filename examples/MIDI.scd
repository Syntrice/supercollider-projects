ServerOptions.devices;
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;

MIDIClient.init;

// connect to all midi devices
MIDIIn.connectAll;

// create mididef
MIDIdef.noteOn(\noteOnTest, {"key down".postln});

// command + period wont remove mididef
MIDIdef.noteOn(\noteOnTest, {"key down".postln}).permanent_(true);

// disable
MIDIdef(\noteOnTest).disable;

// enable
MIDIdef(\noteOnTest).enable;

// free
MIDIdef(\noteOnTest).free;
MIDIdef.freeAll;


// playing sound with midi: simple method

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	{
		var sig, env;
		sig = LFTri.ar(nn.midicps)!2;
		env = EnvGen.kr(Env.perc, doneAction:2);
		sig = sig * env * vel.linexp(1,127,0.01,0.3);
	}.play;
});
)

// playing sound with midi: synthdef

(
SynthDef.new(\tone, {
	arg freq = 440, amp = 0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

(
SynthDef(\strings, {
	var sig, env, temp;
	env = Env.adsr(
		\atk.ir(2),
		\dec.ir(0.5),
		\slev.ir(0.8),
		\rel.ir(0.4)
	).ar(Done.freeSelf, \gate.kr(1));
	sig = 0;
	8.do({
		arg count;
		temp = Saw.ar(\freq.kr(440) + Rand(-1.2,1.2));
		temp = Pan2.ar(temp, (count/7 * 2) + -1, \amp.kr(0.3)) * env;
		sig = sig + temp;
	});
	sig = LPF.ar(sig, \cutoff.ir(4000));
	Out.ar(\out.kr(0), sig);
}).add;
)

(
SynthDef.new(\reverb, {
	arg in = 6, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig,0.5,0.8,0.2);
	Out.ar(out, sig);
}).add;
)

~reverbBus = Bus.audio(s,2);
~srcgrp = Group.new;
~fxgrp = Group.after(~sourceGrp);

~reverb = Synth.new(\reverb, [\in, ~reverbBus], ~fxgrp);




~notes = Array.newClear(128);

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\strings,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1,127,0.01,0.3),
			\gate, 1,
			\out, ~reverbBus,
			\cutoff, 2000
		],
		~srcgrp
	);
});
)

(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});
)



