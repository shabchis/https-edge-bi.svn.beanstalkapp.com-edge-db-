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
using Edge.Data.Objects;

public partial class StoredProcedures
{
	/// <summary>
	/// Identity stage II: update EdgeObject DB (staging) with edge object from Delivery DB
	/// using LOCK on EdgeObject table:
	/// * sync last changes according transform timestamp
	/// * update modified EdgeObjects --> IdentityStatus = Modified
	/// * insert new EdgeObjects --> IdentityStatus = New
	/// * find best match staging table
	/// * insert delivery metrics into staging metrics table
	/// </summary>
	// TODO: Pass only one parameter DeliveryID and load delivery from DB
	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void IdentityII(SqlInt32 accoutId, SqlString deliveryTablePrefix, SqlDateTime identity1Timestamp, SqlBoolean createNewEdgeObjects)
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			objectsConnection.Open();
			var identityMng = new IdentityManager(objectsConnection);
			
			// pass all delivery parameters as parameters to SP
			identityMng.AccountId = Convert.ToInt32(accoutId.ToString());
			identityMng.TablePrefix = deliveryTablePrefix.ToString();
			identityMng.CreateNewEdgeObjects = Convert.ToBoolean(createNewEdgeObjects.ToString());
			identityMng.TransformTimestamp = Convert.ToDateTime(identity1Timestamp.ToString());

			identityMng.Log(string.Format("Starting Identity II, parameters: accountId={0}, delivery table prefix='{1}', identity I timestamp={2}, create new delivery objects={3}",
										   accoutId, deliveryTablePrefix, identityMng.TransformTimestamp.ToString("dd/MM/yyyy HH:mm:ss"), identityMng.CreateNewEdgeObjects));
			try
			{
				identityMng.UpdateEdgeObjects();
			}
			catch (System.Exception ex)
			{
				// TODO: write to log in DB
				throw;
			}
		}
    }
}
