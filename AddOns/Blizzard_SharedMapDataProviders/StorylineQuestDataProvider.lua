StorylineQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function StorylineQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("StorylineQuestPinTemplate");
end

function StorylineQuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent) and (mapInfo.mapType ~= Enum.UIMapType.World) and (mapInfo.mapType ~= Enum.UIMapType.Cosmic) then
		for _, questLineInfo in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
			if (not questLineInfo.isHidden or IsTrackingHiddenQuests()) then
				local pin = self:GetMap():AcquirePin("StorylineQuestPinTemplate", questLineInfo.questID);
				pin:SetPosition(questLineInfo.x, questLineInfo.y);
				pin:Show();
			end
		end
	end
end

function StorylineQuestDataProviderMixin:OnShow()
	self:RegisterEvent("QUESTLINE_UPDATE");
end

function StorylineQuestDataProviderMixin:OnHide()
	self:UnregisterEvent("QUESTLINE_UPDATE");
end

function StorylineQuestDataProviderMixin:OnEvent(event, ...)
	if (event == "QUESTLINE_UPDATE") then
		self:RefreshAllData();
	end
end

StorylineQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function StorylineQuestPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_STORY_LINE");
end

function StorylineQuestPinMixin:OnAcquired(questID)
	self.questID = questID;
	self.mapID = self:GetMap():GetMapID();
	local questLineInfo = C_QuestLine.GetQuestLineInfo(self.questID, self.mapID);
	if (questLineInfo.isLegendary) then
		self.Texture:SetAtlas("QuestLegendary", true);
	elseif (questLineInfo.isHidden) then
		self.Texture:SetAtlas("TrivialQuests", true);
	else
		self.Texture:SetAtlas("QuestNormal", true);
	end
	self.Below:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Below);
	self.Above:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Above);
	self.Texture:SetDesaturated(questLineInfo.floorLocation ~= Enum.QuestLineFloorLocation.Same);
end

function StorylineQuestPinMixin:OnMouseEnter()
	local questLineInfo = C_QuestLine.GetQuestLineInfo(self.questID, self.mapID);
	if (questLineInfo) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT");
		WorldMapTooltip:SetText(questLineInfo.questName);
		WorldMapTooltip:AddLine(AVAILABLE_QUEST, 1, 1, 1, true);
		if (questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Below) then
			WorldMapTooltip:AddLine(QUESTLINE_LOCATED_BELOW, 0.5, 0.5, 0.5, true);
		elseif (questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Above) then
			WorldMapTooltip:AddLine(QUESTLINE_LOCATED_ABOVE, 0.5, 0.5, 0.5, true);
		end
		WorldMapTooltip:Show();
	end
end

function StorylineQuestPinMixin:OnMouseLeave()
	WorldMapTooltip:Hide();
end