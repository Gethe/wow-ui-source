
local TUTORIAL_CONFIG = {
	scribeCurrencyID = 3327,
	evadeTrackingQuestID = 93248,
	quillgraveInstanceMapID = 2863,
	scribeUITrackingQuestID = 93343,
	scribeText = WOWHACK_SCRIBE_TUTORIAL,
	microMenuTutorialText = WOWHACK_MICROMENU_TUTORIAL,
	scribeBitfieldFlag = LE_FRAME_TUTORIAL_WOWHACK_SCRIBE,
	microMenuBitfieldFlag = LE_FRAME_TUTORIAL_WOWHACK_MICROMENU,
	scribeWindowOpenedBitfieldFlag = LE_FRAME_TUTORIAL_WOWHACK_SCRIBE_WINDOW_OPENED,
};

local SCRIBE_TUTORIAL_KEY = "scribe";
local SCRIBE_TUTORIAL_WINDOW_OPENED_KEY = "scribeWindowOpened";
local MICROMENU_TUTORIAL_KEY = "postEvadeMicroMenu";

local TUTORIAL_SYSTEM = "WoWHackTutorials";
local TUTORIAL_STATE_CVAR = "closedInfoFrames";
local TUTORIAL_STATE_CVAR_LOWER = strlower(TUTORIAL_STATE_CVAR);

local TUTORIAL_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"CURRENCY_DISPLAY_UPDATE",
	"QUEST_LOG_UPDATE",
	"CVAR_UPDATE",
};

WoWHackTutorialControllerMixin = {};

function WoWHackTutorialControllerMixin:GetConfig()
	return self.config or TUTORIAL_CONFIG;
end

function WoWHackTutorialControllerMixin:GetScribeMicroButton()
	return ScribeMicroButton;
end

function WoWHackTutorialControllerMixin:GetSpellbookMicroButton()
	return SpellbookMicroButton;
end

function WoWHackTutorialControllerMixin:GetMicroMenu()
	return MicroMenu;
end

function WoWHackTutorialControllerMixin:GetTutorialBitfieldFlag(key)
	local config = self:GetConfig();
	if key == SCRIBE_TUTORIAL_KEY then
		return config.scribeBitfieldFlag;
	elseif key == SCRIBE_TUTORIAL_WINDOW_OPENED_KEY then
		return config.scribeWindowOpenedBitfieldFlag;
	end
	return config.microMenuBitfieldFlag;
end

function WoWHackTutorialControllerMixin:IsTutorialAcknowledged(key)
	return GetCVarBitfield(TUTORIAL_STATE_CVAR, self:GetTutorialBitfieldFlag(key));
end

function WoWHackTutorialControllerMixin:AcknowledgeTutorial(key)
	SetCVarBitfield(TUTORIAL_STATE_CVAR, self:GetTutorialBitfieldFlag(key), true);
end

function WoWHackTutorialControllerMixin:OnLoad()
	local scribeButton = self:GetScribeMicroButton();
	local microMenu = self:GetMicroMenu();
	self.microMenuHighlight = microMenu.TutorialHighlight;
	FrameUtil.RegisterFrameForEvents(self, TUTORIAL_EVENTS);
	EventRegistry:RegisterCallback("ScribeFrame.Opened", self.OnScribeWindowOpened, self);
	EventRegistry:RegisterCallback("ScribeFrame.Closed", self.OnScribeWindowClosed, self);
	scribeButton:RegisterCallback("OnEnable", self.ScheduleUpdate, self);
	scribeButton:RegisterCallback("OnDisable", self.ScheduleUpdate, self);
	EventRegistry:RegisterCallback("MicroMenu.Updated", self.OnMicroMenuUpdated, self);
end

function WoWHackTutorialControllerMixin:OnMicroMenuUpdated(pushedButton)
	if self.activeTutorial == MICROMENU_TUTORIAL_KEY and pushedButton then
		HelpTip:AcknowledgeSystem(TUTORIAL_SYSTEM, self:GetConfig().microMenuTutorialText);
	end
end

function WoWHackTutorialControllerMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		local config = self:GetConfig();
		local currencyID = ...;
		if currencyID and currencyID ~= 0 and currencyID ~= config.scribeCurrencyID then
			return;
		end
	elseif event == "CVAR_UPDATE" then
		local cvarName = ...;
		cvarName = cvarName and strlower(cvarName);
		if cvarName ~= TUTORIAL_STATE_CVAR_LOWER and cvarName ~= "hidehelptips" then
			return;
		end
	end

	self:ScheduleUpdate();
end

function WoWHackTutorialControllerMixin:ScheduleUpdate()
	if self.updateScheduled then
		return;
	end
	self.updateScheduled = true;
	RunNextFrame(function()
		self.updateScheduled = nil;
		self:Update();
	end);
end

function WoWHackTutorialControllerMixin:GetScribeCurrencyQuantity()
	local config = self:GetConfig();
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(config.scribeCurrencyID);
	return currencyInfo and currencyInfo.quantity or 0;
end

function WoWHackTutorialControllerMixin:IsInQuillgrave()
	local config = self:GetConfig();
	local instanceMapID = select(8, GetInstanceInfo());
	return instanceMapID == config.quillgraveInstanceMapID;
end

function WoWHackTutorialControllerMixin:IsScribeTutorialEligible()
	local config = self:GetConfig();
	return not self:IsTutorialAcknowledged(SCRIBE_TUTORIAL_KEY)
		and C_QuestLog.IsQuestFlaggedCompleted(config.scribeUITrackingQuestID);
end

function WoWHackTutorialControllerMixin:IsScribeWindowShown()
	return ScribeFrame and ScribeFrame:IsShown();
end

function WoWHackTutorialControllerMixin:OpenScribeWindow()
	local displayOnly = not IsScribeFromMicroButtonEditable();
	ShowScribeUI(displayOnly);
end

function WoWHackTutorialControllerMixin:OnScribeWindowOpened(scribeFrame)
	if self:IsScribeTutorialEligible() then
		self.showScribeCurrencyHighlight = not self:IsTutorialAcknowledged(SCRIBE_TUTORIAL_WINDOW_OPENED_KEY);
		if self.showScribeCurrencyHighlight then
			self:AcknowledgeTutorial(SCRIBE_TUTORIAL_WINDOW_OPENED_KEY);
		end
	else
		self.showScribeCurrencyHighlight = false;
	end
	if self.showScribeCurrencyHighlight and scribeFrame then
		self.scribeCurrencyHighlight = scribeFrame.Currency.TutorialHighlight;
	end
	if self.activeTutorial == SCRIBE_TUTORIAL_KEY then
		HelpTip:AcknowledgeSystem(TUTORIAL_SYSTEM, self:GetConfig().scribeText);
	end
	self:UpdateScribeCurrencyHighlight();
	self:ScheduleUpdate();
end

function WoWHackTutorialControllerMixin:OnScribeWindowClosed()
	self.showScribeCurrencyHighlight = false;
	self:UpdateScribeCurrencyHighlight();
	self:ScheduleUpdate();
end

function WoWHackTutorialControllerMixin:UpdateScribeCurrencyHighlight(quantity)
	if self.scribeCurrencyHighlight then
		local showHighlight = self.showScribeCurrencyHighlight and self:IsScribeWindowShown()
			and MainMenuMicroButton_AreAlertsEnabled() and HelpTip:AreHelpTipsEnabled();
		if showHighlight then
			quantity = quantity or self:GetScribeCurrencyQuantity();
			showHighlight = quantity > 0;
		end
		self.scribeCurrencyHighlight:SetHighlightShown(showHighlight);
	end
end

function WoWHackTutorialControllerMixin:UpdateIndicator(showIndicator)
	local button = self:GetScribeMicroButton();
	if button:HasNotification() ~= showIndicator then
		button:SetHasNotification(showIndicator);
	end

	local shouldGlow = showIndicator and button:IsVisible() and button:IsEnabled() and MainMenuMicroButton_AreAlertsEnabled();
	if shouldGlow then
		if not self.ownsGlow then
			button.FlashBorder:SetAlpha(1);
			button.FlashBorder:Show();
			self.ownsGlow = true;
		end
	elseif self.ownsGlow then
		self.ownsGlow = nil;
		button.FlashBorder:Hide();
	end
