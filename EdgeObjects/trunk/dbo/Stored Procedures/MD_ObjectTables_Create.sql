-- Batch submitted through debugger: SQLQuery13.sql|7|0|C:\Users\shiratr\AppData\Local\Temp\~vs640B.sql
-- =============================================
-- Author:		Amit Bluman
-- Create date: 8/1/2013
-- Description:	This SP will create the whole objects' tables defined in EdgeType table.
--				These tables will used as the delivery objects area, and will be populated by the delivery .net process.
--				The SP input would be table prefix in order to create objects environment to each prefix (delivery signature).
-- Update date:			15/01/2013
-- Last Update desc:		Change GUID to TK, and change it's data type to navrchar(500)
-- =============================================
CREATE PROCEDURE [dbo].[MD_ObjectTables_Create]
	@TablePrefix nvarchar(4000)
AS
BEGIN

Declare @TablesList as nvarchar(4000);
Declare @CurrentTable as nvarchar(1000);
Declare @LastSQLStr as Nvarchar(4000);
Declare @CreateTableSQL as Nvarchar(4000);
Declare @CreateToDB as nvarchar(50); 

-- Debug --------------------
--Declare @TablePrefix as Nvarchar(500);
--Set @TablePrefix = 'A1_454545_';
-- Debug --------------------

Set @CreateToDB = '[EdgeDeliveries].[dbo].[' -- Should contain the DB and the schema with []

-- Find all the objects tables needs to create from EdgeType table
	Select @TablesList = COALESCE(@TablesList+' ','')+ISNULL(TableName+',','')	
	From 
		(Select distinct TableName from MD_EdgeType) A

-- print the tables
--	print  'Tables to create: ' +  @TablesList

-- Loop each table, in each loop create and add usid columns where there are GKs
While (Len(@TablesList) > 0)
		BEGIN
			-- Clear temporary parameters
			Create Table #TableStructure ( Structure NVarchar(4000));
			Set @CurrentTable = '';
			Set @CreateTableSQL = ''
			Set @LastSQLStr = ''

			-- Find current table
			Set @CurrentTable = Ltrim(Rtrim(Substring(@TablesList, 0, Charindex(',',@TablesList,0))));
				
			-- print the current table
			--print  'Current table: ' +  @CurrentTable

			-- The section will create a temp table to hold the fields in each line, than will add the guid fields for each GK, than will add FKs and Indexes if needed.
			Insert Into #TableStructure(Structure) Values ('Create Table ' + @CreateToDB + @TablePrefix + @CurrentTable + '] (');
 
			Insert Into #TableStructure(Structure)
			Select
			 '[' + C.Name + '] ' +  Ty.name + Case When C.Scale Is NULL Then '(' + Cast(C.Length as Varchar) + ') ' Else '' End +
						Case When C.IsNullable =0 And C.Colstat & 1 <> 1 Then ' NOT NULL ' Else ' NULL ' End 
						-- + Case When C.Colstat & 1 = 1 Then ' Identity(' +  Cast(ident_seed(T.name) as varchar) + ',' + Cast(ident_incr(T.name) as Varchar) + ') '  Else '' End
						+ Isnull(' Constraint ' + ChkCon.Name + ' Check ' + comments.Text ,'')
						+ Isnull(' Default ' + defcomments.text ,'') + ','
			From
			 Sysobjects T
			  Join Syscolumns C on T.id = C.Id
			  Join systypes Ty On C.xtype = Ty.xType And Ty.Name <> 'SysName'
			  Left Outer Join sysobjects ChkCon On ChkCon.parent_obj = T.Id
									And ChkCon.xtype= 'C' And ChkCon.Info = C.Colorder
						Left Outer Join syscomments comments ON Comments.id = ChkCon.id And Comments.colid =1
			  Left Outer Join sysobjects def On def.parent_obj = T.Id
									And def.xtype= 'D' And def.Info = C.Colorder
						Left Outer Join syscomments defcomments ON defcomments.id = def.id 
 
			Where
			 T.Type='U'
			 And T.Name = @CurrentTable
			 Order By T.Name, C.Colorder
 

			---- Add Indexes -------
			--Insert Into #TableStructure(Structure)
			--Select
			--            'Constraint [' + ind.name + '] ' + case when xtype='PK' Then ' Primary Key ' Else ' Unique ' End  + Case when ind.status & 16=16 Then ' clustered ' Else ' nonclustered' End  +  '(' +  dbo.GetAllIndexedColumns(@CurrentTable, 2)  + '),'
			--From
			--            sysindexes ind Join sysobjects tbl On tbl.parent_obj = object_id(@CurrentTable)
			--                        and ind.name = object_name(tbl.id)
			--                        and xtype in ('PK', 'UQ')
			---- Add FKs -----
			--Insert Into #TableStructure(Structure)
			--select
			--            'Constraint [' + tbl.name + '] FOREIGN KEY ([' + col_name(fk.fkeyid, fk.fkey) + ']) REFERENCES [' + 
			--            object_name(fk.rkeyid) + ']([' + col_name(fk.rkeyid, fk.rkey) + ']),'
			--from    
			--            sysforeignkeys fk Join sysobjects tbl On tbl.parent_obj = object_id(@CurrentTable)
			--                                    and fk.constid = tbl.id
			--                                    and xtype in ('F')

			-- Add USID for each GK field
			Update #TableStructure
			Set Structure = Structure + Replace(Replace(Structure,'gk','TK'),'bigint','nvarchar(500)')
			Where Structure like '%GK%'
				
			-- Eliminates the last comma in the query
			--Select @LastSQLStr = Structure From #TableStructure;
			
			--Update #TableStructure
			--Set   Structure = Substring(Structure,1,Len(Structure)-1)
			--Where Structure = @LastSQLStr;

			-- Add IdentityStatus in order to tag each object if it's new/modified/unChanged
			-- and the last )
			Insert Into #TableStructure(Structure) values (' [IdentityStatus] tinyint NULL DEFAULT 0)');

			Select @CreateTableSQL = COALESCE(@CreateTableSQL+' ','')+ISNULL(Structure + '','')	
				From #TableStructure

			select * from  #TableStructure

			-- Create the current table
			Exec (@CreateTableSQL) -- Keep the brackets 

			--Print @TablePrefix + @CurrentTable + ' Table Created !!'	
					
			-- Drops temp structure definition table 
			Drop table #TableStructure	
			
			-- Delete current table from the string
			Set @TablesList = Substring(@TablesList, Charindex(',',@TablesList,0)+1, 9999)
		END 
-- End of while loop

END