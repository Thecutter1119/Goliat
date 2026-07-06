<?php
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

// Cargar variables de entorno desde .env (simplificado)
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value, '"');
        if (!defined($name)) {
            define($name, $value);
        }
    }
}

// Parsear la URL de la base de datos
function parseDbUrl($url) {
    $parsed = parse_url($url);
    $host = $parsed['host'];
    $port = isset($parsed['port']) ? $parsed['port'] : 5432;
    $user = $parsed['user'];
    $pass = $parsed['pass'];
    $dbname = ltrim($parsed['path'], '/');
    // Extraer parámetros de query (sslmode, etc.)
    $query = isset($parsed['query']) ? $parsed['query'] : '';
    parse_str($query, $params);
    return [
        'host' => $host,
        'port' => $port,
        'user' => $user,
        'pass' => $pass,
        'dbname' => $dbname,
        'params' => $params
    ];
}

function detectBaseUrl() {
    if (PHP_SAPI === 'cli') {
        return 'http://localhost:8000/';
    }

    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
    $scheme = $https ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost:8000';
    $scriptName = $_SERVER['SCRIPT_NAME'] ?? '';
    $basePath = rtrim(str_replace('\\', '/', dirname(dirname($scriptName))), '/');

    if ($basePath === '' || $basePath === '.') {
        return $scheme . '://' . $host . '/';
    }

    return $scheme . '://' . $host . $basePath . '/';
}

define("BASE_URL", detectBaseUrl());

function getDB() 
{
    try {
        $dbInfo = parseDbUrl(DATABASE_URL);
        $dsn = "pgsql:host={$dbInfo['host']};port={$dbInfo['port']};dbname={$dbInfo['dbname']}";
        // Añadir SSL mode si está presente
        if (isset($dbInfo['params']['sslmode'])) {
            $dsn .= ";sslmode={$dbInfo['params']['sslmode']}";
        }
        $dbConnection = new PDO($dsn, $dbInfo['user'], $dbInfo['pass']); 
        $dbConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $dbConnection;
    }
    catch (PDOException $e) {
        throw $e;
    }
}
?>
