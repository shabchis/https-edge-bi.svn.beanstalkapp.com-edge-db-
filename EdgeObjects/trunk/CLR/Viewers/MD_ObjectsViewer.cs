//------------------------------------------------------------------------------
// <copyright file="CSSqlStoredProcedure.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using Edge.Data.Pipeline.Metrics.Indentity;

public partial class StoredProcedures
{
	/// <summary>
	/// Combine SELECT of relevant fields only per each edge type
	/// </summary>
	/// <param name="account"></param>
    [Microsoft.SqlServer.Server.SqlProcedure]
	public static void MD_ObjectsViewer(SqlInt32 account)
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			objectsConnection.Open();

			int accountId = Convert.ToInt32(account.ToString());
			EdgeViewer.GetObjectsView(accountId, objectsConnection, SqlContext.Pipe);
		}
    }
}
