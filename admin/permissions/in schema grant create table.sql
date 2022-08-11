--Создание таблиц в схеме
--Эта задача требует разрешения CREATE TABLE в базе данных и разрешения ALTER на схему, в которой создается таблица.
--https://docs.microsoft.com/ru-ru/sql/relational-databases/tables/create-tables-database-engine?view=sql-server-ver16
/*
ALTER AUTHORIZATION ON SCHEMA::[APPA] to [CORP\user]; 
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO [CORP\user];
*/

GRANT ALTER ON SCHEMA::[APPA] to [CORP\user];
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO [CORP\user];
GRANT VIEW DEFINITION ON SCHEMA::[APPA] to [CORP\user];
GRANT select, INSERT, DELETE, UPDATE ON SCHEMA::[APPA] to [CORP\user];