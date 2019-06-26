DungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap", "SHOW_DUNGEON_ENTRANCES");

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
		self:GetMap():AcquirePin("DungeonEntrancePinTemplate", dungeonEntranceInfo);
	end
end

--[[ Pin ]]--
DungeonEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");

function DungeonEntrancePinMixin:OnAcquired(dungeonEntranceInfo) -- override
	BaseMapPoiPinMixin.OnAcquired(self, dungeonEntranceInfo);

	self.journalInstanceID = dungeonEntranceInfo.journalInstanceID;
end

function DungeonEntrancePinMixin:OnClick()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.journalInstanceID);
end
