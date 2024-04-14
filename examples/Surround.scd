
// Server Setup
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
s.options.numAudioBusChannels = 128;
s.options.numOutputBusChannels = 9; // 8 plus subwoofer
s.options.numInputBusChannels = 2;
Server.default.reboot;
)

(
// Parameters

~stereo = false; // toggle to enable a stereo mixdown
~numChannels = 8; // number of mixing channels
~numLFE = 1; // number of LFE channels

// Mixer

~mixer.free; ~mixer = Group(s, \addToTail);

// Master Channel

SynthDef(\master, {
	arg in;
	var snd;
	var l, r, c, lfe, ls, rs, bsl, bsr, bc;

	snd = In.ar(in, ~numChannels + ~numLFE);

	// Reorder output to match speaker arrangement

	#l, c, r, rs, bsr, bc, bsl, ls, lfe = snd;


	if (~stereo) {
		r = Mix([c,r,rs,bsr,bc]);
		l = Mix([c,l,ls,bsl,bc]);
		snd = [l,r];
	} {
		//snd = [l, r, c, lfe, ls, rs, bsl, bsr, bc];
	};

	// Limiter
	snd = Limiter.ar(snd, -32.dbamp);


	Out.ar(0, snd);
}
).add;

~master_b.free; ~master_b = Bus.audio(s, 8);
~master_s.free; ~master_s = Synth(\master, [\in, ~master_b], ~mixer, \addToTail);

// Reverb

SynthDef(\reverb, {
	arg in;
	var snd, input;

	input = In.ar(in, ~numChannels);
	snd = Array(~numChannels);

	~numChannels.do { |i|
		snd.add(FreeVerb.ar(input[i]));
	};

	snd.postln;

	Out.ar(~master_b, snd);
}
).add;

~reverb_b.free; ~reverb_b = Bus.audio(s, 8);
~reverb_s.free; ~reverb_s = Synth(\reverb, [\in, ~reverb_b], ~mixer);

// Sources

SynthDef(\test, {
	var snd;

	snd = WhiteNoise.ar();

	snd = LPF.ar(snd, 2000);

	snd = snd * Env.perc(0.01,0.05,1.0).ar(Done.freeSelf, \gate.kr(1));

	snd = PanAz.ar(~numChannels, snd, \pan.kr(0), 1.0);


	Out.ar(\out.kr(~master_b), snd);
}).add;
)

x = Synth(\test, [\out, ~reverb_b, \pan, 0]);
x.set(\pan, 4);
x.free;


~reverb_b

