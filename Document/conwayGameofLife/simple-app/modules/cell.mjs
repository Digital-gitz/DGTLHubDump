import {
    CELL_COLOR
} from "./constants.mjs"

export class Cell {
    #alive = true
    #neighbors = 0

    constructor(ctx, x, y, cellSize) {
        this.ctx = ctx

        this.x = x
        this.y = y
        this.cellSize = cellSize
    }

    nextGeneration() {
        if (!this.#alive && this.#neighbors === 3) {
            this.#alive = true
        } else {
            this.#alive = this.#alive && (this.#neighbors === 2 || this.#neighbors === 3)
        }
    }

    draw() {
        if (this.#alive) {
            this.ctx.fillStyle = CELL_COLOR
            this.ctx.fillRect(...this.#position)
        }
    }

    get #position() {
        return [
            this.x * this.cellSize,
            this.y * this.cellSize,
            this.cellSize,
            this.cellSize
        ]
    }

    set alive(alive) {
        this.#alive = alive
    }

    get alive() {
        return this.#alive
    }

    set neighbors(neighbors) {
        this.#neighbors = neighbors
    }
}
