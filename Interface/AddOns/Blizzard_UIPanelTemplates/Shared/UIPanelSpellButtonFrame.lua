UIPanelSpellButtonFrameMixin = {};

function UIPanelSpellButtonFrameMixin:OnLoad()
	self.events = { "SPELL_UPDATE_COOLDOWN", "SPELLS_CHANGED" };

	local button = self.Button;
	local height = self:GetHeight();
	button:SetSize(height, height);

	if self.buttonBorderAtlas then
		self.Button.Border:SetTexCoord(0, 1, 0, 1);
		local useAtlasSize = true;
		if self.buttonBorderAtlasSize then
			self.Button.Border:SetSize(self.buttonBorderAtlasSize, self.buttonBorderAtlasSize);
			useAtlasSize = false;
		end
		self.Button.Border:SetAtlas(self.buttonBorderAtlas, useAtlasSize);
	end

	button:SetScript("OnClick", GenerateClosure(self.OnIconClick, self));
	button:SetScript("OnDragStart", GenerateClosure(self.OnIconDragStart, self));
	button:SetScript("OnEnter", GenerateClosure(self.OnIconEnter, self));
	button:SetScript("OnLeave", GenerateClosure(self.OnIconLeave, self));
	button.UpdateTooltip =  GenerateClosure(self.UpdateTooltip, self);

	-- Is the spell anchored on the left or right side of the frame.
	self.Button:ClearAllPoints();
	if self.spellButtonJustifyLeft then
		self.Button:SetPoint("LEFT");
		self.Label:SetJustifyH("LEFT");

		if not self.resizeToText then
			self.Label:SetPoint("LEFT", self.Button.Border, "RIGHT", self.textPadLeft, 0);
			self.Label:SetPoint("RIGHT", -self.textPadRight, 0);
		end
	else
		self.Button:SetPoint("RIGHT");
		self.Label:SetJustifyH("RIGHT");

		if not self.resizeToText then
			self.Label:SetPoint("LEFT", self.textPadLeft, 0);
			self.Label:SetPoint("RIGHT", self.Button.Border, "LEFT", -self.textPadRight, 0);
		end
	end

	self:UpdateDisplay();
end

function UIPanelSpellButtonFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, self.events);
	self:UpdateCooldown();
	self:UpdateUsability();
end

function UIPanelSpellButtonFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, self.events);
end

function UIPanelSpellButtonFrameMixin:OnIconClick()
	CastSpellByID(self.spellID);
end

function UIPanelSpellButtonFrameMixin:OnIconDragStart()
	C_Spell.PickupSpell(self.spellID);
end

function UIPanelSpellButtonFrameMixin:OnIconEnter()
	GameTooltip:SetOwner(self.Button, self.tooltipAnchor);
	self:UpdateTooltip();
end

function UIPanelSpellButtonFrameMixin:OnIconLeave()
	GameTooltip:Hide();
end

function UIPanelSpellButtonFrameMixin:SetSpellID(spellID)
	self.spellID = spellID;
	self:UpdateDisplay();
end

function UIPanelSpellButtonFrameMixin:UpdateDisplay()
	local iconID, name;
	if self.spellID then
		local spellInfo = C_Spell.GetSpellInfo(self.spellID);
		if spellInfo then
			iconID = spellInfo.iconID;
			name = spellInfo.name;
		end
	end

	self.Button.Icon:SetTexture(iconID);
	self.Label:SetText(self.labelText or name);

	if self.resizeToText then
		self.Label:ClearAllPoints();

		if self.spellButtonJustifyLeft then
			self.Label:SetPoint("LEFT", self.Button.Border, "RIGHT", self.textPadLeft, 0);
			self.Label:SetPoint("RIGHT", -self.textPadRight, 0);
		else
			self.Label:SetPoint("LEFT", self.textPadLeft, 0);
			self.Label:SetPoint("RIGHT", self.Button.Border, "LEFT", -self.textPadRight, 0);
		end

		local fontStringWidth = self.Label:GetWidth();
		local buttonWidth = self.Button:GetWidth();
		self:SetWidth(fontStringWidth + buttonWidth + self.textPadLeft + self.textPadRight + 1);	-- add 1 to account for rounding errors
	end

	if self:IsShown() then
		self:UpdateCooldown();
		self:UpdateUsability();
	end
end

function UIPanelSpellButtonFrameMixin:AddUsabilityUpdateEvent(event)
	table.insert(self.events, event);
end

function UIPanelSpellButtonFrameMixin:UpdateUsability()
	local button = self.Button;
	if self:IsAvailable() then
		if self:IsLocked() then
			local locked = true;
			button:SetButtonState("NORMAL", locked);
			button.Icon:SetDesaturated(true);
			button.LockIcon:Show();
			button.BlackCover:Show();
		else
			local locked = false;
			button:SetButtonState("NORMAL", locked);
			button.Icon:SetDesaturated(false);
			button.LockIcon:Hide();
			button.BlackCover:Hide();
		end
	else
		button.Icon:SetDesaturated(true);
		button.LockIcon:Hide();
		button.BlackCover:Show();
	end
end

function UIPanelSpellButtonFrameMixin:IsAvailable()
	-- override in your mixin
	return true;
end

function UIPanelSpellButtonFrameMixin:IsLocked()
	-- override in your mixin
	return false;
end

function UIPanelSpellButtonFrameMixin:OnEvent(event, ...)
	if event == "SPELL_UPDATE_COOLDOWN" then
		self:UpdateCooldown();
		if GameTooltip:GetOwner() == self.Button then
			self:UpdateTooltip();
		end
	else
		self:UpdateUsability();
	end
end

function UIPanelSpellButtonFrameMixin:UpdateCooldown()
	local cooldownInfo = self.spellID and C_Spell.GetSpellCooldown(self.spellID);
	if cooldownInfo then
		CooldownFrame_Set(self.Button.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled);
	else
		CooldownFrame_Clear(self.Button.Cooldown);
	end
end

function UIPanelSpellButtonFrameMixin:UpdateTooltip()
	GameTooltip:SetSpellByID(self.spellID);
	self:OnSetTooltip(GameTooltip);
	GameTooltip:Show();
end

function UIPanelSpellButtonFrameMixin:OnSetTooltip(tooltip)
	-- override to add lines to the bottom of the tooltip
end
