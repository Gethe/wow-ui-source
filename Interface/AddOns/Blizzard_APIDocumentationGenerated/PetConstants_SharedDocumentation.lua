local PetConstants_Shared =
{
	Tables =
	{
		{
			Name = "PetActionFeedback",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Success", Type = "PetActionFeedback", EnumValue = 0 },
				{ Name = "Dead", Type = "PetActionFeedback", EnumValue = 1 },
				{ Name = "InvalidTarget", Type = "PetActionFeedback", EnumValue = 2 },
				{ Name = "FriendlyTarget", Type = "PetActionFeedback", EnumValue = 3 },
				{ Name = "NoPath", Type = "PetActionFeedback", EnumValue = 4 },
			},
		},
		{
			Name = "PetMode",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Passive", Type = "PetMode", EnumValue = 0 },
				{ Name = "Defensive", Type = "PetMode", EnumValue = 1 },
				{ Name = "Aggressive", Type = "PetMode", EnumValue = 2 },
				{ Name = "Assist", Type = "PetMode", EnumValue = 3 },
			},
		},
		{
			Name = "PetOrders",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Wait", Type = "PetOrders", EnumValue = 0 },
				{ Name = "Follow", Type = "PetOrders", EnumValue = 1 },
				{ Name = "Attack", Type = "PetOrders", EnumValue = 2 },
				{ Name = "Dismiss", Type = "PetOrders", EnumValue = 3 },
				{ Name = "MoveTo", Type = "PetOrders", EnumValue = 4 },
			},
		},
		{
			Name = "PetOverride",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "PetOverride", EnumValue = 0 },
				{ Name = "AICombatControl", Type = "PetOverride", EnumValue = 1 },
				{ Name = "AICombatPassive", Type = "PetOverride", EnumValue = 2 },
				{ Name = "OwnerMounted", Type = "PetOverride", EnumValue = 4 },
			},
		},
		{
			Name = "Pettameresult",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "Ok", Type = "Pettameresult", EnumValue = 0 },
				{ Name = "Invalidcreature", Type = "Pettameresult", EnumValue = 1 },
				{ Name = "Toomany", Type = "Pettameresult", EnumValue = 2 },
				{ Name = "Creaturealreadyowned", Type = "Pettameresult", EnumValue = 3 },
				{ Name = "Nottameable", Type = "Pettameresult", EnumValue = 4 },
				{ Name = "Anothersummonactive", Type = "Pettameresult", EnumValue = 5 },
				{ Name = "Unitscanttame", Type = "Pettameresult", EnumValue = 6 },
				{ Name = "Nopetavailable", Type = "Pettameresult", EnumValue = 7 },
				{ Name = "Internalerror", Type = "Pettameresult", EnumValue = 8 },
				{ Name = "Toohighlevel", Type = "Pettameresult", EnumValue = 9 },
				{ Name = "Dead", Type = "Pettameresult", EnumValue = 10 },
				{ Name = "Notdead", Type = "Pettameresult", EnumValue = 11 },
				{ Name = "Cantcontrolexotic", Type = "Pettameresult", EnumValue = 12 },
				{ Name = "Invalidslot", Type = "Pettameresult", EnumValue = 13 },
				{ Name = "EliteToohighlevel", Type = "Pettameresult", EnumValue = 14 },
				{ Name = "Numresults", Type = "Pettameresult", EnumValue = 15 },
			},
		},
		{
			Name = "StableResult",
			Type = "Enumeration",
			NumValues = 17,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "MaxSlots", Type = "StableResult", EnumValue = 0 },
				{ Name = "InsufficientFunds", Type = "StableResult", EnumValue = 1 },
				{ Name = "NotStableMaster", Type = "StableResult", EnumValue = 2 },
				{ Name = "InvalidSlot", Type = "StableResult", EnumValue = 3 },
				{ Name = "NoPet", Type = "StableResult", EnumValue = 4 },
				{ Name = "AlreadyStabled", Type = "StableResult", EnumValue = 5 },
				{ Name = "AlreadySummoned", Type = "StableResult", EnumValue = 6 },
				{ Name = "NotFound", Type = "StableResult", EnumValue = 7 },
				{ Name = "StableSuccess", Type = "StableResult", EnumValue = 8 },
				{ Name = "UnstableSuccess", Type = "StableResult", EnumValue = 9 },
				{ Name = "ReviveSuccess", Type = "StableResult", EnumValue = 10 },
				{ Name = "CantControlExotic", Type = "StableResult", EnumValue = 11 },
				{ Name = "InternalError", Type = "StableResult", EnumValue = 12 },
				{ Name = "CheckForLuaHack", Type = "StableResult", EnumValue = 13 },
				{ Name = "BuySlotSuccess", Type = "StableResult", EnumValue = 14 },
				{ Name = "FavoriteToggle", Type = "StableResult", EnumValue = 15 },
				{ Name = "PetRenamed", Type = "StableResult", EnumValue = 16 },
			},
		},
		{
			Name = "UnitMirrorPetFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Renameable", Type = "UnitMirrorPetFlags", EnumValue = 1 },
				{ Name = "Dismissable", Type = "UnitMirrorPetFlags", EnumValue = 2 },
				{ Name = "RecentlyTamed", Type = "UnitMirrorPetFlags", EnumValue = 4 },
				{ Name = "Stampede", Type = "UnitMirrorPetFlags", EnumValue = 8 },
				{ Name = "ExtraPet", Type = "UnitMirrorPetFlags", EnumValue = 16 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetConstants_Shared);