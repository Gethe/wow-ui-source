local ForbiddenAspectConstants =
{
	Tables =
	{
		{
			Name = "ForbiddenAspect",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "SetToDefaults", Type = "ForbiddenAspect", EnumValue = 1, Documentation = { "Restricts resetting this object to a default state. Implied automatically when any other forbidden aspect is set." } },
				{ Name = "ScriptBindings", Type = "ForbiddenAspect", EnumValue = 2, Documentation = { "Restricts querying, replacement, or hooks of scripts on this object." } },
				{ Name = "UntrustedScriptExecution", Type = "ForbiddenAspect", EnumValue = 4, Documentation = { "Restricts execution of all scripts for this object. Propagates to any children of this object." } },
				{ Name = "UntrustedLayoutScriptExecution", Type = "ForbiddenAspect", EnumValue = 8, Documentation = { "Restricts execution of layout scripts (eg. OnSizeChanged) for this object. Propagates to any children of this object, and anything anchored to to this object." } },
				{ Name = "EventRegistrations", Type = "ForbiddenAspect", EnumValue = 16, Documentation = { "Restricts querying or modifying registered script events for this object." } },
				{ Name = "AlwaysPropagateInput", Type = "ForbiddenAspect", EnumValue = 32, Documentation = { "Forces propagation of mouse and keypress input for this object. Propagates to any children." } },
				{ Name = "ScriptedInput", Type = "ForbiddenAspect", EnumValue = 64, Documentation = { "Restricts APIs that trigger synthetic input interactions on objects from Lua scripts." } },
				{ Name = "QueryFocus", Type = "ForbiddenAspect", EnumValue = 128, Documentation = { "Restricts APIs that query input focus state." } },
				{ Name = "ChangeAnimationTarget", Type = "ForbiddenAspect", EnumValue = 256, Documentation = { "Restricts APIs that can change the target object of an animation." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ForbiddenAspectConstants);