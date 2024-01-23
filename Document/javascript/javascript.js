const computerChoiceDisplay = document.getElementById("computerChoice");
const userChoiceDisplay = document.getElementById("userChoice");
const result = document.getElementById("result");
const possibleChoices = document.querySelectorAll("button");
let userChoice;
let computerChoice;
let resultDisplay;

possibleChoices.forEach(possibleChoice => possibleChoice.addEventListener('click', (e) => {
    userChoice = e.target.id;
    userChoiceDisplay.innerHTML = userChoice;
    generateComputerChoice();
}))

function generateComputerChoice() {
    //you can use possible.choices.length instead of 3.
        const randomNumber = Math.floor(Math.random() * 3) + 1;
        if (randomNumber === 1) {
            computerChoice = "rock";
        }
        if (randomNumber === 2) {
            computerChoice = "paper";
        }
        if (randomNumber === 3) {
            computerChoice = "scissors";
        }
    computerChoiceDisplay.innerHTML = computerChoice;
     checkResult();
   console.log(randomNumber);
    };

function checkResult() {
    if (computerChoice === userChoice) {
        result.innerHTML = "It's a tie!";
    }
    if (computerChoice === "rock" && userChoice === "paper") {
        result.innerHTML = "You won!";
    }
        result.innerHTML = "You lost!";
    }
    if (computerChoice === "paper" && userChoice === "rock") {
        result.innerHTML = "You lost!";
    }
    if (computerChoice === "paper" && userChoice === "scissors") {
        result.innerHTML = "You won!";
    }
    if (computerChoice === "scissors" && userChoice === "rock") {
        result.innerHTML = "You won!";
    }
    if (computerChoice === "scissors" && userChoice === "paper") {
        result.innerHTML = "You lost!";
    }

    // V.2 starts here.

    const choices = ["🪨", "📄", "✂️"];
    const playerScore = document.getElementById("playerScore");
    const computerScore = document.getElementById("computerScore");
    const resolution = document.getElementById("resolution");

    
    function playGame(playerChoice) {
      const computerChoice = choices[Math.floor(Math.random() * 3)]
      console.log( computerChoice);
    }

// this function is doing some weird inner~html selection 
// that I don't understand. and is returning value to the v1 choices.... feature..  
    function rockPaperScissors() {
        const playerChoice = this.id;
        const computerChoice = choices[Math.floor(Math.random() * choices.length)];
        console.log(playerChoice, computerChoice);
        if (playerChoice === computerChoice) {
            resolution.innerHTML = "It's a tie!";
        } else if (playerChoice === "🪨" && computerChoice === "✂️") {
            resolution.innerHTML = "You win!";
            playerScore.innerHTML++;
        } else if (playerChoice === "📄" && computerChoice === "🪨") {
            resolution.innerHTML = "You win!";
            playerScore.innerHTML++;
        } else if (playerChoice === "✂️" && computerChoice === "📄") {
            resolution.innerHTML = "You win!";
            playerScore.innerHTML++;
        } else {
            resolution.innerHTML = "You lose!";
            computerScore.innerHTML++;
        }
    }
