Scale.all.put(\octatonic, Scale(#[0, 1, 3, 4, 6, 7, 9, 10]));
Scale.at(\octatonic);

(
~triads = [
	#[0,2,5],
	#[0,3,5],
	#[2,4,7],
	#[2,5,7],
	#[4,6,9],
	#[4,7,9],
	#[6,8,11],
	#[6,9,11]
];
)

(
~dom_sevenths = [
	#[1,3,5,6],
	#[3,5,7,8],
	#[5,7,9,10],
	#[7,9,11,12],
];
)

(
~data = Pbind(
	\type, \rest,
	\dur, 8,
	\chord, Pseq([Pxrand(~triads,1),Pxrand(~dom_sevenths,1)],inf),
).collect({ |ev| ~data_ev = ev;});
)

x = ~data.asStream;
x.next(());

~data_ev;

(
Pbindef(\pattern1_a,
	\instrument, \sine,
	\dur, 0.25,
	\degree, Pfunc({~data_ev[\chord]}),
	\scale, Scale.at(\octatonic),
	\atk, 0.05,
	\rel, 0.25,
	\legato, 0.2,
	\vib_rate, 0,
	\pan, Pwhite(-0.8,0.8,inf),
).play;
)

(
Pbindef(\pattern1_a,
	\instrument, \sine,
	\dur, 0.25,
	\degree, { var i = 0-1; loop({i = i + 1; ~data_ev[\chord][i % 3].yield;})}.p,
	\scale, Scale.at(\octatonic),
	\atk, 0.05,
	\rel, 0.25,
	\legato, 0.2,
	\vib_rate, 0,
	\pan, Pwhite(-0.8,0.8,inf),
).play;
)

(
Pbindef(\pattern1_b,
	\instrument, \sine,
	\dur, 0.25,
	\degree, Pxrand(~dom_sevenths.collect { |row| Pxrand(row, 1)},inf ),
	\scale, Scale.at(\octatonic),
	\atk, 0.005,
	\rel, 0.5,
	\legato, 0.2,
	\vib_rate, 0,
	\pan, Pwhite(-0.8,0.8,inf),
).play;
)

(
Pbindef(\pattern1_b,
	\instrument, \sine,
	\dur, 0.125,
	\degree, Pdup(4,Pxrand(~dom_sevenths,inf)),
	\scale, Scale.at(\octatonic),
	\atk, 0.005,
	\rel, 0.5,
	\ctranspose, Pdup(16, Pwhite(-8,4,inf)),
	\legato, 0.2,
	\vib_rate, 0,
	\pan, Pwhite(-0.8,0.8,inf),
).play;
)

// Patterns

(
Pbindef(\pattern1_a,
	\instrument, \sine,
	\dur, Prand([0.25,0.5,0.75,1],inf),
	\degree, 0,
	\scale, Scale.at(\octatonic),
	\atk, 0.005,
	\rel, 0.5,
	\legato, 0.2,
	\vib_rate, 0,
	\pan, Pwhite(-0.8,0.8,inf),
).play;
)

(
Pbindef(\pattern1_b, *Pbindef(\pattern1_a).source.pairs.deepCopy);
Pbindef(\pattern1_b, \degree, 5);
Pbindef(\pattern1_b).play;
)

(
Pbindef(\pattern1_c, *Pbindef(\pattern1_a).source.pairs.deepCopy);
Pbindef(\pattern1_c, \degree, -7);
Pbindef(\pattern1_c).play;
)

(
Pbindef(\pattern1_d, *Pbindef(\pattern1_a).source.pairs.deepCopy);
Pbindef(\pattern1_d, \degree, -3);
Pbindef(\pattern1_d).play;
)

(
Pbindef(\pattern1_a, \degree, Prand([0,2],inf));
Pbindef(\pattern1_b, \degree, Prand([5,6],inf));
Pbindef(\pattern1_c, \degree, Prand([-7,-6],inf));
Pbindef(\pattern1_d, \degree, Prand([-3,-2],inf));
)

(
Pbindef(\pattern2_a,
	\instrument, \strings,
	\dur, Pseq([4,Pwhite(4,7,inf)],inf),
	\scale, Scale.at(\octatonic),
	\degree, Pseq([Pwhite(8,16,1),Rest()], inf),
	\atk, 2,
	\rel, 2,
	\legato, 1,
	\dtune, 0.01,
	\pan, Pwhite(-0.8,0.8,inf),
	\cutoff, 2000,
);
)

Pbindef(\pattern2_a).play;

(
Pbindef(\pattern2_b, *Pbindef(\pattern2_a).source.pairs.deepCopy);
Pbindef(\pattern2_b, \ctranspose, -3);
Pbindef(\pattern2_b).play;
)