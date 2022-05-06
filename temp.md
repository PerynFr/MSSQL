CREATE TABLE #temp ( LogDate datetime, ProcessInfo varchar(100), TextData varchar(max) )

INSERT INTO #temp(LogDate, ProcessInfo, TextData)
EXEC sp_readerrorlog 0, 1, N'Manufacturer'

SELECT TextData FROM #temp
