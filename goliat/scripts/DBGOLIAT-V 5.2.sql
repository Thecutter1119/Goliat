-- ========================================================================================================================
--  BASE DE DATOS: PROCESOS DE GOLIAT
-- ========================================================================================================================


-- ========================================================================================================================
-- SCRIPT DE LIMPIEZA TOTAL (DROP TABLES) - PROCESOS DE GOLIAT V5
-- ========================================================================================================================

-- 1. Tablas Transaccionales y de negocio (Módulos principales)
DROP TABLE IF EXISTS tab_archivos_base_expediente;
DROP TABLE IF EXISTS tab_tipo_archivo;
DROP TABLE IF EXISTS tab_termino_procesal;
DROP TABLE IF EXISTS tab_notificacion;
DROP TABLE IF EXISTS tab_medida_cautelar;
DROP TABLE IF EXISTS tab_actuacion;
DROP TABLE IF EXISTS tab_archivos;
DROP TABLE IF EXISTS tab_cuaderno;
DROP TABLE IF EXISTS tab_etapa_procesal;
DROP TABLE IF EXISTS tab_dictamen_pericial;
DROP TABLE IF EXISTS tab_sujetos_expediente;
DROP TABLE IF EXISTS tab_expediente;

-- 2. Tablas del Sistema, Accesos y Menús
DROP TABLE IF EXISTS tab_menu_usuario;
DROP TABLE IF EXISTS tab_menu;
DROP TABLE IF EXISTS tab_sesion;
DROP TABLE IF EXISTS tab_usuario;

-- 3. Tablas de Personas, Roles y Entidades
DROP TABLE IF EXISTS tab_funcionario;
DROP TABLE IF EXISTS tab_auxiliar_justicia;
DROP TABLE IF EXISTS tab_abogado;
DROP TABLE IF EXISTS tab_persona;
DROP TABLE IF EXISTS tab_despacho;

-- 4. Tablas Geográficas y de Parámetros Base
DROP TABLE IF EXISTS tab_entidad;
DROP TABLE IF EXISTS tab_ciudad;
DROP TABLE IF EXISTS tab_deptos;
DROP TABLE IF EXISTS tab_rol_sujeto;
DROP TABLE IF EXISTS tab_tipo_expediente;
DROP TABLE IF EXISTS tab_tipo_notificacion;
DROP TABLE IF EXISTS tab_tipo_medio_prueba;
DROP TABLE IF EXISTS tab_tipo_actuacion;
DROP TABLE IF EXISTS tab_estado_proceso;
DROP TABLE IF EXISTS tab_tipo_documento_identidad;

-- 5. Tablas de catálogo referenciadas en FKs (antes faltaban, ahora sí se crean más abajo)
DROP TABLE IF EXISTS tab_tipo_auxiliar_justicia;
DROP TABLE IF EXISTS tab_tipo_cargo_funcionario;
DROP TABLE IF EXISTS tab_tipo_dictamen;
DROP TABLE IF EXISTS tab_parametros;



--TABLA DE PARAMETROS DEL SISTEMA
CREATE TABLE IF NOT EXISTS tab_parametros
(
    id_empresa                          DECIMAL(10,0)   NOT NULL,
    valor_actual_consecutivo            INT             NOT NULL    CHECK(valor_actual_consecutivo > 0),
    PRIMARY KEY (id_empresa)
);
-- TABLA DE TIPOS DE DOCUMENTOS DE INDENTIDAD
CREATE TABLE IF NOT EXISTS tab_tipo_documento_identidad
(
    id_tipo_doc         DECIMAL(1,0)    NOT NULL,
    cod_tipo_doc        VARCHAR(5)      NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_doc)) BETWEEN 2 AND 5),
    des_tipo_doc        VARCHAR(80)     NOT NULL    CHECK(LENGTH(TRIM(des_tipo_doc)) >= 3),
    PRIMARY KEY (id_tipo_doc)
);


-- ========================================================================================================================
--TABLA DE ESTADOS DE UN PROCESO
CREATE TABLE IF NOT EXISTS tab_estado_proceso
(
    id_estado_proceso   DECIMAL(2,0)    NOT NULL,
    cod_estado_proceso  VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_estado_proceso)) BETWEEN 3 AND 30),
    des_estado_proceso  VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(des_estado_proceso)) >= 3),
    ind_terminal        BOOLEAN         NOT NULL    DEFAULT FALSE,
    PRIMARY KEY (id_estado_proceso)
);

-- ========================================================================================================================
--TABLA DE TIPOS DE ACTUACIONES 
CREATE TABLE IF NOT EXISTS tab_tipo_actuacion
(
    id_tipo_actuacion   DECIMAL(2,0)    NOT NULL,
    cod_tipo_actuacion  VARCHAR(40)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_actuacion)) BETWEEN 3 AND 40),
    des_tipo_actuacion  VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(des_tipo_actuacion)) >= 3),
    PRIMARY KEY (id_tipo_actuacion)
);
-- ========================================================================================================================
--TABLA DE LOS MEDIOS DE PRUEBAS
CREATE TABLE IF NOT EXISTS tab_tipo_medio_prueba
(
    id_tipo_medio_prueba    DECIMAL(1,0)    NOT NULL,
    cod_tipo_medio_prueba   VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_medio_prueba)) BETWEEN 3 AND 30),
    des_tipo_medio_prueba   VARCHAR(80)     NOT NULL    CHECK(LENGTH(TRIM(des_tipo_medio_prueba)) >= 3),
    PRIMARY KEY (id_tipo_medio_prueba)
);
-- ========================================================================================================================
--TABLA DE LOS TIPOS DE NOTIFICACIONES 
CREATE TABLE IF NOT EXISTS tab_tipo_notificacion
(
    id_tipo_notificacion    DECIMAL(1,0)    NOT NULL,
    cod_tipo_notificacion   VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_notificacion)) BETWEEN 3 AND 30),
    des_tipo_notificacion   VARCHAR(80)     NOT NULL    CHECK(LENGTH(TRIM(des_tipo_notificacion)) >= 3),
    PRIMARY KEY (id_tipo_notificacion)
);

