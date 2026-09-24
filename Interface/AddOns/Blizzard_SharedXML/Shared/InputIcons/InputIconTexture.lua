-----------------------------
-- InputDeviceIconSetMixin --
-----------------------------
local InputDeviceIconSetMixin = {};	-- Holds the textures used by the InputIconTextureMixin for a given input device.

--[[
	Representation of _how_ this InputIcon can be used. Certain texture state
	transitions will be blocked base on the usability state.

	* "Pressable" allows for transition between Normal / Hover / Pressed
	* "Focused" locks the texture to "active" and ignores other transitions
	* "Disabled" locks the texture to "disabled" and ignores other transitions
]]
local InputIconUsableState = {
	Pressable = 1,
	Focused = 2,
	Disabled = 3,
}

--[[
	The state that drives the literal texture being rendered.

	Texture state transitions will be constrained by the InputIconUsableState rules.
]]
local InputIconTextureState = {
	Normal = 1,
	Hover = 2,
	Pressed = 3,
	Active = 4,
	Disabled = 5,
}

--[[
	The default texture state to set when first entering a usable state.
]]
local DefaultTextureStatesByUsable = {
	[InputIconUsableState.Pressable] = InputIconTextureState.Normal,
	[InputIconUsableState.Focused] = InputIconTextureState.Active,
	[InputIconUsableState.Disabled] = InputIconTextureState.Disabled,
}

--[[
	Which variation of the a button propt to utilize.

	Design intent:
	* 'Standard' is the icon variants without any dropshadow)
	* 'WithShadow_Game' is a variant that has a dropshadow, which will be used outside of glue screens
	* 'WithShadow_Glue' is a variant that has a dropshadow, which will be used when in glue screens

	Current reality:
	* Replacement art was only provided _with_ dropshadows. This needs to be rectified for launch, but the
	code remains - it was was deemed acceptable for BlizzCon.
]]
local InputIconVariant = {
	Standard = 1,
	WithShadow_Game = 2,
	WithShadow_Glue = 3,
}

function InputDeviceIconSetMixin:Init()
	self.inputIconPromptTextures = {};
end

function InputDeviceIconSetMixin:GetInputIconTexturesForKey(inputKey)
	if not self.inputIconPromptTextures[inputKey] then
		return;
	end

	--[[ Code remains in place to support shadowed and unshadowed variants of icon
		textures. Variable shadow versions of each are also implemented, one for
		glue screens, and one for game screens. This variable (and code defining it)
		exists to maintain that functionality.

		At time of writing, only full-shadowed icons exist, and are used universally.
		We shall call this 'Standard' for now, and otherwise revisit them when
		proper icons are ready.

		Naming conventions are inconsistently applied, and I get the feeling that art
		is completely unaware that these multiple variations exist, so I'm holding off
		on implementing the variations / predicting their atlas keys until that
		discussion is had.
	]]
	local variant = InputIconVariant.Standard;
	if self.useDropShadow then
		if InGlue() then
			variant = InputIconVariant.WithShadow_Glue;
		else
			variant = InputIconVariant.WithShadow_Game;
		end
	end

	--[[ Until the above is revisited, this assert is impractical, but I'm leaving it here
		because I do think it should exist when that day arrives. For now, fall back
		to the standard variation if a variant is not found. ]]
	-- assert(self.inputIconPromptTextures[inputKey][variant], "Variant not found.");
	return self.inputIconPromptTextures[inputKey][variant] or self.inputIconPromptTextures[inputKey][InputIconVariant.Standard];
end

function InputDeviceIconSetMixin:GetInputIconTextureSetForKey(inputKey)
	if self.inputIconPromptTextures[inputKey] == nil then
		self.inputIconPromptTextures[inputKey] = {};

		for _, variant in pairs(InputIconVariant) do
			self.inputIconPromptTextures[inputKey][variant] = {}
			for _, state in pairs(InputIconTextureState) do
				self.inputIconPromptTextures[inputKey][variant][state] = {}
			end
		end
	end

	return self.inputIconPromptTextures[inputKey];
