#!/bin/sh

echo 'Creating rmoff.customers table'

sqlplus rmoff/asgard@//localhost:1521/ORCLPDB1  <<- EOF

  drop table customers purge;
  
  create table CUSTOMERS (
          id NUMBER(5,0) GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 42) NOT NULL PRIMARY KEY,
          first_name VARCHAR(50),
          last_name VARCHAR(50),
          email VARCHAR(50),
          gender VARCHAR(50),
          club_status VARCHAR(8),
          comments VARCHAR(90),
          create_ts timestamp DEFAULT CURRENT_TIMESTAMP ,
          update_ts timestamp 
  );

  CREATE OR REPLACE TRIGGER TRG_CUSTOMERS_UPD 
  BEFORE INSERT OR UPDATE ON rmoff.CUSTOMERS 
  REFERENCING NEW AS NEW_ROW
    FOR EACH ROW
  BEGIN
    SELECT SYSDATE
          INTO :NEW_ROW.UPDATE_TS
          FROM DUAL;
  END;
  /
  
EOF

sqlplus sys/Admin123@//localhost:1521/ORCLPDB1 as sysdba <<- EOF

  ALTER TABLE rmoff.customers ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
  GRANT SELECT ON rmoff.customers to c##xstrm;

  -- From https://xanpires.wordpress.com/2013/06/26/how-to-check-the-supplemental-log-information-in-oracle/
  COLUMN LOG_GROUP_NAME HEADING 'Log Group' FORMAT A20
  COLUMN TABLE_NAME HEADING 'Table' FORMAT A20
  COLUMN ALWAYS HEADING 'Type of Log Group' FORMAT A30

  SELECT LOG_GROUP_NAME, TABLE_NAME, DECODE(ALWAYS, 'ALWAYS', 'Unconditional', NULL, 'Conditional') ALWAYS FROM DBA_LOG_GROUPS;

  exit;
EOF