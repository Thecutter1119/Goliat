<?php
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

require_once __DIR__ . '/src/conexion.php';

header('Content-Type: application/json; charset=utf-8');

function json_out($status, $payload) {
    http_response_code($status);
    echo json_encode($payload);
    exit();
}

function require_auth() {
    if (empty($_SESSION['id_usuario'])) {
        json_out(401, ['ok' => false, 'error' => 'no_auth']);
    }
}

function param($key) {
    if (isset($_POST[$key])) return trim((string)$_POST[$key]);
    if (isset($_GET[$key])) return trim((string)$_GET[$key]);
    return '';
}

function ensure_roles($db) {
    $count = (int)$db->query("SELECT COUNT(*) FROM tab_rol_sujeto")->fetchColumn();
    if ($count > 0) {
        return;
    }

    $db->exec("
        INSERT INTO tab_rol_sujeto (id_rol_sujeto, nom_rol_sujeto, desc_rol_sujeto) VALUES
        ('DEMANDANTE', 'Demandante', 'Parte demandante del proceso'),
        ('DEMANDADO', 'Demandado', 'Parte demandada del proceso'),
        ('APODERADO', 'Apoderado', 'Abogado o representante'),
        ('TERCERO', 'Tercero', 'Tercero interviniente')
        ON CONFLICT (id_rol_sujeto) DO NOTHING
    ");
}

function ensure_tipos_doc($db) {
    $db->exec("
        INSERT INTO tab_tipo_documento_identidad (id_tipo_doc, cod_tipo_doc, des_tipo_doc) VALUES
        (1, 'CC', 'Cédula de ciudadanía'),
        (2, 'CE', 'Cédula de extranjería'),
        (3, 'TI', 'Tarjeta de identidad'),
        (4, 'PA', 'Pasaporte'),
        (5, 'RC', 'Registro civil de nacimiento'),
        (6, 'NUI', 'Número único de identificación')
        ON CONFLICT (id_tipo_doc) DO NOTHING
    ");
}

function next_id($db, $table, $column) {
    $stmt = $db->query("SELECT COALESCE(MAX($column), 0) + 1 AS next_id FROM $table");
    return (int)$stmt->fetchColumn();
}

function ensure_default_etapa($db, $id_expediente) {
    $stmt = $db->prepare("SELECT id_etapa FROM tab_etapa_procesal WHERE id_expediente = :id_expediente ORDER BY orden LIMIT 1");
    $stmt->execute([':id_expediente' => $id_expediente]);
    $id_etapa = $stmt->fetchColumn();
    if ($id_etapa) {
        return (int)$id_etapa;
    }

    $id_etapa = next_id($db, 'tab_etapa_procesal', 'id_etapa');
    $stmt = $db->prepare("INSERT INTO tab_etapa_procesal (id_etapa, id_expediente, nom_etapa, orden) VALUES (:id_etapa, :id_expediente, :nom_etapa, 1)");
    $stmt->execute([
        ':id_etapa' => $id_etapa,
        ':id_expediente' => $id_expediente,
        ':nom_etapa' => 'Primera Instancia',
    ]);

    return (int)$id_etapa;
}

function ensure_default_cuaderno($db, $id_etapa) {
    $stmt = $db->prepare("SELECT id_cuaderno FROM tab_cuaderno WHERE id_etapa = :id_etapa ORDER BY id_cuaderno LIMIT 1");
    $stmt->execute([':id_etapa' => $id_etapa]);
    $id_cuaderno = $stmt->fetchColumn();
    if ($id_cuaderno) {
        return (int)$id_cuaderno;
    }

    $id_cuaderno = next_id($db, 'tab_cuaderno', 'id_cuaderno');
    $stmt = $db->prepare("INSERT INTO tab_cuaderno (id_cuaderno, id_etapa, cod_cuaderno, nom_cuaderno) VALUES (:id_cuaderno, :id_etapa, 'C01', 'Principal')");
    $stmt->execute([
        ':id_cuaderno' => $id_cuaderno,
        ':id_etapa' => $id_etapa,
    ]);

    return (int)$id_cuaderno;
}

function create_placeholder_archivo($db, $id_expediente, $usuario) {
    $base = (int)floor(microtime(true) * 1000);
    $id_archivo = ($base * 1000) + random_int(1, 999);
    $nom_archivo = "Actuacion_{$id_expediente}_{$id_archivo}.txt";
    if (strlen($nom_archivo) > 50) {
        $nom_archivo = substr($nom_archivo, 0, 46) . '.txt';
    }
    $hash = hash('sha256', random_bytes(16) . $usuario . $id_expediente . $id_archivo);
    $url = "local://actuacion/{$id_expediente}/{$id_archivo}";

    $stmt = $db->prepare("INSERT INTO tab_archivos (id_archivo, nom_archivo, id_tipo_archivo, formato_archivo, tam_bytes, paginas, url_documento, id_usuario_carga, fec_carga, hash_sha256, ind_publico) VALUES (:id_archivo, :nom_archivo, 'ACTUACION', 'TXT', 1, 1, :url_documento, :id_usuario_carga, NOW(), :hash_sha256, FALSE)");
    $stmt->execute([
        ':id_archivo' => $id_archivo,
        ':nom_archivo' => $nom_archivo,
        ':url_documento' => $url,
        ':id_usuario_carga' => $usuario,
        ':hash_sha256' => $hash,
    ]);

    $stmt = $db->prepare("INSERT INTO tab_archivos_base_expediente (id_expediente, id_archivo, id_sujeto_aporta) VALUES (:id_expediente, :id_archivo, NULL) ON CONFLICT (id_expediente, id_archivo) DO NOTHING");
    $stmt->execute([
        ':id_expediente' => $id_expediente,
        ':id_archivo' => $id_archivo,
    ]);

    return (int)$id_archivo;
}

$action = param('action');

if ($action === 'health') {
    json_out(200, ['ok' => true]);
}

require_auth();

try {
    $db = getDB();
    if (!$db) json_out(500, ['ok' => false, 'error' => 'db_null']);

    if ($action === 'tipos_doc_list') {
        $stmt = $db->query("SELECT id_tipo_doc, cod_tipo_doc, des_tipo_doc FROM tab_tipo_documento_identidad ORDER BY id_tipo_doc");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'personas_list') {
        $stmt = $db->query("SELECT p.id_persona, p.id_tipo_doc, COALESCE(t.cod_tipo_doc, 'N/D') AS cod_tipo_doc, p.nom_y_ape_completos, p.email_persona, p.tel_persona, p.fec_creacion FROM tab_persona p LEFT JOIN tab_tipo_documento_identidad t ON t.id_tipo_doc = p.id_tipo_doc ORDER BY p.fec_creacion DESC LIMIT 200");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'personas_select_list') {
        $stmt = $db->query("SELECT p.id_persona, p.nom_y_ape_completos FROM tab_persona p ORDER BY p.nom_y_ape_completos ASC LIMIT 300");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'persona_create') {
        $id_persona = param('id_persona');
        $id_tipo_doc = param('id_tipo_doc');
        $nombre = param('nom_y_ape_completos');
        $email = param('email_persona');
        $tel = param('tel_persona');

        if ($id_persona === '' || $id_tipo_doc === '' || $nombre === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        if (!preg_match('/^[0-9]{6,10}$/', $id_persona)) {
            json_out(400, ['ok' => false, 'error' => 'invalid_id_persona']);
        }

        $stmt = $db->prepare("INSERT INTO tab_persona (id_persona, id_tipo_doc, nom_y_ape_completos, email_persona, tel_persona, fec_creacion) VALUES (:id_persona, :id_tipo_doc, :nombre, :email, :tel, NOW()) ON CONFLICT (id_persona) DO NOTHING");
        $stmt->execute([
            ':id_persona' => $id_persona,
            ':id_tipo_doc' => $id_tipo_doc,
            ':nombre' => $nombre,
            ':email' => $email !== '' ? $email : null,
            ':tel' => $tel !== '' ? $tel : null,
        ]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'persona_update') {
        $id_persona = param('id_persona');
        $id_tipo_doc = param('id_tipo_doc');
        $nombre = param('nom_y_ape_completos');
        $email = param('email_persona');
        $tel = param('tel_persona');

        if ($id_persona === '' || $id_tipo_doc === '' || $nombre === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        $stmt = $db->prepare("UPDATE tab_persona SET id_tipo_doc = :id_tipo_doc, nom_y_ape_completos = :nombre, email_persona = :email, tel_persona = :tel WHERE id_persona = :id_persona");
        $stmt->execute([
            ':id_persona' => $id_persona,
            ':id_tipo_doc' => $id_tipo_doc,
            ':nombre' => $nombre,
            ':email' => $email !== '' ? $email : null,
            ':tel' => $tel !== '' ? $tel : null,
        ]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'persona_delete') {
        $id_persona = param('id_persona');
        if ($id_persona === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_id_persona']);
        }

        $stmtUsuario = $db->prepare("SELECT COUNT(*) FROM tab_usuario WHERE id_usuario = :id");
        $stmtUsuario->execute([':id' => $id_persona]);
        if ((int)$stmtUsuario->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'persona_has_usuario']);
        }

        $stmtSuj = $db->prepare("SELECT COUNT(*) FROM tab_sujetos_expediente WHERE id_persona = :id");
        $stmtSuj->execute([':id' => $id_persona]);
        if ((int)$stmtSuj->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'persona_linked_to_expediente']);
        }

        $stmt = $db->prepare("DELETE FROM tab_persona WHERE id_persona = :id_persona");
        $stmt->execute([':id_persona' => $id_persona]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'procesos_list') {
        $stmt = $db->query("SELECT e.id_expediente, e.identificador_interno, e.num_radicado, e.obs_expediente, e.id_estado_proceso, s.cod_estado_proceso, e.fec_reparto, e.fec_creacion FROM tab_expediente e JOIN tab_estado_proceso s ON s.id_estado_proceso = e.id_estado_proceso ORDER BY e.fec_creacion DESC LIMIT 200");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'tipos_actuacion_list') {
        $stmt = $db->query("SELECT id_tipo_actuacion, cod_tipo_actuacion, des_tipo_actuacion FROM tab_tipo_actuacion ORDER BY id_tipo_actuacion");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'actuaciones_list') {
        $id_expediente = param('id_expediente');
        if ($id_expediente === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_id_expediente']);
        }

        $stmt = $db->prepare("SELECT a.id_actuacion, a.fec_actuacion, a.des_actuacion, a.id_tipo_actuacion, t.cod_tipo_actuacion, t.des_tipo_actuacion, a.id_archivo, ar.url_documento, e.nom_etapa, c.nom_cuaderno FROM tab_actuacion a JOIN tab_cuaderno c ON c.id_cuaderno = a.id_cuaderno JOIN tab_etapa_procesal e ON e.id_etapa = c.id_etapa JOIN tab_tipo_actuacion t ON t.id_tipo_actuacion = a.id_tipo_actuacion JOIN tab_archivos ar ON ar.id_archivo = a.id_archivo WHERE e.id_expediente = :id_expediente ORDER BY a.fec_actuacion DESC, a.id_actuacion DESC LIMIT 200");
        $stmt->execute([':id_expediente' => $id_expediente]);
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'actuacion_create') {
        $id_expediente = param('id_expediente');
        $id_tipo_actuacion = param('id_tipo_actuacion');
        $fec_actuacion = param('fec_actuacion');
        $des_actuacion = param('des_actuacion');
        $usuario = (string)$_SESSION['id_usuario'];

        if ($id_expediente === '' || $id_tipo_actuacion === '' || $fec_actuacion === '' || $des_actuacion === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        if (strlen(trim($des_actuacion)) < 3) {
            json_out(400, ['ok' => false, 'error' => 'invalid_des_actuacion']);
        }

        $dt = DateTime::createFromFormat('Y-m-d', $fec_actuacion);
        if (!$dt || $dt->format('Y-m-d') !== $fec_actuacion) {
            json_out(400, ['ok' => false, 'error' => 'invalid_fec_actuacion']);
        }

        $tipoStmt = $db->prepare("SELECT COUNT(*) FROM tab_tipo_actuacion WHERE id_tipo_actuacion = :id");
        $tipoStmt->execute([':id' => $id_tipo_actuacion]);
        if ((int)$tipoStmt->fetchColumn() === 0) {
            json_out(400, ['ok' => false, 'error' => 'invalid_id_tipo_actuacion']);
        }

        $db->beginTransaction();
        try {
            $id_etapa = ensure_default_etapa($db, (int)$id_expediente);
            $id_cuaderno = ensure_default_cuaderno($db, $id_etapa);
            $id_archivo = create_placeholder_archivo($db, (int)$id_expediente, $usuario);
            $id_actuacion = next_id($db, 'tab_actuacion', 'id_actuacion');

            $stmt = $db->prepare("INSERT INTO tab_actuacion (id_actuacion, id_cuaderno, id_archivo, id_tipo_actuacion, fec_actuacion, des_actuacion, id_usuario_registra) VALUES (:id_actuacion, :id_cuaderno, :id_archivo, :id_tipo_actuacion, :fec_actuacion, :des_actuacion, :id_usuario_registra)");
            $stmt->execute([
                ':id_actuacion' => $id_actuacion,
                ':id_cuaderno' => $id_cuaderno,
                ':id_archivo' => $id_archivo,
                ':id_tipo_actuacion' => $id_tipo_actuacion,
                ':fec_actuacion' => $fec_actuacion,
                ':des_actuacion' => $des_actuacion,
                ':id_usuario_registra' => $usuario,
            ]);

            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            throw $e;
        }

        json_out(200, ['ok' => true]);
    }

    if ($action === 'actuacion_delete') {
        $id_actuacion = param('id_actuacion');
        if ($id_actuacion === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_id_actuacion']);
        }

        $stmt = $db->prepare("SELECT id_archivo FROM tab_actuacion WHERE id_actuacion = :id_actuacion");
        $stmt->execute([':id_actuacion' => $id_actuacion]);
        $id_archivo = $stmt->fetchColumn();
        if (!$id_archivo) {
            json_out(404, ['ok' => false, 'error' => 'not_found']);
        }

        $stmt = $db->prepare("SELECT COUNT(*) FROM tab_notificacion WHERE id_actuacion = :id_actuacion");
        $stmt->execute([':id_actuacion' => $id_actuacion]);
        if ((int)$stmt->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'actuacion_has_notificaciones']);
        }

        $stmt = $db->prepare("SELECT COUNT(*) FROM tab_termino_procesal WHERE id_actuacion_origen = :id_actuacion");
        $stmt->execute([':id_actuacion' => $id_actuacion]);
        if ((int)$stmt->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'actuacion_has_terminos']);
        }

        $stmt = $db->prepare("SELECT COUNT(*) FROM tab_medida_cautelar WHERE id_actuacion = :id_actuacion");
        $stmt->execute([':id_actuacion' => $id_actuacion]);
        if ((int)$stmt->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'actuacion_has_medidas']);
        }

        $db->beginTransaction();
        try {
            $stmt = $db->prepare("DELETE FROM tab_actuacion WHERE id_actuacion = :id_actuacion");
            $stmt->execute([':id_actuacion' => $id_actuacion]);

            $stmt = $db->prepare("DELETE FROM tab_archivos_base_expediente WHERE id_archivo = :id_archivo");
            $stmt->execute([':id_archivo' => $id_archivo]);

            $stmt = $db->prepare("DELETE FROM tab_archivos WHERE id_archivo = :id_archivo");
            $stmt->execute([':id_archivo' => $id_archivo]);

            $db->commit();
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            throw $e;
        }

        json_out(200, ['ok' => true]);
    }

    if ($action === 'proceso_create') {
        $radicado = param('num_radicado');
        $obs = param('obs_expediente');
        $usuario = (string)$_SESSION['id_usuario'];

        if ($radicado === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_num_radicado']);
        }

        $radicadoLen = strlen(trim($radicado));
        if ($radicadoLen < 5 || $radicadoLen > 40) {
            json_out(400, ['ok' => false, 'error' => 'invalid_num_radicado', 'message' => 'El número de radicado debe tener entre 5 y 40 caracteres.']);
        }

        $tipoStmt = $db->query("SELECT id_tipo_expediente FROM tab_tipo_expediente ORDER BY id_tipo_expediente LIMIT 1");
        $tipo = $tipoStmt->fetchColumn();
        if (!$tipo) {
            $db->exec("INSERT INTO tab_tipo_expediente (id_tipo_expediente, etiqueta_tipo, nom_tipo_expediente, jurisdiccion, campos_adicionales) VALUES (1, 'GEN', 'General', 'General', '{}'::jsonb) ON CONFLICT (id_tipo_expediente) DO NOTHING");
            $tipo = 1;
        }

        $estadoStmt = $db->query("SELECT id_estado_proceso FROM tab_estado_proceso ORDER BY id_estado_proceso LIMIT 1");
        $estado = $estadoStmt->fetchColumn();
        if (!$estado) {
            $db->exec("INSERT INTO tab_estado_proceso (id_estado_proceso, cod_estado_proceso, des_estado_proceso, ind_terminal) VALUES (1, 'ACTIVO', 'En trámite', FALSE) ON CONFLICT (id_estado_proceso) DO NOTHING");
            $estado = 1;
        }

        $identificador = 'EXP-' . preg_replace('/[^0-9A-Za-z]+/', '-', $radicado) . '-' . substr(bin2hex(random_bytes(6)), 0, 12);

        $stmt = $db->prepare("INSERT INTO tab_expediente (identificador_interno, num_radicado, id_tipo_expediente, id_despacho, id_estado_proceso, obs_expediente, fec_reparto, id_usuario_crea, fec_creacion, fec_actualizacion) VALUES (:identificador, :radicado, :tipo, NULL, :estado, :obs, CURRENT_DATE, :usuario, NOW(), NULL) RETURNING id_expediente");
        $stmt->execute([
            ':identificador' => $identificador,
            ':radicado' => $radicado,
            ':tipo' => $tipo,
            ':estado' => $estado,
            ':obs' => $obs !== '' ? $obs : null,
            ':usuario' => $usuario,
        ]);

        $id = $stmt->fetchColumn();
        json_out(200, ['ok' => true, 'id_expediente' => $id]);
    }

    if ($action === 'proceso_update') {
        $id_expediente = param('id_expediente');
        $radicado = param('num_radicado');
        $obs = param('obs_expediente');

        if ($id_expediente === '' || $radicado === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        $radicadoLen = strlen(trim($radicado));
        if ($radicadoLen < 5 || $radicadoLen > 40) {
            json_out(400, ['ok' => false, 'error' => 'invalid_num_radicado', 'message' => 'El número de radicado debe tener entre 5 y 40 caracteres.']);
        }

        $stmt = $db->prepare("UPDATE tab_expediente SET num_radicado = :radicado, obs_expediente = :obs, fec_actualizacion = NOW() WHERE id_expediente = :id_expediente");
        $stmt->execute([
            ':id_expediente' => $id_expediente,
            ':radicado' => $radicado,
            ':obs' => $obs !== '' ? $obs : null,
        ]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'proceso_delete') {
        $id_expediente = param('id_expediente');
        if ($id_expediente === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_id_expediente']);
        }

        $stmtSuj = $db->prepare("SELECT COUNT(*) FROM tab_sujetos_expediente WHERE id_expediente = :id");
        $stmtSuj->execute([':id' => $id_expediente]);
        if ((int)$stmtSuj->fetchColumn() > 0) {
            json_out(400, ['ok' => false, 'error' => 'proceso_has_sujetos']);
        }

        $stmt = $db->prepare("DELETE FROM tab_expediente WHERE id_expediente = :id_expediente");
        $stmt->execute([':id_expediente' => $id_expediente]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'roles_list') {
        $stmt = $db->query("SELECT id_rol_sujeto, nom_rol_sujeto FROM tab_rol_sujeto ORDER BY nom_rol_sujeto");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'sujetos_list') {
        $id_expediente = param('id_expediente');
        if ($id_expediente === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_id_expediente']);
        }

        $stmt = $db->prepare("SELECT s.id_sujeto, s.id_expediente, s.id_rol_sujeto, r.nom_rol_sujeto, s.id_persona, p.nom_y_ape_completos FROM tab_sujetos_expediente s JOIN tab_rol_sujeto r ON r.id_rol_sujeto = s.id_rol_sujeto LEFT JOIN tab_persona p ON p.id_persona = s.id_persona WHERE s.id_expediente = :id_expediente ORDER BY s.id_sujeto");
        $stmt->execute([':id_expediente' => $id_expediente]);
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'sujeto_create') {
        $id_expediente = param('id_expediente');
        $id_persona = param('id_persona');
        $id_rol_sujeto = param('id_rol_sujeto');

        if ($id_expediente === '' || $id_persona === '' || $id_rol_sujeto === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        ensure_roles($db);
        $nextIdStmt = $db->prepare("SELECT COALESCE(MAX(id_sujeto), 0) + 1 FROM tab_sujetos_expediente WHERE id_expediente = :id_expediente");
        $nextIdStmt->execute([':id_expediente' => $id_expediente]);
        $id_sujeto = (int)$nextIdStmt->fetchColumn();

        $stmt = $db->prepare("INSERT INTO tab_sujetos_expediente (id_sujeto, id_expediente, id_rol_sujeto, id_persona, id_abogado, id_auxiliar, id_funcionario) VALUES (:id_sujeto, :id_expediente, :id_rol_sujeto, :id_persona, NULL, NULL, NULL)");
        $stmt->execute([
            ':id_sujeto' => $id_sujeto,
            ':id_expediente' => $id_expediente,
            ':id_rol_sujeto' => $id_rol_sujeto,
            ':id_persona' => $id_persona,
        ]);

        json_out(200, ['ok' => true]);
    }

    if ($action === 'sujeto_delete') {
        $id_expediente = param('id_expediente');
        $id_sujeto = param('id_sujeto');
        if ($id_expediente === '' || $id_sujeto === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_fields']);
        }

        $stmt = $db->prepare("DELETE FROM tab_sujetos_expediente WHERE id_expediente = :id_expediente AND id_sujeto = :id_sujeto");
        $stmt->execute([
            ':id_expediente' => $id_expediente,
            ':id_sujeto' => $id_sujeto,
        ]);

        json_out(200, ['ok' => true]);
    }

    json_out(404, ['ok' => false, 'error' => 'unknown_action']);
} catch (Throwable $e) {
    json_out(500, ['ok' => false, 'error' => 'server_error', 'message' => $e->getMessage()]);
}
