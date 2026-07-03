--================================================================================
--BASE DE DATOS GOLIAT V-6
--Creada por: Daniel Sanchez
--Base de datos para el proyecto Goliat, Sistema de gestion de procesos legales
--================================================================================

--********************************************************************************************************************
--* SECCION 1: DROP TABLES 
--********************************************************************************************************************
DROP TABLE IF EXISTS tab_notificacion;
DROP TABLE IF EXISTS tab_termino_procesal;
DROP TABLE IF EXISTS tab_archivos_anexos;
DROP TABLE IF EXISTS tab_archivos_expediente;
DROP TABLE IF EXISTS tab_archivos;
DROP TABLE IF EXISTS tab_cuaderno;
DROP TABLE IF EXISTS tab_etapa_procesal;
DROP TABLE IF EXISTS tab_sujetos_expediente;
DROP TABLE IF EXISTS tab_abogado_expediente;
DROP TABLE IF EXISTS tab_expediente;
DROP TABLE IF EXISTS tab_abogado;
DROP TABLE IF EXISTS tab_entidad;
DROP TABLE IF EXISTS tab_despacho;
DROP TABLE IF EXISTS tab_menu_usuario;
DROP TABLE IF EXISTS tab_menu;
DROP TABLE IF EXISTS tab_sesion;
DROP TABLE IF EXISTS tab_usuario;
DROP TABLE IF EXISTS tab_persona;
DROP TABLE IF EXISTS tab_ciudad;
DROP TABLE IF EXISTS tab_deptos;
DROP TABLE IF EXISTS tab_tipo_notificacion;
DROP TABLE IF EXISTS tab_tipo_archivo;
DROP TABLE IF EXISTS tab_rol_sujeto;
DROP TABLE IF EXISTS tab_subserie_expediente;
DROP TABLE IF EXISTS tab_serie_expediente;
DROP TABLE IF EXISTS tab_estado_proceso;
DROP TABLE IF EXISTS tab_tipo_documento_identidad;
DROP TABLE IF EXISTS tab_parametros; 

--=================================================================================



--CREACION DE TABLAS

--********************************************************************************************************************
--* SECCION 2: TABLAS MAESTRAS DEL SISTEMA*
--********************************************************************************************************************
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

--TABLA DE ESTADOS DE UN PROCESO
CREATE TABLE IF NOT EXISTS tab_estado_proceso
(
    id_estado_proceso   DECIMAL(2,0)    NOT NULL,
    nom_estado_proceso  VARCHAR(30)     NOT NULL    CHECK(LENGTH(TRIM(nom_estado_proceso)) BETWEEN 3 AND 30),
    des_estado_proceso  VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(des_estado_proceso)) >= 3),
    ind_terminal        BOOLEAN         NOT NULL    DEFAULT FALSE,
    PRIMARY KEY (id_estado_proceso)
);

--TABLA DE SERIES O TIPOS DE PROCESOS - EXPEDIENTES
CREATE TABLE IF NOT EXISTS tab_serie_expediente
(
    id_serie                    INT            NOT NULL,
	etiqueta_serie              VARCHAR(6)     NOT NULL,
    nom_serie                   VARCHAR(40)    NOT NULL,
    campos_adicionales          JSONB          NOT NULL,
    PRIMARY KEY (id_serie)
);

--TABLA DE SUBSERIES O SUB-TIPOS DE EXPEDIENTES
CREATE TABLE IF NOT EXISTS tab_subserie_expediente
(
    id_subserie                 INT             NOT NULL,
    id_serie                    INT             NOT NULL,
    nom_subserie                VARCHAR(40)     NOT NULL,
    campos_adicionales          JSONB           NOT NULL,
    PRIMARY KEY (id_subserie),
    FOREIGN KEY (id_serie) REFERENCES tab_serie_expediente(id_serie)
);

CREATE TABLE IF NOT EXISTS tab_rol_sujeto
(
    id_rol_sujeto            VARCHAR(10)     NOT NULL,
    nom_rol_sujeto           VARCHAR(50)     NOT NULL,
    desc_rol_sujeto          VARCHAR(150)    NOT NULL,
    campos_esquema_json      JSONB           NOT NULL,
    PRIMARY KEY (id_rol_sujeto)
);

--TABLA DE TIPOS DE ARCHIVOS  
CREATE TABLE IF NOT EXISTS tab_tipo_archivo
(
    id_tipo_archivo         DECIMAL(2,0)    NOT NULL,
    nom_tipo_archivo        VARCHAR         NOT NULL,
    desc_tipo_archivo       VARCHAR         NOT NULL,
    PRIMARY KEY (id_tipo_archivo)
);



--TABLA DE LOS TIPOS DE NOTIFICACIONES 
CREATE TABLE IF NOT EXISTS tab_tipo_notificacion
(
    id_tipo_notificacion    DECIMAL(1,0)    NOT NULL,
    nom_tipo_notificacion   VARCHAR(40)     NOT NULL    CHECK(LENGTH(TRIM(nom_tipo_notificacion)) BETWEEN 3 AND 40),
    des_tipo_notificacion   VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(des_tipo_notificacion)) >= 3),
    PRIMARY KEY (id_tipo_notificacion)
);

--********************************************************************************************************************
--* SECCION 3: TABLAS DE UBICACION GEOGRAFICA
--********************************************************************************************************************

--TABLA DE DEPARTAMENTOS 
CREATE TABLE IF NOT EXISTS tab_deptos
(
    id_depto            VARCHAR(2)      NOT NULL    CHECK(LENGTH(TRIM(id_depto)) >= 2),
    nom_depto           VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(nom_depto)) >= 2),
    nom_pais            VARCHAR(60)     NOT NULL    DEFAULT 'Colombia',
    PRIMARY KEY (id_depto)
);

--TABLA DE CIUDADES
CREATE TABLE IF NOT EXISTS tab_ciudad
(
    id_ciudad           VARCHAR(7)      NOT NULL,
    cod_dane            VARCHAR(10)                 CHECK(LENGTH(TRIM(cod_dane)) BETWEEN 4 AND 10),
    nom_ciudad          VARCHAR(120)    NOT NULL    CHECK(LENGTH(TRIM(nom_ciudad)) BETWEEN 2 AND 120),
    id_depto            VARCHAR(2)      NOT NULL,
    PRIMARY KEY (id_ciudad),
    FOREIGN KEY (id_depto) REFERENCES tab_deptos(id_depto)
);

--********************************************************************************************************************
--* SECCION 4: TABLAS DE PERSONAS - USUARIOS DEL SISTEMA
--********************************************************************************************************************

--TABLA PADRE PERSONAS EN GENERAL
CREATE TABLE IF NOT EXISTS tab_persona
(
    id_persona          VARCHAR(10)     NOT NULL    CHECK(id_persona ~ '^[0-9]{6,10}$'),
    id_tipo_doc         DECIMAL(1,0)    NOT NULL,
    nom_y_ape_completos VARCHAR(250)    NOT NULL    CHECK(LENGTH(TRIM(nom_y_ape_completos)) BETWEEN 2 AND 250),
    fec_nacimiento      DATE,
    tip_genero          CHAR(1)                     CHECK(tip_genero IN ('M','F','X')),
    email_persona       VARCHAR(120),
    tel_persona         VARCHAR(20),
    dir_persona         VARCHAR(250),
    id_ciudad           VARCHAR(7),
    
    fec_creacion        TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    PRIMARY KEY (id_persona),
    FOREIGN KEY (id_tipo_doc) REFERENCES tab_tipo_documento_identidad(id_tipo_doc),
    FOREIGN KEY (id_ciudad)   REFERENCES tab_ciudad(id_ciudad)
);

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
--********************************************************************************************************************
--* SECCION 5: TABLAS DE DESPACHOS Y ENTIDADES JURIDICAS
--********************************************************************************************************************

--TABLAS DE DESPACHOS - JUZGADOS, TRIBUNALES, NOTARIAS, FISCALES, POLICIALES, ETC
CREATE TABLE IF NOT EXISTS tab_despacho
(
    id_despacho         INT             NOT NULL    CHECK(id_despacho > 0),
    nom_despacho        VARCHAR(150)    NOT NULL    CHECK(LENGTH(TRIM(nom_despacho)) BETWEEN 5 AND 150),
    dir_despacho        VARCHAR(250),
    tel_despacho        VARCHAR(20),
    email_despacho      VARCHAR(120),
    id_ciudad           VARCHAR(7),
    PRIMARY KEY (id_despacho),
    FOREIGN KEY (id_ciudad) REFERENCES tab_ciudad(id_ciudad)
);
--ENTIDADES QUE PUEDEN INTERVENIR EN UN PROCESO LEGAL - LABORATORIOS, UNIVERSIDADES, ENTIDADES PUBLICAS Y PRIVADAS, ONG, ETC
CREATE TABLE IF NOT EXISTS tab_entidad
(
    id_entidad          INT             NOT NULL    CHECK(id_entidad > 0),
    nom_entidad         VARCHAR(150)    NOT NULL    CHECK(LENGTH(TRIM(nom_entidad)) BETWEEN 3 AND 150),
    nit_entidad         VARCHAR(20),
    tip_entidad         VARCHAR(40)                 CHECK(tip_entidad IN ('LABORATORIO','UNIVERSIDAD','ENTIDAD_PUBLICA','ENTIDAD_PRIVADA','ONG','OTRO')),
    dir_entidad         VARCHAR(250),
    tel_entidad         VARCHAR(20),
    email_entidad       VARCHAR(120),
    id_ciudad           VARCHAR(7),
    PRIMARY KEY (id_entidad),
    FOREIGN KEY (id_ciudad) REFERENCES tab_ciudad(id_ciudad)
);

