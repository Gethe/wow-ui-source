local SimpleFrameAPI =
{
	Name = "SimpleFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AbortDrag",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "CanChangeAttribute",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canChangeAttributes", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearAlphaGradient",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearAttribute",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "cleared", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearAttributes",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "CreateFontString",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "drawLayer", Type = "DrawLayer", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "line", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "CreateLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "drawLayer", Type = "DrawLayer", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
				{ Name = "subLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "line", Type = "SimpleLine", Nilable = false },
			},
		},
		{
			Name = "CreateMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "drawLayer", Type = "DrawLayer", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
				{ Name = "subLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "maskTexture", Type = "SimpleMaskTexture", Nilable = false },
			},
		},
		{
			Name = "CreateTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "drawLayer", Type = "DrawLayer", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
				{ Name = "subLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "DesaturateHierarchy",
			Type = "Function",

			Arguments =
			{
				{ Name = "desaturation", Type = "number", Nilable = false },
				{ Name = "excludeRoot", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "DisableDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "DoesClipChildren",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "clipsChildren", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesHyperlinkPropagateToParent",
			Type = "Function",
			Documentation = { "Returns whether hyperlink events (ex. OnHyperlinkEnter, OnHyperlinkLeave, OnHyperlinkClick) are propagated to this frame's parent." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canPropagate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnableDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "EnableGamePadButton",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableGamePadStick",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableKeyboard",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ExecuteAttribute",
			Type = "Function",

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
				{ Name = "arguments", Type = "cstring", Nilable = true, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "returns", Type = "cstring", Nilable = true, StrideIndex = 1 },
			},
		},
		{
			Name = "GetAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "GetAttribute",
			Type = "Function",

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetBoundsRect",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
				{ Name = "width", Type = "uiUnit", Nilable = false },
				{ Name = "height", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetChildren",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "children", Type = "SimpleFrame", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetClampRectInsets",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetDontSavePosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "dontSave", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetEffectiveAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "effectiveAlpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "GetEffectiveScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "effectiveScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEffectivelyFlattensRenderLayers",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "flatten", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFlattensRenderLayers",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "flatten", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFrameLevel",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFrameStrata",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "strata", Type = "FrameStrata", Nilable = false },
			},
		},
		{
			Name = "GetHighestFrameLevel",
			Type = "Function",
			Documentation = { "Returns the highest framelevel of the frame and its first order children, or all children if iterateAllChildren is true." },

			Arguments =
			{
				{ Name = "iterateAllChildren", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHitRectInsets",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetHyperlinksEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumChildren",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numChildren", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumRegions",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numRegions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPropagateKeyboardInput",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "propagate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRaisedFrameLevel",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRegions",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "regions", Type = "SimpleRegion", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetResizeBounds",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "minWidth", Type = "uiUnit", Nilable = false },
				{ Name = "minHeight", Type = "uiUnit", Nilable = false },
				{ Name = "maxWidth", Type = "uiUnit", Nilable = false },
				{ Name = "maxHeight", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "frameScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetWindow",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = false },
			},
		},
		{
			Name = "HasAlphaGradient",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasAlphaGradient", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFixedFrameLevel",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasFixedFrameStrata",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Hide",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "InterceptStartDrag",
			Type = "Function",

			Arguments =
			{
				{ Name = "delegate", Type = "SimpleFrame", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsClampedToScreen",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "clampedToScreen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDrawLayerEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEventRegistered",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRegistered", Type = "bool", Nilable = false },
				{ Name = "units", Type = "string", Nilable = true, StrideIndex = 1 },
			},
		},
		{
			Name = "IsFrameBuffer",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isFrameBuffer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGamePadButtonEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGamePadStickEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHighlightLocked",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIgnoringParentAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIgnoringParentScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsKeyboardEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMovable",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isMovable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsObjectLoaded",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isLoaded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsResizable",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "resizable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShown",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsToplevel",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isTopLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUserPlaced",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isUserPlaced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingParentLevel",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "usingParentLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsVisible",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LockHighlight",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Lower",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "Raise",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "RegisterAllEvents",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "RegisterEvent",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "registered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RegisterForDrag",
			Type = "Function",

			Arguments =
			{
				{ Name = "buttons", Type = "MouseButton", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "RegisterUnitEvent",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "units", Type = "string", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "registered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RotateTextures",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false, Default = 0.5 },
				{ Name = "y", Type = "number", Nilable = false, Default = 0.5 },
			},
		},
		{
			Name = "SetAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "SetAlphaGradient",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "gradient", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "SetAttribute",
			Type = "Function",

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetAttributeNoHandler",
			Type = "Function",

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetClampRectInsets",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetClampedToScreen",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "clampedToScreen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetClipsChildren",
			Type = "Function",

			Arguments =
			{
				{ Name = "clipsChildren", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDontSavePosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "dontSave", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDrawLayerEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "isEnabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetFixedFrameLevel",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFixedFrameStrata",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFlattensRenderLayers",
			Type = "Function",

			Arguments =
			{
				{ Name = "flatten", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFrameLevel",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFrameStrata",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "strata", Type = "FrameStrata", Nilable = false },
			},
		},
		{
			Name = "SetHighlightLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHitRectInsets",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetHyperlinkPropagateToParent",
			Type = "Function",
			Documentation = { "Enables or disables propagating hyperlink events (ex. OnHyperlinkEnter, OnHyperlinkLeave, OnHyperlinkClick) to this frame's parent." },

			Arguments =
			{
				{ Name = "canPropagate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHyperlinksEnabled",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetID",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentScale",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIsFrameBuffer",
			Type = "Function",

			Arguments =
			{
				{ Name = "isFrameBuffer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMovable",
			Type = "Function",

			Arguments =
			{
				{ Name = "movable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPropagateKeyboardInput",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "propagate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResizable",
			Type = "Function",

			Arguments =
			{
				{ Name = "resizable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResizeBounds",
			Type = "Function",

			Arguments =
			{
				{ Name = "minWidth", Type = "uiUnit", Nilable = false },
				{ Name = "minHeight", Type = "uiUnit", Nilable = false },
				{ Name = "maxWidth", Type = "uiUnit", Nilable = true },
				{ Name = "maxHeight", Type = "uiUnit", Nilable = true },
			},
		},
		{
			Name = "SetScale",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetShown",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "shown", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetToplevel",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "topLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUserPlaced",
			Type = "Function",

			Arguments =
			{
				{ Name = "userPlaced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUsingParentLevel",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "usingParentLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
			},
		},
		{
			Name = "Show",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "StartMoving",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "alwaysStartFromMouse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "StartSizing",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
				{ Name = "resizePoint", Type = "FramePoint", Nilable = true },
				{ Name = "alwaysStartFromMouse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "StopMovingOrSizing",
			Type = "Function",
			IsProtectedFunction = true,

			Arguments =
			{
			},
		},
		{
			Name = "UnlockHighlight",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "UnregisterAllEvents",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "UnregisterEvent",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "registered", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameAPI);