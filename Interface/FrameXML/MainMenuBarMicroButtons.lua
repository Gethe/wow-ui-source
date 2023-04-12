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

MicroMenuPositionEnum = {
	BottomLeft = 1;
	BottomRight = 2;
	TopLeft = 3;
	TopRight = 4;
};

DISPLAYED_COMMUNITIES_INVITATIONS = {};
local PERFORMANCE_BAR_UPDATE_INTERVAL = 1;
local EJ_ALERT_TIME_DIFF = 60*60*24*7*2; -- 2 weeks

local g_microButtonAlertsEnabledLocks = {};
local g_activeMicroButtonAlert;
local g_acknowledgedMicroButtonAlerts = {};
local g_microButtonAlertPriority = {};
local g_processAlertCloseCallback = true;
local g_flashingMicroButtons = {};

local LOWEST_TALENT_FRAME_PRIORITY = 1000;
local TALENT_FRAME_PRIORITIES =
{
	TALENT_MICRO_BUTTON_SPEC_TUTORIAL = 1,
	TALENT_MICRO_BUTTON_TALENT_TUTORIAL = 2,
	TALENT_MICRO_BUTTON_NO_SPEC = 3,
	TALENT_MICRO_BUTTON_UNSPENT_TALENTS = 4,
	TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT = 5,
	TALENT_MICRO_BUTTON_NEW_PVP_TALENT = 6,
}

local EJMicroButtonEvents = {
	"NEW_RUNEFORGE_POWER_ADDED",
};

local PERFORMANCEBAR_LOW_LATENCY = 300;
local PERFORMANCEBAR_MEDIUM_LATENCY = 600;

--Textures
function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	local prefix = "UI-HUD-MicroMenu-";
	self:SetNormalAtlas(prefix..name.."-Up");
	self:SetPushedAtlas(prefix..name.."-Down");
	self:SetDisabledAtlas(prefix..name.."-Disabled");
	self:SetHighlightAtlas(prefix..name.."-Mouseover");
end

--Tooltips
function MicroButtonTooltipText(text, action)
	local keyStringFormat = NORMAL_FONT_COLOR_CODE.."(%s)"..FONT_COLOR_CODE_CLOSE;
	local bindingAvailableFormat = "%s %s";
	return FormatBindingKeyIntoText(text, action, bindingAvailableFormat, keyStringFormat);
end

function SetKioskTooltip(frame)
	if (Kiosk.IsEnabled()) then
		frame.minLevel = nil;
		frame.disabledTooltip = ERR_SYSTEM_DISABLED;
	end
end

--Positioning and visual states
function ResetMicroMenuPosition()
	MicroMenu:SetParent(MicroMenuContainer);
	MicroMenu.stride = MicroMenu.numButtons;

	local forceFullUpdate = true;
	EditModeManagerFrame:UpdateSystem(MicroMenuContainer, forceFullUpdate);

	UpdateMicroButtons();
end

