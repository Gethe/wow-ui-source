AzeriteEmpoweredItemTierMixin = {};

AzeriteEmpoweredItemTierMixin.ANIM_STATE_NONE = nil;
AzeriteEmpoweredItemTierMixin.ANIM_STATE_LOCKING_IN = 1;

local INNER_GEAR_ANIM_RATE = .25; -- percent

function AzeriteEmpoweredItemTierMixin:OnLoad()
	local startingSound = SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONSTARTCLICKS;
	local loopingSound = SOUNDKIT.UI_80_AZERITEARMOR_ROTATION_LOOP;
	local endingSound = SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDCLICKS;

	local loopStartDelay = .5;
	local loopEndDelay = 0;
	local loopFadeTime = 500; -- ms
	self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function AzeriteEmpoweredItemTierMixin:Reset()
	self:SetAnimState(self.ANIM_STATE_NONE);

	self.owningFrame = nil;
	self.azeritePowerButtons = {};
	self.selectedPowerID = nil;
	self.meetsPowerLevelRequirement = false;
	self.prereqTier = nil;
	self.tierRingGlow = nil;
	self.tierPlug = nil;
	self.tierPlugBackground = nil;
	self.tierInfo = nil;

	self.transformNode = nil;
	self.animatedGearNode = nil;

	self.loopingSoundEmitter:CancelLoopingSound();
end

function AzeriteEmpoweredItemTierMixin:SetOwner(owningFrame, azeriteItemDataSource)
	self.owningFrame = owningFrame;
	self.azeriteItemDataSource = azeriteItemDataSource;
end

function AzeriteEmpoweredItemTierMixin:SetTierInfo(tierIndex, numTiers, tierInfo, prereqTier)
	self.tierIndex = tierIndex;
	self.tierOffset = AZERITE_EMPOWERED_ITEM_MAX_TIERS - numTiers;
	self.tierInfo = tierInfo;
	self.prereqTier = prereqTier;
	self.isFinalTier = tierIndex == numTiers;
end

function AzeriteEmpoweredItemTierMixin:SetVisuals(tierSlot, tierRingGlow, tierPlug, tierPlugBackground, transformNode, animatedGearNode)
	self.tierSlot = tierSlot;
	self.tierRingGlow = tierRingGlow;
	self.tierPlug = tierPlug;
	self.tierPlugBackground = tierPlugBackground;
	self.transformNode = transformNode;
	self.animatedGearNode = animatedGearNode;

	if self.tierRingGlow then
		self.tierRingGlow:Show();
	end
end

function AzeriteEmpoweredItemTierMixin:SetupPlugs()
	if self.tierPlug and self.tierPlugBackground and self.tierSlot then
		self.tierPlugBackground:Show();
		self.tierSlot:Show();

		local offset = AzeriteLayoutInfo.CalculatePlugOffset(self:GetTierIndex() + self.tierOffset);

		local function ApplyOffset(texture, offset)
			local scale = texture:GetScale();
			texture:SetPoint("CENTER", texture:GetParent(), "CENTER", offset.x / scale, offset.y / scale);
		end

		ApplyOffset(self.tierPlug, offset);
		ApplyOffset(self.tierPlugBackground, offset);
		ApplyOffset(self.tierSlot, offset);
	end
end

function AzeriteEmpoweredItemTierMixin:CreatePowers(powerPool)
	local numPowers = #self.tierInfo.azeritePowerIDs;
	for powerIndex, azeritePowerID in ipairs(self.tierInfo.azeritePowerIDs) do
		local localNodePosition, angleRads = AzeriteLayoutInfo.CalculatePowerOffset(powerIndex, numPowers, self:GetTierIndex() + self.tierOffset);
		local azeritePowerButton = powerPool:Acquire(self.transformNode, localNodePosition);

		azeritePowerButton:Setup(self, self.azeriteItemDataSource, azeritePowerID, -angleRads);
		table.insert(self.azeritePowerButtons, azeritePowerButton);

		azeritePowerButton:Show();
	end

	self:SetupPlugs();
end

