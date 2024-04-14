/**

Yet to be named minimalism composition is a work which is based upon the three octatonic collections,
and the chords which can be made up of the collection. The work incoporates a Markov chain which determines the chord to play next based on probability.

Currently, there is a customizable chance that a chord will progress onto a chord in the same octatonic progression, or move by dominant motion to a chord in an adjacent collection.

Currently, future ideas including more Markov controlled parameters, more specific voicing of chords, or experimenting with neo-riemannian theory further.

For example, another set of states could be used for rhythmic identity, or chord voicing, or arpeggitaion. Or any other possibility really.

**/


// Dictionary of all the chords used in the piece
(
~chords = Dictionary[
	\C -> [0,4,7,11], //C
	\Cm -> [0,3,7,10], //C
	\Ds -> [3,7,10,14], //D#
	\Dsm -> [3,6,10,13], //D#
	\Fs -> [6,10,13,17], //F#
	\Fsm -> [6,9,13,16], //F#
	\A -> [9,13,16,20], // A
	\Am -> [9,12,16,19], // A

	\Cs -> [1,5,8,12], // C#
	\Csm -> [1,4,8,11], // C#
	\E -> [4,8,11,15], // E
	\Em -> [4,7,11,14], // E
	\G -> [7,11,14,18], // G
	\Gm -> [7,10,14,17], // G
	\As -> [10,14,17,21], // A#
	\Asm -> [10,13,17,20], // A#

	\D -> [2,6,9,13], // D
	\Dm -> [2,5,9,12], // D
	\F -> [5,9,12,16], // F
	\Fm -> [5,8,12,15], // F
	\Gs -> [8,12,15,19], // G#
	\Gsm -> [8,11,15,18], // G#
	\B -> [11,15,18,22], // B
	\Bm -> [11,14,18,21], // B
];
)

(
// A Markov setup to determine probability of moving between octatonic collections

~weights = [
	70, // hexatonic forward major
	70, // hexatonic forward minor
	20, // hexatonic backward major
	20, // hexatonic backward minor
	50, // dominant major
	50, // dominant minor
	25, // subdominant major
	25, // subdominant minor
	30  // parallel
].normalizeSum;

m = MarkovSet([
	[\C, [\Ds, \Dsm, \A, \Am, \G, \Gm, \F, \Fm, \Cm], ~weights],
	[\Cm, [\Ds, \Dsm, \A, \Am, \G, \Gm, \F, \Fm, \C], ~weights],

	[\Ds, [\Fs, \Fsm, \C, \Cm, \A, \Am, \Gs, \Gsm, \Dsm], ~weights],
	[\Dsm, [\Fs, \Fsm, \C, \Cm, \A, \Am, \Gs, \Gsm, \Ds], ~weights],

	[\Fs, [\A, \Am, \Ds, \Dsm, \Cs, \Csm, \B, \Bm, \Fsm], ~weights],
	[\Fsm, [\A, \Am, \Ds, \Dsm, \Cs, \Csm, \B, \Bm, \Fs], ~weights],

	[\A, [\C, \Cm, \Fs, \Fsm, \E, \Em, \D, \Dm, \Am], ~weights],
	[\Am, [\C, \Cm, \Fs, \Fsm, \E, \Em, \D, \Dm, \A], ~weights],

	[\Cs, [\E, \Em, \As, \Asm, \Gs, \Gsm, \Fs, \Fsm, \Csm], ~weights],
	[\Csm, [\E, \Em, \As, \Asm, \Gs, \Gsm, \Fs, \Fsm, \Cs], ~weights],

	[\E, [\G, \Gm, \Cs, \Csm, \B, \Bm, \A, \Am, \Em], ~weights],
	[\Em, [\G, \Gm, \Cs, \Csm, \B, \Bm, \A, \Am, \E], ~weights],

	[\G, [\As, \Asm, \E, \Em, \D, \Dm, \C, \Cm, \Gm], ~weights],
	[\Gm, [\As, \Asm, \E, \Em, \D, \Dm, \C, \Cm, \G], ~weights],

	[\As, [\Cs, \Csm, \As, \Asm, \F, \Fm, \Ds, \Dsm, \Asm], ~weights],
	[\Asm, [\Cs, \Csm, \As, \Asm, \F, \Fm, \Ds, \Dsm, \As], ~weights],

	[\D, [\F, \Fm, \B, \Bm, \A, \Am, \G, \Gm, \Dm], ~weights],
	[\Dm, [\F, \Fm, \B, \Bm, \A, \Am, \G, \Gm, \D], ~weights],

	[\F, [\Gs, \Gsm, \D, \Dm, \C, \Cm, \As, \Asm, \Fm], ~weights],
	[\Fm, [\Gs, \Gsm, \D, \Dm, \C, \Cm, \As, \Asm, \F], ~weights],

	[\Gs, [\B, \Bm, \F, \Fm, \Ds, \Dsm, \Cs, \Csm, \Gsm], ~weights],
	[\Gsm, [\B, \Bm, \F, \Fm, \Ds, \Dsm, \Cs, \Csm, \Gs], ~weights],

	[\B, [\D, \Dm, \Gs, \Gsm, \Fs, \Fsm, \E, \Em, \Bm], ~weights],
	[\Bm, [\D, \Dm, \Gs, \Gsm, \Fs, \Fsm, \E, \Em, \B], ~weights],
]);
)


// Setup a data Pdef that will iterate through the markov chain to set chords
(
~state = \C.postln;


Pdef(\data, Pbind(
	\type, \rest,
	\dur, 8,
	\scale, Pfunc({
		~state = m.next(~state);

		// Chose either the major or minor chord - doesn't affect Markov chain
		("State: " ++ ~state).postln;

		~chords[~state].postln;
	});
).collect({ |ev| ~data_ev = ev;}));
)

// Composition Patterns
(
Pdef(\a,
	Pbind(
		\instrument, \sine,
		\dur, Pbjorklund2(5,7),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, [-4,0,1,2,3],
		\amp, 0.2,
		\pan, Pseq([-0.8,0.8],inf);
	);
);
)

(
Pdef(\b,
	Pbind(
		\instrument, \strings,
		\dur, Pbjorklund2(5,7,inf,1),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, -8,
		\amp, 0.4,
		\pan, 0,
	);
);
)

(
Pdef(\c,
	Pbind(
		\instrument, \sine,
		\dur, Pbjorklund2(5,7) / 4,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pwrand([Pseq([1,0,4,2,3,0],1),Pseq([1,0,4,2,3,0,5],1)],[10,5].normalizeSum,inf),
		\amp, 0.2,
		\mtranspose, 4,
		\pan, Pseq([-0.8,0.8],inf);
	);
);
)

(
Pdef(\metronome,
	Pbind(
		\instrument, \tap,
		\dur, 1,
		\freq, Pseq([440*3,440*2,440*2,440*2],inf),
		\amp, Pseq([0.2,0.05,0.05,0.05],inf),
	);
);
)


// Test the composition

(
~tempo = 120;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)


~state = \A;

Pdef(\metronome).play(t,quant: 4);
Pdef(\data).play(t, quant: [4,0,0.05]);
Pdef(\a).play(t, quant: 4);
Pdef(\b).play(t, quant: 4);
Pdef(\c).play(t, quant: 4);
