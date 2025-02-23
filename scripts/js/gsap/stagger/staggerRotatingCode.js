"use strict"
for (let i = 1; i < 23; i++) {
  document.body.innerHTML += 
    '<div class="code"><img src="images/' + i + '.png"></div>';
  }
let skip = 1, increment = 2;
let angleY = 0, angleZ = 0;
window.addEventListener('mousemove', function(e) {
  if (skip % 5 == 0) {
    if (angleY < -89) {
      if (angleY % 90 == 0) {
        increment = increment*(-1);
      }
    }
    gsap.to(".code", { 
      duration: 2, 
      rotateY: angleY,  
      rotateZ: -angleZ, 
      stagger: 0.1});
    skip +=1;
    angleY = angleY - 5 * Math.abs(increment);
    angleZ = angleZ + increment;
  };
  console.log("angleY=",angleY,"angleZ=",angleZ)
  skip +=1;
}, false);

