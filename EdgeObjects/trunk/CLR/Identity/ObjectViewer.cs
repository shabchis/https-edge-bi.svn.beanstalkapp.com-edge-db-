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
    [Microsoft.SqlServer.Server.SqlProcedure]
	public static void ObjectViewer(SqlInt32 accout)
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			objectsConnection.Open();

			int accountId = Convert.ToInt32(accout.ToString());
			EdgeObjectConfigLoader.GetObjectsView(accountId, objectsConnection, SqlContext.Pipe);
		}
    }
}
