(

// --- Global Parameters ---

~tempo = 120;
~signiture = 3.5;
~record = false;

// These probalities control which chord follows the previous chord
~weights = [

	70, // hexatonic forward major
	70, // hexatonic forward minor
	10, // hexatonic backward major
	10, // hexatonic backward minor
	50, // dominant major
	50, // dominant minor
	10, // subdominant major
	10, // subdominant minor
	20,  // parallel

].normalizeSum;

// --- Setup ---

"minimalism_setup.scd".loadRelative;

// Dictionary of all the chords used in the piece
~chords = Dictionary[
	\C -> [0,4,7,11], //C
	\Cm -> [0,3,7,10], //C
	\Ds -> [2,3,7,10], //D#
	\Dsm -> [1,3,6,10], //D#
	\Fs -> [5,6,10,13], //F#
	\Fsm -> [4,6,9,13], //F#
	\A -> [4,8,9,13], // A
	\Am -> [4,9,7,12], // A

	\Cs -> [0,1,5,8], // C#
	\Csm -> [1,4,8,11], // C#
	\E -> [3,4,8,11], // E
	\Em -> [2,4,7,11], // E
	\G -> [2,6,7,11], // G
	\Gm -> [2,5,7,10], // G
	\As -> [2,5,9,10], // A#
	\Asm -> [1,5,8,10], // A#

	\D -> [1,2,6,9], // D
	\Dm -> [0,2,5,9], // D
	\F -> [0,4,5,9], // F
	\Fm -> [0,3,5,8], // F
	\Gs -> [0,3,7,8], // G#
	\Gsm -> [3,6,8,11], // G#
	\B -> [3,6,10,11], // B
	\Bm -> [2,6,9,11], // B
];

// just a mapping of which note in each array is the root of the chord
~roots = Dictionary[
	\C -> 0, //C
	\Cm -> 0, //C
	\Ds -> 1, //D#
	\Dsm -> 1, //D#
	\Fs -> 1, //F#
	\Fsm -> 1, //F#
	\A -> 2, // A
	\Am -> 1, // A

	\Cs -> 1, // C#
	\Csm -> 0, // C#
	\E -> 1, // E
	\Em -> 1, // E
	\G -> 2, // G
	\Gm -> 2, // G
	\As -> 3, // A#
	\Asm -> 3, // A#

	\D -> 1, // D
	\Dm -> 1, // D
	\F -> 2, // F
	\Fm -> 2, // F
	\Gs -> 3, // G#
	\Gsm -> 2, // G#
	\B -> 3, // B
	\Bm -> 3, // B
];

// A Markov set mapping the weights onto different chords
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


// This Pdef is used to iterate through the states, and collect relevant information for performance
~chord_state = \C;

// A dictionary of performance events
~events = Dictionary()

.add(\begin_pm -> {

	Pbindef(\pm,
		\instrument, \perc,
		\dur, Pwhite(0.5,2,inf),
		\freq, 1000,
		\rel, 0.1,
		\legato, 0.01,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);

	\begin_pm.postln;
})

.add(\begin_pl -> {

	Pbindef(\pl,
		\instrument, \perc,
		\dur, Pwhite(1,3,inf).round(0.5),
		\freq, 500,
		\rel, 0.1,
		\legato, 0.01,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);

	\begin_pl.postln;
})

.add(\begin_ph -> {
	Pbindef(\ph,
		\instrument, \perc,
		\dur, Pwhite(0.5,1.5,inf).round(0.5),
		\freq, 1500,
		\rel, 0.1,
		\legato, 0.01,
		\amp, Pwhite(0.06,0.175),
		\out, ~bus_reverb,
	).play(t, quant: 3.5);


	\begin_ph.postln;
})

.add(\begin_ch -> {

	Pdef(\data, Pbind(
		\type, \rest,
		\dur, Pwhite(5,10),
		\scale, Pfunc({ |ev|
			~chord_state = m.next(~chord_state);

			("State: " ++ ~chord_state).postln;

			~chords[~chord_state];
		}),
		\bass, Pfunc({
			~roots[~chord_state];
		}),
	).collect({|ev| ~data_ev = ev; ~data_ev.postln;})
	).play(t, quant: [7, 0, 0.05]);

	Pbindef(\ch,
		\instrument, \sine,
		\dur, Pfunc({~data_ev[\dur]}),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, [0,1,2,3]-2,
		\atk, 4,
		\rel, 2.5,
		\amp, 0.125,
		\legato, 0.6,
		\out, ~bus_master,
	).play(t, quant: 7);

	\begin_ch.postln;
})

.add(\unify_pm -> {

	Pbindef(\pm).quant = 7;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(4,7,4,0),
			Pbjorklund2(6,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],4),
			Pseq([0.1,0.175,0.1,0.175],4),
		],inf);
	);

	Pbindef(\pm).reset;

	\unify_pm.postln;
})

