
HouseFinderWatcherMixin = {};

local HOUSE_FINDER_WATCHER_EVENTS = {
	"NEIGHBORHOOD_LIST_UPDATED",
	"HOUSE_FINDER_NEIGHBORHOOD_DATA_RECIEVED",
}

function HouseFinderWatcherMixin:StartWatching()
	if self.isWatching then
		return;
	end

	self.isWatching = true;

	for _i, event in ipairs(HOUSE_FINDER_WATCHER_EVENTS) do
		Dispatcher:RegisterEvent(event, self);
	end

	EventRegistry:RegisterCallback("HouseFinder.PlotInfoFrameVisibilityUpdated", self.OnPlotInfoFrameVisibilityUpdated, self);
	EventRegistry:RegisterCallback("HouseFinder.NeighborhoodListShown", self.OnNeighborhoodListShown, self);
end

function HouseFinderWatcherMixin:StopWatching()
	if not self.isWatching then
		return;
	end

	self.isWatching = false;

	for _i, event in ipairs(HOUSE_FINDER_WATCHER_EVENTS) do
		Dispatcher:UnregisterEvent(event, self);
	end

	EventRegistry:UnregisterCallback("HouseFinder.PlotInfoFrameVisibilityUpdated", self);
	EventRegistry:UnregisterCallback("HouseFinder.NeighborhoodListShown", self);
end

function HouseFinderWatcherMixin:NEIGHBORHOOD_LIST_UPDATED()
	self:InitHouseFinderMapTutorial();
end

function HouseFinderWatcherMixin:HOUSE_FINDER_NEIGHBORHOOD_DATA_RECIEVED()
	self:InitHouseFinderMapTutorial();
end

function HouseFinderWatcherMixin:OnNeighborhoodListShown()
	self:InitHouseFinderMapTutorial();
end

function HouseFinderWatcherMixin:InitHouseFinderMapTutorial()
	if not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderMap) then
		if not self.houseFinderMapTutorial then
			self.houseFinderMapTutorial = CreateAndInitFromMixin(HouseFinderMapTutorialMixin);
		end

		self.houseFinderMapTutorial:BeginInitialState();
	end
end

function HouseFinderWatcherMixin:OnPlotInfoFrameVisibilityUpdated(plotInfoVisible)
	if C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderVisitHouse) then
		return;
	end

	local visitHouseButton = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseFinderTutorial.VisitHouseButton);
	local helpTipInfo = HousingTutorialData.HouseFinderTutorial.VisitHouseHelpTipInfo;
	if plotInfoVisible then
		HelpTip:Show(visitHouseButton, helpTipInfo);
	else
		HelpTip:Hide(visitHouseButton, helpTipInfo.text);
	end
end

HouseFinderMapTutorialMixin = CreateFromMixins(HelpTipStateMachineBasedTutorialMixin);

function HouseFinderMapTutorialMixin:Init()
	self.helpTipInfos = HousingTutorialData.HouseFinderTutorial.MapHelpTipInfos;

	local neighborhoodListHelpTip = self.helpTipInfos[HousingTutorialStates.HouseFinderTutorial.NeighborhoodList];
	neighborhoodListHelpTip.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseFinderTutorial.NeighborhoodScrollFrame);
	neighborhoodListHelpTip.onAcknowledgeCallback = function()
		self:BeginState(HousingTutorialStates.HouseFinderTutorial.NeighborhoodMap);
	end;
	neighborhoodListHelpTip.onHideCallback = function(acknowledged, arg, reason)
		self:OnTutorialHidden(reason);
	end;

	local neighborhoodMapHelpTip = self.helpTipInfos[HousingTutorialStates.HouseFinderTutorial.NeighborhoodMap];
	neighborhoodMapHelpTip.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseFinderTutorial.NeighborhoodMapFrame);
	neighborhoodMapHelpTip.onAcknowledgeCallback = function()
		self:AcknowledgeTutorial();
	end;
	neighborhoodMapHelpTip.onHideCallback = function(acknowledged, arg, reason)
		self:OnTutorialHidden(reason);
	end;

	HelpTipStateMachineBasedTutorialMixin.Init(
		self,
		self.helpTipInfos,
		HousingTutorialHelpTipSystems.HouseFinderMap,
		HousingTutorialStates.HouseFinderTutorial,
		HousingTutorialStates.HouseFinderTutorial.NeighborhoodList,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		Enum.FrameTutorialAccount.HousingHouseFinderMap
	);
end

function HouseFinderMapTutorialMixin:StartPhase_NeighborhoodMap()
	self:ShowHelpTipByState(HousingTutorialStates.HouseFinderTutorial.NeighborhoodMap);

	local glow = true;
	local glowLoopCount = 2;
	self.helpTipParent:SetAllPinsByTemplateGlowing("HouseFinderPlotForSalePinTemplate", glow, glowLoopCount);
end

function HouseFinderMapTutorialMixin:StopPhase_NeighborhoodMap()
	local glow = false;
	local glowLoopCount = 2;
	self.helpTipParent:SetAllPinsByTemplateGlowing("HouseFinderPlotForSalePinTemplate", glow, glowLoopCount);

	self:HideHelpTipByState(HousingTutorialStates.HouseFinderTutorial.NeighborhoodMap);
end

function HouseFinderMapTutorialMixin:OnTutorialHidden(reason)	
	if self:IsShowingTutorialHelp() then
		HelpTip:HideAllSystem(self:GetSystem());
	end
	
	local houseFinderMapFrame = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HouseFinderTutorial.NeighborhoodMapFrame);
	local glow = false;
	houseFinderMapFrame:SetAllPinsByTemplateGlowing("HouseFinderPlotForSalePinTemplate", glow);
end
