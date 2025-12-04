
HousingTutorialsQuestManager = CreateFromMixins(TutorialQuestManager);

HouseDecorQuestWatcherMixin = {};

function HouseDecorQuestWatcherMixin:Initialize()
	-- Register for quest related callbacks
	HousingTutorialsQuestManager:Initialize();
	HousingTutorialsQuestManager:RegisterForCallbacks(self);
end

function HouseDecorQuestWatcherMixin:StartWatching()
	if self.isWatching then
		return;
	end

	self.isWatching = true;
	EventRegistry:RegisterCallback("HouseEditor.StateUpdated", self.OnHouseEditorStateUpdated, self);

	-- Reintialize quests upon starting watching
	HousingTutorialsQuestManager:ReinitializeExistingQuests();
end

function HouseDecorQuestWatcherMixin:OnHouseEditorStateUpdated(decorModeActive)
	UpdateHousingTutorials();

	if not self.houseDecorTutorial then
		return;
	end

	if decorModeActive and not self.houseDecorTutorial:IsComplete() then
		local objectiveText, _objectiveType, finished, _numFulfilled, _numRequired = GetQuestObjectiveInfo(self.houseDecorTutorial.questID, 1, false);
		if not finished then
			self.houseDecorTutorial:BeginState(HousingTutorialStates.QuestTutorials.QuestInProgress);
		end

		local storagePanel = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.LayoutStorageFrame);
		if storagePanel then
			if self.houseDecorTutorial.questID == HousingTutorialQuestIDs.CleanupQuest then
				storagePanel:SetCollapsed(true);
			elseif self.houseDecorTutorial.questID == HousingTutorialQuestIDs.DecorateQuest then
				storagePanel:SetCollapsed(false);
			end
		end
	else
		self.houseDecorTutorial:Deactivate();
	end
end

function HouseDecorQuestWatcherMixin:StopWatching()
	if not self.isWatching then
		return;
	end

	self.isWatching = false;
	EventRegistry:UnregisterCallback("HouseEditor.StateUpdated", self);
end

function HouseDecorQuestWatcherMixin:InitHouseDecorTutorial(questID, questTutorialData)
	if self.houseDecorTutorial and questID ~= self.houseDecorTutorial.questID then
		self.houseDecorTutorial:Deactivate();
		HelpTip:HideAllSystem(self.houseDecorTutorial:GetSystem());
	end

	local houseEditorButton = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.EnterDecorModeButton);
	questTutorialData.helpTipInfos[HousingTutorialStates.QuestTutorials.QuestAccepted].parent = houseEditorButton;
	questTutorialData.helpTipInfos[HousingTutorialStates.QuestTutorials.QuestInProgress].parent = houseEditorButton;
	questTutorialData.helpTipInfos[HousingTutorialStates.QuestTutorials.ObjectivesComplete].parent = houseEditorButton;

	self.houseDecorTutorial = CreateAndInitFromMixin(HouseDecorQuestTutorialMixin, questID, questTutorialData.helpTipInfos, questTutorialData.helpTipSystemName, questTutorialData.bitfieldFlag);
end

function HouseDecorQuestWatcherMixin:Quest_Accepted(questData)
	local questID = questData.QuestID;
	local questTutorialData = HousingTutorialData.HouseDecorTutorial.QuestTutorials[questID];
	if questTutorialData then
		self:InitHouseDecorTutorial(questID, questTutorialData);
		self.houseDecorTutorial:BeginInitialState();
	end
end

function HouseDecorQuestWatcherMixin:Quest_Updated(questData)
	local questID = questData.QuestID;
	if self.houseDecorTutorial and questID == self.houseDecorTutorial.questID then
		local helpTipInfo = self.houseDecorTutorial.helpTipInfos[HousingTutorialStates.QuestTutorials.QuestInProgress];

		self.houseDecorTutorial:UpdateInProgressHelpTip();

		local tutorialComplete = self.houseDecorTutorial:GetState() == HousingTutorialStates.QuestTutorials.ObjectivesComplete;
		local helpTipShowing = HelpTip:IsShowing(self.houseDecorTutorial.helpTipParent, helpTipInfo.text);

		-- If the HelpTip is already showing, we want to update it. If the tutorial is complete, we wanna make sure the in-progress helptip is hidden
		if not tutorialComplete and helpTipShowing then
			HelpTip:Hide(self.houseDecorTutorial.helpTipParent, helpTipInfo.text);
			HelpTip:Show(self.houseDecorTutorial.helpTipParent, helpTipInfo, self.houseDecorTutorial.helpTipParent);
		elseif helpTipShowing then
			HelpTip:Hide(self.houseDecorTutorial.helpTipParent, helpTipInfo.text);
		end
	end
end

function HouseDecorQuestWatcherMixin:Quest_ObjectivesComplete(questData)
	self:ObjectivesCompleteInternal(questData);
end

function HouseDecorQuestWatcherMixin:ObjectivesCompleteInternal(questData)
	local questID = questData.QuestID;
	if self.houseDecorTutorial and questID == self.houseDecorTutorial.questID then
		self.houseDecorTutorial:UpdateInProgressHelpTip();
	end

	local questTutorialData = HousingTutorialData.HouseDecorTutorial.QuestTutorials[questID];
	if questTutorialData then
		self:InitHouseDecorTutorial(questID, questTutorialData);

		self.houseDecorTutorial:BeginState(HousingTutorialStates.QuestTutorials.ObjectivesComplete);
	end
end

function HouseDecorQuestWatcherMixin:Quest_TurnedIn(questData)
	local questID = questData.QuestID;
	if self.houseDecorTutorial and questID == self.houseDecorTutorial.questID and C_QuestLog.IsQuestFlaggedCompleted(questID) then
		self.houseDecorTutorial:AcknowledgeTutorial();
		self.houseDecorTutorial = nil;

		UpdateHousingTutorials();
	end
end

function HouseDecorQuestWatcherMixin:Quest_Abandoned(questData)
	if self.houseDecorTutorial and questData.QuestID == self.houseDecorTutorial.questID then
		self.houseDecorTutorial:Deactivate();
		HelpTip:HideAllSystem(self.houseDecorTutorial:GetSystem());
		self.houseDecorTutorial = nil;
	end
end

HouseDecorQuestTutorialMixin = CreateFromMixins(HelpTipStateMachineBasedTutorialMixin);

function HouseDecorQuestTutorialMixin:Init(questID, helpTipInfos, helpTipSystemName, bitfieldFlag)
	self.questID = questID;
	self.helpTipInfos = helpTipInfos;
	self.helpTipSystemName = helpTipSystemName;

	HelpTipStateMachineBasedTutorialMixin.Init(
		self,
		helpTipInfos,
		helpTipSystemName,
		HousingTutorialStates.QuestTutorials,
		HousingTutorialStates.QuestTutorials.QuestAccepted,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		bitfieldFlag
	);
end

function HouseDecorQuestTutorialMixin:ShowHelpTipByState(stateName)
	if stateName == HousingTutorialStates.QuestTutorials.QuestInProgress then
		self:UpdateInProgressHelpTip();
	end

	local helpTipInfo = self.helpTipInfos[stateName];
	-- text can be nil here if the quest is complete
	if helpTipInfo.text then
		self.helpTipParent = helpTipInfo.parent;
		HelpTip:Show(self.helpTipParent, helpTipInfo, self.helpTipParent);
	end
end

function HouseDecorQuestTutorialMixin:UpdateInProgressHelpTip()
	local helpTipInfo = self.helpTipInfos[HousingTutorialStates.QuestTutorials.QuestInProgress];
	if helpTipInfo.formattingText then
		local objectiveText, _objectiveType, finished, _numFulfilled, _numRequired = GetQuestObjectiveInfo(self.questID, 1, false);
		if not finished then
			self.helpTipInfos[HousingTutorialStates.QuestTutorials.QuestInProgress].text = helpTipInfo.formattingText:format(objectiveText);
		else
			HelpTip:Hide(self.helpTipParent, helpTipInfo.text);
		end
	end
end

HouseDecorWatcherMixin = {};

local HOUSE_DECOR_PLACEMENT_WATCHER_EVENTS = {
	"HOUSE_EDITOR_MODE_CHANGED",
};

function HouseDecorWatcherMixin:StartWatching()
	if self.isWatching then
		return;
	end

	self.isWatching = true;

	for _i, event in ipairs(HOUSE_DECOR_PLACEMENT_WATCHER_EVENTS) do
		Dispatcher:RegisterEvent(event, self);
	end

	if not self.housingModesUnlocked then
		self.housingModesUnlocked = CreateFromMixins(HouseModesUnlockedTutorialMixin);
		self.housingModesUnlocked:UpdateHelpTip();

		self.housingModesUnlocked.OnAcknowledgeCallback = function()
			self:HOUSE_EDITOR_MODE_CHANGED(C_HouseEditor.GetActiveHouseEditorMode());
		end
	end

	EventRegistry:RegisterCallback("HousingMarketTab.VisibilityUpdated", self.OnMarketTabVisibilityUpdated, self);
end

function HouseDecorWatcherMixin:StopWatching()
	if not self.isWatching then
		return;
	end

	self.isWatching = false;

	for _i, event in ipairs(HOUSE_DECOR_PLACEMENT_WATCHER_EVENTS) do
		Dispatcher:UnregisterEvent(event, self);
	end

	self.HousingModesUnlocked = nil;
	EventRegistry:UnregisterCallback("HousingMarketTab.VisibilityUpdated", self.OnMarketTabVisibilityUpdated, self);
end

function HouseDecorWatcherMixin:OnMarketTabVisibilityUpdated()
	self:HOUSE_EDITOR_MODE_CHANGED(C_HouseEditor.GetActiveHouseEditorMode());
end

function HouseDecorWatcherMixin:HOUSE_EDITOR_MODE_CHANGED(activeHouseMode)
	if self.housingModesUnlocked and self.housingModesUnlocked:CanBegin() then
		self.housingModesUnlocked:UpdateHelpTip();
		return;
	end

	if activeHouseMode == Enum.HouseEditorMode.BasicDecor then
		if not self.clippingAndGridTutorial then
			self.clippingAndGridTutorial = CreateFromMixins(HouseClippingAndGridTutorialMixin);
		end

		self.clippingAndGridTutorial:UpdateHelpTip();

		if not self.houseMarketTabTutorial then
			self.houseMarketTabTutorial = CreateFromMixins(HouseMarketTabTutorialMixin);
		end

		self.houseMarketTabTutorial:UpdateHelpTip();
	end

	if activeHouseMode == Enum.HouseEditorMode.ExpertDecor then
		if not self.expertModeTutorial then
			self.expertModeTutorial = CreateFromMixins(HouseExpertModeTutorialMixin);
		end

		self.expertModeTutorial:UpdateHelpTip();
	end

	if activeHouseMode == Enum.HouseEditorMode.Cleanup then
		if not self.cleanupModeTutorial then
			self.cleanupModeTutorial = CreateFromMixins(HouseCleanupModeTutorialMixin);
		end

		self.cleanupModeTutorial:UpdateHelpTip();
	else
		if self.cleanupModeTutorial then
			HelpTip:HideAllSystem(HousingTutorialHelpTipSystems.CleanupMode);
		end
	end

	if activeHouseMode == Enum.HouseEditorMode.Customize and not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorCustomization) then
		if not self.customizationTutorial then
			self.customizationTutorial = CreateAndInitFromMixin(HouseDecorCustomizationsTutorialMixin);
		end

		self.customizationTutorial:BeginInitialState();
	elseif self.customizationTutorial then
		self.customizationTutorial:Deactivate();
		HelpTip:HideAllSystem(self.customizationTutorial:GetSystem());
	end

	if activeHouseMode == Enum.HouseEditorMode.Layout then
		if not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorLayout) then
			if not self.layoutTutorial then
				self.layoutTutorial = CreateAndInitFromMixin(HouseLayoutTutorialMixin);
			end

			self.layoutTutorial:BeginInitialState();
		end

		HelpTip:HideAllSystem(HousingTutorialHelpTipSystems.MarketTab);
	elseif self.layoutTutorial then
		self.layoutTutorial:Deactivate();
		HelpTip:HideAllSystem(self.layoutTutorial:GetSystem());
	end