function OverrideMicroMenuPosition(parent, anchor, anchorTo, relAnchor, x, y, isStacked)
	MicroMenu:SetScale(1);
	MicroMenu:SetParent(parent);

	MicroMenu.stride = (isStacked and MicroMenu.numButtons / 2 or MicroMenu.numButtons);
	MicroMenu.isHorizontal = true;
	MicroMenu.layoutFramesGoingRight = true;
	MicroMenu.layoutFramesGoingUp = false;
	MicroMenu:Layout();

	MicroMenu:ClearAllPoints();
	MicroMenu:SetPoint(anchor, anchorTo, relAnchor, x, y);

	UpdateMicroButtons();
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
		CharacterMicroButton:SetPushed();
	else
		CharacterMicroButton:SetNormal();
	end

	if ( SpellBookFrame and SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", true);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if (ClassTalentFrame and ClassTalentFrame:IsShown()) then
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
		or ( SettingsPanel:IsShown())
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetPushed();
	else
		MainMenuMicroButton:SetNormal();
	end

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
	elseif ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		GuildMicroButton:Enable();
		GuildMicroButton:SetButtonState("PUSHED", true);
	else
		GuildMicroButton:Enable();
		GuildMicroButton:SetButtonState("NORMAL");
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

	EJMicroButton:UpdateDisplay();

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

			if ( HelpFrame and HelpFrame:IsShown() ) then
				HelpMicroButton:SetButtonState("PUSHED", true);
			else
				HelpMicroButton:SetButtonState("NORMAL");
			end
		else
			StoreMicroButton.disabledTooltip = BLIZZARD_STORE_ERROR_UNAVAILABLE;
			StoreMicroButton:Disable();
		end
	elseif C_PlayerInfo.IsPlayerNPERestricted() then
		local tutorials = TutorialLogic and TutorialLogic.Tutorials;
		if tutorials and tutorials.UI_Watcher and tutorials.UI_Watcher.IsActive then
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
	UIFrameFlash(self.FlashBorder, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
	UIFrameFlash(self.FlashContent, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
end

function MicroButtonPulseStop(self)
	UIFrameFlashStop(self.FlashBorder);
	UIFrameFlashStop(self.FlashContent);
	g_flashingMicroButtons[self] = nil;
end

function MicroButton_KioskModeDisable(self)
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
end

--Alerts
function MainMenuMicroButton_Init()
	g_microButtonAlertPriority = { CollectionsMicroButton, SpellBookMicroButton, TalentMicroButton, EJMicroButton, GuildMicroButton };
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

--Mixins (In order of placement)
MainMenuBarMicroButtonMixin = {};

function MainMenuBarMicroButtonMixin:OnEnter()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( self:IsEnabled() or self.minLevel or self.disabledTooltip or self.factionGroup) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, self.tooltipText);
			if ( not self:IsEnabled() ) then
				if ( self.factionGroup == "Neutral" ) then
					GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				elseif ( self.minLevel ) then
					GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				elseif ( self.disabledTooltip ) then
					local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
					GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				end
			end
			GameTooltip:Show();
		end
	end
end

function MainMenuBarMicroButtonMixin:OnShow()
	MicroMenuContainer:Layout();
end

function MainMenuBarMicroButtonMixin:OnHide()
	MicroMenuContainer:Layout();
end

CharacterMicroButtonMixin = {};

function CharacterMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "CharacterInfo");
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
end

function CharacterMicroButtonMixin:OnMouseDown()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( self.down ) then
			self.down = nil;
			ToggleCharacter("PaperDollFrame");
		else
			self:SetPushed();
			self.down = 1;
		end
	end
end

function CharacterMicroButtonMixin:OnMouseUp(button)
	if ( KeybindFrames_InQuickKeybindMode() ) then
		self:QuickKeybindButtonOnClick(button);
	else
		if ( self.down ) then
			self.down = nil;
			if ( self:IsMouseOver() ) then
				ToggleCharacter("PaperDollFrame");
			end
			UpdateMicroButtons();
		elseif ( self:GetButtonState() == "NORMAL" ) then
			self:SetPushed();
			self.down = 1;
		else
			self:SetNormal();
			self.down = 1;
		end
	end
end

function CharacterMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	end
end

function CharacterMicroButtonMixin:SetPushed()
	CharacterMicroButton:SetButtonState("PUSHED", true);
end

function CharacterMicroButtonMixin:SetNormal()
	CharacterMicroButton:SetButtonState("NORMAL");
end


SpellbookMicroButtonMixin = {};

function SpellbookMicroButtonMixin:OnLoad()
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	LoadMicroButtonTextures(self, "SpellbookAbilities");
	self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK");
end

function SpellbookMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		HelpTip:Hide(UIParent, SPEC_CHANGED_HAS_NEW_ABILITIES);

		if self.jumpToSpellID then
			SpellBookFrame_OpenToSpell(self.jumpToSpellID, false, nil);
			self.jumpToSpellID = nil;
		else
			ToggleSpellBook(BOOKTYPE_SPELL);
		end
	end
end

function SpellbookMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK");
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED") then
		self:EvaluateAlertVisibility();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self.oldSpecID = GetSpecialization();
	end
end

function SpellbookMicroButtonMixin:EvaluateAlertVisibility()
	local newSpecID = GetSpecialization();
	local playerAtMax = UnitLevel("player") >= GetMaxLevelForLatestExpansion();
	local specUsedAlready = GetCVarBitfield("maxLevelSpecsUsed", newSpecID);

	--Makes sure that alerts are only shown when the spec is changed and not when talent is changed. Also makes sure the player hasn't switched to the spec at max already
	if newSpecID == self.oldSpecID or (playerAtMax and specUsedAlready) then
		return;
	end

	if playerAtMax and not specUsedAlready then
		SetCVarBitfield("maxLevelSpecsUsed", newSpecID, true);
	end

	self.oldSpecID = newSpecID;

	local alertText = SPEC_CHANGED_HAS_NEW_ABILITIES;
	local hasUndraggedSpell, firstUndraggedId = SpellBookFrame_SpecHasUnDraggedSpells();
	if hasUndraggedSpell then
		if not SpellBookFrame or not SpellBookFrame:IsShown() then
			if MainMenuMicroButton_ShowAlert(self, alertText) then
				MicroButtonPulse(self);
				self.jumpToSpellID = firstUndraggedId;
			end
		elseif SpellBookFrame:IsShown() then
			SpellBookFrame_OpenToSpell(firstUndraggedId, false, nil);
			self.jumpToSpellID = nil;
		end
	end

	return false;
end


TalentMicroButtonMixin = {};

function TalentMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "SpecTalents");
	self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	self.newbieText = NEWBIE_TOOLTIP_TALENTS;

	self.disabledTooltip =	function()
		local _, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
		return failureReason;
	end

	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
