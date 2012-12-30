//------------------------------------------------------------------------------
// <copyright file="CSSqlClassFile.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Eggplant.Entities.Persistence;
using System.Reflection;
using Edge.Data.Objects;
using Eggplant.Entities.Cache;


public static class MappingMetaData
{
	public static string[] ForType(Type clrType, EntityCacheManager cache)
	{
		// Get the default mapping from the static nested 'Mappings' class
		Type mappingsContainer = clrType.GetNestedType("Mappings");
		var defaultMapping = (IMapping) mappingsContainer.GetField("Default", BindingFlags.Static).GetValue(null);
		if (defaultMapping == null)
			return null;

		var metadata = new MappingMetaDataChannel();
		MappingContext context = new MappingContext<object>(null, EdgeObjectsUtility.EntitySpace, metadata, cache);
		Recursive(defaultMapping, context);
		return metadata._called.ToArray();
	}

	static void Recursive(IMapping mapping, MappingContext context)
	{
		if (mapping is IActionMapping)
		{
			var actionMapping = (IActionMapping)mapping;
			actionMapping.Execute(context);
		}
		else if (!(mapping is ISubqueryMapping || mapping is IInlineMapping))
		{
			foreach (IMapping subMapping in mapping.SubMappings)
				Recursive(subMapping, context);
		}
	}
}

public class MappingMetaDataChannel: PersistenceChannel
{
	//Dictionary<string, string> _fieldMappings = new Dictionary<string,string>();
	//string _current = null;
	//string _field;

	public List<string> _called = new List<string>();

	/*
	public void Begin(string alias)
	{
		if (_current != null)
			throw new InvalidOperationException("Begin has already been called, call Accept() or Reject() first.");
		_current = alias;
	}

	public void Accept()
	{
		_fieldMappings[_current] = _field;
		_current = null;
	}
	
	public void Reject()
	{
		_current = null;
	}
	*/

	public override object GetField(string field)
	{
		//_field = field;
		_called.Add(field);
		return null;
	}

	public override void Dispose()
	{
	}

	/*
	public IEnumerable<KeyValuePair<string, string>> Mappings
	{
		get { return _fieldMappings.AsEnumerable(); }
	}
	*/

	public override void SetField(string field, object value)
	{
		throw new NotImplementedException();
	}
}



