MICRO_BUTTONS = {
	"CharacterMicroButton",
	"ProfessionMicroButton",
	"PlayerSpellsMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"HousingMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CollectionsMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
	"StoreMicroButton",
}

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
local PLAYERSPELLS_FRAME_PRIORITIES =
{
	TALENT_MICRO_BUTTON_SPEC_TUTORIAL = 1,
	TALENT_MICRO_BUTTON_TALENT_TUTORIAL = 2,
	TALENT_MICRO_BUTTON_NO_SPEC = 3,
	TALENT_MICRO_BUTTON_UNSPENT_TALENTS = 4,
	TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT = 5,
	TALENT_MICRO_BUTTON_NEW_PVP_TALENT = 6,
	SPEC_CHANGED_HAS_NEW_ABILITIES = 7,
}

local EJMicroButtonEvents = {
	"NEW_RUNEFORGE_POWER_ADDED",
};

local PERFORMANCEBAR_LOW_LATENCY = 300;
local PERFORMANCEBAR_MEDIUM_LATENCY = 600;

--Textures
function LoadMicroButtonTextures(self, name, color)
	local prefix = "UI-HUD-MicroMenu-";
	self.textureName = name; 
	self:SetNormalAtlas(prefix..name.."-Up");
	self:SetPushedAtlas(prefix..name.."-Down");
	self:SetDisabledAtlas(prefix..name.."-Disabled");
	self:SetHighlightAtlas(prefix..name.."-Mouseover");

	if(color) then 
		local normalTexture = self:GetNormalTexture(); 
		normalTexture:SetVertexColor(color.r, color.g, color.b);

		local pushedTexture = self:GetPushedTexture(); 
		pushedTexture:SetVertexColor(color.r, color.g, color.b);

		local disabledTexture = self:GetDisabledTexture(); 
		disabledTexture:SetVertexColor(color.r, color.g, color.b);
		
		local highlightTexture = self:GetHighlightTexture(); 
		highlightTexture:SetVertexColor(color.r, color.g, color.b);
	end
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

local MICRO_BUTTONS_DISABLED = false;

-- Disables all microbuttons
--	Arg disables main menu button or store button and optionally sets an error tooltip
-- 
local function DisableMicroButtons(disableMainMenu, disableShop, disabledTooltip)
	MICRO_BUTTONS_DISABLED = true;

	CharacterMicroButton.disabledTooltip = disabledTooltip;
	CharacterMicroButton:Disable();
	
	ProfessionMicroButton.disabledTooltip = disabledTooltip;
	ProfessionMicroButton:Disable();

	PlayerSpellsMicroButton.disabledTooltip = disabledTooltip;
	PlayerSpellsMicroButton:Disable();

	QuestLogMicroButton.disabledTooltip = disabledTooltip;
	QuestLogMicroButton:Disable();

	HousingMicroButton.disabledTooltip = disabledTooltip;
	HousingMicroButton:Disable();

	GuildMicroButton.disabledTooltip = disabledTooltip;
	GuildMicroButton:Disable();

	LFDMicroButton.disabledTooltip = disabledTooltip;
	LFDMicroButton:Disable();

	AchievementMicroButton.disabledTooltip = disabledTooltip;
	AchievementMicroButton:Disable();

	EJMicroButton.disabledTooltip = disabledTooltip;
	EJMicroButton:Disable();

	CollectionsMicroButton.disabledTooltip = disabledTooltip;
	CollectionsMicroButton:Disable();

	if (disableMainMenu) then
		MainMenuMicroButton.disabledTooltip = disabledTooltip;
		MainMenuMicroButton:Disable();
	end

	if (disableShop) then
		StoreMicroButton.disabledTooltip = disabledTooltip;
		StoreMicroButton:Disable();
	end
end

local reentranceGuard = SecureTypes.CreateSecureBoolean();
-- Enables all microbuttons but the store
local function EnableMicroButtons()
	if reentranceGuard:IsTrue() then
		return;
	end
	reentranceGuard:SetValue(true);

	MICRO_BUTTONS_DISABLED = false;

	CharacterMicroButton:Enable();
	CharacterMicroButton:UpdateMicroButton();

	ProfessionMicroButton:Enable();
	ProfessionMicroButton:UpdateMicroButton();

	PlayerSpellsMicroButton:Enable();
	PlayerSpellsMicroButton:UpdateMicroButton();

	QuestLogMicroButton:Enable();
	QuestLogMicroButton:UpdateMicroButton();

	HousingMicroButton:Enable();
	HousingMicroButton:UpdateMicroButton();

	GuildMicroButton:Enable();
	GuildMicroButton:UpdateMicroButton();

	LFDMicroButton:Enable();
	LFDMicroButton:UpdateMicroButton();

	AchievementMicroButton:Enable();
	AchievementMicroButton:UpdateMicroButton();

	EJMicroButton:Enable();
	EJMicroButton:UpdateMicroButton();

	CollectionsMicroButton:Enable();
	CollectionsMicroButton:UpdateMicroButton();

	MainMenuMicroButton:Enable();
	MainMenuMicroButton:UpdateMicroButton();

	StoreMicroButton:Enable();
	StoreMicroButton:UpdateMicroButton();

	reentranceGuard:SetValue(false);
