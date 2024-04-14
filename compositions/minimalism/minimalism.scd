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
	\A -> [0,4,7,11], //C
	\A1 -> [0,3,7,10], //C
	\B -> [3,7,10,14], //D#
	\B1 -> [3,6,10,13], //D#
	\C -> [6,10,13,17], //F#
	\C1 -> [6,9,13,16], //F#
	\D -> [9,13,16,20], // A
	\D1 -> [9,12,16,19], // A

	\E -> [1,5,8,12], // C#
	\E1 -> [1,4,8,11], // C#
	\F -> [4,8,11,15], // E
	\F1 -> [4,7,11,14], // E
	\G -> [7,11,14,18], // G
	\G1 -> [7,10,14,17], // G
	\H -> [10,14,17,21], // A#
	\H1 -> [10,13,17,20], // A#

	\I -> [2,6,9,13], // D
	\I1 -> [2,5,9,12], // D
	\J -> [5,9,12,16], // F
	\J1 -> [5,8,12,15], // F
	\K -> [8,12,15,19], // G#
	\K1 -> [8,11,15,18], // G#
	\L -> [11,15,18,22], // B
	\L1 -> [11,14,18,21], // B
];
)

(
// A Markov setup to determine probability of moving between octatonic collections

// Weights to use [stay in octatonic, move to Dominant]
~weights = [50,50].normalizeSum;

m = MarkovSet([
	[\A, [\B, \G], ~weights],
	[\B, [\C, \H], ~weights],
	[\C, [\D, \E], ~weights],
	[\D, [\A, \F], ~weights],

	[\E, [\F, \K], ~weights],
	[\F, [\G, \L], ~weights],
	[\G, [\H, \I], ~weights],
	[\H, [\E, \J], ~weights],

	[\I, [\J, \D], ~weights],
	[\J, [\K, \A], ~weights],
	[\K, [\L, \B], ~weights],
	[\L, [\I, \C], ~weights],
]);
)

// Setup a data Pdef that will iterate through the markov chain to set chords
(
~state = \A.postln;

Pdef(\data, Pbind(
	\type, \rest,
	\dur, Pbjorklund2(3,16),
	\scale, Pfunc({
		~state = m.next(~state);

		// Chose either the major or minor chord - doesn't affect Markov chain
		("State: " ++ ~state).postln;

		[~chords[(~state ++ \1).asSymbol],~chords[~state]].choose.postln;
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
