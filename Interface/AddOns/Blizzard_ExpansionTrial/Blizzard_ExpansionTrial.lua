ExpansionTrialCheckPointDialogMixin = Mixin({
	ReachedLevelLimit = 1,
	FinishedCampaign = 2,
	GainedBankedLevel = 3,
	TrialUpgrade = 4,
	}, BaseExpandableDialogMixin
);

local textureKitRegionInfo = {
	["Top"] = {formatString= "%s-expansionTrialPopup-top", useAtlasSize=true},
	["Middle"] = {formatString="%s-expansionTrialPopup-middle", useAtlasSize = false},
	["Bottom"] = {formatString="%s-expansionTrialPopup-bottom", useAtlasSize = true},
	["CloseButtonBG"] = {formatString="%s-expansionTrialPopup-exit-frame", useAtlasSize = true}
}

function ExpansionTrialCheckPointDialogMixin:OnLoad()
	self:MarkIgnoreInLayout(self.Top, self.Bottom, self.Middle, self.CloseButtonBG, self.CloseButton);

	local expansionTrialBoostType = 0;
	local upgradeDisplayData = C_CharacterServices.GetCharacterServiceDisplayData(expansionTrialBoostType);
	self:SetupTextureKit(upgradeDisplayData.popupInfo.textureKit, textureKitRegionInfo);

	local currentExpansionLevel = GetClampedCurrentExpansionLevel();
	local expansionDisplayInfo = GetExpansionDisplayInfo(currentExpansionLevel);
	if expansionDisplayInfo then
		self.ExpansionImage:SetTexture(expansionDisplayInfo.logo);
	end

	EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function()
		self:CheckProcessQueuedDialogs();
	end);

	self:SetupCheckpoints();
end

local dialogData =
{
	[ExpansionTrialCheckPointDialogMixin.ReachedLevelLimit] = function(self)
		self.ExpansionImage:Show();
		self.Title:Show();
		self.GainedLevelContainer:Hide();
		self.Title:SetText(EXPANSION_TRIAL_THANKS_TITLE);
		self.Description:SetText(EXPANSION_TRIAL_THANKS_TEXT);
		self.Button:SetText(EXPANSION_TRIAL_THANKS_BUTTON);
	end,

	[ExpansionTrialCheckPointDialogMixin.FinishedCampaign] = function(self)
		self.ExpansionImage:Show();
		self.Title:Show();
		self.GainedLevelContainer:Hide();
		self.Title:SetText(EXPANSION_TRIAL_THANKS_TITLE);
		self.Description:SetText(EXPANSION_TRIAL_THANKS_TEXT_FINISHED_CAMPAIGN);
		self.Button:SetText(EXPANSION_TRIAL_THANKS_BUTTON);
	end,

	[ExpansionTrialCheckPointDialogMixin.GainedBankedLevel] = function(self)
		self.ExpansionImage:Hide();
		self.Title:Hide();
		self.GainedLevelContainer:Show();
		self.GainedLevelContainer.Text:SetText(EXPANSION_TRIAL_GAINED_LEVEL_TEXT:format(self:GetCurrentPlayerLevel()));
		self.GainedLevelContainer:Layout();
		self.Description:SetText(EXPANSION_TRIAL_THANKS_TEXT_GAINED_BANKED_LEVEL);
		self.Button:SetText(EXPANSION_TRIAL_THANKS_BUTTON);
	end,

	[ExpansionTrialCheckPointDialogMixin.TrialUpgrade] = function(self)
		self.ExpansionImage:Show();
		self.Title:Show();
		self.GainedLevelContainer:Hide();
		self.Title:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_TITLE);
		self.Description:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_TEXT);
		self.Button:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_BUTTON);
	end,
};

function ExpansionTrialCheckPointDialogMixin:ShowDialogType(dialogType, force)
	if not force and UnitAffectingCombat("player") then
		self.queuedDialog = dialogType;
	else
		self.dialogType = dialogType;
		dialogData[dialogType](self);
		self:MarkDirty();
		self:Show();
	end
end

