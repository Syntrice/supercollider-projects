s.boot;

// creating a synthdef with .new

(
SynthDef.new(\test, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}).store;
)

x = Synth.new(\test);
y = Synth.new(\test, [\noiseHz, 32]);

(
x.free;
y.free;
)

(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;

	amp1 = LFPulse.kr(ampHz,0,0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;

	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);

	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);

	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);

	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

x = Synth.new(\pulseTest);

s.plotTree;

// Envelopes and done action

(
x = {
	var sig, env;
	env = Line.kr(1,0,1, doneAction:2); // by adding doneAction: 2, the synth is automatically freed
	//after the envelope is finished.
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)


// Xline is more smooth, as amplitude is experience exponentially,
// However, remember that exponential curves will not intersect 0, so you have to constrain to either the positive or negative side of the axis. Line is still better if working in dBs. (convert using env.dbamp, and back into dBs using .ampdb).
(
x = {
	var sig, env;
	env = XLine.kr(1,0.01,1, doneAction:2); // by adding doneAction: 2, the synth is automatically freed
	//after the envelope is finished.
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)

(
x = {
	arg duration = 1;
	var sig, freq, env;
	env = XLine.kr(1,0.01, duration, doneAction:2);
	freq = XLine.kr(880, 110, duration, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

