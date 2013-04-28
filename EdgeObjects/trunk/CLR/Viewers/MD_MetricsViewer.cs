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
	/// Build Metics SELECT to fill Staging Metrics from Delivery Metrics (JOIN all delivery objects by TKs)
	/// </summary>
	/// <param name="account"></param>
	/// <param name="deliveryTableName"></param>
	/// <param name="metricsSelect"></param>
    [Microsoft.SqlServer.Server.SqlProcedure]
	public static void MD_MetricsViewer(SqlInt32 account, SqlString deliveryTableName, out SqlChars metricsSelect)
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			objectsConnection.Open();
			int accountId = Convert.ToInt32(account.ToString());
			metricsSelect = new SqlChars(EdgeViewer.GetMetricsView(accountId, deliveryTableName.ToString(), objectsConnection));
		}
    }
}
