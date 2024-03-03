import { Board } from "./board.mjs"
import { Cell } from "./cell.mjs"
import { BOARD_HEIGHT, BOARD_WIDTH } from "./constants.mjs";

export class Game {
    #cells = []

    constructor(canvas) {
        this.canvas = canvas
        this.board = new Board(this.canvas)

        this.canvas.width = BOARD_WIDTH
        this.canvas.height = BOARD_HEIGHT
    }

    initialize = () => {
        this.initializeCells()
        this.launch()
    }

    initializeCells() {
        for (let i = 0; i < this.board.size.cellNumberX; i++) {
            this.#cells[i] = []

            for (let j = 0; j < this.board.size.cellNumberY; j++) {
                this.#cells[i][j] = new Cell(this.board.context, i, j, this.board.size.cellSize)
                this.#cells[i][j].alive = Math.random() > 0.8
                this.#cells[i][j].draw()
            }
        }
    }

    launch = () => {
        this.board.drawBackground()

        this.updateCells()

        requestAnimationFrame(this.launch)
    }

    updateCells = () => {
        for (let i = 0; i < this.board.size.cellNumberX; i++) {
            for (let j = 0; j < this.board.size.cellNumberY; j++) {
                this.updateCellNeighbors(i, j);
            }
        }

        for (let i = 0; i < this.board.size.cellNumberX; i++) {
            for (let j = 0; j < this.board.size.cellNumberY; j++) {
                this.#cells[i][j].nextGeneration()
                this.#cells[i][j].draw()
            }
        }
    }

    updateCellNeighbors = (x, y) => {
        let aliveNeighborsCount = 0

        const neighborCoords = [
            [x, y + 1],
            [x, y - 1],
            [x + 1, y],
            [x - 1, y],
            [x + 1, y + 1],
            [x - 1, y - 1],
            [x + 1, y - 1],
            [x - 1, y + 1]
        ]

        for (const coords of neighborCoords) {
            let [xCord, yCord] = coords;

            const xOutOfBounds = xCord < 0 || xCord >= this.board.size.cellNumberX
            const yOutOfBounds = yCord < 0 || yCord >= this.board.size.cellNumberY

            const wrappedX = xOutOfBounds ? (xCord + this.board.size.cellNumberX) % this.board.size.cellNumberX : xCord
            const wrappedY = yOutOfBounds ? (yCord + this.board.size.cellNumberY) % this.board.size.cellNumberY : yCord

            if (this.#cells[wrappedX]?.[wrappedY]?.alive) {
                aliveNeighborsCount++
            }
        }

        this.#cells[x][y].neighbors = aliveNeighborsCount
    }
}
