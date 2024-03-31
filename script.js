document.addEventListener('DOMContentLoaded', function () {
    const anchors = document.querySelectorAll('h1 a, h2 a, h3 a, h4 a, h5 a, h6 a'); // Select anchors within heading tags

    anchors.forEach(anchor => {
        // Generate random positions
        const x = Math.random() * (window.innerWidth - anchor.clientWidth);
        const y = Math.random() * (window.innerHeight - anchor.clientHeight);

        // Apply absolute positioning
        anchor.style.position = 'relative';
        anchor.style.left = `${x}px`;
        anchor.style.top = `${y}px`;

        // Generate a random color
        const randomColor = `rgb(${Math.floor(Math.random() * 256)}, ${Math.floor(Math.random() * 256)}, ${Math.floor(Math.random() * 256)})`;
        anchor.style.color = randomColor;
    });
    
});

document.addEventListener('DOMContentLoaded', function () {
  const anchors = document.querySelectorAll('h1 a, h2 a, h3 a, h4 a, h5 a, h6 a');
  anchors.forEach(anchor => {
      const baseColor = getRandomColor();
      anchor.style.color = baseColor;
      anchor.onmouseover = () => anchor.style.color = getRandomColor();
      anchor.onmouseout = () => anchor.style.color = baseColor;
  });

  function getRandomColor() {
      return `rgb(${Math.floor(Math.random() * 256)}, ${Math.floor(Math.random() * 256)}, ${Math.floor(Math.random() * 256)})`;
  }
});