local SwingTimer =
{
	Name = "SwingTimer",
	Type = "System",
	Namespace = "C_SwingTimer",
	Environment = "All",

	Functions =
	{
		{
			Name = "EnableRangeCheck",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Used in conjunction with PlayerSwingRangeUpdate to inform the UI when the current target goes in or out of auto attack range." },

			Arguments =
			{
				{ Name = "swingType", Type = "PlayerSwingType", Nilable = false },
				{ Name = "enable", Type = "bool", Nilable = false, Documentation = { "True if changes in range for the swing type should dispatch PlayerSwingRangeUpdate. False if the swing type no longer needs the event." } },
			},
		},
		{
			Name = "IsTargetWithinSwingRange",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Whether the current target is within range of the player's auto attack for the given swing type. Auto attacks only ever apply to the current target, so no other unit can be queried." },

			Arguments =
			{
				{ Name = "swingType", Type = "PlayerSwingType", Nilable = false },
			},

			Returns =
			{
				{ Name = "isInRange", Type = "bool", Nilable = true, Documentation = { "Nil when no range check could be made, for example there is no target, the target cannot be attacked, or no weapon is equipped for the swing type. Nil must not be treated as out of range." } },
			},
		},
	},

	Events =
	{
		{
			Name = "PlayerSwing",
			Type = "Event",
			LiteralName = "PLAYER_SWING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "swingDuration", Type = "number", Nilable = false },
				{ Name = "swingType", Type = "PlayerSwingType", Nilable = false },
			},
		},
		{
			Name = "PlayerSwingRangeUpdate",
			Type = "Event",
			LiteralName = "PLAYER_SWING_RANGE_UPDATE",
			SynchronousEvent = true,
			Documentation = { "Only signaled for swing types that have an active range check. See C_SwingTimer.EnableRangeCheck." },
			Payload =
			{
				{ Name = "swingType", Type = "PlayerSwingType", Nilable = false },
				{ Name = "isInRange", Type = "bool", Nilable = false, Documentation = { "Whether the current target is within auto attack range. Should not be used if the 'checksRange' parameter is false." } },
				{ Name = "checksRange", Type = "bool", Nilable = false, Documentation = { "Can be false if a range check was not made for any reason, for example there is not a current target." } },
			},
		},
	},

	Tables =
	{
		{
			Name = "PlayerSwingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "MainHand", Type = "PlayerSwingType", EnumValue = 0 },
				{ Name = "OffHand", Type = "PlayerSwingType", EnumValue = 1 },
				{ Name = "Ranged", Type = "PlayerSwingType", EnumValue = 2 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SwingTimer);