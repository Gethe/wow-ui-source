AzeriteEmpoweredItemPowerMixin = {};

local CLICK_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(219, 1983548); -- 8FX_AZERITE_GENERIC_NOVAHIGH_BASE;
local SELECTION_READY_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(222, 1983980); -- 8FX_AZERITE_EMPOWER_STATECHEST

function AzeriteEmpoweredItemPowerMixin:Setup(owningTierFrame, azeriteItemDataSource, azeritePowerID, baseAngle)
	self:CancelItemLoadCallback();

	self.owningTierFrame = owningTierFrame;
	self.azeriteItemDataSource = azeriteItemDataSource;
	self.azeritePowerID = azeritePowerID;
	self.baseAngle = baseAngle;

	self:Update();

	self.canBeSelected = nil;
	self.transitionStateInitialized = false;

	if self:IsFinalPower() then
		self.IconOn:SetAtlas("Azerite-CenterTrait-On", true);
		self.IconOff:SetAtlas("Azerite-CenterTrait-Off", true);
		self.IconDesaturated:SetAtlas("Azerite-CenterTrait-On", true);
	else
		local spellTexture = GetSpellTexture(self:GetSpellID());
		self.IconOn:SetTexture(spellTexture);
		self.IconOff:SetTexture(spellTexture);
		self.IconDesaturated:SetTexture(spellTexture);
	end

	self:SetupModelScene();
end

function AzeriteEmpoweredItemPowerMixin:Reset()
	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();
	self.TransitionAnimation:Stop();
	self.SwirlContainer.SelectedAnim:Stop();
	self.SwirlContainer.RevealAnim:Stop();
	self.SwirlContainer:Hide();
	self.needsBuffAvailableSoundPlayed = nil;
	self:SetFrameStrata("MEDIUM");
end

function AzeriteEmpoweredItemPowerMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_EQUIPPED_STATUS_CHANGED");
	self.isHeartOfAzerothEquipped = C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped();
end

function AzeriteEmpoweredItemPowerMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:UnregisterEvent("AZERITE_EMPOWERED_ITEM_EQUIPPED_STATUS_CHANGED");
end

function AzeriteEmpoweredItemPowerMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(forceUpdate);
	elseif event == "AZERITE_EMPOWERED_ITEM_EQUIPPED_STATUS_CHANGED" then
		self.isHeartOfAzerothEquipped = ...;
		self:SetPowerButtonState();
		self:UpdateStyle();
	end
end

function AzeriteEmpoweredItemPowerMixin:OnFinalEffectUpdate(elapsed)
	self.wispyOffsetX = (self.wispyOffsetX or 0) + elapsed * 0.05;
	self.wispyOffsetY = (self.wispyOffsetY or 0) - elapsed * 0.05;
	self.FinalEffectContainer.Wispy:SetTexCoord(0 + self.wispyOffsetX, 1 + self.wispyOffsetX, 0 + self.wispyOffsetY, 5 + self.wispyOffsetY);

	self.sparklesOffsetX = (self.sparklesOffsetX or 0) - elapsed * 0.15;
	self.sparklesOffsetY = (self.sparklesOffsetY or 0) + elapsed * 0.05;

	self.FinalEffectContainer.Sparkles1:SetTexCoord(0 + self.sparklesOffsetX, 1 + self.sparklesOffsetX, 0 + self.sparklesOffsetY, 1 + self.sparklesOffsetY);
	self.FinalEffectContainer.Sparkles2:SetTexCoord(0 - self.sparklesOffsetX, 1 - self.sparklesOffsetX, 0.5 - self.sparklesOffsetY, 1.5 - self.sparklesOffsetY);

	self.goldOffsetX = (self.goldOffsetX or 0) + elapsed * 0.15;
	self.goldOffsetY = (self.goldOffsetY or 0) - elapsed * 0.025;

	self.FinalEffectContainer.Gold:SetTexCoord(0 + self.goldOffsetX, 1 + self.goldOffsetX, 0 + self.goldOffsetY, 1 + self.goldOffsetY);
end

function AzeriteEmpoweredItemPowerMixin:SetupModelScene(forceUpdate)
	self.ClickEffect:Hide();
	local stopAnim = true;
	self.clickEffectActor = StaticModelInfo.SetupModelScene(self.ClickEffect, CLICK_MODEL_SCENE_INFO, forceUpdate, stopAnim);

	self.CanSelectEffect:Hide();
	StaticModelInfo.SetupModelScene(self.CanSelectEffect, SELECTION_READY_MODEL_SCENE_INFO, forceUpdate);
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

