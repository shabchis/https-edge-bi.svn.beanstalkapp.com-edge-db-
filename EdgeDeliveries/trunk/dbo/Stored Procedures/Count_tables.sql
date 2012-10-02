

CREATE procedure [dbo].[Count_tables]
 @TableInitial varchar(4000)
as
begin
-- the @TableInitial can be any table initial you want, but it must folow the table name.
Declare @CountCmd varchar(4000)
Declare @TableInitialLen as int -- will be used for the left function

-- for debug --set @TableInitial ='D7_20110627'

select @TableInitialLen = LEN(@TableInitial)

declare CountCommands cursor for 
	select	'Select count(*) as '+ SUBSTRING(Name,@TableInitialLen+1, 999) +' from ' + name 
			from sysobjects
			where	type in ('U','V')	
			and left(name,@TableInitialLen) = @TableInitial

open CountCommands
	while 1=1
	begin
		fetch CountCommands into @CountCmd
		if @@fetch_status != 0 break
		print 'Executing: '+ (@CountCmd)
		exec(@CountCmd)				 -- counting the table
		print ':)'  
	end
close CountCommands
deallocate CountCommands

end




