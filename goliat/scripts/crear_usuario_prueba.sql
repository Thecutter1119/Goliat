-- ========================================================
-- SCRIPT PARA CREAR USUARIO ADMINISTRADOR DE PRUEBA
-- ========================================================

-- 1. Primero insertamos la persona (requisito para el usuario)
INSERT INTO tab_persona (id_persona, id_tipo_doc, nom_y_ape_completos, fec_nacimiento, ind_menor_edad, tip_genero, email_persona, tel_persona, dir_persona, id_ciudad, obs_persona, fec_creacion)
VALUES (
    '1234567890',  -- Número de cédula (username para login)
    1,              -- Tipo de documento: CC (Cédula de ciudadanía)
    'Juan Pérez García',
    '1990-01-15',
    FALSE,
    'M',
    'juan.perez@ejemplo.com',
    '3001234567',
    'Calle 123 #45-67, Bogotá',
    NULL,           -- id_ciudad (puedes cambiarlo si tienes ciudades insertadas)
    'Usuario administrador de prueba',
    NOW()
);

-- 2. Insertamos el usuario (vinculado a la persona)
INSERT INTO tab_usuario (id_usuario, contrasena, ind_admin, ind_estado, fec_ultimo_acceso, fec_creacion, fec_actualizacion)
VALUES (
    '1234567890',  -- Mismo id_persona (cedula)
    'admin123',     -- Contraseña de prueba
    TRUE,           -- Es administrador
    TRUE,           -- Estado activo
    NULL,
    NOW(),
    NOW()
);

-- ========================================================
-- CREDENCIALES DE INICIO DE SESIÓN:
-- Usuario (cédula): 1234567890
-- Contraseña: admin123
-- ========================================================
