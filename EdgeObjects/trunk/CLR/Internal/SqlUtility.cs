using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data.SqlClient;
using System.Data;

namespace Edge.Core.Utilities
{
	// TODO: use Edge.Core.Utilities project
	public static class SqlUtility
	{
		public static object SqlValue(object obj, object nullValue, Func<object> valueFunc = null)
		{
			if (Object.Equals(obj, null) || Object.Equals(obj, nullValue))
				return DBNull.Value;
			else
				return valueFunc == null ? obj : valueFunc();
		}

		public static object SqlValue(object obj, Func<object> valueFunc = null)
		{
			return SqlValue(obj, null, valueFunc);
		}

		public static T ClrValue<T>(object dbValue) where T : class
		{
			return dbValue is DBNull ? null : (T)dbValue;
		}

		public static T ClrValue<T>(object dbValue, T emptyVal)
		{
			return dbValue is DBNull ? emptyVal : (T)dbValue;
		}

		public static T ClrValue<R, T>(object dbValue, Func<R, T> convertFunc, T emptyVal)
		{
			return dbValue is DBNull ? emptyVal : convertFunc((R)dbValue);
		}

		public static T Get<T>(this IDataRecord reader, string field, T nullVal = default(T))
		{
			var val = reader[field];
			if (val is DBNull)
				return nullVal;
			else
				return (T)val;
		}

		public static ConvertT Convert<SourceT, ConvertT>(this IDataRecord reader, string field, Func<SourceT, ConvertT> convertFunc, SourceT nullVal = default(SourceT))
		{
			SourceT val = reader.Get<SourceT>(field, nullVal);
			return convertFunc(val);
		}

		public static bool IsDBNull(this IDataRecord reader, params string[] fields)
		{
			bool isnull = true;
			for (int i = 0; i < fields.Length; i++)
				isnull &= reader[fields[i]] is DBNull;
			return isnull;
		}
	}
}