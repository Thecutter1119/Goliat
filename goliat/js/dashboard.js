  if (localStorage.getItem('tema') === 'claro') {
      document.documentElement.classList.add('modo-claro');
    }
  
  
  /* ============================================================
     VERIFICACIÓN DE SESIÓN (ROUTE GUARD)
     ============================================================ */
  const token = localStorage.getItem('auth_token');
  if (!token) {
    // Si no hay token, redirigimos al login inmediatamente
    window.location.replace('../login/login.php');
  }

  /* ============================================================
     TOGGLE TEMA CLARO / OSCURO
     ============================================================ */
  const toggleTema  = document.getElementById('toggleTema');
  const iconoTema   = document.getElementById('iconoTema');
  const logoOscuro  = document.querySelectorAll('.logo-oscuro');
  const logoClaro   = document.querySelectorAll('.logo-claro');

  function aplicarTema(claro) {
    if (claro) {
      document.documentElement.classList.add('modo-claro');
      iconoTema.textContent = '🌙';
      logoOscuro.forEach(l => l.style.display = 'none');
      logoClaro.forEach(l  => l.style.display = 'block');
    } else {
      document.documentElement.classList.remove('modo-claro');
      iconoTema.textContent = '☀️';
      logoOscuro.forEach(l => l.style.display = 'block');
      logoClaro.forEach(l  => l.style.display = 'none');
    }
  }

  // Carga preferencia guardada
  aplicarTema(localStorage.getItem('tema') === 'claro');

  toggleTema.addEventListener('click', () => {
    const esClaro = !document.documentElement.classList.contains('modo-claro');
    aplicarTema(esClaro);
    localStorage.setItem('tema', esClaro ? 'claro' : 'oscuro');
  });


  /* ============================================================
     SIDEBAR MÓVIL
     ============================================================ */
  const sidebar    = document.getElementById('sidebar');
  const overlay    = document.getElementById('overlay');
  const btnMenu    = document.getElementById('btnHamburguesa');

  btnMenu.addEventListener('click', () => {
    sidebar.classList.toggle('abierto');
    overlay.classList.toggle('visible');
  });

  overlay.addEventListener('click', () => {
    sidebar.classList.remove('abierto');
    overlay.classList.remove('visible');
  });

const contenidoPrincipal = document.getElementById("contenido-principal");

const dashboardInicial = contenidoPrincipal.innerHTML;

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

async function apiRequest(action, method = 'GET', data = {}) {
  const url = new URL('../api.php', window.location.href);
  url.searchParams.set('action', action);

  const options = { method, headers: { 'Accept': 'application/json' } };
  if (method !== 'GET') {
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8';
    options.body = new URLSearchParams(data).toString();
  } else {
    Object.entries(data).forEach(([k, v]) => url.searchParams.set(k, v));
  }

  const res = await fetch(url.toString(), options);
  const json = await res.json().catch(() => null);
  if (!res.ok || !json || json.ok !== true) {
    const msg = json && json.error ? json.error : `http_${res.status}`;
    throw new Error(msg);
  }
  return json.data ?? json;
}
  /* ============================================================
     ÍTEM ACTIVO DEL SIDEBAR
     Al hacer clic en un ítem del menú, actívalo visualmente
     ============================================================ */
  document.querySelectorAll('.sidebar-item').forEach(item => {
    item.addEventListener('click', function(e) {
      // Solo cambia el activo si no es "Cerrar sesión"
      if (!this.querySelector('svg path[d*="M17 16"]')) {
        document.querySelectorAll('.sidebar-item').forEach(i => i.classList.remove('activo'));
        this.classList.add('activo');
      }
    });
  });

/* ============================================================
   NAVEGACIÓN SPA (Carga dinámica de vistas)
   ============================================================ */

/**
 * Carga una vista parcial HTML y la inyecta en el contenedor principal.
 * @param {string} url - La ruta del archivo HTML a cargar.
 */