end

local function ShouldShowClippingAndGridTutorial()
	return not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorClippingGrid);
end

HouseClippingAndGridTutorialMixin = {};

function HouseClippingAndGridTutorialMixin:CanBegin()
	return ShouldShowClippingAndGridTutorial();
end

function HouseClippingAndGridTutorialMixin:UpdateHelpTip()
	if self:CanBegin() then
		local subButtonBar = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.DecorPlacementSubButtonBar);
		self.helpTipParent = subButtonBar;

		local helpTipInfo = {
			text = HOUSING_CLIPPING_GRID_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetX = 0,
			offsetY = 0,
			system = HousingTutorialHelpTipSystems.ClippingGrid,
			autoHideWhenTargetHides = true,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingDecorClippingGrid,
		};

		HelpTip:Show(self.helpTipParent, helpTipInfo);
	end
end

local function ShouldShowModesUnlockedTutorial()
	return not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingModesUnlocked);
end

HouseModesUnlockedTutorialMixin = {};

function HouseModesUnlockedTutorialMixin:CanBegin()
	return ShouldShowModesUnlockedTutorial();
end

function HouseModesUnlockedTutorialMixin:UpdateHelpTip()
	if self:CanBegin() then
		local modesBar = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.ModesBar);
		self.helpTipParent = modesBar;

		if not self.helpTipParent then
			return;
		end

		local helpTipInfo = {
			text = HOUSING_MODES_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Exit,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetX = 0,
			offsetY = 32,
			system = HousingTutorialHelpTipSystems.ModesUnlocked,
			autoHideWhenTargetHides = true,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingModesUnlocked,
			hideArrow = true,
		};

		if self.OnAcknowledgeCallback then
			helpTipInfo.onAcknowledgeCallback = self.OnAcknowledgeCallback;
		end

		HelpTip:Show(self.helpTipParent, helpTipInfo);
	end
end

local function ShouldShowExpertModeTutorial()
	return not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingExpertMode);
end

HouseExpertModeTutorialMixin = {};

function HouseExpertModeTutorialMixin:CanBegin()
	return ShouldShowExpertModeTutorial();
end

function HouseExpertModeTutorialMixin:UpdateHelpTip()
	if self:CanBegin() then
		local subButtonBar = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.DecorExpertPlacementSubButtonBar);
		self.helpTipParent = subButtonBar;

		local helpTipInfo = {
			text = HOUSING_ADVANCED_MODE_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetX = 0,
			offsetY = 0,
			system = HousingTutorialHelpTipSystems.ExpertMode,
			autoHideWhenTargetHides = true,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingExpertMode,
		};

		HelpTip:Show(self.helpTipParent, helpTipInfo);
	end
end

local function ShouldShowCleanupModeTutorial()
	return not GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingCleanupMode);
end

HouseCleanupModeTutorialMixin = {};

function HouseCleanupModeTutorialMixin:CanBegin()
	return ShouldShowCleanupModeTutorial();
end

function HouseCleanupModeTutorialMixin:UpdateHelpTip()
	if self:CanBegin() then
		local cleanupButton = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.CleanupModeButton);
		self.helpTipParent = cleanupButton;

		local helpTipInfo = {
			text = HOUSING_CLEANUP_MODE_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetX = 0,
			offsetY = 0,
			system = HousingTutorialHelpTipSystems.CleanupMode,
			autoHideWhenTargetHides = true,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingCleanupMode,
		};

		HelpTip:Show(self.helpTipParent, helpTipInfo);
	end
end

HouseMarketTabTutorialMixin = {};

function HouseMarketTabTutorialMixin:CanBegin()
	if ShouldShowClippingAndGridTutorial() or GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingMarketTab) then
		return false;
	end

	local storagePanel = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.LayoutStorageFrame);
	return storagePanel:IsMarketTabShown();