end

function InputDeviceIconSetMixin:SetInputIconTextureForKey(inputKey, variant, state, promptIconTexture)
	local set = self:GetInputIconTextureSetForKey(inputKey);
	set[variant][state] = promptIconTexture;
end

local INPUT_DEVICE_INPUT_ICON_TEXTURE_SETS =
{
	Generic = CreateAndInitFromMixin(InputDeviceIconSetMixin),
	Letters = CreateAndInitFromMixin(InputDeviceIconSetMixin),
	Shapes = CreateAndInitFromMixin(InputDeviceIconSetMixin),
	Reverse = CreateAndInitFromMixin(InputDeviceIconSetMixin),
}

for _, key in ipairs({"Generic", "Letters"}) do
	local iconSet = INPUT_DEVICE_INPUT_ICON_TEXTURE_SETS[key];
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-trigger-lt-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-trigger-lt-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-trigger-lt-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-trigger-lt-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-trigger-lt-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-trigger-rt-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-trigger-rt-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-trigger-rt-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-trigger-rt-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-trigger-rt-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-trigger-lb-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-trigger-lb-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-trigger-lb-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-trigger-lb-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-trigger-lb-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-trigger-rb-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-trigger-rb-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-trigger-rb-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-trigger-rb-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-trigger-rb-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadall-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadall-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadall-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadall-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadall-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadleftright-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadleftright-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadleftright-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadleftright-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadleftright-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadupdown-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadupdown-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadupdown-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadupdown-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadupdown-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadup-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadup-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadup-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadup-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadup-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpaddown-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpaddown-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpaddown-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpaddown-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpaddown-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadleft-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadleft-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadleft-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadleft-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadleft-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-dpadright-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-dpadright-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-dpadright-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-dpadright-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-dpadright-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-buttony-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-buttony-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-buttony-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-buttony-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-buttony-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-buttona-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-buttona-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-buttona-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-buttona-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-buttona-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-buttonx-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-buttonx-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-buttonx-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-buttonx-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-buttonx-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-buttonb-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-buttonb-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-buttonb-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-buttonb-focus");
	-- NOTE: Typo in texture name.
	iconSet:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-buttonb-isabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stick-l-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stick-l-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stick-l-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stick-l-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stick-l-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stick-r-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stick-r-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stick-r-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stick-r-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stick-r-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stick-r3-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stick-r3-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stick-r3-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stick-r3-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stick-r3-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stick-l3-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stick-l3-over");
	-- NOTE: Typo in texture name
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stick-l3_down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stick-l3-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stick-l3-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stick-updown-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stick-updown-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stick-updown-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stick-updown-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stick-updown-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-stickr-leftright-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-stickr-leftright-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-stickr-leftright-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-stickr-leftright-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-stickr-leftright-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-menu-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-menu-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-menu-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-menu-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-menu-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-xblogo-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-xblogo-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-xblogo-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-xblogo-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-xblogo-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-xbox1-view-normal");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-xbox1-view-over");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-xbox1-view-down");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-xbox1-view-focus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-xbox1-view-disabled");

	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-plus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-plus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-plus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-plus");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-plus");

	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-slash");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-slash");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-slash");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-slash");
	iconSet:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-slash");
end

