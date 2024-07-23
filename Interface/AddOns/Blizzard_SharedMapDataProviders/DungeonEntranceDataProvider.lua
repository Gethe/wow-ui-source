DungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap");

function DungeonEntranceDataProviderMixin:OnShow()
	CVarMapCanvasDataProviderMixin.OnShow(self);
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function DungeonEntranceDataProviderMixin:OnHide()
	CVarMapCanvasDataProviderMixin.OnHide(self);
	EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
end


function DungeonEntranceDataProviderMixin:OnSuperTrackingChanged()
	for pin in self:GetMap():EnumeratePinsByTemplate("DungeonEntrancePinTemplate") do
		pin:UpdateSupertrackedHighlight();
	end
end

function DungeonEntranceDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DungeonEntrancePinTemplate");
end

function DungeonEntranceDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(mapID);
	for i, dungeonEntranceInfo in ipairs(dungeonEntrances) do
		local pin = self:GetMap():AcquirePin("DungeonEntrancePinTemplate", dungeonEntranceInfo);
		pin.dataProvider = self;
		pin:UpdateSupertrackedHighlight();
	end
end

--[[ Pin ]]--
DungeonEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");

function DungeonEntrancePinMixin:OnLoad()
	BaseMapPoiPinMixin.OnLoad(self);

	self:SetNudgeSourceRadius(1);
	self:SetNudgeSourceMagnitude(2, 2);
end

function DungeonEntrancePinMixin:OnAcquired(dungeonEntranceInfo) -- override
	SuperTrackablePoiPinMixin.OnAcquired(self, dungeonEntranceInfo);

	self.journalInstanceID = dungeonEntranceInfo.journalInstanceID;
    self.isRaid = select(11, EJ_GetInstanceInfo(self.journalInstanceID));
end

function DungeonEntrancePinMixin:ShouldMouseButtonBePassthrough(button)
	-- Dungeon entrances allow left click to super track and right click to open journal.
	-- Other buttons don't matter at this time.
	return false;
end

function DungeonEntrancePinMixin:UseTooltip()
	return true;
end

function DungeonEntrancePinMixin:GetFallbackName()
	return DUNGEON_MAP_PIN_FALLBACK_NAME;
end

function DungeonEntrancePinMixin:GetTooltipInstructions()
	return DUNGEON_POI_TOOLTIP_INSTRUCTION_LINE;
end

function DungeonEntrancePinMixin:OnMouseClickAction(button)
	SuperTrackablePinMixin.OnMouseClickAction(self, button);
	if button == "RightButton" then
		EncounterJournal_LoadUI();
		EncounterJournal_OpenJournal(nil, self.journalInstanceID);
	end
end

function DungeonEntrancePinMixin:GetHighlightType() -- override
	if QuestSuperTracking_ShouldHighlightDungeons(self:GetMap():GetMapID()) then
		return MapPinHighlightType.SupertrackedHighlight;
	end

	return MapPinHighlightType.None;
end

function DungeonEntrancePinMixin:UpdateSupertrackedHighlight()
	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);
end