end

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

	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES) and canUseTalentUI and C_ClassTalents.HasUnspentTalentPoints() then
		alert = "TALENT_MICRO_BUTTON_UNSPENT_TALENTS";
	end

	self.canUseTalentSpecUI = canUseTalentSpecUI;
	self.canUseTalentUI = canUseTalentUI;

	return _G[alert], TALENT_FRAME_PRIORITIES[alert] or LOWEST_TALENT_FRAME_PRIORITY;
end

function TalentMicroButtonMixin:HasPvpTalentAlertToShow()
	local isInterestedInPvP = C_PvP.IsWarModeDesired() or PVPUtil.IsInActiveBattlefield();
	if not isInterestedInPvP or not IsPlayerInWorld() or not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
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

	MainMenuMicroButton_HideAlert(self);
	MicroButtonPulseStop(self);

	if not alertText then
		return false;
	end

	if not ClassTalentFrame or not ClassTalentFrame:IsShown() then
		if MainMenuMicroButton_ShowAlert(self, alertText) then
			MicroButtonPulse(self);
			if IsPlayerInitialSpec() then
				TalentMicroButton.suggestedTab = 1;
			else
				TalentMicroButton.suggestedTab = 2;
			end
			return true;
		end
	end

    TalentMicroButton.suggestedTab = nil;
	return false;
end

function TalentMicroButtonMixin:OnEvent(event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LEVEL_CHANGED" or event == "UPDATE_BATTLEFIELD_STATUS" ) then
		self:EvaluateAlertVisibility();
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "HONOR_LEVEL_UPDATE" ) then
		UpdateMicroButtons();
		self:EvaluateAlertVisibility();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

function TalentMicroButtonMixin:OnClick(button, down)
    if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleTalentFrame(self.suggestedTab);
	end
end


AchievementMicroButtonMixin = {};

function AchievementMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Achievements");
	self:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST");
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	self.newbieText = NEWBIE_TOOLTIP_ACHIEVEMENT;
	--Just used for display. But we know that it will become available by level 10 due to the level 10 achievement.
	self.minLevel = Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL;
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
end

function AchievementMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleAchievementFrame();
	end
end

function AchievementMicroButtonMixin:OnEvent(event, ...)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end


QuestLogMicroButtonMixin = {};

function QuestLogMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Questlog");
	self:UpdateTooltipText();
end

function QuestLogMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self:UpdateTooltipText();
	end
end

function QuestLogMicroButtonMixin:UpdateTooltipText()
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG");
	self.newbieText = NEWBIE_TOOLTIP_QUESTLOG;
end

function QuestLogMicroButtonMixin:OnClick(button)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleQuestLog();
	end
end


GuildMicroButtonMixin = {};

function GuildMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "GuildCommunities");
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
	if ( IsCommunitiesUIDisabledByTrialAccount() ) then
		self:Disable();
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
	end
	if (Kiosk.IsEnabled()) then
		self:Disable();
	end
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

function GuildMicroButtonMixin:SetNewClubId(newClubId)
	self.newClubId = newClubId;
end

function GuildMicroButtonMixin:GetNewClubId()
	return self.newClubId;
end


LFDMicroButtonMixin = {};

function LFDMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Groupfinder");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER");

	self.disabledTooltip =	function()
		local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
		return canUse and FEATURE_UNAVAILBLE_PLAYER_IS_NEUTRAL or failureReason;
	end

	self.IsActive =	function()
		local factionGroup = UnitFactionGroup("player");
		local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
		return canUse and factionGroup ~= "Neutral" and not Kiosk.IsEnabled();
	end
end

function LFDMicroButtonMixin:OnEvent(event, ...)
	if ( Kiosk.IsEnabled() ) then
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER");
	end
	UpdateMicroButtons();
end

function LFDMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		PVEFrame_ToggleFrame();
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

function CollectionMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Collections");
	SetDesaturation(self:GetDisabledTexture(), true);
	self:RegisterEvent("HEIRLOOMS_UPDATED");
	self:RegisterEvent("PET_JOURNAL_NEW_BATTLE_SLOT");
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
	LoadMicroButtonTextures(self, "AdventureGuide");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL;

	--events that can trigger a refresh of the adventure journal
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
end

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

				self:UpdateAlerts(true);
			end
			self:UpdateLastEvaluations();
		end
	end

	if not alertShown and self.runeforgePowerAdded and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_RUNEFORGE_LEGENDARY_POWER) then
		alertShown = MainMenuMicroButton_ShowAlert(self, FIRST_RUNEFORGE_LEGENDARY_POWER_TUTORIAL, LE_FRAME_TUTORIAL_FIRST_RUNEFORGE_LEGENDARY_POWER);
		if alertShown then
			MicroButtonPulse(EJMicroButton);
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

function EJMicroButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, EJMicroButtonEvents);

	MicroButton_KioskModeDisable(self);
end

function EJMicroButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, EJMicroButtonEvents);
end

function EJMicroButtonMixin:OnEvent(event, ...)
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
			if ( self:IsEnabled() ) then
				C_AdventureJournal.UpdateSuggestions(true);
			end
		end
	elseif ( event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" ) then
		local playerLevel = UnitLevel("player");
		local spec = GetSpecialization();
		local ilvl = GetAverageItemLevel();
		if ( playerLevel == GetMaxLevelForPlayerExpansion() and ((not self.lastEvaluatedSpec or self.lastEvaluatedSpec ~= spec) or (not self.lastEvaluatedIlvl or self.lastEvaluatedIlvl < ilvl))) then
			self.lastEvaluatedSpec = spec;
			self.lastEvaluatedIlvl = ilvl;
			if ( self:IsEnabled() ) then
				C_AdventureJournal.UpdateSuggestions(false);
			end
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		self.zoneEntered = true;
	elseif ( event == "NEW_RUNEFORGE_POWER_ADDED" ) then
		local powerID = ...;
		self.runeforgePowerAdded = powerID;
		self:EvaluateAlertVisibility();
	end

	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
		if self.playerEntered and self.varsLoaded and self.zoneEntered then
			self:UpdateDisplay();
			if self:IsEnabled() then
				C_AdventureJournal.UpdateSuggestions();
				self:EvaluateAlertVisibility();
			end
		end
	end
end

function EJMicroButtonMixin:UpdateNewAdventureNotice()
	if ( self:IsEnabled() and (not EncounterJournal or not EncounterJournal:IsShown()) ) then
		self.FlashBorder:Show();
	end
end

function EJMicroButtonMixin:ClearNewAdventureNotice()
	self.FlashBorder:Hide();
end

function EJMicroButtonMixin:UpdateDisplay()
	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		self:SetButtonState("PUSHED", true);
	else
		local inKioskMode = Kiosk.IsEnabled();
		local disabled = inKioskMode or not C_AdventureJournal.CanBeShown();
		if ( disabled ) then
			self:Disable();
			self.disabledTooltip = inKioskMode and ERR_SYSTEM_DISABLED or FEATURE_NOT_YET_AVAILABLE;
			self:ClearNewAdventureNotice();
		else
			self:Enable();
			self:SetButtonState("NORMAL");
		end
	end
end

function EJMicroButtonMixin:UpdateAlerts(flag)
	if ( flag ) then
		self:RegisterEvent("UNIT_LEVEL");
		self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
		if (self:IsEnabled()) then
			C_AdventureJournal.UpdateSuggestions(false);
		end
	else
		self:UnregisterEvent("UNIT_LEVEL");
		self:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
		self:ClearNewAdventureNotice()
	end
end

function EJMicroButtonMixin:OnClick(button, down)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleEncounterJournal();
	end
end

function EJMicroButtonMixin:ShouldShowPowerTab(button, down)
	return (self.runeforgePowerAdded ~= nil) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_RUNEFORGE_LEGENDARY_POWER), self.runeforgePowerAdded;
end


StoreMicroButtonMixin = {};

function StoreMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Shop");
	self.tooltipText = BLIZZARD_STORE;
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

HelpMicroButtonMixin = {};

function HelpMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "GameMenu");
end


MainMenuMicroButtonMixin = {};

function MainMenuMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "GameMenu");
	self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU");

	self.updateInterval = 0;
	self:RegisterForClicks("AnyUp");
end

function MainMenuMicroButtonMixin:OnUpdate(elapsed)
	if ( self.updateInterval > 0 ) then
		self.updateInterval = self.updateInterval - elapsed;
	else
		self.updateInterval = PERFORMANCE_BAR_UPDATE_INTERVAL;
		local status = GetFileStreamingStatus();
		if ( status == 0 ) then
			status = (GetBackgroundLoadingStatus()~=0) and 1 or 0;
		end

		local prefix = "UI-HUD-MicroMenu-";
		local disabledPostfix = (status == 0) and "-Disabled" or "-Up";
		local highlightPostfix = (status == 0) and "-Mouseover" or "-Up";

		local textureKit = "GameMenu";
		if ( status == 1 ) then
			textureKit = "StreamDLGreen";
		elseif ( status == 2 ) then
			textureKit = "StreamDLYellow";
		elseif ( status == 3 ) then
			textureKit = "StreamDLRed";
		end

		self:SetNormalAtlas(prefix..textureKit.."-Up");
		self:SetPushedAtlas(prefix..textureKit.."-Down");
		self:SetDisabledAtlas(prefix..textureKit..disabledPostfix);
		self:SetHighlightAtlas(prefix..textureKit..highlightPostfix);

		local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
		local latency = latencyHome > latencyWorld and latencyHome or latencyWorld;
		if ( latency > PERFORMANCEBAR_MEDIUM_LATENCY ) then
			self.MainMenuBarPerformanceBar:SetVertexColor(1, 0, 0);
		elseif ( latency > PERFORMANCEBAR_LOW_LATENCY ) then
			self.MainMenuBarPerformanceBar:SetVertexColor(1, 1, 0);
		else
			self.MainMenuBarPerformanceBar:SetVertexColor(0, 1, 0);
		end
		if ( self.hover and not KeybindFrames_InQuickKeybindMode() ) then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU");
			MainMenuBarPerformanceBarFrame_OnEnter(self);
		end
	end
end

function MainMenuMicroButtonMixin:OnMouseDown(button)
	self:SetPushed();
	self.down = 1;
end

function MainMenuMicroButtonMixin:OnMouseUp(button)
	if ( self.down ) then
		self.down = nil;
		if ( self:IsMouseOver() ) then
			if ( not GameMenuFrame:IsShown() ) then
				if ( not AreAllPanelsDisallowed() ) then
					if ( SettingsPanel:IsShown() ) then
						SettingsPanel:Close();
					end
					CloseMenus();
					CloseAllWindows();
					PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
					ShowUIPanel(GameMenuFrame);
				end
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
				HideUIPanel(GameMenuFrame);
				self:SetNormal();
			end
		end
		UpdateMicroButtons();
		return;
	end
	if ( self:GetButtonState() == "NORMAL" ) then
		self:SetPushed();
		self.down = 1;
	else
		self:SetNormal();
		self.down = 1;
	end
end

function MainMenuMicroButtonMixin:OnEnter()
	self.hover = 1;
	self.updateInterval = 0;
	if ( KeybindFrames_InQuickKeybindMode() ) then
		self:QuickKeybindButtonOnEnter();
	end
end

function MainMenuMicroButtonMixin:OnLeave()
	self.hover = nil;
	GameTooltip:Hide();
	if ( KeybindFrames_InQuickKeybindMode() ) then
		self:QuickKeybindButtonOnLeave();
	end
end

function MainMenuMicroButtonMixin:SetPushed()
	self:SetButtonState("PUSHED", true);
end

function MainMenuMicroButtonMixin:SetNormal()
	self:SetButtonState("NORMAL");
end

MicroMenuMixin = {};

-- Gets the button on the the extreme edge of the micro menu based on the inputs and the orientation of the bar
function MicroMenuMixin:GetEdgeButton(rightMost, topMost)
	local characterButtonX, characterButtonY = CharacterMicroButton:GetCenter();
	local mainMenuButtonX, mainMenuButtonY = MainMenuMicroButton:GetCenter();

	if self.isHorizontal then
		if rightMost then
			return characterButtonX > mainMenuButtonX and CharacterMicroButton or MainMenuMicroButton;
		else -- leftMost
			return characterButtonX < mainMenuButtonX and CharacterMicroButton or MainMenuMicroButton;
		end
	else
		if topMost then
			return characterButtonY > mainMenuButtonY and CharacterMicroButton or MainMenuMicroButton;
		else -- bottomMost
			return characterButtonY < mainMenuButtonY and CharacterMicroButton or MainMenuMicroButton;
		end
	end
end

function MicroMenuMixin:UpdateHelpTicketButtonAnchor(position)
	if not HelpOpenWebTicketButton then
		return;
	end

	-- Update help button anchor so it stays on screen
	local isOnBottomSideOfScreen, isOnLeftSideOfScreen;
	if position == MicroMenuPositionEnum.BottomLeft then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = true, true;
	elseif position == MicroMenuPositionEnum.BottomRight then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = true, false;
	elseif position == MicroMenuPositionEnum.TopLeft then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = false, true;
	elseif position == MicroMenuPositionEnum.TopRight then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = false, false;
	end

	local relativeTo = self:GetEdgeButton(isOnLeftSideOfScreen, isOnBottomSideOfScreen);
	local offsetY = isOnBottomSideOfScreen and 25 or -25;
	HelpOpenWebTicketButton:SetPoint("CENTER", relativeTo, "CENTER", 0, offsetY);
