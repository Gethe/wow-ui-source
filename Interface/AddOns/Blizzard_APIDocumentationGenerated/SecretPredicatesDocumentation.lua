local SecretPredicates =
{
	Tables =
	{
	},
	Predicates =
	{
		{
			Name = "RequiresComparableUnitTokens",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
			Documentation = { "Guarded APIs only accept unit token pairs that can be compared with one another. For example, comparisons where either unit is 'player' or 'target' are permitted, but comparisons between 'nameplate3' and 'boss1' are not." },
		},
		{
			Name = "RequiresFontStringTextAccess",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
			Documentation = { "Guarded APIs reject access for tainted callers if the object has the secret Text aspect assigned." },
		},
		{
			Name = "RequiresScriptObjectAlphaAccess",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
		},
		{
			Name = "RequiresScriptObjectDesaturationAccess",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
		},
		{
			Name = "RequiresStatusBarDesaturationAccess",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
		},
		{
			Name = "RequiresUnitIdentityAccess",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
			Documentation = { "Guarded APIs and events require that callers have access to unit identity values. This does not raise a blocked action error - instead, protected APIs will return no values." },
		},
		{
			Name = "SecretInActivePvPMatch",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when PvP match addon restrictions are in effect." },
		},
		{
			Name = "SecretInChatMessagingLockdown",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when encounter, challenge mode, or PvP match addon restrictions are in effect, and when the player is on a communication-restricted map such as a dungeon or raid." },
		},
		{
			Name = "SecretOnRestrictedMaps",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when the player is on an addon-restricted map such as a dungeon or raid." },
		},
		{
			Name = "SecretWhenAnchoringSecret",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when an object has secret anchoring information." },
		},
		{
			Name = "SecretWhenUnitAuraRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when combat, encounter, challenge mode, or PvP match addon restrictions are in effect. Individual spells may be flagged as never or always secret, which takes priority over restrictions." },
		},
		{
			Name = "SecretWhenCooldownsRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when combat, encounter, challenge mode, or PvP match addon restrictions are in effect. Individual spells may be flagged as never or always secret, which takes priority over restrictions." },
		},
		{
			Name = "SecretWhenInCombat",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when combat addon restrictions are in effect." },
		},
		{
			Name = "SecretWhenLossOfControlInfoRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values if the subject unit is not the active player, unless they are an active spectator or commentator of a PvP match." },
		},
		{
			Name = "SecretWhenTotemSlotSecret",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when combat, encounter, challenge mode, or PvP match addon restrictions are in effect. Individual totem spell auras may be flagged as never or always secret, which takes priority over restrictions." },
		},
		{
			Name = "SecretWhenUnitSpellCastRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values if the unit being queried for cast information is not the player or their pet. Individual spells may be flagged as never or always secret, which takes priority." },
		},
		{
			Name = "SecretWhenUnitComparisonRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values based upon supplied unit tokens. Comparisons involving compound unit tokens (eg. 'boss1target') are always secret. This restriction only applies when the player is on an addon-restricted map." },
		},
		{
			Name = "SecretWhenUnitHealthMaxRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when the subject unit is attackable." },
		},
		{
			Name = "SecretWhenUnitIdentityRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when the subject unit is attackable, or if a compound unit token (eg. 'boss1target') was specified where any unit in the chain is attackable." },
		},
		{
			Name = "SecretWhenUnitPowerMaxRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when the subject unit is attackable. Individual power types may be flagged as never or always secret, which takes priority." },
		},
		{
			Name = "SecretWhenUnitPowerRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values for power types not explicitly flagged as being never secret, unless the subject unit does not have a power of this type." },
		},
		{
			Name = "SecretWhenUnitStatsRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values when access to unit auras would generally produce secret values." },
		},
		{
			Name = "SecretWhenUnitThreatStateRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values based upon supplied unit tokens. Queries where only one unit token is specified, or where one unit token is the player, their pet, or an ally while the other is a nameplate, boss, target, etc., are generally not secret." },
		},
		{
			Name = "SecretWhenUnitThreatValuesRestricted",
			Type = "Secret",
			Documentation = { "Guarded APIs and events produce secret values based upon supplied unit tokens. Queries where only one unit token is specified, or where one unit token is the player, their pet, or an ally while the other is a non-boss or nameplate target, are generally not secret." },
		},
	},
};

APIDocumentation:AddDocumentationTable(SecretPredicates);