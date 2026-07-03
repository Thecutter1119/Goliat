<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/src/conexion.php';
require_once __DIR__ . '/clases/userClass.php';

echo "<h1>Prueba de Login</h1>";

// Prueba 1: Conexión a BD
try {
    $db = getDB();
    echo "<p style='color: green;'>✅ Conexión a BD exitosa</p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Error conexión: " . $e->getMessage() . "</p>";
    exit();
}

// Prueba 2: Buscar usuario de prueba en la BD
echo "<h2>Prueba 2: Buscar usuario 1234567890</h2>";
$stmt = $db->prepare("SELECT * FROM tab_usuario WHERE id_usuario = '1234567890'");
$stmt->execute();
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if ($usuario) {
    echo "<p style='color: green;'>✅ Usuario encontrado en BD</p>";
    echo "<ul>";
    echo "<li>ID: " . $usuario['id_usuario'] . "</li>";
    echo "<li>Contraseña en BD: " . $usuario['contrasena'] . "</li>";
    echo "<li>Admin: " . ($usuario['ind_admin'] ? 'Sí' : 'No') . "</li>";
    echo "</ul>";
} else {
    echo "<p style='color: red;'>❌ Usuario NO encontrado en BD. Ejecuta setup_completo_usuario.sql en Neon.</p>";
}

// Prueba 3: Probar la función userLogin
echo "<h2>Prueba 3: Llamar a userLogin('1234567890', 'admin123')</h2>";
$userClass = new userClass();
$resultado = $userClass->userLogin('1234567890', 'admin123');

if ($resultado) {
    echo "<p style='color: green;'>✅ userLogin() retornó TRUE</p>";
} else {
    echo "<p style='color: red;'>❌ userLogin() retornó FALSE</p>";
}

// Prueba 4: Verificar sesión
echo "<h2>Prueba 4: Verificar sesión</h2>";
if (isset($_SESSION['id_usuario'])) {
    echo "<p style='color: green;'>✅ Sesión guardada: " . $_SESSION['id_usuario'] . "</p>";
} else {
    echo "<p style='color: red;'>❌ NO hay sesión guardada</p>";
}

echo "<hr>";
echo "<p><a href='login/login.php'>Ir a Login</a> | <a href='sistema/index.html'>Ir a Dashboard</a></p>";
?>
