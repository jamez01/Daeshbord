document.addEventListener('DOMContentLoaded', function() {
  setTimeout(function() {
    var flash = document.querySelector('.flash');
    if (flash) {
      flash.classList.add('fade-out');
      setTimeout(function() {
        flash.style.display = 'none';
      }, 500);
    }
  }, 4000);

  document.querySelectorAll('.dropdown-icon').forEach(function(icon) {
    icon.addEventListener('click', function() {
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