.add(\unify_pl -> {

	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(4,14,2,0),
			Pbjorklund2(6,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],2),
			Pseq([0.1,0.175,0.1,0.175],2),
		],inf);
	);

	Pbindef(\pl).reset;

	\unify_pl.postln;
})

.add(\unify_ph -> {


	Pbindef(\ph).quant = 7;

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(4,7,4,2),
		Pbjorklund2(6,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1],4),
			Pseq([0.1,0.175,0.1,0.175],4),
		],inf);
	);

	Pbindef(\ph).reset();

	\unify_ph.postln;
})

.add(\unify_ch -> {

	Pbindef(\ch).stop;
	Pdef(\data).stop;

	Pdef(\data).reset();
	Pbindef(\ch).reset();

	Pdef(\data, Pbind(
		\type, \rest,
		\dur, 7,
		\scale, Pfunc({ |ev|
			~chord_state = m.next(~chord_state);

			("State: " ++ ~chord_state).postln;

			~chords[~chord_state];
		}),
		\bass, Pfunc({
			~roots[~chord_state];
		}),
	).collect({|ev| ~data_ev = ev; ~data_ev.postln;})
	).play(t, quant: [7, 0, 0.05] );

	Pbindef(\ch, \dur, 7).play(t, quant: 7);

	\unify_ch.postln;
})



.add(\begin_bass1 -> {
	Pbindef(\bass1,
		\instrument, \saw,
		\dur, Pseq([3,3,3,2,2,1],inf) / 2,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, Pseq([0.15,0.1,0.1,0.15,0.1,0.15],inf),
		\ctranspose, -24,
		\pan, Pseg([-0.5,0.5,-0.5],[7,7],repeats: inf),
		\rel, 0.5,
	).play(t, quant: 7);
})

.add(\ch_loatkrel -> {
	Pbindef(\ch,
		\atk, 1,
		\rel, 2,
		\amp, 0.125,
		\legato, 0.4,
	)
})

.add(\begin_bchordm -> {

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Prand([0.5,1,1.5],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	).play(t, quant: 7);

	\begin_bchordm.postln;
})

.add(\begin_bchordl -> {

	Pbindef(\bchordl,
		\instrument, \sine,
		\dur, 1,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) -3,
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	).play(t, quant: 7);

	\begin_bchordl.postln;
})

.add(\bchordm_regular -> {

	Pbindef(\bchordm).quant = 7;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, 1/2,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordm_regular.postln;
})

.add(\bchordm_contour -> {

	Pbindef(\bchordm).quant = 7;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, 1/2,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordm_contour.postln;
})

.add(\pm_change1 -> {
	Pbindef(\pm).quant = 7;

	Pbindef(\pm,
		\dur, Pseq([
			Pbjorklund2(5,7,4,0),
			Pbjorklund2(7,7,4,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.1,0.175,0.175],4),
		],inf);
	);

	Pbindef(\pm).reset;

	\pm_change1.postln;
})

.add(\ph_change1 -> {
	Pbindef(\ph).quant = 7;

	Pbindef(\ph,
		\dur, Pseq([
		Pbjorklund2(5,7,4,2),
		Pbjorklund2(6,7,4,2),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1],4),
			Pseq([0.1,0.175,0.1,0.175,0.175],4),
		],inf);
	);

	Pbindef(\ph).reset;
	\ph_change1.postln;
})

.add(\pl_change1 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pseq([
			Pbjorklund2(8,14,2,0),
			Pbjorklund2(10,14,2,0),
		],inf) / 2,

		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175,0.1,0.175],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1,0.175,0.1],2),
		],inf);
	);

	Pbindef(\pl).reset;
	\pl_change1.postln;
})

.add(\begin_pll -> {

	Pbindef(\pll,
		\instrument, \perc,
		\dur, Pseq([
			Pbjorklund2(8,14,inf,4),
			Pbjorklund2(10,14,inf,4),
		],inf) / 2,

		\freq, 200,
		\rel, 0.5,
		\amp, Pseq([
			Pseq([0.175,0.1,0.175,0.1,0.1,0.175,0.1,0.175],2),
			Pseq([0.1,0.175,0.1,0.175,0.175,0.1,0.175,0.1],2),
		],inf) * 1.5,
		\band_width, 5,
		\out, ~bus_reverb,
		\legato, 0.1,
	).play(t, quant: 7);


	\begin_pll.postln;
})

.add(\begin_drum -> {

	Pbindef(\drum,
		\instrument, \perc,
		\dur, 1/2,
		\freq, 2000,
		\rel, Pseq([Pseq([0.3,0.125],6),Pseq([0.125,0.3],6)],inf),
		\band_width, 1000,
		\amp, Pseq([Pseq([0.1,0.05],6),Pseq([0.05,0.1],6)],inf),
		\out, ~bus_reverb,
		\legato, 0.1,
	).play(t, quant: 7);

	\begin_drum.postln;
})

