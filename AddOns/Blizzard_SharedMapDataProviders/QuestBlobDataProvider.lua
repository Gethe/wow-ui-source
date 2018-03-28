
QuestBlobDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function QuestBlobDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("QuestBlobPinTemplate", "QuestPOIFrame");

	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("QuestBlobPinTemplate");
	pin.dataProvider = self;
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;
end

function QuestBlobDataProviderMixin:OnMapChanged()
	self.pin:OnMapChanged();
end

--[[ Quest Blob Pin ]]--
QuestBlobPinMixin = CreateFromMixins(MapCanvasPinMixin);

function QuestBlobPinMixin:OnLoad()
	self:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(1.0);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_BLOB");
	self.questID = 0;
end

function QuestBlobPinMixin:OnShow()
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	self:SetQuestID(GetSuperTrackedQuestID());
end

function QuestBlobPinMixin:OnHide()
	self:UnregisterEvent("SUPER_TRACKED_QUEST_CHANGED");
end

function QuestBlobPinMixin:OnEvent(event, ...)
	if event == "SUPER_TRACKED_QUEST_CHANGED" then
		self:SetQuestID(GetSuperTrackedQuestID());
	end
end

function QuestBlobPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function QuestBlobPinMixin:OnCanvasScaleChanged()
	-- need to wait until end of the frame to update
	self:MarkDirty();
end

function QuestBlobPinMixin:MarkDirty()
	if not self.dirty then
		self.dirty = true;
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function QuestBlobPinMixin:SetQuestID(questID)
	self.questID = questID;
	self:Refresh();
end

function QuestBlobPinMixin:OnUpdate()
	self.dirty = nil;
	self:SetScript("OnUpdate", nil);
	self:Refresh();
end

function QuestBlobPinMixin:Refresh()
	self:DrawNone();
	if self.mapAllowsBlobs and self.questID > 0 and not IsQuestComplete(self.questID) then
		self:DrawBlob(self.questID, true);
	end
end

function QuestBlobPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	self.mapAllowsBlobs = MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType);
	self:SetMapID(mapID);
	self:Refresh();
end