--select fun_insert_abogados('1054708619','247274297498274','Civiles familiares');
--select * from tab_abogado;
CREATE OR REPLACE FUNCTION fun_insert_abogados(xid_abogado tab_abogado.id_abogado%TYPE,
												xnum_tarjeta_profesional tab_abogado.num_tarjeta_profesional%TYPE,
												xespecialidad tab_abogado.especialidad%TYPE) RETURNS BOOLEAN AS
$$
	DECLARE 
	xvid_persona tab_persona.id_persona%TYPE;
	xvid_abogado tab_abogado.id_abogado%TYPE;
	BEGIN 
	
		SELECT a.id_persona INTO xvid_persona FROM tab_persona a WHERE id_persona = xid_abogado;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF; 
		
		SELECT a.id_abogado INTO xvid_abogado FROM tab_abogado a WHERE id_abogado = xid_abogado;
		IF FOUND THEN 
			RETURN FALSE;
		END IF;

		INSERT INTO tab_abogado VALUES(xid_abogado,xnum_tarjeta_profesional,xespecialidad);
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


