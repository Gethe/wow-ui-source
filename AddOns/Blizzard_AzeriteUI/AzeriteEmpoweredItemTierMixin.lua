AzeriteEmpoweredItemTierMixin = {};

AzeriteEmpoweredItemTierMixin.BACKGROUND_GLOW_STATE_NONE = nil;
AzeriteEmpoweredItemTierMixin.BACKGROUND_GLOW_STATE_SELECTION_ACTIVE = 1;
AzeriteEmpoweredItemTierMixin.BACKGROUND_GLOW_STATE_SELECTED = 2;

function AzeriteEmpoweredItemTierMixin:Reset()
	self.tierAnimation = nil;
	self.animatingAzeritePowerButton = nil;

	self.owningFrame = nil;
	self.azeritePowerButtons = {};
	self.selectedPowerID = nil;
	self.meetsPowerLevelRequirement = false;
	self.prereqTier = nil;
	self.tierRingGlow = nil;
	self.glowState = nil;
	self.tierPlug = nil;
	self.tierPlugBackground = nil;
	self.tierInfo = nil;
	self.rankFrame = nil;
	self.tierSelectedLights = nil;
	self.tierSlot = nil;

	self.transformNode = nil;
	self.animatedGearNode = nil;
end

function AzeriteEmpoweredItemTierMixin:SetOwner(owningFrame, azeriteItemDataSource)
	self.owningFrame = owningFrame;
	self.azeriteItemDataSource = azeriteItemDataSource;
end

function AzeriteEmpoweredItemTierMixin:GetOwner()
	return self.owningFrame;
end

function AzeriteEmpoweredItemTierMixin:SetTierInfo(tierIndex, numTiers, tierInfo, prereqTier)
	self.tierIndex = tierIndex;
	self.tierOffset = AZERITE_EMPOWERED_ITEM_MAX_TIERS - numTiers;
	self.tierInfo = tierInfo;
	self.prereqTier = prereqTier;
	self.isFinalTier = tierIndex == numTiers;
end

function AzeriteEmpoweredItemTierMixin:SetVisuals(tierSlot, rankFrame, tierPlug, rootTransformNode)
	self.tierSlot = tierSlot;
	self.tierPlug = tierPlug;

	self.rankFrame = rankFrame;
	if self.rankFrame then
		self.rankFrame:Show();
		
		self.tierSelectedLights = rankFrame.RingLights;
		self.tierRingGlow = rankFrame.RingBgGlow;
		self.tierPlugBackground = rankFrame.PlugBg;

		self.animatedGearNode = rankFrame.Gear.transformNode;

		self.transformNode = rankFrame.RingBg.transformNode;
	else
		self.transformNode = rootTransformNode;
	end
end

function AzeriteEmpoweredItemTierMixin:SetupPlugs()
	if self.tierPlug or self.tierPlugBackground or self.tierSlot then
		if self.tierPlugBackground then
			self.tierPlugBackground:Show();
		end
		if self.tierSlot then
			self.tierSlot:Show();
		end

		local offset = AzeriteLayoutInfo.CalculatePlugOffset(self:GetTierIndex() + self.tierOffset);

		local function ApplyOffset(texture, offset)
			local scale = texture:GetScale();
			texture:SetPoint("CENTER", texture:GetParent(), "CENTER", offset.x / scale, offset.y / scale);
		end

		if self.tierPlug then
			ApplyOffset(self.tierPlug, offset);
		end
		if self.tierPlugBackground then
			ApplyOffset(self.tierPlugBackground, offset);
		end
		if self.tierSlot then
			ApplyOffset(self.tierSlot, offset);
		end
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

function AzeriteEmpoweredItemTierMixin:PrepareForReveal()
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		azeritePowerButton:PrepareForRevealAnimation();
	end

	if self:IsFinalTier() then
		self:PlayPowerReveal(3.2);
	else
		self.tierAnimation = AzeriteTierRevealAnimationMixin:Create(self);

		local animBegin = true;
		self.owningFrame:OnTierAnimationStateChanged(self, animBegin);

		self.tierAnimation:Play();
	end
end

function AzeriteEmpoweredItemTierMixin:OnTierRevealRotationStarted()
	local forceNoDuplicates = false;
	PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONSTARTCLICKS, nil, forceNoDuplicates);

	self.owningFrame:OnTierRevealRotationStarted(self);
