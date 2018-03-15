AzeriteEmpoweredItemTierMixin = {};

AzeriteEmpoweredItemTierMixin.ANIM_STATE_NONE = nil;
AzeriteEmpoweredItemTierMixin.ANIM_STATE_LOCKING_IN = 1;

function AzeriteEmpoweredItemTierMixin:Reset()
	self.owningFrame = nil;
	self.azeritePowerButtons = {};
	self.selectedPowerID = nil;
	self.meetsPowerLevelRequirement = false;
	self.previousTier = nil;
	self.tierRingGlow = nil;
	self.tierInfo = nil;
	self.transformNode = nil;

	self:SetAnimState(self.ANIM_STATE_NONE);
end

function AzeriteEmpoweredItemTierMixin:Setup(owningFrame, empoweredItemLocation, tierInfo, previousTier, tierRingGlow, transformNode, powerPool)
	self:Reset();
	self.owningFrame = owningFrame;
	self.previousTier = previousTier;
	self.tierInfo = tierInfo;
	self.tierRingGlow = tierRingGlow;
	self.transformNode = transformNode;

	if self.tierRingGlow then
		self.tierRingGlow:Show();
	end

	self:CreatePowers(empoweredItemLocation, powerPool);
end

local BASE_ROTATION_OFFSET = math.pi / 2;

local LAYOUT_TIER_INFO = {
	{ 
		radius = 0, 
		startRadians = 
		{
			default = 0.0,
		},
	},
	{ 
		radius = 103, 
		startRadians = 
		{
			default = math.pi / 2,
		},
	},
	{ 
		radius = 176, 
		startRadians = 
		{
			default = math.pi / 2.5,
		},
	},
	{ 
		radius = 250,
		startRadians = 
		{
			default = math.pi / 4,
		},
	},
}

local function CalculatePowerOffset(powerIndex, numPowers, tierIndex)
	local layoutInfo = LAYOUT_TIER_INFO[tierIndex];
	if not layoutInfo then
		error("Unknown tier index");
	end

	local startRadians = layoutInfo.startRadians[numPowers] or layoutInfo.startRadians.default;
	local angleRads = Lerp(startRadians, 2 * math.pi - startRadians, PercentageBetween(powerIndex, 1, numPowers));
	return CreateVector2D(math.cos(BASE_ROTATION_OFFSET + angleRads) * layoutInfo.radius, math.sin(BASE_ROTATION_OFFSET + angleRads) * layoutInfo.radius), angleRads;
end

function AzeriteEmpoweredItemTierMixin:CreatePowers(empoweredItemLocation, powerPool)
	if self.tierInfo.tierIndex == 3 then -- fix data
		--table.insert(self.tierInfo.azeritePowerIDs, 30);
	end
	if self.tierInfo.tierIndex == 4 then -- fake druid
		--table.insert(self.tierInfo.azeritePowerIDs, 30);
	end

	local numPowers = #self.tierInfo.azeritePowerIDs;
	for powerIndex, azeritePowerID in ipairs(self.tierInfo.azeritePowerIDs) do
		local localNodePosition, angleRads = CalculatePowerOffset(powerIndex, numPowers, self.tierInfo.tierIndex);
		local azeritePowerButton = powerPool:Acquire(self.transformNode, localNodePosition);

		azeritePowerButton:Setup(self, empoweredItemLocation, azeritePowerID, -angleRads);
		table.insert(self.azeritePowerButtons, azeritePowerButton);

		azeritePowerButton:Show();
	end
end

function AzeriteEmpoweredItemTierMixin:Update(azeriteItemPowerLevel)
	self.azeriteItemPowerLevel = azeriteItemPowerLevel;
	self.meetsPowerLevelRequirement = azeriteItemPowerLevel >= self.tierInfo.unlockLevel;
	self.selectedPowerID = nil;

	if self:IsAnimating() then
		return;
	end

	self:UpdatePowerStates();

	self:SnapToSelection();
end

