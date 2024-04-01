s.boot;

// ----
// more pattern stuff
// ----

// Chords
// Chords can be played using comma-separated values in square brackets

(
Pbind(
	\degree, Pseq([[0,2,4],[-1,1,4]],3),
	\dur, 0.25
).play;
)

// the strum parameter arpeggiates all notes in a chord

(
Pbind(
	\degree, Pseq([[0,2,4],[-1,1,4]],3),
	\dur, 0.5,
	\legato, 0.4,
	\strum, 0.1
).play;
)

// Scales
// use the \scale parameter to change scale type when passing degrees

(
Pbind(
	\degree, Pseq([0,1,2,3,4,5,6,7],1),
	\scale, Scale.harmonicMinor,
	\dur, 0.15;
).play;
)

// to show all possible scales
Scale.directory;

// to add chromatic steps in between scale degress, use 1 decimal point (e.g. .1) to indicate one step above

// Transposition

(
Pbind(
	\degree, Pseq([0,1,2,3,4,5,6,7],1),
	\scale, Scale.harmonicMinor,
	\dur, 0.15,
	\ctranspose, 7; /*chromatic transposition*/
).play;
)

// Microtones

// Microtones with \note and \midinote:
Pbind(\note, Pseq([0, 0.5, 1, 1.5, 1.75, 2], 1)).play;
Pbind(\midinote, Pseq([60, 69, 68.5, 60.25, 70], 1)).play;

// Controlling Tempo
// use TempoClock as a argument to play
(
Pbind(\degree, Pseq([0, 0.1, 1, 2, 3, 4, 5, 6, 7]),
\dur, 1;
).play(TempoClock(120/60)); // 120 beats over 60 seconds: 120 BPM
)

// Rests
// use the Rest function
(
Pbind(
\degree, Pwhite(0, 10),
\dur, Pseq([0.1, 0.1, 0.3, 0.6, Rest(0.3), 0.25], inf);
).play;
)

// Playing multiple Pbinds
// Simultanously
(
t = TempoClock(76/60);
	Pbind(
		\note, Pseq([1,3,7],8),
		\dur, 1/4;
	).play(t);

	Pbind(
		\note, Pseq([3,6,7],16),
		\dur, 1/8;
	).play(t)
)

// Forking, i.e. playing multiple pbinds in time ordered fashion

(
t = TempoClock(76/60);
{
	Pbind(
		\note, Pseq([1,3,7],8),
		\dur, 1/4;
	).play(t);

	2.wait;

	Pbind(
		\note, Pseq([3,6,7],16),
		\dur, 1/8;
	).play(t)
}.fork(t)
)

// Ppar and Pspawner are further ways of playing Pbinds together and in sequence
