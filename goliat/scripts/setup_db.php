<?php
require_once __DIR__ . '/../src/conexion.php';

try {
    $db = getDB();
    echo "Conectado a la base de datos exitosamente!\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/DBGOLIAT-V 5.2.sql';
    $sql = file_get_contents($sqlFile);
    
    if ($sql === false) {
        die("Error al leer el archivo SQL\n");
    }

    // Ejecutar el SQL (dividir por punto y coma, pero tener cuidado con strings que contengan ;)
    // Nota: Este método simple funciona para este caso específico
    $statements = explode(';', $sql);
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (empty($statement)) continue;
        
        try {
            $db->exec($statement);
            echo "Ejecutado: " . substr($statement, 0, 50) . "...\n";
        } catch (PDOException $e) {
            echo "Error en statement: " . $e->getMessage() . "\n";
        }
    }
    
    echo "\nEstructura de base de datos creada exitosamente!\n";

} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}
?>