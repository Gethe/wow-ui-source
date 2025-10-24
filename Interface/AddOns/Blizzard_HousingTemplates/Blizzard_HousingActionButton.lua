BaseHousingActionButtonMixin = {};

function BaseHousingActionButtonMixin:OnLoad()
	local iconName, isAtlas = self:GetDefaultTexture();
	self:UpdateIconVisuals(iconName, isAtlas, nil);

	self:UpdateKeybind();
end

function BaseHousingActionButtonMixin:UpdateState()
	local wasEnabled = self:IsEnabled();

	local enabled = true;
	self.disabledTooltip = nil;
	
	if self.CheckEnabled then
		enabled, self.disabledTooltip = self:CheckEnabled();
	end

	if wasEnabled ~= enabled then
		self:SetEnabled(enabled);
	end

	self:UpdateKeybind();

	local isPressed = false;
	self:UpdateVisuals(isPressed);
end

function BaseHousingActionButtonMixin:GetDefaultTexture()
	local iconName, isAtlas = nil, false;
	if self.iconTexture and self.iconTexture ~= "" then
		iconName = self.iconTexture;
		isAtlas = false;
	elseif self.iconAtlas and self.iconAtlas ~= "" then
		iconName = self.iconAtlas;
		isAtlas = true;
	end
	return iconName, isAtlas;
end

function BaseHousingActionButtonMixin:GetIconForState(state)
	-- By default, base button doesn't update textures for states
	return nil;
end

function BaseHousingActionButtonMixin:GetIconColorForState(state)
	local stateColor = nil;
	if not state.isEnabled then
		stateColor = DARKGRAY_COLOR;
	elseif state.isPressed then
		stateColor = state.isActive and DARKYELLOW_FONT_COLOR or GRAY_FONT_COLOR;
	elseif state.isHovered and not self.HoverIcon then
		stateColor = state.isActive and DARKYELLOW_FONT_COLOR or LIGHTGRAY_FONT_COLOR;
	else
		stateColor = state.isActive and YELLOW_FONT_COLOR or WHITE_FONT_COLOR;
	end
	return stateColor;
end

function BaseHousingActionButtonMixin:GetState(isPressed)
	return {
		isPressed = isPressed,
		isHovered = self:IsMouseMotionFocus(),
		isActive = self:IsActive(),
		isEnabled = self:IsEnabled(),
	};
end

function BaseHousingActionButtonMixin:UpdateCustomVisuals(state)
	--for if subtypes have custom behavior that they want to happen on UpdateVisuals.
end

function BaseHousingActionButtonMixin:UpdateVisuals(isPressed)
	local state = self:GetState(isPressed);

	local showHoverVisuals = state.isHovered and state.isEnabled and not state.isPressed;

	local stateColor = nil;
	if self.useStateColors then
		stateColor = self.useStateColors and self:GetIconColorForState(state) or WHITE_FONT_COLOR;
	end

	local stateIcon, isAtlas = nil, false;
	if self.useStateTextures then
		stateIcon, isAtlas = self:GetIconForState(state);
	end

	self:UpdateIconVisuals(stateIcon, isAtlas, stateColor);

	if self.useStateColors then
		if self.Background then
			self.Background:SetVertexColor(stateColor:GetRGB());
		end
	end

	if self.HoverIcon then
		self.HoverIcon:SetShown(showHoverVisuals);
	end

	if self.HoverRegions and #self.HoverRegions > 0 then
		for _, hoverRegion in ipairs(self.HoverRegions) do
			hoverRegion:SetShown(showHoverVisuals);
			if showHoverVisuals and self.useStateColors then
				hoverRegion:SetVertexColor(stateColor:GetRGB());
			end
		end
	end

	if state.isHovered then
		self:UpdateTooltip();
	end

	self:UpdateCustomVisuals(state);
end

function BaseHousingActionButtonMixin:UpdateIconVisuals(iconName, isAtlas, color)
	if color then
		local r, g, b = color:GetRGB();
		self.Icon:SetVertexColor(r, g, b);
		if self.HoverIcon then
			self.HoverIcon:SetVertexColor(r, g, b);
		end
	end

	if iconName then
		if isAtlas then
			self.Icon:SetAtlas(iconName);
			if self.HoverIcon then 
				self.HoverIcon:SetAtlas(iconName);
			end
		else
			self.Icon:SetTexture(iconName);
			if self.HoverIcon then
				self.HoverIcon:SetTexture(iconName);
			end
		end
	end
end

function BaseHousingActionButtonMixin:UpdateKeybind()
	self.bindingKey = nil;
	self.altBindingKey = nil;

	local bindingKeyAbbr;
	if self.keybindName then
		local abbreviated = true;

		local bindingKey = GetBindingText(GetBindingKey(self.keybindName));
		if bindingKey and bindingKey ~= "" then
			self.bindingKey = bindingKey;
		end
		bindingKeyAbbr = GetBindingText(GetBindingKey(self.keybindName), abbreviated);
	end
	if self.altKeybindName then
		local altBindingKey = GetBindingText(GetBindingKey(self.altKeybindName));
		if altBindingKey and altBindingKey ~= "" then
			self.altBindingKey = altBindingKey;
		end
	end

	if self.ControlText then
		if bindingKeyAbbr and bindingKeyAbbr ~= "" then
			self.ControlText:SetText(bindingKeyAbbr);
			self.ControlText:Show();
		else
			self.ControlText:Hide();
		end
	end
