local PlayerScript =
{
	Name = "PlayerScript",
	Type = "System",

	Functions =
	{
		{
			Name = "AcceptAreaSpiritHeal",
			Type = "Function",
		},
		{
			Name = "AcceptGuild",
			Type = "Function",
		},
		{
			Name = "AcceptResurrect",
			Type = "Function",
		},
		{
			Name = "Ambiguate",
			Type = "Function",

			Arguments =
			{
				{ Name = "fullName", Type = "cstring", Nilable = false },
				{ Name = "context", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AutoEquipCursorItem",
			Type = "Function",
		},
		{
			Name = "BeginTrade",
			Type = "Function",
		},
		{
			Name = "CanDualWield",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanInspect",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetGUID", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanLootUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetUnit", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasLoot", Type = "bool", Nilable = false },
				{ Name = "canLoot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelAreaSpiritHeal",
			Type = "Function",
		},
		{
			Name = "CancelPendingEquip",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelTrade",
			Type = "Function",
		},
		{
			Name = "CheckInteractDistance",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitGUID", Type = "UnitToken", Nilable = false },
				{ Name = "distIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CheckTalentMasterDist",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ConfirmBarbersChoice",
			Type = "Function",
		},
		{
			Name = "ConfirmBinder",
			Type = "Function",
		},
		{
			Name = "ConfirmPetUnlearn",
			Type = "Function",
		},
		{
			Name = "ConfirmTalentWipe",
			Type = "Function",
		},
		{
			Name = "DeclineGuild",
			Type = "Function",
		},
		{
			Name = "DeclineResurrect",
			Type = "Function",
		},
		{
			Name = "Dismount",
			Type = "Function",
		},
		{
			Name = "EquipPendingItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FollowUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false, Default = "0" },
				{ Name = "exactMatch", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetAllowLowLevelRaid",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAreaSpiritHealerTime",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAutoDeclineGuildInvites",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetBindLocation",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCemeteryPreference",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCorpseRecoveryDelay",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNormalizedRealmName",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetPVPDesired",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPVPTimer",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetReleaseTimeRemaining",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRestState",
			Type = "Function",

			Returns =
			{
				{ Name = "exhaustionID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "factor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRestrictedAccountData",
			Type = "Function",

			Returns =
			{
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "maxMoney", Type = "WOWMONEY", Nilable = false },
				{ Name = "professionCap", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSheathState",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetTaxiBenchmarkMode",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetXPExhaustion",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasIgnoreDualWieldWeapon",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasKey",
			Type = "Function",

			Returns =
			{
				{ Name = "hasKey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasNoReleaseAura",
			Type = "Function",

			Returns =
			{
				{ Name = "hasCannotReleaseEffect", Type = "bool", Nilable = false },
				{ Name = "longestDuration", Type = "number", Nilable = false },
				{ Name = "hasUntilCancelledDuration", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InitiateTrade",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "IsAccountSecured",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCemeterySelectionAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCharacterNewlyBoosted",
			Type = "Function",

			Returns =
			{
				{ Name = "newlyBoosted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPVPTimerRunning",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerInWorld",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerMoving",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRestrictedAccount",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NoPlayTime",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "NotifyInspect",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetGUID", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "PartialPlayTime",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "RandomRoll",
			Type = "Function",

			Arguments =
			{
				{ Name = "min", Type = "number", Nilable = false },
				{ Name = "max", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RepopMe",
			Type = "Function",
		},
		{
			Name = "RequestTimePlayed",
			Type = "Function",
		},
		{
			Name = "ResurrectGetOfferer",
			Type = "Function",

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ResurrectHasSickness",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResurrectHasTimer",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RetrieveCorpse",
			Type = "Function",
		},
		{
			Name = "SetAllowLowLevelRaid",
			Type = "Function",

			Arguments =
			{
				{ Name = "allow", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAutoDeclineGuildInvites",
			Type = "Function",

			Arguments =
			{
				{ Name = "allow", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetCemeteryPreference",
			Type = "Function",

			Arguments =
			{
				{ Name = "cemetaryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaxiBenchmarkMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ShowCloak",
			Type = "Function",

			Arguments =
			{
				{ Name = "show", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowHelm",
			Type = "Function",

			Arguments =
			{
				{ Name = "show", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowingCloak",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowingHelm",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SitStandOrDescendStart",
			Type = "Function",
		},
		{
			Name = "StartAttack",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "exactMatch", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "StopAttack",
			Type = "Function",
		},
		{
			Name = "Stuck",
			Type = "Function",
		},
		{
			Name = "TimeoutResurrect",
			Type = "Function",
		},
		{
			Name = "ToggleSelfHighlight",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleSheath",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerScript);