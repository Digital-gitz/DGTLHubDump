"use strict";
function NewCircle(id, positionX, positionY, radius, fill) {
    this.id = id;
    this.positionX = positionX || 0;
    this.positionY = positionY || 0;
    this.radius = radius;
    this.fill = fill;

    this.draw = function() {
      svgContainer.innerHTML += `<circle id="${this.id}" 
        cx="${this.positionX}" cy="${this.positionY}" 
        r="${this.radius}" fill="${this.fill}" />`
     }
  }

function figureAssembly(){
  let x = 600, y = 300;
  let r = 200, color = "yellow";
  for (let j = 0; j < 40; j++) { 
    new NewCircle("cr", x, y, r, color).draw();
    r-=5;
    if ((j % 2) == 0) {color = "black"}
    else {color = "yellow"}
  }
}

figureAssembly();

window.addEventListener('mousemove', function(e) {
  gsap.to("#cr", {
    duration: 0.5, 
    x: e.pageX - 600, 
    y: e.pageY - 300, 
    ease: "power1.out", 
    stagger: 0.05})   
}, false)

 