AzeriteEmpoweredItemPowerMixin = {};

function AzeriteEmpoweredItemPowerMixin:Setup(owningTierFrame, azeriteItemDataSource, azeritePowerID, baseAngle)
	self:CancelItemLoadCallback();

	self.owningTierFrame = owningTierFrame;
	self.azeriteItemDataSource = azeriteItemDataSource;
	self.azeritePowerID = azeritePowerID;
	self.baseAngle = baseAngle;

	self:Update();

	self.canBeSelected = nil;

	local spellTexture = GetSpellTexture(self:GetSpellID()); 
	self.Icon:SetTexture(spellTexture);

	self:SetupModelScene();
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
	self.CanSelectGlow:SetShown(self:CanBeSelected() and not self:IsFinalPower());
	self.CanSelectEffect:SetShown(self:CanBeSelected());
	self.Arrow:SetShown(self:CanBeSelected());

	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();
	self.CanSelectEffectAnim:Stop();
	self.CanSelectEffect:SetAlpha(0);

	self:SetFrameStrata(self:IsFinalPower() and "HIGH" or "MEDIUM");
	self.ClickEffect:SetFrameStrata(self:IsFinalPower() and "DIALOG" or "HIGH")

	if self:IsFinalPower() then
		self:SetSize(120, 120);
		self.Icon:SetSize(130, 130);
		self.IconNotSelectableOverlay:SetSize(130, 130);
		self.CircleMask:SetSize(120, 120);
	else
		self:SetSize(80, 80);
		self.Icon:SetSize(100, 100);
		self.IconNotSelectableOverlay:SetSize(100, 100);
		self.CircleMask:SetSize(100, 100);
	end

	self.IconBorder:Show();
	self.Icon:SetVertexColor(1, 1, 1);
	self.IconNotSelectableOverlay:Hide();

	if self.azeriteItemDataSource:IsPreviewSource() then
		self.Icon:SetDesaturation(self:GetDesaturationValue());
		self.IconNotSelectableOverlay:SetShown(not self:IsSpecAllowed());

		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-Trait-Ring", true);
		end
	elseif self:IsSelected() and not self:IsAnimatingAsSelection() then
		self.Icon:SetDesaturation(0);
		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:Hide();
		end
	elseif self:CanBeSelected() or self:IsAnimatingAsSelection() then
		self.Icon:SetDesaturation(0);
		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-Trait-Ring-Open", true);
		end
	else
		self.Icon:SetDesaturation(self:GetDesaturationValue());
		self.Icon:SetVertexColor(.85, .85, .85);
		self.IconNotSelectableOverlay:Show();

		if self:IsFinalPower() then
			self.IconBorder:SetAtlas("Azerite-CenterTrait-Ring", true);
		else
			self.IconBorder:SetAtlas("Azerite-Trait-Ring", true);
		end
	end

	if self:CanBeSelected() then
		self.CanSelectGlowAnim:Play();
		self.CanSelectArrowAnim:Play();
		self.CanSelectEffectAnim:Play();
	end
end

function AzeriteEmpoweredItemPowerMixin:GetDesaturationValue()
	if not self:IsSpecAllowed() then
		return 1;
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
		self:PlaySelectedAnimation();
	end
end

function AzeriteEmpoweredItemPowerMixin:PlaySelectedAnimation()
	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();
	self.CanSelectEffectAnim:Stop();

	if self.clickEffectActor then
		self.clickEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, function() self.clickEffectActor:SetAnimation(0, 0, 0, 0); end);
	end
	
	self.BigWhirls:Show();
	self.SpinningGlows:Show();
	self.SpinningGlows2:Show();
	self.StarBurst:Show();
	self.RingBurst:Show();
	self.SelectedAnim:Play();
end

function AzeriteEmpoweredItemPowerMixin:OnSelectedAnimationFinished()
	self.BigWhirls:Hide();
	self.SpinningGlows:Hide();
	self.SpinningGlows2:Hide();
	self.StarBurst:Hide();
	self.RingBurst:Hide();
end