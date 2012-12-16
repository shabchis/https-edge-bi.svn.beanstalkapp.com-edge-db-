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
using System.Collections.Generic;
using System.Linq;
using System.Text;


public partial class StoredProcedures
{
	public class campaign
	{
		public int ID;
		public string Name;
		public double Cost;
		public double Conv;
		public double CPA;
		public bool zeroConv = false;

		public campaign(SqlDataReader reader)
		{
			ID = Convert.ToInt32(reader[0]);
			Name = Convert.ToString(reader[1]);
			Cost = Convert.ToDouble(reader[2]);
			Conv = Convert.ToDouble(reader[3]);


			if (Conv != 0)
				CPA = Cost / Conv;
			else
			{
				zeroConv = true;
				Conv = 1;
				CPA = Cost;
			}
		}

		public campaign(SqlDataReader mdxReader, string convSqlField)
		{
			Name = Convert.ToString(mdxReader[1]);
			SqlContext.Pipe.Send(string.Format("Name = {0}", Name));

			Cost = Convert.ToDouble(mdxReader[2]);
			SqlContext.Pipe.Send(string.Format("Cost = {0}", Cost));

			CPA = Convert.ToDouble(mdxReader[3]);
			SqlContext.Pipe.Send(string.Format("CPA = {0}", CPA));

			Conv = Convert.ToDouble(mdxReader[4]);
			SqlContext.Pipe.Send(string.Format("Conv = {0}", Conv));


		}
		public double GetConvIncludZero()
		{
			if (zeroConv) return 0;
			else
				return this.Conv;
		}


	}

	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void CLR_Alerts_ConversionAnalysis(Int32 AccountID, Int32 Period, DateTime ToDay, Int32 ChannelID, Int32 threshold, string excludeIds, string cubeName, string convSqlField, out SqlString returnMsg)
	{
		returnMsg = string.Empty;

		//string admobConnectionString = "Data Source=BI_RND\\MSSQLSERVER2;Database=Seperia_Test";
		

		#region Exclude
		StringBuilder excludeBuilder = new StringBuilder();
		string excludeSyntax = "[Getways Dim].[Gateways].[Campaign].&[{0}]";
		if (!string.IsNullOrEmpty(excludeIds))
			foreach (string id in excludeIds.Split(','))
			{
				excludeBuilder.Append(string.Format(excludeSyntax, id));
				excludeBuilder.Append(",");
			}
		if (excludeBuilder.Length > 0)
			excludeSyntax.Remove(excludeBuilder.Length - 1, 1);
		#endregion


		string fromDate = ToDay.AddDays((Double)(-1 * Period)).ToString("yyyyMMdd");
		string toDate = ToDay.ToString("yyyyMMdd");

		try
		{
			StringBuilder withMdxBuilder = new StringBuilder();
			withMdxBuilder.Append("With Set [ [Filtered Campaigns] As '");
			withMdxBuilder.Append("{" + excludeBuilder.ToString() + "}'");

			StringBuilder selectMdxBuilder = new StringBuilder();
			selectMdxBuilder.Append("Select {[Measures].[Cost], ");
			selectMdxBuilder.Append(string.Format("[Measures].[Cost/{0}],", convSqlField));
			selectMdxBuilder.Append(string.Format("[Measures].[{0}s]{1} on 0,", convSqlField, "}"));
			selectMdxBuilder.Append(" NonEmpty([Getways Dim].[Gateways].[Campaign].members) on Columns ");
			selectMdxBuilder.Append("{ NonEmpty ( {HIERARCHIZE ( Except ( {[Getways Dim].[Gateways].[Campaign].Allmembers}, [Filtered Campaigns] )  ) })} On Rows ");

			StringBuilder fromMdxBuilder = new StringBuilder();
			fromMdxBuilder.Append(string.Format("From {0} ", cubeName));
			fromMdxBuilder.Append(string.Format("where ( [Accounts Dim].[Accounts].[Account].&[{0}], ", AccountID.ToString()));
			fromMdxBuilder.Append(string.Format("[Channels Dim].[Channels].[Channel].&[{0}], ", ChannelID.ToString()));
			fromMdxBuilder.Append(string.Format("[Time Dim].[Time Dim].[Day].&[{0}]:[Time Dim].[Time Dim].[Day].&[{1}])", fromDate, toDate));

			List<campaign> campaigns = new List<campaign>();

			SqlCommand command = new SqlCommand("dbo.SP_ExecuteMDX");
			command.CommandType = CommandType.StoredProcedure;
			SqlParameter withMDX = new SqlParameter("WithMDX", withMdxBuilder.ToString());
			command.Parameters.Add(withMDX);
			
			SqlParameter selectMDX = new SqlParameter("SelectMDX", selectMdxBuilder.ToString());
			command.Parameters.Add(selectMDX);

			SqlParameter fromMDX = new SqlParameter("FromMDX", fromMdxBuilder.ToString());
			command.Parameters.Add(fromMDX);

			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				using (SqlDataReader reader = command.ExecuteReader(CommandBehavior.CloseConnection))
				{
					while (reader.Read())
					{
						campaigns.Add(new campaign(reader, convSqlField));
					}
				}
			}


			if (campaigns.Count > 0)
			{
				double totalCost = 0;
				double totalConv = 0;
				double avgCpa = 0;

				foreach (campaign camp in campaigns)
				{
					totalCost += camp.Cost;
					totalConv += camp.GetConvIncludZero();
				}

				avgCpa = totalCost / totalConv;
				SqlContext.Pipe.Send(string.Format("The AVG CPA is {0}", avgCpa));

				var CPA_Alert = from c in campaigns
								where c.CPA > threshold * avgCpa
								select c;

				StringBuilder commandBuilder = new StringBuilder();

				foreach (var item in CPA_Alert)
				{
					commandBuilder.Append(string.Format("select '{3}' as CampaignID, '{0}' as 'Campaign' , {1} as 'Cost', {2} as 'Conv' ,{4} as 'CPA' Union "
						, item.Name, item.Cost, item.Conv, item.ID, item.CPA));
				}

				if (commandBuilder.Length > 0)
				{
					commandBuilder.Remove(commandBuilder.Length - 6, 6);
					SqlCommand reasultsCmd = new SqlCommand(commandBuilder.ToString());
					using (SqlConnection conn2 = new SqlConnection("context connection=true"))
					{
						conn2.Open();
						reasultsCmd.Connection = conn2;
						reasultsCmd.CommandTimeout = 9000;
						using (SqlDataReader reader = reasultsCmd.ExecuteReader())
						{
							SqlContext.Pipe.Send(reader);
						}
					}
				}

			}

		}
		catch (Exception e)
		{
			throw new Exception(".Net Exception : " + e.ToString(), e);
		}
		returnMsg = string.Format("<span style='font-size:9.5pt;font-family:Consolas;color:#A31515'>Worst CPA performance on the following time period : {0} - {1} . Criteria: CPA > 300% AVG CPA </span>", ToDay.AddDays(-1 * Period).ToString("dd/MM/yy"), ToDay.ToString("dd/MM/yy"));

	}
}
