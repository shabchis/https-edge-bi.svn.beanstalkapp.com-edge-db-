
CREATE procedure [dbo].[Drop_Delivery_tables]
 @TableInitial varchar(4000)
as
begin
-- the @TableInitial can be any table initial you want, but it must folow the table name.
-- several examples:
-- If one wants to drop tables for specific delivery, the @TableInitial param should be: D1007_20110626_084743_82f1cbb6c5f74b58b65742368ab14f76
-- If one wants to drop tables for specific account and date, the @TableInitial param should be: D1007_20110626
-- If one wants to drop tables for specific account and date and hour, the @TableInitial param should be: D1007_20110627_08
-- If one wants to drop tables for specific account, the @TableInitial param should be: D1007
-- If one wants to drop all delivery tables, the @TableInitial param should be: D

Declare @DropCmd varchar(4000)
Declare @TableInitialLen as int -- will be used for the left function

-- for debug --set @TableInitial ='D7_20110627'

select @TableInitialLen = LEN(@TableInitial)

declare DropCommands2 cursor for 
	select	'DROP TABLE ' + name from sysobjects
	where	type in ('U') 
			and left(name,@TableInitialLen) = @TableInitial

open DropCommands2
	while 1=1
	begin
		fetch DropCommands2 into @DropCmd
		if @@fetch_status != 0 break
		print 'Executing: '+ (@DropCmd)
		exec(@DropCmd)				 -- dropping the table
		print 'Table Dropped :)'  
	end
close DropCommands2
deallocate DropCommands2


declare DropCommands3 cursor for 
	select	'DROP View ' + name from sysobjects
	where	type in ('V') 
			and left(name,@TableInitialLen) = @TableInitial

open DropCommands3
	while 1=1
	begin
		fetch DropCommands3 into @DropCmd
		if @@fetch_status != 0 break
		print 'Executing: '+ (@DropCmd)
		exec(@DropCmd)				 -- dropping the table
		print 'View Dropped :)'  
	end
close DropCommands3
deallocate DropCommands3

end


