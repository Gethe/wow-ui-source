function CollectionsSpellButton_OnLoad(self, updateFunction)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.updateFunction = updateFunction;
end

function CollectionsButton_OnEvent(self, event, ...)
	if GameTooltip:GetOwner() == self then
		self:GetScript("OnEnter")(self);
	end

	self.updateFunction(self);
end

function CollectionsSpellButton_OnShow(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

	self.updateFunction(self);
end

function CollectionsSpellButton_OnHide(self)
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
end

function CollectionsSpellButton_UpdateCooldown(self)
	if (self.itemID == -1 or self.itemID == nil) then
		return;
	end

	local cooldown = self.cooldown;
	local start, duration, enable = GetItemCooldown(self.itemID);
	if (cooldown and start and duration) then
		if (enable) then
			cooldown:Hide();
		else
			cooldown:Show();
		end
		CooldownFrame_Set(cooldown, start, duration, enable);
	else
		cooldown:Hide();
	end
end

function CollectionsWrappedModelFrame_OnEnter(self)
	self:SetLight(true, false, 0, 0, 0, self.highlightIntensity, 1.0, 1.0, 1.0);
end

function CollectionsWrappedModelFrame_OnLeave(self)
	self:SetLight(true, false, 0, 0, 0, self.normalIntensity, 1.0, 1.0, 1.0);
end