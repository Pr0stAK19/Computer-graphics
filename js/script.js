
document.addEventListener("DOMContentLoaded", () => {
    const menuToggle = document.getElementById('menuToggle');
    const mainMenu = document.getElementById('mainMenu');

    if (menuToggle && mainMenu) {
        menuToggle.addEventListener('click', () => {
            mainMenu.classList.toggle('active');
            // Анимация иконки (опционально)
            menuToggle.classList.toggle('open');
        });
    }
});

const scrollBtn = document.getElementById("scrollTop");
window.onscroll = function() {
    if (document.body.scrollTop > 100 || document.documentElement.scrollTop > 100) {
        scrollBtn.style.display = "block";
    } else {
        scrollBtn.style.display = "none";
    }
};

scrollBtn.addEventListener("click", (e) => {
    e.preventDefault();
    window.scrollTo({ top: 0, behavior: 'smooth' });
});

document.addEventListener('DOMContentLoaded', function() {
    const leavesLayer = document.querySelector('.leaves-layer');
    const scrollTopBtn = document.getElementById('scrollTop');

    function updateParallax() {
        if (!leavesLayer) return;

        const scrollPosition = window.pageYOffset;
        let slowScroll = scrollPosition * 0.2;
        const textureHeight = 320;
        slowScroll = slowScroll % textureHeight;
        leavesLayer.style.transform = `translateY(${slowScroll}px)`;
    }

    let ticking = false;
    window.addEventListener('scroll', function() {
        if (!ticking) {
            requestAnimationFrame(function() {
                updateParallax();
                ticking = false;
            });
            ticking = true;
        }
    });

    updateParallax();

    if (scrollTopBtn) {
        window.addEventListener('scroll', function() {
            if (window.pageYOffset > 300) {
                scrollTopBtn.classList.add('visible');
            } else {
                scrollTopBtn.classList.remove('visible');
            }
        });

        scrollTopBtn.addEventListener('click', function(e) {
            e.preventDefault();
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }

    const counterElement = document.getElementById('visitor-counter');
    if (counterElement) {
        let count = localStorage.getItem('visitorCount');
        if (count === null) {
            count = 1;
        } else {
            count = parseInt(count) + 1;
        }
        localStorage.setItem('visitorCount', count);
        counterElement.textContent = `Посетителей: ${count}`;
    }
});