// Sequencing using Pbind

// Besides value patterns, event patterns are used to create events.

// Pbind is a way to name values that patterns generate, wrapping them in events.

(
p = Pbind(
	\degree, Pseq([0,1,2,3],4),
	\dur, Pseq([0.5,1],inf),
).asStream;
)

p.next(Event.new);

// Events can be played as follows, but Pbind does this atuomatically
( 'degree': 0, 'dur': 0.5 ).play;

// Rests can be specified by creating an instance of Rest(), which plays no value:

('degree': Rest(), 'dur': 0.5).play;

// Pmono

// Pmono plays just one Synth node and changes its values with each event.

p = Pmono(\default, \degree, Pwhite(0,7, inf), \dur, 0.25).play;

// PmonoArtic plays one synth at a time, but allows events to be re-articulated and supports staccato in the middle of a monophonic phrase.

p = PmonoArtic(\default, \degree, Pwhite(0,7, inf), \dur, 1, \amp, Pseg([0.1,0.8,0.1],1,'lin',inf)).play;