function PetFrame_SetHappiness()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness();
	local hasPetUI, isHunterPet = HasPetUI();
	if ( not happiness or not isHunterPet ) then
		PetFrameHappiness:Hide();
		return;	
	end
	PetFrameHappiness:Show();
	if ( happiness == 1 ) then
		PetFrameHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif ( happiness == 2 ) then
		PetFrameHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif ( happiness == 3 ) then
		PetFrameHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end
	PetFrameHappiness.tooltip = _G["PET_HAPPINESS"..happiness];
	PetFrameHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
end

function PetFrame_AdjustPoint(self)
	local _, class = UnitClass("player");
	--Death Knights need the Pet frame moved down for their Runes and Druids need it moved down for the secondary power bar.
	if ( class == "DEATHKNIGHT"  or class == "DRUID" ) then	
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75);
	elseif ( class == "SHAMAN" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -100);
	end
end