local shapes = INPUT_DEVICE_INPUT_ICON_TEXTURE_SETS.Shapes;
do
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-triggerl2-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-triggerl2-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-triggerl2-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-triggerl2-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-triggerl2-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-triggerr2-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-triggerr2-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-triggerr2-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-triggerr2-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-triggerr2-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-triggerl1-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-triggerl1-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-triggerl1-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-triggerl1-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-triggerl1-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-triggerr1-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-triggerr1-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-triggerr1-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-triggerr1-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-triggerr1-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadall-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadall-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadall-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadall-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadall-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadleftright-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadleftright-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadleftright-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadleftright-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadleftright-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadupdown-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadupdown-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadupdown-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadupdown-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadupdown-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadup-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadup-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadup-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadup-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadup-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpaddown-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpaddown-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpaddown-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpaddown-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpaddown-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadleft-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadleft-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadleft-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadleft-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadleft-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-dpadright-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-dpadright-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-dpadright-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-dpadright-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-dpadright-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-buttontriangle-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-buttontriangle-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-buttontriangle-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-buttontriangle-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-buttontriangle-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-buttoncrox-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-buttoncrox-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-buttoncrox-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-buttoncrox-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-buttoncrox-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-buttonsquare-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-buttonsquare-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-buttonsquare-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-buttonsquare-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-buttonsquare-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-buttoncircle-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-buttoncircle-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-buttoncircle-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-buttoncircle-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-buttoncircle-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickl-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickl-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickl-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickl-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickl-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickr-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickr-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickr-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickr-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickr-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickr3-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickr3-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickr3-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickr3-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickr3-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickl3-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickl3-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickl3-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickl3-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickl3-disabled");
	
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickr-updown-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickr-updown-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickr-updown-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickr-updown-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickr-updown-disabled");
	
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-stickr-leftright-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-stickr-leftright-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-stickr-leftright-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-stickr-leftright-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-stickr-leftright-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-options-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-options-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-options-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-options-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-options-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-pslogo-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-pslogo-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-pslogo-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-pslogo-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-pslogo-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-ps-share-normal");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-ps-share-over");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-ps-share-down");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-ps-share-focus");
	shapes:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-ps-share-disabled");

	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-plus");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-plus");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-plus");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-plus");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-plus");

	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-slash");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-slash");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-slash");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-slash");
	shapes:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-slash");
end

local reverse = INPUT_DEVICE_INPUT_ICON_TEXTURE_SETS.Reverse;
do
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-zl-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-zl-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-zl-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-zl-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-zl-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-zr-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-zr-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-zr-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-zr-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_TRIGGER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-zr-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-shoulder-l-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-shoulder-l-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-shoulder-l-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-shoulder-l-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-shoulder-l-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-shoulder-r-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-shoulder-r-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-shoulder-r-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-shoulder-r-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_SHOULDER_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-shoulder-r-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-all-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-all-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-all-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-all-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-all-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-leftright-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-leftright-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-leftright-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-leftright-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-leftright-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-updown-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-updown-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-updown-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-updown-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-updown-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-up-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-up-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-up-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-up-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-up-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-down-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-down-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-down-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-down-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-down-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-left-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-left-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-left-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-left-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-left-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-dpad-right-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-dpad-right-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-dpad-right-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-dpad-right-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_DPAD_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-dpad-right-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-face-x-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-face-x-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-face-x-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-face-x-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_TOP, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-face-x-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-face-b-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-face-b-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-face-b-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-face-b-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_BOTTOM, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-face-b-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-face-y-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-face-y-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-face-y-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-face-y-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-face-y-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-face-a-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-face-a-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-face-a-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-face-a-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_FACE_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-face-a-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-l-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-l-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-l-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-l-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-l-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-r-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-r-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-r-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-r-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-r-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-r3-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-r3-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-r3-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-r3-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-r3-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-l3-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-l3-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-l3-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-l3-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_LEFT_PRESS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-l3-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-r-updown-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-r-updown-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-r-updown-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-r-updown-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_VERTICAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-r-updown-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-stick-r-leftright-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-stick-r-leftright-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-stick-r-leftright-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-stick-r-leftright-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_STICK_RIGHT_HORIZONTAL, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-stick-r-leftright-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-plus-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-plus-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-plus-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-plus-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_RIGHT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-plus-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-home-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-home-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-home-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-home-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_CENTER, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-home-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-switch-128x-minus-normal");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-switch-128x-minus-hover");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-switch-128x-minus-pressed");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-switch-128x-minus-selected");
	reverse:SetInputIconTextureForKey(GAMEPAD_MENU_LEFT, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-switch-128x-minus-disabled");

	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-plus");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-plus");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-plus");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-plus");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_PLUS, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-plus");

	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Normal, "gamepad-symbols-slash");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Hover, "gamepad-symbols-slash");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Pressed, "gamepad-symbols-slash");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Active, "gamepad-symbols-slash");
	reverse:SetInputIconTextureForKey(GAMEPAD_PROMPT_DIVIDER_SLASH, InputIconVariant.Standard, InputIconTextureState.Disabled, "gamepad-symbols-slash");