-- ========================================================================================================================
--TABLAS DE UBICACION GEOGRAFICA
CREATE TABLE IF NOT EXISTS tab_deptos
(
    id_depto            VARCHAR(2)      NOT NULL    CHECK(LENGTH(TRIM(id_depto)) >= 2),
    nom_depto           VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(nom_depto)) >= 2),
    nom_pais            VARCHAR(60)     NOT NULL    DEFAULT 'Colombia',
    PRIMARY KEY (id_depto)
);

CREATE TABLE IF NOT EXISTS tab_ciudad
(
    id_ciudad           VARCHAR(7)      NOT NULL,
    cod_dane            VARCHAR(10)                 CHECK(LENGTH(TRIM(cod_dane)) BETWEEN 4 AND 10),
    nom_ciudad          VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(nom_ciudad)) BETWEEN 2 AND 120),
    id_depto            VARCHAR(2)      NOT NULL,
    PRIMARY KEY (id_ciudad),
    FOREIGN KEY (id_depto) REFERENCES tab_deptos(id_depto)
);
--========================================================================================================================
--TABLAS DE ENTIDADES JUDICIALES - JUZGADOS - DESPACHOS - ENTIDADES EXTERNAS
CREATE TABLE IF NOT EXISTS tab_despacho
(
    id_despacho         DECIMAL(15,0)   NOT NULL    CHECK(id_despacho > 0),
    nom_despacho        VARCHAR(150)    NOT NULL    CHECK(LENGTH(TRIM(nom_despacho)) BETWEEN 5 AND 150),
    dir_despacho        TEXT,
    tel_despacho        VARCHAR(20),
    email_despacho      VARCHAR(120),
    id_ciudad           VARCHAR(7),
    PRIMARY KEY (id_despacho),
    FOREIGN KEY (id_ciudad) REFERENCES tab_ciudad(id_ciudad)
);
--========================================================================================================================


--TABLAS DE PERSONAS - USUARIOS - ABOGADOS - PARTES DEL PROCESO - AUXILIARES - FUNCIONARIOS
--TABLA PADRE PERSONAS EN GENERAL
CREATE TABLE IF NOT EXISTS tab_persona
(
    id_persona          VARCHAR(10)     NOT NULL    CHECK(id_persona ~ '^[0-9]{6,10}$'),
    id_tipo_doc         DECIMAL(1,0)    NOT NULL,
    nom_y_ape_completos VARCHAR(200)    NOT NULL    CHECK(LENGTH(TRIM(nom_y_ape_completos)) BETWEEN 2 AND 200),
    fec_nacimiento      DATE,
    ind_menor_edad      BOOLEAN         NOT NULL    DEFAULT FALSE,
    tip_genero          CHAR(1)                     CHECK(tip_genero IN ('M','F','X')),
    email_persona       VARCHAR(120),
    tel_persona         VARCHAR(15),
    dir_persona         TEXT,
    id_ciudad           VARCHAR(7),
    obs_persona         TEXT,
    fec_creacion        TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    PRIMARY KEY (id_persona),
    FOREIGN KEY (id_tipo_doc) REFERENCES tab_tipo_documento_identidad(id_tipo_doc),
    FOREIGN KEY (id_ciudad)   REFERENCES tab_ciudad(id_ciudad)
);


-- ========================================================================================================================
-- TABLAS DE CATÁLOGO QUE FALTABAN (estaban referenciadas en FK pero nunca se creaban)
-- ========================================================================================================================

--TABLA DE ENTIDADES EXTERNAS (laboratorios, universidades, entidades públicas que aportan auxiliares de justicia)
CREATE TABLE IF NOT EXISTS tab_entidad
(
    id_entidad          INT             NOT NULL    CHECK(id_entidad > 0),
    nom_entidad         VARCHAR(150)    NOT NULL    CHECK(LENGTH(TRIM(nom_entidad)) BETWEEN 3 AND 150),
    nit_entidad         VARCHAR(20),
    tip_entidad         VARCHAR(40)                 CHECK(tip_entidad IN ('LABORATORIO','UNIVERSIDAD','ENTIDAD_PUBLICA','ENTIDAD_PRIVADA','ONG','OTRO')),
    dir_entidad         TEXT,
    tel_entidad         VARCHAR(20),
    email_entidad       VARCHAR(120),
    id_ciudad           VARCHAR(7),
    PRIMARY KEY (id_entidad),
    FOREIGN KEY (id_ciudad) REFERENCES tab_ciudad(id_ciudad)
);

--TABLA DE TIPOS DE AUXILIAR DE JUSTICIA (perito, curador, secuestre, etc.)
CREATE TABLE IF NOT EXISTS tab_tipo_auxiliar_justicia
(
    id_tipo_auxiliar    DECIMAL(1,0)    NOT NULL,
    cod_tipo_auxiliar   VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_auxiliar)) BETWEEN 3 AND 30),
    des_tipo_auxiliar   VARCHAR(100)    NOT NULL    CHECK(LENGTH(TRIM(des_tipo_auxiliar)) >= 3),
    PRIMARY KEY (id_tipo_auxiliar)
);

--TABLA DE TIPOS DE CARGO DE FUNCIONARIO (juez, secretario, sustanciador, etc.)
CREATE TABLE IF NOT EXISTS tab_tipo_cargo_funcionario
(
    id_tipo_cargo       DECIMAL(1,0)    NOT NULL,
    cod_tipo_cargo      VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_cargo)) BETWEEN 3 AND 30),
    des_tipo_cargo      VARCHAR(100)    NOT NULL    CHECK(LENGTH(TRIM(des_tipo_cargo)) >= 3),
    PRIMARY KEY (id_tipo_cargo)
);

