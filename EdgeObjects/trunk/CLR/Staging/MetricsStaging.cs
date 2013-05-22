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
	/// Perfrom metrics staging: insert all metrics table data into staging table
	/// </summary>
	/// <param name="accoutId"></param>
	/// <param name="deliveryTable"></param>
	/// <param name="stagingTable"></param>
    [Microsoft.SqlServer.Server.SqlProcedure]
	public static void MetricsStaging(SqlInt32 accoutId, SqlString deliveryTable, SqlString stagingTable, out SqlChars metricsSelect)
    {
		using (var connection = new SqlConnection("context connection=true"))
		{
			connection.Open();
			
			// pass all delivery parameters as parameters to SP
			var account = Convert.ToInt32(accoutId.ToString());
			var deliveryTableName = deliveryTable.ToString();
			var stagingTableName = stagingTable.ToString();

			try
			{
				metricsSelect = new SqlChars(EdgeViewer.StageMetrics(account, deliveryTableName, stagingTableName, connection));
			}
			catch (System.Exception ex)
			{
				// TODO: write to log in DB
				throw;
			}
		}
    }
}
