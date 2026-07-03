<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../src/conexion.php';

header('Content-Type: text/html; charset=utf-8');
echo "<!DOCTYPE html><html><head><title>Setup DB Goliat</title></head><body><h1>Configuración de Base de Datos Goliat</h1><pre>";

try {
    $db = getDB();
    echo "✅ Conectado a la base de datos exitosamente!\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/DBGOLIAT-V 5.2.sql';
    $sql = file_get_contents($sqlFile);
    
    if ($sql === false) {
        die("❌ Error al leer el archivo SQL\n");
    }

    // Ejecutar el SQL usando PDO (mejor manejo de múltiples statements con PDO::prepare)
    // Primero limpiamos el SQL (eliminamos comentarios de línea)
    $sql = preg_replace('/--.*$/m', '', $sql);
    
    // Dividimos por punto y coma, pero manejamos mejor los casos
    $statements = explode(';', $sql);
    $successCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (empty($statement)) continue;
        
        try {
            $db->exec($statement);
            echo "✅ Ejecutado: " . substr($statement, 0, 60) . "...\n";
            $successCount++;
        } catch (PDOException $e) {
            echo "⚠️  Error (puede ser normal): " . $e->getMessage() . "\n";
            $errorCount++;
        }
    }
    
    echo "\n🎉 Estructura de base de datos creada! ($successCount ejecutados, $errorCount advertencias/errores)\n";
    
    // Ahora ejecutamos otros scripts SQL si existen
    $otherScripts = ['poblado.sql', 'Crud - Tabla Despachos.sql', 'Crud - Tabla Personas.sql', 'Crud - Tabla Usuarios.sql', 'Crud - Tabla Abogados.sql'];
    
    foreach ($otherScripts as $script) {
        $scriptPath = __DIR__ . '/' . $script;
        if (file_exists($scriptPath)) {
            echo "\n📄 Ejecutando $script...\n";
            $scriptSql = file_get_contents($scriptPath);
            $scriptSql = preg_replace('/--.*$/m', '', $scriptSql);
            $scriptStatements = explode(';', $scriptSql);
            
            foreach ($scriptStatements as $stmt) {
                $stmt = trim($stmt);
                if (empty($stmt)) continue;
                try {
                    $db->exec($stmt);
                    $successCount++;
                } catch (PDOException $e) {
                    // Ignoramos errores de duplicados etc.
                }
            }
            echo "✅ $script ejecutado!\n";
        }
    }

} catch (PDOException $e) {
    die("❌ Error: " . $e->getMessage() . "\n");
}

echo "</pre></body></html>";
?>