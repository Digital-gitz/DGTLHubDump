/// <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script> 



integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous">
//this line adds a class of js to your html element,
//we add the class with javascript instead of just putting it in the html so if javascript isn't available,
// the preloader does not show up, because without javascript it won't fade out and would just be there forever.
document.documentElement.classList.add("js");
// dom is loaded
jQuery(document).ready(function ($) {
 // fade out preloader
 $("#preloader").fadeOut("slow", function () {
   $(this).remove();
 });
});