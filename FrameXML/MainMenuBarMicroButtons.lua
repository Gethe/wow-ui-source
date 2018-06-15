PERFORMANCEBAR_UPDATE_INTERVAL = 1;
MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"StoreMicroButton",
	}

EJ_ALERT_TIME_DIFF = 60*60*24*7*2; -- 2 weeks

local g_microButtonAlertsEnabled = true;
local g_visibleMicroButtonAlerts = {};
local g_flashingMicroButtons = {};

function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	local prefix = "hud-microbutton-";
	self:SetNormalAtlas(prefix..name.."-Up", true);
	self:SetPushedAtlas(prefix..name.."-Down", true);
	self:SetDisabledAtlas(prefix..name.."-Disabled", true);
	self:SetHighlightAtlas("hud-microbutton-highlight", true);
end

function MicroButtonTooltipText(text, action)
	if ( GetBindingKey(action) ) then
		return text.." "..NORMAL_FONT_COLOR_CODE.."("..GetBindingText(GetBindingKey(action))..")"..FONT_COLOR_CODE_CLOSE;
	else
		return text;
	end

end

function MicroButton_OnEnter(self)
	if ( self:IsEnabled() or self.minLevel or self.disabledTooltip or self.factionGroup) then
		GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);
		if ( not self:IsEnabled() ) then
			if ( self.factionGroup == "Neutral" ) then
				GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				GameTooltip:Show();
			elseif ( self.minLevel ) then
				GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				GameTooltip:Show();
			elseif ( self.disabledTooltip ) then
				GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				GameTooltip:Show();
			end
		end
	end
end

function UpdateMicroButtonsParent(parent)
	for i=1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(parent);
	end
end

function MoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)
	CharacterMicroButton:ClearAllPoints();
	CharacterMicroButton:SetPoint(anchor, anchorTo, relAnchor, x, y);
	LFDMicroButton:ClearAllPoints();
	if ( isStacked ) then
		LFDMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, -1);
	else
		LFDMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", -2, 0);
	end
	MainMenuMicroButton_RepositionAlerts();
	UpdateMicroButtons();
end

function SetKioskTooltip(frame)
	if (IsKioskModeEnabled()) then
		frame.minLevel = nil;
		frame.disabledTooltip = ERR_SYSTEM_DISABLED;
	end
end

local function GuildFrameIsOpen()
	return ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) or ( LookingForGuildFrame and LookingForGuildFrame:IsShown() );
end