async function renderProcesos() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Mis Procesos</h1>
      <p class="pagina-subtitulo">Crea y lista expedientes en tu base de datos.</p>
    </div>
    <div class="tabla-card" style="margin-bottom:16px;">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Nuevo proceso</div>
      </div>
      <div style="padding:16px;">
        <form id="form-proceso" style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; align-items:end;">
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Número de radicado</label>
            <input name="num_radicado" required style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Observación</label>
            <input name="obs_expediente" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div style="grid-column: 1 / -1; display:flex; gap:10px; align-items:center;">
            <button type="submit" id="btn-crear-proceso" class="btn-cerrar-sesion2" style="background: var(--rojo);">Crear proceso</button>
            <div id="msg-proceso" style="font-size:13px; opacity:0.85;"></div>
          </div>
        </form>
      </div>
    </div>
    <div class="tabla-card">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Procesos</div>
        <a href="#" class="tabla-card-accion" id="btn-recargar-procesos">Recargar →</a>
      </div>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Identificador</th>
            <th>Radicado</th>
            <th>Estado</th>
            <th>Fecha</th>
          </tr>
        </thead>
        <tbody id="tabla-procesos"></tbody>
      </table>
    </div>
  `;

  const tbody = document.getElementById('tabla-procesos');
  const msg = document.getElementById('msg-proceso');

  const cargar = async () => {
    tbody.innerHTML = `<tr><td colspan="5">Cargando...</td></tr>`;
    try {
      const data = await apiRequest('procesos_list');
      if (!data.length) {
        tbody.innerHTML = `<tr><td colspan="5">Sin procesos todavía.</td></tr>`;
        return;
      }
      tbody.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_expediente)}</td>
          <td>${escapeHtml(row.identificador_interno)}</td>
          <td>${escapeHtml(row.num_radicado)}</td>
          <td><span class="badge badge-activo">${escapeHtml(row.cod_estado_proceso)}</span></td>
          <td>${escapeHtml(row.fec_reparto || '')}</td>
        </tr>
      `).join('');
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="5">Error cargando procesos: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  const form = document.getElementById('form-proceso');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn-crear-proceso');
    btn.disabled = true;
    msg.textContent = 'Creando...';
    try {
      const fd = new FormData(form);
      await apiRequest('proceso_create', 'POST', {
        num_radicado: fd.get('num_radicado'),
        obs_expediente: fd.get('obs_expediente'),
      });
      form.reset();
      msg.textContent = 'Creado.';
      await cargar();
    } catch (err) {
      msg.textContent = `Error: ${err.message}`;
    } finally {
      btn.disabled = false;
    }
  });

  const btnRecargar = document.getElementById('btn-recargar-procesos');
  btnRecargar.addEventListener('click', async (e) => {
    e.preventDefault();
    await cargar();
  });

  await cargar();
}

async function renderPersonas() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Personas</h1>
      <p class="pagina-subtitulo">Crea y lista personas (clientes, partes, etc.).</p>
    </div>
    <div class="tabla-card" style="margin-bottom:16px;">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Nueva persona</div>
      </div>
      <div style="padding:16px;">
        <form id="form-persona" style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; align-items:end;">
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Documento</label>
            <input name="id_persona" required style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Tipo</label>
            <select name="id_tipo_doc" id="sel-tipo-doc" required style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);"></select>
          </div>
          <div style="grid-column: 1 / -1;">
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Nombre completo</label>
            <input name="nom_y_ape_completos" required style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Email</label>
            <input name="email_persona" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Teléfono</label>
            <input name="tel_persona" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div style="grid-column: 1 / -1; display:flex; gap:10px; align-items:center;">
            <button type="submit" id="btn-crear-persona" class="btn-cerrar-sesion2" style="background: var(--rojo);">Crear persona</button>
            <div id="msg-persona" style="font-size:13px; opacity:0.85;"></div>
          </div>
        </form>
      </div>
    </div>
    <div class="tabla-card">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Personas</div>
        <a href="#" class="tabla-card-accion" id="btn-recargar-personas">Recargar →</a>
      </div>
      <table>
        <thead>
          <tr>
            <th>Documento</th>
            <th>Tipo</th>
            <th>Nombre</th>
            <th>Email</th>
            <th>Teléfono</th>
          </tr>
        </thead>
        <tbody id="tabla-personas"></tbody>
      </table>
    </div>
  `;

  const selTipo = document.getElementById('sel-tipo-doc');
  const tbody = document.getElementById('tabla-personas');
  const msg = document.getElementById('msg-persona');

  const cargarTipos = async () => {
    selTipo.innerHTML = `<option value="">Cargando...</option>`;
    try {
      const tipos = await apiRequest('tipos_doc_list');
      selTipo.innerHTML = `<option value="">Seleccionar</option>` + tipos.map(t => `<option value="${escapeHtml(t.id_tipo_doc)}">${escapeHtml(t.cod_tipo_doc)} - ${escapeHtml(t.des_tipo_doc)}</option>`).join('');
    } catch (e) {
      selTipo.innerHTML = `<option value="">Error</option>`;
    }
  };

  const cargar = async () => {
    tbody.innerHTML = `<tr><td colspan="5">Cargando...</td></tr>`;
    try {
      const data = await apiRequest('personas_list');
      if (!data.length) {
        tbody.innerHTML = `<tr><td colspan="5">Sin personas todavía.</td></tr>`;
        return;
      }
      tbody.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_persona)}</td>
          <td>${escapeHtml(row.cod_tipo_doc)}</td>
          <td>${escapeHtml(row.nom_y_ape_completos)}</td>
          <td>${escapeHtml(row.email_persona || '')}</td>
          <td>${escapeHtml(row.tel_persona || '')}</td>
        </tr>
      `).join('');
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="5">Error cargando personas: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  const form = document.getElementById('form-persona');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn-crear-persona');
    btn.disabled = true;
    msg.textContent = 'Creando...';
    try {
      const fd = new FormData(form);
      await apiRequest('persona_create', 'POST', {
        id_persona: fd.get('id_persona'),
        id_tipo_doc: fd.get('id_tipo_doc'),
        nom_y_ape_completos: fd.get('nom_y_ape_completos'),
        email_persona: fd.get('email_persona'),
        tel_persona: fd.get('tel_persona'),
      });
      form.reset();
      msg.textContent = 'Creada.';
      await cargar();
    } catch (err) {
      msg.textContent = `Error: ${err.message}`;
    } finally {
      btn.disabled = false;
    }
  });

  const btnRecargar = document.getElementById('btn-recargar-personas');
  btnRecargar.addEventListener('click', async (e) => {
    e.preventDefault();
    await cargar();
  });

  await cargarTipos();
  await cargar();
}

