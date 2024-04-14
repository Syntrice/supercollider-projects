(

// An implementation of Arvo Pärt's Tintinnabuli technique.
// TODO: Optimize implementation of direction control flow.


~t_pitch = {
	arg m_pitch, chord, order, octave_steps = 8;
	var m_oct, oct, direction, magnitude, value, i;

	// calculate pitch class and octave
	m_oct = m_pitch.div(octave_steps);
	m_pitch = m_pitch % octave_steps;

	// calculate direction and magnitude
	direction = order.abs / order;
	magnitude = order - direction;

	// which direction to calculate t_pitch

	if (direction > 0, {
		i = 0;
		oct = 0;
		value = chord[0];
		while {(value + (octave_steps * oct)) <= m_pitch} {
			value = chord[i % chord.size];
			oct = i.div(chord.size);
			i = i + 1;
		};

		if (magnitude > 0) {
			value = chord[(i + magnitude - 1) % chord.size];
			oct = oct + (i + magnitude - 1).div(chord.size);
		};

		value = value + (octave_steps * (oct + m_oct));

	},
	{
		i = -1;
		oct = 0;

		value = chord[-1 % chord.size];

		while {(value + (octave_steps * oct)) >= m_pitch} {
			value = chord[i % chord.size];
			oct = i.div(chord.size) + 1;

			i = i - 1;
		};

		if (magnitude < 0) {
			value = chord[(i + magnitude + 1) % chord.size];
			oct = (i + magnitude + 1).div(chord.size) + 1;
		};

		value = value + (octave_steps * oct) + (octave_steps * m_oct);
	}
	);

	value;
}
)

// Connect to midi keyboard to demo the algorithm.

MIDIClient.init;
MIDIIn.connectAll;

~notes = Array.newClear(128);
~t = Array.newClear(128);


// chord to use
~chord = [0,4,9];
~order = -1;
~orbit = false;

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\default,
		[
			\freq, (nn).midicps,
			\amp, vel.linexp(1,127,0.01,0.3),
			\gate, 1,
			\cutoff, 2000,
			\band_width, 10,

		],
	);
	~t[nn] = Synth.new(
		\default,
		[
			\freq, (~t_pitch.((nn - 60), ~chord, ~order, 12) + 60).midicps,
			\amp, vel.linexp(1,127,0.01,0.3),
			\gate, 1,
			\cutoff, 2000,
			\band_width, 10,
		],
	);

	// inverts direction every note
	if (~orbit) {
		~order = ~order * -1;
		~order.postln;
	};
});
)

(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
	~t[nn].set(\gate, 0);
	~t[nn] = nil;


});
)
