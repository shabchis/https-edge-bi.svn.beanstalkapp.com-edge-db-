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
	[Microsoft.SqlServer.Server.SqlProcedure]
    public static void IdentityI ()
    {
		using (var objectsConnection = new SqlConnection("context connection=true"))
		{
			using (var deliveryConnection = new SqlConnection("Server=localhost;Database=EdgeDeliveries;Integrated Security=SSPI"))
			{
				objectsConnection.Open();
				deliveryConnection.Open();

				var identityMng = new IdentityManager(deliveryConnection, objectsConnection);
				// pass all delivery parameters as parameters to SP
				identityMng.AccountId = 2;
				identityMng.TablePrefix = "2__20130403_144213_5f368d7f48490b6484bcc9482b730dba";

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
}
