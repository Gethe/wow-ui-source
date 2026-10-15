local RaidMarkerConstants =
{
	Tables =
	{
		{
			Name = "RaidMarkerSpellids",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 84996,
			MaxValue = 171557,
			Fields =
			{
				{ Name = "RaidMarker_0", Type = "RaidMarkerSpellids", EnumValue = 84996 },
				{ Name = "RaidMarker_1", Type = "RaidMarkerSpellids", EnumValue = 84997 },
				{ Name = "RaidMarker_2", Type = "RaidMarkerSpellids", EnumValue = 84998 },
				{ Name = "RaidMarker_3", Type = "RaidMarkerSpellids", EnumValue = 84999 },
				{ Name = "RaidMarker_4", Type = "RaidMarkerSpellids", EnumValue = 85000 },
				{ Name = "RaidMarker_5", Type = "RaidMarkerSpellids", EnumValue = 171555 },
				{ Name = "RaidMarker_6", Type = "RaidMarkerSpellids", EnumValue = 171556 },
				{ Name = "RaidMarker_7", Type = "RaidMarkerSpellids", EnumValue = 171557 },
			},
		},
		{
			Name = "RaidMarkerConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_RAID_TARGETS_USER", Type = "number", Value = 8 },
				{ Name = "MAX_RAID_TARGETS_RESTRICTED", Type = "number", Value = 8 },
				{ Name = "MAX_VALID_RAID_TARGETS", Type = "number", Value = 0 },
				{ Name = "MAX_RAID_MARKERS", Type = "number", Value = 8 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(RaidMarkerConstants);