--TABLA DE TIPOS DE DICTAMEN PERICIAL
CREATE TABLE IF NOT EXISTS tab_tipo_dictamen
(
    id_tipo_dictamen    DECIMAL(1,0)    NOT NULL,
    cod_tipo_dictamen   VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(cod_tipo_dictamen)) BETWEEN 3 AND 30),
    des_tipo_dictamen   VARCHAR(100)    NOT NULL    CHECK(LENGTH(TRIM(des_tipo_dictamen)) >= 3),
    PRIMARY KEY (id_tipo_dictamen)
);

--TABLA DE ABOGADOS
CREATE TABLE IF NOT EXISTS tab_abogado
(
    id_abogado          VARCHAR(10)     NOT NULL    CHECK(id_abogado ~ '^[0-9]{6,10}$'),
    num_tarjeta_prof    VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(num_tarjeta_prof)) BETWEEN 4 AND 30),
    email_notificacion  VARCHAR(120)    NOT NULL,
    ind_activo          BOOLEAN         NOT NULL    DEFAULT TRUE,
    PRIMARY KEY (id_abogado),
    FOREIGN KEY (id_abogado) REFERENCES tab_persona(id_persona)
);

--TABLA DE AUXILIARES DE JUSTICIA 
CREATE TABLE IF NOT EXISTS tab_auxiliar_justicia
(
    id_auxiliar         VARCHAR(10)     NOT NULL    CHECK(id_auxiliar ~ '^[0-9]{6,10}$'),
    id_tipo_auxiliar    DECIMAL(1,0)    NOT NULL,
    id_entidad          INT,
    num_registro_prof   VARCHAR(40),
    email_institucional VARCHAR(120),
    ind_activo          BOOLEAN         NOT NULL    DEFAULT TRUE,
    PRIMARY KEY (id_auxiliar),
    FOREIGN KEY (id_auxiliar)       REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_tipo_auxiliar)  REFERENCES tab_tipo_auxiliar_justicia(id_tipo_auxiliar),
    FOREIGN KEY (id_entidad)        REFERENCES tab_entidad(id_entidad)
);

--TABLA DE FUNCIONARIOS Y/O AUTORIDADES EN UNA ENTIDAD RESPONSABLE (JUZGADOS, COMISARIAS, ETC ) 
CREATE TABLE IF NOT EXISTS tab_funcionario
(
    id_funcionario      VARCHAR(10)     NOT NULL    CHECK(id_funcionario ~ '^[0-9]{6,10}$'),
    id_despacho         INT             NOT NULL,
    id_tipo_cargo       DECIMAL(1,0)    NOT NULL,
    email_institucional VARCHAR(120),
    ind_activo          BOOLEAN         NOT NULL    DEFAULT TRUE,
    fec_vinculacion     DATE,
    fec_retiro          DATE,
    PRIMARY KEY (id_funcionario),
    FOREIGN KEY (id_funcionario)    REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_despacho)       REFERENCES tab_despacho(id_despacho),
    FOREIGN KEY (id_tipo_cargo)     REFERENCES tab_tipo_cargo_funcionario(id_tipo_cargo)
);

-- ========================================================================================================================
-- USUARIOS - SESIONES - MENUS
--TABLA DE USUARIOS DEL SISTEMA
CREATE TABLE IF NOT EXISTS tab_usuario
(
    id_usuario          VARCHAR(10)     NOT NULL,
    contrasena          TEXT            NOT NULL,
    ind_admin           BOOLEAN         NOT NULL    DEFAULT FALSE, -- CORRECCIÓN: Renombrado de ind_usuario a ind_admin para claridad
    ind_estado          BOOLEAN         NOT NULL    DEFAULT TRUE,
    fec_ultimo_acceso   TIMESTAMPTZ,
    fec_creacion        TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_actualizacion   TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    PRIMARY KEY (id_usuario),
    FOREIGN KEY (id_usuario) REFERENCES tab_persona(id_persona)
);

--TABLA DE AUDITORIA DE SESIONES DEL SISTEMA
CREATE TABLE IF NOT EXISTS tab_sesion
(
    id_sesion           BIGINT          NOT NULL    CHECK(id_sesion > 0),
    id_usuario          VARCHAR(10)     NOT NULL,
    tok_sesion          VARCHAR(256)    NOT NULL    CHECK(LENGTH(TRIM(tok_sesion)) >= 10),
    ip_sesion           INET,
    fec_inicio          TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_expira          TIMESTAMPTZ     NOT NULL,
    ind_activa          BOOLEAN         NOT NULL    DEFAULT TRUE,
    PRIMARY KEY (id_sesion),
    UNIQUE      (tok_sesion),
    FOREIGN KEY (id_usuario) REFERENCES tab_usuario(id_usuario)
);

--TABLA DE MENUS DEL SISTEMA 
CREATE TABLE IF NOT EXISTS tab_menu
(
    id_menu             VARCHAR(10)     NOT NULL,
    nom_menu            VARCHAR(100)    NOT NULL,
    id_menu_padre       VARCHAR(10)     DEFAULT NULL,
    nom_programa        VARCHAR(100)    NOT NULL,
    PRIMARY KEY (id_menu),
    FOREIGN KEY (id_menu_padre) REFERENCES tab_menu(id_menu)
);

--RELACION DE MENUS CON USUARIOS DEL SISTEMA 
CREATE TABLE IF NOT EXISTS tab_menu_usuario
(
    id_usuario          VARCHAR(10)     NOT NULL,
    id_menu             VARCHAR(10)     NOT NULL,
    PRIMARY KEY (id_usuario, id_menu),
    FOREIGN KEY (id_usuario)  REFERENCES tab_usuario(id_usuario),
    FOREIGN KEY (id_menu)     REFERENCES tab_menu(id_menu)
);


