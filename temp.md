CREATE TABLE #temp ( LogDate datetime, ProcessInfo varchar(100), TextData varchar(max) )

INSERT INTO #temp(LogDate, ProcessInfo, TextData)
EXEC sp_readerrorlog 0, 1, N'Manufacturer'

SELECT TextData FROM #temp


The root cause is that connection to SQL Server was temporary lost, for instance because of a network glitch. When the client regains contact, it attempts to recover the connection, but this is only possible under some conditions, and when it is not, you get this error message.
