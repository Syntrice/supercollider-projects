// Mouse control
{SinOsc.ar(freq: MouseX.kr(300,2500), mul: MouseY.kr(0,1))}.play;

// Plotting
{ SinOsc.ar }.plot;
{ Saw.ar }.plot;
{ Pulse.ar }.plot;

// Unit generators:
// Kr runs ar the audio rate
// Ar runs kr the control rate

// There are two types of Ugens, and they output different values
// Unipolar: between 0 and 1
// Bipolar: between -1 and +1


// poll function prints a few numbers every second. Sinosc is bipolar
{SinOsc.kr(1).poll}.play;

{LFNoise0.ar(10000).poll}.play;

// range scales the bipolar values between -1 and 1 to values in the specified range
{SinOsc.ar(freq: LFNoise0.kr(20).range(500,1500),mul: 0.1)}.play;

// you can also scale with mul and add
{SinOsc.kr(1, mul: 50, add: 150).poll}.play;

// set values of x
x = {arg freq = 440, amp = 0.1; SinOsc.ar(freq, 0, amp)}.play;
x.set(\freq, 778);
x.set(\amp, 0.5);
x.set(\freq, 920, \amp, 0.2);
x.free;

// sending to audio buses: 0 is left, 1 is right
// supercollider has 128 audio buses
{Out.ar(1, SinOsc.ar(440, 0, 0.1))}.play; // right channel

f = {Out.ar(0, BPF.ar(in: In.ar(55), freq: MouseY.kr(1000, 5000), rq: 0.1))}.play;