-- ========================================================================================================================
--TABLA DE TIPOS DE ARCHIVOS O DOCUMENTOS 
CREATE TABLE IF NOT EXISTS tab_tipo_archivo
(
    id_tipo_archivo         DECIMAL(2,0)    NOT NULL,
    nom_tipo_archivo        VARCHAR         NOT NULL,
    desc_tipo_archivo       VARCHAR         NOT NULL,
    PRIMARY KEY (id_tipo_archivo)
);

--TABLA DE DOCUMENTACION / Y ARCHIVOS DIGITALES 
CREATE TABLE IF NOT EXISTS tab_archivos
(
    id_archivo              BIGINT             NOT NULL    CHECK(id_archivo > 0),
    nom_archivo             VARCHAR(50)        NOT NULL    CHECK(LENGTH(TRIM(nom_archivo)) BETWEEN 3 AND 50),
    id_tipo_archivo         VARCHAR(60)       NOT NULL,
    formato_archivo         VARCHAR           NOT NULL,
    tam_bytes               BIGINT             NOT NULL    CHECK(tam_bytes > 0),
    paginas                 INT                NOT NULL    CHECK(paginas > 0),
    url_documento           TEXT               NOT NULL,

    id_usuario_carga        VARCHAR(10)                 CHECK(id_usuario_carga ~ '^[0-9]{6,10}$'),
    fec_carga               TIMESTAMPTZ        NOT NULL    DEFAULT NOW(),
    hash_sha256             CHAR(64)           NOT NULL,
    ind_publico             BOOLEAN            NOT NULL    DEFAULT FALSE,
    PRIMARY KEY (id_archivo),
    FOREIGN KEY (id_usuario_carga) REFERENCES tab_usuario(id_usuario)
);

-- ========================================================================================================================
--TABLA D TIPOS DE PROCESOS - EXPEDIENTES
CREATE TABLE IF NOT EXISTS tab_tipo_expediente
(
    id_tipo_expediente          INT            NOT NULL,
	etiqueta_tipo               VARCHAR(6)     NOT NULL,
    nom_tipo_expediente         VARCHAR(40)    NOT NULL,
    jurisdiccion                VARCHAR        NOT NULL,
    campos_adicionales          JSONB          NOT NULL,
    PRIMARY KEY (id_tipo_expediente)
);


--TABLA EXPEDIENTES, TABLA PILAR DEL SISTEMA 
CREATE TABLE IF NOT EXISTS tab_expediente
(
    id_expediente       INT             NOT NULL    GENERATED ALWAYS AS IDENTITY,
    identificador_interno VARCHAR(40)   NOT NULL    UNIQUE,
    num_radicado        VARCHAR(40)     NOT NULL    CHECK(LENGTH(TRIM(num_radicado)) BETWEEN 5 AND 40),
    id_tipo_expediente  INT             NOT NULL,
    id_despacho         INT,
    id_estado_proceso   DECIMAL(2,0)    NOT NULL,
    obs_expediente      VARCHAR(250),


    fec_reparto         DATE            NOT NULL,
    id_usuario_crea     VARCHAR(10)     NOT NULL    CHECK(id_usuario_crea ~ '^[0-9]{6,10}$'),
    fec_creacion        TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_actualizacion   TIMESTAMPTZ ,
    PRIMARY KEY (id_expediente),
    FOREIGN KEY (id_tipo_expediente)    REFERENCES tab_tipo_expediente(id_tipo_expediente),
    FOREIGN KEY (id_estado_proceso)     REFERENCES tab_estado_proceso(id_estado_proceso),
    FOREIGN KEY (id_despacho)            REFERENCES tab_despacho(id_despacho),
    FOREIGN KEY (id_usuario_crea)       REFERENCES tab_usuario(id_usuario)
);


-- ========================================================================================================================
--TABLA DE ROL DEL SUJETO DENTRO DEL PROCESO 
CREATE TABLE IF NOT EXISTS tab_rol_sujeto
(
    id_rol_sujeto            VARCHAR(10)     NOT NULL,
    nom_rol_sujeto           VARCHAR(50)     NOT NULL,
    desc_rol_sujeto          VARCHAR(150)    NOT NULL,
    PRIMARY KEY (id_rol_sujeto)
);
                                                                                             

--TABLA DE SUJETOS QUE INTERVIENEN EN EL PROCESO 
CREATE TABLE IF NOT EXISTS tab_sujetos_expediente
(
    id_sujeto                INT                NOT NULL,
    id_expediente            INT                NOT NULL,
    id_rol_sujeto            VARCHAR(10)        NOT NULL,
    id_persona               VARCHAR(10)        CHECK(id_persona ~ '^[0-9]{6,10}$'),
    id_abogado               VARCHAR(10)        CHECK(id_abogado ~ '^[0-9]{6,10}$'),
    id_auxiliar              VARCHAR(10)        CHECK(id_auxiliar ~ '^[0-9]{6,10}$'),
    id_funcionario           VARCHAR(10)        CHECK(id_funcionario ~ '^[0-9]{6,10}$'),
    PRIMARY KEY (id_sujeto,id_expediente),
    FOREIGN KEY (id_expediente)             REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_persona)                 REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_abogado)                 REFERENCES tab_abogado(id_abogado),
    FOREIGN KEY (id_auxiliar)                REFERENCES tab_auxiliar_justicia(id_auxiliar),
    FOREIGN KEY (id_funcionario)             REFERENCES tab_funcionario(id_funcionario)
);

CREATE TABLE IF NOT EXISTS tab_archivos_base_expediente
(
    id_expediente       INT                NOT NULL    CHECK(id_expediente > 0),
    id_archivo          BIGINT             NOT NULL    CHECK(id_archivo > 0),
    id_sujeto_aporta    INT,
    PRIMARY KEY (id_expediente, id_archivo),
    FOREIGN KEY (id_expediente)    REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_archivo)       REFERENCES tab_archivos(id_archivo),
    
    FOREIGN KEY (id_sujeto_aporta, id_expediente) REFERENCES tab_sujetos_expediente(id_sujeto, id_expediente)
);
-- ========================================================================================================================

--TABLA DE DICTAMENES DE AUXILIARES DE JUSTICIA 
CREATE TABLE IF NOT EXISTS tab_dictamen_pericial
(
    id_dictamen         INT             NOT NULL    CHECK(id_dictamen > 0),
    id_expediente       INT             NOT NULL,
    id_auxiliar         VARCHAR(10)     NOT NULL    CHECK(id_auxiliar ~ '^[0-9]{6,10}$'),
    id_tipo_dictamen    DECIMAL(1,0)    NOT NULL,
    fec_encargo         DATE,
    fec_entrega         DATE,
    txt_resumen         TEXT,
    txt_conclusiones    TEXT,
    url_archivo         TEXT,
    PRIMARY KEY (id_dictamen),
    FOREIGN KEY (id_expediente)    REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_auxiliar)      REFERENCES tab_auxiliar_justicia(id_auxiliar),
    FOREIGN KEY (id_tipo_dictamen) REFERENCES tab_tipo_dictamen(id_tipo_dictamen)
);

-- ========================================================================================================================

--TABLA MAS TRANSACCIONAL DENTRO DEL SISTEMA 
--TABLA DE ACTUACIONES EN UN EXPEDIENTE 

-- ========================================================================================================================
-- EXPEDIENTE ELECTRÓNICO: ETAPAS PROCESALES Y CUADERNOS
-- Jerarquía exigida por la Rama Judicial: Expediente -> Etapa -> Cuaderno -> Actuación -> Documento
-- ========================================================================================================================

--TABLA DE ETAPAS PROCESALES (Primera Instancia, Segunda Instancia, Casación, etc.)
CREATE TABLE IF NOT EXISTS tab_etapa_procesal
(
    id_etapa            INT             NOT NULL    CHECK(id_etapa > 0),
    id_expediente       INT             NOT NULL,
    nom_etapa           VARCHAR(30)    NOT NULL     CHECK(LENGTH(TRIM(nom_etapa)) BETWEEN 3 AND 30),
    orden               INT             NOT NULL    CHECK(orden > 0),
    PRIMARY KEY (id_etapa),
    FOREIGN KEY (id_expediente) REFERENCES tab_expediente(id_expediente),
    CONSTRAINT uq_expediente_orden_etapa UNIQUE (id_expediente, orden)
);

--TABLA DE CUADERNOS (Principal, Pruebas, Medidas Cautelares, etc., dentro de cada etapa)
CREATE TABLE IF NOT EXISTS tab_cuaderno
(
    id_cuaderno         INT             NOT NULL    CHECK(id_cuaderno > 0),
    id_etapa            INT             NOT NULL,
    cod_cuaderno        VARCHAR(3)      NOT NULL    CHECK(LENGTH(TRIM(cod_cuaderno)) BETWEEN 2 AND 3),
    nom_cuaderno        VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(nom_cuaderno)) BETWEEN 3 AND 30),
    PRIMARY KEY (id_cuaderno),
    FOREIGN KEY (id_etapa) REFERENCES tab_etapa_procesal(id_etapa),
    CONSTRAINT uq_etapa_codigo_cuaderno UNIQUE (id_etapa, cod_cuaderno)
);

--TABLA DE ACTUACIONES: cada actuación queda registrada dentro de UN cuaderno fijo
-- (se conserva id_expediente, además de id_cuaderno, para no romper los índices ya
--  definidos más abajo; la app debe validar que el cuaderno pertenezca al expediente indicado)
CREATE TABLE IF NOT EXISTS tab_actuacion
(
    id_actuacion            INT             NOT NULL    CHECK(id_actuacion > 0),
    id_cuaderno             INT             NOT NULL,
    id_archivo              BIGINT          NOT NULL    CHECK(id_archivo > 0),
    id_tipo_actuacion       DECIMAL(2,0)    NOT NULL,
    fec_actuacion           DATE            NOT NULL,
    des_actuacion           TEXT            NOT NULL    CHECK(LENGTH(TRIM(des_actuacion)) >= 3),
    id_usuario_registra     VARCHAR(10)     NOT NULL    CHECK(id_usuario_registra ~ '^[0-9]{6,10}$'),
    fec_registro            TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    PRIMARY KEY (id_actuacion),
    FOREIGN KEY (id_cuaderno)          REFERENCES tab_cuaderno(id_cuaderno),
    FOREIGN KEY (id_archivo)            REFERENCES tab_archivos(id_archivo),
    FOREIGN KEY (id_tipo_actuacion)    REFERENCES tab_tipo_actuacion(id_tipo_actuacion),
    FOREIGN KEY (id_usuario_registra)  REFERENCES tab_usuario(id_usuario)
);

-- ========================================================================================================================

--TABLA DE NOTIFICACIONES 
CREATE TABLE IF NOT EXISTS tab_notificacion
(
    id_notificacion     INT             NOT NULL    CHECK(id_notificacion > 0),
    id_expediente       INT             NOT NULL,
    id_actuacion        INT,
    id_persona_dest     VARCHAR(10)     NOT NULL    CHECK(id_persona_dest ~ '^[0-9]{6,10}$'),
    id_tipo_notif       DECIMAL(1,0)    NOT NULL,
    fec_envio           DATE,
    fec_surtida         DATE,
    ind_surtida         BOOLEAN         NOT NULL    DEFAULT FALSE,
    tip_medio           VARCHAR(20)                 CHECK(tip_medio IN ('CORREO_FISICO','EMAIL','ESTRADO','CURADOR_AD_LITEM')),
    url_constancia      TEXT,
    obs_notificacion    TEXT,
    PRIMARY KEY (id_notificacion),
    FOREIGN KEY (id_expediente)  REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_actuacion)   REFERENCES tab_actuacion(id_actuacion),
    FOREIGN KEY (id_persona_dest) REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_tipo_notif)  REFERENCES tab_tipo_notificacion(id_tipo_notificacion)
);

