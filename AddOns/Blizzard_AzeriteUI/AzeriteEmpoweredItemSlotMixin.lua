AzeriteEmpoweredItemSlotMixin = {};

function AzeriteEmpoweredItemSlotMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteEmpoweredItemSlotMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self.modelSceneType = nil;
end

function AzeriteEmpoweredItemSlotMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(forceUpdate);
	end
end

function AzeriteEmpoweredItemSlotMixin:Enable()
	if not self.enabled then
		self.enabled = true;
		self:RefreshTooltip();
	end
end

function AzeriteEmpoweredItemSlotMixin:RefreshTooltip()
	if GetMouseFocus() == self then
		self:OnEnter();
	end
end

function AzeriteEmpoweredItemSlotMixin:Disable()
	if self.enabled then
		self.enabled = false;
		if GameTooltip:GetOwner() == self then
			self:OnLeave();
		end
	end
end

function AzeriteEmpoweredItemSlotMixin:SetPowerLevelInfo(azeritePowerLevel, unlockLevel, hasSelectedPower, isSelectionActive, isPreviewSource, isFinalTier)
	self.azeritePowerLevel = azeritePowerLevel;
	self.unlockLevel = unlockLevel;
	self.isPreviewSource = isPreviewSource;
	self.isFinalTier = isFinalTier;

	self:EnableMouse(not isFinalTier and not hasSelectedPower); -- No tooltips if we have a selected power or are the final power

	self:SetupModelScene();
	self:RefreshTooltip();
end

function AzeriteEmpoweredItemSlotMixin:PlayLockedInEffect()
	if self.lockedInEffectActor then
		self.lockedInEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(1, function() self.lockedInEffectActor:SetAnimation(0, 0, 0, 0); end);
	end
end

function AzeriteEmpoweredItemSlotMixin:SetupModelScene(forceUpdate)
	local modelSceneType = self.isFinalTier and AzeriteModelInfo.ModelSceneTypeFinalPowerLockedIn or AzeriteModelInfo.ModelSceneTypePowerLockedIn;
	if forceUpdate or self.modelSceneType ~= modelSceneType then
		self.modelSceneType = modelSceneType;

		self.lockedInEffectActor = AzeriteModelInfo.SetupModelScene(self.LockedInEffect, modelSceneType, forceUpdate);
		if self.lockedInEffectActor then
			self.lockedInEffectActor:SetAnimation(0, 0, 0, 0);
		end
	end
end

function AzeriteEmpoweredItemSlotMixin:OnEnter()
	if not self.enabled then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.azeritePowerLevel >= self.unlockLevel then
		if self.isPreviewSource then
			GameTooltip:SetText(REQUIRES_AZERITE_LEVEL_TOOLTIP:format(self.unlockLevel), NORMAL_FONT_COLOR:GetRGB());
		else
			GameTooltip:SetText(SELECT_AZERITE_POWER_TOOLTIP, NORMAL_FONT_COLOR:GetRGB());
		end
	else
		GameTooltip:SetText(REQUIRES_AZERITE_LEVEL_TOOLTIP:format(self.unlockLevel), RED_FONT_COLOR:GetRGB());
	end
end

function AzeriteEmpoweredItemSlotMixin:OnLeave()
	GameTooltip:Hide();
end