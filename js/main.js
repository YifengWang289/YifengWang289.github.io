// 1) Project picker: hover or click a category on the left to swap the projects on the right.
(function () {
  var tabs = document.querySelectorAll('.cats [role="tab"]');
  if (!tabs.length) return;
  function select(tab) {
    tabs.forEach(function (t) {
      var on = t === tab;
      t.setAttribute('aria-selected', on ? 'true' : 'false');
      var p = document.getElementById(t.getAttribute('aria-controls'));
      if (p) { p.hidden = !on; if (on) { var g = p.querySelector('.grid'); if (g) g.scrollLeft = 0; } }
    });
  }
  tabs.forEach(function (t) {
    t.addEventListener('click', function () { select(t); });
    t.addEventListener('mouseenter', function () { if (matchMedia('(hover:hover)').matches) select(t); });
    t.addEventListener('keydown', function (e) {
      var i = Array.prototype.indexOf.call(tabs, t), n = null;
      if (e.key === 'ArrowDown' || e.key === 'ArrowRight') n = tabs[(i + 1) % tabs.length];
      if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') n = tabs[(i - 1 + tabs.length) % tabs.length];
      if (n) { e.preventDefault(); n.focus(); select(n); }
    });
  });
  select(tabs[0]);
})();

// 2) Scroll reveal: fade-up once when an element enters the viewport. Without JS everything stays visible.
(function () {
  window.__revealReady = true;
  var els = document.querySelectorAll('.reveal');
  function show(el) {
    el.classList.add('in');
    // if the animation clock stalls (background tab, throttled pane), still end visible
    setTimeout(function () { el.classList.add('done'); }, 1700);
  }
  if (!('IntersectionObserver' in window)) { els.forEach(show); return; }
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (en) {
      if (en.isIntersecting) { show(en.target); io.unobserve(en.target); }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -4% 0px' });
  els.forEach(function (e) { io.observe(e); });
})();

// 3) Dock: highlight the section in view.
(function () {
  var links = document.querySelectorAll('.dock a[href^="#"]:not(.mark):not(.btn)');
  var map = {};
  links.forEach(function (a) { map[a.getAttribute('href').slice(1)] = a; });
  var secs = Object.keys(map).map(function (id) { return document.getElementById(id); }).filter(Boolean);
  if (!secs.length || !('IntersectionObserver' in window)) return;
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (en) {
      if (!en.isIntersecting) return;
      links.forEach(function (a) { a.removeAttribute('aria-current'); });
      var a = map[en.target.id]; if (a) a.setAttribute('aria-current', 'true');
    });
  }, { rootMargin: '-45% 0px -50% 0px' });
  secs.forEach(function (s) { io.observe(s); });
})();

// 4) Hero photo: a few pixels of parallax on desktop.
(function () {
  var img = document.querySelector('.hero-photo img');
  if (!img || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  var ticking = false;
  function update() {
    ticking = false;
    if (innerWidth < 860) { img.style.transform = ''; return; }
    var y = Math.min(window.scrollY * 0.05, 28);
    img.style.transform = 'translate3d(0,' + y + 'px,0) scale(1.08)';
  }
  addEventListener('scroll', function () { if (!ticking) { ticking = true; requestAnimationFrame(update); } }, { passive: true });
})();
