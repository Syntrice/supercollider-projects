s.boot;

// ----------------------------------
// --- Patterns and Streams


// Patterns can be used to perform calculations on demand, like a routine. They can calculate data and return it as required.

// The asStream method is useful here, as it returns a stream from which values may be yielded. Any number of streams can be made from the same pattern too.
a = Pseries(start: 0, step: 1, length: inf).asStream;

a.nextN(10);

// ----------------------------------
// --- Generating Values

// play through list and repeat n times
Pseq([1,2,3],2).asStream.nextN(6)

// pick a random item from list, n times
Prand(['a','b','c'],6).asStream.nextN(6)

// pick a non-repeating random item from list, n times
Pxrand(['a','b','c'],6).asStream.nextN(6)

// shuffle the list before playing through in sequence n times
Pshuf([1,2,3,4],2).asStream.nextN(8)

// chooses randomly, based on weighted probabilities
Pwrand([1,2,3],[15,10,5].normalizeSum,inf).asStream.nextN(8);

// Arithmatic series
Pseries(0,2,5).asStream.nextN(5);

// Geometric series
Pgeom(1,2,5).asStream.nextN(5);

// Random numbers in range, equal distribution
Pwhite(0,20,inf).asStream.nextN(5);

// Random numbers, exponential distribution. Useful for frequencies
Pexprand(100,1000,inf).asStream.nextN(5);

// Random brownian motion - produces nice scalar motion
Pbrown(0,12,1,16).asStream.nextN(16);

// Gets values from the function times
(
Pfunc({
	var a, b;
	a = Prand(['apple','orange','banana']).asStream.next;
	b = Prand(['red','purple','blue']).asStream.next;
	b ++ "-" ++ a;
}).asStream.nextN(5);
)

// same as above, but stops after repeat times
Pfuncn()

// returns a routine from a function
Prout()

// --- Other List Patterns

//Like PSeq, except repeats specifies total items returned. Wraps around when end of list reached
Pser([0,1,2,3],4).asStream.nextN(5)

// Specify segments and step to play from a list
Pslide([0,1,2,3,4], 2, 2, 3).asStream.nextN(4)

// Easy way to define a sequence, so increments the list index based upon the result of the step pattern, which defines what steps to take to move to the next index
Pwalk(Array.series(20,0,1), Pseq([1,-1,2],inf)).asStream.nextN(8);

// Interlaces imbedded arrays. When pattern repeats, next item from imbedded array will be chosen.
Place([[-1,1],2,3,4],inf).asStream.nextN(8);

// Like above, but returns an array of streams or patterns
Ppatlace();

// Groups together all items in list and returns it as an array
Ptuple([1,2,3,4],2).asStream.nextN(2);