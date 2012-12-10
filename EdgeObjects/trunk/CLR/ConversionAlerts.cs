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
using Microsoft.AnalysisServices.AdomdClient;

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

		public campaign(AdomdDataReader mdxReader, string convSqlField)
		{

			//SqlContext.Pipe.Send(string.Format("Fields count = {0}", mdxReader.FieldCount));
			//for (int i = 0; i < mdxReader.FieldCount; i++)
			//{
			//    SqlContext.Pipe.Send(string.Format("{0}=========================================", i));
			//    //SqlContext.Pipe.Send(mdxReader[i] == DBNull.Value ? "0" : mdxReader[i].ToString());
			//    SqlContext.Pipe.Send(mdxReader.GetName(i));
			//}

			//[Getways Dim].[Gateways].[Campaign]
			//ID = Convert.ToInt32(mdxReader["[Paid Campaigns Dim].[Campaign Gk]"]);
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
	public static void ConversionPPCAlerts(Int32 AccountID, Int32 Period, DateTime ToDay, Int32 ChannelID, Int32 threshold, string excludeIds, string convSqlField, out SqlString returnMsg)
	{
		returnMsg = string.Empty;

		//string CONNECTION = "Data Source=BI_RND;Initial Catalog=testdb;Integrated Security=False;Pooling=False;";
		string Edge_conn = "Data Source=79.125.11.74;Initial Catalog=Seperia;Integrated Security=false;User ID=SeperiaServices;PWD=Asada2011!";

		string fromDate =ToDay.AddDays((Double)(-1 *Period)).ToString("yyyyMMdd");
		string toDate = ToDay.ToString("yyyyMMdd");

		try
		{
			string txtCmd = " select campaignid,campaign, sum(cost), sum(" + convSqlField + ") " +
							  "FROM [dbo].[Paid_API_AllColumns_v29] " +
							   "where account_id = @accountID " +
							  "and day_code between @fromDayCode and @toDayCode " +
							  "and channel_id = @channelID ";

			if (!string.IsNullOrEmpty(excludeIds))
			{
				txtCmd += string.Format("and campaignid NOT IN({0}) ", excludeIds);
			}

			txtCmd += string.Format("group by campaignid,campaign order by 3 ");

			SqlCommand cmd = new SqlCommand(txtCmd);
			SqlParameter accountID = new SqlParameter("@accountID", AccountID);
			SqlParameter fromDayCode = new SqlParameter("@fromDayCode", fromDate);
			SqlParameter toDayCode = new SqlParameter("@toDayCode", toDate);
			SqlParameter channelID = new SqlParameter("@channelID", ChannelID);
			cmd.Parameters.Add(accountID);
			cmd.Parameters.Add(fromDayCode);
			cmd.Parameters.Add(toDayCode);
			cmd.Parameters.Add(channelID);

			List<campaign> campaigns = new List<campaign>();

			using (SqlConnection conn = new SqlConnection(Edge_conn))
			{
				conn.Open();
				
				cmd.Connection = conn;
				cmd.CommandTimeout = 9000;
				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					while (reader.Read())
					{
						campaigns.Add(new campaign(reader));
					}
				}
			}

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
					, item.Name, item.Cost, item.Conv,item.ID,item.CPA));
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
		catch (Exception e)
		{
			throw new Exception("Could not get table data " + e.ToString(), e);
		}
		returnMsg = string.Format("<span style='font-size:9.5pt;font-family:Consolas;color:#A31515'>Worst CPA performance on the following time period : {0} - {1} . Criteria: CPA > 300% AVG CPA </span>", ToDay.AddDays(-1 * Period).ToString("dd/MM/yy"), ToDay.ToString("dd/MM/yy"));
		
	}

	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void ConversionAnalysisAlerts(Int32 AccountID, Int32 Period, DateTime ToDay, Int32 ChannelID, Int32 threshold, string excludeIds, string convName, string convSqlField, out SqlString returnMsg)
	{
		returnMsg = string.Empty;

		string admobConnectionString = "Data Source=BI_RND\\MSSQLSERVER2;Database=Seperia_Test";
		StringBuilder mdxBuilder = new StringBuilder();
		

		string fromDate = ToDay.AddDays((Double)(-1 * Period)).ToString("yyyyMMdd");
		string toDate = ToDay.ToString("yyyyMMdd");

		try
		{
			string cubeName = "BOEasyForexTest2";

			mdxBuilder.Append("Select {[Measures].[Cost], ");
			mdxBuilder.Append(string.Format("[Measures].[Cost/{0}],", convSqlField));
			mdxBuilder.Append(string.Format("[Measures].[{0}s]{1} on 0,", convSqlField,"}"));
			mdxBuilder.Append(" NonEmpty([Getways Dim].[Gateways].[Campaign].members) on 1 ");
			mdxBuilder.Append(string.Format("From {0} ", cubeName));
			mdxBuilder.Append(string.Format("where ( [Accounts Dim].[Accounts].[Account].&[{0}], ", AccountID.ToString()));
			mdxBuilder.Append(string.Format("[Channels Dim].[Channels].[Channel].&[{0}], ", ChannelID.ToString()));
			mdxBuilder.Append(string.Format("[Time Dim].[Time Dim].[Day].&[{0}]:[Time Dim].[Time Dim].[Day].&[{1}])", fromDate, toDate));

			List<campaign> campaigns = new List<campaign>();

			using (AdomdConnection adomdConn = new AdomdConnection(admobConnectionString))
			{
				
				adomdConn.Open();

				AdomdCommand mdxCmd = new AdomdCommand(mdxBuilder.ToString(), adomdConn);
				using (AdomdDataReader mdxReader = mdxCmd.ExecuteReader(CommandBehavior.CloseConnection))
				{
					while (mdxReader.Read())
					{
						campaigns.Add(new campaign(mdxReader, convSqlField));
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
