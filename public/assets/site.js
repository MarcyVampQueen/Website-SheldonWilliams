document.querySelectorAll('[data-menu-toggle]').forEach((toggle) => {
  const menu = document.getElementById(toggle.getAttribute('aria-controls'));

  toggle.addEventListener('click', () => {
    const isOpen = menu.classList.toggle('is-open');
    toggle.setAttribute('aria-expanded', String(isOpen));
  });
});

document.querySelectorAll('.nav-links a').forEach((link) => {
  link.addEventListener('click', () => {
    const menu = link.closest('.nav-links');
    if (menu) menu.classList.remove('is-open');
  });
});