end

InputIconTextureSetUtility = {};

function InputIconTextureSetUtility.GetActiveInputIconButtonTextures(buttonKey)
	assert(type(buttonKey) == "string");
	local activeInputDeviceIconSet = InputDeviceIconSetManager:GetActiveInputDeviceIconSet();
	local activeInputDeviceInputIconTextureSet = INPUT_DEVICE_INPUT_ICON_TEXTURE_SETS[activeInputDeviceIconSet];
	return activeInputDeviceInputIconTextureSet and activeInputDeviceInputIconTextureSet:GetInputIconTexturesForKey(buttonKey);
end

function InputIconTextureSetUtility.GetNormalActiveInputIconButtonTexture(buttonKey)
	return InputIconTextureSetUtility.GetActiveInputIconButtonTextures(buttonKey)[InputIconTextureState.Normal];
end

function InputIconTextureSetUtility.GetInputIconNameFromBindingKey(bindingKey)
	local INPUT_ICON_NAME_OVERRIDES =
	{
		SHIFT = GAMEPAD_TRIGGER_LEFT,
		CTRL = GAMEPAD_TRIGGER_RIGHT,
		PADRSTICKUP = GAMEPAD_STICK_RIGHT,
		PADRSTICKDOWN = GAMEPAD_STICK_RIGHT,
		PADLSTICKUP = GAMEPAD_STICK_LEFT,
		PADLSTICKDOWN = GAMEPAD_STICK_LEFT
	};

	local inputIconNames = {};

	if (bindingKey) then
		local split = { strsplit("-", bindingKey) }
		for i = 1, #split do
			local inputIconName = split[i];
			if (INPUT_ICON_NAME_OVERRIDES[inputIconName]) then
				inputIconName = INPUT_ICON_NAME_OVERRIDES[inputIconName];
			end
			table.insert(inputIconNames, inputIconName);
		end
	end

	return inputIconNames;
end

---------------------------
-- InputIconTextureMixin --
---------------------------
InputIconTextureMixin = { mappedButtonKey = GAMEPAD_FACE_BOTTOM, useDropShadow = false, };
local LARGE_PROMPT_ATLAS_WIDTH = 76;
local LARGE_PROMPT_ATLAS_HEIGHT = 75;

function InputIconTextureMixin:RefreshIconTextures()
	local iconTextures = InputIconTextureSetUtility.GetActiveInputIconButtonTextures(self.mappedButtonKey);
	for state, texture in pairs(self.textureStateTextures) do
		texture:SetAtlas(iconTextures[state]);
		self:ApplyTextureLayout(texture, iconTextures[state]);
	end
end

--[[
	New controller prompt assets use a larger 76x75 canvas and include
	additional border/shadow padding. Adjust the bounds and texcoords so
	they remain visually consistent with legacy footer prompts.
]]--
function InputIconTextureMixin:ApplyTextureLayout(texture, atlasKey)
	texture:ClearAllPoints();

	if self:ShouldUseAdjustedTextureBounds(atlasKey) then
		texture:SetPoint("TOPLEFT", -5, 5);
		texture:SetPoint("BOTTOMRIGHT", 4, -3);
		texture:SetTexCoord(0.015, 0.96, 0.015, 0.94);
	else
		texture:SetAllPoints();
		texture:SetTexCoord(0, 1, 0, 1);
	end
