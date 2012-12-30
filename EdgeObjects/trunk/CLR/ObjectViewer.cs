using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Reflection;
using System.Text;
using Eggplant.Entities.Model;
using Eggplant.Entities.Persistence;
using Edge.Core.Utilities;
using Edge.Data.Objects;
using Microsoft.SqlServer.Server;
using Eggplant.Entities.Cache;

public partial class StoredProcedures
{
	[Microsoft.SqlServer.Server.SqlProcedure]

	public static void EdgeTypes_Get(SqlInt32 accountID, SqlInt32 channelID)
	{
		using (SqlConnection connection = new SqlConnection("context connection=true"))
		{
			// TODO: convert to eggplant query EdgeType.Queries.Get
			var command = new SqlCommand(@"
				select
					TypeID,
					ClrType,
					Name,
					IsAbstract,
					TableName,
					AccountID,
					ChannelID
				from
					EdgeType
				where
					AccountID in (-1, @accountID) and
					ChannelID in (-1, channelID)"
			, connection);

			var cache = new EntityCacheManager();

			using (SqlDataReader reader = command.ExecuteReader())
			{
				while (reader.Read())
				{
					if (reader.Get<bool>("IsAbstract"))
						continue;

					// Get the actual type
					Type clrType = Type.GetType(reader.Get<string>("ClrType"));
					string[] fields = MappingMetaData.ForType(clrType, cache);
					
					//SqlContext.Pipe.Send();
				}
			}
		}
	}
}

	#if SHAY
	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void GetTablesList(SqlInt32 accountID, SqlInt32 channelID)
	{
		try
		{
				var sb = new StringBuilder();

				foreach (Type type in typeof(EdgeObject).Assembly.GetTypes())
				{
					if (!type.Equals(typeof(Segment)) && !type.IsAbstract)
					{


						if (type.IsSubclassOf(typeof(EdgeObject)))
						{
							StringBuilder select = new StringBuilder();
							string from = string.Empty;
							StringBuilder where = new StringBuilder();

							//Setting Select statement
							foreach (var field in mapper.GetFields(type))
							{
								select.Append(string.Format("[{0}] as [{1}], ", field.Value, field.Key));
							}
							select.Remove(select.Length - 1, 1);

							//Get table name from class attribute
							string tableName = ((TableInfoAttribute)Attribute.GetCustomAttribute(type, typeof(TableInfoAttribute))).Name;
							where = where.Append(string.Format("AccountID ={0} AND ObjectType=''{1}''", accountID, type.Name));
							
							//setting From statement
							from = GetTableSource(type);

							sb.Append(string.Format("SELECT '{0}' as TableName,'{1}' as [select],'{2}' as [From], '{3}' as [Where] Union ", tableName, select, from, where));
						}

						//Getting Other tables such as - Channel, Account ...
						else if (((TableInfoAttribute)Attribute.GetCustomAttribute(type, typeof(TableInfoAttribute))) != null)
						{
							StringBuilder select = new StringBuilder();
							string from = string.Empty;
							StringBuilder where = new StringBuilder();

							//Setting Select statement
							foreach (var field in mapper.GetFields(type))
							{
								select.Append(string.Format("[{0}] as [{1}], ", field.Value, field.Key));
							}
							//setting Where statement
							where = where.Append(string.Format("AccountID in(-1,{0}) AND ObjectType=''{1}''", accountID, type.Name));
							string tableName = ((TableInfoAttribute)Attribute.GetCustomAttribute(type, typeof(TableInfoAttribute))).Name;
							from = tableName;
							sb.Append(string.Format("SELECT '{0}' as TableName,'{1}' as [select],'{2}' as [From], '{3}' as [Where] Union ", tableName, select, from, where));
						}
					}
				}


				//Getting data from connection definition table
				
				List<ConnectionDef> accountConnections = GetConnections(accountID.Value, channelID.Value);
				foreach (ConnectionDef connection in accountConnections)
				{
					StringBuilder select = new StringBuilder();
					string fromTable = string.Empty;
					StringBuilder where = new StringBuilder();

					Type type = GetTypeByTableName(connection.BaseValue);
					
					//Setting Select statement
					foreach (var field in mapper.GetFields(type))
					{
						select.Append(string.Format("[{0}] as [{1}], ", field.Value, field.Key));
					}

					//setting Where statement

					if (type.IsSubclassOf(typeof(Segment)))
					{
						string ConnectionDefinitionIDField = mapper.GetSqlTargetMapFieldName(type, "ConnectionDefinitionID");
						where = where.Append(string.Format("AccountID in(-1,{0}) AND ObjectType=''{1}'' AND {2}={3}", accountID, typeof(Segment).Name, ConnectionDefinitionIDField, connection.ID));
					}
					else
					{
						where = where.Append(string.Format("AccountID ={0} AND ObjectType=''{1}''", accountID, type.Name));
					}

					fromTable = GetTableSource(type);
					sb.Append(string.Format("SELECT '{0}' as TableName,'{1}' as [select],'{2}' as [From], '{3}' as [Where] Union ", connection.Name, select, fromTable, where));
					
				}
				sb.Remove(sb.Length - 6, 6);

				SqlCommand cmd = new SqlCommand(sb.ToString());
				using (SqlConnection conn = new SqlConnection("context connection=true"))
				{
					conn.Open();
					cmd.Connection = conn;
					using (SqlDataReader reader = cmd.ExecuteReader())
					{
						SqlContext.Pipe.Send(reader);
					}
				}
			
		}

		catch (Exception e)
		{
			throw new Exception("Could not get table list from data object data base " + e.ToString(), e);
		}
	}

	[Microsoft.SqlServer.Server.SqlProcedure]
	public static void GetTableStructureByName(SqlString virtualTableName)
	{
		try
		{
			DummyMapper mapper = new DummyMapper();
			string classNamespace = typeof(Creative).Namespace;

			Type type = GetTypeByTableName(virtualTableName.Value);

			//Creating Select by Dummy table name
			StringBuilder col = new StringBuilder();
			#region Members
			/*******************************************************/

			Dictionary<string, string> tableStructure = GetSqlTableStructure(type);

			foreach (MemberInfo member in type.GetMembers())
			{
				if (IsRelevant(member))
				{
					string sql_name = string.Empty;
					string sql_type = string.Empty;
					string dotNet_name = string.Empty;
					string dotNet_type = string.Empty;
					string display = string.Empty;
					bool isEnum = false;

					string memberNamespace = string.Empty;
					MemberTypes memberType = member.MemberType;
					//Get MemberName
					if (member.MemberType.Equals(MemberTypes.Field))
						memberNamespace = ((FieldInfo)(member)).FieldType.Namespace;
					else
						memberNamespace = ((PropertyInfo)(member)).PropertyType.Namespace;

					//Verify that memeber is class member of Edge.Data.Object
					if (memberNamespace == typeof(EdgeObject).Namespace || memberNamespace.StartsWith(classNamespace + "."))//Memeber is class member from Edge.Data.Object
					{
						//Getting Enum Types
						if ((((FieldInfo)(member)).FieldType).BaseType == typeof(Enum))
						{
							sql_name = member.Name;
							sql_type = tableStructure[mapper.GetSqlTargetMapFieldName(type, member.Name)];
							dotNet_name = member.Name;
							//dotNet_type = ((MemberInfo)(((FieldInfo)(member)).FieldType)).Name;
							dotNet_type = member.ReflectedType.Name;
							display = string.Format("{0} {1}", dotNet_name, sql_type);
							isEnum = true;
						}

						//else if (member.MemberType.Equals(MemberTypes.Field)) //ID
						//{
						//    sql_name = member.Name + "ID";
						//    dotNet_name = member.Name + ".ID";
						//    sql_type = tableStructure[sql_name];
						//    isEnum = false;
						//}
						//else //GK
						//{
						//    sql_name = member.Name + "GK";
						//    dotNet_name = member.Name + ".GK";
						//    sql_type = tableStructure[sql_name];
						//    isEnum = false;
						//}

						//dotNet_type = member.ReflectedType.Name;
						//display = string.Format("{0} {1}", sql_name, sql_type);


						//Getting Types that are not Enum  but member of Edge.Data.Object
						if ((((FieldInfo)(member)).FieldType).BaseType != typeof(Enum))
						{
							sql_name = member.Name + "ID";
							dotNet_name = member.Name + ".ID";
							if (!tableStructure.TryGetValue(sql_name, out sql_type))
							{
								sql_name = member.Name + "GK";
								dotNet_name = member.Name + ".GK";
								sql_type = tableStructure[sql_name];
							}
							//sql_type = tableStructure.TryGetValue(sql_name);

							//dotNet_type = ((MemberInfo)(((FieldInfo)(member)).FieldType)).Name;
							dotNet_type = member.ReflectedType.Name;
							display = string.Format("{0} {1}", sql_name, sql_type);
						}


					}

					else
					{//Incase that memeber is not class member of Edge.Data.Object for ex. Budget
						sql_name = mapper.GetSqlTargetMapFieldName(type, member.Name);
						sql_type = tableStructure[sql_name];
						dotNet_name = member.Name;
						//dotNet_type = ((MemberInfo)(((FieldInfo)(member)).FieldType)).Name;
						dotNet_type = member.ReflectedType.Name;
						display = string.Format("{0} {1}", dotNet_name, sql_type);
					}

					//Creating sql select query
					if (!string.IsNullOrEmpty(sql_name))
						col.Append(string.Format(" Select '{0}' as 'SQL Name', '{1}' as 'SQL Type', '{2}' as '.Net Name', '{3}' as '.Net Type', '{4}' as 'Display Name', '{5}' as 'IsEnum' Union ",
														sql_name,
														sql_type,
														dotNet_name,
														dotNet_type,
														display,
														isEnum
													)
									  );
				}
			}

			if (col.Length > 0)
			{
				//Removing last "union string"
				col.Remove(col.Length - 6, 6);

				//Creating SQL command 
				SqlCommand cmd = new SqlCommand(col.ToString());

				try
				{
					using (SqlConnection conn = new SqlConnection("context connection=true"))
					{
						conn.Open();
						cmd.Connection = conn;

						using (SqlDataReader reader = cmd.ExecuteReader())
						{
							SqlContext.Pipe.Send(reader);
						}
					}
				}
				catch (Exception e)
				{
					throw new Exception("Could not get table data - GetTableStructureByName() " + e.ToString(), e);
				}
			}

			/****************************************************************/

			#endregion
		}
		catch (Exception ex)
		{
			SqlContext.Pipe.Send(ex.Message);
		}
	}

	static string CONN_STRING = "Data Source=BI_RND;Initial Catalog=EdgeObjects;Integrated Security=True;Pooling=False";

	private static List<ConnectionDef> GetConnections(int accountID, int ChannelID)
	{

		List<ConnectionDef> connections = new List<ConnectionDef>();

		StringBuilder cmdSb = new StringBuilder();
		cmdSb.Append("Select [ID],[Name],[BaseValueType] from ConnectionDefinition where ");

		if (accountID != null)
			cmdSb.Append(" AccountID = @accountID and ");

		if (accountID != null)
		{
			cmdSb.Append(" ChannelID = @channelID");
		}

		SqlCommand cmd = new SqlCommand(cmdSb.ToString());

		SqlParameter sql_account = new SqlParameter("@accountID", accountID);
		SqlParameter sql_ChannelID = new SqlParameter("@channelID", ChannelID);

		cmd.Parameters.Add(sql_account);
		cmd.Parameters.Add(sql_ChannelID);

		try
		{
			using (SqlConnection conn = new SqlConnection(CONN_STRING))
			{
				conn.Open();
				cmd.Connection = conn;

				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					while (reader.Read())
					{
						connections.Add(new ConnectionDef(reader));
					}
				}
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not get table data - GetConnectionDefinitionBaseValueType() " + e.ToString(), e);
		}

		return connections;
	}
	private static string GetTableSource(Type type)
	{
		if (type.IsSubclassOf(typeof(Ad)) || type.Equals(typeof(Ad)))
			return typeof(Ad).Name;

		else if (type.IsSubclassOf(typeof(Target)) || type.Equals(typeof(Target)))
			return typeof(Target).Name;

		else if (type.IsSubclassOf(typeof(Creative)) || type.Equals(typeof(Creative)))
			return typeof(Creative).Name;

		else if (type.IsSubclassOf(typeof(ConnectionDefinition)) || type.Equals(typeof(ConnectionDefinition)))
			return typeof(ConnectionDefinition).Name;

		else if (type.IsSubclassOf(typeof(CompositeCreative)) || type.Equals(typeof(CompositeCreative)))
			return typeof(CompositeCreative).Name;

		else return typeof(EdgeObject).Name;
	}
	private static Type GetTypeByTableName(string virtualTableName)
	{

		string sqlAssembly = typeof(Creative).Assembly.FullName;
		string classNamespace = typeof(Creative).Namespace;

		Type type = Type.GetType(string.Format("{0}.{1},{2}", classNamespace, virtualTableName, sqlAssembly));

		//Get type from Attribute table name
		#region Try Get Type from Attribute
		/************************************************/
		if (type == null) // Unrecognized type name ( ex. TargetKeyword )
		{
			var assemblyNestedTypes = from t in Assembly.GetAssembly(typeof(Creative)).GetTypes()
									  where t.IsClass && t.Namespace == classNamespace
									  select t;

			foreach (Type t in assemblyNestedTypes)
			{
				TableInfoAttribute tableInfo = (TableInfoAttribute)Attribute.GetCustomAttribute(t, typeof(TableInfoAttribute));
				if (tableInfo != null && tableInfo.Name == virtualTableName)
				{
					type = t;
				}
			}
		}

		/************************************************/
		#endregion


		//Get type from Meta Property Name
		#region Try Get Type from Connection Table
		/************************************************/
		if (type == null) // still Unrecognized type name ( ex. color )
		{
			Int32 connectionDefinitionID = 0;
			string baseValueType = GetConnectionDefinitionBaseValueType(virtualTableName, SqlInt32.Null, out connectionDefinitionID);

			if (!string.IsNullOrEmpty(baseValueType))
				type = Type.GetType(string.Format("{0}.{1},{2}", classNamespace, baseValueType, sqlAssembly));
			/************************************************/
		#endregion
		}

		return type;
	}
	private static bool IsRelevant(MemberInfo member)
	{
		if (member.MemberType != MemberTypes.Field && member.MemberType != MemberTypes.Property)
			return false;

		if (member.DeclaringType != typeof(EdgeObject) && !member.DeclaringType.IsSubclassOf(typeof(EdgeObject)))
			return false;

		if (member.Name == "Connections" || member.Name == "ConnectionDefinition" || member.Name == "HasChildsObjects") return false;
		//else if (member.MemberType == MemberTypes.Constructor || member.MemberType == MemberTypes.Method)
		//    return false;
		else
			return true;
	}
	private static Dictionary<string, string> GetSqlTableStructure(Type type)
	{
		Dictionary<string, string> structure = new Dictionary<string, string>();
		string dbtableName = string.Empty;

		if (type.Equals(typeof(Ad)))
			dbtableName = typeof(Ad).Name;

		else if (type != null)
		{
			//Check if subclass of creative / Target / EdgeObject
			if (type.IsSubclassOf(typeof(Creative)))
			{
				dbtableName = typeof(Creative).Name;
			}
			else if (type.IsSubclassOf(typeof(Target)))
			{
				dbtableName = typeof(Target).Name;
			}
			else if (type.IsSubclassOf(typeof(EdgeObject)))
			{
				dbtableName = typeof(EdgeObject).Name;
			}

		}
		else // EdgeObject Type
		{
			//isMetaProperty = true;
			dbtableName = typeof(EdgeObject).Name;
		}


		SqlCommand cmd = new SqlCommand("select COLUMN_NAME , DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION, NUMERIC_SCALE, IS_NULLABLE from information_schema.COLUMNS where TABLE_NAME = @tableName");
		SqlParameter tableName = new SqlParameter("@tableName", dbtableName);

		cmd.Parameters.Add(tableName);

		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				cmd.Connection = conn;

				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					while (reader.Read())
					{
						string TYPE = reader[1].ToString();
						string CHARACTER_MAXIMUM_LENGTH = reader[2] == DBNull.Value ? string.Empty : reader[2].ToString();
						string NUMERIC_PRECISION = reader[3] == DBNull.Value ? string.Empty : reader[3].ToString();
						string NUMERIC_SCALE = reader[4] == DBNull.Value ? string.Empty : reader[4].ToString();
						string IS_NULLABLE = reader[5].ToString().Equals("YES") ? "NULL" : "NOT NULL";

						List<string> properties = new List<string>();
						if (!String.IsNullOrEmpty(CHARACTER_MAXIMUM_LENGTH))
							properties.Add(CHARACTER_MAXIMUM_LENGTH);

						if (TYPE.Equals("decimal"))
						{
							properties.Add(NUMERIC_PRECISION);
							properties.Add(NUMERIC_SCALE);
						}


						StringBuilder sbType = new StringBuilder();
						sbType.Append(TYPE);
						if (properties.Count > 0)
						{
							sbType.Append("(");
							foreach (string prop in properties)
							{
								sbType.Append(prop + ",");
							}
							sbType.Remove(sbType.Length - 1, 1);
							sbType.Append(")");
						}

						sbType.Append(" " + IS_NULLABLE);
						structure.Add(reader[0].ToString(), sbType.ToString());
					}
				}
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not get table data : GetSqlTableStructure()" + e.ToString(), e);
		}

		return structure;
	}
	private static string GetConnectionDefinitionBaseValueType(string connectionDefinitionName, SqlInt32 accountID, out Int32 connectionDefinitionNameID)
	{

		string connectionDefinitionBaseValueType = string.Empty;

		connectionDefinitionNameID = 0;
		StringBuilder cmdSb = new StringBuilder();
		cmdSb.Append("Select [ID], [BaseValueType] from ConnectionDefinition where ");

		if (!accountID.IsNull)
			cmdSb.Append(" AccountID = @accountID and ");

		cmdSb.Append(" Name = @connectionDefinitionName");

		SqlCommand cmd = new SqlCommand(cmdSb.ToString());

		SqlParameter sql_account = new SqlParameter("@accountID", accountID);
		SqlParameter sql_connectionDefinitionName = new SqlParameter("@connectionDefinitionName", connectionDefinitionName);

		cmd.Parameters.Add(sql_account);
		cmd.Parameters.Add(sql_connectionDefinitionName);

		try
		{
			using (SqlConnection conn = new SqlConnection("context connection=true"))
			{
				conn.Open();
				cmd.Connection = conn;

				using (SqlDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						connectionDefinitionBaseValueType = reader[1].ToString();
						connectionDefinitionNameID = Convert.ToInt32(reader[0]);
					}
				}
			}
		}
		catch (Exception e)
		{
			throw new Exception("Could not get table data - GetConnectionDefinitionBaseValueType() " + e.ToString(), e);
		}

		return connectionDefinitionBaseValueType;
	}




}


#endif