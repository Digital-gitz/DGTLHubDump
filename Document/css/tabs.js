/* eslint-disable */

var $tabs = $('.tabs .tab');

$tabs.click(function(event) {
  var selectedClass = 'is-tab-selected';
  $tabs.removeClass(selectedClass);
  $(event.target).addClass(selectedClass);
});