--TABLA DE MEDIDAS CAUTELARES
CREATE TABLE IF NOT EXISTS tab_medida_cautelar
(
    id_medida           INT             NOT NULL    CHECK(id_medida > 0),
    id_expediente       INT             NOT NULL,
    tip_medida          VARCHAR(20)     NOT NULL    CHECK(tip_medida IN ('EMBARGO','SECUESTRO','VISITA_SUPERVISADA','ALIMENTOS_PROV','MEDIDA_PROTECCION')),
    des_medida          TEXT            NOT NULL,
    id_actuacion        INT,
    fec_decreto         DATE,
    fec_ejecucion       DATE,
    fec_levantamiento   DATE,
    ind_vigente         BOOLEAN         NOT NULL    DEFAULT TRUE,
    id_responsable      VARCHAR(10),
    PRIMARY KEY (id_medida),
    FOREIGN KEY (id_expediente)  REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_actuacion)   REFERENCES tab_actuacion(id_actuacion),
    FOREIGN KEY (id_responsable) REFERENCES tab_auxiliar_justicia(id_auxiliar)
);





--TABLA DE TERMINOS PROCESALES 
CREATE TABLE IF NOT EXISTS tab_termino_procesal
(
    id_termino          INT             NOT NULL    CHECK(id_termino > 0),
    id_expediente       INT             NOT NULL,
    des_termino         VARCHAR(200)    NOT NULL    CHECK(LENGTH(TRIM(des_termino)) BETWEEN 5 AND 200),
    tip_termino         VARCHAR(20)                 CHECK(tip_termino IN ('TRASLADO','RECURSO','AUDIENCIA','EJECUTORIA','PLAZO_PERICIA')),
    fec_inicio          DATE            NOT NULL,
    fec_ejecutoria      DATE,
    fec_vencimiento     DATE            NOT NULL,
    num_dias_habiles    INT,
    est_termino         VARCHAR(20)     NOT NULL    DEFAULT 'VIGENTE' CHECK(est_termino IN ('VIGENTE','VENCIDO','SUSPENDIDO','INTERRUMPIDO')),
    id_actuacion_origen INT,
    obs_termino         TEXT,
    PRIMARY KEY (id_termino),
    FOREIGN KEY (id_expediente)       REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_actuacion_origen) REFERENCES tab_actuacion(id_actuacion)
);

-- ========================================================================================================================

--SECCION DE INDEX 
-- tab_ciudad
CREATE INDEX IF NOT EXISTS idx_ciudad_depto ON tab_ciudad (id_depto);

-- tab_despacho
CREATE INDEX IF NOT EXISTS idx_despacho_ciudad ON tab_despacho (id_ciudad);

-- tab_persona
CREATE INDEX IF NOT EXISTS idx_persona_tipodoc ON tab_persona (id_tipo_doc);
CREATE INDEX IF NOT EXISTS idx_persona_ciudad  ON tab_persona (id_ciudad);
CREATE INDEX IF NOT EXISTS idx_persona_nombre  ON tab_persona (nom_y_ape_completos);
CREATE INDEX IF NOT EXISTS idx_persona_email   ON tab_persona (email_persona);

-- tab_entidad
CREATE INDEX IF NOT EXISTS idx_entidad_ciudad ON tab_entidad (id_ciudad);

-- tab_auxiliar_justicia
CREATE INDEX IF NOT EXISTS idx_auxiliar_tipo    ON tab_auxiliar_justicia (id_tipo_auxiliar);
CREATE INDEX IF NOT EXISTS idx_auxiliar_entidad ON tab_auxiliar_justicia (id_entidad);

-- tab_funcionario
CREATE INDEX IF NOT EXISTS idx_funcionario_despacho  ON tab_funcionario (id_despacho);
CREATE INDEX IF NOT EXISTS idx_funcionario_tipocargo ON tab_funcionario (id_tipo_cargo);

-- tab_sesion 
CREATE INDEX IF NOT EXISTS idx_sesion_usuario       ON tab_sesion (id_usuario);
CREATE INDEX IF NOT EXISTS idx_sesion_activa_expira ON tab_sesion (ind_activa, fec_expira);

-- tab_menu
CREATE INDEX IF NOT EXISTS idx_menu_padre ON tab_menu (id_menu_padre);

-- tab_menu_usuario (la PK ya cubre id_usuario como columna líder; falta id_menu)
CREATE INDEX IF NOT EXISTS idx_menuusuario_menu ON tab_menu_usuario (id_menu);

-- tab_archivos
CREATE INDEX IF NOT EXISTS idx_archivos_usuario_carga ON tab_archivos (id_usuario_carga);
CREATE INDEX IF NOT EXISTS idx_archivos_tipo          ON tab_archivos (id_tipo_archivo);
CREATE INDEX IF NOT EXISTS idx_archivos_hash          ON tab_archivos (hash_sha256);

-- tab_expediente (tabla pilar: búsqueda por radicado, estado y fechas)
CREATE INDEX IF NOT EXISTS idx_expediente_tipo         ON tab_expediente (id_tipo_expediente);
CREATE INDEX IF NOT EXISTS idx_expediente_despacho     ON tab_expediente (id_despacho);
CREATE INDEX IF NOT EXISTS idx_expediente_estado       ON tab_expediente (id_estado_proceso);
CREATE INDEX IF NOT EXISTS idx_expediente_usuario_crea ON tab_expediente (id_usuario_crea);
CREATE INDEX IF NOT EXISTS idx_expediente_radicado     ON tab_expediente (num_radicado);
CREATE INDEX IF NOT EXISTS idx_expediente_fec_reparto  ON tab_expediente (fec_reparto);