end

function AzeriteEmpoweredItemTierMixin:OnTierRevealRotationStopped()
	self.owningFrame:OnTierRevealRotationStopped(self);
end

function AzeriteEmpoweredItemTierMixin:PlayRevealGlows()
	self:TransitionBackgroundGlow(self.BACKGROUND_GLOW_STATE_SELECTED);

	if self.rankFrame then
		self.rankFrame.SelectedAnim:Play();
	end
end

function AzeriteEmpoweredItemTierMixin:PlayPowerReveal(timeDelay)
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		azeritePowerButton:PlayRevealAnimation(timeDelay);
	end
end

function AzeriteEmpoweredItemTierMixin:Update(azeriteItemPowerLevel)
	self.azeriteItemPowerLevel = azeriteItemPowerLevel;
	self.meetsPowerLevelRequirement = azeriteItemPowerLevel >= self.tierInfo.unlockLevel;
	self.selectedPowerID = nil;

	if self:IsAnimating() then
		if self.tierSlot then
			self.tierSlot:Disable();
		end
		return;
	end

	self:UpdatePowerStates();

	if self.tierSlot then
		self.tierSlot:SetPowerLevelInfo(self.azeriteItemPowerLevel, self.tierInfo.unlockLevel, self:HasAnySelected(), self:IsSelectionActive(), self.azeriteItemDataSource:IsPreviewSource(), self:IsFinalTier());
		self.tierSlot:Enable();
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

	local isSelectionActive = not self:IsAnyTierRevealing() and not self:IsAnimating() and self:IsSelectionActive();
	local specID = GetSpecializationInfo(GetSpecialization())
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		local isSpecAllowed = C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(azeritePowerButton:GetAzeritePowerID(), specID);
		azeritePowerButton:SetCanBeSelectedDetails(isSelectionActive, self.meetsPowerLevelRequirement, self.tierInfo.unlockLevel, isSpecAllowed, self:HasAnySelected());
	end

	if not self:IsAnyTierRevealing() then
		self:TransitionBackgroundGlow(isSelectionActive and self.BACKGROUND_GLOW_STATE_SELECTION_ACTIVE or self.BACKGROUND_GLOW_STATE_NONE);
	end

	if self.tierPlug then
		self.tierPlug:SetShown(self:ShouldShowTierPlug(isSelectionActive));
	end
end

function AzeriteEmpoweredItemTierMixin:ShouldShowTierPlug(isSelectionActive)
	if self:IsAnyTierRevealing() then
		return true;
	end

	if self:IsAnimating() then
		return false;
	end

	if self:HasAnySelected() then
		return false;
	end

	return not isSelectionActive;
end

function AzeriteEmpoweredItemTierMixin:TransitionBackgroundGlow(glowState)
	if self.rankFrame and self.glowState ~= glowState then
		if glowState == self.BACKGROUND_GLOW_STATE_NONE then
			self.rankFrame.SelectionActiveFadeAnim:SetScript("OnFinished", nil);
			self.rankFrame.SelectionActiveFadeAnim.Alpha:SetFromAlpha(self.tierRingGlow:GetAlpha());
			self.rankFrame.SelectionActiveFadeAnim.Alpha:SetToAlpha(0.0);
			self.rankFrame.SelectionActiveFadeAnim:Stop();
			self.rankFrame.SelectionActiveLoopAnim:Stop();
			self.rankFrame.SelectedGlowAnim:Stop();

			self.rankFrame.SelectionActiveFadeAnim:Play();
		elseif glowState == self.BACKGROUND_GLOW_STATE_SELECTION_ACTIVE then
			self.rankFrame.SelectedGlowAnim:Stop();
			self.rankFrame.SelectionActiveFadeAnim:Stop();

			if not self.rankFrame.SelectionActiveLoopAnim:IsPlaying() then
				self.rankFrame.SelectionActiveFadeAnim.Alpha:SetFromAlpha(self.tierRingGlow:GetAlpha());
				self.rankFrame.SelectionActiveFadeAnim.Alpha:SetToAlpha(0.5);

				self.rankFrame.SelectionActiveFadeAnim:SetScript("OnFinished", function()
					self.rankFrame.SelectionActiveFadeAnim:SetScript("OnFinished", nil);

					self.rankFrame.SelectionActiveLoopAnim:Play();
				end);
				self.rankFrame.SelectionActiveFadeAnim:Play();
			end
		elseif glowState == self.BACKGROUND_GLOW_STATE_SELECTED then
			self.rankFrame.SelectionActiveFadeAnim:SetScript("OnFinished", nil);

			self.rankFrame.SelectedGlowAnim.Alpha:SetFromAlpha(self.tierRingGlow:GetAlpha());
			self.rankFrame.SelectionActiveLoopAnim:Stop();

			self.rankFrame.SelectionActiveFadeAnim:Stop();

			self.rankFrame.SelectedGlowAnim:Play();
		end

		self.glowState = glowState;
	end
