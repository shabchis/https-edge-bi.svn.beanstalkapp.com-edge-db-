using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
	[Microsoft.SqlServer.Server.SqlFunction]
	public static SqlString ConvertFromBase64CLR(SqlString toDecode)
	{
		byte[] DecodedBytes = System.Convert.FromBase64String(toDecode.ToString());
		SqlString returnValue = System.Text.ASCIIEncoding.ASCII.GetString(DecodedBytes);
		return returnValue;
	}

	[Microsoft.SqlServer.Server.SqlFunction]
	public static SqlString ConvertToBase64CLR(SqlString toEncode)
	{
		byte[] toEncodeAsBytes = System.Text.ASCIIEncoding.ASCII.GetBytes(toEncode.ToString());
		SqlString returnValue = System.Convert.ToBase64String(toEncodeAsBytes);
		return returnValue;
	}
}
