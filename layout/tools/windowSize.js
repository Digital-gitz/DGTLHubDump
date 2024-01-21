function getWindowSize() {
    var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    var height = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
  
    return { width: width, height: height };
  }
  
  // Get the current window size
  var size = getWindowSize();
  console.log("Window size: Width = " + size.width + ", Height = " + size.height);

  