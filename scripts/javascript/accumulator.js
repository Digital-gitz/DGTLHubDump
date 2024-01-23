// an example of the accumulator pattern
let countTo = 3; // how high should we count?
let sum = 0; // this is a place to store our sum

for (let i = 1; i <= countTo; i++) {
  sum += i;
  console.log("The current sum is: " + sum);
}
console.log("The final sum is: " + sum);


// An example of the accumulator pattern
let colors = ["red", "white", "blue"];
let statement = "My favorite colors are ";


// Challenge 1: Make the statement say the following:
// 'My favorite colors are red, white, blue,'
for (let i = 0; i < colors.length; i++) {
  // append each color to the iteration
statement += colors[i] + ", ";
}

// Challenge 2: Make the statement say the following:
// 'My favorite colors are red, white and blue.'
//step back one index and add "and" before the last color
for (let i = 0; i < colors.length; i++) {
    if (i === colors.length - 1) {
      statement += "and " + colors[i] + ".";
    } else {
      statement += colors[i] + ", ";
    }
  }


console.log(statement);