local FillingAnimationTime = 5.0; 

EssencePowerBar = {};
function EssencePowerBar:UpdatePower()
	if (self.delayedUpdate) then
		return;
	end
	local unit = self.unit or self:GetParent().unit;
	local comboPoints = UnitPower(unit, Enum.PowerType.Essence);
	local maxComboPoints = UnitPowerMax(unit, Enum.PowerType.Essence);
	for i = 1, min(comboPoints, self.maxUsablePoints) do
		self.classResourceButtonTable[i]:SetEssennceFull(); 
	end
	for i = comboPoints + 1, self.maxUsablePoints do
		self.classResourceButtonTable[i]:AnimOut();
	end
	
	local isAtMaxPoints = comboPoints == maxComboPoints; 
	local peace,interrupted = GetPowerRegenForPowerType(Enum.PowerType.Essence)
	if (peace == nil or peace == 0) then
		peace = 0.2;
	end
	local cooldownDuration = 1 / peace;
	local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration;
	if (not isAtMaxPoints and self.classResourceButtonTable[comboPoints + 1] and not self.classResourceButtonTable[comboPoints + 1].EssenceFull:IsShown()) then 
		self.classResourceButtonTable[comboPoints + 1]:AnimIn(animationSpeedMultiplier)
	end 
end

function EssencePowerBar:SetupEvoker()
	local showBar = false;
	local _, myclass = UnitClass("player");
	if myclass == "EVOKER" then
		showBar = true;
	end
	return showBar;
end

EssencePointButtonMixin = { }; 
function EssencePointButtonMixin:OnUpdate(elapsed) 
	local peace,interrupted = GetPowerRegenForPowerType(Enum.PowerType.Essence)
	if (peace == nil or peace == 0) then
		peace = 0.2;
	end
	local cooldownDuration = 1 / peace;
	local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration
	self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
	self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
end

function EssencePointButtonMixin:AnimIn(animationSpeedMultiplier)
	self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
	self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
	self:SetScript("OnUpdate", self.OnUpdate);
	self.EssenceFilling:Show();
	self.EssenceDepleting:Hide(); 
	self.EssenceEmpty:Hide(); 
	self.EssenceFillDone:Hide();
	self.EssenceFull:Hide();
end

function EssencePointButtonMixin:AnimOut()
	if(self.EssenceFull:IsShown() or self.EssenceFilling:IsShown() or self.EssenceFillDone:IsShown()) then 
		self.EssenceDepleting:Show();
		self.EssenceFilling:Hide(); 
		self.EssenceEmpty:Hide(); 
		self.EssenceFillDone:Hide();
		self.EssenceFull:Hide(); 
	end 
end

function EssencePointButtonMixin:SetEssennceFull()
	self.EssenceFilling.FillingAnim:Stop();
	self.EssenceFilling.CircleAnim:Stop();
	self.EssenceFillDone:Show();
	self.EssenceEmpty:Hide();
	self:SetScript("OnUpdate", nil);
end 