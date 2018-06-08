AzeriteEmpoweredItemPowerMixin = {};

function AzeriteEmpoweredItemPowerMixin:Setup(owningTierFrame, azeriteItemDataSource, azeritePowerID, baseAngle)
	self:CancelItemLoadCallback();

	self.owningTierFrame = owningTierFrame;
	self.azeriteItemDataSource = azeriteItemDataSource;
	self.azeritePowerID = azeritePowerID;
	self.baseAngle = baseAngle;

	self:Update();

	self.canBeSelected = nil;
	self.transitionStateInitialized = false;

	local spellTexture = GetSpellTexture(self:GetSpellID()); 
	self.Icon:SetTexture(spellTexture);
	self.IconDesaturated:SetTexture(spellTexture);

	self:SetupModelScene();
end

function AzeriteEmpoweredItemPowerMixin:Reset()
	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();
	self.TransitionAnimation:Stop();
	self.SwirlContainer.Anim:Stop();
	self.SwirlContainer:Hide();
end

function AzeriteEmpoweredItemPowerMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteEmpoweredItemPowerMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteEmpoweredItemPowerMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(forceUpdate);
	end
end

function AzeriteEmpoweredItemPowerMixin:SetupModelScene(forceUpdate)
	self.clickEffectActor = AzeriteModelInfo.SetupModelScene(self.ClickEffect, AzeriteModelInfo.ModelSceneTypePowerClick, forceUpdate);
	if self.clickEffectActor then
		self.clickEffectActor:SetAnimation(0, 0, 0, 0);
	end

	AzeriteModelInfo.SetupModelScene(self.CanSelectEffect, AzeriteModelInfo.ModelSceneTypePowerReadyForSelection, forceUpdate);
end

function AzeriteEmpoweredItemPowerMixin:Update()
	self.spellID = self.azeriteItemDataSource:GetPowerSpellID(self.azeritePowerID);
	self.isSelected = self.azeriteItemDataSource:IsPowerSelected(self.azeritePowerID);

	C_Spell.RequestLoadSpellData(self:GetSpellID()); -- Try to minimize tooltips popping as spell data loads
end

function AzeriteEmpoweredItemPowerMixin:IsFinalPower()
	return self.owningTierFrame:IsFinalTier();
end

function AzeriteEmpoweredItemPowerMixin:GetBaseAngle()
	return self.baseAngle;
end

function AzeriteEmpoweredItemPowerMixin:UpdateStyle()
	self.CanSelectGlow:SetShown(self:CanBeSelected());
	self.Arrow:SetShown(false); -- Trying without

	self:SetFrameStrata(self:IsFinalPower() and "HIGH" or "MEDIUM");
	self.ClickEffect:SetFrameStrata(self:IsFinalPower() and "DIALOG" or "HIGH")

	if self:IsFinalPower() then
		self:SetSize(120, 120);
		self.Icon:SetSize(135, 135);
		self.CircleMask:SetSize(115, 115);
		self.IconBorder:SetAtlas("Azerite-CenterTrait-RingDisable", true);
		self.IconBorderSelectable:SetAtlas("Azerite-CenterTrait-Ring", true);
		self.CanSelectGlow:SetScale(1.35);
		self.SwirlContainer:SetScale(1.35);
	else
		self:SetSize(80, 80);
		self.Icon:SetSize(100, 100);
		self.CircleMask:SetSize(100, 100);
		self.IconBorder:SetAtlas("Azerite-Trait-Ring", true);
		self.IconBorderSelectable:SetAtlas("Azerite-Trait-Ring-Open", true);
		self.CanSelectGlow:SetScale(1.0);
		self.SwirlContainer:SetScale(1.0);
	end

	self.IconBorder:SetShown(not self:IsSelected() or self:IsAnimatingAsSelection());
	if self.azeriteItemDataSource:IsPreviewSource() or self:CanBeSelected() or self:IsSelected() or self:IsAnimatingAsSelection() then
		self.Icon:SetVertexColor(1, 1, 1);
		self.IconDesaturated:SetVertexColor(1, 1, 1);
	else
		self.Icon:SetVertexColor(.85, .85, .85);
		self.IconDesaturated:SetVertexColor(.85, .85, .85);
	end

	if self:CanBeSelected() then
		self.CanSelectGlowAnim:Play();
		self.CanSelectArrowAnim:Play();
	else
		self.CanSelectGlowAnim:Stop();
		self.CanSelectArrowAnim:Stop();
	end

	self:PlayTransitionAnimation();
