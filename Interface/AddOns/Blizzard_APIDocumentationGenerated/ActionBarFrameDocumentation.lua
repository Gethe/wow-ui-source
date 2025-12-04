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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenTainted",
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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Force updates some internals for an action button slot." },

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetActionAutocast",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "autocastAllowed", Type = "bool", Nilable = false },
				{ Name = "autocastEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActionBarPage",
			Type = "Function",

			Returns =
			{
				{ Name = "currentPage", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetActionCharges",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretWhenActionCooldownRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "chargeInfo", Type = "ActionBarChargeInfo", Nilable = false },
			},
		},
		{
			Name = "GetActionCooldown",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretWhenActionCooldownRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "cooldownInfo", Type = "ActionBarCooldownInfo", Nilable = false },
			},
		},
		{
			Name = "GetActionLossOfControlCooldown",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretWhenActionCooldownRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActionText",
			Type = "Function",
			MayReturnNothing = true,
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetActionTexture",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "textureFileID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetActionUseCount",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretWhenActionCooldownRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBonusBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "bonusBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetBonusBarIndexForSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetBonusBarOffset",
			Type = "Function",

			Returns =
			{
				{ Name = "bonusBarOffset", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExtraBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "extraBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetItemActionOnEquipSpellID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetMultiCastBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "multiCastBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetOverrideBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "overrideBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetOverrideBarSkin",
			Type = "Function",

			Returns =
			{
				{ Name = "textureFileID", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "GetPetActionPetBarIndices",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetProfessionQualityInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingQualityInfo", Nilable = true },
			},
		},
		{
			Name = "GetSpell",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetTempShapeshiftBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "tempShapeshiftBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetVehicleBarIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "vehicleBarIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "HasAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if an actionbar slot is populated with an action." },

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAction", Type = "bool", Nilable = false },
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
			Name = "HasBonusActionBar",
			Type = "Function",

			Returns =
			{
				{ Name = "hasBonusActionBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasExtraActionBar",
			Type = "Function",

			Returns =
			{
				{ Name = "hasExtraActionBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFlyoutActionButtons",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "HasOverrideActionBar",
			Type = "Function",

			Returns =
			{
				{ Name = "hasOverrideActionBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPetActionButtons",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "HasRangeRequirements",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasRangeRequirements", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSpellActionButtons",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			Name = "HasTempShapeshiftActionBar",
			Type = "Function",

			Returns =
			{
				{ Name = "hasTempShapeshiftActionBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasVehicleActionBar",
			Type = "Function",

			Returns =
			{
				{ Name = "hasVehicleActionBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsActionInRange",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "isInRange", Type = "bool", Nilable = true, Documentation = { "If nil, range cannot be determined (eg. no target is available)." } },
			},
		},
		{
			Name = "IsAssistedCombatAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
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
			Name = "IsAttackAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAttackAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAutoCastPetAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsAutoRepeatAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoRepeatAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsConsumableAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isConsumableAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCurrentAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCurrentAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabledAutoCastPetAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsEquippedAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEquippedAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedGearOutfitAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEquippedGearOutfitAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHarmfulAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsInterruptAction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether the given action button contains a spell that can interrupt spellcasting." },

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isInterruptAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnBarOrSpecialBar",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			Name = "IsPossessBarVisible",
			Type = "Function",

			Returns =
			{
				{ Name = "isPossessBarVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsStackableAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isStackableAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsableAction",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "isLackingResources", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PutActionInSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "RegisterActionUIButton",
			Type = "Function",
			RequiresValidActionSlot = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "checkboxFrame", Type = "SimpleCheckbox", Nilable = false },
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
				{ Name = "cooldownFrame", Type = "CooldownFrame", Nilable = false },
			},
		},
		{
			Name = "SetActionBarPage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "pageIndex", Type = "luaIndex", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "UnregisterActionUIButton",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "checkboxFrame", Type = "SimpleCheckbox", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActionRangeCheckUpdate",
			Type = "Event",
			LiteralName = "ACTION_RANGE_CHECK_UPDATE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "changes", Type = "table", InnerType = "ActionUsableState", Nilable = false },
			},
		},
		{
			Name = "ActionbarHidegrid",
			Type = "Event",
			LiteralName = "ACTIONBAR_HIDEGRID",
			SynchronousEvent = true,
		},
		{
			Name = "ActionbarPageChanged",
			Type = "Event",
			LiteralName = "ACTIONBAR_PAGE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ActionbarShowBottomleft",
			Type = "Event",
			LiteralName = "ACTIONBAR_SHOW_BOTTOMLEFT",
			SynchronousEvent = true,
		},
		{
			Name = "ActionbarShowgrid",
			Type = "Event",
			LiteralName = "ACTIONBAR_SHOWGRID",
			SynchronousEvent = true,
		},
		{
			Name = "ActionbarSlotChanged",
			Type = "Event",
			LiteralName = "ACTIONBAR_SLOT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ActionbarUpdateCooldown",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_COOLDOWN",
			UniqueEvent = true,
		},
		{
			Name = "ActionbarUpdateState",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_STATE",
			UniqueEvent = true,
		},
		{
			Name = "ActionbarUpdateUsable",
			Type = "Event",
			LiteralName = "ACTIONBAR_UPDATE_USABLE",
			UniqueEvent = true,
		},
		{
			Name = "PetBarUpdate",
			Type = "Event",
			LiteralName = "PET_BAR_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateBonusActionbar",
			Type = "Event",
			LiteralName = "UPDATE_BONUS_ACTIONBAR",
			SynchronousEvent = true,
			UniqueEvent = true,
		},
		{
			Name = "UpdateExtraActionbar",
			Type = "Event",
			LiteralName = "UPDATE_EXTRA_ACTIONBAR",
			UniqueEvent = true,
		},
		{
			Name = "UpdateMultiCastActionbar",
			Type = "Event",
			LiteralName = "UPDATE_MULTI_CAST_ACTIONBAR",
			UniqueEvent = true,
		},
		{
			Name = "UpdateOverrideActionbar",
			Type = "Event",
			LiteralName = "UPDATE_OVERRIDE_ACTIONBAR",
			UniqueEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ActionBarFrame);