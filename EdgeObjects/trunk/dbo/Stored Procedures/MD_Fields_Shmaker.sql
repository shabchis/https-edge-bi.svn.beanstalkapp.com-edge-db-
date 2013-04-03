-- =============================================
-- Author:		Amit Bluman
-- Create date: 01/01/2013
-- Description:	This SP will create system fields in a cetain table, based on the column type and till the field index
-- =============================================
CREATE PROCEDURE [MD_Fields_Shmaker]
	@TableName as nvarchar(100),
	@ColumnType as nvarchar(50),
	@TillColumnIndex as int
AS
BEGIN
	SET NOCOUNT ON;

    
Declare @ColumnIndex as int;
Declare @ColumnExists as int;
Declare @ColumnDBType as nvarchar(100);
Declare @SQL as nvarchar(4000);
Declare @ColumnName as nvarchar(100);

-- Debug
--Set @TableName = 'Creative'
--Set @ColumnType = 'float'
--Set @TillColumnIndex = 6
-- Debug
Set @columnIndex = 1

Set @ColumnDBType = Case 
						when @ColumnType ='string' then '[nvarchar](1000)'
						when @ColumnType ='int' then '[int]'
						when @ColumnType ='float' then '[decimal](18,3)'
						-- when @ColumnType ='obj' then '[bigint]' -- It is hardcoded in the @SQL parameter
					End

--alter TABLE [dbo].[Creative]
--add [obj_Field5_type] [int] NULL, [obj_Field6_gk] [bigint] NULL
While (@ColumnIndex <= @TillColumnIndex)
Begin
		Set @ColumnExists = -1
		
		If @ColumnType != 'obj' 
			Begin
				Set @ColumnName = @ColumnType + '_Field' + convert(nvarchar(5),@ColumnIndex);
				-- Print @ColumnName;
		
				-- Check if the column exists
				select @ColumnExists = Column_id from [EdgeObjects].[sys].[columns] as SysColumns
					inner join [EdgeObjects].[sys].[Tables]  as SysTables 
						on SysColumns.[object_id] = SysTables.[object_id]
				Where SysTables.Name = @TableName and SysColumns.name = @ColumnName

				-- print @ColumnExists

				-- Create the field if it not exists
				If (@ColumnExists = -1)
					Begin 
						Set @SQL = 'ALTER TABLE [dbo].['+@TableName+'] Add ['+@ColumnName+'] '+@ColumnDBType+' NULL';			
						-- Print @SQL;
						Exec (@SQL);
					End	 
			End

			If @ColumnType = 'obj' 
			Begin
				Set @ColumnName = @ColumnType + '_Field' + convert(nvarchar(5),@ColumnIndex);
				-- Print @ColumnName;
				
				-- Check if the column exists, the assumption is : "if there is at least one obj_... column, then both fields exists"
				select top 1 @ColumnExists =  Column_id from [EdgeObjects].[sys].[columns] as SysColumns
					inner join [EdgeObjects].[sys].[Tables]  as SysTables 
						on SysColumns.[object_id] = SysTables.[object_id]
				Where SysTables.Name = @TableName and SysColumns.name like @ColumnName + '%'

				-- print @ColumnExists

				-- Create the field if it not exists
				If (@ColumnExists = -1) 
					Begin 
						Set @SQL = 'ALTER TABLE [dbo].['+@TableName+'] Add ['+@ColumnName+'_gk] bigint NULL , ['+@ColumnName+'_type] int NULL';			
						-- Print @SQL;
						Exec (@SQL);
					End	 
			End
				-- Increase the index by 1
				Set @ColumnIndex += 1
End -- of while loop

	
END