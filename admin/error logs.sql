declare @temp as table ( LogDate datetime, ProcessInfo varchar(100), TextData varchar(max) )

INSERT INTO @temp(LogDate, ProcessInfo, TextData)
EXEC sp_readerrorlog 

SELECT * FROM @temp where TextData like '%error%'
