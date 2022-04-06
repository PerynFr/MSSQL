--какие ХП созданы, какие действия они выполняют и над какими таблицами.

-- Хранимые процедуры 
SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DBName ,
        o.name AS StoredProcedureName ,
        o.[Type] ,
        o.create_date
FROM    sys.objects o
WHERE   o.[Type] = 'P' -- Stored Procedures 
ORDER BY o.name

--OR 
-- Дополнительная информация о ХП 

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DB_Name ,
        o.name AS 'ViewName' ,
        o.[type] ,
        o.Create_date ,
        sm.[definition] AS 'Stored Procedure script'
FROM    sys.objects o
        INNER JOIN sys.sql_modules sm ON o.object_id = sm.object_id
WHERE   o.[type] = 'P' -- Stored Procedures 
        -- AND sm.[definition] LIKE '%insert%'
        -- AND sm.[definition] LIKE '%update%'
        -- AND sm.[definition] LIKE '%delete%'
        -- AND sm.[definition] LIKE '%tablename%'
ORDER BY o.name;

GO

--Добавив условие в WHERE мы можем получить информацию только о тех хранимых процедурах, которые, например, выполняют операции INSERT.

WHERE   o.[type]  = 'P' -- Stored Procedures 
        AND sm.definition LIKE '%insert%'
ORDER BY o.name