end

function AzeriteEmpoweredItemPowerMixin:PlayTransitionAnimation()
	if self.SwirlContainer.Anim:IsPlaying() then
		assert(not self.TransitionAnimation:IsPlaying());
		return;
	end

	if not self.transitionStateInitialized then
		self.transitionStateInitialized = true;
		assert(not self.TransitionAnimation:IsPlaying());

		self.CanSelectEffect:SetAlpha(0);
		self.IconDesaturated:SetAlpha(self:GetDesaturationValue());
		self.IconBorderSelectable:SetAlpha(self:GetBorderSelectableAlphaValue());
		self.IconBorder:SetAlpha(self:GetBorderAlphaValue());
		self.IconNotSelectableOverlay:SetAlpha(self:GetIconNotSelectableOverlayAlphaValue());
	end

	self.TransitionAnimation.Effect:SetFromAlpha(self.CanSelectEffect:GetAlpha());
	self.TransitionAnimation.Effect:SetToAlpha(self:GetCanSelectEffectAlphaValue());
	
	self.TransitionAnimation.Desaturation:SetFromAlpha(self.IconDesaturated:GetAlpha());
	self.TransitionAnimation.Desaturation:SetToAlpha(self:GetDesaturationValue());

	self.TransitionAnimation.BorderSelectable:SetFromAlpha(self.IconBorderSelectable:GetAlpha());
	self.TransitionAnimation.BorderSelectable:SetToAlpha(self:GetBorderSelectableAlphaValue());
	
	self.TransitionAnimation.IconBorder:SetFromAlpha(self.IconBorder:GetAlpha());
	self.TransitionAnimation.IconBorder:SetToAlpha(self:GetBorderAlphaValue());

	self.TransitionAnimation.IconNotSelectableOverlay:SetFromAlpha(self.IconNotSelectableOverlay:GetAlpha());
	self.TransitionAnimation.IconNotSelectableOverlay:SetToAlpha(self:GetIconNotSelectableOverlayAlphaValue());

	self.TransitionAnimation:Stop();

	self.TransitionAnimation:Play();
end

function AzeriteEmpoweredItemPowerMixin:GetCanSelectEffectAlphaValue()
	if self:IsAnimatingAsSelection() then
		return 1;
	end

	if self:CanBeSelected() then
		return 1;
	end

	return 0;
end

function AzeriteEmpoweredItemPowerMixin:GetBorderSelectableAlphaValue()
	if self:IsSelected() then
		if self:IsFinalPower() then
			return 1;
		end
		return 0;
	end

	if self:IsAnimatingAsSelection() then
		return 1;
	end

	if self:CanBeSelected() then
		return 1;
	end

	if self:IsTierSelectionActive() and self:MeetsPowerLevelRequirement() and not self:IsSpecAllowed() then
		return .75;
	end

	return 0;
end

function AzeriteEmpoweredItemPowerMixin:GetBorderAlphaValue()
	return 1.0 - self:GetBorderSelectableAlphaValue();
end

function AzeriteEmpoweredItemPowerMixin:GetIconNotSelectableOverlayAlphaValue()
	if self.azeriteItemDataSource:IsPreviewSource() then
		if self:IsSpecAllowed() then
			return 0;
		end
		return 1;
	end

	if self:IsAnimatingAsSelection() or self:IsSelected() or self:CanBeSelected() then
		return 0;
	end

	return 1;
end

function AzeriteEmpoweredItemPowerMixin:GetDesaturationValue()
	if self:IsSelected() then
		return 0;
	end

	if self.azeriteItemDataSource:IsPreviewSource() then
		return 0;
	end

	if not self:MeetsPowerLevelRequirement() then
		return 1;
	end

	if self:DoesTierHaveAnyPowersSelected() then
		return 1;
	end

	return 0;
end

function AzeriteEmpoweredItemPowerMixin:IsAnimatingAsSelection()
	return self.owningTierFrame:IsPowerButtonAnimatingSelection(self);
end

function AzeriteEmpoweredItemPowerMixin:GetAzeritePowerID()
	return self.azeritePowerID;
end

function AzeriteEmpoweredItemPowerMixin:GetSpellID()
	return self.spellID;
end

function AzeriteEmpoweredItemPowerMixin:GetTierIndex()
	return self.owningTierFrame:GetTierIndex();
end

function AzeriteEmpoweredItemPowerMixin:IsSelected()
	return self.isSelected;
end

