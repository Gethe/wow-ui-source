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
			SecretArguments = "NotAllowed",

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
			SecretArguments = "NotAllowed",

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
			SecretArguments = "NotAllowed",

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
			SecretArguments = "NotAllowed",

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
			SecretArguments = "NotAllowed",

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
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "desaturation", Type = "number", Nilable = false },
				{ Name = "excludeRoot", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "DisableDrawLayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "EnableGamePadButton",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableGamePadStick",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableKeyboard",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ExecuteAttribute",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretReturnsForAspect = { Enum.SecretAspect.Alpha },

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
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

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
				{ Name = "left", Type = "uiUnit", Nilable = false, ConditionalSecret = true },
				{ Name = "bottom", Type = "uiUnit", Nilable = false, ConditionalSecret = true },
				{ Name = "width", Type = "uiUnit", Nilable = false, ConditionalSecret = true },
				{ Name = "height", Type = "uiUnit", Nilable = false, ConditionalSecret = true },
			},
		},
		{
			Name = "GetChildren",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Hierarchy },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Alpha },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Scale },

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
			SecretReturnsForAspect = { Enum.SecretAspect.FrameLevel },

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
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the highest framelevel of the frame and its first order children, or all children if iterateAllChildren is true." },

			Arguments =
			{
				{ Name = "iterateAllChildren", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false, ConditionalSecret = true },
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
			SecretReturnsForAspect = { Enum.SecretAspect.ID },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Hierarchy },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Hierarchy },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Hierarchy },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Scale },

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
			SecretArguments = "AllowedWhenUntainted",

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
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

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
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "IsIgnoringChildrenForBounds",
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
			SecretReturnsForAspect = { Enum.SecretAspect.Shown },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Toplevel },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Shown },

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "RegisterEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "cb", Type = "FrameEventCallbackType", Nilable = false },
			},

			Returns =
			{
				{ Name = "registered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RegisterForDrag",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "buttons", Type = "MouseButton", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "RegisterUnitEvent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "RegisterUnitEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "cb", Type = "FrameEventCallbackType", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "SetAlphaFromBoolean",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "value", Type = "bool", Nilable = false },
				{ Name = "alphaIfTrue", Type = "SingleColorValue", Nilable = false, Default = 255 },
				{ Name = "alphaIfFalse", Type = "SingleColorValue", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetAlphaGradient",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "gradient", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "SetAttribute",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "attributeName", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetAttributeNoHandler",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "clampedToScreen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetClipsChildren",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clipsChildren", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDontSavePosition",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dontSave", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDrawLayerEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFixedFrameStrata",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isFixed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFlattensRenderLayers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "flatten", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFrameLevel",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArgumentsAddAspect = { Enum.SecretAspect.FrameLevel },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "frameLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFrameStrata",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "strata", Type = "FrameStrata", Nilable = false },
			},
		},
		{
			Name = "SetHighlightLocked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetHitRectInsets",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetID",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArgumentsAddAspect = { Enum.SecretAspect.ID },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentAlpha",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentScale",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoringChildrenForBounds",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIsFrameBuffer",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "isFrameBuffer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMovable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "movable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPropagateKeyboardInput",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "propagate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResizable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "resizable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetResizeBounds",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.Scale },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetShown",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArgumentsAddAspect = { Enum.SecretAspect.Shown },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "shown", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetToplevel",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArgumentsAddAspect = { Enum.SecretAspect.Toplevel },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "topLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUserPlaced",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "userPlaced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUsingParentLevel",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "usingParentLevel", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetWindow",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "alwaysStartFromMouse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "StartSizing",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
		{
			Name = "FrameEventCallbackType",
			Type = "CallbackType",
		},
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameAPI);