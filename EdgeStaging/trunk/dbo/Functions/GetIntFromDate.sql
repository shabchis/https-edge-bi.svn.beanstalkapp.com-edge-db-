Create Function dbo.GetIntFromDate(@fromDate datetime)
Returns Int As Begin
	Return Cast(Replace(Convert(varchar(10), @fromDate, 120), '-', '') As int)
End