--********************************************************************************************************************
--* SECCION 5-1: TABLAS de ABOGADOS 
--********************************************************************************************************************
CREATE TABLE IF NOT EXISTS tab_abogado
(
    id_abogado              VARCHAR(10)     NOT NULL    CHECK(id_abogado ~ '^[0-9]{6,10}$'),
    num_tarjeta_profesional VARCHAR(20)     NOT NULL,
    especialidad            VARCHAR(20),
    ind_estado          BOOLEAN             NOT NULL    DEFAULT TRUE,
    PRIMARY KEY (id_abogado),
    FOREIGN KEY (id_abogado) REFERENCES tab_persona(id_persona)
);

--********************************************************************************************************************
--* SECCION 6: TABLAS DE PROCESOS LEGALES - EXPEDIENTES 
--********************************************************************************************************************

--TABLA EXPEDIENTES, TABLA PILAR DEL SISTEMA 
CREATE TABLE IF NOT EXISTS tab_expediente
(
    id_expediente           INT             NOT NULL    GENERATED ALWAYS AS IDENTITY,
    identificador_interno   VARCHAR(40)   NOT NULL    UNIQUE,
    num_radicado            VARCHAR(40)     NOT NULL    CHECK(LENGTH(TRIM(num_radicado)) BETWEEN 5 AND 40),
    id_subserie             INT             NOT NULL,
    id_despacho             INT,
    id_estado_proceso       DECIMAL(2,0)    NOT NULL,
    obs_expediente          VARCHAR(250),


    fec_reparto         DATE            NOT NULL,
    id_usuario_crea     VARCHAR(10)     NOT NULL    CHECK(id_usuario_crea ~ '^[0-9]{6,10}$'),
    fec_creacion        TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_actualizacion   TIMESTAMPTZ ,
    PRIMARY KEY (id_expediente),
    FOREIGN KEY (id_subserie)    		REFERENCES tab_subserie_expediente(id_subserie),
    FOREIGN KEY (id_estado_proceso)     REFERENCES tab_estado_proceso(id_estado_proceso),
    FOREIGN KEY (id_despacho)           REFERENCES tab_despacho(id_despacho),
    FOREIGN KEY (id_usuario_crea)       REFERENCES tab_usuario(id_usuario)
);


--********************************************************************************************************************
--* SECCION 6-1: TABLAS DE SUJETOS PROCESALES - PERSONAS Y ENTIDADES QUE INTERVIENEN EN UN PROCESO LEGAL
--********************************************************************************************************************

--TABLA PUENTE ENTRE ABOGADOS Y EXPEDIENTES
CREATE TABLE IF NOT EXISTS tab_abogado_expediente
(
    id_abogado          VARCHAR(10)     NOT NULL    CHECK(id_abogado ~ '^[0-9]{6,10}$'),
    id_expediente       INT             NOT NULL,

    fec_vinculacion      TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_desvinculacion   TIMESTAMPTZ,
    PRIMARY KEY (id_abogado, id_expediente),
    FOREIGN KEY (id_abogado)            REFERENCES tab_abogado(id_abogado),
    FOREIGN KEY (id_expediente)         REFERENCES tab_expediente(id_expediente)
);

