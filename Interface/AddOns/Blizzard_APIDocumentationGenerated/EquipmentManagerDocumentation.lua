local EquipmentManager =
{
	Name = "EquipmentSet",
	Type = "System",
	Namespace = "C_EquipmentSet",

	Functions =
	{
		{
			Name = "AssignSpecToEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CanUseEquipmentSets",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseEquipmentSets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearIgnoredSlotsForSave",
			Type = "Function",
		},
		{
			Name = "CreateEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetName", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "DeleteEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EquipmentSetContainsLockedItems",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasLockedItems", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetAssignedSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetForSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetID",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "equipmentSetIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "setID", Type = "number", Nilable = false },
				{ Name = "isEquipped", Type = "bool", Nilable = false },
				{ Name = "numItems", Type = "number", Nilable = false },
				{ Name = "numEquipped", Type = "number", Nilable = false },
				{ Name = "numInInventory", Type = "number", Nilable = false },
				{ Name = "numLost", Type = "number", Nilable = false },
				{ Name = "numIgnored", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIgnoredSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotIgnored", Type = "table", InnerType = "bool", Nilable = false },
			},
		},
		{
			Name = "GetItemIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemLocations",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "locations", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumEquipmentSets",
			Type = "Function",

			Returns =
			{
				{ Name = "numEquipmentSets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IgnoreSlotForSave",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "IsSlotIgnoredForSave",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSlotIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ModifyEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "newName", Type = "cstring", Nilable = false },
				{ Name = "newIcon", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "PickupEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SaveEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "UnassignEquipmentSetSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnignoreSlotForSave",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "UseEquipmentSet",
			Type = "Function",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "setWasEquipped", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EquipmentSetsChanged",
			Type = "Event",
			LiteralName = "EQUIPMENT_SETS_CHANGED",
		},
		{
			Name = "EquipmentSwapFinished",
			Type = "Event",
			LiteralName = "EQUIPMENT_SWAP_FINISHED",
			Payload =
			{
				{ Name = "result", Type = "bool", Nilable = false },
				{ Name = "setID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "EquipmentSwapPending",
			Type = "Event",
			LiteralName = "EQUIPMENT_SWAP_PENDING",
		},
		{
			Name = "TransmogOutfitsChanged",
			Type = "Event",
			LiteralName = "TRANSMOG_OUTFITS_CHANGED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EquipmentManager);