s.options.numOutputBusChannels = 8;
s.boot;
s.reboot;
s.meter;

// Do iterates through a collection. It always returns the collection as well.

(
[6,4,0.5,10,7].do{
	arg item, count;
	[count, item.squared].postln;
}
)

// Collect to return modified values

(
z = [6,4,0.5,10,7].collect{
	arg item;
	item.squared;
}
)

// Compact notation

(
z = [6,4,0.5,10,7].collect(_.squared);
)

// int.do
5.do{arg item; item.postln};

// ---
// Iterative Snythesis
// ---

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;

(
SynthDef.new(\iter, {
	arg freq = 40;
	var temp, sum, env;
	env = EnvGen.kr(
		Env.perc(0.01, 3, 1, -2),
		doneAction:2
	);
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99,1.02)}!2,
			{Rand(0.0,1.0)}!2,
			{ExpRand(0.005,0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);
}).add;
)

(
Synth.new(\iter, [\freq, 60.midicps]);
Synth.new(\iter, [\freq, 64.midicps]);
Synth.new(\iter, [\freq, 67.midicps]);
Synth.new(\iter, [\freq, 71.midicps]);
)

// Another example

(
SynthDef.new(\iter2, {
	arg freq = 200, dev=1.02;
	var temp, sum;
	sum = 0;
	10.do {
		arg count;
		// add a harmonic partial to the sound
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			// randomize partial frequency slightly
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(0.98,1.02)
		);
		// randomize amplitude slightly of each partial
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01,1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2)
x.set(\freq, 50);

