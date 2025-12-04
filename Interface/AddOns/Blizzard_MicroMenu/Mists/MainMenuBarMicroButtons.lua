MICRO_BUTTONS_X_OFFSET = -4;

MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"GuildMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"PVPMicroButton",
	"LFGMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"StoreMicroButton",
}

function UpdateMicroButtons()
	local playerLevel = UnitLevel("player");
	local factionGroup = UnitFactionGroup("player");

	if ( factionGroup == "Neutral" ) then
		PVPMicroButton.factionGroup = factionGroup;
		GuildMicroButton.factionGroup = factionGroup;
	else
		PVPMicroButton.factionGroup = nil;
		GuildMicroButton.factionGroup = nil;
	end

	if ( CharacterFrame and CharacterFrame:IsShown() ) then
		CharacterMicroButton:SetButtonState("PUSHED", true);
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton:SetButtonState("NORMAL");
		CharacterMicroButton_SetNormal();
	end

	if ( SpellBookFrame and SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", true);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		TalentMicroButton:SetButtonState("PUSHED", true);
	else
		if ( not C_SpecializationInfo.CanPlayerUseTalentSpecUI() ) then
			TalentMicroButton:Hide();
			AchievementMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMLEFT", 0, 0);
		else
			TalentMicroButton:Show();
			AchievementMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMRIGHT", -3, 0);
		end
		TalentMicroButton:SetButtonState("NORMAL");
	end

	if ( QuestLogFrame and QuestLogFrame:IsVisible() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end

	SocialsMicroButton:UpdateMicroButton();

	GuildMicroButton:UpdateMicroButton();

	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		EJMicroButton:SetButtonState("PUSHED", 1);
	else
		EJMicroButton:SetButtonState("NORMAL");
	end

	StoreMicroButton:UpdateMicroButton();

	if ( PVPParentFrame and PVPParentFrame:IsShown() ) then
		PVPMicroButton:SetButtonState("PUSHED", true);
	else
		if ( playerLevel < PVPMicroButton.minLevel or factionGroup == "Neutral" ) then
			PVPMicroButton:Disable();
		else
			PVPMicroButton:Enable();
			PVPMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( PVEFrame and PVEFrame:IsShown() ) then
		LFGMicroButton:SetButtonState("PUSHED", true);
	else
		if ( playerLevel < LFGMicroButton.minLevel ) then
			LFGMicroButton:Disable();
		else
			LFGMicroButton:Enable();
			LFGMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( ( GameMenuFrame and GameMenuFrame:IsShown() )
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", true);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	MainMenuMicroButton:ClearAllPoints();
	MainMenuMicroButton:SetPoint("BOTTOMLEFT", StoreMicroButton, "BOTTOMRIGHT", -3, 0);

	if ( HelpFrame and HelpFrame:IsVisible() ) then
		HelpMicroButton:SetButtonState("PUSHED", 1);
	else
		HelpMicroButton:SetButtonState("NORMAL");
	end

	-- Keyring microbutton
	if (IsKeyRingEnabled() and KeyRingButton) then
		if ( IsBagOpen(KEYRING_CONTAINER) ) then
			KeyRingButton:SetButtonState("PUSHED", 1);
		else
			KeyRingButton:SetButtonState("NORMAL");
		end
	end

	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", true);
	else
		if ( ( HasCompletedAnyAchievement() ) and CanShowAchievementUI() and not Kiosk.IsEnabled()  ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			if (Kiosk.IsEnabled()) then
				SetKioskTooltip(AchievementMicroButton);
			end
			AchievementMicroButton:Disable();
		end
	end
end

function AchievementMicroButton_OnLoad()
	LoadMicroButtonTextures(self, "Achievement");
	self:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST");
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	self.newbieText = NEWBIE_TOOLTIP_ACHIEVEMENT;
	self.minLevel = 10;	--Just used for display. But we know that it will become available by level 10 due to the level 10 achievement.
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
end

function AchievementMicroButton_OnEvent(event, ...)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end

CollectionMicroButtonMixin = {};

local function SafeSetCollectionJournalTab(tab)
	if CollectionsJournal_SetTab then
		CollectionsJournal_SetTab(CollectionsJournal, tab);
	else
		SetCVar("petJournalTab", tab);
	end
end

function CollectionMicroButtonMixin:EvaluateAlertVisibility()
	if Kiosk.IsEnabled() then
		return false;
	end

	if CollectionsJournal and CollectionsJournal:IsShown() then
		return false;
	end

	local numMountsNeedingFanfare = C_MountJournal.GetNumMountsNeedingFanfare();
	local numPetsNeedingFanfare = C_PetJournal.GetNumPetsNeedingFanfare();
	local alertShown = false;
	if numMountsNeedingFanfare > self.lastNumMountsNeedingFanfare or numPetsNeedingFanfare > self.lastNumPetsNeedingFanfare then
		MicroButtonPulse(self);
		SafeSetCollectionJournalTab(numMountsNeedingFanfare > 0 and 1 or 2);
	end
	self.lastNumMountsNeedingFanfare = numMountsNeedingFanfare;
	self.lastNumPetsNeedingFanfare = numPetsNeedingFanfare;
	return alertShown;
end

function CollectionMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Mounts");
	SetDesaturation(self:GetDisabledTexture(), true);
	self:RegisterEvent("HEIRLOOMS_UPDATED");
	self:RegisterEvent("TOYS_UPDATED");
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS");
end

function CollectionMicroButtonMixin:OnEvent(event, ...)
	if CollectionsJournal and CollectionsJournal:IsShown() then
		return;
	end

	if ( event == "HEIRLOOMS_UPDATED" ) then
		local itemID, updateReason = ...;
		if itemID and updateReason == "NEW" then
			local tabIndex = 4;
			CollectionsMicroButton_SetAlert(tabIndex);
		end
	elseif ( event == "TOYS_UPDATED" ) then
		local itemID, new = ...;
		if itemID and new then
			local tabIndex = 3;
			CollectionsMicroButton_SetAlert(tabIndex);
		end
	elseif ( event == "COMPANION_LEARNED" or event == "PLAYER_ENTERING_WORLD" or event == "PET_JOURNAL_LIST_UPDATE" ) then
		self:EvaluateAlertVisibility();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS");
	end
end

function CollectionsMicroButton_SetAlert(tabIndex)
	CollectionsMicroButton_SetAlertShown(true);
	SafeSetCollectionJournalTab(tabIndex);
end

function CollectionsMicroButton_SetAlertShown(shown)
	if shown then
		MicroButtonPulse(CollectionsMicroButton);
	else
		MicroButtonPulseStop(CollectionsMicroButton);
	end
end

function CollectionMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleCollectionsJournal();
	end
end

EJMicroButtonMixin = {};

function EJMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "EJ");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL;
	self.minLevel = SHOW_LFD_LEVEL;

	--events that can trigger a refresh of the adventure journal
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
end

function EJMicroButtonMixin:UpdateLastEvaluations()
	local playerLevel = UnitLevel("player");

	self.lastEvaluatedLevel = playerLevel;

	if (playerLevel == GetMaxLevelForPlayerExpansion()) then
		local spec = GetSpecialization();
		local ilvl = GetAverageItemLevel();

		self.lastEvaluatedSpec = spec;
		self.lastEvaluatedIlvl = ilvl;
	end
end

function EJMicroButtonMixin:OnShow()
	MicroButton_KioskModeDisable(self);
end

function EJMicroButtonMixin:OnEvent(event, ...)
	if( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
		self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL;
		UpdateMicroButtons();
	elseif( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self.lastEvaluatedLevel = UnitLevel("player");
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self.playerEntered = true;
	elseif ( event == "UNIT_LEVEL" ) then
		local unitToken = ...;
		if unitToken == "player" and (not self.lastEvaluatedLevel or UnitLevel(unitToken) > self.lastEvaluatedLevel) then
			self.lastEvaluatedLevel = UnitLevel(unitToken);
			-- if ( self:IsEnabled() ) then
			-- 	C_AdventureJournal.UpdateSuggestions(true);
			-- end
		end
	elseif ( event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" ) then
		local playerLevel = UnitLevel("player");
		local spec = GetSpecialization();
		local ilvl = GetAverageItemLevel();
		if ( playerLevel == GetMaxLevelForPlayerExpansion() and ((not self.lastEvaluatedSpec or self.lastEvaluatedSpec ~= spec) or (not self.lastEvaluatedIlvl or self.lastEvaluatedIlvl < ilvl))) then
			self.lastEvaluatedSpec = spec;
			self.lastEvaluatedIlvl = ilvl;
			-- if ( self:IsEnabled() ) then
			-- 	C_AdventureJournal.UpdateSuggestions(false);
			-- end
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		self.zoneEntered = true;
	-- elseif ( event == "NEW_RUNEFORGE_POWER_ADDED" ) then
	-- 	local powerID = ...;
	-- 	self.runeforgePowerAdded = powerID;
	-- 	self:EvaluateAlertVisibility();
	end

	-- if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
	-- 	if self.playerEntered and self.varsLoaded and self.zoneEntered then
	-- 		if self:IsEnabled() then
	-- 			--C_AdventureJournal.UpdateSuggestions();
	-- 			self:EvaluateAlertVisibility();
	-- 		end
	-- 	end
	-- end
end

function EJMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleEncounterJournal();
	end
end

StoreMicroButtonMixin = {};

function StoreMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "BStore");
	self.tooltipText = BLIZZARD_STORE;

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("STORE_STATUS_CHANGED");
	if ( Kiosk.IsEnabled() ) then
		self:Disable();
	end
	if ( IsRestrictedAccount() ) then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function StoreMicroButtonMixin:OnEvent(event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		local level = ...;
		self:EvaluateAlertVisibility(level);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:EvaluateAlertVisibility(UnitLevel("player"));
	end
	UpdateMicroButtons();
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
end

function StoreMicroButtonMixin:GetButtonContext()
	return self.buttonContext;
end

function StoreMicroButtonMixin:OnClick()
	ToggleStoreUI(self:GetButtonContext());
end

function StoreMicroButtonMixin:EvaluateAlertVisibility(level)
	local alertShown = false;
	if (IsTrialAccount()) then
		local rLevel = GetRestrictedAccountData();
		if (level >= rLevel and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRIAL_BANKED_XP)) then
			alertShown = MainMenuMicroButton_ShowAlert(self, STORE_MICRO_BUTTON_ALERT_TRIAL_CAP_REACHED);
			if alertShown then
				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRIAL_BANKED_XP, true);
			end
		end
	end
	return alertShown;
end

function StoreMicroButtonMixin:UpdateMicroButton()
	if ( StoreFrame and StoreFrame_IsShown() ) then
		self:SetButtonState("PUSHED", true);
	else
		self:SetButtonState("NORMAL");
	end

	self:Show();
	HelpMicroButton:Hide();

	if ( Kiosk.IsEnabled() ) then
		self.disabledTooltip = ERR_SYSTEM_DISABLED;
		self:Disable();
	elseif ( not C_StorePublic.IsEnabled() ) then
		if ( GetCurrentRegionName() == "CN" ) then
			self:Show();
			self:Hide();

			if ( HelpFrame and HelpFrame:IsShown() ) then
				HelpMicroButton:SetPushed();
			else
				HelpMicroButton:SetNormal();
			end
		else
			self.disabledTooltip = BLIZZARD_STORE_ERROR_UNAVAILABLE;
			self:Disable();
		end
	elseif C_PlayerInfo.IsPlayerNPERestricted() then
		local tutorials = TutorialLogic and TutorialLogic.Tutorials;
		if tutorials and tutorials.UI_Watcher and tutorials.UI_Watcher.IsActive then
			self:Hide();
		end
	else
		self.disabledTooltip = nil;
		self:Enable();
	end
end
