const canvas2 = document.getElementById("my2edCanvas");
const ctx2 = canvas2.getContext("2d");

// Set canvas size and position
canvas2.width = 300;
canvas2.height = 300;
ctx2.translate(canvas2.width / 2, canvas2.height / 2);

// Draw a face outline
ctx2.beginPath();
ctx2.arc(0, 0, 100, 0, Math.PI * 2); // Head
ctx2.moveTo(0, -20);
ctx2.moveTo(-30, 20);
ctx2.arc(0, 20, 30, 0, Math.PI); // Bottom half of the face (chin)
ctx2.stroke();

// Draw eyes
ctx2.beginPath();
ctx2.arc(-40, -20, 10, 0, Math.PI * 2); // Left eye
ctx2.arc(40, -20, 10, 0, Math.PI * 2); // Right eye
ctx2.fill();