end

function MicroMenuBar_SetFullScreenFrame(frame, buttonDisabledTooltip)
	if frame then
		FrameUtil.SetParentMaintainRenderLayering(MicroMenu, frame);
		DisableMicroButtons(true, true, buttonDisabledTooltip);
	end
end

function MicroMenuBar_ClearFullScreenFrame()
	FrameUtil.SetParentMaintainRenderLayering(MicroMenu, UIParent);
	EnableMicroButtons();
end

function UpdateMicroButtons()
	StoreMicroButton:UpdateMicroButton();

	if (MainMenuMicroButton:IsEnabled()) then
		MainMenuMicroButton:UpdateMicroButton();
	end

	if (MICRO_BUTTONS_DISABLED) then
		return;
	end

	CharacterMicroButton:UpdateMicroButton();
	ProfessionMicroButton:UpdateMicroButton();
	PlayerSpellsMicroButton:UpdateMicroButton();
	QuestLogMicroButton:UpdateMicroButton();
	HousingMicroButton:UpdateMicroButton();
	GuildMicroButton:UpdateMicroButton();
	LFDMicroButton:UpdateMicroButton();
	AchievementMicroButton:UpdateMicroButton();
	EJMicroButton:UpdateMicroButton();
	CollectionsMicroButton:UpdateMicroButton();
end

