local DIVIDER_SPACING_INFO =
{
	[GAMEPAD_PROMPT_DIVIDER_PLUS] =
	{
		FRONT_PADDING = 4,
		BACK_PADDING = 4,
		Y_OFFSET = 0,
		HEIGHT = 16,
		WIDTH = 16
	},
	[GAMEPAD_PROMPT_DIVIDER_SLASH] =
	{
		FRONT_PADDING = 2,
		BACK_PADDING = 2,
		Y_OFFSET = -2,
		HEIGHT = 24,
		WIDTH = 16
	}
}

local TEXT_LEFT_PADDING_FOLLOWING_ICON = 4;

InputPromptMixin = {};

function InputPromptMixin:SetPromptInputIconKey(promptIconID, newInputKey)
	local iconTextureWithID = self.InputIcons[promptIconID];
	if (iconTextureWithID) then
		iconTextureWithID:SetInputKey(newInputKey);
	end

	return false;
end

function InputPromptMixin:SetPromptText(newTextValue)
	local promptTextControl = self.ControlDescText;
	if (promptTextControl) then
		promptTextControl.FontString:SetText(newTextValue);
		local newTextWidth = promptTextControl.FontString:GetWidth();
		self.ControlDescText:SetWidth(newTextWidth);
	end
	self:RefreshInputPromptSize();
end

function InputPromptMixin:SetPromptFont(newFontValue)
	self.ControlDescText.FontString:SetFontObject(newFontValue);
	local newTextWidth = self.ControlDescText.FontString:GetWidth();
	self.ControlDescText:SetWidth(newTextWidth);
	self:RefreshInputPromptSize();
end

function InputPromptMixin:SetUseDropShadow(shouldUse)
	for _, icon in ipairs(self.InputIcons or {}) do
		icon.useDropShadow = shouldUse;
		icon:RefreshIconTextures();
	end
end

function InputPromptMixin:SetDividerType(newDividerType)
	local dividers = self.IconDividers;
	local icons = self.InputIcons;

	if (not dividers or not icons) then
		return;
	end

	local dividerCustomization = DIVIDER_SPACING_INFO[newDividerType];
	if (not dividerCustomization) then
		return;
	end

	for i, divider in ipairs(dividers) do
		divider:SetInputKey(newDividerType);

		local leftIcon = icons[i];
		local rightIcon = icons[i + 1];

		if leftIcon then
			divider:SetPoint("LEFT", leftIcon, "RIGHT", dividerCustomization.FRONT_PADDING, dividerCustomization.Y_OFFSET);
		end

		if rightIcon then
			rightIcon:SetPoint("LEFT", divider, "RIGHT", dividerCustomization.BACK_PADDING, -dividerCustomization.Y_OFFSET);
		end

		divider:SetWidth(dividerCustomization.WIDTH);
		divider:SetHeight(dividerCustomization.HEIGHT);
	end

	self:RefreshInputPromptSize();
end

function InputPromptMixin:GetInputIconControl(promptIconID)
	return self.InputIcons[promptIconID];
end

function InputPromptMixin:GetPromptTextControl()
	return self.ControlDescText;
end

function InputPromptMixin:GetIconDividerControl(iconDividerID)
	return self.IconDividers[iconDividerID];
end

function InputPromptMixin:DisablePrompt()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetDisabled();
	end

	for _, divider in ipairs(self.IconDividers or {}) do
		divider:SetDisabled();
	end

	if (self.ControlDescText) then
		self.ControlDescText:SetAlpha(0.5);
	end
end

function InputPromptMixin:EnablePrompt()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetPressable();
	end

	for _, divider in ipairs(self.IconDividers or {}) do
		divider:SetPressable();
	end

	if (self.ControlDescText) then
		self.ControlDescText:SetAlpha(1);
	end
end

function InputPromptMixin:EnableOrDisablePrompt(shouldEnable)
	if (shouldEnable) then
		self:EnablePrompt();
	else
		self:DisablePrompt();
	end
