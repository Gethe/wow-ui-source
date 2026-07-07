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
			Name = "RequiresDeclassifiedUnitIdentity",
			Type = "Precondition",
			FailureMode = "ReturnWithError",
			Documentation = { "Guarded APIs and events require that callers have access to the identity of a supplied unit token." },
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
			FailureMode = "ReturnWithError",
		},
		{
			Name = "RequiresScriptObjectDesaturationAccess",
			Type = "Precondition",
			FailureMode = "ReturnWithError",
		},
		{
			Name = "RequiresStatusBarDesaturationAccess",
			Type = "Precondition",
			FailureMode = "ReturnWithError",
		},
		{
			Name = "RequiresUnitIdentityAccess",
			Type = "Precondition",
			FailureMode = "ReturnWithError",
			Documentation = { "Guarded APIs and events require that callers have access to unit identity values. This does not raise a blocked action error - instead, protected APIs will return no values." },
		},
	},
};

APIDocumentation:AddDocumentationTable(SecretPredicates);