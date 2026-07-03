select * from tab_expediente;
select fun_insert_expediente('32434324327676575',100,1,244424234,'OBSERVACION DE EJEMPLO');
CREATE OR REPLACE FUNCTION fun_insert_expediente(xnum_radicado tab_expediente.num_radicado%TYPE,
                                                xid_serie   tab_serie_expediente.id_serie%TYPE,
                                                xid_subserie tab_subserie_expediente.id_subserie%TYPE,
                                                xid_despacho tab_despacho.id_despacho%TYPE,
                                                xobs_expediente tab_expediente.obs_expediente%TYPE)RETURNS  BOOLEAN AS
                                                

$$

DECLARE
--parametros
    xreg_parametros                 RECORD;
    xvvalor_actual_consecutivo      INT;
--serie
    xreg_serie_expediente           RECORD;
    xvetiqueta_serie                tab_serie_expediente.etiqueta_serie%TYPE;
--subserie
    xvid_subserie                      tab_subserie_expediente.id_subserie%TYPE;


    xvid_despacho                   tab_despacho.id_despacho%TYPE;

    xv_anio                          INT;
    xvindentificador_interno_final   tab_expediente.identificador_interno%TYPE;

BEGIN
--CARGA DE PARAMETROS DEL SISTEMA
    SELECT a.valor_actual_consecutivo INTO xreg_parametros FROM tab_parametros a;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
--CARGA DE SERIE DE EXPEDIENTE 
    SELECT a.id_serie, a.etiqueta_serie INTO xreg_serie_expediente FROM tab_serie_expediente a WHERE id_serie = xid_serie;
    IF NOT FOUND THEN 
         RAISE EXCEPTION 'la serie no no existe';
    RETURN FALSE;
    END IF;
--CARGA DE LA SUBSERIE DE EXPEDIENTE
    SELECT a.id_subserie INTO xvid_subserie FROM tab_subserie_expediente a WHERE id_subserie = xid_subserie;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'la subserie no no existe';
        RETURN FALSE;
    END IF;

--============================================================================================================
--CREACION DEL IDENTIFICADOR INTERNO

    xvetiqueta_serie = xreg_serie_expediente.etiqueta_serie;
    xvvalor_actual_consecutivo = xreg_parametros.valor_actual_consecutivo;
    xv_anio := EXTRACT(YEAR FROM CURRENT_DATE);
    xvindentificador_interno_final := xvetiqueta_serie || '-' || xv_anio || '-' || xvvalor_actual_consecutivo;
--============================================================================================================
--CARGA DE DESPACHO
    SELECT a.id_despacho, a.nom_despacho INTO xvid_despacho FROM tab_despacho a WHERE a.id_despacho = xid_despacho;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El despacho no existe';
        RETURN FALSE;
    END IF;


--ACTUALIZACION DEL CONSECUTIVO EN LA TABLA DE PARAMETROS
     UPDATE tab_parametros SET valor_actual_consecutivo = valor_actual_consecutivo + 1 WHERE id_empresa = 1;
--INSERT EN LA TABLA DE EXPEDIENTES
    INSERT INTO tab_expediente (identificador_interno, num_radicado, id_subserie, id_despacho,id_estado_proceso, obs_expediente,fec_reparto,id_usuario_crea,fec_creacion,fec_actualizacion)
    VALUES (xvindentificador_interno_final, xnum_radicado, xid_subserie, xid_despacho,1, xobs_expediente,NOW(),'1054708619',NOW(),null);
    RETURN TRUE;
END;
$$
LANGUAGE plpgsql;


