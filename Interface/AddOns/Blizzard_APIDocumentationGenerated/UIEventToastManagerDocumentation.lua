local UIEventToastManager =
{
	Name = "UIEventToastManagerInfo",
	Type = "System",
	Namespace = "C_EventToastManager",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetLevelUpDisplayToastsFromLevel",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "toastInfo", Type = "table", InnerType = "EventToastInfo", Nilable = false },
			},
		},
		{
			Name = "GetNextToastToDisplay",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "toastInfo", Type = "EventToastInfo", Nilable = false },
			},
		},
		{
			Name = "RemoveCurrentToast",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "DisplayEventToastLink",
			Type = "Event",
			LiteralName = "DISPLAY_EVENT_TOAST_LINK",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DisplayEventToasts",
			Type = "Event",
			LiteralName = "DISPLAY_EVENT_TOASTS",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "EventToastInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "eventToastID", Type = "number", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "subtitle", Type = "string", Nilable = false },
				{ Name = "instructionText", Type = "string", Nilable = false },
				{ Name = "iconFileID", Type = "fileID", Nilable = false },
				{ Name = "subIcon", Type = "textureAtlas", Nilable = true },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "qualityString", Type = "string", Nilable = true },
				{ Name = "quality", Type = "number", Nilable = true },
				{ Name = "eventType", Type = "EventToastEventType", Nilable = false },
				{ Name = "displayType", Type = "EventToastDisplayType", Nilable = false },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = false },
				{ Name = "sortOrder", Type = "number", Nilable = false },
				{ Name = "time", Type = "number", Nilable = true },
				{ Name = "uiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "extraUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "titleTooltip", Type = "string", Nilable = true },
				{ Name = "subtitleTooltip", Type = "string", Nilable = true },
				{ Name = "titleTooltipUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "subtitleTooltipUiWidgetSetID", Type = "number", Nilable = true },
				{ Name = "hideDefaultAtlas", Type = "bool", Nilable = true },
				{ Name = "showSoundKitID", Type = "number", Nilable = true },
				{ Name = "hideSoundKitID", Type = "number", Nilable = true },
				{ Name = "colorTint", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
				{ Name = "flags", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIEventToastManager);