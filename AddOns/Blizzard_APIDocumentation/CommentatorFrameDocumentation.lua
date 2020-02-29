local CommentatorFrame =
{
	Name = "CommentatorFrame",
	Type = "System",
	Namespace = "C_Commentator",

	Functions =
	{
		{
			Name = "AddPlayerOverrideName",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerName", Type = "string", Nilable = false },
				{ Name = "overrideName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AddTrackedDefensiveAuras",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "AddTrackedOffensiveAuras",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "AreTeamsSwapped",
			Type = "Function",

			Returns =
			{
				{ Name = "teamsAreSwapped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanUseCommentatorCheats",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseCommentatorCheats", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearCameraTarget",
			Type = "Function",
		},
		{
			Name = "ClearFollowTarget",
			Type = "Function",
		},
		{
			Name = "ClearLookAtTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "lookAtIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "EnterInstance",
			Type = "Function",
		},
		{
			Name = "ExitInstance",
			Type = "Function",
		},
		{
			Name = "FollowPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "forceInstantTransition", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "FollowUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ForceFollowTransition",
			Type = "Function",
		},
		{
			Name = "GetAdditionalCameraWeight",
			Type = "Function",

			Returns =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAdditionalCameraWeightByToken",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllPlayerOverrideNames",
			Type = "Function",

			Returns =
			{
				{ Name = "nameEntries", Type = "table", InnerType = "NameOverrideEntry", Nilable = false },
			},
		},
		{
			Name = "GetCamera",
			Type = "Function",

			Returns =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "fov", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraCollision",
			Type = "Function",

			Returns =
			{
				{ Name = "isColliding", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCameraPosition",
			Type = "Function",

			Returns =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentMapID",
			Type = "Function",

			Returns =
			{
				{ Name = "mapID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDampeningPercent",
			Type = "Function",

			Returns =
			{
				{ Name = "percentage", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDistanceBeforeForcedHorizontalConvergence",
			Type = "Function",

			Returns =
			{
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDurationToForceHorizontalConvergence",
			Type = "Function",

			Returns =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExcludeDistance",
			Type = "Function",

			Returns =
			{
				{ Name = "excludeDistance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHardlockWeight",
			Type = "Function",

			Returns =
			{
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHorizontalAngleThresholdToSmooth",
			Type = "Function",

			Returns =
			{
				{ Name = "angle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInstanceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapIndex", Type = "number", Nilable = false },
				{ Name = "instanceIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "mapName", Type = "string", Nilable = true },
				{ Name = "status", Type = "number", Nilable = false },
				{ Name = "instanceIDLow", Type = "number", Nilable = false },
				{ Name = "instanceIDHigh", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLookAtLerpAmount",
			Type = "Function",

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMapInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "teamSize", Type = "number", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "numInstances", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumPlayersPerTeam",
			Type = "Function",

			Returns =
			{
				{ Name = "maxNumPlayersPerTeam", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumTeams",
			Type = "Function",

			Returns =
			{
				{ Name = "maxNumTeams", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMode",
			Type = "Function",

			Returns =
			{
				{ Name = "commentatorMode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMsToHoldForHorizontalMovement",
			Type = "Function",

			Returns =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMsToHoldForVerticalMovement",
			Type = "Function",

			Returns =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMsToSmoothHorizontalChange",
			Type = "Function",

			Returns =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMsToSmoothVerticalChange",
			Type = "Function",

			Returns =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumMaps",
			Type = "Function",

			Returns =
			{
				{ Name = "numMaps", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumPlayers",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "numPlayers", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerCooldownInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "enable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPlayerCrowdControlInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "expiration", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerCrowdControlInfoByUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "expiration", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerFlagInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFlag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPlayerInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "faction", Type = "number", Nilable = false },
				{ Name = "specialization", Type = "number", Nilable = false },
				{ Name = "damageDone", Type = "number", Nilable = false },
				{ Name = "damageTaken", Type = "number", Nilable = false },
				{ Name = "healingDone", Type = "number", Nilable = false },
				{ Name = "healingTaken", Type = "number", Nilable = false },
				{ Name = "kills", Type = "number", Nilable = false },
				{ Name = "deaths", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerOverrideName",
			Type = "Function",

			Arguments =
			{
				{ Name = "originalName", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "overrideName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetPlayerSpellCharges",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "charges", Type = "number", Nilable = false },
				{ Name = "maxCharges", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPositionLerpAmount",
			Type = "Function",

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSmoothFollowTransitioning",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSoftlockWeight",
			Type = "Function",

			Returns =
			{
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpeedFactor",
			Type = "Function",

			Returns =
			{
				{ Name = "factor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStartLocation",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "pos", Type = "table", Mixin = "Vector3DMixin", Nilable = false },
			},
		},
		{
			Name = "GetTeamHighlightColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "highlightColorR", Type = "number", Nilable = false },
				{ Name = "highlightColorG", Type = "number", Nilable = false },
				{ Name = "highlightColorB", Type = "number", Nilable = false },
				{ Name = "highlightColorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTimeLeftInMatch",
			Type = "Function",

			Returns =
			{
				{ Name = "timeLeft", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetTrackedDefensiveCooldowns",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackedDefensiveCooldowns", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetTrackedOffensiveCooldowns",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "trackedCooldowns", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetUnitTeamIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWargameInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "listID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "minPlayers", Type = "number", Nilable = false },
				{ Name = "maxPlayers", Type = "number", Nilable = false },
				{ Name = "isArena", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasTrackedAuras",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasOffensiveAura", Type = "bool", Nilable = false },
				{ Name = "hasDefensiveAura", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSmartCameraLocked",
			Type = "Function",

			Returns =
			{
				{ Name = "isSmartCameraLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpectating",
			Type = "Function",

			Returns =
			{
				{ Name = "isSpectating", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackedDefensiveAura",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isDefensiveTrigger", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackedDefensiveCooldown",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTrackedCooldown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackedOffensiveAura",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOffensiveTrigger", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrackedOffensiveCooldown",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTrackedCooldown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingSmartCamera",
			Type = "Function",

			Returns =
			{
				{ Name = "isUsingSmartCamera", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LookAtPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "factionIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "lookAtIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "RemoveAllOverrideNames",
			Type = "Function",
		},
		{
			Name = "RemovePlayerOverrideName",
			Type = "Function",

			Arguments =
			{
				{ Name = "originalPlayerName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestPlayerCooldownInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetFoVTarget",
			Type = "Function",
		},
		{
			Name = "ResetTrackedAuras",
			Type = "Function",
		},
		{
			Name = "SetAdditionalCameraWeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "teamIndex", Type = "number", Nilable = false },
				{ Name = "playerIndex", Type = "number", Nilable = false },
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetAdditionalCameraWeightByToken",
			Type = "Function",

			Arguments =
			{
				{ Name = "token", Type = "string", Nilable = false },
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBlacklistedAuras",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetBlacklistedCooldowns",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "fov", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraCollision",
			Type = "Function",

			Arguments =
			{
				{ Name = "collide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCameraPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
				{ Name = "snapToLocation", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCheatsEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enableCheats", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDistanceBeforeForcedHorizontalConvergence",
			Type = "Function",

			Arguments =
			{
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetDurationToForceHorizontalConvergence",
			Type = "Function",

			Arguments =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetExcludeDistance",
			Type = "Function",

			Arguments =
			{
				{ Name = "excludeDistance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFollowCameraSpeeds",
			Type = "Function",

			Arguments =
			{
				{ Name = "elasticSpeed", Type = "number", Nilable = false },
				{ Name = "minSpeed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetHardlockWeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetHorizontalAngleThresholdToSmooth",
			Type = "Function",

			Arguments =
			{
				{ Name = "angle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLookAtLerpAmount",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMapAndInstanceIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapIndex", Type = "number", Nilable = false },
				{ Name = "instanceIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMouseDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMoveSpeed",
			Type = "Function",

			Arguments =
			{
				{ Name = "newSpeed", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMsToHoldForHorizontalMovement",
			Type = "Function",

			Arguments =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMsToHoldForVerticalMovement",
			Type = "Function",

			Arguments =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMsToSmoothHorizontalChange",
			Type = "Function",

			Arguments =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMsToSmoothVerticalChange",
			Type = "Function",

			Arguments =
			{
				{ Name = "ms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPositionLerpAmount",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetRequestedDefensiveCooldowns",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetRequestedOffensiveCooldowns",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SetSmartCameraLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSmoothFollowTransitioning",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSoftlockWeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "weight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpeedFactor",
			Type = "Function",

			Arguments =
			{
				{ Name = "factor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTargetHeightOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offset", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetUseSmartCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "useSmartCamera", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SnapCameraLookAtPoint",
			Type = "Function",
		},
		{
			Name = "StartWargame",
			Type = "Function",

			Arguments =
			{
				{ Name = "listID", Type = "number", Nilable = false },
				{ Name = "teamSize", Type = "number", Nilable = false },
				{ Name = "tournamentRules", Type = "bool", Nilable = false },
				{ Name = "teamOneCaptain", Type = "string", Nilable = false },
				{ Name = "teamTwoCaptain", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SwapTeamSides",
			Type = "Function",
		},
		{
			Name = "ToggleCheats",
			Type = "Function",
		},
		{
			Name = "UpdateMapInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetPlayer", Type = "string", Nilable = true },
			},
		},
		{
			Name = "UpdatePlayerInfo",
			Type = "Function",
		},
		{
			Name = "ZoomIn",
			Type = "Function",
		},
		{
			Name = "ZoomOut",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "CommentatorEnterWorld",
			Type = "Event",
			LiteralName = "COMMENTATOR_ENTER_WORLD",
		},
		{
			Name = "CommentatorImmediateFovUpdate",
			Type = "Event",
			LiteralName = "COMMENTATOR_IMMEDIATE_FOV_UPDATE",
			Payload =
			{
				{ Name = "fov", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CommentatorMapUpdate",
			Type = "Event",
			LiteralName = "COMMENTATOR_MAP_UPDATE",
		},
		{
			Name = "CommentatorPlayerNameOverrideUpdate",
			Type = "Event",
			LiteralName = "COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE",
			Payload =
			{
				{ Name = "nameToOverride", Type = "string", Nilable = false },
				{ Name = "overrideName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CommentatorPlayerUpdate",
			Type = "Event",
			LiteralName = "COMMENTATOR_PLAYER_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "NameOverrideEntry",
			Type = "Structure",
			Fields =
			{
				{ Name = "originalName", Type = "string", Nilable = false },
				{ Name = "overrideName", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CommentatorFrame);