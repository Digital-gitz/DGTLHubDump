"use strict";

gsap.registerPlugin(MotionPathPlugin);

let timeline = gsap.timeline({
  repeat: 2, 
  repeatDelay: 5, 
  defaults: {duration: 12, ease: "power1.inOut"}
})

  .to("#hand", {
    motionPath: {
      path:"#path", 
      align:"#path", 
      alignOrigin:[0.28, 0.08]}
  })

  .to("#path", {strokeDasharray: "4046, " + "0"}, "<");  

document.getElementById("pause").onclick = () => timeline.pause();
document.getElementById("play").onclick = () => timeline.play();
document.getElementById("reverse").onclick = () => timeline.reverse();
document.getElementById("seek").onclick = () => timeline.seek(5);
document.getElementById("restart").onclick = () => timeline.restart();

//Calculating path length:
//console.log(document.getElementById("path").getTotalLength());