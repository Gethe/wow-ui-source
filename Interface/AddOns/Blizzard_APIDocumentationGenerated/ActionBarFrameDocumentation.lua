local ActionBarFrame =
{
	Name = "ActionBar",
	Type = "System",
	Namespace = "C_ActionBar",

	Functions =
	{
		{
			Name = "EnableActionRangeCheck",
			Type = "Function",
			Documentation = { "Used in conjunction with ActionRangeCheckUpdate to inform the UI when an action goes in or out of range with its current target." },

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
				{ Name = "enable", Type = "bool", Nilable = false, Documentation = { "True if changes in range for the action should dispatch ActionRangeCheckUpdate. False if the action no longer needs the event." } },
			},
		},
		{
			Name = "FindAssistedCombatActionButtons",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the list of action bar slots that contain the Assisted Combat action spell." },

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "FindFlyoutActionButtons",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "FindPetActionButtons",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "FindSpellActionButtons",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the list of action bar slots that contain a specified spell." },

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false, Documentation = { "Expects a base spell, so if a spell is overridden the base ID should be provided." } },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ForceUpdateAction",
			Type = "Function",
			Documentation = { "Force updates some internals for an action button slot." },

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetBonusBarIndexForSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "bonusBarIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetItemActionOnEquipSpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "onEquipSpellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPetActionPetBarIndices",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetProfessionQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasAssistedCombatActionButtons",
			Type = "Function",

			Returns =
			{
				{ Name = "hasButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFlyoutActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFlyoutActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPetActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPetActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPetActionPetBarIndices",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPetActionPetBarIndices", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSpellActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSpellActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAssistedCombatAction",
			Type = "Function",
			Documentation = { "Returns whether the given action button contains the Assisted Combat action spell." },

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAssistedCombatAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoCastPetAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabledAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEnabledAutoCastPetAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHarmfulAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
				{ Name = "useNeutral", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHarmful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHelpfulAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
				{ Name = "useNeutral", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHelpful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnBarOrSpecialBar",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOnBarOrSpecialBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PutActionInSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ShouldOverrideBarShowHealthBar",
			Type = "Function",

			Returns =
			{
				{ Name = "showHealthBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldOverrideBarShowManaBar",
			Type = "Function",

			Returns =
			{
				{ Name = "showManaBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActionRangeCheckUpdate",
			Type = "Event",
			LiteralName = "ACTION_RANGE_CHECK_UPDATE",
			Documentation = { "Used in conjunction with EnableActionRangeCheck to inform the UI when an action goes in or out of range with its current target." },
			Payload =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "isInRange", Type = "bool", Nilable = false, Documentation = { "Whether or not the current target is in range of the action. Should not be used if the 'checksRange' parameter is false." } },
				{ Name = "checksRange", Type = "bool", Nilable = false, Documentation = { "Can be false if a range check was not made for any reason, for example there is not a current target." } },
			},
		},
		{
			Name = "ActionUsableChanged",
			Type = "Event",
			LiteralName = "ACTION_USABLE_CHANGED",
			Payload =
			{
				{ Name = "changes", Type = "table", InnerType = "ActionUsableState", Nilable = false },
			},
		},
		{
			Name = "ActionbarHidegrid",
			Type = "Event",
			LiteralName = "ACTIONBAR_HIDEGRID",
		},
		{
			Name = "ActionbarPageChanged",
			Type = "Event",
			LiteralName = "ACTIONBAR_PAGE_CHANGED",
		},
		{
			Name = "ActionbarShowBottomleft",
			Type = "Event",
			LiteralName = "ACTIONBAR_SHOW_BOTTOMLEFT",
		},
		{
			Name = "ActionbarShowgrid",
			Type = "Event",
			LiteralName = "ACTIONBAR_SHOWGRID",
		},
		{
			Name = "ActionbarSlotChanged",
			Type = "Event",
			LiteralName = "ACTIONBAR_SLOT_CHANGED",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ActionbarUpdateCooldown",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_COOLDOWN",
		},
		{
			Name = "ActionbarUpdateState",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_STATE",
		},
		{
			Name = "ActionbarUpdateUsable",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_USABLE",
		},
		{
			Name = "PetBarUpdate",
			Type = "Event",
			LiteralName = "PET_BAR_UPDATE",
		},
		{
			Name = "UpdateBonusActionbar",
			Type = "Event",
			LiteralName = "UPDATE_BONUS_ACTIONBAR",
		},
		{
			Name = "UpdateExtraActionbar",
			Type = "Event",
			LiteralName = "UPDATE_EXTRA_ACTIONBAR",
		},
		{
			Name = "UpdateMultiCastActionbar",
			Type = "Event",
			LiteralName = "UPDATE_MULTI_CAST_ACTIONBAR",
		},
		{
			Name = "UpdateOverrideActionbar",
			Type = "Event",
			LiteralName = "UPDATE_OVERRIDE_ACTIONBAR",
		},
	},

	Tables =
	{
		{
			Name = "ActionUsableState",
			Type = "Structure",
			Fields =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "usable", Type = "bool", Nilable = false },
				{ Name = "noMana", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ActionBarFrame);