function AzeriteEmpoweredItemPowerMixin:CanBeSelected()
	return self:IsTierSelectionActive() and self:MeetsPowerLevelRequirement() and self:IsSpecAllowed() and not self.azeriteItemDataSource:IsPreviewSource();
end

function AzeriteEmpoweredItemPowerMixin:MeetsPowerLevelRequirement()
	return self.meetsPowerLevelRequirement;
end

function AzeriteEmpoweredItemPowerMixin:DoesTierHaveAnyPowersSelected()
	return self.tierHasAnyPowersSelected;
end

function AzeriteEmpoweredItemPowerMixin:IsTierSelectionActive()
	return self.isTierSelectionActive;
end

function AzeriteEmpoweredItemPowerMixin:IsSpecAllowed()
	return self.isSpecAllowed;
end

function AzeriteEmpoweredItemPowerMixin:SetCanBeSelectedDetails(isTierSelectionActive, meetsPowerLevelRequirement, unlockLevel, isSpecAllowed, tierHasAnyPowersSelected)
	self.isTierSelectionActive = isTierSelectionActive;
	self.meetsPowerLevelRequirement = meetsPowerLevelRequirement;
	self.unlockLevel = unlockLevel;
	self.isSpecAllowed = isSpecAllowed;
	self.tierHasAnyPowersSelected = tierHasAnyPowersSelected;

	self:UpdateStyle();
end

function AzeriteEmpoweredItemPowerMixin:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteEmpoweredItemPowerMixin:OnEnter()
	self:CancelItemLoadCallback();
	local item = self.azeriteItemDataSource:GetItem();

	self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local itemID = item:GetItemID();
		local itemLevel = item:GetCurrentItemLevel();
		local itemLink = item:GetItemLink();
		GameTooltip:SetAzeritePower(itemID, itemLevel, self:GetAzeritePowerID(), itemLink);

		if self:CanBeSelected() then
			GameTooltip:AddLine(" ");
			GameTooltip_AddInstructionLine(GameTooltip, AZERITE_CLICK_TO_SELECT, GREEN_FONT_COLOR);
		else
			local showUnlockReq = not self:MeetsPowerLevelRequirement() and not self:DoesTierHaveAnyPowersSelected();
			if showUnlockReq then
				GameTooltip:AddLine(" ");
				GameTooltip_AddColoredLine(GameTooltip, REQUIRES_AZERITE_LEVEL_TOOLTIP:format(self.unlockLevel), RED_FONT_COLOR);
			end

			if not self:IsSpecAllowed() then
				if not showUnlockReq then
					GameTooltip:AddLine(" ");
				end
				GameTooltip_AddColoredLine(GameTooltip, AzeriteUtil.GenerateRequiredSpecTooltipLine(self:GetAzeritePowerID()), RED_FONT_COLOR);
			end
		end

		GameTooltip:Show();
		self.UpdateTooltip = self.OnEnter;
	end);
end

function AzeriteEmpoweredItemPowerMixin:OnLeave()
	self:CancelItemLoadCallback();

	GameTooltip:Hide();
end

function AzeriteEmpoweredItemPowerMixin:OnClick()
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(GetSpellLink(self:GetSpellID()));
		return;
	end

	if self.azeriteItemDataSource:IsPreviewSource() then
		return;
	end

	local empoweredItemLocation = self.azeriteItemDataSource:GetItemLocation();
	if not C_Item.IsBound(empoweredItemLocation) then
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_BIND", nil, nil, {empoweredItemLocation = empoweredItemLocation, azeritePowerID = self:GetAzeritePowerID()});
		return;
	end

	if C_AzeriteEmpoweredItem.SelectPower(empoweredItemLocation, self:GetAzeritePowerID()) then
		self.owningTierFrame:OnPowerSelected(self);

		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_SELECTBUFF);
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONSTARTCLICKS);
		self:PlaySelectedAnimation();
		self:PlayClickedAnimation();
	end
end

function AzeriteEmpoweredItemPowerMixin:PlaySelectedAnimation()
	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();

	self.SwirlContainer:Show();
	self.SwirlContainer.Anim:Play();
end

function AzeriteEmpoweredItemPowerMixin:PlayClickedAnimation()
	if self.clickEffectActor then
		self.clickEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, function() self.clickEffectActor:SetAnimation(0, 0, 0, 0); end);
	end
end

function AzeriteEmpoweredItemPowerMixin:OnSelectedAnimationFinished()
	self.SwirlContainer:Hide();
end