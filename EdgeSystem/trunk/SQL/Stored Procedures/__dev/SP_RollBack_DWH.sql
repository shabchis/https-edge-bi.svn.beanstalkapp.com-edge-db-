CREATE procedure [dbo].[SP_RollBack_DWH] 
( @DeliveryID nvarchar(4000),
  @Signature nvarchar(4000), 
  @CommitTableName nvarchar(4000)) AS

-- This SP will find the "pending roll back" delivery outputs, delete it from the DWH db, and change it's status to rolledback.
-- The SP belongs to system db

-- Start debug
/*
	Declare @DeliveryID nvarchar(4000)
	Declare @Signature nvarchar(4000)
	Declare @CommitTableName nvarchar(4000)

	-- Set @Signature = 'ZmFjZWJvb2stWzYxXS1bNTk2ODQ0MTFdLVt7c3RhcnQ6e2FsaWduOidTdGFydCcsZGF0ZTonMjAxMi0wOC0wOFQwMDowMDowMCd9LGVuZDp7YWxpZ246J0VuZCcsZGF0ZTonMjAxMi0wOC0wOFQyMzo1OTo1OS45OTk5OTk5J319XQ=='
	Set @CommitTableName = 'Paid_API_Allcolumns'
*/
-- End debug 

Declare @DebugMode as bit;
Declare @OutputIDs as nvarchar(4000);
Declare @TableNames as nvarchar(4000);
Declare @CurrentTableName as nvarchar(4000);
Declare @CurrentOutputID as nvarchar(4000);
Declare @DWHDB as nvarchar(4000);
Declare @sql as nvarchar(4000);

--	Drop table #OutputAndTable;
--	Drop table #DistinctTables;
	
	set @DebugMode = 'False' ;
	set @DWHDB = 'EdgeDWH';

	Create table #OutputAndTable (OutputID Nvarchar(4000) not null, TableName Nvarchar(4000) not null)  ;

-- The should ask for rollback per signature OR per commitTableName
    If (@Signature is null and @CommitTableName is null)  Return;
	
	If (@Signature is not null and @CommitTableName is null) 	
-- Find all the "pending roll back" statuses (7) in delivery output table for the specific signature. the data stored is table name and outputID
	Begin
		Insert into #OutputAndTable
		select DO.OutputID as OutputID, DOP.Value as TableName
		from [dbo].[DeliveryOutput] DO	
		  left outer join dbo.DeliveryOutputParameters DOP
			on DO.DeliveryID = DOP.DeliveryID and DO.OutputID = DOP.OutputID
		where  DO.[Signature] = @Signature and DO.Status = 7 and DOP.[Key] = 'CommitTableName';
	End
	
	
	If (@Signature is null and @CommitTableName is not null) 	
-- Find all the "pending roll back" statuses (7) in delivery output table for the specific commitTableName. the data stored is table name and outputID
	Begin
		Insert into #OutputAndTable
		select DO.OutputID as OutputID, DOP.Value as TableName
		from [dbo].[DeliveryOutput] DO	
		  left outer join dbo.DeliveryOutputParameters DOP
			on DO.DeliveryID = DOP.DeliveryID and DO.OutputID = DOP.OutputID
		where  DO.Status = 7 and DOP.[Key] = 'CommitTableName' and DOP.Value = @CommitTableName;
	End

-- Distinct the table names	 
	
	Select distinct TableName
	into #DistinctTables
	from #OutputAndTable 

-- Populate the table names list		
	select @TableNames = COALESCE(@TableNames+'', '','''')+ ISNULL(TableName+',','''')
	from  #DistinctTables;
	
		If (@DebugMode = 'True') print '@TableNames: ' + @TableNames;
 
 -- For each table name - delete all the outputIDs in that table
while LEN(@TableNames) > 0 
	BEGIN 
-- get current table 
	set @CurrentTableName = SUBSTRING(@TableNames,0,CHARINDEX(',',@TableNames,0));
		If (@DebugMode = 'True') print 'CurrentTableName: '+ @currentTableName;

	
 -- Clear and populate the OutputID list which belongs to the current table name
	set @OutputIDs = ''''
	select @OutputIDs = COALESCE(@OutputIDs+'', '''', '''')+ISNULL(OutputID+''',''','')
	from  #OutputAndTable
	where TableName = @CurrentTableName;
	
		If (@DebugMode = 'True')  print 'OutputIDs: ' +@OutputIDs
		
-- Remove the last comma and apostrophe 
	set @OutputIDs = SUBSTRING(@OutputIDs,0,LEN(@OutputIDs)-1)
		If (@DebugMode = 'True')  print 'OutputIDs: ' +@OutputIDs

	set @sql = ''	
	set @sql = 'delete from ['+ @DWHDB + '].[dbo].['+ @CurrentTableName +'] where outputID in ('+ @OutputIDs +')';
		If (@DebugMode = 'True') print @sql
	print ' Delete outputIDs for table: ' + @CurrentTableName;
	 EXECUTE (@sql);

-- After deletion set the status to "Rolledback" in the delivery output table
	set @sql = ''
	set @sql = 'update [dbo].[DeliveryOutput] 
				set [Status] = 5 
				where outputID in ('+ @OutputIDs +')';
		If (@DebugMode = 'True') print @sql;
	
	EXECUTE (@sql)
	print ' Set rolledback status for outputIDs: ' +@OutputIDs

		print ' Delete outputIDs for table: ' + @CurrentTableName;	
-- Delete the current table name from @TableNames
	set @TableNames = SUBSTRING(@TableNames,CHARINDEX(',',@TableNames,0)+1,3999);
		If (@DebugMode = 'True') print @TableNames;
	
	END	-- While end