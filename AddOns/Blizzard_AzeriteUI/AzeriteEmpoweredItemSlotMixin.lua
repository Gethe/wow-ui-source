AzeriteEmpoweredItemSlotMixin = {};

function AzeriteEmpoweredItemSlotMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:SetupModelScene();
end

function AzeriteEmpoweredItemSlotMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteEmpoweredItemSlotMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:SetupModelScene(forceUpdate);
	end
end

function AzeriteEmpoweredItemSlotMixin:SetPowerLevelInfo(azeritePowerLevel, unlockLevel, hasSelectedPower, isSelectionActive, isPreviewSource)
	self.azeritePowerLevel = azeritePowerLevel;
	self.unlockLevel = unlockLevel;
	self.isPreviewSource = isPreviewSource;

	self.LidEffect:SetShown(isSelectionActive);
	self.LidEffect:SetAlpha(1);

	self:EnableMouse(not hasSelectedPower); -- No tooltips if we have a selected power
end

function AzeriteEmpoweredItemSlotMixin:PlayLockedInEffect()
	if self.lockedInEffectActor then
		self.lockedInEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(1, function() self.lockedInEffectActor:SetAnimation(0, 0, 0, 0); end);
	end
end

function AzeriteEmpoweredItemSlotMixin:SetupModelScene(forceUpdate)
	AzeriteModelInfo.SetupModelScene(self.LidEffect, AzeriteModelInfo.ModelSceneTypeLidUnlock, forceUpdate);
	self.lockedInEffectActor = AzeriteModelInfo.SetupModelScene(self.LockedInEffect, AzeriteModelInfo.ModelSceneTypePowerLockedIn, forceUpdate);
	if self.lockedInEffectActor then
		self.lockedInEffectActor:SetAnimation(0, 0, 0, 0);
	end
end

function AzeriteEmpoweredItemSlotMixin:OnEnter()
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