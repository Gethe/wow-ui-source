PetHappinessIndicatorMixin = {};

PetHappinessIndicatorMixin.HappinessText = {
	[1] = PET_HAPPINESS1,
	[2] = PET_HAPPINESS2,
	[3] = PET_HAPPINESS3,
};

function PetHappinessIndicatorMixin:OnLoad()
	self:RegisterEvent("UNIT_HAPPINESS");
	self:RegisterEvent("UNIT_PET");
end

function PetHappinessIndicatorMixin:OnEvent(event, ...)
	if event == "UNIT_HAPPINESS" or event == "UNIT_PET" then
		self:UpdateHappiness();
	end
end

function PetHappinessIndicatorMixin:UpdateHappiness()
	local happiness, damagePercentage, loyaltyRate;

	if self.stabledPetID then
		local petInfo = C_StableInfo.GetStablePetInfo(self.stabledPetID);
		if petInfo then
			happiness = petInfo.happinessLevel;
		else
			happiness = 3;
		end
		damagePercentage = 0;
		loyaltyRate = 0;
	else
		happiness, damagePercentage, loyaltyRate = C_PetInfo.GetPetHappiness();
	end

	local hasPetUI, isHunterPet = HasPetUI();
	if ( not happiness or (not isHunterPet and not self.stabledPetID) ) then
		self:Hide();
		return;	
	end
	self:Show();
	if ( happiness == 1 ) then
		self.texture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif ( happiness == 2 ) then
		self.texture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif ( happiness == 3 ) then
		self.texture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end
	self.tooltip = self.HappinessText[happiness] or NONE;
	self.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
	if ( loyaltyRate < 0 ) then
		self.tooltipLoyalty = LOSING_LOYALTY;
	elseif ( loyaltyRate > 0 ) then
		self.tooltipLoyalty = GAINING_LOYALTY;
	else
		self.tooltipLoyalty = nil;
	end
end

function PetHappinessIndicatorMixin:CreateDietString()
	local diet;

	if self.stabledPetID then
		diet = C_StableInfo.GetStablePetFoodTypes(self.stabledPetID);
	else
		diet = C_PetInfo.GetPetFoodTypes();
	end

	if #diet == 0 then
		 return format(PET_DIET_TEMPLATE, NONE);
	end

	return format(PET_DIET_TEMPLATE, table.concat(diet, PET_FOOD_DELIMIT));
end

function PetHappinessIndicatorMixin:OnEnter()
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		if not self.stabledPetID then
			if (self.tooltipDamage) then
				GameTooltip:AddLine(self.tooltipDamage, "", 1, 1, 1);
			end
			if (self.tooltipLoyalty) then
				GameTooltip:AddLine(self.tooltipLoyalty, "", 1, 1, 1);
			end
		end
		GameTooltip:AddLine(self:CreateDietString(), "", 1, 1, 1);
		GameTooltip:Show();
	end
end
