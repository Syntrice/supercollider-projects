// Tempo Arguments
(
~tempo = 56;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

(
~melody = #[
	[64,66,75,73,68,69,71,69,71,73,68,66,75,76], // 329.64 to 659.26 hz
	[49,51,59,57,52,54,56,54,56,57,52,51,59,61] // 138.59 to 277.18
];
)

(
~events = Dictionary()
.add(\setup -> {
	Ndef(\noise_band_width, {\val.kr(200)});
	Ndef(\tapping_band_width, {\val.kr(200)});
	Ndef(\crackles_band_width, {\val.kr(200)});
	Ndef(\melody_amp, {\val.kr(0.2)});
})

.add(\noise_mid_start -> {

	Pbindef(\noise_mid,
		\instrument, \noise_engine,
		\freq, Pexprand(320,660,inf),
		\band_width, Ndef(\noise_band_width),
		\dur, Pwhite(3,5,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\amp, Pwhite(0.02,0.1),
		\atk, 8, \dec, 0, \sus, 1, \rel, 8,
		\out, ~bus_master,
	).play(t, quant: 1);

	\noise_mid_start.postln;

})

.add(\rumble_start -> {

	Pbindef(\rumble, // low frequency noise engine for LFE use mainly
		\instrument, \noise_engine,
		\freq, Pexprand(40,120,inf), // LFE range frequencies randomized
		\band_width, 40, // has a fair bit of ressonance
		\dur, Pwhite(8,13,inf), // rumbles slightly less often than mid noise
		\pan, Pwhite(0.0,2.0,inf), // non-LFE component pans across stereo field
		\amp, Pwhite(0.02,0.1), // quiet volume for now
		\subamp, Pkey(\amp),
		\atk, 4, \dec, 0, \sus, 1, \rel, 4, // quite slow attack and release
		\legato, 0.5,
		\out, ~bus_master,
	).play(t, quant: 1);

	\rumble_start.postln;

})

.add(\tapping_hi_start -> {
	// low density

	~tapping_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.7,rrand(4,6)),
				\freq, exprand(880,1760),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\tapping_band_width),
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_hi_start.postln;
})

.add(\tapping_lo_start -> {

	~tapping_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.2,0.9,rrand(3,5)),
				\freq, exprand(138,277),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\tapping_band_width),
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_lo_start.postln;

})

.add(\melody_lo_start -> {
	Pbindef(\melody_lower,
		\instrument, \impulse,
		\midinote, Ptuple([Pseq(~melody[1],inf),Pseq(~melody[1],inf)-12],inf),
		\melody_index, Pseq((0..13),inf),
		\dur, 4,
		\pan, Pwhite(0.0,2.0,inf),
		\atk, 2,
		\rel, 8,
		\amp, Pfunc({Ndef(\melody_amp).get(\val)}),
		\pamp, 2,
		\band_width, 10,
		\legato, 0.1,
		\out, ~bus_master,
		\collect, Pfunc({|ev| ~e_melody_lower = ev})
	).play(t, quant: [4, 0, 1.05]);

	\melody_lo_start.postln;

})

.add(\noise_hi_start -> {


	Pbindef(\noise_hi,
		\instrument, \noise_engine,
		\freq, Pexprand(660,1320,inf),
		\band_width, Ndef(\noise_band_width),
		\dur, Pwhite(3,5,inf),
		\pan, Pwhite(0.0,2.0,inf),
		\amp, Pwhite(0.02,0.1),
		\atk, 8, \dec, 0, \sus, 1, \rel, 8,
		\out, ~bus_master,
	).play(t, quant: 1);

	\noise_hi_start.postln;

})

.add(\crackles_hi_start -> {

	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.3,rrand(18,24)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\atk, 0.005,
				\rel, 0.05,
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackles_hi_start.postln;

})

.add(\crackles_lo_start -> {

	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.45,rrand(18,24)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\atk, 0.005,
				\rel, 0.05,
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackles_lo_start.postln;
})

.add(\tapping_hi_increase_density -> {

	~tapping_hi.stop;
	~tapping_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.5,rrand(6,8)),
				\freq, exprand(880,1760),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\tapping_band_width),
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(6,8),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_hi_increase_density.postln;
})

.add(\noise_lower_atk_rel -> {

	Pbindef(\noise_mid, \atk, 1, \dec, 0, \sus, 1, \rel, 5);
	Pbindef(\noise_hi, \atk, 1, \dec, 0, \sus, 1, \rel, 5);

	\noise_lower_atk_rel.postln;
})

