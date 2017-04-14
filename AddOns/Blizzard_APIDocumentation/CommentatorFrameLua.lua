local CommentatorFrameLua =
{
	Name = "CommentatorFrame",
	Type = "System",
	Namespace = "C_Commentator",

	Functions =
	{
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
			Name = "GetCamera",
			Type = "Function",

			Returns =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
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
			Name = "GetMode",
			Type = "Function",

			Returns =
			{
				{ Name = "commentatorMode", Type = "number", Nilable = false },
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
			Name = "IsSmartCameraLocked",
			Type = "Function",

			Returns =
			{
				{ Name = "isSmartCameraLocked", Type = "bool", Nilable = false },
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
			Name = "SetCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "xPos", Type = "number", Nilable = false },
				{ Name = "yPos", Type = "number", Nilable = false },
				{ Name = "zPos", Type = "number", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
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
			Name = "SetMapAndInstanceIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapIndex", Type = "number", Nilable = false },
				{ Name = "instanceIndex", Type = "number", Nilable = false },
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
			Name = "SetSmartCameraLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CommentatorFrameLua);