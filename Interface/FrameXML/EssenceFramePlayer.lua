local FillingAnimationTime = 3.3; 

EssenceFrameMixin = { };
function EssenceFrameMixin:OnLoad()
	self.essencePointButtonPool = CreateFramePool("BUTTON", self, "EssencePointButtonTemplate");
	self.essencePoints = { };
	self.maxUsablePoints = 5;
end 

function EssenceFrameMixin:UpdateMaxPower()
	self.essencePointButtonPool:ReleaseAll(); 
	self.essencePoints = { };

	local unit = self.unit or self:GetParent().unit;
	self.maxUsablePoints = UnitPowerMax(unit, Enum.PowerType.Essence);

	for i = 1, self.maxUsablePoints do
		local comboPoint = self.essencePointButtonPool:Acquire(); 
		self.essencePoints[i] = comboPoint; 
		comboPoint.layoutIndex = i; 
		comboPoint:Show(); 
	end

	self:Layout(); 
end

function EssenceFrameMixin:UpdatePower()
	if (self.delayedUpdate) then
		return;
	end
	local unit = self.unit or self:GetParent().unit;
	local comboPoints = UnitPower(unit, Enum.PowerType.Essence);
	local maxComboPoints = UnitPowerMax(unit, Enum.PowerType.Essence);
	for i = 1, min(comboPoints, self.maxUsablePoints) do
		self.essencePoints[i]:SetEssennceFull(); 
	end
	for i = comboPoints + 1, self.maxUsablePoints do
		self.essencePoints[i]:AnimOut();
	end
	
	local isAtMaxPoints = comboPoints == maxComboPoints; 
	local peace,interrupted = GetPowerRegenForPowerType(Enum.PowerType.Essence)
	if (peace == nil or peace == 0) then
		peace = 0.2;
	end
	local cooldownDuration = 1 / peace;
	local waitTime = cooldownDuration - FillingAnimationTime;
	waitTime = waitTime > 0 and waitTime or 0; 
	if (not isAtMaxPoints and self.essencePoints[comboPoints + 1] and not self.essencePoints[comboPoints + 1].EssenceFull:IsShown()) then 
		self.essencePoints[comboPoints + 1].currentlyFilling = true; 
		C_Timer.After(waitTime, 
		function() 
			local currentComboPoints = UnitPower(unit, Enum.PowerType.Essence);
			if(currentComboPoints == comboPoints) then 
				self.essencePoints[comboPoints + 1]:AnimIn()
			end
		end);
	end 
end

EssencePowerBar = {};
function EssencePowerBar:OnLoad()
	if (GetCVar("comboPointLocation") ~= "2") then
		self:Hide();
		return;
	end

	self:SetPowerTokens("COMBO_POINTS");
	self:SetTooltip(POWER_TYPE_ESSENCE, ESSENCE_TOOLTIP);

	EssenceFrameMixin.OnLoad(self);
	ClassPowerBar.OnLoad(self);
end

function EssencePowerBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		self:Setup();
	elseif (event == "UNIT_MAXPOWER") then
		self:UpdateMaxPower();
	elseif ( event == "UNIT_POWER_FREQUENT" ) then
		self:UpdatePower();
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end

function EssencePowerBar:Setup()
	local showBar = false;
	local frameLevel = 0;
	local xOffset = 43;
	if UnitInVehicle("player") then
		showBar = PlayerVehicleHasComboPoints();
	else
		showBar = self:SetupEvoker();
		if showBar then
			frameLevel = self:GetParent():GetFrameLevel() + 2;
			xOffset = 50;
		end
	end
	
	if showBar then
		local unit = self:GetParent().unit;
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit);
		self:RegisterUnitEvent("UNIT_MAXPOWER", unit);
		self:SetPoint("TOP", self:GetParent(), "BOTTOM", xOffset, 38);	
		self:SetFrameLevel(frameLevel);
		self:Show();
		self:UpdateMaxPower();
		self:UpdatePower(); 
	else
		self:Hide();
		self:UnregisterEvent("UNIT_POWER_FREQUENT");
		self:UnregisterEvent("UNIT_MAXPOWER");
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	end
end

function EssencePowerBar:SetupEvoker()
	local showBar = false;
	local _, myclass = UnitClass("player");
	if myclass == "EVOKER" then
		local powerType, powerToken = UnitPowerType("player");
		showBar = true;
		self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
		self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");
	end
	return showBar;
end

EssencePointButtonMixin = { }; 
function EssencePointButtonMixin:AnimIn()
	self.EssenceFilling:Show();
	self.EssenceDepleting:Hide(); 
	self.EssenceEmpty:Hide(); 
	self.EssenceFillDone:Hide();
	self.EssenceFull:Hide();
end

function EssencePointButtonMixin:AnimOut()
	if(self.currentlyFilling) then
		self.EssenceFilling.FillingAnim:Stop();
		self.EssenceFilling.CircleAnim:Stop();
		self.currentlyFilling = false; 
	end 
	if(self.EssenceFull:IsShown()) then 
		self.EssenceDepleting:Show();
		self.EssenceFilling:Hide(); 
		self.EssenceEmpty:Hide(); 
		self.EssenceFillDone:Hide();
		self.EssenceFull:Hide(); 
	end 
end

function EssencePointButtonMixin:SetEssennceFull()
	self.EssenceFull:Show();
	self.EssenceEmpty:Hide();
end 