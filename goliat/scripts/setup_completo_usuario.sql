-- ========================================================
-- SCRIPT COMPLETO PARA CREAR USUARIO ADMINISTRADOR
-- Primero insertamos los datos básicos necesarios
-- ========================================================

-- 1. Insertar tipos de documento (si no existen)
INSERT INTO tab_tipo_documento_identidad (id_tipo_doc, cod_tipo_doc, des_tipo_doc)
VALUES (1, 'CC', 'Cédula de ciudadanía')
ON CONFLICT (id_tipo_doc) DO NOTHING;

INSERT INTO tab_tipo_documento_identidad (id_tipo_doc, cod_tipo_doc, des_tipo_doc)
VALUES (2, 'CE', 'Cédula de extranjería')
ON CONFLICT (id_tipo_doc) DO NOTHING;

INSERT INTO tab_tipo_documento_identidad (id_tipo_doc, cod_tipo_doc, des_tipo_doc)
VALUES (3, 'TI', 'Tarjeta de identidad')
ON CONFLICT (id_tipo_doc) DO NOTHING;

-- 2. Insertar estados de proceso (básicos)
INSERT INTO tab_estado_proceso (id_estado_proceso, cod_estado_proceso, des_estado_proceso, ind_terminal)
VALUES (1, 'REPARTO', 'En reparto', FALSE)
ON CONFLICT (id_estado_proceso) DO NOTHING;

INSERT INTO tab_estado_proceso (id_estado_proceso, cod_estado_proceso, des_estado_proceso, ind_terminal)
VALUES (2, 'ACTIVO', 'En trámite', FALSE)
ON CONFLICT (id_estado_proceso) DO NOTHING;

INSERT INTO tab_estado_proceso (id_estado_proceso, cod_estado_proceso, des_estado_proceso, ind_terminal)
VALUES (13, 'ARCHIVADO', 'Archivado', TRUE)
ON CONFLICT (id_estado_proceso) DO NOTHING;

-- 3. Insertar la persona
INSERT INTO tab_persona (id_persona, id_tipo_doc, nom_y_ape_completos, fec_nacimiento, ind_menor_edad, tip_genero, email_persona, tel_persona, dir_persona, id_ciudad, obs_persona, fec_creacion)
VALUES (
    '1234567890',
    1,
    'Juan Pérez García',
    '1990-01-15',
    FALSE,
    'M',
    'juan.perez@ejemplo.com',
    '3001234567',
    'Calle 123 #45-67, Bogotá',
    NULL,
    'Usuario administrador de prueba',
    NOW()
)
ON CONFLICT (id_persona) DO NOTHING;

-- 4. Insertar el usuario
INSERT INTO tab_usuario (id_usuario, contrasena, ind_admin, ind_estado, fec_ultimo_acceso, fec_creacion, fec_actualizacion)
VALUES (
    '1234567890',
    'admin123',
    TRUE,
    TRUE,
    NULL,
    NOW(),
    NOW()
)
ON CONFLICT (id_usuario) DO NOTHING;

-- ========================================================
-- CREDENCIALES DE INICIO DE SESIÓN:
-- Usuario (cédula): 1234567890
-- Contraseña: admin123
-- ========================================================