--TABLA DE SUJETOS - EXPEDIENTES 
CREATE TABLE IF NOT EXISTS tab_sujetos_expediente
(
    id_sujeto                INT             NOT NULL    GENERATED ALWAYS AS IDENTITY,
    id_expediente            INT             NOT NULL,
    id_persona               VARCHAR(10)     NOT NULL    CHECK(id_persona ~ '^[0-9]{6,10}$'),
    id_rol_sujeto            VARCHAR(10)     NOT NULL,
    datos_adicionales        JSONB,

    fec_vinculacion          TIMESTAMPTZ     NOT NULL    DEFAULT NOW(),
    fec_desvinculacion       TIMESTAMPTZ,
    ind_activo               BOOLEAN         NOT NULL    DEFAULT TRUE,
    PRIMARY KEY (id_sujeto),
    FOREIGN KEY (id_expediente)             REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_persona)                REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_rol_sujeto)             REFERENCES tab_rol_sujeto(id_rol_sujeto)
);


--********************************************************************************************************************
--* SECCION 6-2: TABLAS DE ORGANIZACION INTERNA DE UN EXPEDIENTE 
--********************************************************************************************************************

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

--********************************************************************************************************************
--* SECCION 6-3: TABLAS DE DOCUMENTOS, ACTUACIONES Y NOTIFICACIONES DE UN EXPEDIENTE
--********************************************************************************************************************

--TABLA DE DOCUMENTACION / Y ARCHIVOS DIGITALES 
CREATE TABLE IF NOT EXISTS tab_archivos
(
    id_archivo              BIGINT             NOT NULL    GENERATED ALWAYS AS IDENTITY,
    nom_archivo             VARCHAR(50)        NOT NULL    CHECK(LENGTH(TRIM(nom_archivo)) BETWEEN 3 AND 50),
    id_tipo_archivo         DECIMAL(2,0)      NOT NULL,
    formato_archivo         VARCHAR           NOT NULL,
    tam_bytes               BIGINT             NOT NULL    CHECK(tam_bytes > 0),
    paginas                 INT                NOT NULL    CHECK(paginas > 0),
    url_documento           TEXT               NOT NULL,

    id_usuario_carga        VARCHAR(10)                 CHECK(id_usuario_carga ~ '^[0-9]{6,10}$'),
    fec_carga               TIMESTAMPTZ        NOT NULL    DEFAULT NOW(),
    hash_sha256             CHAR(64)           NOT NULL,
    ind_publico             BOOLEAN            NOT NULL    DEFAULT FALSE,
    PRIMARY KEY (id_archivo),
    FOREIGN KEY (id_usuario_carga)  REFERENCES tab_usuario(id_usuario),
    FOREIGN KEY (id_tipo_archivo)   REFERENCES tab_tipo_archivo(id_tipo_archivo)
);

--TABLA PUENTE ENTRE ARCHIVOS Y EXPEDIENTES
CREATE TABLE IF NOT EXISTS tab_archivos_expediente
(
    id_archivo              BIGINT             NOT NULL,
    id_expediente           INT                NOT NULL,
    id_cuaderno             INT                NOT NULL,
    PRIMARY KEY (id_archivo, id_expediente),
    FOREIGN KEY (id_archivo)     REFERENCES tab_archivos(id_archivo),
    FOREIGN KEY (id_expediente)  REFERENCES tab_expediente(id_expediente),
    FOREIGN KEY (id_cuaderno)    REFERENCES tab_cuaderno(id_cuaderno)
);



--TABLA DE ANEXOS DE DOCUMENTOS - RELACIONA UN DOCUMENTO PRINCIPAL CON SUS ANEXOS
CREATE TABLE IF NOT EXISTS tab_archivos_anexos
(
    id_archivo_principal    BIGINT             NOT NULL,
    id_archivo_anexo        BIGINT             NOT NULL,
    PRIMARY KEY (id_archivo_principal, id_archivo_anexo),
    FOREIGN KEY (id_archivo_principal) REFERENCES tab_archivos(id_archivo),
    FOREIGN KEY (id_archivo_anexo)     REFERENCES tab_archivos(id_archivo)
);

--********************************************************************************************************************
--* SECCION 7: TABLAS DE TERMINOS PROCESALES - NOTIFICACIONES
--********************************************************************************************************************

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
    obs_termino         TEXT,
    PRIMARY KEY (id_termino),
    FOREIGN KEY (id_expediente)       REFERENCES tab_expediente(id_expediente)
);


--TABLA DE NOTIFICACIONES 
CREATE TABLE IF NOT EXISTS tab_notificacion
(
    id_notificacion     INT             NOT NULL    CHECK(id_notificacion > 0),
    id_expediente       INT             NOT NULL,
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
    FOREIGN KEY (id_persona_dest) REFERENCES tab_persona(id_persona),
    FOREIGN KEY (id_tipo_notif)  REFERENCES tab_tipo_notificacion(id_tipo_notificacion)
);



--=================================================================================
