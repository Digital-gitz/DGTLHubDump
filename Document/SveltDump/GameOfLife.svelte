<!-- src/GameOfLife.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    let canvas: HTMLCanvasElement;
  
    interface Cell {
      x: number;
      y: number;
      alive: boolean;
      context: CanvasRenderingContext2D;
    }


    onMount(() => {
      const context : CanvasRenderingContext2D = canvas.getContext('2d');
      const { width, height } = canvas.getBoundingClientRect();
      canvas.width = width;
      canvas.height = height;
      const cellSize: number = 10; // Size of the cells
      const rows: number = Math.floor(height / cellSize);
      const cols: number = Math.floor(width / cellSize);
      let cells: boolean[][] = createCells(rows, cols);
  
      function createCells(rows: number, cols: number): boolean[][] {
        let arr: boolean[][] = new Array(rows);
        for (let i = 0; i < arr.length; i++) {
          arr[i] = new Array(cols).fill(false);
        }
        return arr;
      }
  
      function draw(): void {
        context.clearRect(0, 0, width, height);
        for (let y = 0; y < rows; y++) {
          for (let x = 0; x < cols; x++) {
            context.beginPath();
            context.rect(x * cellSize, y * cellSize, cellSize, cellSize);
            context.fillStyle = cells[y][x] ? 'black' : 'white';
            context.fill();
            context.stroke();
          }
        }
      }
  
      function update(): void {
        cells = cells.map((row, y) =>
          row.map((cell, x) => {
            const neighbors = getNeighbors(x, y);
            const aliveNeighbors = neighbors.filter(n => cells[n[1]] && cells[n[1]][n[0]]).length;
            if (cell) return aliveNeighbors === 2 || aliveNeighbors === 3;
            return aliveNeighbors === 3;
          })
        );
        draw();
      }
  
      function getNeighbors(x: number, y: number): [number, number][] {
        return [
          [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
          [x - 1, y],                 [x + 1, y],
          [x - 1, y + 1], [x, y + 1], [x + 1, y + 1]
        ];
      }
  
      // Randomize initial state
      cells = cells.map(row => row.map(() => Math.random() < 0.5));
  
      draw();
      const interval: number = window.setInterval(update, 100);
  
      return () => {
        clearInterval(interval);
      };
    });
  </script>
  
  <style>
    canvas {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: -1;
    }
  </style>
  
  <canvas bind:this={canvas}></canvas>