function AzeriteEmpoweredItemPowerMixin:SetFinalPowerSparkleEffectAlpha(sparkleAlpha)
	self.FinalEffectContainer.SparkleAnim.Sparkle1In:SetToAlpha(sparkleAlpha);
	self.FinalEffectContainer.SparkleAnim.Sparkle2In:SetToAlpha(sparkleAlpha);

	self.FinalEffectContainer.SparkleAnim.Sparkle1Out:SetFromAlpha(sparkleAlpha);
	self.FinalEffectContainer.SparkleAnim.Sparkle2Out:SetFromAlpha(sparkleAlpha);
end

function AzeriteEmpoweredItemPowerMixin:UpdateFinalPowerEffects()
	if self:IsSelected() or self:IsAnimatingAsSelection() then
		self.FinalEffectContainer:Show();
		self.FinalEffectContainer.Wispy:SetAlpha(.25);
		self.FinalEffectContainer.Gold:Show();

		self:SetFinalPowerSparkleEffectAlpha(.5);
	elseif self:CanBeSelected() then
		self.FinalEffectContainer:Show();
		self.FinalEffectContainer.Wispy:SetAlpha(.15);
		self.FinalEffectContainer.Gold:Hide();

		self:SetFinalPowerSparkleEffectAlpha(.25);
	else
		self.FinalEffectContainer:Hide();
	end
end

function AzeriteEmpoweredItemPowerMixin:UpdateStyle()
	self.CanSelectGlow:SetShown(self:CanBeSelected());
	self.Arrow:SetShown(false); -- Trying without

	self:SetFrameStrata(self:IsFinalPower() and "HIGH" or "MEDIUM");
	self.ClickEffect:SetFrameStrata(self:IsFinalPower() and "DIALOG" or "HIGH");

	if self:IsFinalPower() then
		self:SetSize(120, 120);
		self.IconOn:SetSize(118, 118);
		self.IconOff:SetSize(118, 118);
		self.IconDesaturated:SetSize(118, 118);
		self.CircleMask:SetSize(115, 115);
		self.IconBorder:SetAtlas("Azerite-CenterTrait-RingDisable", true);
		self.IconBorderSelectable:SetAtlas("Azerite-CenterTrait-Ring", true);
		self.CanSelectGlow:SetScale(1.35);
		self.SwirlContainer:SetScale(1.35);
		self.PlugBg:Show();
		self.FinalEffectContainer:Show();
		self.FinalEffectContainer.SparkleAnim:Play();
		self.FinalEffectContainer.GoldOverlayAnim:Play();

		self:UpdateFinalPowerEffects();
	else
		self:SetSize(80, 80);
		self.IconOn:SetSize(100, 100);
		self.IconOff:SetSize(100, 100);
		self.IconDesaturated:SetSize(100, 100);
		self.CircleMask:SetSize(100, 100);
		self.IconBorder:SetAtlas("Azerite-Trait-Ring", true);
		self.IconBorderSelectable:SetAtlas("Azerite-Trait-Ring-Open", true);
		self.CanSelectGlow:SetScale(1.0);
		self.SwirlContainer:SetScale(1.1);
		self.PlugBg:Hide();
		self.FinalEffectContainer:Hide();
		self.FinalEffectContainer.SparkleAnim:Stop();
		self.FinalEffectContainer.GoldOverlayAnim:Stop();
	end

	self.IconBorder:SetShown(not self:IsSelected() or self:IsAnimatingAsSelection());
	if self.azeriteItemDataSource:IsPreviewSource() or self:CanBeSelected() or self:IsSelected() or self:IsAnimatingAsSelection() then
		self.IconOn:SetVertexColor(1, 1, 1);
		self.IconDesaturated:SetVertexColor(1, 1, 1);
	else
		if self:IsFinalPower() then
			self.IconOff:SetVertexColor(1, 1, 1);
		else
			self.IconOff:SetVertexColor(.85, .85, .85);
		end
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
	if self.SwirlContainer:IsShown() then
		assert(not self.TransitionAnimation:IsPlaying());
		return;
	end

	if not self.transitionStateInitialized then
		self.transitionStateInitialized = true;
		assert(not self.TransitionAnimation:IsPlaying());

		self.CanSelectEffect:SetAlpha(0);
		self.IconOn:SetAlpha(self:GetIconOnAlphaValue());
		self.IconOff:SetAlpha(self:GetIconOffAlphaValue());
		self.IconDesaturated:SetAlpha(self:GetDesaturationValue());
		self.IconBorderSelectable:SetAlpha(self:GetBorderSelectableAlphaValue());
		self.IconBorder:SetAlpha(self:GetBorderAlphaValue());
		self.IconNotSelectableOverlay:SetAlpha(self:GetIconNotSelectableOverlayAlphaValue());
	end

	self.CanSelectEffect:Show();

	self.TransitionAnimation.IconOn:SetFromAlpha(self.IconOn:GetAlpha());
	self.TransitionAnimation.IconOn:SetToAlpha(self:GetIconOnAlphaValue());

	self.TransitionAnimation.IconOff:SetFromAlpha(self.IconOff:GetAlpha());
	self.TransitionAnimation.IconOff:SetToAlpha(self:GetIconOffAlphaValue());

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

function AzeriteEmpoweredItemPowerMixin:GetIconOnAlphaValue()
	if self:IsAnyTierRevealing() then
		return 1;
	end

	if self:IsAnimatingAsSelection() then
		if self:IsFinalPower() then
			return 0;
		end
		return 1;
	end

	if self:IsSelected() then
		return 1;
	end

	return 0;
end

function AzeriteEmpoweredItemPowerMixin:GetIconOffAlphaValue()
	return 1.0 - self:GetIconOnAlphaValue();
end

function AzeriteEmpoweredItemPowerMixin:GetCanSelectEffectAlphaValue()
	if self:IsAnimatingAsSelection() then
		return 1;
	end

	if self:IsAnyTierRevealing() then
		return 0;
	end

	if self:CanBeSelected() then
		return 1;
	end

	return 0;
end

function AzeriteEmpoweredItemPowerMixin:GetBorderSelectableAlphaValue()
	if self.azeriteItemDataSource:IsPreviewSource() then
		return 0;
	end

	if self:IsAnyTierRevealing() then
		if self:IsFinalPower() then
			return 0;
		end
		return 1;
	end

	if self:IsSelected() then
		if self:IsFinalPower() then
			return 0;
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
	if self:IsSelected() then
		if self:IsFinalPower() then
			return 0;
		end
	end
	return 1.0 - self:GetBorderSelectableAlphaValue();
end

function AzeriteEmpoweredItemPowerMixin:GetIconNotSelectableOverlayAlphaValue()
	if not self.isHeartOfAzerothEquipped then
		return 1;
	end

	if self.azeriteItemDataSource:IsPreviewSource() then
		return 0;
	end

	if self:IsAnyTierRevealing() then
		return 0;
	end

	if self:IsAnimatingAsSelection() or self:IsSelected() or self:CanBeSelected() then
		return 0;
	end

	return 1;
end

function AzeriteEmpoweredItemPowerMixin:GetDesaturationValue()
	if self:IsAnyTierRevealing() then
		return 0;
	end

	if self:IsSelected() then
		return 0;
	end

	if self.azeriteItemDataSource:IsPreviewSource() then
		return .25;
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

function AzeriteEmpoweredItemPowerMixin:IsAnyTierRevealing()
	return self.owningTierFrame:IsAnyTierRevealing();
end

function AzeriteEmpoweredItemPowerMixin:IsTierRevealing()
	return self.owningTierFrame:IsRevealing();
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
	return self:IsTierSelectionActive() and self:MeetsPowerLevelRequirement() and self:IsSpecAllowed() and not self.azeriteItemDataSource:IsPreviewSource() and self.isHeartOfAzerothEquipped;
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

function AzeriteEmpoweredItemPowerMixin:SetPowerButtonState()
	self.IconNotSelectableOverlay:SetAlpha(self:GetIconNotSelectableOverlayAlphaValue());
end

