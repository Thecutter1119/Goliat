

--select * from tab_serie_expediente;
--select fun_insert_serie(100,'CIV','EXPEDEINTES CIVILES','{"nivel_prioridad": "Alta", "requiere_notificacion": true, "tiempo_retencion_anios": 10}');

CREATE OR REPLACE FUNCTION fun_insert_serie(xid_serie tab_serie_expediente.id_serie%TYPE,
                                            xetiqueta_serie tab_serie_expediente.etiqueta_serie%TYPE,
                                            xnom_serie tab_serie_expediente.nom_serie%TYPE,
                                            xcampos_adicionales tab_serie_expediente.campos_adicionales%TYPE)RETURNS BOOLEAN AS
$$
DECLARE
    xvid_serie tab_serie_expediente.id_serie%TYPE;
    BEGIN

        SELECT id_serie a INTO xvid_serie FROM tab_serie_expediente a WHERE id_serie = xid_serie;
        IF FOUND THEN 
            RETURN FALSE;
        END IF;

        INSERT INTO tab_serie_expediente VALUES (xid_serie,xetiqueta_serie,xnom_serie,xcampos_adicionales);
        IF NOT FOUND THEN
            RETURN FALSE; 
        END IF;

        RETURN TRUE;
    END;
$$
LANGUAGE plpgsql;

--select * from tab_serie_expediente;
--select fun_update_serie(100,'CIVi','cambio','{"nivel_prioridad": "media", "requiere_notificacion": false, "tiempo_retencion_anios": 5}');
CREATE OR REPLACE FUNCTION fun_update_serie(xid_serie tab_serie_expediente.id_serie%TYPE,
                                            xetiqueta_serie tab_serie_expediente.etiqueta_serie%TYPE,
                                            xnom_serie tab_serie_expediente.nom_serie%TYPE,
                                            xcampos_adicionales tab_serie_expediente.campos_adicionales%TYPE)RETURNS BOOLEAN AS
$$
DECLARE
	xvid_serie tab_serie_expediente.id_serie%TYPE;
	BEGIN
	
		SELECT id_serie a INTO xvid_serie FROM tab_serie_expediente a WHERE id_serie = xid_serie;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;
		
		UPDATE tab_serie_expediente SET etiqueta_serie = xetiqueta_serie,
										nom_serie = xnom_serie,
										campos_adicionales = xcampos_adicionales
										WHERE id_serie = xid_serie;
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


--SELECT fun_delete_serie(100);
--select * from tab_serie_expediente;
CREATE OR REPLACE FUNCTION fun_delete_serie(xid_serie tab_serie_expediente.id_serie%TYPE) RETURNS BOOLEAN AS
$$
	DECLARE
	xvid_serie tab_serie_expediente.id_serie%TYPE;
	xserie tab_subserie_expediente.id_serie%TYPE;
	BEGIN
		SELECT id_serie a INTO xvid_serie FROM tab_serie_expediente a WHERE id_serie = xid_serie;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;

		
		SELECT id_serie a INTO xserie FROM tab_subserie_expediente a WHERE id_serie = xid_serie;
        IF FOUND THEN 
			raise notice 'NO PUEDES ELIMINAR LA SERIE YA QUE TIENE SUBSERIES LIGADAS';
            RETURN FALSE;
        END IF;
		
		DELETE FROM tab_serie_expediente WHERE id_serie = xid_serie;
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;