function AzeriteEmpoweredItemTierMixin:Update(azeriteItemPowerLevel)
	self.azeriteItemPowerLevel = azeriteItemPowerLevel;
	self.meetsPowerLevelRequirement = azeriteItemPowerLevel >= self.tierInfo.unlockLevel;
	self.selectedPowerID = nil;

	if self:IsAnimating() then
		return;
	end

	self:UpdatePowerStates();

	if self.tierSlot then
		self.tierSlot:SetPowerLevelInfo(self.azeriteItemPowerLevel, self.tierInfo.unlockLevel, self:HasAnySelected(), self:IsSelectionActive(), self.azeriteItemDataSource:IsPreviewSource());
	end

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
	local specID = GetSpecializationInfo(GetSpecialization())
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		local isSpecAllowed = C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(azeritePowerButton:GetAzeritePowerID(), specID);
		azeritePowerButton:SetCanBeSelectedDetails(isSelectionActive, self.meetsPowerLevelRequirement, self.tierInfo.unlockLevel, isSpecAllowed, self:HasAnySelected());
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

	if self.tierPlug then
		self.tierPlug:SetShown(not self:IsAnimating() and not self:HasAnySelected() and not isSelectionActive);
	end
end

local function LockInEase(percent)
	if percent < .5 then
		return ((percent * 2) ^ 2) / 2;
	end
	return 1 - (((1 - percent) * 2) ^ 2) / 2;
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
			local newRotation = Lerp(startAngle, targetAngle, LockInEase(percent));

			local LERP_AMOUNT_PER_NORMALIZED_FRAME = .2;
			local smoothedRotation = FrameDeltaLerp(self.transformNode:GetLocalRotation(), newRotation, LERP_AMOUNT_PER_NORMALIZED_FRAME);

			if percent > .85 and not self.animContextData.hasPlayedEndingClickSound then
				self.animContextData.hasPlayedEndingClickSound = true;
				self.loopingSoundEmitter:FinishLoopingSound();
			end

			if percent > .95 and not self.animContextData.hasPlayedLockInEffect then
				self.animContextData.hasPlayedLockInEffect = true;
				PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDS);
				self:PlayLockedInEffect();
			end

			local CLOSE_ENOUGH_ANGLE_DIFF = math.pi * .0001;
			if percent == 1.0 and math.abs(newRotation - smoothedRotation) < CLOSE_ENOUGH_ANGLE_DIFF then
				self:SetNodeRotations(newRotation);
				self:SetAnimState(self.ANIM_STATE_NONE);
			else
				self:SetNodeRotations(smoothedRotation);
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

		self.owningFrame:OnTierAnimationStateChanged();
		self:UpdatePowerStates();
	end
end

function AzeriteEmpoweredItemTierMixin:PlayLockedInEffect()
	if self.tierSlot then
		self.tierSlot:PlayLockedInEffect();
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
		hasPlayedLockInEffect = false,
		hasPlayedEndingClickSound = false,
	};

	self.loopingSoundEmitter:StartLoopingSound();

	if self.tierPlug then
		self.tierPlug:Hide();
	end
end

function AzeriteEmpoweredItemTierMixin:IsAnimating()
	return self.animState ~= self.ANIM_STATE_NONE;
end

function AzeriteEmpoweredItemTierMixin:OnPowerSelected(azeritePowerButton)
	if not self:IsFinalTier() then
		self:SetAnimState(self.ANIM_STATE_LOCKING_IN, azeritePowerButton);
	end
end

function AzeriteEmpoweredItemTierMixin:SetNodeRotations(rotationRads)
	self.transformNode:SetLocalRotation(rotationRads);
	if self.animatedGearNode then
		self.animatedGearNode:SetLocalRotation(-rotationRads * INNER_GEAR_ANIM_RATE);
	end
end

function AzeriteEmpoweredItemTierMixin:SnapToSelection()
	if not self:IsAnimating() then
		local selectedPowerID = self:GetSelectedPowerID();
		if selectedPowerID and not self:IsFinalTier() then
			local azeritePowerButton = self:GetAzeritePowerButtonByID(selectedPowerID);
			self:SetNodeRotations(azeritePowerButton:GetBaseAngle());
		else
			self:SetNodeRotations(0.0);
		end
	end
end

function AzeriteEmpoweredItemTierMixin:GetTierIndex()
	return self.tierIndex;
end

function AzeriteEmpoweredItemTierMixin:IsFinalTier()
	return self.isFinalTier;
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

	if self.azeriteItemDataSource:IsPreviewSource() then
		return false;
	end

	if self.prereqTier then
		if not self.prereqTier:HasAnySelected() then
			return false;
		end
	end

	return self.meetsPowerLevelRequirement;
end

function AzeriteEmpoweredItemTierMixin:IsPowerButtonAnimatingSelection(azeritePowerButton)
	return self.animContextData and self.animContextData.azeritePowerButton == azeritePowerButton or false;
end

function AzeriteEmpoweredItemTierMixin:GetAzeritePowerButtonByID(azeritePowerID)
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		if azeritePowerButton:GetAzeritePowerID() == azeritePowerID then
			return azeritePowerButton;
		end
	end
	return nil;
end