end

function InputIconTextureMixin:ShouldUseAdjustedTextureBounds(iconAtlasKey)
	local atlasInfo = iconAtlasKey and C_Texture.GetAtlasInfo(iconAtlasKey);

	return atlasInfo
		and atlasInfo.width == LARGE_PROMPT_ATLAS_WIDTH
		and atlasInfo.height == LARGE_PROMPT_ATLAS_HEIGHT;
end

function InputIconTextureMixin:OnLoad()
	-- Responsible for registering to active icon set changed event
	-- in the input icon set manager.
	InputDeviceIconSetManager:RegisterActiveInputDeviceIconSetUpdatedCallback(self.RefreshIconTextures, self);

	self.textureStateTextures = {
		[InputIconTextureState.Normal] = self.NormalTexture,
		[InputIconTextureState.Hover] = self.HoverTexture,
		[InputIconTextureState.Pressed] = self.PressedTexture,
		[InputIconTextureState.Active] = self.ActiveTexture,
		[InputIconTextureState.Disabled] = self.DisabledTexture,
	}
	self:RefreshIconTextures();

	if not self.usableState then
		self:SetUsableState(InputIconUsableState.Pressable);
	end

	if not self.textureState then
		self:SetTextureState(InputIconTextureState.Normal);
	end
end

function InputIconTextureMixin:SetInputKey(buttonKey)
	assert(type(buttonKey) == "string", "Passed in button must be a string type");
	self.mappedButtonKey = buttonKey;
	self:RefreshIconTextures();
end

function InputIconTextureMixin:EnableDropShadow()
	local newDropShadowValue = true;
	if self.useDropShadow ~= newDropShadowValue then
		self.useDropShadow = newDropShadowValue;
		self:RefreshIconTextures();
	end;
end

function InputIconTextureMixin:DisableDropShadow()
	local newDropShadowValue = false;
	if self.useDropShadow ~= newDropShadowValue then
		self.useDropShadow = newDropShadowValue;
		self:RefreshIconTextures();
	end;
end

function InputIconTextureMixin:CanEnterTextureState(textureState)
	if self.textureState == textureState then
		return false;
	end

	local isPressable = self.usableState ~= InputIconUsableState.Pressable;
	local isUsableStateTransition = textureState == DefaultTextureStatesByUsable[self.usableState];
	if isPressable and not isUsableStateTransition then
		return false;
	end

	return true;
end

function InputIconTextureMixin:SetTextureState(newTextureState)
	if not self:CanEnterTextureState(newTextureState) then
		return;
	end

	if self.textureState then
		self.textureStateTextures[self.textureState]:Hide();
	end
	self.textureStateTextures[newTextureState]:Show();

	self.textureState = newTextureState;
end

function InputIconTextureMixin:SetUsableState(newUsableState)
	if self.usableState == newUsableState then
		return;
	end

	self.usableState = newUsableState;
	self:SetTextureState(DefaultTextureStatesByUsable[newUsableState]);
end

-- Enters the pressable state, allowing transition from normal / pressed / hover
function InputIconTextureMixin:SetPressable()
	self:SetUsableState(InputIconUsableState.Pressable);
end

-- Enters the disabled state and disallows transitions
function InputIconTextureMixin:SetDisabled()
	self:SetUsableState(InputIconUsableState.Disabled);
end

-- Enters the focused state and disallows transitions
function InputIconTextureMixin:SetFocused()
	self:SetUsableState(InputIconUsableState.Focused);
end

function InputIconTextureMixin:SetTextureWidth(width)
	self:SetWidth(width);
end

function InputIconTextureMixin:SetTextureHeight(height)
	self:SetHeight(height);
end

function InputIconTextureMixin:SetEnabled(enabled)
	self:SetUsableState((enabled and InputIconUsableState.Pressable) or InputIconUsableState.Disabled);
end
