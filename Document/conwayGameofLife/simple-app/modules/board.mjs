import {
    CELL_SIZE,
    BOARD_COLOR
} from './constants.mjs'

export class Board {
    #cellSize = CELL_SIZE
    #backgroundColor = BOARD_COLOR

    constructor(canvas) {
        this.canvas = canvas
        this.ctx = this.canvas.getContext("2d")
    }

    drawBackground() {
        const { width, height } = this.canvas

        this.ctx.fillStyle = this.#backgroundColor
        this.ctx.fillRect(0, 0, width, height)
    }

    get size() {
        const { width, height } = this.canvas

        return {
            cellNumberX: Math.ceil(width / this.#cellSize),
            cellNumberY: Math.ceil(height / this.#cellSize),
            cellSize: this.#cellSize,
        }
    }

    get context() {
        return this.ctx
    }
}