function MicroButtonPulse(self, duration)
	if not MainMenuMicroButton_AreAlertsEnabled() then
		return;
	end

	if (Kiosk.IsEnabled()) then
		return;
	end

	g_flashingMicroButtons[self] = true;
	UIFrameFlash(self.FlashBorder, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
	UIFrameFlash(self.FlashContent, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
end

function MicroButtonPulseStop(self)
	UIFrameFlashStop(self.FlashBorder);
	if(self.FlashContent) then 
		UIFrameFlashStop(self.FlashContent);
	end
	g_flashingMicroButtons[self] = nil;
end

--Alerts
function MainMenuMicroButton_Init()
	g_microButtonAlertPriority = { CollectionsMicroButton, ProfessionMicroButton, PlayerSpellsMicroButton, EJMicroButton, GuildMicroButton };
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

function MainMenuBarMicroButtonMixin:ShouldShowTooltip()
	if KeybindFrames_InQuickKeybindMode() then
		return false;
	end

	-- This function can be called at times other than when the mouse focus changes so ensure only
	-- the mouse focus is displaying a tooltip.
	if not self:IsMouseMotionFocus() then
		return false;
	end

	-- Enabled buttons always show a tooltip.
	if self:IsEnabled() then
		return true;
	end

	-- When all the micro buttons are disabled (except the store and maybe main menu) none of the
	-- disabled ones should have a tooltip.
	if MICRO_BUTTONS_DISABLED then
		return false;
	end

	-- Some buttons need to show a tooltip explaining why they're disabled.
	if self.minLevel or self.disabledTooltip or self.factionGroup then
		return true;
	end

	return false;
end

function MainMenuBarMicroButtonMixin:EvaluateTooltipVisibility()
	if not self:ShouldShowTooltip() then
		-- The button was showing a tooltip but shouldn't be any longer.
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide();
		end

		return;
	end

	-- Every button shows its name and keybind.
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);

	-- Some buttons display extra info when disabled.
	if not self:IsEnabled() then
		if self.factionGroup == "Neutral" then
			GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		elseif self.minLevel then
			GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		elseif self.disabledTooltip then
			local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip");
			GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
	end

	GameTooltip:Show();
end

function MainMenuBarMicroButtonMixin:OnEnter()
	self:EvaluateTooltipVisibility();

	--The shadow is baked into the highlight texture so we shouldn't show the normal texture while the highlight is happening
	local normalTexture = self:GetNormalTexture();
	if(normalTexture) then 
		normalTexture:SetAlpha(0); 
	end 
end

function MainMenuBarMicroButtonMixin:OnLeave()
	GameTooltip:Hide();

	local normalTexture = self:GetNormalTexture();
	if(normalTexture) then 
		normalTexture:SetAlpha(1);
	end
end 


function MainMenuBarMicroButtonMixin:SetPushed()
	self.Background:Hide(); 
	self.PushedBackground:Show(); 

	self:SetButtonState("PUSHED", true);
	self:SetHighlightAtlas("UI-HUD-MicroMenu-"..self.textureName.."-Down", "ADD");

	--Need to duplicate the down texture for highlight when the button is pushed, ADD is to bright and BLEND is too dark, so decrease the alpha
	local highlightTexture = self:GetHighlightTexture();
	highlightTexture:SetAlpha(.50); 
end

function MainMenuBarMicroButtonMixin:SetNormal()
	self:SetButtonState("NORMAL");
	self:SetHighlightAtlas("UI-HUD-MicroMenu-"..self.textureName.."-Mouseover", "BLEND");
	local highlightTexture = self:GetHighlightTexture();
	highlightTexture:SetAlpha(1); 
	self.Background:Show(); 
	self.PushedBackground:Hide(); 
end

function MainMenuBarMicroButtonMixin:OnShow()
	if (MicroMenuContainer) then
		MicroMenuContainer:Layout();
	end
end

function MainMenuBarMicroButtonMixin:OnHide()
	if (MicroMenuContainer) then
		MicroMenuContainer:Layout();
	end
end

function MainMenuBarMicroButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self:SetPushed();
	end
end

function MainMenuBarMicroButtonMixin:OnMouseUp()
	if self:IsEnabled() and not self:IsMouseOver() then
		UpdateMicroButtons();
	end
end

function MainMenuBarMicroButtonMixin:OnEnable()
	self:SetAlpha(1);
	self:EvaluateTooltipVisibility();
end

function MainMenuBarMicroButtonMixin:OnDisable()
	self:SetAlpha(0.5);
	self:EvaluateTooltipVisibility();
end

CharacterMicroButtonMixin = {};

function CharacterMicroButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
end

function CharacterMicroButtonMixin:OnClick()
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( KeybindFrames_InQuickKeybindMode() ) then
		self:QuickKeybindButtonOnClick(button);
	else 
		if ( self.down ) then
			self.down = nil;
			UpdateMicroButtons();
		elseif ( self:GetButtonState() == "NORMAL" ) then
			self:SetPushed();
			self.down = 1;
		else
			self:SetNormal();
			self.down = 1;
		end

		if C_GameRules.IsWoWHack() then
			ToggleWoWHackCharacterUI();
		else
		ToggleCharacter("PaperDollFrame");
	end
	end
end 

function CharacterMicroButtonMixin:OnEnable()
	self:SetAlpha(1);
	SetDesaturation(self.Portrait, false);
end

function CharacterMicroButtonMixin:OnDisable()
	self:SetAlpha(0.5);
	SetDesaturation(self.Portrait, true);
end

function CharacterMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if ( (CharacterFrame and CharacterFrame:IsShown()) or (WoWHackCharacterUI and WoWHackCharacterUI:IsShown()) ) then
		self:SetPushed();
	else
		self:SetNormal();
	end
end

function CharacterMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(self.Portrait, "player");
		end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(self.Portrait, "player");
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(self.Portrait, "player");
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame = GetCVarBool("showTokenFrame");
		if ( not showTokenFrame ) then
			if ( C_CurrencyInfo.GetCurrencyListSize() > 0 ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					MicroButtonPulse(CharacterMicroButton, 60);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab3, 60, 1);
				end

				TokenFrame:Update();
				BackpackTokenFrame:UpdateIfVisible();
			else
				CharacterFrameTab3:Hide();
			end
		else
			TokenFrame:Update();
			BackpackTokenFrame:UpdateIfVisible();
		end
	end
end

function CharacterMicroButtonMixin:SetPushed()
	CharacterMicroButton:SetButtonState("PUSHED", true);
	self.PushedShadow:Show();
	self.Background:Hide(); 
	self.PushedBackground:Show(); 
	self.PortraitMask:ClearAllPoints();
	self.PortraitMask:SetPoint("CENTER", 2, -2);

	self.Portrait:ClearAllPoints(); 
	self.Portrait:SetPoint("TOPLEFT", 7, -7);
	self.Portrait:SetPoint("BOTTOMRIGHT", -6, 5);
end

function CharacterMicroButtonMixin:SetNormal()
	CharacterMicroButton:SetButtonState("NORMAL");
	self.PushedShadow:Hide();
	self.Background:Show(); 
	self.PushedBackground:Hide(); 

	self.PortraitMask:ClearAllPoints();
	self.PortraitMask:SetPoint("CENTER", 0, 0);

	self.Portrait:ClearAllPoints(); 
	self.Portrait:SetPoint("TOPLEFT", 7, -7);
	self.Portrait:SetPoint("BOTTOMRIGHT", -7, 7);
end


ProfessionMicroButtonMixin = {};

function ProfessionMicroButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	LoadMicroButtonTextures(self, "Professions");
	self.tooltipText = MicroButtonTooltipText(PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK");
end

function ProfessionMicroButtonMixin:OnClick(button, down)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleProfessionsBook();
	end
end

function ProfessionMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if ( ProfessionsBookFrame and ProfessionsBookFrame:IsShown() ) then
		self:SetPushed();
	else
		self:SetNormal();
	end
end

function ProfessionMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK");
	end
end

function ProfessionMicroButtonMixin:EvaluateAlertVisibility()
	return false;
end


PlayerSpellsMicroButtonMixin = CreateFromMixins(DirtiableMixin);

function PlayerSpellsMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "SpecTalents");
	self.tooltipText = MicroButtonTooltipText(PLAYERSPELLS_BUTTON, "TOGGLETALENTS");
	self.newbieText = NEWBIE_TOOLTIP_TALENTS;

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	-- Many talent/spell events fire back-to-back on the same frame when changing talents/specs/level
	-- So to prevent repeat alert evaluations from stomping each other, using a dirty flag to ensure we
	-- only evaluate alerts once via calls to MakeDirty in OnEvent
	self:SetDirtyMethod(self.EvaluateAlertVisibility);
end

function PlayerSpellsMicroButtonMixin:CanPlayerUseHeroTalentSpecUI()
	local subTreeIDs, heroSpecUnlockLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec();
	return subTreeIDs and #subTreeIDs > 0 and heroSpecUnlockLevel and UnitLevel("player") >= heroSpecUnlockLevel;
end

function PlayerSpellsMicroButtonMixin:HasPlayerCompletedTalentTutorial()
	return GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES);
