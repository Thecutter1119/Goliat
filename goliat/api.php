<?php
session_start();

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
        $stmt = $db->query("SELECT p.id_persona, p.id_tipo_doc, t.cod_tipo_doc, p.nom_y_ape_completos, p.email_persona, p.tel_persona, p.fec_creacion FROM tab_persona p JOIN tab_tipo_documento_identidad t ON t.id_tipo_doc = p.id_tipo_doc ORDER BY p.fec_creacion DESC LIMIT 200");
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

    if ($action === 'procesos_list') {
        $stmt = $db->query("SELECT e.id_expediente, e.identificador_interno, e.num_radicado, e.id_estado_proceso, s.cod_estado_proceso, e.fec_reparto, e.fec_creacion FROM tab_expediente e JOIN tab_estado_proceso s ON s.id_estado_proceso = e.id_estado_proceso ORDER BY e.fec_creacion DESC LIMIT 200");
        json_out(200, ['ok' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    if ($action === 'proceso_create') {
        $radicado = param('num_radicado');
        $obs = param('obs_expediente');
        $usuario = (string)$_SESSION['id_usuario'];

        if ($radicado === '') {
            json_out(400, ['ok' => false, 'error' => 'missing_num_radicado']);
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

    json_out(404, ['ok' => false, 'error' => 'unknown_action']);
} catch (Throwable $e) {
    json_out(500, ['ok' => false, 'error' => 'server_error', 'message' => $e->getMessage()]);
}