function UpdateMicroButtons()
	local playerLevel = UnitLevel("player");
	local factionGroup = UnitFactionGroup("player");

	if ( factionGroup == "Neutral" ) then
		GuildMicroButton.factionGroup = factionGroup;
		LFDMicroButton.factionGroup = factionGroup;
	else
		GuildMicroButton.factionGroup = nil;
		LFDMicroButton.factionGroup = nil;
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
		if ( playerLevel < SHOW_SPEC_LEVEL ) then
			TalentMicroButton:Disable();
		else
			TalentMicroButton:Enable();
			TalentMicroButton:SetButtonState("NORMAL");
		end
	end

	if (  WorldMapFrame and WorldMapFrame:IsShown() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", true);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end

	if ( ( GameMenuFrame and GameMenuFrame:IsShown() )
		or ( InterfaceOptionsFrame:IsShown())
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", true);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	GuildMicroButton_UpdateTabard();
	if ( IsTrialAccount() or (IsVeteranTrialAccount() and not IsInGuild()) or factionGroup == "Neutral" or IsKioskModeEnabled() ) then
		GuildMicroButton:Disable();
		if (IsKioskModeEnabled()) then
			SetKioskTooltip(GuildMicroButton);
		end
	elseif ( GuildFrameIsOpen() ) then
		GuildMicroButton:Enable();
		GuildMicroButton:SetButtonState("PUSHED", true);
		GuildMicroButtonTabard:SetPoint("TOPLEFT", -1, -1);
		GuildMicroButtonTabard:SetAlpha(0.70);
	else
		GuildMicroButton:Enable();
		GuildMicroButton:SetButtonState("NORMAL");
		GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, 0);
		GuildMicroButtonTabard:SetAlpha(1);
		if ( CommunitiesFrame_IsEnabled() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB");
			GuildMicroButton.newbieText = NEWBIE_TOOLTIP_COMMUNITIESTAB;
		elseif ( IsInGuild() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
			GuildMicroButton.newbieText = NEWBIE_TOOLTIP_GUILDTAB;
		else
			GuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
			GuildMicroButton.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;
		end
	end

	if ( PVEFrame and PVEFrame:IsShown() ) then
		LFDMicroButton:SetButtonState("PUSHED", true);
	else
		if ( IsKioskModeEnabled() or playerLevel < LFDMicroButton.minLevel or factionGroup == "Neutral" ) then
			if (IsKioskModeEnabled()) then
				SetKioskTooltip(LFDMicroButton);
			end
			LFDMicroButton:Disable();
		else
			LFDMicroButton:Enable();
			LFDMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", true);
	else
		if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() and not IsKioskModeEnabled()  ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			if (IsKioskModeEnabled()) then
				SetKioskTooltip(AchievementMicroButton);
			end
			AchievementMicroButton:Disable();
		end
	end

	EJMicroButton_UpdateDisplay();

	if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
		CollectionsMicroButton:Enable();
		CollectionsMicroButton:SetButtonState("PUSHED", true);
	else
		CollectionsMicroButton:Enable();
		CollectionsMicroButton:SetButtonState("NORMAL");
	end

	if ( StoreFrame and StoreFrame_IsShown() ) then
		StoreMicroButton:SetButtonState("PUSHED", true);
	else
		StoreMicroButton:SetButtonState("NORMAL");
	end
	
	StoreMicroButton:Show();
	HelpMicroButton:Hide();
	if ( IsVeteranTrialAccount() ) then
		StoreMicroButton.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		StoreMicroButton:Disable();
	elseif ( IsTrialAccount() and not C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAMES_CATEGORY_ID) ) then
		StoreMicroButton.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		StoreMicroButton:Disable();
	elseif ( C_StorePublic.IsDisabledByParentalControls() ) then
		StoreMicroButton.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS;
		StoreMicroButton:Disable();
	elseif ( IsKioskModeEnabled() ) then
		StoreMicroButton.disabledTooltip = ERR_SYSTEM_DISABLED;
		StoreMicroButton:Disable();
	elseif ( not C_StorePublic.IsEnabled() ) then
		if ( GetCurrentRegionName() == "CN" ) then
			HelpMicroButton:Show();
			StoreMicroButton:Hide();
		else
			StoreMicroButton.disabledTooltip = BLIZZARD_STORE_ERROR_UNAVAILABLE;
			StoreMicroButton:Disable();
		end
	else
		StoreMicroButton.disabledTooltip = nil;
		StoreMicroButton:Enable();
	end
end

function MicroButtonPulse(self, duration)
	if not g_microButtonAlertsEnabled then
		return;
	end

	g_flashingMicroButtons[self] = true;
	UIFrameFlash(self.Flash, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
end

function MicroButtonPulseStop(self)
	UIFrameFlashStop(self.Flash);
	g_flashingMicroButtons[self] = nil;
end

function MicroButton_KioskModeDisable(self)
	if (IsKioskModeEnabled()) then
		self:Disable();
	end
end

function AchievementMicroButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end

function GuildMicroButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		if ( CommunitiesFrame_IsEnabled() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB");
		elseif ( IsInGuild() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
		else
			GuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		GuildMicroButtonTabard.needsUpdate = true;
		UpdateMicroButtons();
	end
end

function GuildMicroButton_UpdateTabard(forceUpdate)
	local tabard = GuildMicroButtonTabard;
	if ( not tabard.needsUpdate and not forceUpdate ) then
		return;
	end
	-- switch textures if the guild has a custom tabard
	local emblemFilename = select(10, GetGuildLogoInfo());
	if ( emblemFilename ) then
		if ( not tabard:IsShown() ) then
			local button = GuildMicroButton;
			button:SetNormalAtlas("hud-microbutton-Character-Up", true);
			button:SetPushedAtlas("hud-microbutton-Character-Down", true);
			-- no need to change disabled texture, should always be available if you're in a guild
			tabard:Show();
		end
		SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background);
	else
		if ( tabard:IsShown() ) then
			local button = GuildMicroButton;
			button:SetNormalAtlas("hud-microbutton-Socials-Up", true);
			button:SetPushedAtlas("hud-microbutton-Socials-Down", true);
			button:SetDisabledAtlas("hud-microbutton-Socials-Disabled", true);
			tabard:Hide();
		end
	end
	tabard.needsUpdate = nil;
end

function CharacterMicroButton_OnLoad(self)
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");
	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER;
	LoadMicroButtonTextures(self, "Character");	
end

function CharacterMicroButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, "player");
		end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(MicroButtonPortrait, "player");
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(MicroButtonPortrait, "player");
		CharacterMicroButton_UpdatePulsing(self);
	elseif ( event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" ) then
		CharacterMicroButton_UpdatePulsing(self);
	elseif ( event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" ) then
		CharacterMicroButton_UpdatePulsing(self);
	end
end

function CharacterMicroButton_UpdatePulsing(self)
	if IsPlayerInWorld() and AzeriteUtil.DoEquippedItemsHaveUnselectedPowers() then
		MicroButtonPulse(self);
	else
		MicroButtonPulseStop(self);
	end
end

function CharacterMicroButton_SetPushed()
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
	CharacterMicroButton_UpdatePulsing(CharacterMicroButton);
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", true);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end

MAIN_MENU_MICRO_ALERT_PRIORITY = {
	"CollectionsMicroButtonAlert",
	"TalentMicroButtonAlert",
	"EJMicroButtonAlert",
};

function MainMenuMicroButton_SetAlertsEnabled(enabled)
	g_microButtonAlertsEnabled = enabled;

	if not enabled then
		for alert in pairs(g_visibleMicroButtonAlerts) do
			alert:Hide();
		end

		for flashingButton in pairs(g_flashingMicroButtons) do
			MicroButtonPulseStop(flashingButton);
		end

		g_visibleMicroButtonAlerts = {};
		g_flashingMicroButtons = {};
	end
end

function MainMenuMicroButton_ShowAlert(alert, text, tutorialIndex)
	if not g_microButtonAlertsEnabled then
		return false;
	end

	if tutorialIndex and GetCVarBitfield("closedInfoFrames", tutorialIndex) then
		return false;
	end

	local isHighestPriority = false;
	for i, priorityFrameName in ipairs(MAIN_MENU_MICRO_ALERT_PRIORITY) do
		local priorityFrame = _G[priorityFrameName];
		if alert == priorityFrame then
			isHighestPriority = true;
		end

		if priorityFrame:IsShown() then
			if not isHighestPriority then
				-- Higher priority is shown
				return false;
			end

			-- Lower priority alert is visible, kill it
			priorityFrame:Hide();
		end
	end
	alert.Text:SetText(text);
	alert:SetHeight(alert.Text:GetHeight()+42);
	alert.tutorialIndex = tutorialIndex;
	MainMenuMicroButton_PositionAlert(alert);
	alert:Show();

	g_visibleMicroButtonAlerts[alert] = true;

	return alert:IsShown();
end

function MainMenuMicroButton_RepositionAlerts()
	for alert in pairs(g_visibleMicroButtonAlerts) do
		MainMenuMicroButton_PositionAlert(alert);
	end
end

function MainMenuMicroButton_PositionAlert(alert)
	if ( alert.MicroButton:GetRight() + (alert:GetWidth() / 2) > UIParent:GetRight() ) then
		alert:ClearAllPoints();
		alert:SetPoint("BOTTOMRIGHT", alert.MicroButton, "TOPRIGHT", 16, 20);
		alert.Arrow:ClearAllPoints();
		alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -4, 4);
	else
		alert:ClearAllPoints();
		alert:SetPoint("BOTTOM", alert.MicroButton, "TOP", 0, 20);
		alert.Arrow:ClearAllPoints();
		alert.Arrow:SetPoint("TOP", alert, "BOTTOM", 0, 4);
	end
end

TalentMicroButtonMixin = {};

function TalentMicroButtonMixin:HasTalentAlertToShow()
	return not AreTalentsLocked() and GetNumUnspentTalents() > 0;
end

function TalentMicroButtonMixin:HasPvpTalentAlertToShow()
	local hasEmptySlot, hasNewTalent = C_SpecializationInfo.GetPvpTalentAlertStatus();
	if (hasEmptySlot) then
		return true, TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT;
	elseif (hasNewTalent) then
		return true, TALENT_MICRO_BUTTON_NEW_PVP_TALENT;
	end

	return false;
end

function TalentMicroButtonMixin:EvaluateAlertVisibility()
	-- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
	if self:HasTalentAlertToShow() and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
		if MainMenuMicroButton_ShowAlert(TalentMicroButtonAlert, TALENT_MICRO_BUTTON_UNSPENT_TALENTS) then
            TalentMicroButton.suggestedTab = 2;
			return;
		end
	end
	local hasAlert, text = self:HasPvpTalentAlertToShow();
	if hasAlert and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
        if (MainMenuMicroButton_ShowAlert(TalentMicroButtonAlert, text)) then
            TalentMicroButton.suggestedTab = 2;
            return;
        end
	end

    TalentMicroButton.suggestedTab = nil;
end

--Talent button specific functions
function TalentMicroButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		local level = ...;
		if (level == SHOW_SPEC_LEVEL) then
			if MainMenuMicroButton_ShowAlert(TalentMicroButtonAlert, TALENT_MICRO_BUTTON_SPEC_TUTORIAL) then
				MicroButtonPulse(self);
			end
		elseif (level == SHOW_TALENT_LEVEL) then
			if MainMenuMicroButton_ShowAlert(TalentMicroButtonAlert, TALENT_MICRO_BUTTON_TALENT_TUTORIAL) then
				MicroButtonPulse(self);
			end
		end
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		self:EvaluateAlertVisibility();
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "HONOR_LEVEL_UPDATE" ) then
		UpdateMicroButtons();
		self:EvaluateAlertVisibility();

		-- On the first update from the server, flash the button if there are unspent points
		-- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
		if (not self.receivedUpdate and GetNumSpecializations(false) > 0) then
			self.receivedUpdate = true;
			local shouldPulseForTalents = self:HasTalentAlertToShow() or self:HasPvpTalentAlertToShow();
			if (UnitLevel("player") >= SHOW_SPEC_LEVEL and (not GetSpecialization() or shouldPulseForTalents)) then
				MicroButtonPulse(self);		
			end
		end
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

function TalentMicroButton_OnClick(self)
    ToggleTalentFrame(self.suggestedTab);
end

do
	local function SafeSetCollectionJournalTab(tab)
		if CollectionsJournal_SetTab then
			CollectionsJournal_SetTab(CollectionsJournal, tab);
		else
			SetCVar("petJournalTab", tab);
		end
	end

	CollectionMicroButtonMixin = {};

	function CollectionMicroButtonMixin:EvaluateAlertVisibility()
		if CollectionsJournal and CollectionsJournal:IsShown() then
			return;
		end

		local numMountsNeedingFanfare = C_MountJournal.GetNumMountsNeedingFanfare();
		local numPetsNeedingFanfare = C_PetJournal.GetNumPetsNeedingFanfare();
		if numMountsNeedingFanfare > self.lastNumMountsNeedingFanfare or numPetsNeedingFanfare > self.lastNumPetsNeedingFanfare then
			if MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, numMountsNeedingFanfare + numPetsNeedingFanfare > 1 and COLLECTION_UNOPENED_PLURAL or COLLECTION_UNOPENED_SINGULAR) then
				MicroButtonPulse(self);
				SafeSetCollectionJournalTab(numMountsNeedingFanfare > 0 and 1 or 2);
			end
		end
		self.lastNumMountsNeedingFanfare = numMountsNeedingFanfare;
		self.lastNumPetsNeedingFanfare = numPetsNeedingFanfare;
	end

	function CollectionsMicroButton_OnEvent(self, event, ...)
		if CollectionsJournal and CollectionsJournal:IsShown() then
			return;
		end

		if ( event == "HEIRLOOMS_UPDATED" ) then
			local itemID, updateReason = ...;
			if itemID and updateReason == "NEW" then
				if MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, HEIRLOOMS_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL) then
					MicroButtonPulse(self);
					SafeSetCollectionJournalTab(4);
				end
			end
		elseif ( event == "PET_JOURNAL_NEW_BATTLE_SLOT" ) then
			if MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, COMPANIONS_MICRO_BUTTON_NEW_BATTLE_SLOT) then
				MicroButtonPulse(self);
				SafeSetCollectionJournalTab(2);
			end
		elseif ( event == "TOYS_UPDATED" ) then
			local itemID, new = ...;
			if itemID and new then
				if MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, TOYBOX_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_TOYBOX) then
					MicroButtonPulse(self);
					SafeSetCollectionJournalTab(3);
				end
			end
		elseif ( event == "COMPANION_LEARNED" or event == "PLAYER_ENTERING_WORLD" or event == "PET_JOURNAL_LIST_UPDATE" ) then
			self:EvaluateAlertVisibility();
		end
	end