.add(\begin_bchordh -> {

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/3,
		\scale, Pfunc({~data_ev[\scale]}),
		\atk, 0.01, \rel, 0.5,
		\degree, Pxrand([0,1,2,3],inf) + 8,
		\amp, Pseq([0.125,0.08,0.07],inf),
		\pan, Pseg([-0.5,0.5,-0.5],[7,7],repeats: inf),
	).play(t, quant: 7);

	\begin_bchordh.postln;
})

.add(\begin_bass2 -> {

	Pbindef(\bass2,
		\instrument, \saw,
		\dur, Pseq([Rest(2),5],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, 0.15,
		\ctranspose, -12,
		\pwidth, 0.8,
		\rel, 0.5,
		\atk, 0.5
	).play(t, quant: 7);

	\begin_bass2.postln;
})

.add(\bchordh_faster -> {

	Pbindef(\bchordh).quant = 7;

	Pbindef(\bchordh,
		\instrument, \sine,
		\dur, 1/4,
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pxrand([0,1,2,3],inf) + 8,
		\amp, Pseq([0.125,0.08,0.07,0.06],inf),
		\pan, Pseg([-0.5,0.5,-0.5],[7,7],repeats: inf),
	);

	Pbindef(\bchordh).reset();

	\begin_bchordh.postln;
})

.add(\begin_melup -> {

	Pbindef(\melup,
		\instrument, \saw,
		\dur, Pseq([Rest(3),4],inf),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pfunc({~data_ev[\bass]}),
		\amp, 0.09,
		\pwidth, 0.8,
		\ctranspose, 12,
		\cutoff, 2000,
		\rel, 0.5,
		\atk, 0.5,
	).play(t, quant: 7);

	\begin_melup.postln;
})

.add(\pm_change2 -> {
	Pbindef(\pm).quant = 7;

	Pbindef(\pm,
		\dur, Pbjorklund2(6,7,inf,1) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\pm).reset;

	\pm_change2.postln;
})

.add(\ph_change2 -> {
	Pbindef(\ph).quant = 7;

	Pbindef(\ph,
		\dur, Pbjorklund2(6,7,inf,2) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\ph).reset;
	\ph_change2.postln;
})

.add(\pl_change2 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pbjorklund2(11,14,inf,1) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\pl).reset;
	\pl_change2.postln;
})

.add(\pm_change3 -> {
	Pbindef(\pm).quant = 7;

	Pbindef(\pm,
		\dur, Pbjorklund2(3,7,inf,1) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\pm).reset;

	\pm_change3.postln;
})

.add(\ph_change3 -> {
	Pbindef(\ph).quant = 7;

	Pbindef(\ph,
		\dur, Pbjorklund2(3,7,inf,2) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\ph).reset;
	\ph_change3.postln;
})

.add(\pl_change3 -> {
	Pbindef(\pl).quant = 7;

	Pbindef(\pl,
		\dur, Pbjorklund2(6,14,inf,1) / 2,
		\amp, Pseq([0.175,0.1,0.1,0.15,0.1,0.15,0.1,0.1],inf)
	);

	Pbindef(\pl).reset;
	\pl_change3.postln;
})

.add(\bchordm_nonreg -> {

	Pbindef(\bchordm).quant = 7;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Pbjorklund2(8,14,inf,1),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordm_nonreg.postln;
})


.add(\bchordl_nonreg -> {

	Pbindef(\bchordm).quant = 7;

	Pbindef(\bchordm,
		\instrument, \sine,
		\dur, Pbjorklund2(8,14,inf,4),
		\scale, Pfunc({~data_ev[\scale]}),
		\degree, Pseq([0,2,1,3,2,4,3],inf) + Pseq([Pn(0,14),Pn(1,14),Pn(2,14),Pn(3,14)],inf),
		\amp, Pseq([0.2,0.125,0.2,0.125,0.2,0.125,0.125],inf),
		\pan, Pseq([-0.5,0.5],inf)
	);

	Pbindef(\bchordm).reset();

	\bchordl_nonreg.postln;
})

.add(\stop_bchordh -> {
	t.play({Pbindef(\bchordh).stop}, quant: 3.5);
	\stop_fast_bc.postln;
})

.add(\stop_ph -> {
	t.play({Pbindef(\ph).stop}, quant: 3.5);
	\stop_ph.postln;
})

.add(\stop_pm -> {
	t.play({Pbindef(\pm).stop}, quant: 3.5);
	\stop_pm.postln;
})

.add(\stop_pl -> {
	t.play({Pbindef(\pl).stop}, quant: 3.5);
	\stop_pl.postln;
})