function AzeriteEmpoweredItemTierMixin:UpdatePowerStates()
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		azeritePowerButton:Update();

		if azeritePowerButton:IsSelected() then
			self.selectedPowerID = azeritePowerButton:GetAzeritePowerID();
		end
	end

	local isSelectionActive = not self:IsAnimating() and self:IsSelectionActive();
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		azeritePowerButton:SetCanBeSelected(isSelectionActive);
	end

	if self.tierRingGlow then
		if isSelectionActive then
			if not self.tierRingGlow.SelectedAnim:IsPlaying() then
				self.tierRingGlow.FadeAnim:Stop();
				self.tierRingGlow.SelectedAnim:Play();
			end
		else
			if self.tierRingGlow.SelectedAnim:IsPlaying() then
				self.tierRingGlow.FadeAnim.Alpha:SetFromAlpha(self.tierRingGlow:GetAlpha());
				self.tierRingGlow.SelectedAnim:Stop();
				self.tierRingGlow.FadeAnim:Play();
			end
		end
	end
end
function AzeriteEmpoweredItemTierMixin:PerformAnimations()
	if self:IsAnimating() then
		if self.animState == self.ANIM_STATE_LOCKING_IN then
			local startAngle = self.animContextData.startAngle;
			local angleDelta = self.animContextData.angleDelta;
			local targetAngle = startAngle + angleDelta;

			local startTime = self.animContextData.startTime;
			local durationSec = self.animContextData.durationSec;
			local endTime = startTime + durationSec;

			local now = GetTime();

			local percent = ClampedPercentageBetween(now, startTime, endTime);
			local newRotation = Lerp(startAngle, targetAngle, percent);
			self.transformNode:SetLocalRotation(newRotation);

			if percent == 1.0 then
				newRotation = targetAngle;
				self:SetAnimState(self.ANIM_STATE_NONE);
			end
		end
	end
end

function AzeriteEmpoweredItemTierMixin:SetAnimState(newAnimState, ...)
	if newAnimState ~= self.animState then
		if newAnimState == self.ANIM_STATE_NONE then
			self.animState = self.ANIM_STATE_NONE;
			self.animContextData = nil;

		elseif newAnimState == self.ANIM_STATE_LOCKING_IN then
			self.animState = self.ANIM_STATE_LOCKING_IN;
			self:InitializeLockInAnimation(...);
		end

		self.owningFrame:OnTierAnimationFinished();
		self:UpdatePowerStates();
	end
end

function AzeriteEmpoweredItemTierMixin:InitializeLockInAnimation(azeritePowerButton)
	local startAngle = self.transformNode:GetLocalRotation();
	local endAngle = azeritePowerButton:GetBaseAngle();
	local angleDelta = math.atan2(math.sin(endAngle - startAngle), math.cos(endAngle - startAngle));

	local DISTANCE_PER_SEC = math.pi * .35;

	self.animContextData = {
		azeritePowerButton = azeritePowerButton,
		startAngle = startAngle,
		angleDelta = angleDelta,
		startTime = GetTime(),
		durationSec = math.abs(angleDelta) / DISTANCE_PER_SEC,
	};
end

function AzeriteEmpoweredItemTierMixin:IsAnimating()
	return self.animState ~= self.ANIM_STATE_NONE;
end

function AzeriteEmpoweredItemTierMixin:OnPowerSelected(azeritePowerButton)
	self:SetAnimState(self.ANIM_STATE_LOCKING_IN, azeritePowerButton);
end

function AzeriteEmpoweredItemTierMixin:SnapToSelection()
	if not self:IsAnimating() then
		local selectedPowerID = self:GetSelectedPowerID();
		if selectedPowerID and #self.tierInfo.azeritePowerIDs > 1 then
			local azeritePowerButton = self:GetAzeritePowerButtonByID(selectedPowerID);
			self.transformNode:SetLocalRotation(azeritePowerButton:GetBaseAngle());
		else
			self.transformNode:SetLocalRotation(0.0);
		end
	end
end

function AzeriteEmpoweredItemTierMixin:GetSelectedPowerID()
	return self.selectedPowerID;
end

function AzeriteEmpoweredItemTierMixin:HasAnySelected()
	return self:GetSelectedPowerID() ~= nil;
end

function AzeriteEmpoweredItemTierMixin:IsSelectionActive()
	if self:HasAnySelected() then
		return false;
	end

	if self.previousTier then
		if not self.previousTier:HasAnySelected() then
			return false;
		end
	end

	return self.meetsPowerLevelRequirement;
end

function AzeriteEmpoweredItemTierMixin:GetAzeritePowerButtonByID(azeritePowerID)
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		if azeritePowerButton:GetAzeritePowerID() == azeritePowerID then
			return azeritePowerButton;
		end
	end
	return nil;
end