
Create procedure [dbo].[Get_Delivery_tables]
 @TableInitial varchar(4000)
as
begin
-- the @TableInitial can be any table initial you want, but it must folow the table name.

Declare @TableInitialLen as int -- will be used for the left function

select @TableInitialLen = LEN(@TableInitial)

select	'DROP TABLE ' + name from sysobjects
where	type in ('U') 
and left(name,@TableInitialLen) = @TableInitial
end


