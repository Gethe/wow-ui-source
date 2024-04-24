
DISPLAYED_COMMUNITIES_INVITATIONS = DISPLAYED_COMMUNITIES_INVITATIONS or {};

PERFORMANCEBAR_UPDATE_INTERVAL = 1;
MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"PVPMicroButton",
	"LFGMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
}

local g_microButtonAlertsEnabled = true;
local g_visibleMicroButtonAlerts = {};
local g_flashingMicroButtons = {};

function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	local prefix = "Interface\\Buttons\\UI-MicroButton-";
	self:SetNormalTexture(prefix..name.."-Up");
	self:SetPushedTexture(prefix..name.."-Down");
	self:SetDisabledTexture(prefix..name.."-Disabled");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("CHAT_DISABLED_CHANGED");
	self:RegisterEvent("CHAT_DISABLED_CHANGE_FAILED");
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
	PVPMicroButton:ClearAllPoints();
	if ( isStacked ) then
		PVPMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 23);
	else
		PVPMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", -2, 0);
	end
	UpdateMicroButtons();
end

function SetKioskTooltip(frame)
	if (Kiosk.IsEnabled()) then
		frame.minLevel = nil;
		frame.disabledTooltip = ERR_SYSTEM_DISABLED;
	end
end

function UpdateMicroButtons()
	local playerLevel = UnitLevel("player");
	local factionGroup = UnitFactionGroup("player");


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

	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		EJMicroButton:SetButtonState("PUSHED", 1);
	else
		EJMicroButton:SetButtonState("NORMAL");
	end

	if ( PVPParentFrame and PVPParentFrame:IsShown() ) then
		PVPMicroButton:SetButtonState("PUSHED", true);
	else
		if ( playerLevel < PVPMicroButton.minLevel ) then
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
		or ( InterfaceOptionsFrame:IsShown())
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", true);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	if ( HelpFrame and HelpFrame:IsVisible() ) then
		HelpMicroButton:SetButtonState("PUSHED", 1);
	else
		HelpMicroButton:SetButtonState("NORMAL");
	end

	-- Keyring microbutton
	if (KeyRingButton) then
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

	GuildMicroButton:UpdateMicroButton();
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
	if (Kiosk.IsEnabled()) then
		self:Disable();
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

function CharacterMicroButton_OnLoad(self)
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER;
end

function CharacterMicroButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( not unit or unit == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, "player");
		end
		return;
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(MicroButtonPortrait, "player");
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	end
end

function CharacterMicroButton_SetPushed()
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
end

function MarkCommunitiesInvitiationDisplayed(clubId)
	DISPLAYED_COMMUNITIES_INVITATIONS[clubId] = true;
end

function HasUnseenCommunityInvitations()
	local invitations = C_Club.GetInvitationsForSelf();
	for i, invitation in ipairs(invitations) do
		if not DISPLAYED_COMMUNITIES_INVITATIONS[invitation.club.clubId] then
			return true;
		end
	end
	
	return false;
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", true);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end

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
	alert:Show();

	g_visibleMicroButtonAlerts[alert] = true;

	return alert:IsShown();
end

function MainMenuMicroButton_HideAlert(microButton)
	-- no-op for Classic
end

--Talent button specific functions
function TalentMicroButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		if ( not CharacterFrame:IsVisible() ) then
			SetButtonPulse(self, 60, 1);
		end
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS, "TOGGLETALENTS");
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

function LFGMicroButton_OnLoad(self)
	LoadMicroButtonTextures(self, "LFG");
	self.tooltipText = MicroButtonTooltipText(LFG_BUTTON, "TOGGLELFGPARENT");
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT;
	self.minLevel = SHOW_LFD_LEVEL;
end

GuildMicroButtonMixin = {};

function GuildMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Socials");
	self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
	self.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;
	self:RegisterEvent("STREAM_VIEW_MARKER_UPDATED");
	self:RegisterEvent("INITIAL_CLUBS_LOADED");
	self:RegisterEvent("CLUB_INVITATION_ADDED_FOR_SELF");
	self:RegisterEvent("CLUB_INVITATION_REMOVED_FOR_SELF");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CLUB_FINDER_COMMUNITY_OFFLINE_JOIN");
	self:RegisterEvent("CHAT_DISABLED_CHANGED");
	self:RegisterEvent("CHAT_DISABLED_CHANGE_FAILED");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	if ( IsCommunitiesUIDisabledByTrialAccount() ) then
		self:Disable();
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
	end
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
	self.needsUpdate = true;
end

