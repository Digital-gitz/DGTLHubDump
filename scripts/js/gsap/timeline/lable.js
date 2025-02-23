"use strict"

let tl = gsap.timeline({ 
  defaults: 
    {duration: 2, ease: "power1.inOut", yoyo: true, repeat: -1}
})

  .to("#cr1", {x: 500})
  .to("#cr2", {x: 461.94, y: -191.64},"<0.25")
  .to("#cr3", {x: 353.55, y: -353.56},"<0.25")
  .to("#cr4", {x: 191.34, y: -461.94},"<0.25")
  .to("#cr5", {y: -500},"lb")
  .to("#cr6", {x: -191.35, y: -461.94},"lb-=0.25")
  .to("#cr7", {x: -353.55, y: -353.56},"lb-=0.5")
  .to("#cr8", {x: -461.94, y: -191.34},"lb-=0.75")






  




