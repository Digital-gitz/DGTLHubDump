"use strict"

gsap.registerPlugin(MotionPathPlugin);

let timeline = gsap.timeline({
    repeat: 2, 
    repeatDelay: 5,
    defaults : { duration: 12, ease: "power1.inOut"}
})

// .to("#hand" {})