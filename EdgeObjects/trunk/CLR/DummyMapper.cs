using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;

namespace Edge.Data.Objects
{
	public class DummyMapper
	{
		public Dictionary<Type, Dictionary<string, string>> Mapping;
		private Dictionary<string, string> EdgeObject;
		private Dictionary<string, string> TextCreative;
		private Dictionary<string, string> ImageCreative;
		private Dictionary<string, string> PlacementTarget;
		private Dictionary<string, string> KeywordTarget;
		private Dictionary<string, string> Segment;
		private Dictionary<string, string> Campaign;
		private Dictionary<string, string> Ad;
		private Dictionary<string, string> LandingPage;
		private Dictionary<string, string> AgeTarget;
		private Dictionary<string, string> GenderTarget;
		private Dictionary<string, string> Account;
		private Dictionary<string, string> Channel;
		private Dictionary<string, string> ChannelSpecificObject;
		private Dictionary<string, string> Target;
		private Dictionary<string, string> TargetMatch;
		private Dictionary<string, string> ConnectionDefinition;
		private Dictionary<string, string> SingleCreative;
		private Dictionary<string, string> Creative;
		private Dictionary<string, string> CompositeCreative;
		
		

		public DummyMapper()
		{
			Mapping = new Dictionary<Type, Dictionary<string, string>>();

			Target = new Dictionary<string, string>();
			Mapping.Add(typeof(Edge.Data.Objects.Target), Target);
			
			Creative = new Dictionary<string, string>();
			Mapping.Add(typeof(Edge.Data.Objects.Creative), Creative);
			
			SingleCreative = new Dictionary<string, string>();
			Mapping.Add(typeof(Edge.Data.Objects.SingleCreative), SingleCreative);

			CompositeCreative = new Dictionary<string, string>();
			Mapping.Add(typeof(Edge.Data.Objects.CompositeCreative), CompositeCreative);

			ConnectionDefinition = new Dictionary<string, string>()
				{
					{"ID","ID"},
					{"ConnectionName","Name"},
					{"AccountID","AccountID"},
					{"ChannelID","ChannelID"},
					{"BaseValueType","BaseValueType"}
				};
			Mapping.Add(typeof(Edge.Data.Objects.ConnectionDefinition), ConnectionDefinition);

			TargetMatch = new Dictionary<string, string>()
				{
					{"DestinationUrl","string_Field1"}
				};
			Mapping.Add(typeof(Edge.Data.Objects.TargetMatch), TargetMatch);

			ChannelSpecificObject = new Dictionary<string, string>()
				{
					{"OriginalID","OriginalID"},
					{"Status","Status"},
					{"ChannelID","ChannelID"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.ChannelSpecificObject), ChannelSpecificObject);

			Channel = new Dictionary<string, string>()
				{
					{"ID","ID"},
					{"Name","Name"},
					{"ChannelType","ChannelType"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.Channel), Channel);

			Account = new Dictionary<string, string>()
				{
					{"ID","ID"},
					{"Name","Name"},
					{"ParentAccountID","ParentAccountID"},
					{"AccountID","AccountID"},
					{"Status","Status"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.Account), Account);

			EdgeObject = new Dictionary<string, string>()
				{
					{"GK","GK"},
					{"Name","Name"},
					{"AccountID","AccountID"},
				};
				Mapping.Add(typeof(Edge.Data.Objects.EdgeObject), EdgeObject);

			AgeTarget = new Dictionary<string, string>()
				{
					{"FromAge","int_Field1"},
					{"ToAge","int_Field2"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.AgeTarget), AgeTarget);

			this.GenderTarget = new Dictionary<string, string>()
				{
					{"Gender","int_Field1"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.GenderTarget), GenderTarget);

			KeywordTarget = new Dictionary<string, string>()
				{
					{"MatchType","int_Field1"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.KeywordTarget), KeywordTarget);

			PlacementTarget = new Dictionary<string, string>()
				{
					{"PlacementType","int_Field1"},
					{"Value","string_Field1"},
				};
				Mapping.Add(typeof(Edge.Data.Objects.PlacementTarget), PlacementTarget);

			TextCreative = new Dictionary<string, string>()
				{
					{"TextType","int_Field1"},
					{"Text","string_Field1"},
					{"Text2","string_Field2"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.TextCreative), TextCreative);

			ImageCreative = new Dictionary<string, string>()
				{
					{"ImageUrl","string_Field1"},
					{"ImageSize","string_Field2"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.ImageCreative), ImageCreative);

			Campaign = new Dictionary<string, string>()
				{
					{"Budget","Decimal_Field1"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.Campaign), Campaign);

			Ad = new Dictionary<string, string>()
				{
					{"DestinationUrl","DestinationUrl"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.Ad), Ad);

			Segment = new Dictionary<string, string>()
				{
					{"ConnectionDefinitionID","int_Field1"},
					{"Value","string_Field1"}
				};
				Mapping.Add(typeof(Edge.Data.Objects.Segment), Segment);

			LandingPage = new Dictionary<string, string>()
				{
					{"LandingPageType","int_Field1"},
				};
				Mapping.Add(typeof(Edge.Data.Objects.LandingPage), LandingPage);

		}

		public string GetMap(Type type, string Name)
		{
			string map;

			Dictionary<string, string> mappDic = new Dictionary<string, string>();
			if (Mapping.TryGetValue(type, out mappDic))
			{
				if (!mappDic.TryGetValue(Name, out map))
				{
					map = EdgeObject[Name];
					if (!EdgeObject.TryGetValue(Name, out map))
						throw new Exception(string.Format("Could not find mapping to field {0} on Type/Object {1}", Name, type.Name));
				}
			}
			else
				throw new Exception(string.Format("Could not find mapping for Type/Object {0}", type.Name));
			return map;

		}

		internal Dictionary<string, string> GetFields(Type type)
		{
			Dictionary<string, string> fields = new Dictionary<string, string>();
			Dictionary<string, string> mappDic = new Dictionary<string, string>();

			if (Mapping.TryGetValue(type, out mappDic))
			{
				Type parentType = type.BaseType;
				fields = mappDic;
				while (parentType != null && (parentType.IsSubclassOf(typeof(EdgeObject)) || parentType == typeof(EdgeObject)))
				{
					Dictionary<string, string> parentMapping = new Dictionary<string, string>();
					if (Mapping.TryGetValue(parentType,out parentMapping))
					{
						fields = fields.Concat(parentMapping).ToDictionary(k => k.Key, v => v.Value);
						parentType = parentType.BaseType;
					}
					else
						throw new Exception(string.Format("Could not find mapping for Parent Type/Object {0}", parentType.Name));
				}
			}
			else
				throw new Exception(string.Format("Could not find mapping for Type/Object {0}", type.Name));

			return fields;
		}
	}
}
