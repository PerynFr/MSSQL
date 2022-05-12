/*
Требуется все таблицы одного владельца (owner) передать другому. Как это можно сделать?

Ответ:
Лучше всего воспользоваться курсором для организации вызова ХП sp_changeobjectowner
*/ -- Объявим переменные
 DECLARE @ObjName varchar(255),
                  @Str varchar(255),
                       @OldOwnerName varchar(255),
                                     @NewOwnerName varchar(255) -- Зададим имена старого и нового владельцев

SELECT @OldOwnerName='Старый владелец',
       @NewOwnerName='Новый владелец' -- Объявим курсор для прохождения по всем объектам старого владельца
 DECLARE Crs_DelObj INSENSITIVE SCROLL
CURSOR
FOR
SELECT so.name
FROM sysobjects so,
     sysusers su
WHERE so.uid = su.uid
  AND su.name = @OldOwnerName
  AND so.type in ('V',
                  'U',
                  'P') -- пойдем по курсору и будем менять владельцев
 OPEN Crs_DelObj FETCH FIRST
  FROM Crs_DelObj INTO @ObjName WHILE @@fetch_status<>-1 BEGIN IF @@fetch_status<>-2 BEGIN
SELECT @Str=ltrim(rtrim(@OldOwnerName))+"."+ltrim(rtrim(@ObjName)) -- меняем владельца
 EXEC ("exec sp_changeobjectowner '"+@STR+"', '"+@NewOwnerName+"'") END FETCH NEXT
FROM Crs_DelObj INTO @ObjName END GO CLOSE Crs_DelObj GO DEALLOCATE Crs_DelObj GO
