const computerChoiceDisplay = document.getElementById('computer-choice')
const userChoiceDisplay = document.getElementById('user-choice')
const resultDisplay = document.getElementById('result')
const possibleChoices = document.querySelectorAll('button')
let userChoice
let computerChoice
let result

possibleChoices.forEach(possibleChoice => possibleChoice.addEventListener('click', (e) => {
  userChoice = e.target.id
  userChoiceDisplay.innerHTML = userChoice
  generateComputerChoice()
  getResult()
}))

function generateComputerChoice() {
  const randomNumber = Math.floor(Math.random() * 3) + 1 // or you can use possibleChoices.length
  
  if (randomNumber === 1) {
    computerChoice = 'rock'
  }
  if (randomNumber === 2) {
    computerChoice = 'scissors'
  }
  if (randomNumber === 3) {
    computerChoice = 'paper'
  }
  computerChoiceDisplay.innerHTML = computerChoice
}

function getResult() {
  if (computerChoice === userChoice) {
    result = 'its a draw!'
  }
  if (computerChoice === 'rock' && userChoice === "paper") {
    result = 'you win!'
  }
  if (computerChoice === 'rock' && userChoice === "scissors") {
    result = 'you lost!'
  }
  if (computerChoice === 'paper' && userChoice === "scissors") {
    result = 'you win!'
  }
  if (computerChoice === 'paper' && userChoice === "rock") {
    result = 'you lose!'
  }
  if (computerChoice === 'scissors' && userChoice === "rock") {
    result = 'you win!'
  }
  if (computerChoice === 'scissors' && userChoice === "paper") {
    result = 'you lose!'
  }
  resultDisplay.innerHTML = result
}



// RockPaperScissors Virsion 2 starts here. 
    // V.2 starts here.
    const choices = ["🪨", "📄", "✂️"];
    const playerScore = document.getElementById("playerScore");
    const computerScore = document.getElementById("computerScore");
    const resolution = document.getElementById("resolution");
    const playerScoreDisplay = document.getElementById("playerScoreDisplay");
    const computerScoreDisplay = document.getElementById("computerScoreDisplay");
    let playerScoreCount = 0;
    let computerScoreCount = 0;

    function playGame(playerPicks) {
      const computerPicks = choices[Math.floor(Math.random() * 3)]
        results = "";

      if(playerPicks === computerPicks){
        results = "It's a tie!";
    }
    else{
        switch(playerPicks){
            case "🪨":
                results = computerPicks === "✂️" ? "You won!" : "You lost!";
                break;
            case "📄":
                results = computerPicks === "🪨" ? "You won!" : "You lost!";
                break;
            case "✂️":
                results = computerPicks === "📄" ? "You won!" : "You lost!";
                break;
        }
    }
    playerScore.textContent = `PLAYER: ${playerPicks}`;
    computerScore.textContent =  `COMPUTER: ${computerPicks}`;
    resolution.textContent = results;  
    
    resolution.classList.remove("greenText", "redText",)

    switch(results){
        case "You won!":
            resolution.classList.add("greenText")
            playerScoreCount++;
            playerScoreDisplay.textContent = playerScoreCount;
            // playerScore.style.color = "green";
            // computerScore.style.color = "red";
            // resolution.style.color = "green";
            break;
        case "You lost!":
            resolution.classList.add("redText")
            computerScoreCount++;
            computerScoreDisplay.textContent = computerScoreCount;
            // playerScore.style.color = "green";
            // computerScore.style.color = "red";
            // resolution.style.color = "green";
            break;
  
    }
            
            //Or maybe I could use a default case here to reset the colors. 

            // default:
            // playerScore.style.color = "black";
            // computerScore.style.color = "black";
            // resolution.style.color = "black";
            // resolution.classList.add('blackText')
    
        }