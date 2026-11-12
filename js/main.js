// 1) Project picker: click a category on the left to swap the projects on the right.
//    One tab stop for the whole group (arrow keys / Home / End move between tabs); the choice is mirrored in the URL hash.
(function () {
  var tabs = document.querySelectorAll('.cats [role="tab"]');
  if (!tabs.length) return;
  var hashFor = function (t) { return '#projects-' + t.id.replace('tab-', ''); };
  function select(tab, sync) {
    tabs.forEach(function (t) {
      var on = t === tab;
      t.setAttribute('aria-selected', on ? 'true' : 'false');
      t.tabIndex = on ? 0 : -1;
      var p = document.getElementById(t.getAttribute('aria-controls'));
      if (p) { p.hidden = !on; if (on) { var g = p.querySelector('.grid'); if (g) g.scrollLeft = 0; } }
    });
    if (sync) { try { history.replaceState(null, '', hashFor(tab)); } catch (e) {} }
  }
  tabs.forEach(function (t, i) {
    t.addEventListener('click', function () { select(t, true); });
    t.addEventListener('keydown', function (e) {
      var n = null;
      if (e.key === 'ArrowDown' || e.key === 'ArrowRight') n = tabs[(i + 1) % tabs.length];
      if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') n = tabs[(i - 1 + tabs.length) % tabs.length];
      if (e.key === 'Home') n = tabs[0];
      if (e.key === 'End') n = tabs[tabs.length - 1];
      if (n) { e.preventDefault(); n.focus(); select(n, true); }
    });
  });
  function fromHash(scroll) {
    var m = Array.prototype.find.call(tabs, function (t) { return location.hash === hashFor(t); });
    select(m || tabs[0], false);
    if (m && scroll) { var sec = document.getElementById('projects'); if (sec) sec.scrollIntoView(); }
  }
  fromHash(true);
  addEventListener('hashchange', function () { fromHash(true); });
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

// 4) Name badge: tilts toward the pointer (mouse / pen), glare follows it, settles back on leave.
//    Touch and reduced-motion users get the static badge (a slow sway when motion is allowed).
(function () {
  var wrap = document.querySelector('.badge-wrap'), badge = document.getElementById('badge');
  if (!wrap || !badge || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  var raf = 0, px = 0, py = 0;
  function apply() {
    raf = 0;
    var r = badge.getBoundingClientRect(), w = wrap.getBoundingClientRect();
    var cx = r.left + r.width / 2, cy = r.top + r.height / 2;
    var nx = Math.max(-1, Math.min(1, (px - cx) / (w.width / 2))), ny = Math.max(-1, Math.min(1, (py - cy) / (w.height / 2)));
    badge.style.setProperty('--ry', (nx * 14).toFixed(2) + 'deg');
    badge.style.setProperty('--rx', (-ny * 10).toFixed(2) + 'deg');
    badge.style.setProperty('--rz', (nx * 3.5).toFixed(2) + 'deg');
    badge.style.setProperty('--gx', Math.round(50 + nx * 45) + '%');
    badge.style.setProperty('--gy', Math.round(40 + ny * 40) + '%');
  }
  wrap.addEventListener('pointermove', function (e) {
    if (e.pointerType === 'touch') return;
    badge.classList.add('live', 'touched'); px = e.clientX; py = e.clientY;
    if (!raf) raf = requestAnimationFrame(apply);
  });
  wrap.addEventListener('pointerleave', function () {
    badge.classList.remove('live');
    ['--rx', '--ry', '--rz'].forEach(function (k) { badge.style.removeProperty(k); });
  });
})();
