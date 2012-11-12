using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Reflection;
using System.Collections.Generic;
using Edge.Data.Objects;


public partial class StoredProcedures
{
	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void Enums_UpdateFromAssembly()
	{
		Dictionary<string, Dictionary<string, Int32>> EnumTypes = new Dictionary<string, Dictionary<string, int>>();
		EnumTypes = GetEnumTypesFromAssembly();

		foreach (var enumType in EnumTypes)
		{
			bool IsExists = IsEnumTableExists(enumType.Key);

			//If Table doesnt exists in DB
			if (!IsExists)
			{
				//CreateTable(tableName: enumType.Key);
				//InsertEnumValues(tableName: enumType.Key, values: enumType.Value);
				throw new Exception("Table doesnt exists in DB");
			}
			//IF TABLE EXISTS IN DB
			else 
			{
				//COMPARE EXSTING DATA TO NEW - CHECK CASES
				CompareWithExistingValues(enumType.Key,enumType.Value);
				DropExsitingTable(tableName: enumType.Key);
				CreateTable(tableName: enumType.Key);
				InsertEnumValues(tableName: enumType.Key, values: enumType.Value);
			}
		}

	}

	private static void CompareWithExistingValues(string tableName, Dictionary<string, int> NewEnumvalues)
	{
		Dictionary<string, Int32> ExistingEnumValues = GetEnumTypesFromDB(tableName);

		foreach (var row in NewEnumvalues)
		{
			if ( !ExistingEnumValues.ContainsKey(row.Key) || (row.Value != ExistingEnumValues[row.Key] ))
				throw new Exception (string.Format("mismatch has been found between enum {0} and table. check if enum table exists or new changed value",row.Key));
		}

	}

	private static Dictionary<string, Int32> GetEnumTypesFromDB(string tableName)
	{

		Dictionary<string, Int32> ExistingEnumValues = new Dictionary<string, int>();

		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				SqlCommand cmd =
					new SqlCommand(string.Format("SELECT [key],[value] FROM {0}", tableName));

				cmd.Connection = conn;
				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					while (reader.Read())
					{
						ExistingEnumValues.Add(Convert.ToString(reader[0]), Convert.ToInt32(reader[1]));
					}
				}
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not check exsiting of table: " + tableName, e);
		}

		return ExistingEnumValues;
	}

	private static void DropExsitingTable(string tableName)
	{
		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				SqlCommand cmd =
					new SqlCommand(string.Format("DROP TABLE {0}", tableName));
				cmd.Connection = conn;
				cmd.ExecuteNonQuery();
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not drop exsiting table.", e);
		}
	}
	private static void CreateTable(string tableName)
	{
		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				SqlCommand cmd =
					new SqlCommand(string.Format("CREATE TABLE {0}([Key] Nvarchar(200),[Value] int)", tableName));

				cmd.Connection = conn;
				cmd.ExecuteNonQuery();
			}
		}
		catch (Exception e)
		{
			throw new Exception(string.Format("Could not create table {0}.",tableName), e);
		}
	}
	private static void InsertEnumValues(string tableName, Dictionary<string, Int32> values)
	{
		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();


				string cmdTxt = string.Format("INSERT INTO {0} VALUES ", tableName);
				string val = string.Empty;

				//creating text values
				foreach (var pair in values)
				{
					val = string.Concat(val, string.Format("('{0}','{1}'),",pair.Key,pair.Value));
				}
				val = val.Remove(val.Length - 1); //removing last comma
				cmdTxt = string.Concat(cmdTxt, val);

				SqlCommand cmd =
					new SqlCommand(cmdTxt);
				
				cmd.Connection = conn; 
				cmd.ExecuteNonQuery();
			}
		}
		catch (Exception e)
		{
			throw new Exception(string.Format("Could insert values to table {0}.", tableName), e);
		}

	}
	private static Dictionary<string, Dictionary<string, int>> GetEnumTypesFromAssembly()
	{
		Dictionary<string, Dictionary<string, Int32>> EnumTypesDic = new Dictionary<string, Dictionary<string, int>>();

		//TO DO : GET ASSEMBLY FROM PARAM

		Assembly asbly = Assembly.GetAssembly(typeof(EdgeObject));
		foreach (Type type in asbly.GetTypes())
		{
			if (type.IsEnum)
			{
				MemberInfo[] typeInfo = type.GetMembers();

				EnumTypesDic.Add(type.Name, new Dictionary<string, Int32>());

				foreach (MemberInfo info in typeInfo)
				{
					if (info is FieldInfo)
					{
						string keyName = info.Name;

						if (keyName != "value__")
						{
							object value = ((FieldInfo)info).GetRawConstantValue();
							EnumTypesDic[type.Name].Add(keyName, Convert.ToInt32(value));
						}
					}
				}

			}
		}

		return EnumTypesDic;
	}
	private static bool IsEnumTableExists(string tableName)
	{
		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				SqlCommand cmd =
					new SqlCommand(string.Format("SELECT DISTINCT TABLE_NAME FROM information_schema.columns WHERE TABLE_SCHEMA ='dbo' and TABLE_NAME = '{0}'",tableName));

				cmd.Connection = conn;
				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
						return true;
					else
						return false;
				}
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not check exsiting of table: " + tableName, e);
		}
	}
};
