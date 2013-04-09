CREATE PROCEDURE [dbo].[sp_MetrixStaging] @FromTable NVARCHAR(100), @ToTable NVARCHAR(100)

AS

--truncate table [EdgeStaging].[dbo].[k2]

--DECLARE @FromTable NVARCHAR(200)

--SET @FromTable  = '[DBO].[2__20130403_110434_5f368d7f48490b6484bcc9482b730dba_Metrics]' --Delivery table
SET @FromTable =      LEFT(@FromTable, len(@FromTable) -1)
SET @FromTable = '[EdgeDeliveries].'+@FromTable + '_MD_TEMP]'

--print @FromTable

--DECLARE @ToTable NVARCHAR(1000)
--SET @ToTable  = 'k2' -- Best match table name

SET @ToTable = '[EdgeStaging].'+ @ToTable

DECLARE @columnNames NVARCHAR(1000)  = ''
DECLARE @SqlStr NVARCHAR(1000)    = ''
DECLARE @SqlStr2 NVARCHAR(1000)    = ''
DECLARE @TableName NVARCHAR(1000)  = ''

----Insert column names into temp table/global variable------------

SET @SqlStr = 
			'SELECT   EdgeFieldName,TableName  into ##ListOfColumns
			 FROM ' +  @fromTable + ' WHERE  EdgeFieldName is not null'
EXEC  (@SqlStr)
--print @SqlStr

----------------------Insert fields Names as a list separated by comma

SELECT   @columnNames  +=   EdgeFieldName  + ', '   FROM ##ListOfColumns

--------------------Cut the last comma from string ------------------------------
SET @columnNames =  LEFT (@columnNames, (LEN(@columnNames) -1))
--print @columnNames

-------SELECT table name from temp table-------------------
SELECT  @TableName  = ' [EdgeDeliveries].' + TableName  from ##ListOfColumns

--print @TableName
------------------------Insert into target Table-----------------

SET @SqlStr2 = 
			'INSERT INTO ' +  @ToTable + '  (' + @columnNames + ')
			 SELECT ' + @columnNames + ' FROM '+ @TableName 

EXEC  (@SqlStr2)
--print @SqlStr2

--------Drop temp objects---------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM ##ListOfColumns)  DROP  TABLE ##ListOfColumns

----------------------------END----------------------------------------------------------------------------------------


select * from  [EdgeStaging].[dbo].[k2]

--EXEC [EdgeStaging].[dbo].[sp_MetrixStaging] '[DBO].[test1]'  ,'[DBO].[k2]'