end

function PlayerSpellsMicroButtonMixin:HasPlayerDisabledTutorials()
	local showTutorials = GetCVarBool("showTutorials");
	return showTutorials == false;
end

function PlayerSpellsMicroButtonMixin:ShouldShowTalentAlerts()
	if not IsPlayerInWorld() then
		return false;
	end

	if not C_SpecializationInfo.CanPlayerUseTalentUI() then
		return false;
	end

	if (Kiosk.IsEnabled()) then
		return false;
	end

	-- Wait to show talent alerts until the player has completed the tutorial.However if a player has
	-- turned off tutorials they might never complete them. But since these alerts are calls to action
	-- the player should take, they should still see them.
	return self:HasPlayerCompletedTalentTutorial() or self:HasPlayerDisabledTutorials();
end

function PlayerSpellsMicroButtonMixin:GetAnyTalentAlert()
	if not self:ShouldShowTalentAlerts() then
		return nil;
	end

	local alert;
	if self:CanPlayerUseHeroTalentSpecUI() and not C_ClassTalents.GetActiveHeroTalentSpec() then
		alert = "TALENT_MICRO_BUTTON_NO_HERO_SPEC";
	elseif C_SpecializationInfo.CanPlayerUseTalentSpecUI() and IsPlayerInitialSpec() and (GetNumSpecializations() > 0) then
		alert = "NPEV2_SPEC_TUTORIAL_GOSSIP_CLOSED";
	elseif C_ClassTalents.HasUnspentTalentPoints() or C_ClassTalents.HasUnspentHeroTalentPoints() then
		alert = "TALENT_MICRO_BUTTON_UNSPENT_TALENTS";
	else
		return nil;
	end	

	local suggestedTab = IsPlayerInitialSpec() and PlayerSpellsUtil.FrameTabs.ClassSpecializations or PlayerSpellsUtil.FrameTabs.ClassTalents;

	return {text = _G[alert], priority = PLAYERSPELLS_FRAME_PRIORITIES[alert] or LOWEST_TALENT_FRAME_PRIORITY, suggestedTab = suggestedTab};
end

