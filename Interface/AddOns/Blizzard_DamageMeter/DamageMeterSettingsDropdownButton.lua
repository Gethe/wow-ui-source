DamageMeterSettingsDropdownButton = CreateFromMixins(ButtonStateBehaviorMixin);

function DamageMeterSettingsDropdownButton:GetIcon()
	return self.Icon;
end

function DamageMeterSettingsDropdownButton:GetIconAtlas()
	if not self:IsEnabled() then
		return self.disabled;
	elseif self:IsDownOver() then
		return self.hoverPressed;
	elseif self:IsOver() then
		return self.hover;
	elseif self:IsDown() then
		return self.pressed;
	elseif self:IsMenuOpen() then
		return self.open;
	else
		return self.normal;
	end
end

function DamageMeterSettingsDropdownButton:OnButtonStateChanged()
	local iconAtlas = self:GetIconAtlas();
	self:GetIcon():SetAtlas(iconAtlas, TextureKitConstants.UseAtlasSize);
end

function DamageMeterSettingsDropdownButton:OnMenuOpened(menu)
	DropdownButtonMixin.OnMenuOpened(self, menu);

	self:OnButtonStateChanged();
end

function DamageMeterSettingsDropdownButton:OnMenuClosed(menu)
	DropdownButtonMixin.OnMenuClosed(self, menu);

	self:OnButtonStateChanged();
end
