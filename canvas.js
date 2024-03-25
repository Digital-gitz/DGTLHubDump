<!-- // Start the main loop -->
mainLoop();


    // Get reference to the canvas element
    var canvas = document.getElementById('canvas');

    // Function to resize the canvas to match the viewport dimensions
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }

    // Call resizeCanvas() initially to set initial dimensions
    resizeCanvas();

    // Add event listener to resize the canvas when the window is resized
    window.addEventListener('resize', resizeCanvas);