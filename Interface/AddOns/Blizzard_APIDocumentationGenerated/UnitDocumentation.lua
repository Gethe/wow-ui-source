local Unit =
{
	Name = "Unit",
	Type = "System",

	Functions =
	{
		{
			Name = "CanEjectPassengerFromSeat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "virtualSeatIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSwitchVehicleSeat",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClosestGameObjectPosition",
			Type = "Function",
			MayReturnNothing = true,
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameObjectID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClosestUnitPosition",
			Type = "Function",
			MayReturnNothing = true,
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EjectPassengerFromSeat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "virtualSeatIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetComboPoints",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNegativeCorruptionEffectInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "corruptionEffects", Type = "table", InnerType = "CorruptionEffectInfo", Nilable = false },
			},
		},
		{
			Name = "GetUnitChargedPowerPoints",
			Type = "Function",
			MayReturnNothing = true,
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "pointIndices", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitEmpowerHoldAtMaxTime",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "holdAtMaxTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitEmpowerMinHoldTime",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "minHoldTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitEmpowerStageDuration",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitHealthModifier",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitMaxHealthModifier",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitPowerBarInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "UnitPowerBarInfo", Nilable = false },
			},
		},
		{
			Name = "GetUnitPowerBarInfoByID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "barID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "UnitPowerBarInfo", Nilable = false },
			},
		},
		{
			Name = "GetUnitPowerBarStrings",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "tooltip", Type = "cstring", Nilable = true },
				{ Name = "cost", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetUnitPowerBarStringsByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "barID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "tooltip", Type = "cstring", Nilable = true },
				{ Name = "cost", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetUnitPowerBarTextureInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "textureIndex", Type = "luaIndex", Nilable = false },
				{ Name = "timerIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitPowerBarTextureInfoByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "barID", Type = "number", Nilable = false },
				{ Name = "textureIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "texture", Type = "fileID", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitPowerModifier",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitSpeed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentSpeed", Type = "number", Nilable = false },
				{ Name = "runSpeed", Type = "number", Nilable = false },
				{ Name = "flightSpeed", Type = "number", Nilable = false },
				{ Name = "swimSpeed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUnitTotalModifiedMaxHealthPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVehicleUIIndicator",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "vehicleIndicatorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "backgroundTextureID", Type = "fileID", Nilable = false },
				{ Name = "numSeatIndicators", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVehicleUIIndicatorSeat",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "vehicleIndicatorID", Type = "number", Nilable = false },
				{ Name = "indicatorSeatIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "virtualSeatIndex", Type = "number", Nilable = false },
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsFalling",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFlying",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerInGuildFromGUID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "IsInGuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSubmerged",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSwimming",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUnitModelReadyForUI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerIsPVPInactive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerVehicleHasComboPoints",
			Type = "Function",

			Returns =
			{
				{ Name = "vehicleHasComboPoints", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ReportPlayerIsPVPAFK",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "ResistancePercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "resistance", Type = "number", Nilable = false },
				{ Name = "casterLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPortraitTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureObject", Type = "SimpleTexture", Nilable = false },
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "disableMasking", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetPortraitTextureFromCreatureDisplayID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureObject", Type = "SimpleTexture", Nilable = false },
				{ Name = "creatureDisplayID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetUnitCursorTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureObject", Type = "SimpleTexture", Nilable = false },
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "style", Type = "CursorStyle", Nilable = true },
				{ Name = "includeLowPriority", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "hasCursor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitAffectingCombat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitAlliedRaceInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAlliedRace", Type = "bool", Nilable = false },
				{ Name = "hasHeritageArmorUnlocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitArmor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "base", Type = "number", Nilable = false },
				{ Name = "effective", Type = "number", Nilable = false },
				{ Name = "real", Type = "number", Nilable = false },
				{ Name = "bonus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitAttackPower",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "attackPower", Type = "number", Nilable = false },
				{ Name = "posBuff", Type = "number", Nilable = false },
				{ Name = "negBuff", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitAttackSpeed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "attackSpeed", Type = "number", Nilable = false },
				{ Name = "offhandAttackSpeed", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitBattlePetLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitBattlePetSpeciesID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitBattlePetType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitCanAssist",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCanAttack",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCanCooperate",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCanPetBattle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCastingInfo",
			Type = "Function",
			SecretWhenUnitCastingInfoRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
				{ Name = "textureID", Type = "fileID", Nilable = false },
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "castID", Type = "WOWGUID", Nilable = false },
				{ Name = "notInterruptible", Type = "bool", Nilable = false },
				{ Name = "castingSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitChannelInfo",
			Type = "Function",
			SecretWhenUnitChannelInfoRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "displayName", Type = "cstring", Nilable = false },
				{ Name = "textureID", Type = "fileID", Nilable = false },
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "notInterruptible", Type = "bool", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "isEmpowered", Type = "bool", Nilable = false },
				{ Name = "numEmpowerStages", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitChromieTimeID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "ID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitClass",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "className", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "classFilename", Type = "cstring", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitClassBase",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "classFilename", Type = "cstring", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitClassification",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitControllingVehicle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCreatureFamily",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitCreatureID",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitCreatureType",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitDamage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "minDamage", Type = "number", Nilable = false },
				{ Name = "maxDamage", Type = "number", Nilable = false },
				{ Name = "offhandMinDamage", Type = "number", Nilable = false },
				{ Name = "offhandMaxDamage", Type = "number", Nilable = false },
				{ Name = "posBuff", Type = "number", Nilable = false },
				{ Name = "negBuff", Type = "number", Nilable = false },
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitDetailedThreatSituation",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "mobGUID", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTanking", Type = "bool", Nilable = false },
				{ Name = "status", Type = "number", Nilable = false },
				{ Name = "scaledPercentage", Type = "number", Nilable = false },
				{ Name = "rawPercentage", Type = "number", Nilable = false },
				{ Name = "rawThreat", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitDistanceSquared",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "distance", Type = "number", Nilable = false },
				{ Name = "checkedDistance", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitEffectiveLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitExists",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitFactionGroup",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
				{ Name = "checkDisplayRace", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "factionGroupTag", Type = "cstring", Nilable = false },
				{ Name = "localized", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitFullName",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
				{ Name = "unitServer", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitGUID",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "UnitGetIncomingHeals",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "healerGUID", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitGetTotalAbsorbs",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitGetTotalHealAbsorbs",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitGroupRolesAssigned",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitGroupRolesAssignedEnum",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHPPerStamina",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHasRelicSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitHasVehiclePlayerFrameUI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitHasVehicleUI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitHealthMax",
			Type = "Function",
			SecretForAttackableUnits = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHealthMissing",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Result of UnitHealthMax() - UnitHealth()" },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "usePredicted", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHealthPercent",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns percent of health remaining - can be scaled to [0, 100] for display purposes" },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "usePredicted", Type = "bool", Nilable = false, Default = true },
				{ Name = "scaleTo100", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHealthPercentColor",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "colorCurve", Type = "LuaColorCurveObject", Nilable = false },
				{ Name = "usePredicted", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "UnitHealth",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "usePredicted", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHonor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHonorLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitHonorMax",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitInAnyGroup",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInBattleground",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "UnitInOtherParty",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Checks whether this unit cannot see your party chat because it is in an instance group" },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "inOtherParty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInParty",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInPartyIsAI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInPartyShard",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "inPartyShard", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInRaid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "UnitInRange",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "inRange", Type = "bool", Nilable = false },
				{ Name = "checkedRange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInSubgroup",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInVehicle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInVehicleControlSeat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInVehicleHidesPetFrame",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsAFK",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsBattlePet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "UnitIsBattlePetCompanion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsBossMob",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsCharmed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsConnected",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isConnected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsControlling",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsCorpse",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsDND",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsDead",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsDeadOrGhost",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsEnemy",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsFeignDeath",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsFriend",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsGameObject",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsGhost",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsGroupAssistant",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAssistant", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsGroupLeader",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "partyCategory", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "isLeader", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsInMyGuild",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsInteractable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsLieutenant",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsMercenary",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsMinion",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether the unit is considered a minion of a player, such as a pet, totem, or guardian." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsOtherPlayersBattlePet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsOtherPlayersPet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsOwnerOrControllerOfUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "controllingUnit", Type = "UnitToken", Nilable = false },
				{ Name = "controlledUnit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitIsOwnerOrControllerOfUnit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsPVP",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsPVPFreeForAll",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsPVPSanctuary",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsPossessed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsQuestBoss",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsRaidOfficer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsSameServer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsSpellTarget",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If the unit is currently casting a spell, returns whether spell's target unit matches the target param. Returns false if the unit is not casting a spell or the spell has no target." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsTapDenied",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsTrivial",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsUnconscious",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsUnit",
			Type = "Function",
			SecretWhenUnitComparisonRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit1", Type = "UnitToken", Nilable = false },
				{ Name = "unit2", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsVisible",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitIsWildBattlePet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitLeadsAnyGroup",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLeader", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitName",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
				{ Name = "unitServer", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitNameUnmodified",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitName", Type = "cstring", Nilable = false },
				{ Name = "unitServer", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitNameplateShowsWidgetsOnly",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "nameplateShowsWidgetsOnly", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitNumPowerBarTimers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitOnTaxi",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitOwnerGUID",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "ownerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "UnitPVPName",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UnitPartialPower",
			Type = "Function",
			SecretWhenUnitPowerRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "partialPower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPercentHealthFromGUID",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "unitGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "percentHealth", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitPhaseReason",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "reason", Type = "PhaseReason", Nilable = true },
			},
		},
		{
			Name = "UnitPlayerControlled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitPlayerOrPetInParty",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitPlayerOrPetInRaid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
				{ Name = "partyIndex", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitPosition",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPower",
			Type = "Function",
			SecretWhenUnitPowerRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "power", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "barID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarTimerInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "expiration", Type = "number", Nilable = false },
				{ Name = "barID", Type = "number", Nilable = false },
				{ Name = "auraID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerDisplayMod",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "powerType", Type = "PowerType", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayMod", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerMax",
			Type = "Function",
			SecretWhenUnitPowerMaxRestricted = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "maxPower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerMissing",
			Type = "Function",
			SecretWhenUnitPowerRestricted = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Result of UnitPowerMax() - UnitPower()" },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerPercent",
			Type = "Function",
			SecretWhenUnitPowerRestricted = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns percent of power available - can be scaled to [0, 100] for display purposes" },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "powerType", Type = "PowerType", Nilable = true },
				{ Name = "unmodified", Type = "bool", Nilable = false, Default = false },
				{ Name = "scaleTo100", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerType",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "powerType", Type = "PowerType", Nilable = false },
				{ Name = "powerTypeToken", Type = "string", Nilable = false },
				{ Name = "rgbX", Type = "number", Nilable = false },
				{ Name = "rgbY", Type = "number", Nilable = false },
				{ Name = "rgbZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPvpClassification",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "classification", Type = "PvPUnitClassification", Nilable = true },
			},
		},
		{
			Name = "UnitQuestTrivialLevelRange",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "levelRange", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitQuestTrivialLevelRangeScaling",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "levelRange", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitRace",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "localizedRaceName", Type = "cstring", Nilable = false },
				{ Name = "englishRaceName", Type = "cstring", Nilable = false },
				{ Name = "raceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitRangedAttackPower",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "attackPower", Type = "number", Nilable = false },
				{ Name = "posBuff", Type = "number", Nilable = false },
				{ Name = "negBuff", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitRangedDamage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "speed", Type = "number", Nilable = false },
				{ Name = "minDamage", Type = "number", Nilable = false },
				{ Name = "maxDamage", Type = "number", Nilable = false },
				{ Name = "posBuff", Type = "number", Nilable = false },
				{ Name = "negBuff", Type = "number", Nilable = false },
				{ Name = "percent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitReaction",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "UnitRealmRelationship",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "realmRelationship", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "UnitSelectionColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "useExtendedColors", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "resultR", Type = "number", Nilable = false },
				{ Name = "resultG", Type = "number", Nilable = false },
				{ Name = "resultB", Type = "number", Nilable = false },
				{ Name = "resultA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSelectionType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "useExtendedColors", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "sex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitSexBase",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "sex", Type = "UnitSex", Nilable = true },
			},
		},
		{
			Name = "UnitShouldDisplayName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitShouldDisplaySpellTargetName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If the unit is currently casting a spell, returns whether the target's name should be displayed. Returns false if the unit is not casting a spell or the spell has no target." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitSpellHaste",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellTargetClass",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If the unit is currently casting a spell, returns the class of the spell's target unit. Returns nil if the unit is not casting a spell or the spell has no target." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "classFilename", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitSpellTargetName",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If the unit is currently casting a spell, returns the name of the spell's target unit. Returns nil if the unit is not casting a spell or the spell has no target." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "targetName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitStagger",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false, ConditionalSecret = true },
			},
		},
		{
			Name = "UnitStat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "currentStat", Type = "number", Nilable = false },
				{ Name = "effectiveStat", Type = "number", Nilable = false },
				{ Name = "statPositiveBuff", Type = "number", Nilable = false },
				{ Name = "statNegativeBuff", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSwitchToVehicleSeat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "virtualSeatIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "UnitTargetsVehicleInRaidUI",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitThreatLeadSituation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a threat state (0-3; representing none, yellow, orange, red) that indicates how far the provided unit is above the secondmost threat on the provided mob. If the unit is not first on threat, will always return red. Can return nil if the provided mob does not exist." },

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "mobGUID", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitThreatPercentageOfLead",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "mobGUID", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitThreatSituation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "mobGUID", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UnitTokenFromGUID",
			Type = "Function",
			SecretWhenUnitIdentityRestricted = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "unitGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitToken", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UnitTreatAsPlayerForDisplay",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "treatAsPlayer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitTrialBankedLevels",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "bankedLevels", Type = "number", Nilable = false },
				{ Name = "xpIntoCurrentLevel", Type = "number", Nilable = false },
				{ Name = "xpForNextLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitTrialXP",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitUsingVehicle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitVehicleSeatCount",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitVehicleSeatInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "virtualSeatIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "controlType", Type = "cstring", Nilable = false },
				{ Name = "occupantName", Type = "cstring", Nilable = false },
				{ Name = "serverName", Type = "cstring", Nilable = false },
				{ Name = "ejectable", Type = "bool", Nilable = false },
				{ Name = "canSwitchSeats", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitVehicleSkin",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "UnitWeaponAttackPower",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "mainHandWeaponAttackPower", Type = "number", Nilable = false },
				{ Name = "offHandWeaponAttackPower", Type = "number", Nilable = false },
				{ Name = "rangedWeaponAttackPower", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitWidgetSet",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiWidgetSet", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitXP",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitXPMax",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "WorldLootObjectExists",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActivePlayerSpecializationChanged",
			Type = "Event",
			LiteralName = "ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ArenaCooldownsUpdate",
			Type = "Event",
			LiteralName = "ARENA_COOLDOWNS_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "ArenaCrowdControlSpellUpdate",
			Type = "Event",
			LiteralName = "ARENA_CROWD_CONTROL_SPELL_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AutofollowBegin",
			Type = "Event",
			LiteralName = "AUTOFOLLOW_BEGIN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AutofollowEnd",
			Type = "Event",
			LiteralName = "AUTOFOLLOW_END",
			SynchronousEvent = true,
		},
		{
			Name = "CancelSummon",
			Type = "Event",
			LiteralName = "CANCEL_SUMMON",
			SynchronousEvent = true,
		},
		{
			Name = "ComboTargetChanged",
			Type = "Event",
			LiteralName = "COMBO_TARGET_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ConfirmBinder",
			Type = "Event",
			LiteralName = "CONFIRM_BINDER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "areaName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ConfirmSummon",
			Type = "Event",
			LiteralName = "CONFIRM_SUMMON",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "summonReason", Type = "number", Nilable = false },
				{ Name = "skippingStartExperience", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EclipseDirectionChange",
			Type = "Event",
			LiteralName = "ECLIPSE_DIRECTION_CHANGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "direction", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HearthstoneBound",
			Type = "Event",
			LiteralName = "HEARTHSTONE_BOUND",
			SynchronousEvent = true,
		},
		{
			Name = "HonorXpUpdate",
			Type = "Event",
			LiteralName = "HONOR_XP_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "IncomingResurrectChanged",
			Type = "Event",
			LiteralName = "INCOMING_RESURRECT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "IncomingSummonChanged",
			Type = "Event",
			LiteralName = "INCOMING_SUMMON_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "KnownTitlesUpdate",
			Type = "Event",
			LiteralName = "KNOWN_TITLES_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "LocalplayerPetRenamed",
			Type = "Event",
			LiteralName = "LOCALPLAYER_PET_RENAMED",
			SynchronousEvent = true,
		},
		{
			Name = "MirrorTimerPause",
			Type = "Event",
			LiteralName = "MIRROR_TIMER_PAUSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "timerName", Type = "cstring", Nilable = false },
				{ Name = "paused", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MirrorTimerStart",
			Type = "Event",
			LiteralName = "MIRROR_TIMER_START",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "timerName", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "paused", Type = "number", Nilable = false },
				{ Name = "timerLabel", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MirrorTimerStop",
			Type = "Event",
			LiteralName = "MIRROR_TIMER_STOP",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "timerName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "NeutralFactionSelectResult",
			Type = "Event",
			LiteralName = "NEUTRAL_FACTION_SELECT_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ObjectEnteredAOI",
			Type = "Event",
			LiteralName = "OBJECT_ENTERED_AOI",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "ObjectLeftAOI",
			Type = "Event",
			LiteralName = "OBJECT_LEFT_AOI",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PetBarUpdateUsable",
			Type = "Event",
			LiteralName = "PET_BAR_UPDATE_USABLE",
			SynchronousEvent = true,
		},
		{
			Name = "PetUiUpdate",
			Type = "Event",
			LiteralName = "PET_UI_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerCanGlideChanged",
			Type = "Event",
			LiteralName = "PLAYER_CAN_GLIDE_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "canGlide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerDamageDoneMods",
			Type = "Event",
			LiteralName = "PLAYER_DAMAGE_DONE_MODS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerEnterCombat",
			Type = "Event",
			LiteralName = "PLAYER_ENTER_COMBAT",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerFarsightFocusChanged",
			Type = "Event",
			LiteralName = "PLAYER_FARSIGHT_FOCUS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerFlagsChanged",
			Type = "Event",
			LiteralName = "PLAYER_FLAGS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerFocusChanged",
			Type = "Event",
			LiteralName = "PLAYER_FOCUS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerImpulseApplied",
			Type = "Event",
			LiteralName = "PLAYER_IMPULSE_APPLIED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerIsGlidingChanged",
			Type = "Event",
			LiteralName = "PLAYER_IS_GLIDING_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isGliding", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerLeaveCombat",
			Type = "Event",
			LiteralName = "PLAYER_LEAVE_COMBAT",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerLevelChanged",
			Type = "Event",
			LiteralName = "PLAYER_LEVEL_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "oldLevel", Type = "number", Nilable = false },
				{ Name = "newLevel", Type = "number", Nilable = false },
				{ Name = "real", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerLevelUp",
			Type = "Event",
			LiteralName = "PLAYER_LEVEL_UP",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "healthDelta", Type = "number", Nilable = false },
				{ Name = "powerDelta", Type = "number", Nilable = false },
				{ Name = "numNewTalents", Type = "number", Nilable = false },
				{ Name = "numNewPvpTalentSlots", Type = "number", Nilable = false },
				{ Name = "strengthDelta", Type = "number", Nilable = false },
				{ Name = "agilityDelta", Type = "number", Nilable = false },
				{ Name = "staminaDelta", Type = "number", Nilable = false },
				{ Name = "intellectDelta", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerMountDisplayChanged",
			Type = "Event",
			LiteralName = "PLAYER_MOUNT_DISPLAY_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerPvpKillsChanged",
			Type = "Event",
			LiteralName = "PLAYER_PVP_KILLS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerPvpRankChanged",
			Type = "Event",
			LiteralName = "PLAYER_PVP_RANK_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerRegenDisabled",
			Type = "Event",
			LiteralName = "PLAYER_REGEN_DISABLED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerRegenEnabled",
			Type = "Event",
			LiteralName = "PLAYER_REGEN_ENABLED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerSoftEnemyChanged",
			Type = "Event",
			LiteralName = "PLAYER_SOFT_ENEMY_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerSoftFriendChanged",
			Type = "Event",
			LiteralName = "PLAYER_SOFT_FRIEND_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerSoftInteractChanged",
			Type = "Event",
			LiteralName = "PLAYER_SOFT_INTERACT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "oldTarget", Type = "WOWGUID", Nilable = false },
				{ Name = "newTarget", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "PlayerSoftTargetInteraction",
			Type = "Event",
			LiteralName = "PLAYER_SOFT_TARGET_INTERACTION",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerSpecializationChanged",
			Type = "Event",
			LiteralName = "PLAYER_SPECIALIZATION_CHANGED",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerStartedLooking",
			Type = "Event",
			LiteralName = "PLAYER_STARTED_LOOKING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerStartedMoving",
			Type = "Event",
			LiteralName = "PLAYER_STARTED_MOVING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerStartedTurning",
			Type = "Event",
			LiteralName = "PLAYER_STARTED_TURNING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerStoppedLooking",
			Type = "Event",
			LiteralName = "PLAYER_STOPPED_LOOKING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerStoppedMoving",
			Type = "Event",
			LiteralName = "PLAYER_STOPPED_MOVING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerStoppedTurning",
			Type = "Event",
			LiteralName = "PLAYER_STOPPED_TURNING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerTargetChanged",
			Type = "Event",
			LiteralName = "PLAYER_TARGET_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerTrialXpUpdate",
			Type = "Event",
			LiteralName = "PLAYER_TRIAL_XP_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PlayerUpdateResting",
			Type = "Event",
			LiteralName = "PLAYER_UPDATE_RESTING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerXpUpdate",
			Type = "Event",
			LiteralName = "PLAYER_XP_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "PortraitsUpdated",
			Type = "Event",
			LiteralName = "PORTRAITS_UPDATED",
			UniqueEvent = true,
		},
		{
			Name = "ProvingGroundsScoreUpdate",
			Type = "Event",
			LiteralName = "PROVING_GROUNDS_SCORE_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "points", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PvpTimerUpdate",
			Type = "Event",
			LiteralName = "PVP_TIMER_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "RunePowerUpdate",
			Type = "Event",
			LiteralName = "RUNE_POWER_UPDATE",
			SecretPayloads = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "runeIndex", Type = "number", Nilable = false },
				{ Name = "added", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "RuneTypeUpdate",
			Type = "Event",
			LiteralName = "RUNE_TYPE_UPDATE",
			SecretPayloads = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "runeIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowFactionSelectUi",
			Type = "Event",
			LiteralName = "SHOW_FACTION_SELECT_UI",
			SynchronousEvent = true,
		},
		{
			Name = "SpellConfirmationPrompt",
			Type = "Event",
			LiteralName = "SPELL_CONFIRMATION_PROMPT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "effectValue", Type = "number", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "currencyTypesID", Type = "number", Nilable = false },
				{ Name = "currencyCost", Type = "number", Nilable = false },
				{ Name = "currentDifficulty", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellConfirmationTimeout",
			Type = "Event",
			LiteralName = "SPELL_CONFIRMATION_TIMEOUT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "effectValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitAbsorbAmountChanged",
			Type = "Event",
			LiteralName = "UNIT_ABSORB_AMOUNT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitAreaChanged",
			Type = "Event",
			LiteralName = "UNIT_AREA_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitAttack",
			Type = "Event",
			LiteralName = "UNIT_ATTACK",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitAttackPower",
			Type = "Event",
			LiteralName = "UNIT_ATTACK_POWER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitAttackSpeed",
			Type = "Event",
			LiteralName = "UNIT_ATTACK_SPEED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitCheatToggleEvent",
			Type = "Event",
			LiteralName = "UNIT_CHEAT_TOGGLE_EVENT",
			SynchronousEvent = true,
		},
		{
			Name = "UnitClassificationChanged",
			Type = "Event",
			LiteralName = "UNIT_CLASSIFICATION_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitCombat",
			Type = "Event",
			LiteralName = "UNIT_COMBAT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "event", Type = "cstring", Nilable = false },
				{ Name = "flagText", Type = "cstring", Nilable = false },
				{ Name = "amount", Type = "number", Nilable = false },
				{ Name = "schoolMask", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitConnection",
			Type = "Event",
			LiteralName = "UNIT_CONNECTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "isConnected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitCtrOptions",
			Type = "Event",
			LiteralName = "UNIT_CTR_OPTIONS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitDamage",
			Type = "Event",
			LiteralName = "UNIT_DAMAGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitDefense",
			Type = "Event",
			LiteralName = "UNIT_DEFENSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitDisplaypower",
			Type = "Event",
			LiteralName = "UNIT_DISPLAYPOWER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitDistanceCheckUpdate",
			Type = "Event",
			LiteralName = "UNIT_DISTANCE_CHECK_UPDATE",
			SecretPayloads = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "isInDistance", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitFaction",
			Type = "Event",
			LiteralName = "UNIT_FACTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitFlags",
			Type = "Event",
			LiteralName = "UNIT_FLAGS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitFormChanged",
			Type = "Event",
			LiteralName = "UNIT_FORM_CHANGED",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitHealAbsorbAmountChanged",
			Type = "Event",
			LiteralName = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitHealPrediction",
			Type = "Event",
			LiteralName = "UNIT_HEAL_PREDICTION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitHealth",
			Type = "Event",
			LiteralName = "UNIT_HEALTH",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitInRangeUpdate",
			Type = "Event",
			LiteralName = "UNIT_IN_RANGE_UPDATE",
			SecretPayloads = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "isInRange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitInventoryChanged",
			Type = "Event",
			LiteralName = "UNIT_INVENTORY_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitLevel",
			Type = "Event",
			LiteralName = "UNIT_LEVEL",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitLoot",
			Type = "Event",
			LiteralName = "UNIT_LOOT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "hasLoot", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitMana",
			Type = "Event",
			LiteralName = "UNIT_MANA",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitMaxHealthModifiersChanged",
			Type = "Event",
			LiteralName = "UNIT_MAX_HEALTH_MODIFIERS_CHANGED",
			SecretPayloads = true,
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "percentMaxHealthAdjusted", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitMaxhealth",
			Type = "Event",
			LiteralName = "UNIT_MAXHEALTH",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitMaxpower",
			Type = "Event",
			LiteralName = "UNIT_MAXPOWER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "powerType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitModelChanged",
			Type = "Event",
			LiteralName = "UNIT_MODEL_CHANGED",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitNameUpdate",
			Type = "Event",
			LiteralName = "UNIT_NAME_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitOtherPartyChanged",
			Type = "Event",
			LiteralName = "UNIT_OTHER_PARTY_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPet",
			Type = "Event",
			LiteralName = "UNIT_PET",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPetExperience",
			Type = "Event",
			LiteralName = "UNIT_PET_EXPERIENCE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPhase",
			Type = "Event",
			LiteralName = "UNIT_PHASE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPortraitUpdate",
			Type = "Event",
			LiteralName = "UNIT_PORTRAIT_UPDATE",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarHide",
			Type = "Event",
			LiteralName = "UNIT_POWER_BAR_HIDE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarShow",
			Type = "Event",
			LiteralName = "UNIT_POWER_BAR_SHOW",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarTimerUpdate",
			Type = "Event",
			LiteralName = "UNIT_POWER_BAR_TIMER_UPDATE",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPowerFrequent",
			Type = "Event",
			LiteralName = "UNIT_POWER_FREQUENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "powerType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitPowerPointCharge",
			Type = "Event",
			LiteralName = "UNIT_POWER_POINT_CHARGE",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitPowerUpdate",
			Type = "Event",
			LiteralName = "UNIT_POWER_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "powerType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UnitQuestLogChanged",
			Type = "Event",
			LiteralName = "UNIT_QUEST_LOG_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitRangedAttackPower",
			Type = "Event",
			LiteralName = "UNIT_RANGED_ATTACK_POWER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitRangeddamage",
			Type = "Event",
			LiteralName = "UNIT_RANGEDDAMAGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitResistances",
			Type = "Event",
			LiteralName = "UNIT_RESISTANCES",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitSpellHaste",
			Type = "Event",
			LiteralName = "UNIT_SPELL_HASTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastChannelStart",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_CHANNEL_START",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastChannelStop",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_CHANNEL_STOP",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "interruptedBy", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastChannelUpdate",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_CHANNEL_UPDATE",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastDelayed",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_DELAYED",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastEmpowerStart",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_EMPOWER_START",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastEmpowerStop",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_EMPOWER_STOP",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "complete", Type = "bool", Nilable = false },
				{ Name = "interruptedBy", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastEmpowerUpdate",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_EMPOWER_UPDATE",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastFailed",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_FAILED",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastFailedQuiet",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_FAILED_QUIET",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastInterrupted",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_INTERRUPTED",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "interruptedBy", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastInterruptible",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_INTERRUPTIBLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastNotInterruptible",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastReticleClear",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_RETICLE_CLEAR",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastReticleTarget",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_RETICLE_TARGET",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastStart",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_START",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastStop",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_STOP",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitSpellcastSucceeded",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_SUCCEEDED",
			SecretWhenSpellCastRestricted = true,
			SynchronousEvent = true,
			CallbackEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitStats",
			Type = "Event",
			LiteralName = "UNIT_STATS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitTarget",
			Type = "Event",
			LiteralName = "UNIT_TARGET",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitTargetableChanged",
			Type = "Event",
			LiteralName = "UNIT_TARGETABLE_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitThreatListUpdate",
			Type = "Event",
			LiteralName = "UNIT_THREAT_LIST_UPDATE",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitThreatSituationUpdate",
			Type = "Event",
			LiteralName = "UNIT_THREAT_SITUATION_UPDATE",
			SynchronousEvent = true,
			UniqueEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UpdateExhaustion",
			Type = "Event",
			LiteralName = "UPDATE_EXHAUSTION",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateMouseoverUnit",
			Type = "Event",
			LiteralName = "UPDATE_MOUSEOVER_UNIT",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateStealth",
			Type = "Event",
			LiteralName = "UPDATE_STEALTH",
			SynchronousEvent = true,
		},
		{
			Name = "VehicleAngleUpdate",
			Type = "Event",
			LiteralName = "VEHICLE_ANGLE_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "normalizedPitch", Type = "number", Nilable = false },
				{ Name = "radians", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PhaseReason",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Phasing", Type = "PhaseReason", EnumValue = 0 },
				{ Name = "Sharding", Type = "PhaseReason", EnumValue = 1 },
				{ Name = "WarMode", Type = "PhaseReason", EnumValue = 2 },
				{ Name = "ChromieTime", Type = "PhaseReason", EnumValue = 3 },
				{ Name = "TimerunningHwt", Type = "PhaseReason", EnumValue = 4 },
			},
		},
		{
			Name = "PvPUnitClassification",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "FlagCarrierHorde", Type = "PvPUnitClassification", EnumValue = 0 },
				{ Name = "FlagCarrierAlliance", Type = "PvPUnitClassification", EnumValue = 1 },
				{ Name = "FlagCarrierNeutral", Type = "PvPUnitClassification", EnumValue = 2 },
				{ Name = "CartRunnerHorde", Type = "PvPUnitClassification", EnumValue = 3 },
				{ Name = "CartRunnerAlliance", Type = "PvPUnitClassification", EnumValue = 4 },
				{ Name = "AssassinHorde", Type = "PvPUnitClassification", EnumValue = 5 },
				{ Name = "AssassinAlliance", Type = "PvPUnitClassification", EnumValue = 6 },
				{ Name = "OrbCarrierBlue", Type = "PvPUnitClassification", EnumValue = 7 },
				{ Name = "OrbCarrierGreen", Type = "PvPUnitClassification", EnumValue = 8 },
				{ Name = "OrbCarrierOrange", Type = "PvPUnitClassification", EnumValue = 9 },
				{ Name = "OrbCarrierPurple", Type = "PvPUnitClassification", EnumValue = 10 },
			},
		},
		{
			Name = "CorruptionEffectInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "minCorruption", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitCastingInfoResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
				{ Name = "textureID", Type = "fileID", Nilable = false },
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "castID", Type = "WOWGUID", Nilable = false },
				{ Name = "notInterruptible", Type = "bool", Nilable = false },
				{ Name = "castingSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitChannelInfoResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "displayName", Type = "cstring", Nilable = false },
				{ Name = "textureID", Type = "fileID", Nilable = false },
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
				{ Name = "isTradeskill", Type = "bool", Nilable = false },
				{ Name = "notInterruptible", Type = "bool", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "isEmpowered", Type = "bool", Nilable = false },
				{ Name = "numEmpowerStages", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitCreatureFamilyResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitCreatureTypeResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UnitPowerBarInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "barType", Type = "number", Nilable = false },
				{ Name = "minPower", Type = "number", Nilable = false },
				{ Name = "startInset", Type = "number", Nilable = false },
				{ Name = "endInset", Type = "number", Nilable = false },
				{ Name = "smooth", Type = "bool", Nilable = false },
				{ Name = "hideFromOthers", Type = "bool", Nilable = false },
				{ Name = "showOnRaid", Type = "bool", Nilable = false },
				{ Name = "opaqueSpark", Type = "bool", Nilable = false },
				{ Name = "opaqueFlash", Type = "bool", Nilable = false },
				{ Name = "anchorTop", Type = "bool", Nilable = false },
				{ Name = "forcePercentage", Type = "bool", Nilable = false },
				{ Name = "sparkUnderFrame", Type = "bool", Nilable = false },
				{ Name = "flashAtMinPower", Type = "bool", Nilable = false },
				{ Name = "fractionalCounter", Type = "bool", Nilable = false },
				{ Name = "animateNumbers", Type = "bool", Nilable = false },
				{ Name = "attachTooltipToBar", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Unit);