-- tab_sujetos_expediente (la PK líder es id_sujeto; se indexan las demás FK)
CREATE INDEX IF NOT EXISTS idx_sujexp_expediente  ON tab_sujetos_expediente (id_expediente);
CREATE INDEX IF NOT EXISTS idx_sujexp_rol         ON tab_sujetos_expediente (id_rol_sujeto);
CREATE INDEX IF NOT EXISTS idx_sujexp_persona     ON tab_sujetos_expediente (id_persona);
CREATE INDEX IF NOT EXISTS idx_sujexp_abogado     ON tab_sujetos_expediente (id_abogado);
CREATE INDEX IF NOT EXISTS idx_sujexp_auxiliar    ON tab_sujetos_expediente (id_auxiliar);
CREATE INDEX IF NOT EXISTS idx_sujexp_funcionario ON tab_sujetos_expediente (id_funcionario);

-- tab_archivos_base_expediente (la PK líder es id_expediente; falta id_archivo y el FK compuesto)
CREATE INDEX IF NOT EXISTS idx_archbaseexp_archivo ON tab_archivos_base_expediente (id_archivo);
CREATE INDEX IF NOT EXISTS idx_archbaseexp_sujeto  ON tab_archivos_base_expediente (id_sujeto_aporta, id_expediente);

-- tab_dictamen_pericial
CREATE INDEX IF NOT EXISTS idx_dictamen_expediente ON tab_dictamen_pericial (id_expediente);
CREATE INDEX IF NOT EXISTS idx_dictamen_auxiliar   ON tab_dictamen_pericial (id_auxiliar);
CREATE INDEX IF NOT EXISTS idx_dictamen_tipo       ON tab_dictamen_pericial (id_tipo_dictamen);

-- tab_actuacion (tabla más transaccional: filtros por cuaderno, tipo y fecha)
CREATE INDEX IF NOT EXISTS idx_actuacion_cuaderno         ON tab_actuacion (id_cuaderno);
CREATE INDEX IF NOT EXISTS idx_actuacion_archivo          ON tab_actuacion (id_archivo);
CREATE INDEX IF NOT EXISTS idx_actuacion_tipo             ON tab_actuacion (id_tipo_actuacion);
CREATE INDEX IF NOT EXISTS idx_actuacion_usuario_registra ON tab_actuacion (id_usuario_registra);
CREATE INDEX IF NOT EXISTS idx_actuacion_fecha            ON tab_actuacion (fec_actuacion);

-- tab_notificacion
CREATE INDEX IF NOT EXISTS idx_notificacion_expediente   ON tab_notificacion (id_expediente);
CREATE INDEX IF NOT EXISTS idx_notificacion_actuacion    ON tab_notificacion (id_actuacion);
CREATE INDEX IF NOT EXISTS idx_notificacion_persona_dest ON tab_notificacion (id_persona_dest);
CREATE INDEX IF NOT EXISTS idx_notificacion_tipo         ON tab_notificacion (id_tipo_notif);
CREATE INDEX IF NOT EXISTS idx_notificacion_pendientes   ON tab_notificacion (id_expediente) WHERE ind_surtida = FALSE;

-- tab_medida_cautelar
CREATE INDEX IF NOT EXISTS idx_medida_expediente  ON tab_medida_cautelar (id_expediente);
CREATE INDEX IF NOT EXISTS idx_medida_actuacion   ON tab_medida_cautelar (id_actuacion);
CREATE INDEX IF NOT EXISTS idx_medida_responsable ON tab_medida_cautelar (id_responsable);
CREATE INDEX IF NOT EXISTS idx_medida_vigentes    ON tab_medida_cautelar (id_expediente) WHERE ind_vigente = TRUE;

-- tab_termino_procesal (control de vencimientos)
CREATE INDEX IF NOT EXISTS idx_termino_expediente       ON tab_termino_procesal (id_expediente);
CREATE INDEX IF NOT EXISTS idx_termino_actuacion_origen ON tab_termino_procesal (id_actuacion_origen);
CREATE INDEX IF NOT EXISTS idx_termino_vencimiento      ON tab_termino_procesal (fec_vencimiento);
CREATE INDEX IF NOT EXISTS idx_termino_vigentes         ON tab_termino_procesal (fec_vencimiento) WHERE est_termino = 'VIGENTE';


-- ========================================================================================================================

--SECCION DE POBLADO DE DATOS SEMILLA DEL SISTEMA 

INSERT INTO tab_tipo_documento_identidad (id_tipo_doc, cod_tipo_doc, des_tipo_doc) VALUES
(1, 'CC',  'Cédula de ciudadanía'),
(2, 'CE',  'Cédula de extranjería'),
(3, 'TI',  'Tarjeta de identidad'),
(4, 'PA',  'Pasaporte'),
(5, 'RC',  'Registro civil de nacimiento'),
(6, 'NUI', 'Número único de identificación');


INSERT INTO tab_estado_proceso (id_estado_proceso, cod_estado_proceso, des_estado_proceso, ind_terminal) VALUES
(1,  'REPARTO',      'En reparto',                    FALSE),
(2,  'ADMITIDO',     'Admitido',                      FALSE),
(3,  'INADMITIDO',   'Inadmitido',                    FALSE),
(4,  'RECHAZADO',    'Rechazado',                     TRUE),
(5,  'NOTIFICADO',   'Notificado a las partes',       FALSE),
(6,  'ACTIVO',       'En trámite',                    FALSE),
(7,  'PROBATORIO',   'Etapa probatoria',              FALSE),
(8,  'ALEGATOS',     'Alegatos de conclusión',        FALSE),
(9,  'PARA_FALLO',   'Para fallo',                    FALSE),
(10, 'FALLADO',      'Sentenciado',                   FALSE),
(11, 'EJECUTORIADO', 'Sentencia ejecutoriada',        FALSE),
(12, 'APELACION',    'En segunda instancia',          FALSE),
(13, 'ARCHIVADO',    'Archivado',                     TRUE),
(14, 'SUSPENDIDO',   'Suspendido',                    FALSE);


INSERT INTO tab_tipo_actuacion (id_tipo_actuacion, cod_tipo_actuacion, des_tipo_actuacion) VALUES
(1,  'DEMANDA',           'Presentación de demanda'),
(2,  'AUTO_ADMISORIO',    'Auto admisorio de la demanda'),
(3,  'AUTO_INADMISORIO',  'Auto inadmisorio'),
(4,  'NOTIFICACION',      'Actuación de notificación'),
(5,  'CONTESTACION',      'Contestación de la demanda'),
(6,  'EXCEPCIONES',       'Formulación de excepciones'),
(7,  'REFORMA_DEMANDA',   'Reforma de la demanda'),
(8,  'DECRETO_PRUEBAS',   'Auto de decreto de pruebas'),
(9,  'AUDIENCIA',         'Audiencia'),
(10, 'ALEGATOS',          'Alegatos de conclusión'),
(11, 'SENTENCIA',         'Sentencia'),
(12, 'RECURSO_APELACION', 'Recurso de apelación'),
(13, 'MEDIDA_CAUTELAR',   'Decreto de medida cautelar'),
(14, 'OFICIO',            'Oficio / comunicación'),
(15, 'CONSTANCIA',        'Constancia de secretaría'),
(16, 'ARCHIVADO',         'Auto de archivo'),
(17, 'OTRO',              'Otro tipo de actuación');

INSERT INTO tab_tipo_medio_prueba (id_tipo_medio_prueba, cod_tipo_medio_prueba, des_tipo_medio_prueba) VALUES
(1, 'DOCUMENTAL',     'Prueba documental'),
(2, 'TESTIMONIAL',    'Testimonio'),
(3, 'PERICIAL',       'Dictamen pericial'),
(4, 'INTERROGATORIO', 'Interrogatorio de parte'),
(5, 'INSPECCION',     'Inspección judicial'),
(6, 'INDICIOS',       'Indicios');

INSERT INTO tab_tipo_notificacion (id_tipo_notificacion, cod_tipo_notificacion, des_tipo_notificacion) VALUES
(1, 'PERSONAL',         'Notificación personal'),
(2, 'AVISO',            'Por aviso / mensaje de datos'),
(3, 'ELECTRONICA',      'Electrónica (email registrado)'),
(4, 'EDICTO',           'Por edicto (surtida con curador)'),
(5, 'ESTRADO',          'En estrados (audiencia)'),
(6, 'CURADOR_AD_LITEM', 'A través de curador ad litem');

INSERT INTO tab_tipo_auxiliar_justicia (id_tipo_auxiliar, cod_tipo_auxiliar, des_tipo_auxiliar) VALUES
(1, 'PERITO',          'Perito técnico'),
(2, 'CURADOR_AD_LITEM','Curador ad lítem'),
(3, 'SECUESTRE',       'Secuestre'),
(4, 'PARTIDOR',        'Partidor'),
(5, 'INTERPRETE',      'Intérprete / traductor'),
(6, 'AUX_CONTABLE',    'Auxiliar contable');

INSERT INTO tab_tipo_cargo_funcionario (id_tipo_cargo, cod_tipo_cargo, des_tipo_cargo) VALUES
(1, 'JUEZ',          'Juez'),
(2, 'MAGISTRADO',    'Magistrado'),
(3, 'SECRETARIO',    'Secretario de despacho'),
(4, 'SUSTANCIADOR',  'Sustanciador'),
(5, 'OFICIAL_MAYOR', 'Oficial mayor'),
(6, 'NOTIFICADOR',   'Notificador');

INSERT INTO tab_tipo_dictamen (id_tipo_dictamen, cod_tipo_dictamen, des_tipo_dictamen) VALUES
(1, 'MEDICO_LEGAL', 'Dictamen médico legal'),
(2, 'PSICOLOGICO',  'Dictamen psicológico'),
(3, 'CONTABLE',     'Dictamen contable'),
(4, 'TECNICO',      'Dictamen técnico'),
(5, 'GRAFOLOGICO',  'Dictamen grafológico'),
(6, 'AVALUO',       'Avalúo / peritaje de bienes');

-- ========================================================================================================================

-- ========================================================================================================================
-- EJEMPLO DE USO DE LA JERARQUÍA EXPEDIENTE -> ETAPA -> CUADERNO -> ACTUACIÓN -> DOCUMENTO
-- (asume que ya existe un tab_expediente con id_expediente = 1, ver INSERTs de tu aplicación)
-- ========================================================================================================================

-- INSERT INTO tab_etapa_procesal (id_etapa, id_expediente, nom_etapa, orden)
-- VALUES (1, 1, 'Primera Instancia', 1);

-- INSERT INTO tab_cuaderno (id_cuaderno, id_etapa, cod_cuaderno, nom_cuaderno) VALUES
-- (1, 1, 'C01', 'Principal'),
-- (2, 1, 'C02', 'Pruebas');

-- INSERT INTO tab_actuacion
--     (id_actuacion, id_expediente, id_cuaderno, id_tipo_actuacion, fec_actuacion, des_actuacion, id_usuario_registra)
-- VALUES
-- (1, 1, 1, 1, '2026-01-10', 'Presentación de la demanda inicial', '1234567890'),
-- (2, 1, 1, 2, '2026-01-15', 'Auto que admite la demanda',         '1234567890');
