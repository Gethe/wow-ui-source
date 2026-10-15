local Attitude =
{
	Mad = 1,
	Neutral = 2,
	Happy = 3,
};

local AttitudeData =
{
	[Attitude.Mad] =
	{
		text = PET_HAPPINESS1,
		atlas = "UI-PetMad",
	},
	[Attitude.Neutral] =
	{
		text = PET_HAPPINESS2,
		atlas = "UI-PetNeutral",
	},
	[Attitude.Happy] =
	{
		text = PET_HAPPINESS3, 
		atlas = "UI-PetHappiness",
	},
};

PetHappinessIndicatorMixin = {};

function PetHappinessIndicatorMixin:OnLoad()
	self:RegisterEvent("UNIT_HAPPINESS");
	self:RegisterEvent("UNIT_PET");
end

function PetHappinessIndicatorMixin:OnEvent(event, ...)
	if event == "UNIT_HAPPINESS" or event == "UNIT_PET" then
		self:UpdateHappiness();
	end
end

function PetHappinessIndicatorMixin:GetHappinessStats()
	if self.stabledPetID then
		local petInfo = C_StableInfo.GetStablePetInfo(self.stabledPetID);
		local damagePercentage = 0;
		local loyaltyRate = 0;
		local happiness = petInfo and petInfo.happinessLevel or Attitude.Happy;
		return happiness, damagePercentage, loyaltyRate;
	end

	return C_PetInfo.GetPetHappiness();
end

function PetHappinessIndicatorMixin:ShouldShow(happiness)
	if (happiness == nil) or (AttitudeData[happiness] == nil) then
		return false;
	end

	if not self.stabledPetID then
		local _hasPetUI, isHunterPet = HasPetUI();
		if not isHunterPet then
			return false;
		end
	end

	return true;
end

function PetHappinessIndicatorMixin:UpdateHappiness()
	local happiness, damagePercentage, loyaltyRate = self:GetHappinessStats();
	if self:ShouldShow(happiness) then
		self.Texture:SetAtlas(AttitudeData[happiness].atlas);

		self.tooltipData = {
			happiness = happiness,
			damagePercentage = damagePercentage,
			loyaltyRate = loyaltyRate,
		};

		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:Show();
		return;
	end

	-- Hiding the frame first so the OnLeave function can still
	-- be called to dispose of the tooltip.
	self:Hide();

	self:SetScript("OnEnter", nil);
	self:SetScript("OnLeave", nil);
end

function PetHappinessIndicatorMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local tooltipData = self.tooltipData;
	GameTooltip_SetTitle(GameTooltip, AttitudeData[tooltipData.happiness].text or NONE);

	local diet = nil;
	if self.stabledPetID then
		diet = C_StableInfo.GetStablePetFoodTypes(self.stabledPetID);
	else
		diet = C_PetInfo.GetPetFoodTypes();

		GameTooltip_AddNormalLine(GameTooltip, PET_DAMAGE_PERCENTAGE:format(tooltipData.damagePercentage));

		if tooltipData.loyaltyRate < 0 then
			GameTooltip_AddNormalLine(GameTooltip, LOSING_LOYALTY);
		elseif tooltipData.loyaltyRate > 0 then
			GameTooltip_AddNormalLine(GameTooltip, GAINING_LOYALTY);
		end
	end

	local dietText = nil;
	if #diet > 0 then
		dietText = PET_DIET_TEMPLATE:format(table.concat(diet, PET_FOOD_DELIMIT));
	else
		dietText = PET_DIET_TEMPLATE:format(NONE);
	end
	GameTooltip_AddNormalLine(GameTooltip, dietText);

	GameTooltip:Show();
end

function PetHappinessIndicatorMixin:OnLeave()
	GameTooltip_Hide();
end