function ExpansionTrialCheckPointDialogMixin:CheckProcessQueuedDialogs()
	if self.queuedDialog and not UnitAffectingCombat("player") then
		self:ShowDialogType(self.queuedDialog, true);
		self.queuedDialog = nil;
	end
end

function ExpansionTrialCheckPointDialogMixin:IsShowingExpansionTrialUpgrade()
	return self:IsVisible() and self.dialogType == self.TrialUpgrade;
end

function ExpansionTrialCheckPointDialogMixin:OnShow()
	SetStoreUIShown(false);
end

function ExpansionTrialCheckPointDialogMixin:OnButtonClick()
	if self:IsShowingExpansionTrialUpgrade() then
		ForceLogout();
	else
		-- TODO: Replace with MirrorVar
		local useNewCashShop = GetCVarBool("useNewCashShop");
		if useNewCashShop then
			local shown = true;
			CatalogShopInboundInterface.SetShown(shown)
			CatalogShopInboundInterface.SetGamesCategory();
		else
			SetStoreUIShown(true);
			StoreFrame_SetGamesCategory();
		end
		C_ExpansionTrial.OnTrialLevelUpDialogClicked();
	end

	BaseExpandableDialogMixin.OnCloseClick(self);
end

function ExpansionTrialCheckPointDialogMixin:OnCloseClick()
	if self:IsShowingExpansionTrialUpgrade() then
		ForceLogout();
	end

	BaseExpandableDialogMixin.OnCloseClick(self);
end

function ExpansionTrialCheckPointDialogMixin:GetCurrentPlayerLevel()
	return UnitLevel("player") + UnitTrialBankedLevels("player");
end

function ExpansionTrialCheckPointDialogMixin:UpdateBasePlayerLevel()
	self.baseLevel = self:GetCurrentPlayerLevel();
end

function ExpansionTrialCheckPointDialogMixin:GetBasePlayerLevel()
	return self.baseLevel;
end

function ExpansionTrialCheckPointDialogMixin:GetGainedLevels()
	return self:GetCurrentPlayerLevel() - self:GetBasePlayerLevel();
end

function ExpansionTrialCheckPointDialogMixin:HasHitLevelLimit(level)
	return level >= GameLimitedMode_GetLevelLimit();
end

function ExpansionTrialCheckPointDialogMixin:SetupCheckpoints()
	local isExpansionTrial = GetExpansionTrialInfo();
	local isClassTrial = C_ClassTrial.IsClassTrialCharacter();
	if isExpansionTrial and not isClassTrial then
		self:UpdateBasePlayerLevel();

		EventRegistry:RegisterFrameEventAndCallback("PLAYER_LEVEL_CHANGED", function(f, oldLevel, newLevel, hasRealLevelChanged)
			if hasRealLevelChanged and newLevel == GameLimitedMode_GetLevelLimit() then
				self:ShowDialogType(self.ReachedLevelLimit);
				C_ExpansionTrial.OnTrialLevelUpDialogShown();
			end
		end);

		EventRegistry:RegisterFrameEventAndCallback("PLAYER_TRIAL_XP_UPDATE", function(f, unitTag)
			if self:GetGainedLevels() > 0 then
				C_Timer.After(2, function()
					self:ShowDialogType(self.GainedBankedLevel);
					self:UpdateBasePlayerLevel();
					C_ExpansionTrial.OnTrialLevelUpDialogShown();
				end);
			end
		end);

		EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
			if self:HasHitLevelLimit(UnitLevel("player")) then
				self:ShowDialogType(self.ReachedLevelLimit);
				C_ExpansionTrial.OnTrialLevelUpDialogShown();
			end
		end);

		EventRegistry:RegisterFrameEventAndCallback("QUEST_TURNED_IN", function(f, questID)
			if questID == 65794 then
				self:ShowDialogType(self.FinishedCampaign);
			end
		end);

		EventRegistry:RegisterFrameEventAndCallback("UPDATE_EXPANSION_LEVEL", function(f, currentExpansionLevel, currentAccountExpansionLevel, previousExpansionLevel, previousAccountExpansionLevel, upgradingFromExpansionTrial)
			if upgradingFromExpansionTrial then
				self:ShowDialogType(self.TrialUpgrade);
			end
		end);
	end
end