end

-- Encounter Journal
function EJMicroButton_OnLoad(self)
	LoadMicroButtonTextures(self, "EJ");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL;

	--events that can trigger a refresh of the adventure journal
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
end

EJMicroButtonMixin = {};

function EJMicroButtonMixin:EvaluateAlertVisibility()
	if self.playerEntered and self.varsLoaded and self.zoneEntered then
		if self:IsEnabled() then
			local showAlert = not IsKioskModeEnabled() and not GetCVarBool("hideAdventureJournalAlerts");
			if( showAlert ) then
				-- display alert if the player hasn't opened the journal for a long time
				local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"));
				if ( GetServerTime() - lastTimeOpened > EJ_ALERT_TIME_DIFF ) then
					if MainMenuMicroButton_ShowAlert(EJMicroButtonAlert, AJ_MICRO_BUTTON_ALERT_TEXT) then
						MicroButtonPulse(EJMicroButton);
					end
				end

				if ( lastTimeOpened ~= 0 ) then
					SetCVar("advJournalLastOpened", GetServerTime() );
				end

				EJMicroButton_UpdateAlerts(true);
			end
			self:UpdateLastEvaluations();
		end
	end
end

function EJMicroButtonMixin:UpdateLastEvaluations()
	local playerLevel = UnitLevel("player");

	self.lastEvaluatedLevel = playerLevel;

	if (playerLevel == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) then
		local spec = GetSpecialization();
		local ilvl = GetAverageItemLevel();

		self.lastEvaluatedSpec = spec;
		self.lastEvaluatedIlvl = ilvl;
	end
