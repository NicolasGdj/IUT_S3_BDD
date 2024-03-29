/* TP BDA 3 */

/*Q1* /
COMMIT;

CREATE OR REPLACE TRIGGER asm BEFORE DELETE ON MODULE FOR EACH ROW
DECLARE
    CNT_MODULE NUMBER(3,0);
BEGIN
    SELECT COUNT(DISTINCT CODE) INTO CNT_MODULE FROM ENSEIGNT WHERE CODE = :old.CODE;
    IF CNT_MODULE > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'MATIERE ENSEIGNER');
    END IF;
END;

DELETE MODULE WHERE CODE='ACSI';

ROLLBACK;

/*Q2* /
COMMIT;

CREATE OR REPLACE TRIGGER asm BEFORE INSERT ON ENSEIGNT FOR EACH ROW
DECLARE
    CNT_MODULE NUMBER(3,0);
BEGIN
    SELECT COUNT(DISTINCT CODE) INTO CNT_MODULE FROM MODULE WHERE CODE = :new.CODE;
    IF CNT_MODULE = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'MATIERE NON ENSEIGNE');
    END IF;
END;

INSERT INTO ENSEIGNT VALUES('LOL', 2, 2101);

ROLLBACK;

/*Q3* /

COMMIT;

CREATE OR REPLACE TRIGGER DefNotation BEFORE INSERT OR UPDATE OF MOY_CC, MOY_TEST ON NOTATION FOR EACH ROW
BEGIN
    IF :new.MOY_CC IS NULL THEN
        :new.MOY_CC := 0;
    END IF;
    IF :new.MOY_TEST IS NULL THEN
        :new.MOY_TEST := 0;
    END IF;
END;

INSERT INTO NOTATION VALUES(2101, 'BD', NULL, NULL);

ROLLBACK;

/*INSERT ET UPDATE MAIS QUE QUAND ON CHANGE MOY_CC OU MOY_TEST*/

/*Q4* /

COMMIT;

CREATE OR REPLACE TRIGGER CheckUser BEFORE INSERT ON NOTATION FOR EACH ROW
DECLARE
    CNT NUMBER(3,0);
BEGIN
    SELECT COUNT(*) INTO CNT FROM ENSEIGNT WHERE CODE=:new.CODE AND NUM_ET=:new.NUM_ET;
    IF CNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ET N''A PAS D''ENSEIGNEMENT');
    END IF;
END;

INSERT INTO NOTATION VALUES (2103, 'BD', 0, 0);

ROLLBACK;

/*Q5* /

CREATE OR REPLACE TRIGGER CHECKCOEF BEFORE INSERT OR UPDATE OF COEFF_TEST, COEFF_CC ON MODULE FOR EACH ROW
BEGIN
    IF (:new.COEFF_TEST + :new.COEFF_CC) <> 100 THEN
        RAISE_APPLICATION_ERROR(-20002, 'COEFF INCORRECT');
    END IF;
END;

/*Q6* /
COMMIT;

CREATE TABLE GROUPE (
    NUMERO NUMBER(1,0),
    ANNEE NUMBER(2,0),
    EFFECTIF NUMBER(2,0)
);  

DECLARE
    NUM_GROUPE NUMBER(2,0);
    NUM_ANNEE NUMBER(2,0);
    G_A ETUDIANT.ANNEE%TYPE;
    EFF NUMBER(3,0);
BEGIN
    SELECT MAX(DISTINCT ANNEE) INTO NUM_ANNEE FROM ETUDIANT;
    SELECT MAX(DISTINCT GROUPE) INTO NUM_GROUPE FROM ETUDIANT;
    FOR g IN 1..NUM_GROUPE LOOP
        FOR a IN 1..NUM_ANNEE LOOP
            SELECT COUNT(*) INTO EFF FROM ETUDIANT WHERE GROUPE = g AND ANNEE= a;
            INSERT INTO GROUPE VALUES (g, a, EFF);
        END LOOP;
    END LOOP;
END;
ROLLBACK;

/**/
COMMIT;
CREATE OR REPLACE TRIGGER UpdateGrp BEFORE INSERT OR UPDATE OF GROUPE, ANNEE ON ETUDIANT FOR EACH ROW
DECLARE
    CURSOR Cu(AN ETUDIANT.ANNEE%TYPE) IS SELECT NUMERO FROM GROUPE WHERE ANNEE = AN ORDER BY EFFECTIF ASC; 
    Va Cu%ROWTYPE;
BEGIN
    IF UPDATING AND :old.GROUPE IS NOT NULL THEN
        UPDATE GROUPE SET EFFECTIF=EFFECTIF-1 WHERE NUMERO=:old.GROUPE AND ANNEE=:old.ANNEE;
    END IF;
    
    IF :new.GROUPE IS NULL THEN
        OPEN Cu(:new.ANNEE);
        FETCH Cu INTO Va;
        IF Cu%FOUND THEN
            :new.GROUPE := Va.NUMERO; 
        END IF;
        CLOSE Cu;
    END IF;
    
    UPDATE GROUPE SET EFFECTIF=EFFECTIF+1 WHERE NUMERO=:new.GROUPE AND ANNEE=:new.ANNEE;
END;
ROLLBACK;