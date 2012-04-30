
--[[
abilityInfo should be defined with the following functions:
{
	:GetName()			- returns the name of the ability
	:GetMaxCooldown()	- returns the maximum cooldown of this ability
	:GetDescription()	- returns the description of the ability
}
--]]

function SharedPetBattleAbilityTooltip_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function SharedPetBattleAbilityTooltip_SetAbility(self, abilityInfo)
	self.Name:SetText(abilityInfo:GetName());
	self.Description:SetText(abilityInfo:GetDescription());

	local maxCooldown = abilityInfo:GetMaxCooldown();
	if ( maxCooldown > 0 ) then
		self.MaxCooldown:SetFormattedText(PET_BATTLE_TURN_COOLDOWN, maxCooldown);
		self.MaxCooldown:Show();
		self.Description:SetPoint("TOPLEFT", self.MaxCooldown, "BOTTOMLEFT", 0, -5);
	else
		self.MaxCooldown:Hide();
		self.Description:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -5);
	end

	--TODO: Might error if no top or bottom
	self:SetHeight(self:GetTop() - self.Description:GetBottom() + 10);
end
