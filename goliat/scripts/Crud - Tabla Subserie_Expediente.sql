

--select * from tab_subserie_expediente;
--select fun_insert_subserie(01,100,'subserie 1','{"nivel_prioridad": "Alta", "requiere_notificacion": true, "tiempo_retencion_anios": 10}');

CREATE OR REPLACE FUNCTION fun_insert_subserie(xid_subserie tab_subserie_expediente.id_serie%TYPE,
											xid_serie tab_serie_expediente.id_serie%TYPE,
                                            xnom_subserie tab_subserie_expediente.nom_subserie%TYPE,
                                            xcampos_adicionales tab_subserie_expediente.campos_adicionales%TYPE)RETURNS BOOLEAN AS
$$
DECLARE
    xvid_serie tab_serie_expediente.id_serie%TYPE;
	xvid_subserie tab_subserie_expediente.id_subserie%TYPE;
    BEGIN
		SELECT id_subserie a INTO xvid_subserie FROM tab_subserie_expediente a WHERE id_subserie = xid_subserie;
        IF FOUND THEN 
            RETURN FALSE;
        END IF;
		
        SELECT id_serie a INTO xvid_serie FROM tab_serie_expediente a WHERE id_serie = xid_serie;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;

        INSERT INTO tab_subserie_expediente VALUES (xid_subserie,xid_serie,xnom_subserie,xcampos_adicionales);
        IF NOT FOUND THEN
            RETURN FALSE; 
        END IF;

        RETURN TRUE;
    END;
$$
LANGUAGE plpgsql;

--select * from tab_subserie_expediente;
--select fun_update_subserie(1,'cambio','{"nivel_prioridad": "alta", "requiere_notificacion": false, "tiempo_retencion_anios": 30}');

CREATE OR REPLACE FUNCTION fun_update_subserie(xid_subserie tab_subserie_expediente.id_serie%TYPE,
                                            xnom_subserie tab_subserie_expediente.nom_subserie%TYPE,
                                            xcampos_adicionales tab_subserie_expediente.campos_adicionales%TYPE)RETURNS BOOLEAN AS
$$
DECLARE
	xvid_subserie tab_subserie_expediente.id_serie%TYPE;
	BEGIN
	
		SELECT id_subserie a INTO xvid_subserie FROM tab_subserie_expediente a WHERE id_subserie = xid_subserie;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;
		
		UPDATE tab_subserie_expediente SET 	nom_subserie = xnom_subserie,
											campos_adicionales = xcampos_adicionales
											WHERE id_subserie = xid_subserie;
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


--SELECT fun_delete_subserie(1);
--select * from tab_subserie_expediente;
CREATE OR REPLACE FUNCTION fun_delete_subserie(xid_subserie tab_subserie_expediente.id_subserie%TYPE) RETURNS BOOLEAN AS
$$
	DECLARE
	xvid_subserie tab_subserie_expediente.id_subserie%TYPE;
	BEGIN
		SELECT id_subserie a INTO xvid_subserie FROM tab_subserie_expediente a WHERE id_subserie = xid_subserie;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;

		
		
		DELETE FROM tab_subserie_expediente WHERE id_subserie = xid_subserie;
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;