end

function AzeriteEmpoweredItemTierMixin:PerformAnimations(elapsed)
	if self:IsAnimating() then
		self.tierAnimation:PerformAnimation(elapsed);

		if self.tierAnimation:IsFinished() then
			self.tierAnimation = nil;
			self.animatingAzeritePowerButton = nil;

			self:UpdatePowerStates();

			local animBegin = false;
			self.owningFrame:OnTierAnimationStateChanged(self, animBegin);
		end
	end
end

function AzeriteEmpoweredItemTierMixin:OnTierAnimationProgress(progress)
	self.owningFrame:OnTierAnimationProgress(self, progress);
end

function AzeriteEmpoweredItemTierMixin:ApplyShakeOffset(offset)
	self.transformNode:SetLocalPosition(offset);
end

function AzeriteEmpoweredItemTierMixin:PlayLockedInEffect()
	if self.tierSlot then
		self.tierSlot:PlayLockedInEffect();
	end
end

function AzeriteEmpoweredItemTierMixin:IsAnimating()
	return self.tierAnimation ~= nil;
end

function AzeriteEmpoweredItemTierMixin:IsRevealing()
	return self:IsAnimating() and self.tierAnimation:GetAnimType() == AzeriteTierRevealAnimationMixin;
end

function AzeriteEmpoweredItemTierMixin:IsAnyTierRevealing()
	return self.owningFrame:IsAnyTierRevealing();
end

function AzeriteEmpoweredItemTierMixin:OnPowerSelected(azeritePowerButton)
	self.animatingAzeritePowerButton = azeritePowerButton;

	self:TransitionBackgroundGlow(self.BACKGROUND_GLOW_STATE_SELECTED);

	if self.rankFrame then
		self.rankFrame.SelectedAnim:Play();
	end

	if self.tierPlug then
		self.tierPlug:Hide();
	end

	if self:IsFinalTier() then
		self.tierAnimation = AzeriteTierFinalPowerSelectedAnimationMixin:Create(self);
	else
		self.tierAnimation = AzeriteTierPowerSelectedAnimationMixin:Create(self, azeritePowerButton, self.transformNode:GetLocalRotation(), self.owningFrame:GetLoopingSoundEmitter());
	end

	local animBegin = true;
	self.owningFrame:OnTierAnimationStateChanged(self, animBegin);

	self.tierAnimation:Play();
end

function AzeriteEmpoweredItemTierMixin:CanSelectPowers()
	return self.owningFrame:CanSelectPowers();
end

function AzeriteEmpoweredItemTierMixin:SetNodeRotations(rotationRads)
	self.transformNode:SetLocalRotation(rotationRads);
	if self.animatedGearNode then
		local INNER_GEAR_ANIM_RATE = .25; -- percent
		self.animatedGearNode:SetLocalRotation(-rotationRads * INNER_GEAR_ANIM_RATE);
	end
end

function AzeriteEmpoweredItemTierMixin:GetNodeRotation()
	return self.transformNode:GetLocalRotation();
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

function AzeriteEmpoweredItemTierMixin:IsFirstTier()
	return self:GetTierIndex() == 1;
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
	return self.animatingAzeritePowerButton == azeritePowerButton;
end

function AzeriteEmpoweredItemTierMixin:GetAzeritePowerButtonByID(azeritePowerID)
	for powerIndex, azeritePowerButton in ipairs(self.azeritePowerButtons) do
		if azeritePowerButton:GetAzeritePowerID() == azeritePowerID then
			return azeritePowerButton;
		end
	end
	return nil;
end