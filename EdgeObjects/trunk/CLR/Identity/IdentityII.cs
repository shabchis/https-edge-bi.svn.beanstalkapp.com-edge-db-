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
using log4net;

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
			using (var deliveryConnection = new SqlConnection("Server=localhost;Database=EdgeDeliveries;Integrated Security=SSPI"))
			{
				objectsConnection.Open();
				deliveryConnection.Open();

				var identityMng = new IdentityManager(deliveryConnection, objectsConnection);
				// pass all delivery parameters as parameters to SP
				identityMng.AccountId = Convert.ToInt32(accoutId.ToString());
				identityMng.TablePrefix = deliveryTablePrefix.ToString();
				identityMng.CreateNewEdgeObjects = Convert.ToBoolean(createNewEdgeObjects.ToString());
				identityMng.TransformTimestamp = Convert.ToDateTime(identity1Timestamp.ToString());

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
}