.add(\tapping_lo_increase_density -> {
	~tapping_lo.stop;
	~tapping_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.15,0.7,rrand(6,8)),
				\freq, exprand(138,277),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\tapping_band_width),
				\amp, Pwhite(0.05,0.1),
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(6,8),
		\method, \par,
	)).play(t, quant: 1);

	\tapping_lo_increase_density.postln;
})



.add(\melody_hi_start ->{
	Pbindef(\noise_mid).stop;

	Pbindef(\melody_upper,
		\instrument, \noise_engine,
		\midinote, Pfunc({~melody[0][~e_melody_lower[\melody_index]]}),
		\band_width, Ndef(\noise_band_width),
		\dur, 4,
		\pan, Pfunc({~e_melody_lower[\pan]+1}), // random pan across octophonic field
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * 0.7}),
		\atk, 1, // slow attack,
		\dec, 0, // no decay
		\sus, 1,
		\rel, 5, // slow release,
		\out, ~bus_master,
	).play(t, quant: 4);

	\melody_hi_start.postln;
})

.add(\crackling_hi_increase_density -> {

	~crackles_hi.stop;
	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.25,rrand(18,24)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\amp, Pwhite(0.05,0.09),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_hi_increase_density.postln;

})

.add(\crackling_lo_increase_density -> {

	~crackles_lo.stop;
	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.1,0.35,rrand(18,24)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\amp, Pwhite(0.05,0.09),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_lo_increase_density.postln;
})

.add(\tapping_to_droplets_hi -> {
	~tapping_hi.stop;

	Pbindef(\droplets_hi,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[0][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.25, 0.5,inf),
		\pan, Pbrown(0.0,8.0,0.25,inf),
		\legato, 0.1,
		\amp, Pwhite(0.03,0.07),
		\band_width, 20,
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\tapping_to_droplets_hi.postln;
})

.add(\t_lo_start -> {

	Pbindef(\t_lo,
		\instrument, \noise_engine,
		\order, Pseq([-1,-1,1,1],inf),
		\midinote, Pfunc({ |ev| ~t_pitch.(~melody[1][~e_melody_lower[\melody_index]] -60, [1,4,8],ev[\order],12)+60}),
		\band_width, Ndef(\noise_band_width),
		\dur, 4,
		\pan, Pfunc({~e_melody_lower[\pan] - 0.5}),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * 0.6}),
		\atk, 1,
		\dec, 0,
		\sus, 1,
		\rel, 5,
		\out, ~bus_master,
	).play(t, quant: 4);

	\t_lo_start.postln;

})

.add(\tapping_to_droplets_low -> {
	~tapping_lo.stop;

	Pbindef(\droplets_lo,
		\instrument, \perc,
		\midinote, Pfunc({(~t_pitch.(~melody[1][~e_melody_lower[\melody_index]] -60, [1,4,8],1,12)+60+12)}),
		\dur, Pwhite(0.25, 0.5,inf),
		\pan, Pbrown(0.0,8.0,0.25,inf),
		\legato, 0.1,
		\amp, Pwhite(0.03,0.07),
		\band_width, Ndef(\noise_band_width),
		\out, ~bus_reverb,
	).play(t, quant: 1);

	\tapping_to_droplets_low.postln;
})

.add(\crackling_hi_increase_density2 -> {

	~crackles_hi.stop;
	~crackles_hi = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.15,rrand(20,36)),
				\freq, exprand(3000,5000),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\amp, Pwhite(0.05,0.07),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_hi_increase_density2.postln;
})

.add(\crackling_lo_increase_density2 -> {

	~crackles_lo.stop;
	~crackles_lo = Pspawn(Pbind(
		\pattern, Pfunc {
			Pbind(
				\instrument, \perc,
				\dur, Pwhite(0.05,0.25,rrand(20,26)),
				\freq, exprand(1900,2900),
				\pan, rrand(0.0,2.0) + Pwhite(-0.1,0.1),
				\band_width, Ndef(\crackles_band_width),
				\amp, Pwhite(0.05,0.07),
				\atk, 0.005,
				\rel, 0.05,
				\legato, 0.1,
				\out, ~bus_reverb,
			)},
		\delta, Pwhite(7,10),
		\method, \par,
	)).play(t, quant: 1);

	\crackling_lo_increase_density2.postln;
})