function AzeriteEmpoweredItemPowerMixin:SetFinalPowerTooltipDescriptions(tooltip)
	local empoweredItemLocation = self.azeriteItemDataSource:GetItemLocation();

	local finalPowers = nil;
	if(self.owningTierFrame:IsFinalTier()) then
		finalPowers = self.owningTierFrame:GetOwner():GetPowerIdsForFinalSelectedTier();
	end

	if(not finalPowers) then
		return;
	end

	local WRAP = true;
	local type = nil;
	local finalPowerSelected = false;
	local base = Enum.AzeritePowerLevel.Base;

	if(self:IsSelected()) then
		type = Enum.AzeritePowerLevel.Downgraded;
		finalPowerSelected = true;
	else
		type = Enum.AzeritePowerLevel.Upgraded;
	end
	tooltip:AddLine(" ");
	for powerIndex, powerID in ipairs(finalPowers) do
		local powerInfoModified = C_AzeriteEmpoweredItem.GetPowerText(empoweredItemLocation, powerID, type);
		GameTooltip_AddColoredLine(tooltip,DASH_WITH_TEXT:format(powerInfoModified.name), HIGHLIGHT_FONT_COLOR, WRAP);
		local powerInfoBase = C_AzeriteEmpoweredItem.GetPowerText(empoweredItemLocation, powerID, base);

		if(finalPowerSelected) then
			GameTooltip_AddNormalLine(tooltip, GetHighlightedNumberDifferenceString(powerInfoModified.description, powerInfoBase.description), WRAP, TOOLTIP_INDENT_OFFSET);
		else
			GameTooltip_AddNormalLine(tooltip, GetHighlightedNumberDifferenceString(powerInfoBase.description, powerInfoModified.description), WRAP, TOOLTIP_INDENT_OFFSET);
		end
	end
end

function AzeriteEmpoweredItemPowerMixin:SetCanBeSelectedDetails(isTierSelectionActive, meetsPowerLevelRequirement, unlockLevel, isSpecAllowed, tierHasAnyPowersSelected)
	local wasSelectable = self:CanBeSelected();

	self.isTierSelectionActive = isTierSelectionActive;
	self.meetsPowerLevelRequirement = meetsPowerLevelRequirement;
	self.unlockLevel = unlockLevel;
	self.isSpecAllowed = isSpecAllowed;
	self.tierHasAnyPowersSelected = tierHasAnyPowersSelected;

	if not wasSelectable and wasSelectable ~= self:CanBeSelected() and not self:IsAnyTierRevealing() and not self.azeriteItemDataSource:IsPreviewSource() then
		if self.SwirlContainer:IsShown() then
			self.needsBuffAvailableSoundPlayed = true;
		else
			self.needsBuffAvailableSoundPlayed = nil;
			PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_BUFFAVAILABLE);
		end
	end

	self:UpdateStyle();
end

function AzeriteEmpoweredItemPowerMixin:OnTransitionAnimationFinished()
	if self.needsBuffAvailableSoundPlayed then
		self.needsBuffAvailableSoundPlayed = nil;
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_BUFFAVAILABLE);
	end
	self.CanSelectEffect:SetShown(self.CanSelectEffect:GetAlpha() ~= 0);
end

function AzeriteEmpoweredItemPowerMixin:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteEmpoweredItemPowerMixin:OnEnter()
	self:CancelItemLoadCallback();
	if self.SwirlContainer:IsShown() then
		return;
	end

	local item = self.azeriteItemDataSource:GetItem();

	self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local itemID = item:GetItemID();
		local itemLevel = item:GetCurrentItemLevel();
		local itemLink = item:GetItemLink();
		GameTooltip:SetAzeritePower(itemID, itemLevel, self:GetAzeritePowerID(), itemLink);

		self:SetFinalPowerTooltipDescriptions(GameTooltip);

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
				local specTooltipLine = AzeriteUtil.GenerateRequiredSpecTooltipLine(self:GetAzeritePowerID());
				if specTooltipLine then
					if not showUnlockReq then
						GameTooltip:AddLine(" ");
					end
					GameTooltip_AddColoredLine(GameTooltip, specTooltipLine, RED_FONT_COLOR);
				end
			end
		end

		if(not self.isHeartOfAzerothEquipped) then
			GameTooltip:AddLine(" ");
			GameTooltip_AddColoredLine(GameTooltip, HEART_OF_AZEROTH_MISSING_ERROR, RED_FONT_COLOR);
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
		local spellLink = GetSpellLink(self:GetSpellID());
		ChatEdit_InsertLink(spellLink);
		return;
	end

	if self.azeriteItemDataSource:IsPreviewSource() then
		UIErrorsFrame:AddExternalErrorMessage(AZERITE_POWER_UNSELECTABLE_IN_PREVIEW);
		return;
	end

	if not self.owningTierFrame:CanSelectPowers() then
		return;
	end

	if not self:IsTierSelectionActive() then
		return;
	end

	if not self:IsSpecAllowed() then
		UIErrorsFrame:AddExternalErrorMessage(AZERITE_POWER_NOT_FOR_YOUR_SPEC);
		return;
	end

	if UnitIsDeadOrGhost("player") then
		UIErrorsFrame:AddExternalErrorMessage(ERR_PLAYER_DEAD);
		return;
	end

	if UnitAffectingCombat("player") then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_IN_COMBAT);
		return;
	end

	if not self.isHeartOfAzerothEquipped then
		return;
	end

	assert(self:CanBeSelected());

	local empoweredItemLocation = self.azeriteItemDataSource:GetItemLocation();
	local function SelectPower()
		if C_AzeriteEmpoweredItem.SelectPower(empoweredItemLocation, self:GetAzeritePowerID()) then
			self.owningTierFrame:OnPowerSelected(self);

			PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_SELECTBUFF);
			if not self:IsFinalPower() then
				PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONSTARTCLICKS);
			end
			self:PlaySelectedAnimation();
			self:PlayClickedAnimation();
		end
	end

	if not C_Item.IsBound(empoweredItemLocation) then
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_BIND", nil, nil, {SelectPower = SelectPower});
		return;
	end

	if self:IsFinalPower() then
		SelectPower();
	else
		StaticPopup_Show("CONFIRM_AZERITE_EMPOWERED_SELECT_POWER", nil, nil, {SelectPower = SelectPower});
	end
