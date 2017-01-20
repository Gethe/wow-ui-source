local EquipmentManagerLua =
{
	Name = "EquipementSet",
	Namespace = "C_EquipmentSet",

	Functions =
	{
		{
			Name = "AssignSpecToEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "specIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanUseEquipmentSets",

			Returns =
			{
				{ Name = "canUseEquipmentSets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearIgnoredSlotsForSave",
		},
		{
			Name = "CreateEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetName", Type = "string", Nilable = false },
				{ Name = "icon", Type = "string", Nilable = true },
			},
		},
		{
			Name = "DeleteEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EquipmentSetContainsLockedItems",

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

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "specIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetID",

			Arguments =
			{
				{ Name = "equipmentSetName", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetIDs",

			Returns =
			{
				{ Name = "equipmentSetIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquipmentSetInfo",

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

			Returns =
			{
				{ Name = "numEquipmentSets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IgnoreSlotForSave",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsSlotIgnoredForSave",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSlotIgnored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ModifyEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "newName", Type = "string", Nilable = false },
				{ Name = "newIcon", Type = "string", Nilable = true },
			},
		},
		{
			Name = "PickupEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SaveEquipmentSet",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UnassignEquipmentSetSpec",

			Arguments =
			{
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnignoreSlotForSave",

			Arguments =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UseEquipmentSet",

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

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EquipmentManagerLua);