.add(\stop_drum -> {
	t.play({Pbindef(\drum).stop}, quant: 3.5);
	\stop_drum.postln;
})

.add(\stop_bass1 -> {
	t.play({Pbindef(\bass1).stop}, quant: 3.5);

	\stop_bass1.postln;
})

.add(\stop_bass2 -> {
	t.play({Pbindef(\bass2).stop}, quant: 3.5);

	\stop_bass2.postln;
})

.add(\stop_bchordl -> {
	t.play({Pbindef(\bchordl).stop}, quant: 3.5);

	\stop_bchordl.postln;
})

.add(\stop_melup -> {
	t.play({Pbindef(\melup).stop}, quant: 3.5);

	\stop_melup.postln;
})

.add(\stop_ch -> {

	t.play({Pbindef(\ch).stop}, quant: 3.5);

})

.add(\stop_pll -> {

	t.play({Pbindef(\pll).stop}, quant: 3.5);

})


.add(\stop_bchordm -> {

	t.play({Pbindef(\bchordm).stop}, quant: 3.5);


	\stop_bchordm.postln;
})

.add(\data_stop -> {
	t.play({Pdef(\data).stop}, quant: 3.5);

})

;

~piece = Routine({
	"playing".postln;
	~events[\begin_pm].fork;
	(3.5 * 2).wait;
	~events[\begin_pl].fork;
	(3.5 * 2).wait;
	~events[\begin_ph].fork;
	(3.5 * 4 - 0.5).wait;
	~events[\begin_ch].fork;
	(3.5 * 2 + 0.5).wait;
	~events[\unify_pm].fork;
	(3.5 * 2).wait;
	~events[\unify_pl].fork;
	(3.5 * 2).wait;
	~events[\unify_ph].fork;
	(3.5 * 2).wait;
	~events[\unify_ch].fork;
	(3.5 * 9).wait;
	~events[\begin_bass1].fork;
	~events[\ch_loatkrel].fork;
	(3.5 * 8).wait;
	~events[\begin_bchordm].fork;
	(3.5 * 4).wait;
	~events[\begin_bchordl].fork;
	(3.5 * 4).wait;
	~events[\bchordm_regular].fork;
	(3.5 * 2).wait;
	~events[\ph_change1].fork;
	(3.5  * 2).wait;
	~events[\pm_change1].fork;
	(3.5 * 2).wait;
	~events[\pl_change1].fork;
	(3.5 * 2).wait;
	~events[\bchordm_contour].fork;
	(3.5 * 2).wait;
	~events[\begin_pll].fork;
	(3.5 * 2).wait;
	~events[\begin_bchordh].fork;
	(3.5 * 4).wait;
	~events[\begin_drum].fork;
	(3.5 * 4).wait;
	~events[\begin_bass2].fork;
	~events[\begin_melup].fork;
	(3.5 * 4).wait;
	~events[\ph_change2].fork;
	(3.5  * 2).wait;
	~events[\pm_change2].fork;
	(3.5 * 2).wait;
	~events[\pl_change2].fork;
	(3.5 * 8).wait;
	~events[\stop_bchordh].fork;
	(3.5 * 2).wait;
	~events[\ph_change3].fork;
	(3.5  * 2).wait;
	~events[\pm_change3].fork;
	(3.5 * 2).wait;
	~events[\pl_change3].fork;
	(3.5 * 2).wait;
	~events[\stop_ph].fork;
	(3.5 * 2).wait;
	~events[\stop_pm].fork;
	(3.5 * 2).wait;
	~events[\stop_pl].fork;
	(3.5 * 2).wait;
	~events[\bchordm_nonreg].fork;
	(3.5 * 1).wait;
	~events[\bchordl_nonreg].fork;
	(3.5 * 1).wait;
	~events[\stop_drum].fork;
	(3.5 * 2).wait;
	~events[\stop_pll].fork;
	(3.5 * 2).wait;
	~events[\stop_bass1].fork;
	(3.5 * 2).wait;
	~events[\stop_bass2].fork;
	~events[\stop_melup].fork;
	(3.5 * 4).wait;
	~events[\stop_bchordl].fork;
	(3.5 * 4).wait;
	~events[\stop_ch].fork;
	(3.5 * 8).wait;
	~events[\stop_bchordm].fork;
	~events[\data_stop].fork;
});
)

(
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
Pdef.removeAll;
Pbindef.removeAll;
~data_ev = nil;
~piece.reset;
~piece.play(t, quant: [7]);
)

// fix overlapping chord issue
// chord too loud in comparison with percussion
// bass too loud also
// bchord regular too much delay after,
// bchord hi too loud
// delay is weird here
// melup and bass2 are too loud
// fix timing being off
// add stop_pll