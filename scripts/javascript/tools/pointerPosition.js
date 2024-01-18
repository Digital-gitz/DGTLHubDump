document.addEventListener('mousemove', function(e) {
    var mouseX = e.pageX; // X coordinate of the mouse pointer relative to the whole document
    var mouseY = e.pageY; // Y coordinate of the mouse pointer relative to the whole document

    console.log("Mouse Position: X = " + mouseX + ", Y = " + mouseY);
});