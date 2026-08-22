document.addEventListener('DOMContentLoaded', () => {
  
  // 1. Navbar Scroll Effect
  const header = document.getElementById('main-header');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  });

  // 2. Scroll Reveal Animations
  const reveals = document.querySelectorAll('.reveal');

  const revealOnScroll = () => {
    const windowHeight = window.innerHeight;
    const elementVisible = 150;

    reveals.forEach((reveal) => {
      const elementTop = reveal.getBoundingClientRect().top;
      if (elementTop < windowHeight - elementVisible) {
        reveal.classList.add('active');
      }
    });
  };

  // Initial trigger
  revealOnScroll();
  
  // Trigger on scroll
  window.addEventListener('scroll', revealOnScroll);

  // 3. Mobile Language Switcher Support
  const langSwitcher = document.querySelector('.lang-switcher');
  if (langSwitcher) {
    const langBtn = langSwitcher.querySelector('a');
    langBtn.addEventListener('click', (e) => {
      e.preventDefault();
      langSwitcher.classList.toggle('active');
    });

    // Close when clicking outside
    document.addEventListener('click', (e) => {
      if (!langSwitcher.contains(e.target)) {
        langSwitcher.classList.remove('active');
      }
    });
  }

  // End of scroll listener
});
