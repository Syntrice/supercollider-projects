s.boot;

// Reciever notation vs functional notation

100.rand // send 100 to the rand function, conntected by dot - reciever notation

rand(100) // sen 100 to the rand function, passed in paranthesis - functional notation


// Enclosure types
// (), [], {}, ""
// most of these are obvious. Curley braces {} define functions, () define blocks

// Conditionals
// Syntax for if/else: if(condition, {true action}, {false action}).

if(100.rand > 50, {"hi".postln}, {"bye".postln});

// case
(
~num = −2;

case
{~num == 0} {"WOW".postln}
{~num == 1} {"ONE!".postln}
{~num < 0} {"negative number!".postln}
{true} {"last case scenario".postln};
)

// Functions

f = { arg a, b; ["sum: ", a+b].postln};

f.value(1,2)

// Arrays

a = [10,11,12,13,14,15,16,17]

a.reverse; // reverse
a.scramble; // randomize
a.choose; // pick at random
a.size; // return size
a.at(0); // item at index
a[0]; // item at index
a.wrapAt(9) // modulo wrap around index
["wow",99] ++ a; // concentrate two arrays
a.add(44); // return new array with item added on
a.insert(5,"wow"); // returns new array, inserts item at specified index

a.put(2,"oops"); // modifies array in place, replaces value at indice
a.permute(3); // send item at index 3 to index 0.
a.mirror; // make a palindrome
a.powerset; // returns all possible combinations of the array's elements


// math can also be done with arrays
[1,2,3,4,5] * 10; //etc

// Creating Arrays:
// Arithmetic series
Array.series(size: 6, start: 10, step: 3);
// Geometric series
Array.geom(size: 10, start: 1, grow: 2);
// Compare the two:
Array.series(7, 100, −10); // 7 items; start at 100, step of −10
Array.geom(7, 100, 0.9); // 7 items; start at 100; multiply by 0.9 each time
// Meet the .fill method
Array.fill(10, "same");
// Compare:
Array.fill(10, rrand(1, 10));
Array.fill(10, {rrand(1, 10)}); // function is re−evaluated 10 times

// The function for the .fill method can take a default argument that is a counter.
// The argument name can be whatever you want.
Array.fill(10, {arg counter; counter * 10});
// For example, generating a list of harmonic frequencies:
Array.fill(10, {arg wow; wow+1 * 440});
// The .newClear method
a = Array.newClear(7); // creates an empty array of given size
a[3] = "wow"; // same as a.put(3, "wow")

// shortcut notation
30!4 // returns array of length 4 with 30 in each part

{rrand(1,10)}!4 // same here but for random range

(10..20) // generates an arithmatic array from 10 to 20

// Iterate through arrays, like for loop: use .do
// collect is similar but returns a new collection

(
~frequencies = Array.fill(3, {rrand(440,880)}); // random frequences between 440 and 880

~frequencies.do({arg item;{SinOsc.ar(item,0,0.1)}.play});
)