function PlayerSpellsMicroButtonMixin:GetAnyPvpTalentAlert()
	local isInterestedInPvP = C_PvP.IsWarModeDesired() or PVPUtil.IsInActiveBattlefield();
	if not isInterestedInPvP or not IsPlayerInWorld() or not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
		return nil;
	end

	local alert;

	local hasEmptySlot, hasNewTalent = C_SpecializationInfo.GetPvpTalentAlertStatus();
	if hasEmptySlot then
		alert = "TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT";
	elseif hasNewTalent then
		alert = "TALENT_MICRO_BUTTON_NEW_PVP_TALENT";
	else
		return nil;
	end

	return {text = _G[alert], priority = PLAYERSPELLS_FRAME_PRIORITIES[alert] or LOWEST_TALENT_FRAME_PRIORITY, suggestedTab = PlayerSpellsUtil.FrameTabs.ClassTalents};
end

function PlayerSpellsMicroButtonMixin:GetAnySpellBookAlert()
	if not IsPlayerInWorld() or IsPlayerInitialSpec() then
		return nil;
	end

	local newSpecID = C_SpecializationInfo.GetSpecialization();
	local playerAtMax = UnitLevel("player") >= GetMaxLevelForLatestExpansion();
	local specUsedAlready = GetCVarBitfield("maxLevelSpecsUsed", newSpecID);

	-- Makes sure that alerts are only shown when the spec is changed and not when talent is changed.
	-- Also makes sure the player hasn't switched to the spec at max already
	if newSpecID == nil or self.oldSpecID == nil or newSpecID == self.oldSpecID or (playerAtMax and specUsedAlready) then
		self.oldSpecID = newSpecID;
		return nil;
	end

	if playerAtMax and not specUsedAlready then
		SetCVarBitfield("maxLevelSpecsUsed", newSpecID, true);
	end

	self.oldSpecID = newSpecID;

	local firstUndraggedSpecSpell = nil;
	local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.MainSpec);
	for i = 1, skillLineInfo.numSpellBookItems do
		local itemType, _, spellID = C_SpellBook.GetSpellBookItemType(i + skillLineInfo.itemIndexOffset, Enum.SpellBookSpellBank.Player);
		if spellID and itemType ~= Enum.SpellBookItemType.FutureSpell and not C_Spell.IsSpellPassive(spellID) and not C_ActionBar.IsOnBarOrSpecialBar(spellID) then
			firstUndraggedSpecSpell = spellID;
			break;
		end
	end

	if not firstUndraggedSpecSpell then
		return nil;
	end

	local alert = "SPEC_CHANGED_HAS_NEW_ABILITIES";

	return {text = _G[alert], priority = PLAYERSPELLS_FRAME_PRIORITIES[alert], suggestedTab = PlayerSpellsUtil.FrameTabs.SpellBook, jumpToSpellID = firstUndraggedSpecSpell};
end

function PlayerSpellsMicroButtonMixin:GetHighestPriorityAlert()
	local alerts = { self:GetAnyTalentAlert(), self:GetAnyPvpTalentAlert(), self:GetAnySpellBookAlert() }
	local highestPriorityAlert = nil;
	for _, alert in pairs(alerts) do -- Intentionally pairs rather than ipairs since one or more alerts may be nil
		if not highestPriorityAlert or alert.priority > highestPriorityAlert.priority then
			highestPriorityAlert = alert;
		end
	end

	return highestPriorityAlert;
end

function PlayerSpellsMicroButtonMixin:EvaluateAlertVisibility()
	local alert = self:GetHighestPriorityAlert();

	MainMenuMicroButton_HideAlert(self);
	MicroButtonPulseStop(self);

	self.jumpToSpellID = alert and alert.jumpToSpellID or nil;
	self.suggestedTab = alert and alert.suggestedTab or nil;

	if not alert then
		return false;
	end

	if not PlayerSpellsFrame or not PlayerSpellsFrame:IsShown() then
		if MainMenuMicroButton_ShowAlert(self, alert.text) then
			MicroButtonPulse(self);
			return true;
		end
	end

	-- SpellBookRevampTODO: As part of setting up new revamp tutorials, reevaluate how we want to handle the "Spec change with undragged spells" alert
	-- while PlayerSpellsFrame is already open (old behavior would force switch to SpellBook tab, which is very disruptive)

	self.jumpToSpellID = nil;
	self.suggestedTab = nil;
	return false;
end

function PlayerSpellsMicroButtonMixin:OnEvent(event, ...)
	if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LEVEL_CHANGED" or event == "UPDATE_BATTLEFIELD_STATUS" then
		self:MarkDirty();
	elseif event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "HONOR_LEVEL_UPDATE" then
		UpdateMicroButtons();
		self:MarkDirty();
	elseif event == "UPDATE_BINDINGS" then
		self.tooltipText =  MicroButtonTooltipText(PLAYERSPELLS_BUTTON, "TOGGLETALENTS");
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.oldSpecID = C_SpecializationInfo.GetSpecialization();
	end
end

function PlayerSpellsMicroButtonMixin:OnClick(button, down)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if not KeybindFrames_InQuickKeybindMode() then
		if self.jumpToSpellID and (not self.suggestedTab or self.suggestedTab == PlayerSpellsUtil.FrameTabs.SpellBook) then
			local knownSpellsOnly, toggleFlyout, flyoutReason = true, false, nil;
			PlayerSpellsUtil.OpenToSpellBookTabAtSpell(self.jumpToSpellID, knownSpellsOnly, toggleFlyout, flyoutReason)
			self.jumpToSpellID = nil;
		else
			PlayerSpellsUtil.TogglePlayerSpellsFrame(self.suggestedTab);
		end
	end
end

function PlayerSpellsMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if (PlayerSpellsFrame and PlayerSpellsFrame:IsShown()) then
		self:SetPushed();
	else
		self:SetNormal();
	end
end


AchievementMicroButtonMixin = {};

function AchievementMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Achievements");

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST");
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	self.newbieText = NEWBIE_TOOLTIP_ACHIEVEMENT;
	--Just used for display. But we know that it will become available by level 10 due to the level 10 achievement.
	self.minLevel = Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL;
end

function AchievementMicroButtonMixin:OnClick(button, down)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleAchievementFrame();
	end
end

function AchievementMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		self:SetPushed();
	else
		if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
			self:Enable();
			self:SetNormal();
		else
			self:Disable();
		end
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

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");

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
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleQuestLog();
	end
end

function QuestLogMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if (  WorldMapFrame and WorldMapFrame:IsShown() ) then
		self:SetPushed();
	else
		self:SetNormal();
	end
end

HousingMicroButtonMixin = {};

function HousingMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Housing");

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("HOUSING_SERVICES_AVAILABILITY_UPDATED");
	EventRegistry:RegisterCallback("HousingDashboard.Toggled", self.UpdateMicroButton, self);

	self:UpdateTooltipText();
end

function HousingMicroButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		self:UpdateTooltipText();
	elseif ( event == "HOUSING_SERVICES_AVAILABILITY_UPDATED" ) then
		self:UpdateMicroButton();
	end
end

function HousingMicroButtonMixin:UpdateTooltipText()
	self.tooltipText = MicroButtonTooltipText(HOUSING_MICRO_BUTTON, "TOGGLEHOUSINGDASHBOARD");
	self.newbieText = NEWBIE_TOOLTIP_HOUSING;
end

function HousingMicroButtonMixin:OnClick(button)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		HousingFramesUtil.ToggleHousingDashboard();
	end
end

function HousingMicroButtonMixin:OnShow()
	EventRegistry:TriggerEvent("HousingMicroButton.Shown");
end

function HousingMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if ( PlayerIsTimerunning() ) then
		-- Don't need to worry about reshowing because Timerunners can only hit this in a single UI session
		self:Hide();
		return;
	elseif ( not C_Housing.IsHousingServiceEnabled() ) then
		self:Disable();
		self.disabledTooltip = ERR_HOUSING_ACTION_UNAVAILABLE;
		return;
	elseif ( C_PlayerInfo.IsPlayerNPERestricted() ) then
		self:Disable();
		self.disabledTooltip = HOUSING_MICROBUTTON_NPE_RESTRICTED_TOOLTIP;
		return;
	else
		self:Enable();
	end

	if (  HousingDashboardFrame and HousingDashboardFrame:IsShown() ) then
		self:SetPushed();
	else
		self:SetNormal();
	end
end


GuildMicroButtonMixin = {};

function GuildMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "GuildCommunities");
	self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
	self.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
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
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	if ( IsCommunitiesUIDisabledByTrialAccount() ) then
		self:Disable();
		self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
	end
	self.needsUpdate = true;
end

function GuildMicroButtonMixin:SetPushed()
	self.Emblem:ClearAllPoints();
	self.HighlightEmblem:ClearAllPoints()

	self.Emblem:SetPoint("CENTER", 1, 1);
	self.HighlightEmblem:SetPoint("CENTER", 1, 1);

	MainMenuBarMicroButtonMixin.SetPushed(self);
end 

