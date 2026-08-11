local SimpleFrameScriptObjectConstants =
{
	Tables =
	{
		{
			Name = "OnUpdateMode",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Disabled", Type = "OnUpdateMode", EnumValue = 0, Documentation = { "Disable OnUpdate execution." } },
				{ Name = "RunWhenVisible", Type = "OnUpdateMode", EnumValue = 1, Documentation = { "Run OnUpdate only while object is visible." } },
				{ Name = "RunWhenVisibleOnce", Type = "OnUpdateMode", EnumValue = 2, Documentation = { "Run OnUpdate once while object is visible; resets to Disabled before running." } },
				{ Name = "RunOnce", Type = "OnUpdateMode", EnumValue = 3, Documentation = { "Run OnUpdate once regardless of visibility; resets to Disabled before running." } },
				{ Name = "RunAlways", Type = "OnUpdateMode", EnumValue = 4, Documentation = { "Run OnUpdate regardless of visibility." } },
			},
		},
		{
			Name = "ScriptBindingType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Postcall", Type = "ScriptBindingType", EnumValue = 2 },
				{ Name = "Precall", Type = "ScriptBindingType", EnumValue = 0 },
				{ Name = "Extrinsic", Type = "ScriptBindingType", EnumValue = 1 },
			},
		},
		{
			Name = "ScriptObjectAccessRestriction",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DenyTaintedAccessWhenAurasAreSecret", Type = "ScriptObjectAccessRestriction", EnumValue = 1, Documentation = { "Denies access to this script object from tainted execution while aura information is secret." } },
			},
		},
		{
			Name = "ScriptObjectMetatable",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Public", Type = "ScriptObjectMetatable", EnumValue = 0 },
				{ Name = "Forbidden", Type = "ScriptObjectMetatable", EnumValue = 1 },
			},
		},
		{
			Name = "ScriptObjectPartition",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Public", Type = "ScriptObjectPartition", EnumValue = 0 },
				{ Name = "Forbidden", Type = "ScriptObjectPartition", EnumValue = 1 },
			},
		},
		{
			Name = "ScriptObjectPropagationPath",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Hierarchy", Type = "ScriptObjectPropagationPath", EnumValue = 0, Documentation = { "Propagation through script object hierarchy relationships, such as parent-child ownership." } },
				{ Name = "Layout", Type = "ScriptObjectPropagationPath", EnumValue = 1, Documentation = { "Propagation through layout dependency relationships, such as frames anchored relative to one another." } },
			},
		},
	},
	Predicates =
	{
		{
			Name = "RequiresAssignableScript",
			Type = "Precondition",
			FailureMode = "Error",
			Documentation = { "Requires that this object permit assignment of scripts of this type. May fail for reasons such as the script type not being supported, or secret aspects blocking assignments." },
		},
		{
			Name = "RequiresSupportedScript",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
			Documentation = { "Requires a valid script type supported by this object. If not supported, functions will return no values." },
		},
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameScriptObjectConstants);