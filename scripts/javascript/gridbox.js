let grid = document.getElementById("svg_grid");
let startX = 5;
let startY = 5;
let rectWidth = 60;
let rectHeight = 60;

let nrOfColumns = 4;
let nrOfRows = 4;

let horizontalPadding = 5;
let verticalPadding = 5;

let strokeWidth = 2;

let rectX = startX;

for (let colIdx = 0; colIdx < nrOfColumns; colIdx++) {

  let rectY = startY;

  for (let rowIdx = 0; rowIdx < nrOfRows; rowIdx++) {
      let rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
      rect.setAttribute("x",  rectX);
      rect.setAttribute("y",  rectY);
      rect.setAttribute("width", rectWidth );
      rect.setAttribute("height", rectHeight);
      rect.setAttribute("style", "fill:blue;stroke:green;stroke-width:" +
                                  strokeWidth +";fill-opacity:0.1;stroke-opacity:0.6");
      // Rounded corners
      rect.setAttribute("rx", "3%");
      rect.setAttribute("ry", "3%");

      grid.appendChild(rect);

      rectY += rectHeight + verticalPadding;
  }
  rectX += rectWidth + horizontalPadding;
}

// Resize the grid to fit its containing rectangles
let svgWidth = startX + nrOfColumns * (horizontalPadding + rectWidth + strokeWidth);
let svgHeight =  startY + nrOfRows * (verticalPadding + rectHeight + strokeWidth);
grid.setAttribute("width", svgWidth);
grid.setAttribute("height", svgHeight);