function GuildMicroButtonMixin:OnEvent(event, ...)
	if ( Kiosk.IsEnabled() ) then
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:EvaluateAlertVisibility();
		C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All);
	elseif ( event == "UPDATE_BINDINGS" ) then
		if ( CommunitiesFrame_IsEnabled() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB");
		elseif ( IsInGuild() ) then
			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
		else
			GuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		self.needsUpdate = true;
		UpdateMicroButtons();
	elseif ( event == "BN_DISCONNECTED" or event == "BN_CONNECTED") then
		UpdateMicroButtons();
	elseif ( event == "INITIAL_CLUBS_LOADED" ) then
		self:UpdateNotificationIcon(GuildMicroButton);
		local previouslyDisplayedInvitations = DISPLAYED_COMMUNITIES_INVITATIONS;
		DISPLAYED_COMMUNITIES_INVITATIONS = {};
		local invitations = C_Club.GetInvitationsForSelf();
		for i, invitation in ipairs(invitations) do
			local clubId = invitation.club.clubId;
			DISPLAYED_COMMUNITIES_INVITATIONS[clubId] = previouslyDisplayedInvitations[clubId];
		end
		UpdateMicroButtons();
	elseif ( event == "STREAM_VIEW_MARKER_UPDATED" or event == "CLUB_INVITATION_ADDED_FOR_SELF" or event == "CLUB_INVITATION_REMOVED_FOR_SELF" ) then
		self:UpdateNotificationIcon(GuildMicroButton);
	elseif ( event == "CLUB_FINDER_COMMUNITY_OFFLINE_JOIN" ) then
		local newClubId = ...;
		self:SetNewClubId(newClubId);
		self.showOfflineJoinAlert = true;
		self:EvaluateAlertVisibility();
	elseif ( event == "CHAT_DISABLED_CHANGE_FAILED" or event == "CHAT_DISABLED_CHANGED" ) then
		self:UpdateNotificationIcon(GuildMicroButton);
	end
end

function GuildMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleGuildFrame();
	end
end

function GuildMicroButtonMixin:UpdateMicroButton()
	local factionGroup = UnitFactionGroup("player");

	if ( factionGroup == "Neutral" ) then
		self.factionGroup = factionGroup;
	else
		self.factionGroup = nil;
	end

	self:UpdateTabard();

	if ( IsCommunitiesUIDisabledByTrialAccount() or factionGroup == "Neutral" or Kiosk.IsEnabled() ) then
		self:Disable();
		if (Kiosk.IsEnabled()) then
			SetKioskTooltip(self);
		else
			self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		end
	elseif ( C_Club.IsEnabled() and not BNConnected() ) then
		self:Disable();
		self.disabledTooltip = BLIZZARD_COMMUNITIES_SERVICES_UNAVAILABLE;
	elseif ( C_Club.IsEnabled() and C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None ) then
		self:Disable();
		self.disabledTooltip = UNAVAILABLE;
	elseif ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		self:Enable();
	else
		self:Enable();
		if ( CommunitiesFrame_IsEnabled() ) then
			self.tooltipText = MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_GUILDTAB;
		elseif ( IsInGuild() ) then
			self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_GUILDTAB;
		else
			self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;
		end
	end

	self:UpdateNotificationIcon(self);
end

function GuildMicroButtonMixin:EvaluateAlertVisibility()
	if Kiosk.IsEnabled() then
		return false;
	end
	local alertShown = false;
	if (self.showOfflineJoinAlert) then
		alertShown = MainMenuMicroButton_ShowAlert(self, CLUB_FINDER_NEW_COMMUNITY_JOINED);
		if alertShown then
			self.showOfflineJoinAlert = false;
		end
	end
	return alertShown;
end
function GuildMicroButtonMixin:MarkCommunitiesInvitiationDisplayed(clubId)
	DISPLAYED_COMMUNITIES_INVITATIONS[clubId] = true;
	self:UpdateNotificationIcon(GuildMicroButton);
end

function GuildMicroButtonMixin:HasUnseenInvitations()
	local invitations = C_Club.GetInvitationsForSelf();
	for i, invitation in ipairs(invitations) do
		if not DISPLAYED_COMMUNITIES_INVITATIONS[invitation.club.clubId] then
			return true;
		end
	end

	return false;
end

function GuildMicroButtonMixin:UpdateNotificationIcon(self)
	if CommunitiesFrame_IsEnabled() and self:IsEnabled() then
		self.NotificationOverlay:SetShown(not C_SocialRestrictions.IsChatDisabled() and (self:HasUnseenInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()));
	else
		self.NotificationOverlay:SetShown(false);
	end
end

function GuildMicroButtonMixin:UpdateTabard(forceUpdate)
	if ( not self.needsUpdate and not forceUpdate ) then
		return;
	end
	-- switch textures if the guild has a custom tabard
	local emblemFilename = select(10, GetGuildLogoInfo());
	local tabardInfo = C_GuildInfo.GetGuildTabardInfo("player");
	if ( emblemFilename and tabardInfo) then
		LoadMicroButtonTextures(self, "GuildCommunities-GuildColor", tabardInfo.backgroundColor);
	else
		LoadMicroButtonTextures(self, "GuildCommunities");
	end
	self.needsUpdate = nil;
end

function GuildMicroButtonMixin:SetNewClubId(newClubId)
	self.newClubId = newClubId;
end

function GuildMicroButtonMixin:GetNewClubId()
	return self.newClubId;
end