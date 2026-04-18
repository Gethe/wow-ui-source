local PlayerScript =
{
	Name = "PlayerScript",
	Type = "System",
	Environment = "All",

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
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "fullName", Type = "cstring", Nilable = false },
				{ Name = "context", Type = "cstring", Nilable = false, NeverSecret = true },
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
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FollowUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetAutoDeclineNeighborhoodInvites",
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
			Name = "GetExpertise",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "mainhandExpertise", Type = "number", Nilable = false },
				{ Name = "offhandExpertise", Type = "number", Nilable = false },
				{ Name = "rangedExpertise", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExpertisePercent",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "mainhandExpertisePercent", Type = "number", Nilable = false },
				{ Name = "offhandExpertisePercent", Type = "number", Nilable = false },
				{ Name = "rangedExpertisePercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLootSpecialization",
			Type = "Function",

			Returns =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMastery",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMasteryEffect",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "masteryEffect", Type = "number", Nilable = false },
				{ Name = "bonusCoefficient", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModResilienceDamageReduction",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

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
			Name = "GetOverrideAPBySpellPower",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOverrideSpellPowerByAP",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetPlayerInfoByGUID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "localizedClass", Type = "cstring", Nilable = false },
				{ Name = "englishClass", Type = "cstring", Nilable = false },
				{ Name = "localizedRace", Type = "cstring", Nilable = false },
				{ Name = "englishRace", Type = "cstring", Nilable = false },
				{ Name = "sex", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "realmName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerDamage",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerHealing",
			Type = "Function",
			SecretWhenUnitStatsRestricted = true,

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
			MayReturnNothing = true,

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsGuildLeader",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInGuild",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemPreferredArmorType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isItemPreferredArmorType", Type = "bool", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "PlayerIsInCombat",
			Type = "Function",

			Returns =
			{
				{ Name = "playerIsInCombat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerIsTimerunning",
			Type = "Function",

			Returns =
			{
				{ Name = "playerIsTimerunning", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PortGraveyard",
			Type = "Function",
		},
		{
			Name = "RandomRoll",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "allow", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAutoDeclineGuildInvites",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "allow", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAutoDeclineNeighborhoodInvites",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "allow", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetCemeteryPreference",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cemetaryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLootSpecialization",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaxiBenchmarkMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ShowCloak",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "show", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShowHelm",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			HasRestrictions = true,
		},
		{
			Name = "StartAttack",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false, Default = "0" },
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
		{
			Name = "PlayerInCombatChanged",
			Type = "Event",
			LiteralName = "PLAYER_IN_COMBAT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "inCombat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerTargetDied",
			Type = "Event",
			LiteralName = "PLAYER_TARGET_DIED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "PlayerAttackPowerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mainHandAttackPower", Type = "number", Nilable = false },
				{ Name = "offHandAttackPower", Type = "number", Nilable = false },
				{ Name = "rangedAttackPower", Type = "number", Nilable = false },
				{ Name = "baseAttackPower", Type = "number", Nilable = false },
				{ Name = "baseRangedAttackPower", Type = "number", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerScript);