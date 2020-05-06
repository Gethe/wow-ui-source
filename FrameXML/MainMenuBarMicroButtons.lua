
DISPLAYED_COMMUNITIES_INVITATIONS = DISPLAYED_COMMUNITIES_INVITATIONS or {};

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

local g_microButtonAlertsEnabledLocks = { };
local g_activeMicroButtonAlert;
local g_acknowledgedMicroButtonAlerts = {};
local g_microButtonAlertPriority = { };
local g_processAlertCloseCallback = true;

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
	local keyStringFormat = NORMAL_FONT_COLOR_CODE.."(%s)"..FONT_COLOR_CODE_CLOSE;
	local bindingAvailableFormat = "%s %s";
	return FormatBindingKeyIntoText(text, action, bindingAvailableFormat, keyStringFormat);
end

function LFDMicroButton_OnLoad(self)
	LoadMicroButtonTextures(self, "LFG");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER");
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT;

	self.disabledTooltip =	function()
		local canUse, failureReason = C_LFGInfo.CanPlayerUseLFD();
		if canUse then
			canUse, failureReason = C_LFGInfo.CanPlayerUsePVP();
		end
		return canUse and FEATURE_UNAVAILBLE_PLAYER_IS_NEUTRAL or failureReason;
	end

	self.IsActive =	function()
		local factionGroup = UnitFactionGroup("player");
		return not Kiosk.IsEnabled() and (C_LFGInfo.CanPlayerUseLFD() or C_LFGInfo.CanPlayerUsePVP()) and factionGroup ~= "Neutral";
	end
end

function MicroButton_OnEnter(self)
	if ( self:IsEnabled() or self.minLevel or self.disabledTooltip or self.factionGroup) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipText);
		if ( not self:IsEnabled() ) then
			if ( self.factionGroup == "Neutral" ) then
				GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				GameTooltip:Show();
			elseif ( self.minLevel ) then
				GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				GameTooltip:Show();
			elseif ( self.disabledTooltip ) then
				local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
				GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
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
	UpdateMicroButtons();
end

function SetKioskTooltip(frame)
	if (Kiosk.IsEnabled()) then
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
		CharacterMicroButton_SetPushed();
	else
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
		if not C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
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

	GuildMicroButton:UpdateTabard();
	if ( IsCommunitiesUIDisabledByTrialAccount() or factionGroup == "Neutral" or Kiosk.IsEnabled() ) then
		GuildMicroButton:Disable();
		if (Kiosk.IsEnabled()) then
			SetKioskTooltip(GuildMicroButton);
		else
			GuildMicroButton.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
		end
	elseif ( C_Club.IsEnabled() and not BNConnected() ) then
		GuildMicroButton:Disable();
		GuildMicroButton.disabledTooltip = BLIZZARD_COMMUNITIES_SERVICES_UNAVAILABLE;
	elseif ( C_Club.IsEnabled() and C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None ) then
		GuildMicroButton:Disable();
		GuildMicroButton.disabledTooltip = UNAVAILABLE;
	elseif ( GuildFrameIsOpen() ) then
		GuildMicroButton:Enable();
		GuildMicroButton:SetButtonState("PUSHED", true);
		GuildMicroButtonTabard:SetPoint("TOPLEFT", -1, -2);
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

	GuildMicroButton:UpdateNotificationIcon(GuildMicroButton);

	if ( PVEFrame and PVEFrame:IsShown() ) then
		LFDMicroButton:SetButtonState("PUSHED", true);
	else
		if not LFDMicroButton:IsActive() then
			if (Kiosk.IsEnabled()) then
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
		if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() and not Kiosk.IsEnabled()  ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			if (Kiosk.IsEnabled()) then
				SetKioskTooltip(AchievementMicroButton);
			end
			AchievementMicroButton:Disable();
		end
	end

	EJMicroButton_UpdateDisplay();

	if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
		CollectionsMicroButton:SetButtonState("PUSHED", true);
	else
		if ( not Kiosk.IsEnabled() ) then
			CollectionsMicroButton:Enable();
			CollectionsMicroButton:SetButtonState("NORMAL");
		else
			SetKioskTooltip(CollectionsMicroButton);
			CollectionsMicroButton:Disable();
		end
	end

	if ( StoreFrame and StoreFrame_IsShown() ) then
		StoreMicroButton:SetButtonState("PUSHED", true);
	else
		StoreMicroButton:SetButtonState("NORMAL");
	end

	StoreMicroButton:Show();
	HelpMicroButton:Hide();
	if ( C_StorePublic.IsDisabledByParentalControls() ) then
		StoreMicroButton.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS;
		StoreMicroButton:Disable();
	elseif ( Kiosk.IsEnabled() ) then
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
	elseif C_PlayerInfo.IsPlayerNPERestricted() then
		if Tutorials and Tutorials.Hide_StoreMicroButton and Tutorials.Hide_StoreMicroButton.IsActive then
			StoreMicroButton:Hide();
		end
	else
		StoreMicroButton.disabledTooltip = nil;
		StoreMicroButton:Enable();
	end
end

function MicroButtonPulse(self, duration)
	if not MainMenuMicroButton_AreAlertsEnabled() then
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

function AchievementMicroButton_OnEvent(self, event, ...)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end

GuildMicroButtonMixin = {};

function GuildMicroButtonMixin:OnLoad() 
	LoadMicroButtonTextures(self, "Socials");
	self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
	self.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("STREAM_VIEW_MARKER_UPDATED");
	self:RegisterEvent("INITIAL_CLUBS_LOADED");
	self:RegisterEvent("CLUB_INVITATION_ADDED_FOR_SELF");
	self:RegisterEvent("CLUB_INVITATION_REMOVED_FOR_SELF");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CLUB_FINDER_COMMUNITY_OFFLINE_JOIN");
	self:UpdateTabard(true);
	if ( IsCommunitiesUIDisabledByTrialAccount() ) then
		self:Disable();
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
	end
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
end 

function GuildMicroButtonMixin:OnEvent(event, ...)
	if (Kiosk.IsEnabled()) then
		return;
	end
	if (event == "PLAYER_ENTERING_WORLD") then 
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
		GuildMicroButtonTabard.needsUpdate = true;
		UpdateMicroButtons();
	elseif ( event == "BN_DISCONNECTED" or event == "BN_CONNECTED" ) then
		UpdateMicroButtons();
	elseif ( event == "INITIAL_CLUBS_LOADED" ) then
		self:UpdateNotificationIcon(GuildMicroButton);
		previouslyDisplayedInvitations = DISPLAYED_COMMUNITIES_INVITATIONS;
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
	end
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
	elseif (self:ShouldShowAlert()) then 
		alertShown = MainMenuMicroButton_ShowAlert(self, CLUB_FINDER_NEW_FEATURE_TUTORIAL, LE_FRAME_TUTORIAL_ACCCOUNT_CLUB_FINDER_NEW_FEATURE, "closedInfoFramesAccountWide");
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
		self.NotificationOverlay:SetShown(self:HasUnseenInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages());
	else
		self.NotificationOverlay:SetShown(false);
	end
end

function GuildMicroButtonMixin:ShouldShowAlert()
	return C_ClubFinder.IsEnabled() and (not CommunitiesFrame or not CommunitiesFrame:IsShown()) and 
	not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCCOUNT_CLUB_FINDER_NEW_FEATURE) and not IsTrialAccount() and not IsVeteranTrialAccount();
end

function GuildMicroButtonMixin:UpdateTabard(forceUpdate)
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

function GuildMicroButtonMixin:SetNewClubId(newClubId)
	self.newClubId = newClubId;
end

function GuildMicroButtonMixin:GetNewClubId()
	return self.newClubId;
end

CharacterMicroButtonMixin = {};

function CharacterMicroButton_OnLoad(self)
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");
	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:RegisterEvent("ADDON_LOADED");
	LoadMicroButtonTextures(self, "Character");
end

function CharacterMicroButton_OnMouseDown(self)
	if ( self.down ) then
		self.down = nil;
		ToggleCharacter("PaperDollFrame");
	else
		CharacterMicroButton_SetPushed();
		self.down = 1;
	end
end

function CharacterMicroButton_OnMouseUp(self)
	if ( self.down ) then
		self.down = nil;
		if ( self:IsMouseOver() ) then
			ToggleCharacter("PaperDollFrame");
		end
		UpdateMicroButtons();
	elseif ( self:GetButtonState() == "NORMAL" ) then
		CharacterMicroButton_SetPushed();
		self.down = 1;
	else
		CharacterMicroButton_SetNormal();
		self.down = 1;
	end
end

function CharacterMicroButton_OnEnter(self)
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);
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
		self:EvaluateAlertVisibility();
	elseif ( event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" ) then
		CharacterMicroButton_UpdatePulsing(self);
		self:EvaluateAlertVisibility();
	elseif ( event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" ) then
		CharacterMicroButton_UpdatePulsing(self);
		self:EvaluateAlertVisibility();
	elseif event == "ADDON_LOADED" then
		local addOnName = ...;
		if addOnName == "Blizzard_AzeriteUI" then
			AzeriteEmpoweredItemUI:RegisterCallback(AzeriteEmpoweredItemUIMixin.Event.OnShow, self.EvaluateAlertVisibility, self);
			AzeriteEmpoweredItemUI:RegisterCallback(AzeriteEmpoweredItemUIMixin.Event.OnHide, self.EvaluateAlertVisibility, self);
		elseif addOnName == "Blizzard_AzeriteEssenceUI" then
			AzeriteEssenceUI:RegisterCallback(AzeriteEssenceUIMixin.Event.OnShow, self.EvaluateAlertVisibility, self);
			AzeriteEssenceUI:RegisterCallback(AzeriteEssenceUIMixin.Event.OnHide, self.EvaluateAlertVisibility, self);
		end
	end
end

function CharacterMicroButtonMixin:ShouldShowAzeriteItemAlert()
	if AzeriteEmpoweredItemUI and AzeriteEmpoweredItemUI:IsShown() then
		return false;
	end

	if self:GetButtonState() == "PUSHED" then
		return false;
	end

	if IsPlayerInWorld() and AzeriteUtil.DoEquippedItemsHaveUnselectedPowers() then
		return true;
	end

	return false;
end

function CharacterMicroButtonMixin:ShouldShowAzeriteEssenceSlotAlert()
	if AzeriteEssenceUI and AzeriteEssenceUI:IsShown() then
		return false;
	end

	if self:GetButtonState() == "PUSHED" then
		return false;
	end

	if IsPlayerInWorld() and AzeriteEssenceUtil.ShouldShowEmptySlotHelptip() then
		return true;
	end

	return false;
end

function CharacterMicroButtonMixin:ShouldShowAzeriteEssenceSwapAlert()
	if AzeriteEssenceUI and AzeriteEssenceUI:IsShown() then
		return false;
	end

	if self:GetButtonState() == "PUSHED" then
		return false;
	end

	return AzeriteEssenceUtil.ShouldShowEssenceSwapTutorial();
end

function CharacterMicroButtonMixin:EvaluateAlertVisibility()
	if self:ShouldShowAzeriteEssenceSlotAlert() then
		if MainMenuMicroButton_ShowAlert(self, CHARACTER_SHEET_MICRO_BUTTON_AZERITE_ESSENCE_SLOT_AVAILABLE) then
			return true;
		end
	end

	if not self.seenAzeriteEssenceSwapAlert and self:ShouldShowAzeriteEssenceSwapAlert() then
		if MainMenuMicroButton_ShowAlert(self, CHARACTER_SHEET_MICRO_BUTTON_AZERITE_ESSENCE_CHANGE_ESSENCES) then
			self.seenAzeriteEssenceSwapAlert = true;
			AzeriteEssenceUtil.SetEssenceSwapTutorialSeen();
			return true;
		end
	end

	if self:ShouldShowAzeriteItemAlert() then
		if MainMenuMicroButton_ShowAlert(self, CHARACTER_SHEET_MICRO_BUTTON_AZERITE_AVAILABLE) then
			return true;
		end
	end

	return false;
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
	CharacterMicroButton:SetButtonState("PUSHED", true);
	CharacterMicroButton:EvaluateAlertVisibility();
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
	CharacterMicroButton:SetButtonState("NORMAL");
	CharacterMicroButton_UpdatePulsing(CharacterMicroButton);
	CharacterMicroButton:EvaluateAlertVisibility();
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", true);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end

function MainMenuMicroButton_Init()
	g_microButtonAlertPriority = { CollectionsMicroButton, TalentMicroButton, CharacterMicroButton, EJMicroButton, GuildMicroButton };
end

function MainMenuMicroButton_SetAlertsEnabled(enabled, reason)
	if not reason then
		error("Must provide a reason");
	end
	if enabled then
		g_microButtonAlertsEnabledLocks[reason] = nil;
	else
		g_microButtonAlertsEnabledLocks[reason] = true;
	end
	MainMenuMicroButton_UpdateAlertsEnabled();
end

function MainMenuMicroButton_UpdateAlertsEnabled(microButtonToSkip)
	if MainMenuMicroButton_AreAlertsEnabled() then
		-- If anything is shown, leave it in that state
		if g_activeMicroButtonAlert then
			return;
		end
		-- Nothing shown, try evaluating its visibility
		for priority, microButton in ipairs(g_microButtonAlertPriority) do
			if microButtonToSkip ~= microButton then
				if microButton:EvaluateAlertVisibility() then
					return;
				end
			end
		end
	else
		if g_activeMicroButtonAlert then
			HelpTip:HideAllSystem("MicroButtons");
		end

		for flashingButton in pairs(g_flashingMicroButtons) do
			MicroButtonPulseStop(flashingButton);
		end

		g_flashingMicroButtons = {};
	end
	-- wipe acknowledgements so future events can still show the appropriate ones
	wipe(g_acknowledgedMicroButtonAlerts);
end

function MainMenuMicroButton_AreAlertsEnabled()
	return not next(g_microButtonAlertsEnabledLocks);
end

function MainMenuMicroButton_GetAlertPriority(microButton)
	for priority, frame in ipairs(g_microButtonAlertPriority) do
		if frame == microButton then
			return priority;
		end
	end
	return math.huge;
end

local function MainMenuMicroButton_OnAlertClose(acknowledged, microButton)
	if not g_processAlertCloseCallback then
		return;
	end
	if acknowledged then
		g_acknowledgedMicroButtonAlerts[microButton] = true;
	end
	g_activeMicroButtonAlert = nil;
	MainMenuMicroButton_UpdateAlertsEnabled(microButton);
end

function MainMenuMicroButton_ShowAlert(microButton, text, tutorialIndex, cvarBitfield)
	if not MainMenuMicroButton_AreAlertsEnabled() then
		return false;
	end

	if g_acknowledgedMicroButtonAlerts[microButton] then
		return false;
	end

	cvarBitfield = cvarBitfield or "closedInfoFrames";
	if tutorialIndex and GetCVarBitfield(cvarBitfield, tutorialIndex) then
		return false;
	end

	if g_activeMicroButtonAlert then
		local visiblePriority = MainMenuMicroButton_GetAlertPriority(g_activeMicroButtonAlert);
		local thisPriority = MainMenuMicroButton_GetAlertPriority(microButton);
		if visiblePriority < thisPriority then
			-- Higher priority is shown
			return false;
		else
			-- Lower priority alert is visible, kill it
			g_processAlertCloseCallback = false;
			HelpTip:HideAllSystem("MicroButtons");
			g_processAlertCloseCallback = true;
		end
	end

	local helpTipInfo = {
		text = text,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		system = "MicroButtons",
		onHideCallback = MainMenuMicroButton_OnAlertClose,
		callbackArg = microButton,
		autoHorizontalSlide = true,
	};
	if tutorialIndex then
		helpTipInfo.cvarBitfield = cvarBitfield;
		helpTipInfo.bitfieldFlag = tutorialIndex;
	end

	if HelpTip:Show(UIParent, helpTipInfo, microButton) then
		g_activeMicroButtonAlert = microButton;
	end

	return true;
end

function MainMenuMicroButton_HideAlert(microButton)
	if g_activeMicroButtonAlert == microButton then
		HelpTip:HideAllSystem("MicroButtons");
	end
end

TalentMicroButtonMixin = {};

function TalentMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Talents");
	self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	self.newbieText = NEWBIE_TOOLTIP_TALENTS;

	self.disabledTooltip =	function()
		local _, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
		return failureReason;
	end

	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
end

local TALENT_FRAME_PRIORITIES =
{
	TALENT_MICRO_BUTTON_SPEC_TUTORIAL = 1,
	TALENT_MICRO_BUTTON_TALENT_TUTORIAL = 2,
	TALENT_MICRO_BUTTON_UNSPENT_TALENTS = 3,
	TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT = 4,
	TALENT_MICRO_BUTTON_NEW_PVP_TALENT = 5,
}

local LOWEST_TALENT_FRAME_PRIORITY = 1000;

function TalentMicroButtonMixin:HasTalentAlertToShow()
	if not IsPlayerInWorld() then
		return nil, LOWEST_TALENT_FRAME_PRIORITY;
	end

	local canUseTalentSpecUI = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
	if self.canUseTalentSpecUI == nil then
		self.canUseTalentSpecUI = canUseTalentSpecUI;
	end

	local canUseTalentUI = C_SpecializationInfo.CanPlayerUseTalentUI();
	if self.canUseTalentUI == nil then
		self.canUseTalentUI = canUseTalentUI;
	end

	local alert;

	if not self.canUseTalentSpecUI and canUseTalentSpecUI then
		alert = "TALENT_MICRO_BUTTON_SPEC_TUTORIAL";
	elseif not self.canUseTalentUI and canUseTalentUI then
		alert = "TALENT_MICRO_BUTTON_TALENT_TUTORIAL";
	elseif canUseTalentUI and not AreTalentsLocked() and GetNumUnspentTalents() > 0 then
		alert = "TALENT_MICRO_BUTTON_UNSPENT_TALENTS";
	end

	self.canUseTalentSpecUI = canUseTalentSpecUI;
	self.canUseTalentUI = canUseTalentUI;

	return _G[alert], TALENT_FRAME_PRIORITIES[alert] or LOWEST_TALENT_FRAME_PRIORITY;
end

function TalentMicroButtonMixin:HasPvpTalentAlertToShow()
	if not IsPlayerInWorld() or not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
		return nil, LOWEST_TALENT_FRAME_PRIORITY;
	end

	local alert;

	local hasEmptySlot, hasNewTalent = C_SpecializationInfo.GetPvpTalentAlertStatus();
	if (hasEmptySlot) then
		alert = "TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT";
	elseif (hasNewTalent) then
		alert = "TALENT_MICRO_BUTTON_NEW_PVP_TALENT";
	end

	return _G[alert], TALENT_FRAME_PRIORITIES[alert] or LOWEST_TALENT_FRAME_PRIORITY;
end

function TalentMicroButtonMixin:EvaluateAlertVisibility()
	local alertText, alertPriority = self:HasTalentAlertToShow();
	local pvpAlertText, pvpAlertPriority = self:HasPvpTalentAlertToShow();

	if not alertText or pvpAlertPriority < alertPriority then
		-- pvpAlert is higher priority, use that instead
		alertText = pvpAlertText;
	end

	if not alertText then
		MicroButtonPulseStop(self);
		return false;
	end

	if not PlayerTalentFrame or not PlayerTalentFrame:IsShown() then
		if MainMenuMicroButton_ShowAlert(self, alertText) then
			MicroButtonPulse(self);
			TalentMicroButton.suggestedTab = 2;
			return true;
		end
	end
	
    TalentMicroButton.suggestedTab = nil;
	return false;
end

--Talent button specific functions
function TalentMicroButtonMixin:OnEvent(event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LEVEL_CHANGED" ) then
		self:EvaluateAlertVisibility();
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "HONOR_LEVEL_UPDATE" ) then
		UpdateMicroButtons();
		self:EvaluateAlertVisibility();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

function TalentMicroButtonMixin:OnClick(self)
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
			alertShown = MainMenuMicroButton_ShowAlert(self, numMountsNeedingFanfare + numPetsNeedingFanfare > 1 and COLLECTION_UNOPENED_PLURAL or COLLECTION_UNOPENED_SINGULAR);
			if alertShown then
				MicroButtonPulse(self);
				SafeSetCollectionJournalTab(numMountsNeedingFanfare > 0 and 1 or 2);
			end
		end
		self.lastNumMountsNeedingFanfare = numMountsNeedingFanfare;
		self.lastNumPetsNeedingFanfare = numPetsNeedingFanfare;
		return alertShown;
	end

	function CollectionsMicroButton_OnLoad(self)
		LoadMicroButtonTextures(self, "Mounts");
		SetDesaturation(self:GetDisabledTexture(), true);
		self:RegisterEvent("HEIRLOOMS_UPDATED");
		self:RegisterEvent("PET_JOURNAL_NEW_BATTLE_SLOT");
		self:RegisterEvent("TOYS_UPDATED");
		self:RegisterEvent("COMPANION_LEARNED");
		self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	function CollectionsMicroButton_OnEvent(self, event, ...)
		if CollectionsJournal and CollectionsJournal:IsShown() then
			return;
		end

		if ( event == "HEIRLOOMS_UPDATED" ) then
			local itemID, updateReason = ...;
			if itemID and updateReason == "NEW" then
				if MainMenuMicroButton_ShowAlert(CollectionsMicroButton, HEIRLOOMS_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL) then
					local tabIndex = 4;
					CollectionsMicroButton_SetAlert(tabIndex);
				end
			end
		elseif ( event == "PET_JOURNAL_NEW_BATTLE_SLOT" ) then
			if MainMenuMicroButton_ShowAlert(CollectionsMicroButton, COMPANIONS_MICRO_BUTTON_NEW_BATTLE_SLOT) then
				local tabIndex = 2;
				CollectionsMicroButton_SetAlert(tabIndex);
			end
		elseif ( event == "TOYS_UPDATED" ) then
			local itemID, new = ...;
			if itemID and new then
				if MainMenuMicroButton_ShowAlert(CollectionsMicroButton, TOYBOX_MICRO_BUTTON_SPEC_TUTORIAL, LE_FRAME_TUTORIAL_TOYBOX) then
					local tabIndex = 3;
					CollectionsMicroButton_SetAlert(tabIndex);
				end
			end
		elseif ( event == "COMPANION_LEARNED" or event == "PLAYER_ENTERING_WORLD" or event == "PET_JOURNAL_LIST_UPDATE" ) then
			self:EvaluateAlertVisibility();
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

	function CollectionsMicroButton_OnEnter(self)
		self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS");
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipText);
	end

	function CollectionsMicroButton_OnClick(self)
		ToggleCollectionsJournal();
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
	local alertShown = false;
	if self.playerEntered and self.varsLoaded and self.zoneEntered then
		if self:IsEnabled() then
			local showAlert = not Kiosk.IsEnabled() and not GetCVarBool("hideAdventureJournalAlerts");
			if( showAlert ) then
				-- display alert if the player hasn't opened the journal for a long time
				local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"));
				if ( GetServerTime() - lastTimeOpened > EJ_ALERT_TIME_DIFF ) then
					alertShown = MainMenuMicroButton_ShowAlert(self, AJ_MICRO_BUTTON_ALERT_TEXT);
					if alertShown then
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
	return alertShown;
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
		if ( playerLevel == GetMaxLevelForPlayerExpansion() and ((not self.lastEvaluatedSpec or self.lastEvaluatedSpec ~= spec) or (not self.lastEvaluatedIlvl or self.lastEvaluatedIlvl < ilvl))) then
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
		local inKioskMode = Kiosk.IsEnabled();
		local disabled = inKioskMode or not C_AdventureJournal.CanBeShown();
		if ( disabled ) then
			frame:Disable();
			frame.disabledTooltip = inKioskMode and ERR_SYSTEM_DISABLED or FEATURE_NOT_YET_AVAILABLE;
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
	if (Kiosk.IsEnabled()) then
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
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
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

QuestLogMicroButtonMixin = {};

function QuestLogMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Quest");
	self:UpdateTooltipText();
end

function QuestLogMicroButtonMixin:OnEvent(event, ...)
	if event == "UPDATE_BINDINGS" then
		self:UpdateTooltipText();
	end
end

function QuestLogMicroButtonMixin:UpdateTooltipText()
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG");
	self.newbieText = NEWBIE_TOOLTIP_QUESTLOG;
end

function QuestLogMicroButtonMixin:OnClick()
	ToggleQuestLog();
end