end

function MicroMenuMixin:UpdateQueueStatusAnchors(position)
	if QueueStatusButton then
		QueueStatusButton:UpdatePosition(position, self.isHorizontal);
	end

	if QueueStatusFrame then
		QueueStatusFrame:UpdatePosition(position, self.isHorizontal);
	end
end

function MicroMenuMixin:AnchorToMenuContainer(position)
	if self:GetParent() ~= MicroMenuContainer then
		-- If micro menu isn't parented to the default container then don't do anything
		-- It is temporarily being overridden to be positioned somewhere else
		return;
	end

	local point;
	if position == MicroMenuPositionEnum.BottomLeft then
		point = "BOTTOMLEFT";
	elseif position == MicroMenuPositionEnum.BottomRight then
		point = "BOTTOMRIGHT";
	elseif position == MicroMenuPositionEnum.TopLeft then
		point = "TOPLEFT";
	elseif position == MicroMenuPositionEnum.TopRight then
		point = "TOPRIGHT";
	end
	self:ClearAllPoints();
	self:SetPoint(point, MicroMenuContainer, point, 0, 0);
end

function MicroMenuMixin:SetQueueStatusScale(scale)
	if QueueStatusButton then
		QueueStatusButton:SetScale(scale);
	end

	self:UpdateQueueStatusAnchors(MicroMenuContainer:GetPosition());
end

function MicroMenuMixin:Layout()
	GridLayoutFrameMixin.Layout(self);

	local position = MicroMenuContainer:GetPosition();
	self:AnchorToMenuContainer(position);
	self:UpdateQueueStatusAnchors(position);
	self:UpdateHelpTicketButtonAnchor(position);
end

MicroMenuContainerMixin = {};

-- Manually wrote a layout method since we want to resize even around hidden frames
-- Also some custom logic for when the micro menu isn't parented to the container
function MicroMenuContainerMixin:Layout()
	local isHorizontal = MicroMenu.isHorizontal;

	local width, height = 0, 0;
	local function AddFrameSize(frame, includeOffset)
		local frameScale = frame:GetScale();

		if isHorizontal then
			width = width + frame:GetWidth() * frameScale;
			if includeOffset then
				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1);
				width = width + math.abs(offsetX * frameScale);
			end

			height = math.max(height, frame:GetHeight() * frameScale);
		else
			width = math.max(width, frame:GetWidth() * frameScale);

			height = height + frame:GetHeight() * frameScale;
			if includeOffset then
				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1);
				height = height + math.abs(offsetY * frameScale);
			end
		end
	end

	if MicroMenu then
		if MicroMenu:GetParent() ~= self then
			-- Don't update size if micro menu parented to container
			-- This is a temporary override and we don't want to resize while the menu is gone
			return;
		end

		MicroMenu:Layout();
		AddFrameSize(MicroMenu);
	end

	if QueueStatusButton then
		local includeOffsetYes = true;
		AddFrameSize(QueueStatusButton, includeOffsetYes);
	end

	self:SetSize(math.max(width, 1), math.max(height, 1));
end

function MicroMenuContainerMixin:GetPosition()
	local centerX, centerY = self:GetCenter();
	local halfScreenWidth = UIParent:GetWidth() / 2;
	local halfScreenHeight = UIParent:GetHeight() / 2;

	if centerY < halfScreenHeight then
		if centerX < halfScreenWidth then
			return MicroMenuPositionEnum.BottomLeft;
		else
			return MicroMenuPositionEnum.BottomRight;
		end
	else
		if centerX < halfScreenWidth then
			return MicroMenuPositionEnum.TopLeft;
		else
			return MicroMenuPositionEnum.TopRight;
		end
	end
end