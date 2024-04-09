Scale.all.put(\octatonic, Scale(#[0, 1, 3, 4, 6, 7, 9, 10]));
Scale.at(\octatonic);

(
~triads = [
	#[0,2,5],
	#[0,3,5],
	#[2,4,7],
	#[2,5,7],
	#[4,6,1],
	#[4,7,1],
	#[6,0,3],
	#[6,1,3],
];


~dom_sevenths = [
	#[1,3,5,6],
	#[3,5,7,0],
	#[5,7,1,2],
	#[7,1,3,4],
];

~dim_7th = [
	#[0,2,4,6],
	#[1,3,5,7],
];

~half_dim_7th = [
	#[1,2,4,6],
	#[3,4,6,0],
	#[5,6,0,2],
	#[7,0,2,4],
];

~minor_7ths = [
	#[1,3,4,6],
	#[3,5,6,0],
	#[5,7,0,2],
	#[7,1,2,4],
];
)

(
~tempo = 60;
~signiture = 4;
t = TempoClock.new(~tempo/60).permanent_(true).schedAbs(0, {t.beatsPerBar_(~signiture)});
)

(
Pdef(\data,
	Pbind(
		\type, \rest,
		\dur, Pxrand([4,8],inf),
		\t, Pstep(Pxrand([-2,-1,0,1,2],inf),32),
		\chord, Pseq([Pseq([Pxrand(~minor_7ths,1),Pxrand(~dom_sevenths,1)],2),Pxrand(~dim_7th)],inf),
	).collect({ |ev| ~data_ev = ev;}
	);
)
)

Pdef(\data).play(t, quant: [4,0,0.05]);

~data_ev[\t]

(
Pdef(\pattern2,
	Pbind(
		\instrument, \strings,
		\dur, 2,
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current -8;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
	);
);
)

(
Pdef(\pattern3,
	Pbind(
		\instrument, \strings,
		\dur, 3/2,
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current +8;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
	);
);
)

Pdef(\data).play(t, quant: [4,0,0.05]);

(
Pdef(\pattern,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(1,4,inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
		\amp, 0.5,
	);
);
)

Pdef(\pattern).play(t, quant:4);

(
Pdef(\pattern2,
	Pbind(
		\instrument, \sine,
		\dur, Pxrand([0.25,0.5,0.75],inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current + 8;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
		\atk, 0.005,
		\rel, 0.5,
		\legato, 0.25,
		\amp, Pwhite(0.1,0.3,inf),
		\pan, Pwhite(-0.8,0.8,inf),
	);
);
)


Pdef(\pattern2).play(t, quant:4);

(
Pdef(\pattern,
	Pbind(
		\instrument, \sine,
		\dur, 0.25,
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, Pfunc({~data_ev[\chord]}),
		\scale, Scale.at(\octatonic),
		\amp, 0.1,
		\atk, 0.005,
		\rel, 0.5,
	);
);
)

(
Pdef(\data,
	Pbind(
		\type, \rest,
		\dur, 4,
		\t, Pstep(Pxrand([-2,-1,0,1,2],inf),32),
		\chord, Pseq([Pseq([Pxrand(~minor_7ths,1),Pxrand(~dom_sevenths,1)],2),Pxrand(~dim_7th)],inf),
	).collect({ |ev| ~data_ev = ev;}
	);
)
)

(
Pdef(\pattern,
	Pbind(
		\instrument, \sine,
		\dur, Pwrand([0.25,0.125],[30,5].normalizeSum,inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, Pfunc({~data_ev[\chord]}),
		\scale, Scale.at(\octatonic),
		\amp, 0.1,
		\atk, 0.005,
		\rel, 0.5,
	);
);
)

(
Pdef(\pattern3,
	Pbind(
		\instrument, \strings,
		\dur, Pwhite(4,7,inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current - 8;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
		\amp, 0.1,
		\atk, 0.5,
		\rel, 0.3,
		\legato, 1,
		\cutoff, 3000,
		\pan, -0.9
	);
);
)

(
Pdef(\pattern3b,
	Pbind(
		\instrument, \strings,
		\dur, Pwhite(4,7,inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, {
			var previous = 0;
			var current;
			loop({
				current = ~data_ev[\chord].choose;
				if(current != previous, {
					previous = current;
					current = current - 8;
					current.yield;
				});
			});

		}.p,
		\scale, Scale.at(\octatonic),
		\amp, 0.1,
		\atk, 0.5,
		\rel, 0.3,
		\legato, 1,
		\cutoff, 3000,
		\pan, 0.8,
	);
);
)

(
Pdef(\pattern4,
	Pbind(
		\instrument, \strings,
		\dur, Pwhite(4,7,inf),
		\ctranspose, Pfunc({~data_ev[\t]}),
		\degree, Pfunc({~data_ev[\chord][0]-16}),
		\scale, Scale.at(\octatonic),
		\amp, 0.1,
		\atk, 0.5,
		\rel, 0.3,
		\legato, 1,
		\cutoff, 3000,
		\pan, 0.8,
	);
);
)

Pdef(\pattern3).play(t, quant:4);
Pdef(\pattern3b).play(t, quant:4);
Pdef(\pattern4).play(t, quant:4);