end

function EJMicroButton_OnEvent(self, event, ...)
	if( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
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
			EJMicroButton_UpdateNewAdventureNotice(true);
		end
	elseif ( event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" ) then
		local playerLevel = UnitLevel("player");
		local spec = GetSpecialization();
		local ilvl = GetAverageItemLevel();
		if ( playerLevel == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] and ((not self.lastEvaluatedSpec or self.lastEvaluatedSpec ~= spec) or (not self.lastEvaluatedIlvl or self.lastEvaluatedIlvl < ilvl))) then
			self.lastEvaluatedSpec = spec;
			self.lastEvaluatedIlvl = ilvl;
			EJMicroButton_UpdateNewAdventureNotice(false);
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		self.zoneEntered = true;
	end

	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
		if self.playerEntered and self.varsLoaded and self.zoneEntered then
			EJMicroButton_UpdateDisplay();
			if self:IsEnabled() then
				C_AdventureJournal.UpdateSuggestions();
				self:EvaluateAlertVisibility();
			end
		end
	end
end

function EJMicroButton_UpdateNewAdventureNotice(levelUp)
	if ( EJMicroButton:IsEnabled() and C_AdventureJournal.UpdateSuggestions(levelUp) ) then
		if( not EncounterJournal or not EncounterJournal:IsShown() ) then
			EJMicroButton.Flash:Show();
			EJMicroButton.NewAdventureNotice:Show();
		end
	end
end

function EJMicroButton_ClearNewAdventureNotice()
	EJMicroButton.Flash:Hide();
	EJMicroButton.NewAdventureNotice:Hide();
end

function EJMicroButton_UpdateDisplay()
	local frame = EJMicroButton;
	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		frame:SetButtonState("PUSHED", true);
	else
		local disabled = not C_AdventureJournal.CanBeShown();
		if ( disabled ) then
			frame:Disable();
			frame.disabledTooltip = FEATURE_NOT_YET_AVAILABLE;
			EJMicroButton_ClearNewAdventureNotice();
		else
			frame:Enable();
			frame:SetButtonState("NORMAL");
		end
	end
end

function EJMicroButton_UpdateAlerts( flag )
	if ( flag ) then
		EJMicroButton:RegisterEvent("UNIT_LEVEL");
		EJMicroButton:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
		EJMicroButton_UpdateNewAdventureNotice(false)
	else
		EJMicroButton:UnregisterEvent("UNIT_LEVEL");
		EJMicroButton:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
		EJMicroButton_ClearNewAdventureNotice()
	end
end

StoreMicroButtonMixin = {};

function StoreMicroButton_OnLoad(self)
	LoadMicroButtonTextures(self, "BStore");
	self.tooltipText = BLIZZARD_STORE;
	self:RegisterEvent("STORE_STATUS_CHANGED");
	if (IsKioskModeEnabled()) then
		self:Disable();
	end
	if (IsRestrictedAccount()) then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function StoreMicroButton_OnEvent(self, event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		local level = ...;
		self:EvaluateAlertVisibility(level);
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self:EvaluateAlertVisibility(UnitLevel("player"));
	end
	UpdateMicroButtons();
	if (IsKioskModeEnabled()) then
		self:Disable();
	end
end

function StoreMicroButtonMixin:EvaluateAlertVisibility(level)
	if (IsTrialAccount()) then
		local rLevel = GetRestrictedAccountData();
		if (level >= rLevel and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRIAL_BANKED_XP)) then
			MainMenuMicroButton_ShowAlert(StoreMicroButtonAlert, STORE_MICRO_BUTTON_ALERT_TRIAL_CAP_REACHED);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRIAL_BANKED_XP, true);
		end
	end
