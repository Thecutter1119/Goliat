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
  const raw = await res.text();
  let json = null;
  try {
    json = raw ? JSON.parse(raw) : null;
  } catch (_err) {
    json = null;
  }
  if (!res.ok || !json || json.ok !== true) {
    const msg = json && json.error
      ? (json.message ? `${json.error}: ${json.message}` : json.error)
      : (raw && raw.trim() ? raw.trim().slice(0, 300) : `http_${res.status}`);
    throw new Error(msg);
  }
  return json.data ?? json;
}

const appCache = {
  personas: null,
  personasSelect: null,
  personasSelectPromise: null,
  roles: null,
  tiposDoc: null,
  tiposActuacion: null,
};
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
      <p class="pagina-subtitulo">Crea, edita, elimina y vincula sujetos procesales.</p>
    </div>
    <div class="tabla-card" style="margin-bottom:16px;">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Proceso</div>
      </div>
      <div style="padding:16px;">
        <form id="form-proceso" style="display:grid; grid-template-columns: 120px 1fr 1fr auto; gap:12px; align-items:end;">
          <input type="hidden" name="id_expediente">
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">ID</label>
            <input id="proceso-id-readonly" disabled placeholder="Auto" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15); background:#f3f4f6;">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Número de radicado</label>
            <input name="num_radicado" required minlength="5" maxlength="40" placeholder="Ej: 11001400300120240012300" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Observación</label>
            <input name="obs_expediente" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div style="display:flex; gap:8px;">
            <button type="submit" id="btn-guardar-proceso" class="btn-cerrar-sesion2" style="background: var(--rojo);">Guardar</button>
            <button type="button" id="btn-cancelar-proceso" class="btn-cerrar-sesion2" style="background:#415A77;">Limpiar</button>
          </div>
          <div style="grid-column: 1 / -1;">
            <div id="msg-proceso" style="font-size:13px; opacity:0.85;"></div>
          </div>
          <div style="grid-column: 1 / -1; font-size:12px; opacity:0.7;">
            El ID y el identificador interno se generan automáticamente. Aquí solo debes ingresar el radicado y, si quieres, una observación.
          </div>
        </form>
      </div>
    </div>
    <div class="tabla-card" style="margin-bottom:16px;">
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
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody id="tabla-procesos"></tbody>
      </table>
    </div>
    <div class="tabla-card">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Sujetos del expediente seleccionado</div>
        <span id="sujetos-contexto" style="font-size:12px; opacity:0.75;">Selecciona un proceso</span>
      </div>
      <div style="padding:16px;">
        <form id="form-sujeto" style="display:grid; grid-template-columns: 1fr 1fr auto; gap:12px; align-items:end; margin-bottom:16px;">
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Persona</label>
            <select id="sel-sujeto-persona" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);"></select>
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Rol</label>
            <select id="sel-sujeto-rol" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);"></select>
          </div>
          <div style="display:flex; gap:8px;">
            <button type="submit" id="btn-agregar-sujeto" class="btn-cerrar-sesion2" style="background: var(--rojo);">Agregar</button>
          </div>
          <div style="grid-column: 1 / -1;">
            <div id="msg-sujetos" style="font-size:13px; opacity:0.85;"></div>
          </div>
        </form>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Documento</th>
              <th>Nombre</th>
              <th>Rol</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody id="tabla-sujetos"></tbody>
        </table>
      </div>
    </div>
    <div class="tabla-card" style="margin-top:16px;">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Actuaciones del expediente seleccionado</div>
        <span id="actuaciones-contexto" style="font-size:12px; opacity:0.75;">Selecciona un proceso</span>
      </div>
      <div style="padding:16px;">
        <form id="form-actuacion" style="display:grid; grid-template-columns: 160px 1fr 160px auto; gap:12px; align-items:end; margin-bottom:16px;">
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Tipo</label>
            <select id="sel-tipo-actuacion" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);"></select>
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Descripción</label>
            <input id="des-actuacion" minlength="3" placeholder="Ej: Presentación de demanda" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div>
            <label style="display:block; font-size:12px; opacity:0.8; margin-bottom:6px;">Fecha</label>
            <input type="date" id="fec-actuacion" style="width:100%; padding:10px; border-radius:10px; border:1px solid rgba(0,0,0,0.15);">
          </div>
          <div style="display:flex; gap:8px;">
            <button type="submit" id="btn-crear-actuacion" class="btn-cerrar-sesion2" style="background: var(--rojo);">Agregar</button>
          </div>
          <div style="grid-column: 1 / -1;">
            <div id="msg-actuaciones" style="font-size:13px; opacity:0.85;"></div>
          </div>
        </form>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Fecha</th>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody id="tabla-actuaciones"></tbody>
        </table>
      </div>
    </div>
  `;

  const form = document.getElementById('form-proceso');
  const tbody = document.getElementById('tabla-procesos');
  const msg = document.getElementById('msg-proceso');
  const procesoIdReadonly = document.getElementById('proceso-id-readonly');
  const sujetosContexto = document.getElementById('sujetos-contexto');
  const tablaSujetos = document.getElementById('tabla-sujetos');
  const msgSujetos = document.getElementById('msg-sujetos');
  const selPersona = document.getElementById('sel-sujeto-persona');
  const selRol = document.getElementById('sel-sujeto-rol');
  const actuacionesContexto = document.getElementById('actuaciones-contexto');
  const tablaActuaciones = document.getElementById('tabla-actuaciones');
  const msgActuaciones = document.getElementById('msg-actuaciones');
  const selTipoActuacion = document.getElementById('sel-tipo-actuacion');
  const inpDesActuacion = document.getElementById('des-actuacion');
  const inpFecActuacion = document.getElementById('fec-actuacion');
  let procesoSeleccionado = null;
  let sujetosCombosCargados = false;
  let tiposActuacionCargados = false;

  const renderPersonasSelect = (items) => {
    selPersona.innerHTML = `<option value="">Seleccionar persona</option>` + items.map((p) => `<option value="${escapeHtml(p.id_persona)}">${escapeHtml(p.id_persona)} - ${escapeHtml(p.nom_y_ape_completos)}</option>`).join('');
  };

  const resetForm = () => {
    form.reset();
    form.id_expediente.value = '';
    procesoIdReadonly.value = '';
    msg.textContent = '';
  };

  const cargarCombosSujetos = async () => {
    if (!appCache.roles) {
      appCache.roles = await apiRequest('roles_list');
    }
    selRol.innerHTML = `<option value="">Seleccionar rol</option>` + appCache.roles.map((r) => `<option value="${escapeHtml(r.id_rol_sujeto)}">${escapeHtml(r.nom_rol_sujeto)}</option>`).join('');

    if (appCache.personasSelect) {
      renderPersonasSelect(appCache.personasSelect);
      sujetosCombosCargados = true;
      return;
    }

    if (appCache.personas) {
      appCache.personasSelect = appCache.personas.map((p) => ({ id_persona: p.id_persona, nom_y_ape_completos: p.nom_y_ape_completos }));
      renderPersonasSelect(appCache.personasSelect);
      sujetosCombosCargados = true;
      return;
    }

    selPersona.innerHTML = `<option value="">Cargando personas...</option>`;
    if (!appCache.personasSelectPromise) {
      appCache.personasSelectPromise = apiRequest('personas_select_list')
        .then((items) => {
          appCache.personasSelect = items;
          renderPersonasSelect(items);
        })
        .catch((_e) => {
          selPersona.innerHTML = `<option value="">Error cargando personas</option>`;
        })
        .finally(() => {
          appCache.personasSelectPromise = null;
        });
    }
    sujetosCombosCargados = true;
  };

  const cargarSujetos = async () => {
    if (!procesoSeleccionado) {
      tablaSujetos.innerHTML = `<tr><td colspan="5">Selecciona un proceso.</td></tr>`;
      tablaActuaciones.innerHTML = `<tr><td colspan="5">Selecciona un proceso.</td></tr>`;
      return;
    }

    sujetosContexto.textContent = `Expediente ${procesoSeleccionado.id_expediente} · ${procesoSeleccionado.num_radicado}`;
    tablaSujetos.innerHTML = `<tr><td colspan="5">Cargando...</td></tr>`;
    try {
      const data = await apiRequest('sujetos_list', 'GET', { id_expediente: procesoSeleccionado.id_expediente });
      if (!data.length) {
        tablaSujetos.innerHTML = `<tr><td colspan="5">Sin sujetos todavía.</td></tr>`;
        return;
      }
      tablaSujetos.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_sujeto)}</td>
          <td>${escapeHtml(row.id_persona || '')}</td>
          <td>${escapeHtml(row.nom_y_ape_completos || '')}</td>
          <td>${escapeHtml(row.nom_rol_sujeto || row.id_rol_sujeto)}</td>
          <td>
            <button type="button" class="btn-cerrar-sesion2 btn-del-sujeto" data-id="${escapeHtml(row.id_sujeto)}" style="background:#6b7280; padding:6px 10px;">Quitar</button>
          </td>
        </tr>
      `).join('');

      document.querySelectorAll('.btn-del-sujeto').forEach((btn) => {
        btn.addEventListener('click', async () => {
          if (!confirm('¿Quitar este sujeto del expediente?')) return;
          try {
            await apiRequest('sujeto_delete', 'POST', {
              id_expediente: procesoSeleccionado.id_expediente,
              id_sujeto: btn.dataset.id,
            });
            msgSujetos.textContent = 'Sujeto eliminado.';
            await cargarSujetos();
          } catch (e) {
            msgSujetos.textContent = `Error: ${e.message}`;
          }
        });
      });
    } catch (e) {
      tablaSujetos.innerHTML = `<tr><td colspan="5">Error cargando sujetos: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  const cargarTiposActuacion = async () => {
    selTipoActuacion.innerHTML = `<option value="">Cargando...</option>`;
    try {
      if (!appCache.tiposActuacion) {
        appCache.tiposActuacion = await apiRequest('tipos_actuacion_list');
      }
      if (!appCache.tiposActuacion.length) {
        selTipoActuacion.innerHTML = `<option value="">No hay tipos</option>`;
        tiposActuacionCargados = true;
        return;
      }
      selTipoActuacion.innerHTML = `<option value="">Seleccionar</option>` + appCache.tiposActuacion.map((t) => `<option value="${escapeHtml(t.id_tipo_actuacion)}">${escapeHtml(t.cod_tipo_actuacion)} - ${escapeHtml(t.des_tipo_actuacion)}</option>`).join('');
      tiposActuacionCargados = true;
    } catch (e) {
      selTipoActuacion.innerHTML = `<option value="">Error</option>`;
    }
  };

  const cargarActuaciones = async () => {
    if (!procesoSeleccionado) {
      actuacionesContexto.textContent = 'Selecciona un proceso';
      tablaActuaciones.innerHTML = `<tr><td colspan="5">Selecciona un proceso.</td></tr>`;
      return;
    }

    actuacionesContexto.textContent = `Expediente ${procesoSeleccionado.id_expediente} · ${procesoSeleccionado.num_radicado}`;
    tablaActuaciones.innerHTML = `<tr><td colspan="5">Cargando...</td></tr>`;
    try {
      const data = await apiRequest('actuaciones_list', 'GET', { id_expediente: procesoSeleccionado.id_expediente });
      if (!data.length) {
        tablaActuaciones.innerHTML = `<tr><td colspan="5">Sin actuaciones todavía.</td></tr>`;
        return;
      }
      tablaActuaciones.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_actuacion)}</td>
          <td>${escapeHtml(row.fec_actuacion)}</td>
          <td>${escapeHtml(row.cod_tipo_actuacion)}</td>
          <td>${escapeHtml(row.des_actuacion)}</td>
          <td>
            <button type="button" class="btn-cerrar-sesion2 btn-del-actuacion" data-id="${escapeHtml(row.id_actuacion)}" style="background:#6b7280; padding:6px 10px;">Eliminar</button>
          </td>
        </tr>
      `).join('');

      document.querySelectorAll('.btn-del-actuacion').forEach((btn) => {
        btn.addEventListener('click', async () => {
          if (!confirm('¿Eliminar esta actuación?')) return;
          try {
            await apiRequest('actuacion_delete', 'POST', { id_actuacion: btn.dataset.id });
            msgActuaciones.textContent = 'Actuación eliminada.';
            await cargarActuaciones();
          } catch (e) {
            msgActuaciones.textContent = `Error: ${e.message}`;
          }
        });
      });
    } catch (e) {
      tablaActuaciones.innerHTML = `<tr><td colspan="5">Error cargando actuaciones: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  const cargar = async () => {
    tbody.innerHTML = `<tr><td colspan="6">Cargando...</td></tr>`;
    try {
      const data = await apiRequest('procesos_list');
      if (!data.length) {
        tbody.innerHTML = `<tr><td colspan="6">Sin procesos todavía.</td></tr>`;
        return;
      }

      tbody.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_expediente)}</td>
          <td>${escapeHtml(row.identificador_interno)}</td>
          <td>${escapeHtml(row.num_radicado)}</td>
          <td><span class="badge badge-activo">${escapeHtml(row.cod_estado_proceso)}</span></td>
          <td>${escapeHtml(row.fec_reparto || '')}</td>
          <td style="display:flex; gap:6px; flex-wrap:wrap;">
            <button type="button" class="btn-cerrar-sesion2 btn-edit-proceso" data-id="${escapeHtml(row.id_expediente)}" style="background:#415A77; padding:6px 10px;">Editar</button>
            <button type="button" class="btn-cerrar-sesion2 btn-sujetos-proceso" data-id="${escapeHtml(row.id_expediente)}" style="background:#1f6f5f; padding:6px 10px;">Sujetos</button>
            <button type="button" class="btn-cerrar-sesion2 btn-del-proceso" data-id="${escapeHtml(row.id_expediente)}" style="background:#6b7280; padding:6px 10px;">Eliminar</button>
          </td>
        </tr>
      `).join('');

      document.querySelectorAll('.btn-edit-proceso').forEach((btn) => {
        btn.addEventListener('click', () => {
          const row = data.find((item) => String(item.id_expediente) === btn.dataset.id);
          if (!row) return;
          form.id_expediente.value = row.id_expediente;
          procesoIdReadonly.value = row.id_expediente;
          form.num_radicado.value = row.num_radicado || '';
          form.obs_expediente.value = row.obs_expediente || '';
          msg.textContent = `Editando expediente ${row.id_expediente}.`;
          window.scrollTo({ top: 0, behavior: 'smooth' });
        });
      });

      document.querySelectorAll('.btn-sujetos-proceso').forEach((btn) => {
        btn.addEventListener('click', async () => {
          procesoSeleccionado = data.find((item) => String(item.id_expediente) === btn.dataset.id) || null;
          msgSujetos.textContent = '';
          msgActuaciones.textContent = '';
          if (!sujetosCombosCargados) {
            msgSujetos.textContent = 'Cargando personas y roles...';
            try {
              await cargarCombosSujetos();
              msgSujetos.textContent = '';
            } catch (e) {
              msgSujetos.textContent = `Error cargando catálogos: ${e.message}`;
              return;
            }
          }
          if (!tiposActuacionCargados) {
            await cargarTiposActuacion();
          }
          await cargarSujetos();
          await cargarActuaciones();
        });
      });

      document.querySelectorAll('.btn-del-proceso').forEach((btn) => {
        btn.addEventListener('click', async () => {
          if (!confirm('¿Eliminar este proceso?')) return;
          try {
            await apiRequest('proceso_delete', 'POST', { id_expediente: btn.dataset.id });
            if (procesoSeleccionado && String(procesoSeleccionado.id_expediente) === btn.dataset.id) {
              procesoSeleccionado = null;
              sujetosContexto.textContent = 'Selecciona un proceso';
              tablaSujetos.innerHTML = `<tr><td colspan="5">Selecciona un proceso.</td></tr>`;
              actuacionesContexto.textContent = 'Selecciona un proceso';
              tablaActuaciones.innerHTML = `<tr><td colspan="5">Selecciona un proceso.</td></tr>`;
            }
            msg.textContent = 'Proceso eliminado.';
            await cargar();
          } catch (e) {
            msg.textContent = `Error: ${e.message}`;
          }
        });
      });
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="6">Error cargando procesos: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn-guardar-proceso');
    btn.disabled = true;
    msg.textContent = form.id_expediente.value ? 'Actualizando...' : 'Creando...';
    try {
      const fd = new FormData(form);
      const radicado = String(fd.get('num_radicado') || '').trim();
      if (radicado.length < 5 || radicado.length > 40) {
        throw new Error('El número de radicado debe tener entre 5 y 40 caracteres.');
      }
      const payload = {
        num_radicado: radicado,
        obs_expediente: fd.get('obs_expediente'),
      };

      if (form.id_expediente.value) {
        payload.id_expediente = form.id_expediente.value;
        await apiRequest('proceso_update', 'POST', payload);
        msg.textContent = 'Proceso actualizado.';
      } else {
        await apiRequest('proceso_create', 'POST', payload);
        msg.textContent = 'Proceso creado.';
      }
      resetForm();
      await cargar();
    } catch (err) {
      msg.textContent = `Error: ${err.message}`;
    } finally {
      btn.disabled = false;
    }
  });

  document.getElementById('btn-cancelar-proceso').addEventListener('click', () => {
    resetForm();
  });

  document.getElementById('btn-recargar-procesos').addEventListener('click', async (e) => {
    e.preventDefault();
    await cargar();
    await cargarSujetos();
    await cargarActuaciones();
  });

  document.getElementById('form-sujeto').addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!procesoSeleccionado) {
      msgSujetos.textContent = 'Primero selecciona un proceso.';
      return;
    }
    if (!sujetosCombosCargados) {
      try {
        await cargarCombosSujetos();
      } catch (e0) {
        msgSujetos.textContent = `Error cargando catálogos: ${e0.message}`;
        return;
      }
    }
    if (!selPersona.value || !selRol.value) {
      msgSujetos.textContent = 'Selecciona persona y rol.';
      return;
    }
    msgSujetos.textContent = 'Agregando...';
    try {
      await apiRequest('sujeto_create', 'POST', {
        id_expediente: procesoSeleccionado.id_expediente,
        id_persona: selPersona.value,
        id_rol_sujeto: selRol.value,
      });
      msgSujetos.textContent = 'Sujeto agregado.';
      await cargarSujetos();
    } catch (e2) {
      msgSujetos.textContent = `Error: ${e2.message}`;
    }
  });

  document.getElementById('form-actuacion').addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!procesoSeleccionado) {
      msgActuaciones.textContent = 'Primero selecciona un proceso.';
      return;
    }
    if (!tiposActuacionCargados) {
      await cargarTiposActuacion();
    }
    const tipo = selTipoActuacion.value;
    const fecha = inpFecActuacion.value;
    const desc = String(inpDesActuacion.value || '').trim();
    if (!tipo || !fecha || desc.length < 3) {
      msgActuaciones.textContent = 'Completa tipo, fecha y descripción (mínimo 3 caracteres).';
      return;
    }
    msgActuaciones.textContent = 'Agregando...';
    try {
      await apiRequest('actuacion_create', 'POST', {
        id_expediente: procesoSeleccionado.id_expediente,
        id_tipo_actuacion: tipo,
        fec_actuacion: fecha,
        des_actuacion: desc,
      });
      inpDesActuacion.value = '';
      msgActuaciones.textContent = 'Actuación creada.';
      await cargarActuaciones();
    } catch (e2) {
      msgActuaciones.textContent = `Error: ${e2.message}`;
    }
  });

  await cargar();
  await cargarSujetos();
  const today = new Date().toISOString().slice(0, 10);
  if (inpFecActuacion) inpFecActuacion.value = today;
  await cargarTiposActuacion();
  await cargarActuaciones();

  if (!appCache.personasSelect && !appCache.personas && !appCache.personasSelectPromise) {
    appCache.personasSelectPromise = apiRequest('personas_select_list')
      .then((items) => { appCache.personasSelect = items; })
      .catch((_e) => {})
      .finally(() => { appCache.personasSelectPromise = null; });
  }
}

