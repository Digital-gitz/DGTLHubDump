// Array of font families to choose from
const fontFamilies = [
    "'Londrina Outline', 'Newsreader', sans-serif",
    "'Newsreader', 'Londrina Outline', sans-serif",
    "'Times New Roman', serif",
    "'Arial', sans-serif",
    "'Verdana', sans-serif",
    "'Courier New', monospace"
];

// Function to select a random font family
function getRandomFontFamily() {
    const randomIndex = Math.floor(Math.random() * fontFamilies.length);
    return fontFamilies[randomIndex];
}

// Get the element to apply the random font family
const enterText = document.getElementById('enterText');

// Apply the random font family
if (enterText) {
    const randomFontFamily = getRandomFontFamily();
    enterText.style.fontFamily = randomFontFamily;
}