/************************************************************
   * ���������� ��������� ����� ���� ������ dbName, ���� ������ ������������ ������, ��� ���������� ���������� ����������� ������ ���� ��������� ����� ������ �� ��������� ������ bak.
 * Time:  
 ************************************************************/
 
 USE [master]
 
 
 ------ ������� ������ ������ ----------------------------------------- --------------------
--1. xp_delete_file  
 - ������������: ������� �������������  
 ����������: �� �� ������ ������� �����, ��������� ��� SQL Server, ������� RAR.  
 - ����������: ������� ������������ � ����� ������������ ����� �������� ��� ����������� �������� ��������� ��� �������� ������.  
DECLARE @oldDate DATETIME  
SET @oldDate = GETDATE() -0  
--EXECUTE MASTER.dbo.xp_delete_file 
 -0, --0: ����� ��������� �����, 1: ��������� ����� � ����� ������������  
 -N'D: \ DataBak \ dbName \ ', - ���� � �����  
 -N'bak ', -File ����������  
 - @ oldDate, - ��� ����� �� ����� ������� ����� �������  
 -1-������� ����� � ���������  
 
 
EXEC xp_cmdshell 'rd D:\DataBak\dbName',
           no_output-������� �����, ����� �������� ������ ��������� ����� 
EXEC xp_cmdshell 'mkdir D:\DataBak\dbName',
           no_output-���������� ����� 
 
DECLARE @BakCount INT 
DECLARE @n INT 
DECLARE @Sql NVARCHAR(MAX) 
DECLARE @FILENAME VARCHAR(500)
DECLARE @DATABaseName VARCHAR(500)
DECLARE @DATABakPath VARCHAR(500)
 
SET @DATABakPath = 'D:\DataBak\'
 SET @BakCount = 5-���������� ��� ������ ��� ����������
SET @DATABaseName = 'dbName'
SET @n = 1
SET @FILENAME = REPLACE(
        REPLACE(
            REPLACE(CONVERT(VARCHAR, GETDATE(), 120), '-', ''),
            ' ',
            ''
        ),
        ':',
        ''
    ) + '';
DECLARE @exeText VARCHAR(100)
 SET @exeText = 'mkdir' + + @DATABakPath + @DATABaseName + '\' + @ FILENAME - ������� ��������� ����� �������� 
EXEC xp_cmdshell @exeText,
     no_output    
SET @Sql = 'BACKUP DATABASE dbName 
TO DISK = N''' + @DATABakPath + @DATABaseName + '\' + @FILENAME + '\' + 
    @DATABaseName + '_' + @FILENAME + '_0.bak'''
WHILE @n < @BakCount
BEGIN
    SET @Sql = @Sql + ',
	DISK = N''' + @DATABakPath + @DATABaseName + '\' + @FILENAME + '\' + 
        @DATABaseName + '_' + @FILENAME + '_' + CONVERT(VARCHAR, @n) + '.bak'''
    
    SET @n = @n + 1
END
EXEC (@Sql) 
 
 
 ������ '----------- ��������� �����������' + @DATABaseName + '������ ---------------------' + CONVERT (VARCHAR (100) , GETDATE (), 126)
+ '---------------'




 
/ *** ������������ ����������� ���� ��������� �����. ���� ������ ������, �� ������ ���������� � ���� ��������� �����. ����������� ��������� ***** /
 
RESTORE DATABASE dbName FROM 
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_0.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_1.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_2.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_3.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_4.bak' 
WITH MOVE 'dbName' TO 'D:\SqlDataBase\dbName.mdf', 
     MOVE 'dbName_log' 
     TO 'D:\SqlDataBase\dbName_log.ldf',
     STATS = 5