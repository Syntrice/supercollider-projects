(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
p = Pbind(
	\type, \note, // event type: this is the default
	\instrument, \sine,
	\dur, Pseq([0.8,0.7,0.6,0.5,0.4,0.3,0.4,0.5,0.6,0.7,0.8], inf),
	\freq, Pseq([330, 247, 370, 220], inf)
).play;
)


// Note that in the arguments listed in the PBind help file, you should implement these accordingly into the synth as they have convenience functions (e.g. to convert from midinote to freq

(
p = Pbind(
	\type, \note, // event type: this is the default
	\instrument, \sine,
	\dur, Pseq([0.6,0.15,0.15], inf),
	\freq, Pseq([330, 247, 370, 220], inf)
).play;
)

// Random values

(
p = Pbind(
	\type, \note, // event type: this is the default
	\instrument, \sine,
	\dur, Pwhite(0.05,0.5,inf),
	\midinote, 33,
	\harmonic, Pexprand(1,80,inf).round.trace, // create harmonics from midi note
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0,10.0, inf),
	\amp, Pkey(\harmonic).reciprocal * 0.3, //Pkey allows backwards access to other values in the Pbind or pattern
	\pan, Pwhite(-0.8, 0.8, inf),

).play;
)

// Manipulating patterns while they are running by enclosing in a Pdef
(
Pdef(\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(0.05,0.5,inf),
		\midinote, Pseq([
			Pn(36,30),
			Pn(48,30),
			Pn(30,30)]
		),
		\harmonic, Pexprand(1,80,inf).round.trace,
		\atk, Pwhite(2.0, 3.0, inf),
		\rel, Pwhite(5.0,10.0, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).play;
)



