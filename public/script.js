function fetchServiceIcon(hostname, scheme, elementId) {
  const iconUrls = [
    `${scheme}://${hostname}/android-512x512.png`,
    `${scheme}://${hostname}/apple-icon-180x180.png`,
    `${scheme}://${hostname}/apple-icon-152x152.png`,
    `${scheme}://${hostname}/apple-icon-144x144.png`,
    `${scheme}://${hostname}/ms-icon-144x144.png`,
    `${scheme}://${hostname}/apple-icon-120x120.png`,
    `${scheme}://${hostname}/apple-icon-114x114.png`,
    `${scheme}://${hostname}/apple-icon-76x76.png`,
    `${scheme}://${hostname}/apple-icon-72x72.png`,
    `${scheme}://${hostname}/apple-icon-60x60.png`,
    `${scheme}://${hostname}/apple-icon-57x57.png`,
    `${scheme}://${hostname}/android-192x192.png`,
    `${scheme}://${hostname}/apple-touch-icon.png`,
    `${scheme}://${hostname}/favicon-16x16.png`,
    `${scheme}://${hostname}/favicon.ico`
  ];

  const iconElement = document.getElementById(elementId);

  function tryNextIcon(index) {
    if (index >= iconUrls.length) {
      iconElement.innerHTML = '<p>No icon found</p>';
      return;
    }

    const img = new Image();
    img.src = iconUrls[index];
    img.onload = () => {
      iconElement.innerHTML = `<img src="${img.src}" alt="Service Icon">`;
    };
    img.onerror = () => {
      tryNextIcon(index + 1);
    };
  }

  tryNextIcon(0);
}