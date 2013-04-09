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
using System.Collections.Generic;
using System.Linq;
using Edge.Data.Objects;
using System.Security;

public partial class StoredProcedures
{
	/// <summary>
	/// Identity stage I: update delivery objects with existing in EdgeObject DB object GKs 
	/// tag Delivery objects by IdentityStatus (New, Modified or Unchanged)
	/// </summary>
	// TODO: Pass only one parameter DeliveryID and load delivery from DB
	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void IdentityI(SqlInt32 accoutId, SqlString deliveryTablePrefix, SqlDateTime identity1Timestamp, SqlBoolean createNewEdgeObjects)
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			objectsConnection.Open();
			var identityMng = new IdentityManager(objectsConnection);
			
			// pass all delivery parameters as parameters to SP
			identityMng.AccountId = Convert.ToInt32(accoutId.ToString());
			identityMng.TablePrefix = deliveryTablePrefix.ToString();

			identityMng.Log(string.Format("Starting Identity I, parameters: accountId={0}, delivery table prefix='{1}'", accoutId, deliveryTablePrefix));
			try
			{
				identityMng.IdentifyDeliveryObjects();
			}
			catch (System.Exception ex)
			{
				// TODO: write to log in DB
				throw;
			}
		}
    }
}
