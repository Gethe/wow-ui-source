
local function ClassTrialChooseBoostType_OnClick(self, boostType)
		-- Hide early to avoid having the dialogs try to stack.
		self:Hide();
		if boostType == C_CharacterServices.GetActiveClassTrialBoostType() then
			ClassTrialDialogMixin:StartCharacterUpgrade(boostType);
		else
			StaticPopup_Show("CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT", nil, nil, boostType);
		end
end

StaticPopupDialogs["CLASS_TRIAL_CHOOSE_BOOST_TYPE"] = {
	text = CLASS_TRIAL_CHOOSE_BOOST_TYPE_TEXT,
	button1 = ACCEPT,
	button2 = ACCEPT,
	button3 = CANCEL,
	selectCallbackByIndex = true,
	OnShow = function(self)
		if #self.data >= 2 then
			local info1 = C_CharacterServices.GetCharacterServiceDisplayData(self.data[1]);
			self.button1:SetText(info1.flowTitle);
			local info2 = C_CharacterServices.GetCharacterServiceDisplayData(self.data[2]);
			self.button2:SetText(info2.flowTitle);

			local maxWidth = math.max(self.button1:GetTextWidth(), self.button2:GetTextWidth());
			local buttonWidth = maxWidth + 60;
			self.button1:SetWidth(buttonWidth);
			self.button2:SetWidth(buttonWidth);
		else
			self:Hide();
		end
	end,
	OnButton1 = function(self, data)
		ClassTrialChooseBoostType_OnClick(self, data[1]);
	end,
	OnButton2 = function(self, data)
		ClassTrialChooseBoostType_OnClick(self, data[2]);
	end,
	OnButton3 = function ()
		ClassTrialThanksForPlayingDialog:ShowThanks();
	end,

	timeout = 0,
	whileDead = 1,
	verticalButtonLayout = true,
	fullScreenCover = true,
};

StaticPopupDialogs["CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT"] = {
	text = CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT_TEXT,
	button1 = CAMP_NOW,
	button2 = CANCEL,

	OnAccept = function(self, boostType)
		C_CharacterServices.SetAutomaticBoost(boostType);
		C_CharacterServices.SetAutomaticBoostCharacter(UnitGUID("player"));
		Logout();
	end,
	OnCancel = function()
		ClassTrialThanksForPlayingDialog:ShowThanks();
	end,

	timeout = 0,
	whileDead = 1,
	fullScreenCover = true,
};

local classFilenameToAtlas = {
	["WARRIOR"] = "ClassTrial-Warrior-Ring",
	["PALADIN"] = "ClassTrial-Paladin-Ring",
	["HUNTER"] = "ClassTrial-Hunter-Ring",
	["ROGUE"] = "ClassTrial-Rogue-Ring",
	["PRIEST"] = "ClassTrial-Priest-Ring",
	["DEATHKNIGHT"] = "ClassTrial-DeathKnight-Ring",
	["SHAMAN"] = "ClassTrial-Shaman-Ring",
	["MAGE"] = "ClassTrial-Mage-Ring",
	["WARLOCK"] = "ClassTrial-Warlock-Ring",
	["MONK"] = "ClassTrial-Monk-Ring",
	["DRUID"] = "ClassTrial-Druid-Ring",
	["DEMONHUNTER"] = "ClassTrial-DemonHunter-Ring",
};

function ClassTrial_SetHasAvailableBoost(hasBoost)
	ClassTrialThanksForPlayingDialog:UpdateDialogButtons(hasBoost);
end

function ClassTrial_ConfirmApplyToken(guid, boostType)
	ClassTrialSecureFrame:SetAttribute("upgradecharacter-confirm", { guid = guid, boostType = boostType });
end

function ClassTrial_ShowStoreServices(guid, boostType)
	if not StoreFrame_IsShown or not StoreFrame_IsShown() then
		ToggleStoreUI();
	end

	StoreFrame_SelectBoost(boostType, "forClassTrialUnlock", guid);
end

ClassTrialDialogMixin = {}

function ClassTrialDialogMixin:ShowThanks(soundKit)
	local className, classFilename = UnitClass("player");
	self.ClassNameText:SetText(className);
	self.ClassIcon:SetAtlas(classFilenameToAtlas[classFilename])
	self.soundKit = soundKit;

	local dialogText = CLASS_TRIAL_THANKS_DIALOG_TEXT:format(UnitName("player"));
	self.DialogText:SetText(dialogText);

	self:Show();
end

function ClassTrialDialogMixin:StartCharacterUpgrade(boostType)
	ClassTrialSecureFrame:SetAttribute("upgradecharacter", { guid = UnitGUID("player"), boostType = boostType });
end

function ClassTrialDialogMixin:HandleButtonClickCommon()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ClassTrialTimerDisplay:ShowTimer();
end