.add(\t_hi_start -> {
	Pbindef(\noise_hi).stop;

	Pbindef(\t_hi,
		\instrument, \noise_engine,
		\order, Pseq([-1,-1,1,1],inf),
		\midinote, Pfunc({ |ev| ~t_pitch.(~melody[0][~e_melody_lower[\melody_index]] -60, [1,4,8],ev[\order],12)+60}),
		\band_width, Ndef(\noise_band_width),
		\dur, 4,
		\pan, Pfunc({~e_melody_lower[\pan] + 0.5}),
		\amp, Pfunc({Ndef(\melody_amp).get(\val) * 0.7}),
		\atk, 1,
		\dec, 0,
		\sus, 1,
		\rel, 5,
		\out, ~bus_master,
	).play(t, quant: 4);

	\t_hi_start.postln;

})

.add(\start_boom -> {
	Pbindef(\taps_boom,
		\instrument, \perc,
		\midinote, ~melody[1][1]-24,
		\dur, 16,
		\pan, Pseq([Pwhite(0.0,2.0,1), 0],inf),
		\amp, 0.4,
		\subamp, Pkey(\amp),
		\rel, 4,
		\band_width, 100,
		\subamp, 0.2,
		\legato, 0.2,
		\out, ~bus_reverb,
	).play(t, quant: 4);

	\start_boom.postln;
})

.add(\droplets_hi_unify_rhythm -> {

})

.add(\droplets_lo_unify_rhythm -> {

})

.add(\crackling_unify_rhythm -> {

})

.add(\crackles_lo_stop -> {
	~crackles_lo.stop;
	\crackles_lo_stop.postln;
})

.add(\crackles_hi_stop -> {
	~crackles_hi.stop;
	\crackles_hi_stop.postln;
})

.add(\melody_lo_stop -> {
	Pbindef(\melody_lower).stop;
	\melody_lo_stop.postln;
})

.add(\t_hi_stop -> {
	Pbindef(\t_hi).stop;
	\t_hi_stop.postln;
})

.add(\t_lo_stop -> {
	Pbindef(\t_lo).stop;
	\t_lo_stop.postln;
})

.add(\melody_hi_stop -> {
	Pbindef(\melody_upper).stop;
	\melody_hi_stop.postln;
})


)

(
r = Routine({
	~events[\noise_mid_start].();
	~parameterChange.(Ndef(\noise_band_width), Env([200,5,1],[135,45]),t,16);
	~parameterChange.(Ndef(\melody_amp), Env([0.2,0.2,0.4,0.2,0.05],[90,45,45]),t,1);

	4.wait;
	~events[\rumble_start].();
	4.wait;
	~events[\tapping_hi_start].();
	6.wait;
	~events[\tapping_lo_start].();
	4.wait;
	~events[\melody_lo_start].();
	12.wait;
	~events[\noise_hi_start].();
	2.wait;
	~events[\crackles_hi_start].();
	6.wait;
	~events[\crackles_lo_start].();
	4.wait;
	~events[\tapping_hi_increase_density].();
	4.wait;
	~events[\noise_lower_atk_rel].();
	4.wait;
	~events[\tapping_lo_increase_density].();
	8.wait;
	~events[\melody_hi_start].();
	8.wait;
	~events[\crackling_hi_increase_density].();
	2.wait;
	~events[\crackling_lo_increase_density].();
	8.wait;
	~events[\tapping_to_droplets_hi].();
	8.wait;
	~events[\t_lo_start].();
	6.wait;
	~events[\tapping_to_droplets_low].();
	8.wait;
	~events[\crackling_hi_increase_density2].();
	2.wait;
	~events[\crackling_lo_increase_density2].();
	2.wait;
	~events[\t_hi_start].();
	4.wait;
	~events[\start_boom].();
	10.wait;
	~events[\crackles_hi_stop].();
	10.wait;
	~events[\crackles_lo_stop].();
	10.wait;
	~events[\droplets_hi_stop].();
	10.wait;
	~events[\droplets_lo_stop].();
	10.wait;
	~events[\melody_lo_stop].();
	10.wait;
	~events[\t_hi_stop].();
	10.wait;
	~events[\t_lo_stop].();
	10.wait;
	~events[\melody_hi_stop].();

	\done.postln;
});
)

~events[\tapping_to_droplets_hi].();

~events[\melody_lo_start].();
~events[\melody_hi_start].();
~events[\t_lo_start].();
~events[\t_hi_start].();

~events[\setup].();
r.play(t, quant: 4);


~e_melody_lower[\melody_index];