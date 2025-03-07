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
			MayReturnNothing = true,

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
			Name = "ClearPendingBindConversionItem",
			Type = "Function",
		},
		{
			Name = "ConfirmTalentWipe",
			Type = "Function",
		},
		{
			Name = "ConvertItemToBindToAccount",
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
			Name = "GetAttackPowerForStat",
			Type = "Function",

			Arguments =
			{
				{ Name = "stat", Type = "luaIndex", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},

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
			Name = "GetAvoidance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetBlockChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetCombatRating",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCombatRatingBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCombatRatingBonusForCombatRatingValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
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
			Name = "GetCorruption",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCorruptionResistance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCritChanceProvidesParryEffect",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDodgeChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDodgeChanceFromAttribute",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExpertise",
			Type = "Function",

			Returns =
			{
				{ Name = "mainhandExpertise", Type = "number", Nilable = false },
				{ Name = "offhandExpertise", Type = "number", Nilable = false },
				{ Name = "rangedExpertise", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHitModifier",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetJailersTowerLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLifesteal",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetManaRegen",
			Type = "Function",

			Returns =
			{
				{ Name = "baseManaRegen", Type = "number", Nilable = false },
				{ Name = "castingManaRegen", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMastery",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMasteryEffect",
			Type = "Function",

			Returns =
			{
				{ Name = "masteryEffect", Type = "number", Nilable = false },
				{ Name = "bonusCoefficient", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxCombatRatingBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "ratingIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMaxPlayerLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "maxPlayerLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMeleeHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModResilienceDamageReduction",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMoney",
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
			Name = "GetOverrideAPBySpellPower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOverrideSpellPowerByAP",
			Type = "Function",

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
			Name = "GetPVPGearStatRules",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPVPLifetimeStats",
			Type = "Function",

			Returns =
			{
				{ Name = "lifetimeHonorableKills", Type = "number", Nilable = false },
				{ Name = "lifetimeMaxPVPRank", Type = "PvPRanks", Nilable = false },
			},
		},
		{
			Name = "GetPVPSessionStats",
			Type = "Function",

			Returns =
			{
				{ Name = "honorableKills", Type = "number", Nilable = false },
				{ Name = "dishonorableKills", Type = "number", Nilable = false },
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
			Name = "GetPVPYesterdayStats",
			Type = "Function",

			Returns =
			{
				{ Name = "honorableKills", Type = "number", Nilable = false },
				{ Name = "dishonorableKills", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetParryChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetParryChanceFromAttribute",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetMeleeHaste",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetSpellBonusDamage",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerFacing",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPlayerInfoByGUID",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "GetPowerRegen",
			Type = "Function",

			Returns =
			{
				{ Name = "basePowerRegen", Type = "number", Nilable = false },
				{ Name = "castingPowerRegen", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerRegenForPowerType",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "basePowerRegen", Type = "number", Nilable = false },
				{ Name = "castingPowerRegen", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerDamage",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPvpPowerHealing",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRangedCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRangedHaste",
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
			Name = "GetResSicknessDuration",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = true },
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
			Name = "GetRuneCooldown",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "runeIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "isRuneReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRuneCount",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "runeIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetShieldBlock",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpeed",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellBonusDamage",
			Type = "Function",

			Arguments =
			{
				{ Name = "school", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSpellBonusHealing",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellCritChance",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellHitModifier",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellPenetration",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSturdiness",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "GetVersatilityBonus",
			Type = "Function",

			Arguments =
			{
				{ Name = "combatRating", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
			Name = "HasAPEffectsSpellPower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasDualWieldPenalty",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFullControl",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "HasSPEffectsAttackPower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsAdvancedFlyableArea",
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
			Name = "IsDrivableArea",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDualWielding",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFlyableArea",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsInJailersTower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIndoors",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInsane",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemPreferredArmorType",
			Type = "Function",

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
			Name = "IsJailersTowerLayerTimeLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "layerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsLoggedIn",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMounted",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnGroundFloorInJailersTower",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOutOfBounds",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOutdoors",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "IsRangedWeapon",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsResting",
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
			Name = "IsStealthed",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsXPUserDisabled",
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
			Name = "PlayerCanTeleport",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerEffectiveAttackPower",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "mainHandAttackPower", Type = "number", Nilable = false },
				{ Name = "offHandAttackPower", Type = "number", Nilable = false },
				{ Name = "rangedAttackPower", Type = "number", Nilable = false },
				{ Name = "baseAttackPower", Type = "number", Nilable = false },
				{ Name = "baseRangedAttackPower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerGetTimerunningSeasonID",
			Type = "Function",

			Returns =
			{
				{ Name = "timerunningSeasonID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PortGraveyard",
			Type = "Function",
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
			Name = "RespondInstanceLock",
			Type = "Function",

			Arguments =
			{
				{ Name = "acceptLock", Type = "bool", Nilable = false },
			},
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
			Name = "SetLootSpecialization",
			Type = "Function",

			Arguments =
			{
				{ Name = "specializationID", Type = "number", Nilable = false },
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
			Name = "ShouldShowIslandsWeeklyPOI",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowSpecialSplashScreen",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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
			Name = "SplashFrameCanBeShown",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartAttack",
			Type = "Function",

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
};

APIDocumentation:AddDocumentationTable(PlayerScript);