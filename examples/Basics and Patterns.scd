// ----
// Some basics
// ----

// start server
Server.default = s = Server.internal.boot

{SinOsc.ar(LFNoise0.kr(10).range(500, 1500), mul: 0.1)}.play;
{RLPF.ar(Dust.ar([5, 10]), LFNoise1.ar([1, 2]).range(100, 3000), 0.02)}.play;

// repeat multiple times
100.do({"Print this line over and over...".scramble.postln});


// ----
// Patterns
// ----


// Pbind examples

Pbind(\degree, Pseries(0, 1, 30), \dur, 0.05).play;

Pbind(\degree, 0, \dur, 0.5).play;

Pbind(\degree, Pseq([0,1,2,3,4,5,6,7]),\dur, 0.5).play;

Pbind(\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 5/*play five times*/), \dur, Pseq([0.2, 0.1, 0.1, 0.2, 0.2,0.35], inf)).play;

Pbind(\degree, Pseq([0,3,5,7,5,3], inf), \dur, Pseq([0.2,0.5,0.1,0.8],inf)).play;

// more readible syntax

(
Pbind(
\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 5),
\dur, Pseq([0.2, 0.1, 0.1, 0.2, 0.2, 0.35], inf)
).play;
)

// Different ways of specifying pitch types: all play the same middle C

Pbind(\degree, 5).play;
Pbind(\note, 9).play;
Pbind(\midinote, 69).play;
Pbind(\freq, 440).play;

// Specify amp and legato
(
Pbind(
\degree, Pseq([0, −1, 2, −3, 4, −3, 7, 11, 4, 2, 0, −3], 5),
\dur, Pseq([0.2, 0.1, 0.1], inf),
\amp, Pseq([0.7, 0.5, 0.3, 0.2], inf),
\legato, 0.1
).play;
)

// --
// different types of randomizaton
// --

// Randomizing from list using Prand
(
Pbind(
	\degree, Prand([2,3,4,5,6], inf),
	\dur, Prand([0.5,0.25,0.75], inf),
	\amp, Prand([0.2,0.4,0.8], inf),
	\legato, Prand([0.1,1], inf)
).play;
)

// Pwhite picks a random value in a range, from white noise distribution
// For integers, add a decimal place to also generate to that number of decimal places
(
Pbind(
\freq, Pwhite(100, 500),
\dur, Prand([0.15, 0.25, 0.3], inf),
\amp, 0.2,
\legato, 0.3
).trace.play;
)

// Iterate through 11 numbers of the list
(
Pbind(
	\note, Pser([0,2,3,5,7,8,11,12],11),
	\dur, 0.15;
).play;
)

// Pxrand never repeats same element twice in a row
(
p = Pbind(
	\note, Pxrand([0,2,3,5,7,8,11,12], inf),
	\dur, 0.15;
).play;
)


// Pshuf shuffles a list and repeats n times
(
p = Pbind(
\note, Pshuf([0, 2, 3, 5, 7, 8, 11, 12], 6),
\dur, 0.15;
).play;
)

// Pslide
// Takes 4 arguments: list, repeats, length, step
// Iterates through list in sequence, breaking into segments and stepping through list
(
Pbind(
\note, Pslide([0, 2, 3, 5, 7, 8, 11, 12], 7, 3, 1),
\dur, 0.15;
).play;
)

// Pseries
// Takes three arguments: start, step, length
// gives linearly spaced series of integers
(
Pbind(
\note, Pseries(0, 2, 15),
\dur, 0.15;
).play;
)

// Pgeom
// Takes three arguments: start, grow, length
// gives geometrically spaced series of integers
(
Pbind(
\note, Pseq([0, 2, 3, 5, 7, 8, 11, 12], inf),
\dur, Pgeom(0.1, 1.1, 25);
).play;
)

// Pn
// simple way to repeat a pattern n times
(
Pbind(
\note, Pseq([0, Pn(2, 3), 3, Pn(5, 3), 7, Pn(8, 3), 11, 12], 1),
\dur, 0.15;
).play;
)
