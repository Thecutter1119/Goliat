--SELECT fun_insert_usuarios('1054708619','admin123',TRUE,TRUE);
--select * from tab_usuario;
CREATE OR REPLACE FUNCTION fun_insert_usuarios(xid_usuario tab_usuario.id_usuario%TYPE,
                                                xcontrasena tab_usuario.contrasena%TYPE,
                                                xind_admin tab_usuario.ind_admin%TYPE,
                                                xind_estado tab_usuario.ind_estado%TYPE)RETURNS BOOLEAN AS
$$
DECLARE 
xvid_usuario tab_usuario.id_usuario%TYPE;
xvid_persona tab_persona.id_persona%TYPE;

    BEGIN 

        SELECT id_usuario a INTO xvid_usuario FROM tab_usuario a WHERE id_usuario = xid_usuario;
        IF FOUND THEN 
			RAISE NOTICE 'EL USUARIO YA EXISTE';
            RETURN FALSE;
        END IF;

        SELECT id_persona a INTO xvid_persona FROM tab_persona WHERE id_persona = xid_usuario;
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;
        
        INSERT INTO tab_usuario VALUES (xid_usuario,xcontrasena,xind_admin,xind_estado,NOW(),NOW(),NOW());
        IF NOT FOUND THEN 
            RETURN FALSE;
        END IF;
        RETURN TRUE;
    END;
$$
LANGUAGE plpgsql; 


--SELECT fun_update_usuario('1054709503','abogado1234',FALSE,TRUE)
CREATE OR REPLACE FUNCTION fun_update_usuario(xid_usuario tab_usuario.id_usuario%TYPE,
                                                xcontrasena tab_usuario.contrasena%TYPE,
                                                xind_admin tab_usuario.ind_admin%TYPE,
                                                xind_estado tab_usuario.ind_estado%TYPE)RETURNS BOOLEAN AS
$$
DECLARE 
	xvid_usuario tab_usuario.id_usuario%TYPE;
	BEGIN
		SELECT id_usuario a INTO xvid_usuario FROM tab_usuario WHERE id_usuario = xid_usuario;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;
		
		UPDATE tab_usuario SET contrasena = xcontrasena,
								ind_admin = xind_admin,
								ind_estado = xind_estado,
								fec_actualizacion = NOW()
								WHERE id_usuario = xid_usuario;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


--select fun_delete_usuario('1054708619');
CREATE OR REPLACE FUNCTION fun_delete_usuario(xid_usuario tab_usuario.id_usuario%TYPE) RETURNS BOOLEAN AS
$$
DECLARE
	xvid_usuario tab_usuario.id_usuario%TYPE;
	BEGIN 
		SELECT id_usuario a INTO xvid_usuario FROM tab_usuario a WHERE id_usuario = xid_usuario;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;
		
		DELETE FROM tab_usuario WHERE id_usuario = xid_usuario;
		IF NOT FOUND THEN 
		RETURN FALSE;
		END IF;
		
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;




