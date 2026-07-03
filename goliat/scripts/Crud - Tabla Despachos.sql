--SELECT fun_insert_despachos(244424234,'desapcho r de goliat', 'calle 4 donde julio','3124786484','daniel_san@gmail.com','68001');
--select * from tab_despacho;
CREATE OR REPLACE FUNCTION fun_insert_despachos(xid_despacho tab_despacho.id_despacho%TYPE,
                                                   xnom_despacho tab_despacho.nom_despacho%TYPE,
                                                   xdir_despacho tab_despacho.dir_despacho%TYPE,
                                                   xtel_despacho tab_despacho.tel_despacho%TYPE,
                                                   xemail_despacho tab_despacho.email_despacho%TYPE,
                                                   xid_ciudad tab_despacho.id_ciudad%TYPE) RETURNS BOOLEAN AS
$BODY$
    DECLARE xreg_despacho  RECORD;
    BEGIN
        SELECT a.id_despacho,a.nom_despacho into xreg_despacho FROM tab_despacho a
        WHERE a.id_despacho = xid_despacho;
		
        IF FOUND THEN
            RETURN FALSE;
        ELSE
		
            INSERT INTO tab_despacho VALUES(xid_despacho,xnom_despacho,xdir_despacho,xtel_despacho,xemail_despacho,xid_ciudad);
            IF FOUND THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        END IF;
    END;
$BODY$
LANGUAGE plpgsql;


--SELECT fun_update_despachos(244424234,'cambio de nombre', 'calle 4 nuevo lugar','3124786484','daniel_san@gmail.comun','68001');
--select * from tab_despacho;
CREATE OR REPLACE FUNCTION fun_update_despachos(xid_despacho tab_despacho.id_despacho%TYPE,
                                                   xnom_despacho tab_despacho.nom_despacho%TYPE,
                                                   xdir_despacho tab_despacho.dir_despacho%TYPE,
                                                   xtel_despacho tab_despacho.tel_despacho%TYPE,
                                                   xemail_despacho tab_despacho.email_despacho%TYPE,
                                                   xid_ciudad tab_despacho.id_ciudad%TYPE) RETURNS BOOLEAN AS
$$
	DECLARE xvid_despacho tab_despacho.id_despacho%TYPE;
	BEGIN 
		SELECT a.id_despacho into xvid_despacho FROM tab_despacho a WHERE a.id_despacho = xid_despacho;
		
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;

		UPDATE tab_despacho SET nom_despacho 	= xnom_despacho,
								dir_despacho 	= xdir_despacho,
								tel_despacho 	= xtel_despacho,
								email_despacho 	= xemail_despacho,
								id_ciudad 		= xid_ciudad
								WHERE id_despacho = xid_despacho;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;	
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


--select fun_delete_despachos(244424234);
--select * from tab_despacho;
CREATE OR REPLACE FUNCTION fun_delete_despachos (xid_despacho tab_despacho.id_despacho%TYPE) RETURNS BOOLEAN AS
$$
	DECLARE 
	xvid_despacho tab_despacho.id_despacho%TYPE;
	BEGIN
		SELECT a.id_despacho INTO xvid_despacho FROM tab_despacho a WHERE a.id_despacho = xid_despacho;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;

		DELETE FROM tab_despacho  WHERE id_despacho = xid_despacho;
		IF NOT FOUND THEN 
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


