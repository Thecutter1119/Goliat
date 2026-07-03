<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Incluir la conexión
require_once __DIR__ . '/src/conexion.php';

echo "<h1>Prueba de Conexión a la Base de Datos</h1>";

try {
    // Intentar conectar
    $db = getDB();
    echo "<p style='color: green; font-size: 1.2rem;'>✅ Conexión a Neon exitosa!</p>";

    // Verificar si las tablas existen
    $stmt = $db->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    $tablas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tablas) > 0) {
        echo "<h2>Tablas encontradas en la base de datos:</h2>";
        echo "<ul>";
        foreach ($tablas as $tabla) {
            echo "<li>$tabla</li>";
        }
        echo "</ul>";
    } else {
        echo "<p style='color: orange;'>⚠️ No se encontraron tablas. Ejecuta el script DBGOLIAT-V 5.2.sql en Neon.</p>";
    }

    // Verificar si el usuario de prueba existe
    $stmt = $db->prepare("SELECT id_usuario, nom_y_ape_completos, ind_admin FROM tab_persona p JOIN tab_usuario u ON p.id_persona = u.id_usuario WHERE u.id_usuario = '1234567890'");
    $stmt->execute();
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario) {
        echo "<h2>✅ Usuario de prueba encontrado:</h2>";
        echo "<ul>";
        echo "<li><strong>Cédula:</strong> " . $usuario['id_usuario'] . "</li>";
        echo "<li><strong>Nombre:</strong> " . $usuario['nom_y_ape_completos'] . "</li>";
        echo "<li><strong>Admin:</strong> " . ($usuario['ind_admin'] ? 'Sí' : 'No') . "</li>";
        echo "</ul>";
    } else {
        echo "<p style='color: orange;'>⚠️ No se encontró el usuario de prueba. Ejecuta setup_completo_usuario.sql en Neon.</p>";
    }

} catch (PDOException $e) {
    echo "<p style='color: red; font-size: 1.2rem;'>❌ Error de conexión: " . $e->getMessage() . "</p>";
}
?>