end

function WoWHackTutorialControllerMixin:UpdateMicroMenuGlow(showGlow)
	self.microMenuHighlight:SetHighlightShown(showGlow);
end

function WoWHackTutorialControllerMixin:OnTutorialHidden(key, _acknowledged)
	if self.activeTutorial == key then
		self.activeTutorial = nil;
		self:UpdateMicroMenuGlow(false);
	end
	self:ScheduleUpdate();
end

function WoWHackTutorialControllerMixin:HideTutorial()
	self:UpdateMicroMenuGlow(false);
	if self.activeTutorial then
		HelpTip:HideAllSystem(TUTORIAL_SYSTEM);
		self.activeTutorial = nil;
	end
end

function WoWHackTutorialControllerMixin:ShowTutorial(key, button, text)
	local info = {
		text = text,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		system = TUTORIAL_SYSTEM,
		cvarBitfield = TUTORIAL_STATE_CVAR,
		bitfieldFlag = self:GetTutorialBitfieldFlag(key),
		checkCVars = true,
		autoHorizontalSlide = true,
		autoHideWhenTargetHides = true,
		onHideCallback = function(acknowledged)
			self:OnTutorialHidden(key, acknowledged);
		end,
	};
	if HelpTip:Show(UIParent, info, button) then
		self.activeTutorial = key;
		self:UpdateMicroMenuGlow(key == MICROMENU_TUTORIAL_KEY);
	end
end

function WoWHackTutorialControllerMixin:Update()
	local config = self:GetConfig();
	local scribeButton = self:GetScribeMicroButton();
	local spellbookButton = self:GetSpellbookMicroButton();
	local microMenu = self:GetMicroMenu();
	local quantity = self:GetScribeCurrencyQuantity();
	self:UpdateScribeCurrencyHighlight(quantity);
	self:UpdateIndicator(quantity > 0 and self:IsInQuillgrave());

	local scribeEligible = self:IsScribeTutorialEligible();
	local scribeWindowShown = self:IsScribeWindowShown();
	if scribeEligible then
		local scribeWindowOpened = self:IsTutorialAcknowledged(SCRIBE_TUTORIAL_WINDOW_OPENED_KEY);
		if scribeWindowShown then
			if not scribeWindowOpened then
				self:AcknowledgeTutorial(SCRIBE_TUTORIAL_WINDOW_OPENED_KEY);
			end
		elseif not scribeWindowOpened then
			self:HideTutorial();
			self:OpenScribeWindow();
			return;
		end
	end
	local evadeEligible = not self:IsTutorialAcknowledged(MICROMENU_TUTORIAL_KEY) and C_QuestLog.IsQuestFlaggedCompleted(config.evadeTrackingQuestID);
	local alertsEnabled = MainMenuMicroButton_AreAlertsEnabled() and HelpTip:AreHelpTipsEnabled();
	local scribeAvailable = scribeEligible and not scribeWindowShown and scribeButton:IsVisible() and scribeButton:IsEnabled();
	local evadeAvailable = evadeEligible and microMenu:IsVisible() and spellbookButton:IsEnabled();

	if self.activeTutorial then
		local activeAvailable = (self.activeTutorial == SCRIBE_TUTORIAL_KEY and scribeAvailable) or (self.activeTutorial == MICROMENU_TUTORIAL_KEY and evadeAvailable);
		if activeAvailable and alertsEnabled then
			self:UpdateMicroMenuGlow(self.activeTutorial == MICROMENU_TUTORIAL_KEY);
			return;
		end
		self:HideTutorial();
	end

	if not alertsEnabled or scribeWindowShown then
		return;
	end
	if scribeAvailable then
		self:ShowTutorial(SCRIBE_TUTORIAL_KEY, scribeButton, config.scribeText);
	elseif evadeAvailable then
		self:ShowTutorial(MICROMENU_TUTORIAL_KEY, scribeButton, config.microMenuTutorialText);
	end
end
