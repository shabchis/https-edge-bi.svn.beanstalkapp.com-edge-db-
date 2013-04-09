CREATE PROCEDURE [dbo].[sp_BestMatch] @InputTable NVARCHAR(200), @BestMatch NVARCHAR(200) OUTPUT

AS

--DECLARE @BestMatch NVARCHAR(100)
--DECLARE @InputTable nvarchar(100)


--SET @InputTable = '[DBO].[2__20130403_110434_5f368d7f48490b6484bcc9482b730dba_Metrics]'

DECLARE @SqlStr1  NVARCHAR(4000)
DECLARE @OnlyTableName nvarchar(300)
DECLARE @NewTableName nvarchar(300)
                
-----------------------------1.FILL STAGING DATA-------------------------------------------------------------------------
TRUNCATE TABLE [EdgeStaging].[dbo].[MD_StagingMetadata]

INSERT INTO  [dbo].[MD_StagingMetadata] (TableName, EdgeFieldName, FieldDataType, FieldsCount)
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, ( SELECT MAX(ORDINAL_POSITION) 
										     FROM information_schema.COLUMNS T2
											 GROUP BY TABLE_NAME  
											 HAVING  T1.TABLE_NAME = T2.TABLE_NAME) AS  FieldsCount
FROM   [EdgeStaging].information_schema.COLUMNS T1
WHERE  TABLE_NAME <> 'MD_StagingMetadata' AND TABLE_NAME <> 'sysdiagrams'

-------------------2. Check if not exists and create table by input table name + 'MD_Temp'-----------------------------

SET @NewTableName = '[EdgeDeliveries].' + @InputTable 

SET @NewTableName = LEFT (@NewTableName, (LEN(@NewTableName) -1))   + '_MD_TEMP] '

--print @NewTableName

SET @OnlyTableName = LEFT (@InputTable, (LEN(@InputTable) -1))   + '_MD_TEMP '
SET @OnlyTableName = RIGHT(@OnlyTableName, LEN(@OnlyTableName) -6)

--SET @SqlStr1 = 'USE [EdgeDeliveries] IF NOT EXISTS (SELECT * FROM sysobjects  where name=''' + @OnlyTableName + ''')
--                CREATE TABLE  ' + @NewTableName +'  ([TableName] NVARCHAR(200), [EdgeFieldName] NVARCHAR(200) ) '


				
SET @SqlStr1 = 'USE [EdgeDeliveries] IF  EXISTS (SELECT * FROM sysobjects  where name=''' + @OnlyTableName + ''')
                DROP TABLE  ' + @NewTableName 

EXEC (@SqlStr1)
SET @SqlStr1 = 'CREATE TABLE  ' + @NewTableName +'  ([TableName] NVARCHAR(200), [EdgeFieldName] NVARCHAR(200) ) '


EXEC (@SqlStr1)


----------Union Objects and Measures fields + System fields into one colunm. Insert to temp table-------------------------------

SET @SqlStr1 = 'INSERT INTO  ' + @NewTableName +'  ([TableName] , [EdgeFieldName])
(
SELECT  [TableName]
      ,[EdgeFieldName]
  FROM [EdgeDeliveries].[dbo].[MD_MetricsMetadata]
  WHERE [EdgeFieldName] is not null 
  AND [TableName] = ''' + @InputTable + '''
  
  UNION 

  SELECT 
	  [TableName]
      ,[MeasureName]
  FROM [EdgeDeliveries].[dbo].[MD_MetricsMetadata]    
  WHERE [MeasureName] is not null 
  AND [TableName] = ''' + @InputTable + '''

  UNION 
  SELECT ''' + @InputTable+ ''', [SystemField] 
  FROM [EdgeStaging].[dbo].[SystemFields]

 )
 '


 --print @SqlStr1
 exec (@SqlStr1)
   
/*---------------------------------------FIND BEST MATCH TABLE----------------------------------
-----Select tables that exactly fits all columns by check number/count of adjustments: 
If the number of adjustments is equal to number of columns, then the table is suitable
*/ 

SET @SqlStr1 = 'SELECT Staging.TableName,  COUNT(Staging.[EdgeFieldName]) AS  MatchCount, min(Staging.FieldsCount)  as FieldsCount  INTO  ##TEMP
FROM  [EdgeStaging].[dbo].[MD_StagingMetadata] as Staging INNER JOIN  ' + @NewTableName + ' AS Delivery 
ON Staging.[EdgeFieldName] =  Delivery.[EdgeFieldName]
GROUP BY Staging.tablename
HAVING COUNT(Staging.[EdgeFieldName]) = (SELECT  COUNT(*)  FROM ' + @NewTableName + ')'

exec (@SqlStr1)

--------Select One  Table in case there are more than one adjustments
SELECT @BestMatch  = (SELECT  TOP 1 (T1.TableName) FROM ##Temp AS T1 INNER JOIN ##Temp AS T2
ON T1.FieldsCount <= T2.FieldsCount)

--print @BestMatch


PRINT 'See in "Results" tables that "Best Match" algorithm found :'
SELECT * FROM ##Temp

--------------Result-------------------------------------------------------------------------------------------------
 
PRINT 'The "Best Match" table Is:'  
IF (@BestMatch IS NOT NULL )  PRINT @BestMatch


--------Drop temp objects---------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM ##Temp)  DROP  TABLE ##Temp

----------------------------END----------------------------------------------------------------------------------------

--EXEC [EdgeStaging].[dbo].[sp_BestMatch] '[DBO].[2__20130408_094958_5f368d7f48490b6484bcc9482b730dba_Metrics]' , a



--select count(*) from [EdgeDeliveries].[DBO].[2__20130408_094958_5f368d7f48490b6484bcc9482b730dba_Metrics_MD_TEMP]