function renderAgenda() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Agenda</h1>
      <p class="pagina-subtitulo">Audiencias y vencimientos (demo).</p>
    </div>
    <div class="panel-card">
      <div class="panel-card-header">
        <div class="panel-card-titulo">Próximos eventos</div>
      </div>
      <div class="evento-item">
        <div class="evento-fecha">
          <div class="evento-dia">18</div>
          <div class="evento-mes">Mar</div>
        </div>
        <div class="evento-info">
          <div class="evento-nombre">Audiencia inicial</div>
          <div class="evento-caso">Caso #2024-081 · 9:00 AM</div>
        </div>
      </div>
      <div class="evento-item">
        <div class="evento-fecha">
          <div class="evento-dia">21</div>
          <div class="evento-mes">Mar</div>
        </div>
        <div class="evento-info">
          <div class="evento-nombre">Entrega de pruebas</div>
          <div class="evento-caso">Caso #2024-074 · 2:00 PM</div>
        </div>
      </div>
    </div>
  `;
}

function renderDocumentos() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Documentos</h1>
      <p class="pagina-subtitulo">Repositorio de archivos por expediente (demo).</p>
    </div>
    <div class="tabla-card">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Documentos recientes (demo)</div>
        <a href="#" class="tabla-card-accion" id="btnSubirDoc">Subir →</a>
      </div>
      <table>
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Tipo</th>
            <th>Fecha</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Poder.pdf</td>
            <td>PDF</td>
            <td>10 Mar</td>
          </tr>
          <tr>
            <td>Demanda.docx</td>
            <td>DOCX</td>
            <td>08 Mar</td>
          </tr>
        </tbody>
      </table>
    </div>
  `;

  const btnSubir = document.getElementById('btnSubirDoc');
  if (btnSubir) {
    btnSubir.addEventListener('click', (e) => {
      e.preventDefault();
      alert('Módulo en construcción: aquí iría la carga de documentos.');
    });
  }
}

function renderConfiguracion() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Configuración</h1>
      <p class="pagina-subtitulo">Parámetros y administración (demo).</p>
    </div>
    <div class="tabla-card">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Sesión</div>
      </div>
      <div style="padding:16px;">
        <div><strong>Token local:</strong> <span id="token-local"></span></div>
      </div>
    </div>
  `;

  const el = document.getElementById('token-local');
  if (el) el.textContent = localStorage.getItem('auth_token') || '';
}

// Asignar eventos a los botones del menú usando la nueva función
document.getElementById("btnProcesos").addEventListener("click", (e) => {
  e.preventDefault();
  void renderProcesos();
});

document.getElementById("btnAgenda").addEventListener("click", (e) => {
  e.preventDefault();
  renderAgenda();
});

document.getElementById("btonDocumentos").addEventListener("click", (e) => {
  e.preventDefault();
  renderDocumentos();
});

document.getElementById("btnPersonas").addEventListener("click", (e) => {
  e.preventDefault();
  void renderPersonas();
});

document.getElementById("btnConfiguracion").addEventListener("click", (e) => {
  e.preventDefault();
  renderConfiguracion();
});

document.getElementById("btnDashboard").addEventListener("click", (e) => {
  e.preventDefault();
  // El dashboard principal ya lo tenemos guardado en la variable dashboardInicial
  contenidoPrincipal.innerHTML = dashboardInicial;
});

/* ============================================================
   CERRAR SESIÓN
   ============================================================ */

document.getElementById("btnCerrarSesion").addEventListener("click", function(e) {
  e.preventDefault();
  const confirmar = confirm("¿Deseas cerrar sesión?");
  if (confirmar) {
    localStorage.clear();
    window.location.href = "../index.html";
  }
});