end

function BaseHousingActionButtonMixin:UpdateTooltip()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipAnchorX, self.tooltipAnchorY);
	local hasTooltipContent = false;

	if self:IsEnabled() then
		if self.bindingKey and self.enabledTooltipKeybind then
			GameTooltip_AddHighlightLine(tooltip, self.enabledTooltipKeybind:format(self.bindingKey));
			hasTooltipContent = true;
		elseif self.enabledTooltip then
			GameTooltip_AddHighlightLine(tooltip, self.enabledTooltip);
			hasTooltipContent = true;
		end

		if self.AddEnabledTooltipText then
			hasTooltipContent = self:AddEnabledTooltipText(tooltip) or hasTooltipContent;
		end
	elseif self.disabledTooltip then
		GameTooltip_AddErrorLine(tooltip, self.disabledTooltip);
		hasTooltipContent = true;
	end

	if hasTooltipContent then
		tooltip:Show();
	else
		tooltip:Hide();
	end
end

function BaseHousingActionButtonMixin:OnEnter()
	local isPressed = false;
	self:UpdateVisuals(isPressed);

	if self.onHoverSound then
		PlaySound(SOUNDKIT[self.onHoverSound]);
	end
end

function BaseHousingActionButtonMixin:OnLeave()
	local isPressed = false;
	self:UpdateVisuals(isPressed);

	GameTooltip:Hide();
end

function BaseHousingActionButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		local isPressed = true;
		self:UpdateVisuals(isPressed);
	end
end

function BaseHousingActionButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		local isPressed = false;
		self:UpdateVisuals(isPressed);
	end
end

function BaseHousingActionButtonMixin:IsActive()
	-- By default, base buttons don't have an "active" toggled state
	-- This should be overriden by any Action buttons that have a "toggled" active/inactive state
	return false;
end

function BaseHousingActionButtonMixin:CheckEnabled()
	-- Optional, override by any Action buttons with potential Disabled states
	-- return isEnabled, (optional) disabledTooltip;
	return true;
end

function BaseHousingActionButtonMixin:OnClick()
	-- Required
	assert(false);
end


BaseHousingModeButtonMixin = {};

function BaseHousingModeButtonMixin:OnLoad()
	BaseHousingActionButtonMixin.OnLoad(self);
end

function BaseHousingModeButtonMixin:OnClick()
	self:ToggleMode();
end

function BaseHousingModeButtonMixin:ToggleMode()
	self:SetModeActive(not self:IsActive());
end

function BaseHousingModeButtonMixin:SetModeActive(shouldBeActive)
	local isModeActive = self:IsActive();
	if isModeActive == shouldBeActive then
		return;
	end

	if isModeActive and not shouldBeActive then
		self:LeaveMode();
	elseif not isModeActive and shouldBeActive then
		self:EnterMode();
	end

	if self.PlayEnterSound then
		self:PlayEnterSound();
	end

	self:UpdateState();
end

function BaseHousingModeButtonMixin:AddEnabledTooltipText(tooltip)
	local tooltipText = nil;
	local altTooltipText = nil;
	if self:IsActive() then
		if self.bindingKey and self.exitTooltipKeybind then
			tooltipText = self.exitTooltipKeybind:format(self.bindingKey);
		elseif self.exitTooltip then
			tooltipText = self.exitTooltip;
		end
		
		if self.altBindingKey and self.exitAltBindingTooltip then
			altTooltipText = self.exitAltBindingTooltip:format(self.altBindingKey);
		end
	else
		if self.bindingKey and self.enterTooltipKeybind then
			tooltipText = self.enterTooltipKeybind:format(self.bindingKey);
		elseif self.enterTooltip then
			tooltipText = self.enterTooltip;
		end

		if self.altBindingKey and self.enterAltBindingTooltip then
			altTooltipText = self.enterAltBindingTooltip:format(self.altBindingKey);
		end
	end

	if tooltipText then
		GameTooltip_AddHighlightLine(tooltip, tooltipText);
	end

	if altTooltipText then
		GameTooltip_AddHighlightLine(tooltip, altTooltipText);
	end

	local addedTooltipText = tooltipText ~= nil or altTooltipText ~= nil;
	return addedTooltipText;
end

function BaseHousingModeButtonMixin:CheckEnabled()
	-- Required
	-- return isEnabled, (optional) disabledTooltip;
	assert(false);
end

function BaseHousingModeButtonMixin:IsActive()
	-- Required
	-- Should return whether the relevant "Mode" is currently active
	assert(false);
end

function BaseHousingModeButtonMixin:EnterMode()
	-- Required
	assert(false);
end

function BaseHousingModeButtonMixin:LeaveMode()
	-- Required
	assert(false);
end
