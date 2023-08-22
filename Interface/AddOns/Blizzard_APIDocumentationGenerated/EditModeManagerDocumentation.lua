local EditModeManager =
{
	Name = "EditModeManager",
	Type = "System",
	Namespace = "C_EditMode",

	Functions =
	{
		{
			Name = "ConvertLayoutInfoToString",
			Type = "Function",

			Arguments =
			{
				{ Name = "layoutInfo", Type = "EditModeLayoutInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "layoutInfoAsString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConvertStringToLayoutInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "layoutInfoAsString", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "layoutInfo", Type = "EditModeLayoutInfo", Nilable = false },
			},
		},
		{
			Name = "GetAccountSettings",
			Type = "Function",

			Returns =
			{
				{ Name = "accountSettings", Type = "table", InnerType = "EditModeSettingInfo", Nilable = false },
			},
		},
		{
			Name = "GetLayouts",
			Type = "Function",

			Returns =
			{
				{ Name = "layoutInfo", Type = "EditModeLayouts", Nilable = false },
			},
		},
		{
			Name = "OnEditModeExit",
			Type = "Function",
		},
		{
			Name = "OnLayoutAdded",
			Type = "Function",

			Arguments =
			{
				{ Name = "addedLayoutIndex", Type = "luaIndex", Nilable = false },
				{ Name = "activateNewLayout", Type = "bool", Nilable = false },
				{ Name = "isLayoutImported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OnLayoutDeleted",
			Type = "Function",

			Arguments =
			{
				{ Name = "deletedLayoutIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SaveLayouts",
			Type = "Function",

			Arguments =
			{
				{ Name = "saveInfo", Type = "EditModeLayouts", Nilable = false },
			},
		},
		{
			Name = "SetAccountSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "setting", Type = "EditModeAccountSetting", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetActiveLayout",
			Type = "Function",

			Arguments =
			{
				{ Name = "activeLayout", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EditModeLayoutsUpdated",
			Type = "Event",
			LiteralName = "EDIT_MODE_LAYOUTS_UPDATED",
			Payload =
			{
				{ Name = "layoutInfo", Type = "EditModeLayouts", Nilable = false },
				{ Name = "reconcileLayouts", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "EditModeAnchorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "string", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EditModeLayoutInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "layoutName", Type = "string", Nilable = false },
				{ Name = "layoutType", Type = "EditModeLayoutType", Nilable = false },
				{ Name = "systems", Type = "table", InnerType = "EditModeSystemInfo", Nilable = false },
			},
		},
		{
			Name = "EditModeLayouts",
			Type = "Structure",
			Fields =
			{
				{ Name = "layouts", Type = "table", InnerType = "EditModeLayoutInfo", Nilable = false },
				{ Name = "activeLayout", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "EditModeSettingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "setting", Type = "number", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EditModeSystemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "system", Type = "EditModeSystem", Nilable = false },
				{ Name = "systemIndex", Type = "luaIndex", Nilable = true },
				{ Name = "anchorInfo", Type = "EditModeAnchorInfo", Nilable = false },
				{ Name = "anchorInfo2", Type = "EditModeAnchorInfo", Nilable = true },
				{ Name = "settings", Type = "table", InnerType = "EditModeSettingInfo", Nilable = false },
				{ Name = "isInDefaultPosition", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EditModeManager);