async function renderPersonas() {
  contenidoPrincipal.innerHTML = `
    <div class="pagina-header">
      <h1 class="pagina-titulo">Personas</h1>
      <p class="pagina-subtitulo">Crea, edita y elimina personas.</p>
    </div>
    <div class="tabla-card" style="margin-bottom:16px;">
      <div class="tabla-card-header">
        <div class="tabla-card-titulo">Persona</div>
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
            <button type="submit" id="btn-guardar-persona" class="btn-cerrar-sesion2" style="background: var(--rojo);">Guardar</button>
            <button type="button" id="btn-cancelar-persona" class="btn-cerrar-sesion2" style="background:#415A77;">Limpiar</button>
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
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody id="tabla-personas"></tbody>
      </table>
    </div>
  `;

  const form = document.getElementById('form-persona');
  const selTipo = document.getElementById('sel-tipo-doc');
  const tbody = document.getElementById('tabla-personas');
  const msg = document.getElementById('msg-persona');

  const setCreateMode = () => {
    form.id_persona.readOnly = false;
    form.id_persona.style.background = '';
  };

  const setEditMode = () => {
    form.id_persona.readOnly = true;
    form.id_persona.style.background = '#f3f4f6';
  };

  const resetForm = () => {
    form.reset();
    setCreateMode();
    msg.textContent = '';
  };

  const cargarTipos = async () => {
    selTipo.innerHTML = `<option value="">Cargando...</option>`;
    try {
      if (!appCache.tiposDoc) {
        appCache.tiposDoc = await apiRequest('tipos_doc_list');
      }
      selTipo.innerHTML = `<option value="">Seleccionar</option>` + appCache.tiposDoc.map(t => `<option value="${escapeHtml(t.id_tipo_doc)}">${escapeHtml(t.cod_tipo_doc)} - ${escapeHtml(t.des_tipo_doc)}</option>`).join('');
    } catch (e) {
      selTipo.innerHTML = `<option value="">Error</option>`;
    }
  };

  const cargar = async () => {
    tbody.innerHTML = `<tr><td colspan="6">Cargando...</td></tr>`;
    try {
      if (appCache.personas) {
        const data = appCache.personas;
        if (!data.length) {
          tbody.innerHTML = `<tr><td colspan="6">Sin personas todavía.</td></tr>`;
          return;
        }
        tbody.innerHTML = data.map((row) => `
          <tr>
            <td>${escapeHtml(row.id_persona)}</td>
            <td>${escapeHtml(row.cod_tipo_doc)}</td>
            <td>${escapeHtml(row.nom_y_ape_completos)}</td>
            <td>${escapeHtml(row.email_persona || '')}</td>
            <td>${escapeHtml(row.tel_persona || '')}</td>
            <td style="display:flex; gap:6px; flex-wrap:wrap;">
              <button type="button" class="btn-cerrar-sesion2 btn-edit-persona" data-id="${escapeHtml(row.id_persona)}" style="background:#415A77; padding:6px 10px;">Editar</button>
              <button type="button" class="btn-cerrar-sesion2 btn-del-persona" data-id="${escapeHtml(row.id_persona)}" style="background:#6b7280; padding:6px 10px;">Eliminar</button>
            </td>
          </tr>
        `).join('');
      }

      const data = await apiRequest('personas_list');
      appCache.personas = data;
      if (!data.length) {
        tbody.innerHTML = `<tr><td colspan="6">Sin personas todavía.</td></tr>`;
        return;
      }
      tbody.innerHTML = data.map((row) => `
        <tr>
          <td>${escapeHtml(row.id_persona)}</td>
          <td>${escapeHtml(row.cod_tipo_doc)}</td>
          <td>${escapeHtml(row.nom_y_ape_completos)}</td>
          <td>${escapeHtml(row.email_persona || '')}</td>
          <td>${escapeHtml(row.tel_persona || '')}</td>
          <td style="display:flex; gap:6px; flex-wrap:wrap;">
            <button type="button" class="btn-cerrar-sesion2 btn-edit-persona" data-id="${escapeHtml(row.id_persona)}" style="background:#415A77; padding:6px 10px;">Editar</button>
            <button type="button" class="btn-cerrar-sesion2 btn-del-persona" data-id="${escapeHtml(row.id_persona)}" style="background:#6b7280; padding:6px 10px;">Eliminar</button>
          </td>
        </tr>
      `).join('');

      document.querySelectorAll('.btn-edit-persona').forEach((btn) => {
        btn.addEventListener('click', () => {
          const row = data.find((item) => String(item.id_persona) === btn.dataset.id);
          if (!row) return;
          form.id_persona.value = row.id_persona || '';
          form.id_tipo_doc.value = row.id_tipo_doc || '';
          form.nom_y_ape_completos.value = row.nom_y_ape_completos || '';
          form.email_persona.value = row.email_persona || '';
          form.tel_persona.value = row.tel_persona || '';
          setEditMode();
          msg.textContent = `Editando persona ${row.id_persona}.`;
          window.scrollTo({ top: 0, behavior: 'smooth' });
        });
      });

      document.querySelectorAll('.btn-del-persona').forEach((btn) => {
        btn.addEventListener('click', async () => {
          if (!confirm('¿Eliminar esta persona?')) return;
          try {
            await apiRequest('persona_delete', 'POST', { id_persona: btn.dataset.id });
            msg.textContent = 'Persona eliminada.';
            appCache.personas = null;
            await cargar();
          } catch (e) {
            msg.textContent = `Error: ${e.message}`;
          }
        });
      });
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="6">Error cargando personas: ${escapeHtml(e.message)}</td></tr>`;
    }
  };

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn-guardar-persona');
    btn.disabled = true;
    try {
      const fd = new FormData(form);
      const payload = {
        id_persona: fd.get('id_persona'),
        id_tipo_doc: fd.get('id_tipo_doc'),
        nom_y_ape_completos: fd.get('nom_y_ape_completos'),
        email_persona: fd.get('email_persona'),
        tel_persona: fd.get('tel_persona'),
      };

      if (form.id_persona.readOnly) {
        msg.textContent = 'Actualizando...';
        await apiRequest('persona_update', 'POST', payload);
        msg.textContent = 'Persona actualizada.';
      } else {
        msg.textContent = 'Creando...';
        await apiRequest('persona_create', 'POST', payload);
        msg.textContent = 'Persona creada.';
      }

      appCache.personas = null;
      resetForm();
      await cargar();
    } catch (err) {
      msg.textContent = `Error: ${err.message}`;
    } finally {
      btn.disabled = false;
    }
  });

  document.getElementById('btn-cancelar-persona').addEventListener('click', () => {
    resetForm();
  });

  document.getElementById('btn-recargar-personas').addEventListener('click', async (e) => {
    e.preventDefault();
    appCache.personas = null;
    await cargar();
  });

  await Promise.all([cargarTipos(), cargar()]);
  setCreateMode();
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
    window.location.href = "../logout.php";
  }
});
