
---------------------
-- Frame Glow mixin

FrameGlowMixin = {};

local FrameGlowTable = {
	PortraitFrameTemplate = { atlas = "gamepad-uiframemetal-largeportrait-focus", x = -20, y = 24, x1= 14, y1 = -14,},
	PortraitFrameTemplateMinimizable = { atlas = "gamepad-uiframemetal-largeportrait-focus", x = -20, y = 24, x1 = 14, y1 = -14,},
	HeldBagLayout = { atlas = "gamepad-uiframemetal-smallportrait-focus", x = -20, y = 17, x1 = 14, y1 = -14,},
	ButtonFrameTemplateNoPortrait = { atlas = "gamepad-uiframemetal-focus", x = -10, y = 14, x1 = 14, y1 = -14, },
	Default = { atlas = "", x = 0, y = 0, x1 = 0, y1 = 0,},
	MenuProxyTemplate = { atlas = "gamepad-menuproxy-focus-prototype", x = -18, y = 13, x1 = 17, y1 = -7, },
	StackSplitTemplate = { atlas = "gamepad-uiframemetal-focus", x = 0, y = 0, x1 = 0, y1 = 0, },
	CompactRaidFrameTemplate = { atlas = "gamepad-uiframemetal-focus", x = -18, y = 9, x1 = 10, y1 = -9, },
	DialogFrameTemplate = { atlas = "gamepad-uiframediamondmetal-focus-large", x =-6, y = 6, x1 = 6, y1 = -6, },
};

-- Following the implementation of the function of the same name from NineSlicePanelMixin
function FrameGlowMixin:GetFrameLayoutType()
	return self.layoutType or self:GetParent().layoutType;
end

function FrameGlowMixin:GetContainerFrame()
	return self:GetParent().NineSlice or self:GetParent();
end

function FrameGlowMixin:OnLoad()
	local layout = self:GetFrameLayoutType();
	local entry = FrameGlowTable[layout];
	if entry == nil then
		entry = FrameGlowTable.Default;
	end
	self.GlowTexture:SetAtlas(entry.atlas);
	self:ClearAllPoints();

	local containerFrame = self:GetContainerFrame();

	self:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", entry.x, entry.y);
	self:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", entry.x1, entry.y1);

	local function OnGamepadFocusStateColorChanged()
		local value = tonumber(C_CVar.GetCVar("GamepadFocusStateColor"));
		if ( value == 1 ) then
			self.GlowTexture:SetVertexColor(1, 0.9, 0.4); -- Gold.
		elseif ( value == 2 ) then
			self.GlowTexture:SetVertexColor(0, 0, 0); -- Black.
		elseif ( value == 3 ) then
			self.GlowTexture:SetVertexColor(0.3, 0.5, 1); -- Blue.
		end
	end

	local function OnGamepadFocusStateOpacityChanged()
		local alpha = tonumber(C_CVar.GetCVar("GamepadFocusStateOpacity"));
		self:SetAlpha(alpha);
	end

	CVarCallbackRegistry:RegisterCallback("GamepadFocusStateColor", OnGamepadFocusStateColorChanged, self);
	CVarCallbackRegistry:RegisterCallback("GamepadFocusStateOpacity", OnGamepadFocusStateOpacityChanged, self);
end

--------------------
-- Focus Acquisition

FocusFramesInterfaceMixin = {};

function FocusFramesInterfaceMixin:GetFocusFrameRoot()
	return self.FocusFrameParent and self[self.FocusFrameParent] or self;
end

function FocusFramesInterfaceMixin:RefreshFocus()
	if self.isFocused or self.lockedFocus then
		self:GetFocusFrameRoot().FrameGlow:Show();
	else
		self:GetFocusFrameRoot().FrameGlow:Hide();
	end
end

function FocusFramesInterfaceMixin:StartFocus()
	self.isFocused = true;
	self:RefreshFocus();
end

function FocusFramesInterfaceMixin:EndFocus()
	self.isFocused = false;
	self:RefreshFocus();
end

function FocusFramesInterfaceMixin:LockInFocus(locked)
	self.lockedFocus = locked;
	self:RefreshFocus();
end

function FocusFramesInterfaceMixin:ShowLeftJumpHint()
	self:GetFocusFrameRoot().LeftJumpHint:Show();
end

function FocusFramesInterfaceMixin:HideLeftJumpHint()
	self:GetFocusFrameRoot().LeftJumpHint:Hide();
end

function FocusFramesInterfaceMixin:ShowRightJumpHint()
	self:GetFocusFrameRoot().RightJumpHint:Show();
end

function FocusFramesInterfaceMixin:HideRightJumpHint()
	self:GetFocusFrameRoot().RightJumpHint:Hide();
end

function FocusFramesInterfaceMixin:ShowFocusJumpHint()
	self:GetFocusFrameRoot().FocusJumpHint:Show();
end

function FocusFramesInterfaceMixin:HideFocusJumpHint()
	self:GetFocusFrameRoot().FocusJumpHint:Hide();
end
