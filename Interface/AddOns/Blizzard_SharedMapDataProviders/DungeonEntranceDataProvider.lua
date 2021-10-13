DungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap", "SHOW_DUNGEON_ENTRANCES");

function DungeonEntranceDataProviderMixin:OnShow()
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function DungeonEntranceDataProviderMixin:OnHide()
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
		pin:UpdateSupertrackedHighlight();
	end
end

--[[ Pin ]]--
DungeonEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");

function DungeonEntrancePinMixin:OnAcquired(dungeonEntranceInfo) -- override
	BaseMapPoiPinMixin.OnAcquired(self, dungeonEntranceInfo);

	self.journalInstanceID = dungeonEntranceInfo.journalInstanceID;
end

function DungeonEntrancePinMixin:OnMouseClickAction()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.journalInstanceID);
end

function DungeonEntrancePinMixin:UpdateSupertrackedHighlight()
	local highlight = QuestSuperTracking_ShouldHighlightDungeons(self:GetMap():GetMapID());
	MapPinHighlight_CheckHighlightPin(highlight, self, self.Texture);
end