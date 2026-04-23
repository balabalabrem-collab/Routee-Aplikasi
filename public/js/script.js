/* ===================================================
   ROUTEE — script.js  (v2 Refined)
   Interactive Features — No Framework, No API
   =================================================== */

document.addEventListener('DOMContentLoaded', function () {

    // ── PAGE TRANSITION ───────────────────────────────
    const overlay = document.getElementById('page-overlay');

    // Intercept all internal navigation links for smooth page transition
    document.querySelectorAll('a[href]').forEach(link => {
        const href = link.getAttribute('href');
        // Skip anchor links, external links, empty hrefs, JS links
        if (!href || href.startsWith('#') || href.startsWith('http') ||
            href.startsWith('mailto') || href.startsWith('javascript')) return;

        link.addEventListener('click', function (e) {
            const target = this.getAttribute('href');
            if (!target || target === window.location.pathname) return;
            e.preventDefault();
            if (overlay) {
                overlay.classList.add('leaving');
                setTimeout(() => { window.location.href = target; }, 320);
            } else {
                window.location.href = target;
            }
        });
    });

    // ── NAVBAR SCROLL ─────────────────────────────────
    const navbar = document.getElementById('navbar');
    if (navbar) {
        const onScroll = () => {
            navbar.classList.toggle('scrolled', window.scrollY > 40);
        };
        window.addEventListener('scroll', onScroll, { passive: true });
        onScroll(); // init
    }

    // ── HAMBURGER MENU ────────────────────────────────
    const hamburger  = document.getElementById('hamburger');
    const mobileMenu = document.getElementById('mobile-menu');

    if (hamburger && mobileMenu) {
        const toggle = (force) => {
            const open = force !== undefined ? force : !mobileMenu.classList.contains('open');
            mobileMenu.classList.toggle('open', open);
            hamburger.setAttribute('aria-expanded', String(open));
            mobileMenu.setAttribute('aria-hidden', String(!open));
        };

        hamburger.addEventListener('click', () => toggle());

        // Close when clicking a link
        mobileMenu.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => toggle(false));
        });

        // Close on outside click
        document.addEventListener('click', (e) => {
            if (!navbar.contains(e.target)) toggle(false);
        });
    }

    // ── EXPLORE TABS ──────────────────────────────────
    const tabBtns = document.querySelectorAll('.tab-btn[data-tab]');
    if (tabBtns.length > 0) {
        const activateTab = (target) => {
            tabBtns.forEach(b => b.classList.toggle('active', b.dataset.tab === target));
            document.querySelectorAll('.tab-content').forEach(panel => {
                panel.classList.toggle('active', panel.id === 'tab-content-' + target);
            });
        };

        tabBtns.forEach(btn => {
            btn.addEventListener('click', () => activateTab(btn.dataset.tab));
        });

        // Keyboard support
        const tabBar = document.querySelector('.tab-bar');
        if (tabBar) {
            tabBar.addEventListener('keydown', (e) => {
                const tabs = [...tabBtns];
                const idx  = tabs.findIndex(b => b === document.activeElement);
                if (idx === -1) return;
                if (e.key === 'ArrowRight') tabs[(idx + 1) % tabs.length].focus();
                if (e.key === 'ArrowLeft')  tabs[(idx - 1 + tabs.length) % tabs.length].focus();
                if (e.key === 'Enter') tabs[idx].click();
            });
        }
    }

    // ── TRANSPORT MODAL ───────────────────────────────
    document.querySelectorAll('[data-modal]').forEach(btn => {
        btn.addEventListener('click', () => {
            const type = btn.dataset.modal;
            const modal = document.getElementById('modal-' + type);
            if (modal) {
                modal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        });
    });
    document.querySelectorAll('[data-modal-close]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modal = btn.closest('.modal-overlay');
            if (modal) {
                modal.style.display = 'none';
                document.body.style.overflow = '';
            }
        });
    });
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.style.display = 'none';
                document.body.style.overflow = '';
            }
        });
    });
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay').forEach(m => {
                m.style.display = 'none';
                document.body.style.overflow = '';
            });
        }
    });

    // ── TRANSPORT CARD SELECTION ──────────────────────
    document.querySelectorAll('.transport-card').forEach(card => {
        card.addEventListener('click', function(e) {
            if (e.target.closest('.btn')) return; // allow button click to propagate
            document.querySelectorAll('.transport-card').forEach(c => c.classList.remove('selected'));
            this.classList.add('selected');
        });
    });

    // ── UMKM QUICK-BUY MODAL ──────────────────────────
    document.querySelectorAll('[data-umkm-modal]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modal = document.getElementById('umkm-modal');
            const name  = btn.dataset.umkmName  || 'Produk UMKM';
            const price = btn.dataset.umkmPrice || 'Rp 50.000';
            if (modal) {
                const nameEl  = modal.querySelector('#modal-product-name');
                const priceEl = modal.querySelector('#modal-product-price');
                if (nameEl)  nameEl.textContent  = name;
                if (priceEl) priceEl.textContent = price;
                modal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        });
    });

    // ── ADD TO TRIP BUTTON ────────────────────────────
    const addTripBtn = document.getElementById('add-trip-btn');
    if (addTripBtn) {
        addTripBtn.addEventListener('click', function () {
            this.textContent = '✅ Ditambahkan!';
            this.classList.replace('btn-primary', 'btn-outline');
            this.disabled = true;

            const toast = document.getElementById('add-toast');
            if (toast) {
                toast.style.display = 'flex';
                setTimeout(() => {
                    toast.style.opacity = '0';
                    toast.style.transition = 'opacity .5s';
                    setTimeout(() => { toast.style.display = 'none'; toast.style.opacity = ''; }, 500);
                }, 2800);
            }
        });
    }

    // ── HERO PLAN BUTTON ──────────────────────────────
    const planBtn = document.getElementById('hero-plan-btn');
    if (planBtn) {
        planBtn.addEventListener('click', function (e) {
            // The page transition handles navigation — just add loading feedback
            const btnText = this.querySelector('.btn-text');
            if (btnText) btnText.textContent = 'Menyiapkan rute...';
        });
    }

    // ── HERO CARD 3D TILT ─────────────────────────────
    const hcardFront = document.getElementById('hero-card-front');
    if (hcardFront && window.matchMedia('(hover:hover)').matches) {
        hcardFront.addEventListener('mousemove', (e) => {
            const rect = hcardFront.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width  / 2;
            const y = e.clientY - rect.top  - rect.height / 2;
            hcardFront.style.transform =
                `rotate(-2deg) rotateY(${x / 22}deg) rotateX(${-y / 22}deg)`;
        });
        hcardFront.addEventListener('mouseleave', () => {
            hcardFront.style.transform = 'rotate(-2deg)';
        });
    }

    // ── SCROLL REVEAL ──────────────────────────────────
    const revealEls = document.querySelectorAll(
        '.dest-card, .culinary-card, .step-card, .explore-card, ' +
        '.transport-card, .umkm-card, .timeline-item, .sidebar-card, ' +
        '.route-step, .nearby-card'
    );

    if ('IntersectionObserver' in window) {
        const io = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity    = '1';
                    entry.target.style.transform  = 'translateY(0) scale(1)';
                    io.unobserve(entry.target);
                }
            });
        }, { threshold: 0.07 });

        revealEls.forEach((el, i) => {
            if (window.scrollY < 50 || !isInViewport(el)) {
                el.style.opacity    = '0';
                el.style.transform  = 'translateY(20px) scale(.98)';
                el.style.transition = `opacity .5s ease ${Math.min(i * 0.06, 0.5)}s, transform .5s ease ${Math.min(i * 0.06, 0.5)}s`;
            }
            io.observe(el);
        });
    }

    function isInViewport(el) {
        const rect = el.getBoundingClientRect();
        return rect.top < window.innerHeight && rect.bottom > 0;
    }

    // ── ACTIVE NAV LINK ───────────────────────────────
    // This is now handled server-side via Blade, but JS fallback:
    const path = window.location.pathname;
    document.querySelectorAll('.nav-links a').forEach(link => {
        const href = link.getAttribute('href');
        if (href && href !== '/' && path.startsWith(href)) {
            link.classList.add('active');
        }
    });

    // ── IMAGE ERROR FALLBACK ──────────────────────────
    document.querySelectorAll('img[src]').forEach(img => {
        img.addEventListener('error', function () {
            if (!this.errored) {
                this.errored = true;
                this.src = '/images/placeholder.jpg';
            }
        });
    });

    // ── SMOOTH ANCHOR SCROLL ──────────────────────────
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                e.preventDefault();
                e.stopPropagation(); // prevent page transition handler
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });

    // ── CONSOLE WELCOME ───────────────────────────────
    console.log('%c🗺️ ROUTEE — Surabaya Heritage Trip Planner', 'color: #D39858; font-size: 16px; font-weight: bold;');
    console.log('%c✅ Running on Laravel 12 | UTS Universitas Teknologi Surabaya', 'color: #8A4E1E; font-size: 12px;');

});