end

function HouseMarketTabTutorialMixin:UpdateHelpTip()
	if self:CanBegin() then
		local tabSystem = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.HouseChestTabSystem);
		self.helpTipParent = tabSystem;

		local helpTipInfo = {
			text = HOUSING_MARKET_TAB_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
			offsetX = 200,
			offsetY = 0,
			system = HousingTutorialHelpTipSystems.MarketTab,
			autoHideWhenTargetHides = true,
			cvarBitfield = HOUSING_TUTORIAL_CVAR_BITFIELD,
			bitfieldFlag = Enum.FrameTutorialAccount.HousingMarketTab,
		};

		HelpTip:Show(self.helpTipParent, helpTipInfo);
	end
end

HouseDecorCustomizationsTutorialMixin = CreateFromMixins(HelpTipStateMachineBasedTutorialMixin);

function HouseDecorCustomizationsTutorialMixin:Init()
	self.helpTipInfos = HousingTutorialData.HouseDecorTutorial.CustomizationHelptips;

	local customizationActionHelpTipInfo = self.helpTipInfos[HousingTutorialStates.CustomizationTutorial.ActionButton]
	customizationActionHelpTipInfo.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.DecorCustomizationButton);
	customizationActionHelpTipInfo.onAcknowledgeCallback = function()
		self:BeginState(HousingTutorialStates.CustomizationTutorial.ClickDecor);
	end

	local clickDecorHelpTipInfo = self.helpTipInfos[HousingTutorialStates.CustomizationTutorial.ClickDecor];
	clickDecorHelpTipInfo.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.EnterDecorModeButton);
	clickDecorHelpTipInfo.onAcknowledgeCallback = function()
		self:AcknowledgeTutorial();
	end

	HelpTipStateMachineBasedTutorialMixin.Init(
		self,
		self.helpTipInfos,
		HousingTutorialHelpTipSystems.Customize,
		HousingTutorialStates.CustomizationTutorial,
		HousingTutorialStates.CustomizationTutorial.ActionButton,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		Enum.FrameTutorialAccount.HousingDecorCustomization
	);
end

HouseLayoutTutorialMixin = CreateFromMixins(HelpTipStateMachineBasedTutorialMixin);

function HouseLayoutTutorialMixin:Init()
	self.helpTipInfos = HousingTutorialData.HouseDecorTutorial.LayoutHelptips;

	local layoutActionHelpTipInfo = self.helpTipInfos[HousingTutorialStates.LayoutTutorial.ActionButton]
	layoutActionHelpTipInfo.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.DecorLayoutButton);
	local storagePanel = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.LayoutStorageFrame);
	layoutActionHelpTipInfo.onAcknowledgeCallback = function()
		storagePanel:SetCollapsed(false);
		self:BeginState(HousingTutorialStates.LayoutTutorial.Chest);
	end

	local layoutChestHelpTipInfo = self.helpTipInfos[HousingTutorialStates.LayoutTutorial.Chest];
	layoutChestHelpTipInfo.parent = storagePanel.OptionsContainer;
	layoutChestHelpTipInfo.onAcknowledgeCallback = function()
		self:BeginState(HousingTutorialStates.LayoutTutorial.Floors);
	end

	local layoutFloorsHelpTipInfo = self.helpTipInfos[HousingTutorialStates.LayoutTutorial.Floors];
	layoutFloorsHelpTipInfo.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseDecorTutorial.LayoutFloorsFrame);
	layoutFloorsHelpTipInfo.onAcknowledgeCallback = function()
		self:AcknowledgeTutorial();
	end

	HelpTipStateMachineBasedTutorialMixin.Init(
		self,
		self.helpTipInfos,
		HousingTutorialHelpTipSystems.Layout,
		HousingTutorialStates.LayoutTutorial,
		HousingTutorialStates.LayoutTutorial.ActionButton,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		Enum.FrameTutorialAccount.HousingDecorLayout
	);
end
