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
	if ( loyaltyRate < 0 ) then
		PetFrameHappiness.tooltipLoyalty = _G["LOSING_LOYALTY"];
	elseif ( loyaltyRate > 0 ) then
		PetFrameHappiness.tooltipLoyalty = _G["GAINING_LOYALTY"];
	else
		PetFrameHappiness.tooltipLoyalty = nil;
	end
end

function RefreshBuffsOrDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	RefreshBuffs(frame, unit, numDebuffs, suffix, checkCVar);
end
