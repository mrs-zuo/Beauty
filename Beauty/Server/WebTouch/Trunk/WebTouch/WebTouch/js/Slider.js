var slider = Swipe(document.getElementById('slider'), {
    auto: 3000,
    continuous: true,
    callback: function(pos) {
      var i = bullets.length;
      while (i--) {
        bullets[i].className = ' ';
      }
      bullets[pos].className = 'on';
    }
  });
var bullets = document.getElementById('position').getElementsByTagName('li');
