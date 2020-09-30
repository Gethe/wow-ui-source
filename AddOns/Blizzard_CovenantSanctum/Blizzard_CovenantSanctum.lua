CovenantSanctumMixin = {};

local TAB_UPGRADES = 1;
local TAB_RENOWN = 2;

local TUTORIAL_REWARDS = 1;
local TUTORIAL_RENOWN = 2;
local TUTORIAL_MILESTONES = 3;
local TUTORIAL_DEPOSIT = 4;
local TUTORIAL_FEATURES = 5;
local TUTORIAL_RENOWN_UPGRADES = 6;

function CovenantSanctumMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);

	local attributes =
	{
		area = "center",
		pushable = 0,
		allowOtherPanels = 0,
	};
	RegisterUIPanel(CovenantSanctumFrame, attributes);

	-- tutorials
	local onAcknowledgeCallback = GenerateClosure(self.OnAcknowledgeTutorial, self);
	self.tutorials = {
		[TUTORIAL_REWARDS] = {
			text = COVENANT_SANCTUM_TUTORIAL1,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeTop,
			offsetX = 145,
			offsetY = -75,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_RENOWN,
		},
		[TUTORIAL_RENOWN] = {
			text = COVENANT_SANCTUM_TUTORIAL2,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = -10,
			offsetY = 0,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_RENOWN,
			target = self.LevelFrame;
		},
		[TUTORIAL_MILESTONES] = {
			text = COVENANT_SANCTUM_TUTORIAL3,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetX = 0,
			offsetY = 0,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_RENOWN,
			tabRegion = "MilestonesFrame",
		},
		[TUTORIAL_DEPOSIT] = {
			text = COVENANT_SANCTUM_TUTORIAL4,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetX = 0,
			offsetY = 0,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_UPGRADES,
			tabRegion = "DepositButton",
		},
		[TUTORIAL_FEATURES] = {
			text = COVENANT_SANCTUM_TUTORIAL5,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 59,
			offsetY = 59,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_UPGRADES,
			showConditionFunc = self.HasAnySoulCurrencies,
		},
		[TUTORIAL_RENOWN_UPGRADES] = {
			text = COVENANT_SANCTUM_TUTORIAL6,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetX = 0,
			offsetY = 0,
			onAcknowledgeCallback = onAcknowledgeCallback,
			system = "CovenantSanctum",
			-- non-helptip stuff
			tabIndex = TAB_UPGRADES,
			target = self.LevelFrame.Level,
		}
	};
end

local CovenantSanctumEvents = {
	"COVENANT_SANCTUM_INTERACTION_ENDED",
	"COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED",
};

function CovenantSanctumMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantSanctumEvents);

	if C_CovenantSanctumUI.CanAccessReservoir() then
		PanelTemplates_EnableTab(self, TAB_UPGRADES);
		self.UpgradesTabButton.tooltipText = nil;
		self:SetTab(TAB_UPGRADES);
	else
		PanelTemplates_DisableTab(self, TAB_UPGRADES);
		self.UpgradesTabButton.tooltipText = COVENANT_SANCTUM_RESERVOIR_INACTIVE;
		self:SetTab(TAB_RENOWN);
	end
	self:RefreshLevel();

	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_OPEN_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function CovenantSanctumMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumEvents);

	C_CovenantSanctumUI.EndInteraction();

	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_CLOSE_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function CovenantSanctumMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_INTERACTION_STARTED" then
		self:SetCovenantInfo();
		ShowUIPanel(self);
	elseif event == "COVENANT_SANCTUM_INTERACTION_ENDED" then
		HideUIPanel(self);
	elseif event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		self:RefreshLevel();
	end
end

function CovenantSanctumMixin:RefreshLevel()
	self.LevelFrame.Level:SetFormattedText(COVENANT_SANCTUM_LEVEL, C_CovenantSanctumUI.GetRenownLevel());
end

function CovenantSanctumMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);

	self.UpgradesTab:SetShown(tabID == TAB_UPGRADES);
	self.RenownTab:SetShown(tabID == TAB_RENOWN);

	self:CheckTutorial();
end

function CovenantSanctumMixin:SetCovenantInfo()
	local treeID = C_Garrison.GetCurrentGarrTalentTreeID();
	if treeID ~= self.treeID then
		self.treeID = treeID;
		local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
		self.textureKit = treeInfo.textureKit;
		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, treeInfo.textureKit);
		NineSliceUtil.DisableSharpening(self.NineSlice);

		local atlas = "CovenantSanctum-Level-Border-%s";
		local useAtlasSize = true;
		self.LevelFrame.Background:SetAtlas(atlas:format(treeInfo.textureKit), useAtlasSize);

		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, treeInfo.textureKit);
	end
end

function CovenantSanctumMixin:GetTreeID()
	return self.treeID;
end

function CovenantSanctumMixin:GetTextureKit()
	return self.textureKit;
end

function CovenantSanctumMixin:GetTabFrame(tabIndex)
	if tabIndex == TAB_UPGRADES then
		return self.UpgradesTab;
	elseif tabIndex == TAB_RENOWN then
		return self.RenownTab;
	end
	return nil;
end

function CovenantSanctumMixin:HasAnySoulCurrencies()
	if not self.soulCurrencies then
		self.soulCurrencies = C_CovenantSanctumUI.GetSoulCurrencies();
	end
	for i, currencyID in ipairs(self.soulCurrencies) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		if currencyInfo.quantity > 0 then
			return true;
		end
	end
	return false;
end

function CovenantSanctumMixin:AcknowledgeDepositTutorial()
	self:AcknowledgeTutorial(TUTORIAL_DEPOSIT);
end

function CovenantSanctumMixin:AcknowledgeFeaturesTutorial()
	self:AcknowledgeTutorial(TUTORIAL_FEATURES);
end

function CovenantSanctumMixin:AcknowledgeTutorial(index)
	local tutorial = self.tutorials[index];
	local frame = self:GetTabFrame(tutorial.tabIndex) or self;
	if HelpTip:IsShowing(frame, tutorial.text) then
		self:OnAcknowledgeTutorial();
	end
end

function CovenantSanctumMixin:OnAcknowledgeTutorial()
	local advance = true;
	self:CheckTutorial(advance);
end

function CovenantSanctumMixin:CheckTutorial(advance)
	local lastSeenIndex = tonumber(GetCVar("lastCovenantSanctumTutorial")) or 0;
	local currentIndex = lastSeenIndex + 1;
	if advance then
		SetCVar("lastCovenantSanctumTutorial", currentIndex);
		currentIndex = currentIndex + 1;
	end
	HelpTip:HideAllSystem("CovenantSanctum");	
	local tutorial = self.tutorials[currentIndex];
	if not tutorial then
		return;
	end
	if PanelTemplates_GetSelectedTab(self) ~= tutorial.tabIndex then
		return;
	end
	if tutorial.showConditionFunc and not tutorial.showConditionFunc(self) then
		return;
	end

	local frame = self:GetTabFrame(tutorial.tabIndex) or self;
	local region;
	if tutorial.target then
		region = tutorial.target;
	elseif tutorial.tabRegion then
		region = frame[tutorial.tabRegion];
	else
		region = frame;
	end
	HelpTip:Show(frame, tutorial, region);
end