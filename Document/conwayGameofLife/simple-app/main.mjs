import { Game } from "./modules/game.mjs"
// window.addEventListener('resize', resizeCanvas, false);

// function resizeCanvas() {
const canvas = document.getElementById("game-board")
// canvas.width = window.innerWidth;
// canvas.height = window.innerHeight;
// }

// resizeCanvas();
const game = new Game(canvas)


game.initialize()