function ClassTrialDialogMixin:BuyCharacterBoost()
	self:HandleButtonClickCommon();
	local classTrialBoostType = C_CharacterServices.GetActiveClassTrialBoostType();
	local activeBoostType = C_CharacterServices.GetActiveCharacterUpgradeBoostType();
	if classTrialBoostType ~= activeBoostType then
		local upgradeDistributions = C_SharedCharacterServices.GetUpgradeDistributions();
		local classTrialBoostDistributions = upgradeDistributions[classTrialBoostType];
		local activeBoostDistributions = upgradeDistributions[activeBoostType];
		if classTrialBoostDistributions and classTrialBoostDistributions.amount >= 1 and activeBoostDistributions and activeBoostDistributions.amount >= 1 then
			StaticPopup_Show("CLASS_TRIAL_CHOOSE_BOOST_TYPE", nil, nil, { activeBoostType, classTrialBoostType });
		elseif classTrialBoostDistributions and classTrialBoostDistributions.amount >= 1 then
			ClassTrialDialogMixin:StartCharacterUpgrade(classTrialBoostType);
		else
			-- Either apply the boost the player already has, or prompt them to buy a new one.
			ClassTrialDialogMixin:StartCharacterUpgrade(activeBoostType);
		end
	else
		ClassTrialDialogMixin:StartCharacterUpgrade(classTrialBoostType);
	end
end

function ClassTrialDialogMixin:ConfirmCharacterBoost(guid, boostType)
	ClassTrial_ConfirmApplyToken(guid, boostType);
end

function ClassTrialDialogMixin:DecideLater()
	self:HandleButtonClickCommon();
end

function ClassTrialDialogMixin:OnUpgradeComplete()
	self:Hide();

	self:UnregisterEvent("CLASS_TRIAL_TIMER_START");
	self:UnregisterEvent("CLASS_TRIAL_UPGRADE_COMPLETE");
end

function ClassTrialDialogMixin:UpdateDialogButtons(hasBoost)
	if hasBoost then
		self.BuyCharacterBoostButton:SetText(CLASS_TRIAL_THANKS_DIALOG_APPLY_BOOST_BUTTON);
	else
		self.BuyCharacterBoostButton:SetText(CLASS_TRIAL_THANKS_DIALOG_BUY_BOOST_BUTTON);
	end

	self.BuyCharacterBoostButton:SetWidth(self.BuyCharacterBoostButton:GetTextWidth() + 80);
	self.DecideLaterButton:SetWidth(self.DecideLaterButton:GetTextWidth() + 80);

	local buttonsWidth = self.DecideLaterButton:GetRight() - self.BuyCharacterBoostButton:GetLeft();
	local offset = (self.DialogFrame:GetWidth() - buttonsWidth) / 2;

	self.BuyCharacterBoostButton:SetPoint("BOTTOMLEFT", self.DialogFrame, "BOTTOMLEFT", offset, 50);
end

function ClassTrialDialogMixin:OnEvent(event, ...)
	if ExpansionTrialThanksForPlayingDialog:IsShown() then
		-- This means that the player has just purchased the expansion but is sitting on their logout dialog...so do nothing
		return;
	end

	if event == "CLASS_TRIAL_TIMER_START" then
		if not CanUpgradeExpansion() then
			self:ShowThanks(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING);
		end
	elseif event == "CLASS_TRIAL_UPGRADE_COMPLETE" then
		self:OnUpgradeComplete();
	end
end

function ClassTrialDialogMixin:OnShow()
	ClassTrialTimerDisplay:Hide();
	PlaySound(self.soundKit or SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER);
end

function ClassTrialDialogMixin:OnLoad()
	ClassTrialSecureFrame:SetAttribute("updateboostpurchasebutton");

	self:RegisterEvent("CLASS_TRIAL_TIMER_START");
	self:RegisterEvent("CLASS_TRIAL_UPGRADE_COMPLETE");
end

ExpansionTrialDialogMixin = CreateFromMixins(BaseExpandableDialogMixin);

local textureKitRegionInfo = {
	["Top"] = {formatString= "%s-expansionTrialPopup-top", useAtlasSize=true},
	["Middle"] = {formatString="%s-expansionTrialPopup-middle", useAtlasSize = false},
	["Bottom"] = {formatString="%s-expansionTrialPopup-bottom", useAtlasSize = true},
	["CloseButtonBG"] = {formatString="%s-expansionTrialPopup-exit-frame", useAtlasSize = true}
}

function ExpansionTrialDialogMixin:OnLoad()
	local expansionTrialBoostType = 0;
	local upgradeDisplayData = C_CharacterServices.GetCharacterServiceDisplayData(expansionTrialBoostType);
	self:SetupTextureKit(upgradeDisplayData.popupInfo.textureKit, textureKitRegionInfo);

	local currentExpansionLevel = GetClampedCurrentExpansionLevel();
	local expansionDisplayInfo = GetExpansionDisplayInfo(currentExpansionLevel);
	if expansionDisplayInfo then
		self.ExpansionImage:SetTexture(expansionDisplayInfo.logo);
	end

	self:RegisterEvent("CLASS_TRIAL_TIMER_START");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
