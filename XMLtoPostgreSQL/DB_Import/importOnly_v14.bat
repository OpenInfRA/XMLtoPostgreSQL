@echo off
echo Import XML nach Postgresql 
echo.
set db_name=openinfra
set user_name=postgres
set schema_name=project_02c7ba53-6d0c-4a78-93e5-46916ac804c7
set path_name=C:\"Program Files"\PostgreSQL\9.4\bin\psql
set host=localhost
set port=5432
set PGPASSWORD=postgres

%path_name% -h %host% -p %port% -U %user_name% -d %db_name% -1 -f Import.sql
echo.
pause 
rem cls