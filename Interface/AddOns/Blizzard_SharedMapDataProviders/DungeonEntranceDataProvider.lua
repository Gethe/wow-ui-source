DungeonEntranceDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DungeonEntranceDataProviderMixin:Init("showDungeonEntrancesOnMap");

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
		pin.dataProvider = self;
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

function DungeonEntrancePinMixin:GetHighlightType() -- override
	if QuestSuperTracking_ShouldHighlightDungeons(self:GetMap():GetMapID()) then
		return MapPinHighlightType.SupertrackedHighlight;
	end
	
	return MapPinHighlightType.None;
end

function DungeonEntrancePinMixin:UpdateSupertrackedHighlight()
	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);
end