ALTER SESSION SET CONTAINER = CDB$ROOT;
ACC sql_id PROMPT 'Enter SQL_ID (req): ';
ACC pdb_name PROMPT 'PDB Name (opt, default all): ';
PRO Report Only Flag [Y|N]. Y=Report Only. N=Create/Promote/Demote SPB.
ACC report_only PROMPT 'Enter Report Only Flag [Y|N] (opt, default Y): ';
-- exit graciously if executed on standby
WHENEVER SQLERROR EXIT SUCCESS;
DECLARE
  l_open_mode VARCHAR2(20);
BEGIN
  SELECT open_mode INTO l_open_mode FROM v$database;
  IF l_open_mode <> 'READ WRITE' THEN
    raise_application_error(-20000, 'Must execute on PRIMARY');
  END IF;
END;
/
SELECT CASE open_mode WHEN 'READ WRITE' THEN open_mode ELSE TO_CHAR(1/0) END open_mode FROM v$database;
SET ECHO OFF VER OFF FEED OFF HEA OFF PAGES 0 TAB OFF LINES 300 TRIMS ON SERVEROUT ON SIZE UNLIMITED;
COL report_file NEW_V report_file;
SELECT '/tmp/iod_spm_fpz_&&sql_id._&&pdb_name._'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') report_file FROM DUAL;
SPO &&report_file..txt;
EXEC c##iod.iod_spm.fpz(p_report_only => NVL(SUBSTR(UPPER(TRIM('&&report_only.')), 1, 1), 'Y'), p_pdb_name => UPPER(TRIM('&&pdb_name.')), p_sql_id => NVL(TRIM('&&sql_id.'), 'invalid'));
SPO OFF;
HOS zip -mj &&report_file..zip &&report_file..txt
HOS unzip -l &&report_file..zip
WHENEVER SQLERROR CONTINUE;
