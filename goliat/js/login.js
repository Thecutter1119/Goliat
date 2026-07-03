// js/login.js
// Controlador del lado del cliente para validar campos y animar el precargador de Goliat.

document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('formLogin');
    if (form) {
        form.addEventListener('submit', manejarLogin);
    }
});

function manejarLogin(event) {
    // 1. Detenemos el envío automático para realizar las validaciones primero
    event.preventDefault();

    const form = event.target;
    const usuarioInput = document.getElementById('campo-usuario');
    const contrasenaInput = document.getElementById('campo-contrasena');
    const btnSubmit = document.getElementById('btnSubmit');
    const precargador = document.getElementById('precargador');
    const barraProgreso = document.getElementById('barra-progreso');

    const usuario = usuarioInput.value.trim();
    const contrasena = contrasenaInput.value.trim();

    // ============================================================
    // VALIDADORES DE CAMPOS (Frontend)
    // ============================================================

    // Validación A: Campos vacíos
    if (usuario === "" || contrasena === "") {
        mostrarNotificacion("Por favor, completa todos los campos del formulario.", "error");
        if (usuario === "") usuarioInput.focus();
        else contrasenaInput.focus();
        return;
    }

    // Validación B: Formato de la Cédula (Solo números, entre 5 y 12 dígitos)
    const patronCedula = /^[0-9]+$/;
    if (!patronCedula.test(usuario)) {
        mostrarNotificacion("La cédula ingresada debe contener únicamente números.", "error");
        usuarioInput.focus();
        return;
    }




    // ============================================================
    // ANIMACIÓN DEL PRECARGADOR Y ENVÍO SEGURO
    // ============================================================
    
    // Deshabilitamos el botón para evitar múltiples clics
    if (btnSubmit) btnSubmit.disabled = true;

    // Mostramos la capa del precargador animado
    if (precargador && barraProgreso) {
        precargador.style.display = 'flex';
        barraProgreso.style.width = '0%';

        let progreso = 0;
        const intervalo = setInterval(() => {
            progreso += 5;
            barraProgreso.style.width = progreso + '%';

            if (progreso >= 100) {
                clearInterval(intervalo);
                
                // Agregamos un campo oculto al vuelo para que PHP sepa que el submit viene del botón 'loginSubmit'
                const inputHidden = document.createElement('input');
                inputHidden.type = 'hidden';
                inputHidden.name = 'loginSubmit';
                inputHidden.value = '1';
                form.appendChild(inputHidden);

                // Procedemos con el envío nativo del formulario hacia login.php
                form.submit();
            }
        }, 35); // La animación dura aproximadamente 700ms antes de enviar
    } else {
        // Si por alguna razón el precargador no está en el HTML, enviamos el formulario inmediatamente
        form.submit();
    }
}

// Función auxiliar para mostrar alertas estéticas en tu div de notificaciones
function mostrarNotificacion(mensaje, tipo) {
    const notificacion = document.getElementById('notificacion');
    if (!notificacion) return;

    notificacion.textContent = mensaje;
    
    // Limpiamos clases previas y agregamos la nueva (ej: 'notificacion error' o 'notificacion success')
    notificacion.className = `notificacion ${tipo}`;
    notificacion.style.display = 'block';

    // Ocultar automáticamente la alerta después de 4 segundos
    setTimeout(() => {
        notificacion.style.display = 'none';
    }, 4000);
}