end

function AzeriteEmpoweredItemPowerMixin:PlaySelectedAnimation()
	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();

	self:ResetSwirlAlpha();

	self.SwirlContainer:Show();
	self.SwirlContainer.SelectedAnim:Play();
end

function AzeriteEmpoweredItemPowerMixin:PlayClickedAnimation()
	if self.clickEffectActor then
		self.ClickEffect:Show();
		self.clickEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(.2, 
			function()
				self.clickEffectActor:SetAnimation(0, 0, 0, 0);
				C_Timer.After(5, 
					function()
						self.ClickEffect:Hide();
					end
				);
			end
		);
	end
end

function AzeriteEmpoweredItemPowerMixin:OnSwirlAnimationFinished()
	self.SwirlContainer:Hide();
	self:PlayTransitionAnimation();

	if GetMouseFocus() == self then
		self:OnEnter();
	end
end

do
	local function ResetAlpha(region, ...)
		region:SetAlpha(0);
		if ... then
			return ResetAlpha(...);
		end
	end

	function AzeriteEmpoweredItemPowerMixin:ResetSwirlAlpha()
		ResetAlpha(self.SwirlContainer:GetRegions());
	end
end

function AzeriteEmpoweredItemPowerMixin:PrepareForRevealAnimation()
	self.transitionStateInitialized = true;

	self.CanSelectGlowAnim:Stop();
	self.CanSelectArrowAnim:Stop();
	self.TransitionAnimation:Stop();

	local NUM_RUNE_TYPES = 11;
	local runeIndex = math.random(1, NUM_RUNE_TYPES);

	self.SwirlContainer.LightRune:SetAtlas(("Rune-%02d-light"):format(runeIndex), true);
	if self:IsFinalPower() then
		self.SwirlContainer.LightRune:SetScale(1.25);
	else
		self.SwirlContainer.LightRune:SetScale(1.50);
	end

	self:ResetSwirlAlpha();

	self.IconBorder:SetAlpha(self:IsFinalPower() and 1 or 0);
	self.IconOn:SetAlpha(0);
	self.IconOff:SetAlpha(0);
	self.IconDesaturated:SetAlpha(0);
	self.IconNotSelectableOverlay:SetAlpha(0);
	self.IconBorderSelectable:SetAlpha(0);
	self.CanSelectEffect:SetAlpha(0);

	self.SwirlContainer:Show();
end

function AzeriteEmpoweredItemPowerMixin:PlayRevealAnimation(timeDelay)
	assert(not self.CanSelectGlowAnim:IsPlaying());
	assert(not self.CanSelectArrowAnim:IsPlaying());
	assert(not self.TransitionAnimation:IsPlaying());

	self:ResetSwirlAlpha();

	self.SwirlContainer.RevealAnim.Start:SetEndDelay(timeDelay or 0.0);
	self.SwirlContainer.RevealAnim:Play();
end