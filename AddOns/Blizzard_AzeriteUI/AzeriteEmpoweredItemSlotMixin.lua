local POWER_LOCKED_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(221, 2101307); -- 8FX_AZERITE_ABSORBCURRENCY_LARGE_IMPACTBASE
local FINAL_POWER_LOCKED_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(223, 2101307); -- 8FX_AZERITE_ABSORBCURRENCY_LARGE_IMPACTBASE

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
		self.LockedInEffect:Show();
		self.lockedInEffectActor:SetAnimation(0, 0, 1, 0);
		C_Timer.After(1, 
			function() 
				self.lockedInEffectActor:SetAnimation(0, 0, 0, 0); 
				C_Timer.After(5, 
					function() self.LockedInEffect:Hide(); 
					end
				);
			end
		);
	end
end

function AzeriteEmpoweredItemSlotMixin:SetupModelScene(forceUpdate)
	local modelSceneInfo = self.isFinalTier and FINAL_POWER_LOCKED_MODEL_SCENE_INFO or POWER_LOCKED_MODEL_SCENE_INFO;
	if forceUpdate or self.modelSceneInfo ~= modelSceneInfo then
		self.modelSceneInfo = modelSceneInfo;
		local stopAnim = true;
		self.lockedInEffectActor = StaticModelInfo.SetupModelScene(self.LockedInEffect, modelSceneInfo, forceUpdate, stopAnim);
		self.LockedInEffect:Hide();
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