function GuildMicroButtonMixin:SetNormal()
	self.Emblem:ClearAllPoints();
	self.HighlightEmblem:ClearAllPoints()

	self.Emblem:SetPoint("CENTER", 0, 2);
	self.HighlightEmblem:SetPoint("CENTER", 0, 2);
	MainMenuBarMicroButtonMixin.SetNormal(self);
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
		self:UpdateNotificationIcon();
		local previouslyDisplayedInvitations = DISPLAYED_COMMUNITIES_INVITATIONS;
		DISPLAYED_COMMUNITIES_INVITATIONS = {};
		local invitations = C_Club.GetInvitationsForSelf();
		for i, invitation in ipairs(invitations) do
			local clubId = invitation.club.clubId;
			DISPLAYED_COMMUNITIES_INVITATIONS[clubId] = previouslyDisplayedInvitations[clubId];
		end
		UpdateMicroButtons();
	elseif ( event == "STREAM_VIEW_MARKER_UPDATED" or event == "CLUB_INVITATION_ADDED_FOR_SELF" or event == "CLUB_INVITATION_REMOVED_FOR_SELF" ) then
		self:UpdateNotificationIcon();
	elseif ( event == "CLUB_FINDER_COMMUNITY_OFFLINE_JOIN" ) then
		local newClubId = ...;
		self:SetNewClubId(newClubId);
		self.showOfflineJoinAlert = true;
		self:EvaluateAlertVisibility();
	elseif ( event == "CHAT_DISABLED_CHANGE_FAILED" or event == "CHAT_DISABLED_CHANGED" ) then
		self:UpdateNotificationIcon();
	end
end

function GuildMicroButtonMixin:OnClick(button, down)
	if (Kiosk.IsEnabled()) then
		return;
	end

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

	if (Kiosk.IsEnabled()) then
		self:Disable();
			SetKioskTooltip(self);
		return;
	end

	if ( IsCommunitiesUIDisabledByTrialAccount() or factionGroup == "Neutral" ) then
		self:Disable();
			self.disabledTooltip = ERR_RESTRICTED_ACCOUNT_TRIAL;
	elseif ( C_Club.IsEnabled() and not BNConnected() ) then
		self:Disable();
		self.disabledTooltip = BLIZZARD_COMMUNITIES_SERVICES_UNAVAILABLE;
	elseif ( C_Club.IsEnabled() and C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None ) then
		self:Disable();
		self.disabledTooltip = UNAVAILABLE;
	elseif ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
		self:Enable();
		self:SetPushed();
	else
		self:Enable();
		self:SetNormal();
		if ( CommunitiesFrame_IsEnabled() ) then
			self.tooltipText = MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_COMMUNITIESTAB;
		elseif ( IsInGuild() ) then
			self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_GUILDTAB;
		else
			self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
			self.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB;
		end
	end

	self:UpdateNotificationIcon();
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
	self:UpdateNotificationIcon();
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

function GuildMicroButtonMixin:UpdateNotificationIcon()
	if CommunitiesFrame_IsEnabled() and self:IsEnabled() then
		self.NotificationOverlay:SetShown(C_SocialRestrictions.CanReceiveChat() and (self:HasUnseenInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()));
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
		if ( not self.Emblem:IsShown() ) then
			self.Emblem:Show();
			self.HighlightEmblem:Show();
		end

		LoadMicroButtonTextures(self, "GuildCommunities-GuildColor", tabardInfo.backgroundColor);
		SetSmallGuildTabardTextures("player", self.Emblem);
		SetSmallGuildTabardTextures("player", self.HighlightEmblem);
	else
		LoadMicroButtonTextures(self, "GuildCommunities");
		if ( self.Emblem:IsShown() ) then
			self.Emblem:Hide();
			self.HighlightEmblem:Hide();
		end
	end
	self.needsUpdate = nil;
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

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
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
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		PVEFrame_ToggleFrame();
	end
end

function LFDMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	local factionGroup = UnitFactionGroup("player");

	if ( factionGroup == "Neutral" ) then
		self.factionGroup = factionGroup;
	else
		self.factionGroup = nil;
	end

	if ( PVEFrame and PVEFrame:IsShown() ) then
		self:SetPushed();
	else
		if not self:IsActive() then
			self.disabledTooltip =	function()
				local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
				return canUse and FEATURE_UNAVAILBLE_PLAYER_IS_NEUTRAL or failureReason;
			end
			self:Disable();
		else
			self:Enable();
			self:SetNormal();
			EventRegistry:TriggerEvent("PlunderstormQueueTutorial.Update");
		end
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

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
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
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleCollectionsJournal();
	end
end

function CollectionMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
		self:SetPushed();
	else
		self:Enable();
		self:SetNormal();
	end
end

EJMicroButtonMixin = {};

function EJMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "AdventureGuide");
	SetDesaturation(self:GetDisabledTexture(), true);
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL");
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL;

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");

	--events that can trigger a refresh of the adventure journal
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	CVarCallbackRegistry:RegisterCallback("closedInfoFramesAccountWide", function(_cvar, _value)
		self:UpdateNotificationIcon();
	end);
