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
	for i = comboPoints + 2, self.maxUsablePoints do -- we skip comboPoints + 1 because it's about to start filing below
		self.classResourceButtonTable[i]:AnimOut();
	end
	
	-- We need to update the animation of the filling point if it hasn't started at all, or if it's inaccurate'
	local isAtMaxPoints = comboPoints == maxComboPoints; 
	local fillingPoint = self.classResourceButtonTable[comboPoints + 1];
	if (not isAtMaxPoints and fillingPoint) then
		local partialPoint = UnitPartialPower(unit, Enum.PowerType.Essence);
		local elapsedPortion = (partialPoint / 1000.0);

		local filling = fillingPoint.EssenceFilling.FillingAnim:IsPlaying() or fillingPoint.EssenceFull:IsShown(); 
		local outdatedProgress = false;
		if filling then
			-- 10% too fast or too slow is the current threshold for updating the anim
			outdatedProgress = math.abs(elapsedPortion - fillingPoint.EssenceFilling.FillingAnim:GetProgress()) > 0.1;
		end

		if not filling or outdatedProgress then
			local peace,interrupted = GetPowerRegenForPowerType(Enum.PowerType.Essence)
			if (peace == nil or peace == 0) then
				peace = 0.2;
			end
			local cooldownDuration = 1 / peace;
			local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration;
			if not filling then
				fillingPoint.EssenceFilling.FillingAnim:Stop();
				fillingPoint.EssenceFilling.CircleAnim:Stop();
			end
			fillingPoint:AnimIn(animationSpeedMultiplier, elapsedPortion);
		end
	end
end

function EssencePowerBar:UpdateChargedPowerPoints()
	self:UpdatePower();
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

function EssencePointButtonMixin:AnimIn(animationSpeedMultiplier, animationElapsedPortion)
	self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
	self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier);
	self:SetScript("OnUpdate", self.OnUpdate);
	self.EssenceFilling:Show();
	local fillingElapsedOffset = animationElapsedPortion * self.EssenceFilling.FillingAnim:GetDuration();
	local circleElapsedOffset = animationElapsedPortion * self.EssenceFilling.CircleAnim:GetDuration();
	self.EssenceFilling.FillingAnim:Play(false, fillingElapsedOffset);
	self.EssenceFilling.CircleAnim:Play(false, circleElapsedOffset);
	self.EssenceDepleting:Hide(); 
	self.EssenceEmpty:Hide(); 
	self.EssenceFillDone:Hide();
	self.EssenceFull:Hide();
end

function EssencePointButtonMixin:AnimOut()
	if(self.EssenceFull:IsShown() or self.EssenceFilling:IsShown() or self.EssenceFillDone:IsShown()) then 
		self.EssenceDepleting:Show();
		if(self.EssenceFilling.FillingAnim:IsPlaying()) then
			-- No depletion anim if we're filling (depletion art is for a full essence),
			-- but we do need to set ourselves to the final frame to get all element alphas correct.
			self.EssenceFilling.FillingAnim:Stop();
			self.EssenceFilling.CircleAnim:Stop();
			self.EssenceDepleting.AnimIn:Play(false, self.EssenceDepleting.AnimIn:GetDuration());
		else
			self.EssenceDepleting.AnimIn:Play();
		end
		self.EssenceFilling:Hide(); 
		self.EssenceEmpty:Hide(); 
		self.EssenceFillDone:Hide();
		self.EssenceFull:Hide(); 
		self:SetScript("OnUpdate", nil);
	end 
end

function EssencePointButtonMixin:SetEssennceFull()
	self.EssenceFilling.FillingAnim:Stop();
	self.EssenceFilling.CircleAnim:Stop();
	self.EssenceFillDone:Show();
	self.EssenceEmpty:Hide();
	self:SetScript("OnUpdate", nil);
end 