end

function InputPromptMixin:ApplyInactiveEnabledPromptStyling()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetDisabled();
	end

	for _, divider in ipairs(self.IconDividers or {}) do
		divider:SetDisabled();
	end

	if (self.ControlDescText) then
		self.ControlDescText:SetAlpha(0.5);
	end
end

function InputPromptMixin:OnLoad()
	local supportedKeyValues =
	{
		{"Icon1", self.SetPromptInputIconKey, {1, self.Icon1}},
		{"Icon2", self.SetPromptInputIconKey, {2, self.Icon2}},
		{"Icon3", self.SetPromptInputIconKey, {3, self.Icon3}},
		{"Text", self.SetPromptText, {self.Text}},
		{"Font", self.SetPromptFont, {self.Font}},
		{"useDropShadow", self.SetUseDropShadow, {self.useDropShadow}},
	}

	-- Apply the default divider type sizing.
	if (self.IconDivider1) then
		self:SetDividerType(GAMEPAD_PROMPT_DIVIDER_PLUS);
	end

	for _, keyValueInfo in ipairs(supportedKeyValues) do
		if (self[keyValueInfo[1]]) then
			keyValueInfo[2](self, unpack(keyValueInfo[3]));

			--[[
				Clear the key value information pulled from XML as it is no longer
				needs to stay a part of the prompt frame's table and any further changes
				should go through the support functions
			]]
			self[keyValueInfo[1]] = nil;
		end
	end

	self:RefreshInputPromptSize();
end

function InputPromptMixin:GetDividerSpacingForPrompt()
	if (self.IconDivider1) then
		local dividerType = self.IconDivider1.mappedButtonKey;
		return DIVIDER_SPACING_INFO[dividerType];
	end
end

function InputPromptMixin.GetDividerSpacingInfo(dividerType)
	return DIVIDER_SPACING_INFO[dividerType];
end

function InputPromptMixin:RefreshInputPromptSize()
	local promptWidth = 0;
	local promptHeight = 0;

	for _, icon in ipairs(self.InputIcons or {}) do
		local iconWidth = icon:GetWidth();
		promptWidth = promptWidth + iconWidth;

		local iconHeight = icon:GetHeight();
		if (iconHeight > promptHeight) then
			promptHeight = iconHeight;
		end
	end

	for _, divider in ipairs(self.IconDividers or {}) do
		local dividerType = divider.mappedButtonKey;
		local dividerSpacingInfo = DIVIDER_SPACING_INFO[dividerType];
		promptWidth = promptWidth + dividerSpacingInfo.FRONT_PADDING + dividerSpacingInfo.WIDTH + dividerSpacingInfo.BACK_PADDING;

		if (dividerSpacingInfo.HEIGHT > promptHeight) then
			promptHeight = dividerSpacingInfo.HEIGHT;
		end
	end

	if (self.ControlDescText) then
		promptWidth = promptWidth + TEXT_LEFT_PADDING_FOLLOWING_ICON;
		promptWidth = promptWidth + self.ControlDescText:GetWidth();

		local textHeight = self.ControlDescText:GetHeight();
		if (textHeight > promptHeight) then
			promptHeight = textHeight;
		end
	end

	self:SetWidth(promptWidth);
	self:SetHeight(promptHeight);
end

function InputPromptMixin:SetInputIconSize(iconID, x, y)
	local iconTextureWithID = self.InputIcons[iconID];
	if (iconTextureWithID) then
		iconTextureWithID:SetWidth(x);
		iconTextureWithID:SetHeight(y);
	end

	self:RefreshInputPromptSize();
end

function InputPromptMixin:SetPressable()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetPressable();
	end
end

function InputPromptMixin:SetDisabled()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetDisabled();
	end
end

function InputPromptMixin:SetFocused()
	for _, icon in ipairs(self.InputIcons or {}) do
		icon:SetFocused();
	end
end
