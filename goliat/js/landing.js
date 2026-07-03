 const botonMenu = document.querySelector('.nav-hamburguesa');
  const enlacesNav = document.querySelector('.nav-enlaces');

  // Al hacer clic en las tres rayas, muestra u oculta el menú
  botonMenu.addEventListener('click', () => {
    enlacesNav.classList.toggle('menu-abierto');
  });

  // Al hacer clic en un enlace del menú, lo cierra automáticamente
  document.querySelectorAll('.nav-enlaces a').forEach(enlace => {
    enlace.addEventListener('click', () => {
      enlacesNav.classList.remove('menu-abierto');
    });
  });


  /* ============================================================
   TOGGLE MODO CLARO / OSCURO
   ============================================================ */
  const toggleTema = document.getElementById('toggleTema');
  const iconoTema = toggleTema.querySelector('.icono-tema');

  // Recupera preferencia guardada
  if (localStorage.getItem('tema') === 'claro') {
    document.body.classList.add('modo-claro');
    iconoTema.textContent = '🌙';
  }

  toggleTema.addEventListener('click', () => {
    const esModoClaro = document.body.classList.toggle('modo-claro');
    iconoTema.textContent = esModoClaro ? '🌙' : '☀️';
    localStorage.setItem('tema', esModoClaro ? 'claro' : 'oscuro');
  });

  /* ============================================================
   BANNER DE COOKIES
   ============================================================ */
  const cookieBanner = document.getElementById('cookie-banner');
  const btnAceptar = document.getElementById('btn-aceptar-cookies');
  const btnRechazar = document.getElementById('btn-rechazar-cookies');

  // Verificar si ya hay una preferencia guardada
  const cookiePreference = localStorage.getItem('cookies-aceptadas');

  if (!cookiePreference) {
    // Si no hay preferencia, mostramos el banner después de 1 segundo
    setTimeout(() => {
      if (cookieBanner) cookieBanner.classList.add('mostrar');
    }, 1000);
  }

  // Lógica para aceptar
  if (btnAceptar) {
    btnAceptar.addEventListener('click', () => {
      localStorage.setItem('cookies-aceptadas', 'true');
      cookieBanner.classList.remove('mostrar');
      // Aquí se podrían inicializar scripts de Google Analytics, etc.
    });
  }

  // Lógica para rechazar
  if (btnRechazar) {
    btnRechazar.addEventListener('click', () => {
      localStorage.setItem('cookies-aceptadas', 'false');
      cookieBanner.classList.remove('mostrar');
      // Aquí se asegura de NO cargar scripts de tracking
    });
  }