end

function EJMicroButtonMixin:EvaluateAlertVisibility()
	local alertShown = false;
	if self.playerEntered and self.varsLoaded and self.zoneEntered then
		if self:IsEnabled() then
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
		local spec = C_SpecializationInfo.GetSpecialization();
		local ilvl = GetAverageItemLevel();

		self.lastEvaluatedSpec = spec;
		self.lastEvaluatedIlvl = ilvl;
	end
end

function EJMicroButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, EJMicroButtonEvents);
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
		self:UpdateNotificationIcon();
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
		local spec = C_SpecializationInfo.GetSpecialization();
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
		self:SetPushed();
	else
		if ( not AdventureGuideUtil.IsAvailable() ) then
			self:Disable();
			self.disabledTooltip = inKioskMode and ERR_SYSTEM_DISABLED or FEATURE_NOT_YET_AVAILABLE;
			self:ClearNewAdventureNotice();
		else
			self:Enable();
			self:SetNormal();
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
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ToggleEncounterJournal();
	end
end

function EJMicroButtonMixin:UpdateMicroButton()
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	self:UpdateDisplay();
end

function EJMicroButtonMixin:ShouldShowPowerTab(button, down)
	return (self.runeforgePowerAdded ~= nil) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_RUNEFORGE_LEGENDARY_POWER), self.runeforgePowerAdded;
end

function EJMicroButtonMixin:UpdateNotificationIcon()
	local show = not GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.EnconterJournalTutorialsTabSeen);
	local journeyTutorial = not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_JOURNEYS_TAB);
	self.NotificationOverlay:SetShown(show or journeyTutorial);
end

StoreMicroButtonMixin = {};

function StoreMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "Shop");
	self.tooltipText = BLIZZARD_STORE;

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("STORE_STATUS_CHANGED");

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
end

function StoreMicroButtonMixin:GetButtonContext()
	return self.buttonContext;
end

function StoreMicroButtonMixin:OnClick()
	if (Kiosk.IsEnabled()) then
		return;
	end

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
	if (Kiosk.IsEnabled()) then
		self:Disable();
		SetKioskTooltip(self);
		return;
	end

	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		local wasShown = CatalogShopInboundInterface.IsShown();
		if CatalogShopFrame and wasShown then
			self:SetPushed();
			DisableMicroButtons(true);
		else
			EnableMicroButtons();
			self:SetNormal();
		end
	else
		local wasShown = StoreFrame_IsShown();
		if ( StoreFrame and wasShown ) then
			self:SetPushed();
			DisableMicroButtons(true);
		else
			EnableMicroButtons();
			self:SetNormal();
		end
	end

	self:Show();
	HelpMicroButton:Hide();

	if ( not C_StorePublic.IsEnabled() ) then
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
		local tutorialWatcher = TutorialManager and TutorialManager:GetWatcher("UI_Watcher");
		if tutorialWatcher and tutorialWatcher.IsActive then
			self:Hide();
		end
	else
		self.disabledTooltip = nil;
		self:Enable();
	end

	self.NotificationOverlay:SetShown(C_CatalogShop.HasNewProducts());
end

HelpMicroButtonMixin = {};

function HelpMicroButtonMixin:OnLoad()
	LoadMicroButtonTextures(self, "GameMenu");

	self:RegisterForClicks("AnyUp");
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

		if(self:GetButtonState() == "NORMAL") then 
			self:SetHighlightAtlas(prefix..textureKit..highlightPostfix, "BLEND");
		else 
			self:SetHighlightAtlas(prefix..textureKit.."-Down", "ADD");
		end 
	
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

function MainMenuMicroButtonMixin:OnClick(button, down)
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
		end
	end
end

function MainMenuMicroButtonMixin:UpdateMicroButton()
	if ( ( GameMenuFrame and GameMenuFrame:IsShown() )
		or ( SettingsPanel:IsShown())
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		self:SetPushed();

		if( ( GameMenuFrame and GameMenuFrame:IsShown() )
			or ( SettingsPanel:IsShown() ) ) then
			DisableMicroButtons(false);
		end
	else
		EnableMicroButtons();
		self:SetNormal();
	end

	self:UpdateNotificationIcon();
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

function MainMenuMicroButtonMixin:UpdateNotificationIcon()
	local needEditModeNotification = EditModeManagerFrame:CanEnterEditMode() and EditModeManagerFrame.Tutorial:HasHelptipsToShow();
	self.NotificationOverlay:SetShown(needEditModeNotification or CurrentVersionHasNewUnseenSettings());
end
