import {
    BOARD_HEIGHT,
    BOARD_WIDTH,
    DEFAULT_CELL_SIZE,
    DEFAULT_GRID_COLOR,
    BOARD_BACKGROUND_COLOR
} from './constants.mjs'

export class Board {
    #width = BOARD_WIDTH
    #height = BOARD_HEIGHT

    #cellSize = DEFAULT_CELL_SIZE

    #gridColor = DEFAULT_GRID_COLOR
    #backgroundColor = BOARD_BACKGROUND_COLOR

    #grid = false

    constructor(canvas) {
        this.canvas = canvas

        this.ctx = this.canvas.getContext("2d")

        this.canvas.width = this.#width
        this.canvas.height = this.#height
    }

    drawBackground() {
        this.ctx.fillStyle = this.#backgroundColor
        this.ctx.fillRect(0, 0, this.#width, this.#height)
    }

    drawGrid() {
        if (this.#grid) {
            for (let i = 0; i < this.size.cellNumberX; i++) {
                this.drawGridLine(i * this.#cellSize, i * this.#cellSize, 0, this.size.cellNumberY * this.#cellSize)
            }

            for (let j = 0; j < this.size.cellNumberY; j++) {
                this.drawGridLine(0, this.size.cellNumberX * this.#cellSize, j * this.#cellSize, j * this.#cellSize)
            }
        }
    }

    drawGridLine(x1, x2, y1, y2) {
        this.ctx.beginPath()
        this.ctx.lineWidth = 2
        this.ctx.moveTo(x1, y1)
        this.ctx.lineTo(x2, y2)
        this.ctx.strokeStyle = this.#gridColor
        this.ctx.stroke()
    }

    get size() {
        return {
            cellNumberX: Math.ceil(this.#width / this.#cellSize),
            cellNumberY: Math.ceil(this.#height / this.#cellSize),
            cellSize: this.#cellSize,
        }
    }

    get context() {
        return this.ctx
    }

    set grid(grid) {
        this.#grid = grid
    }

    get grid() {
        return this.#grid
    }
}