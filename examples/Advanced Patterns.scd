(
SynthDef(\tone, {
	var sig, env;
	env = Env.adsr(
		\atk.ir(0.001), \dec.ir(0.2), \slev.ir(0.4), \rel.ir(0.3)
	).ar(Done.freeSelf, \gate.kr(1));
	sig = LFTri.ar(\freq.kr(880));
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth(\tone);
x.set(\gate, 0);

(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([5,7,8,9], inf),
);

x = p.play;
)

x.stop;

// (1) Tempo / Quantization

t = TempoClock.new(112/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(3)});

// change time signiture mid running
t.schedAbs(t.nextBar, { t.beatsPerBar_(4) });

// change tempo mid running

t.schedAbs(t.nextBar, { t.tempo_(80/60) });

// gradual tempo change (target tempo, duration to change)
// create a function as follows

(
~tempoChange = {
	arg clock, newTempo, numBeats;
	var i = 0, tempoArray;
	tempoArray = Array.interpolation(numBeats, clock.tempo, newTempo/60);
	clock.schedAbs(clock.nextBar, {
		clock.tempo_(tempoArray[i]);
		i = i + 1;
		if(i < numBeats) {1} {\done.postln};
	});
};
)

~tempoChange.(t, 112, 4);

(
~post = { t.beats.postln; 1; };
t.schedAbs(t.nextBar, { ~post.() });
)

t.beats;
t.nextBar;

t.stop;

// syncing two patterns using quantization and phase
// Quant is the target, phase is the offset
(
p = Pbind(
	\instrument, \tone,
	\dur, 0.5,
	\degree, Pseq([5,7,8,9,8s,9], inf),
);

y = p.play(t, quant: Quant(4));
)

(
q = Pbind(
	\instrument, \tone,
	\dur, 3/2,
	\degree, Pseq([0,1], inf),
);

y = q.play(t, quant: Quant(4));
)

x.stop;

// (2) \sustain and \legato

// (4) Constraint patterns


