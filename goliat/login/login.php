<?php
// login.php
// Incluimos la conexión y la clase de usuario utilizando tus rutas relativas reales
include("../src/conexion.php");
include("../clases/userClass.php");

$errorMsgLogin = '';
$dashboardUrl = '../sistema/index.html';

// Si el usuario ya tiene sesión iniciada, lo redirigimos directamente al sistema
if (!empty($_SESSION['id_usuario'])) {
    $token = session_id();
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Redirigiendo…</title></head><body><script>';
    echo 'localStorage.setItem("auth_token", ' . json_encode($token) . ');';
    echo 'window.location.replace(' . json_encode($dashboardUrl) . ');';
    echo '</script></body></html>';
    exit();
}

// PROCESAMIENTO POST: Se ejecuta con cualquier envío de formulario tipo POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $userClass = new userClass();
    $userID = isset($_POST['userID']) ? trim($_POST['userID']) : '';
    $password = isset($_POST['password']) ? trim($_POST['password']) : '';

    if (strlen($userID) > 1 && strlen($password) > 1) {
        $id_usuario = $userClass->userLogin($userID, $password);
        if ($id_usuario) {
            $token = session_id();
            echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Redirigiendo…</title></head><body><script>';
            echo 'localStorage.setItem("auth_token", ' . json_encode($token) . ');';
            echo 'window.location.replace(' . json_encode($dashboardUrl) . ');';
            echo '</script></body></html>';
            exit();
        } else {
            $errorMsgLogin = "No tiene acceso. Por favor, consulte con el Administrador";
        }
    } else {
        $errorMsgLogin = "Por favor, complete todos los campos requeridos.";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inicio de sesión - Goliat</title>
  <link rel="stylesheet" href="../css/tokens.css">
  <link rel="stylesheet" href="../css/login.css">
</head>
<body>

  <!-- 
    Se envuelve toda la tarjeta de sesión dentro de un formulario real 
    para posibilitar la captura automática de datos por JavaScript y HTML5.
  -->
  <form id="formLogin" method="POST" action="login.php" class="tarjeta-sesion" novalidate>

    <div class="contenedor-logo">
      <a href="../index.html">
        <img src="../img/goliatletraoscura.png" alt="logo-oscuro" class="logo-oscuro">
        <img src="../img/logo-goliat.png" alt="logo-claro" class="logo-claro">
      </a>
    </div>

    <h1 class="titulo-sesion">Bienvenido de nuevo a Goliat</h1>
    <p class="descripcion-sesion">Ingresa tus credenciales para continuar</p>

    <!-- CAMPO: id-usuario -->
    <div class="grupo-campo">
      <label class="etiqueta-campo" for="campo-usuario">Número de cédula</label>
      <input class="entrada-campo" type="text" id="campo-usuario" name="userID"
        placeholder="Ej: 1010202030" autocomplete="username" required>
      <p class="ayuda-campo">Ingresa tu número de identificación (cédula)</p>
    </div>

    <!-- CAMPO: CONTRASEÑA -->
    <div class="grupo-campo">
      <label class="etiqueta-campo" for="campo-contrasena">Contraseña</label>
      <input class="entrada-campo" type="password" id="campo-contrasena" name="password" placeholder="••••••••"
        autocomplete="current-password" required>
      <p class="ayuda-campo">Mínimo 8 caracteres</p>
    </div>

    <!-- ENLACE: OLVIDÉ MI CONTRASEÑA -->
    <div class="grupo-olvidar">
      <a class="enlace-olvidar" href="#">¿Olvidaste tu contraseña?</a>
    </div>

    <div class="contenedor-captcha">
      <div class="g-recaptcha" data-sitekey="6LdA49UsAAAAAGwflmaDHC9AY4kgARqO3An7mSyL"></div>
    </div>

    <!-- Botón con tipo submit nativo que dispara la validación del JS -->
    <button type="submit" class="boton-ingresar" name="loginSubmit" id="btnSubmit">
      Iniciar sesión
    </button>
  </form>

  <!-- NOTIFICACION — mensaje temporal controlado dinámicamente por JS -->
  <div class="notificacion" id="notificacion" role="status" aria-live="polite"></div>

  <!-- ============================================================
       PRECARGADOR (Se oculta inicialmente de forma estricta con display: none y fondo fallback)
       ============================================================ -->
  <div class="precargador-overlay" id="precargador" style="display: none; background-color: #0b0f19;">
    <div class="precargador-contenido">
      <img src="../img/goliatletraoscura.png" alt="Goliat Logo" class="precargador-logo logo-oscuro">
      <img src="../img/logo-goliat.png" alt="Goliat Logo" class="precargador-logo logo-claro">
      
      <div class="precargador-barra-fondo">
        <div class="precargador-barra-progreso" id="barra-progreso"></div>
      </div>
      <p class="precargador-texto">Ingresando al sistema...</p>
    </div>
  </div>

  <!-- Carga de Scripts al final de la página -->
  <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  <!--<script src="../js/login.js"></script> -->

  <!-- 
    SCRIPT INTEGRADO: Dispara la notificación usando tus estilos CSS cuando PHP devuelve error.
  -->

</body>
</html>
