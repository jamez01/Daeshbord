document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.holder').forEach(function(holder) {
    var serviceName = holder.getAttribute('data-service');
    colorElement(serviceName, holder);
  });

  setTimeout(function() {
    var flash = document.querySelector('.flash');
    if (flash) {
      flash.classList.add('fade-out');
      setTimeout(function() {
        flash.style.display = 'none';
      }, 500);
    }
  }, 4000);

  function stringToColor(str) {
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    var color = 'hsl(' + (hash % 360) + ', 70%, 30%)'; // Ensure the background color is dark enough
    return color;
  }

  function colorElement(str, element) {
    var color = stringToColor(str);
    element.style.backgroundColor = color;
    element.style.color = '#ffffff'; // Ensure the font color is white
  }

  document.querySelectorAll('.dropdown-icon').forEach(function(icon) {
    icon.addEventListener('click', function() {
      document.querySelectorAll('.dropdown-content').forEach(function(content) {
        content.style.display = 'none';
      });
      var dropdownContent = this.nextElementSibling;
      dropdownContent.style.display = dropdownContent.style.display === 'block' ? 'none' : 'block';
    });
  });

  window.addEventListener('click', function(event) {
    if (!event.target.matches('.dropdown-icon')) {
      document.querySelectorAll('.dropdown-content').forEach(function(content) {
        content.style.display = 'none';
      });
    }
  });

});

