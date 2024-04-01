s.options.numOutputBusChannels = 8;
s.reboot;
s.meter;

// send audio to left and right channels
x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play;

x.free;

// does same thing
x = {SinOsc.ar([300,500])}.play;

// Modulating in different channels:
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,3]).range(0,1);
	sig = SinOsc.ar([300,500,200]);
	sig = sig * amp;
}.play;
)

// Mixing down into two identical channels
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,3,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300,500,700,900,1100]);
	sig = sig * amp;
	Mix.new(sig)!2 * 0.25 // use !2 as a shortcut for the dup method, creating an array
}.play;
)

// Mixing down into two channels using splay across stereo field
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,3,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300,500,700,900,1100]);
	sig = sig * amp;
	Splay.ar(sig) * 0.5 // use !2 as a shortcut for the dup method, creating an array
}.play;
)

// Same thing as a SynthDef
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7,1,3,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300,500,700,900,1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.5; // use !2 as a shortcut for the dup method, creating an array
	Out.ar(0, sig);
}).add;
)
x = Synth.new(\multi);

// UGen duplication:
// Basically, depending on where you put the duplication, different objects will be duplicated and have different results

x = {PinkNoise.ar(0.5)!2}.play;
x = {PinkNoise.ar(0.5!2)}.play;

rrand(50,1200)!4; // array of 4 of the same random numbers
{rrand(50,1200)}!4; // function carried out 4 times, so 4 different random numbers


// Randomization example using duplication:
// uses duplication to generate random amplitude frequencies and pitch frequencies
// exprand is not the best choice for SynthDef as the random values are fixed when the synth def is declared
// instead, ExpRand chooses values when the synth is created rather than at decleration
// Lots more multichannel ugens to look at the docs
(
SynthDef.new(\multi, {
	var sig, amp, env;
	env = EnvGen.kr(
		Env.new([0,1,0],[5,5],[1,-1]),
		doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!8);
	sig = sig * amp * env;
	sig = Splay.ar(sig) * 0.5; // use !2 as a shortcut for the dup method, creating an array
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
	