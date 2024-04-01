s.boot;


// Envelopes
// EnvGen is a complex way of making envelopes

(
x = {
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0,1,0.2,0],
		[0.5,1,2],
		[3,-3,0]),
	doneAction:2);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)

// gate is used to reset the envelopoe
// t_ makes gate a trigger argument: if you set t_gate equal to 1, it will automatically return to 0 on the next control sample

(
x = {
	arg t_gate=1;
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0,1,0.2,0],
		[0.5,1,2],
		[3,-3,0]),
	t_gate, doneAction:0);
	sig = Pulse.ar(ExpRand(30,500)) * env;
}.play;
)

x.set(\t_gate, 1);

// ADSR Envelope

(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(1,0.3,0.5,1.0), gate);
	sig = VarSaw.ar(SinOsc.kr(2).range(500,1000)) * env;
}.play;
)

x.set(\gate, 1)