end

--Micro Button alerts
function MicroButtonAlert_SetText(self, text)
	self.Text:SetText(text or "");
end

function MicroButtonAlert_OnLoad(self)
	self.Text:SetSpacing(4);
	MicroButtonAlert_SetText(self, self.label);
end

function MicroButtonAlert_OnShow(self)
	self:SetHeight(self.Text:GetHeight() + 42);
	if ( self.tutorialIndex and GetCVarBitfield("closedInfoFrames", self.tutorialIndex) ) then
		self:Hide();
	end
end

function MicroButtonAlert_OnHide(self)
	g_visibleMicroButtonAlerts[self] = nil;

	if not g_microButtonAlertsEnabled then
		return;
	end

	-- If anything is shown, leave it in that state
	for i, priorityFrameName in ipairs(MAIN_MENU_MICRO_ALERT_PRIORITY) do
		local priorityFrame = _G[priorityFrameName];
		if priorityFrame:IsShown() then
			return;
		end
	end

	-- Nothing shown, try evaluating its visibility
	for i, priorityFrameName in ipairs(MAIN_MENU_MICRO_ALERT_PRIORITY) do
		local priorityFrame = _G[priorityFrameName];
		if priorityFrame ~= self then
			priorityFrame.MicroButton:EvaluateAlertVisibility();
			if priorityFrame:IsShown() then
				break;
			end
		end
	end
end

function MicroButtonAlert_CreateAlert(parent, tutorialIndex, text, anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	local alert = CreateFrame("Frame", nil, parent, "MicroButtonAlertTemplate");
	alert.tutorialIndex = tutorialIndex;

	alert:SetPoint(anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY);

	MicroButtonAlert_SetText(alert, text);
	return alert;
end