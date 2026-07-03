CREATE OR REPLACE FUNCTION fun_insert_persona(xid_persona tab_persona.id_persona%TYPE,
												xid_tipo_doc tab_tipo_documento_identidad.id_tipo_doc%TYPE,
												xnom_y_ape_completos tab_persona.nom_y_ape_completos%TYPE,
												xfec_nacimiento tab_persona.fec_nacimiento%TYPE,
												xtip_genero tab_persona.tip_genero%TYPE,
												xemail_persona tab_persona.email_persona%TYPE,
												xtel_persona tab_persona.tel_persona%TYPE,
												xdir_persona tab_persona.dir_persona%TYPE,
												xid_ciudad tab_ciudad.id_ciudad%TYPE)
RETURNS BOOLEAN AS
	
$$
	DECLARE	xpersona 		tab_persona.id_persona%TYPE;
	BEGIN 
	
		SELECT a.id_persona INTO xpersona FROM tab_persona a WHERE id_persona = xid_persona;
		IF FOUND THEN 
			RETURN FALSE;
		END IF;
		
		INSERT INTO tab_persona VALUES 
		(xid_persona,xid_tipo_doc,xnom_y_ape_completos,xfec_nacimiento,xtip_genero,xemail_persona,xtel_persona,xdir_persona,xid_ciudad,NOW());
		
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;




--SELECT fun_insert_persona('1054708619',1,'Daniel Alonso Sanchez Galindo','1990-05-15','M','danielsanchezgalindo007@gmail.com','3124786484','Carrera 19 No.200A 15','68001');

CREATE OR REPLACE FUNCTION fun_update_persona(xid_n_persona tab_persona.id_persona%TYPE,
												xid_tipo_doc tab_tipo_documento_identidad.id_tipo_doc%TYPE,
												xnom_y_ape_completos tab_persona.nom_y_ape_completos%TYPE,
												xemail_persona tab_persona.email_persona%TYPE,
												xtel_persona tab_persona.tel_persona%TYPE,
												xdir_persona tab_persona.dir_persona%TYPE,
												xid_ciudad tab_ciudad.id_ciudad%TYPE)
RETURNS BOOLEAN AS
$$
	DECLARE xreg_persona RECORD;
	BEGIN 	
		UPDATE tab_persona SET  id_tipo_doc =		xid_tipo_doc,
								nom_y_ape_completos = xnom_y_ape_completos,
								email_persona = 	xemail_persona,
								tel_persona = 		xtel_persona,
								dir_persona = 		xdir_persona,
								id_ciudad  = 		xid_ciudad
						WHERE id_persona = xid_n_persona;
		IF NOT FOUND THEN 
		RETURN FALSE;
		END IF;
		
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;



--SELECT fun_update_persona ('1054708619',2,'Alonso Sanchez','adso@gmail.com','3214214142','jdajdjsadsi','68001');

CREATE OR REPLACE FUNCTION fun_delete_persona(xid_n_persona tab_persona.id_persona%TYPE) RETURNS BOOLEAN AS
$$
DECLARE 
	xvid_persona tab_persona.id_persona%TYPE;
	xvid_usuario tab_usuario.id_usuario%TYPE;
	xvid_abogado tab_abogado.id_abogado%TYPE;
	BEGIN 
	
		SELECT id_persona a INTO xvid_persona FROM tab_persona WHERE id_persona = xid_n_persona;
		IF NOT FOUND THEN
			RETURN FALSE;
		END IF;
		
		SELECT id_abogado a INTO xvid_abogado FROM tab_abogado WHERE id_abogado = xid_n_persona;
		IF FOUND THEN 
			raise notice 'no puedes eliminar esta persona';
			RETURN FALSE;
		END IF;
		
		SELECT id_usuario a INTO xvid_usuario FROM tab_usuario WHERE id_usuario = xid_n_persona;
		IF FOUND THEN 
			raise notice 'no puedes eliminar esta persona';
			RETURN FALSE;
		END IF;
		
		DELETE FROM tab_persona WHERE id_persona = xid_n_persona;
		
		IF NOT FOUND THEN 
		RETURN FALSE;
		END IF;

		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;
--SELECT fun_delete_persona('1054708619');
--SELECT * from tab_persona;