CREATE Function [dbo].[GetDateFromInt](@fromInt INT)
Returns datetime As Begin
	Return CONVERT (datetime,convert(char(8),@fromInt))
End