end

function ExpansionTrialDialogMixin:OnEvent(event, ...)
	if event == "CLASS_TRIAL_TIMER_START" then
		if CanUpgradeExpansion() then
			self:SetupDialogType(false);
			self:Show();
		end
	elseif event == "UPDATE_EXPANSION_LEVEL" then
		local upgradingFromExpansionTrial = select(5, ...);
		if upgradingFromExpansionTrial then
			self:SetupDialogType(true);
			self:Show();
		end
	end
end

function ExpansionTrialDialogMixin:SetupDialogType(expansionTrialUpgrade, suppressClassTrial)
	self.suppressClassTrial = suppressClassTrial;

	if expansionTrialUpgrade then
		self.Title:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_TITLE);
		self.Description:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_TEXT);
		self.Button:SetText(EXPANSION_TRIAL_PURCHASE_THANKS_BUTTON);
	else
		self.Title:SetText(EXPANSION_TRIAL_THANKS_TITLE);
		self.Description:SetText(EXPANSION_TRIAL_THANKS_TEXT);
		self.Button:SetText(EXPANSION_TRIAL_THANKS_BUTTON);
	end

	self.expansionTrialUpgrade = expansionTrialUpgrade;
end

function ExpansionTrialDialogMixin:IsShowingExpansionTrialUpgrade()
	return self:IsShown() and self.expansionTrialUpgrade;
end

function ExpansionTrialDialogMixin:OnShow()
	SetStoreUIShown(false);
	self:SetHeight(300 + self.Description:GetHeight() + self.Title:GetHeight());
end

function ExpansionTrialDialogMixin:OnHide()
	if not self.suppressClassTrial then
		ClassTrialTimerDisplay:ShowTimer();
	end
end

function ExpansionTrialDialogMixin:OnButtonClick()
	BaseExpandableDialogMixin.OnCloseClick(self);

	if self.expansionTrialUpgrade then
		ForceLogout();
	else
		SetStoreUIShown(true);
		StoreFrame_SetGamesCategory();
	end
end

function ExpansionTrialDialogMixin:OnCloseClick()
	BaseExpandableDialogMixin.OnCloseClick(self);
	if self.expansionTrialUpgrade then
		ForceLogout();
	end
end

ClassTrialTimerDisplayMixin = {}

function ClassTrialTimerDisplayMixin:SetupCountdown()
	self.kickTime = C_ClassTrial.GetClassTrialLogoutTimeSeconds();
end

function ClassTrialTimerDisplayMixin:UpdateTimerText()
	self.remaining = max(self.kickTime - GetTime(), 0);

	local formattedTime = SecondsToTime(self.remaining, false, true, 1, true);
	local timerText = CLASS_TRIAL_TIMER_DIALOG_TEXT_NO_REMAINING_TIME;

	if formattedTime ~= "" then
		timerText = CLASS_TRIAL_TIMER_DIALOG_TEXT_HAS_REMAINING_TIME:format(formattedTime);
	end

	self.TimerText:SetText(timerText);
end

function ClassTrialTimerDisplayMixin:ShowTimer()
	self:SetupCountdown();
	self:UpdateTimerText();
	self:Show();
end

function ClassTrialTimerDisplayMixin:CheckShowTimer()
	self:SetupCountdown();
	if self.kickTime > 0 then
		self:ShowTimer();
	end
end

function ClassTrialTimerDisplayMixin:OnUpdate()
	self:UpdateTimerText();
end

function ClassTrialTimerDisplayMixin:OnUpgradeComplete()
	self:Hide();

	self:UnregisterEvent("CLASS_TRIAL_TIMER_START");
	self:UnregisterEvent("CLASS_TRIAL_UPGRADE_COMPLETE");
end

function ClassTrialTimerDisplayMixin:OnEvent(event, ...)
	if event == "CLASS_TRIAL_UPGRADE_COMPLETE" then
		self:OnUpgradeComplete();
	end
end

function ClassTrialTimerDisplayMixin:OnMouseUp()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if CanUpgradeExpansion() then
		ExpansionTrialThanksForPlayingDialog:Show();
	else
		ClassTrialThanksForPlayingDialog:ShowThanks();
	end
end

function ClassTrialTimerDisplayMixin:OnShow()
	ClassTrialThanksForPlayingDialog:Hide();
end

function ClassTrialTimerDisplayMixin:OnLoad()
	self:RegisterEvent("CLASS_TRIAL_TIMER_START");
	self:RegisterEvent("CLASS_TRIAL_UPGRADE_COMPLETE");
	self:CheckShowTimer();
end
