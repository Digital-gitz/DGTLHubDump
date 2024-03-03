const canvas = document.getElementById("myCanvas");
canvas.width = 300;
canvas.height = 300;



const ctx = canvas.getContext("2d");
ctx.translate(canvas.width/2,canvas.height/2);
ctx.scale(canvas.width*0.5, canvas.height*0.5);
const img = new Image();
img.src="headshot216.png"

const A={x:0, y:-0.13};

img.onload=function(){
    ctx.globalAlpha=0.2;
    ctx.drawImage(img,-1,-1,2,2);
    ctx.globalAlpha=1;
    
    drawMe();
}

// Util to get cords of mouse click
canvas.addEventListener("click", getCoordinates);
function getCoordinates(evt){
    const x=(evt.x-canvas.width/2)/(canvas.width/2);
    const y=(evt.y-canvas.width/2)/(canvas.width/2);
    console.log(x.toFixed(2),y.toFixed(2));
}

function drawMe(){
drawHead();

drawPoint(A,"A")

}


function updatePoint(info){
    console.log(info.value);
}


function drawHead(){
    ctx.lineWidth=0.01;
    ctx.beginPath();
    ctx.moveTo(0,-0.77);
    ctx.lineTo(0,0.46);
    ctx.moveTo(0.5,-0.13);
    ctx.lineTo(0.5,-0.13);
    ctx.stroke();


    ctx.beginPath();
    ctx.moveTo(0,-0.77);
    ctx.quadraticCurveTo(-0.44,-0.71,-0.5,-0.13);
    ctx.quadraticCurveTo(-0.37,0.28,0,46);
    ctx.stroke();
}

function drawBody() {
    ctx.arch(loc.x,loc.y,rad,0,Math.PI*2);
    ctx.fill();
    ctx.fillStyle="while";
    ctx.font-(rad*1.6)+"px Arial";
    ctx.textAlighn="center";
    ctx.textBaseline="middle";
    ctx.fillText(label,loc.x,loc.y+rad*0.15)
}

// function drawPoint(loc,lable,)