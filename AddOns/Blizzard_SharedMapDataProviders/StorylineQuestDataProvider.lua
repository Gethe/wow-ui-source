StorylineQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function StorylineQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("StorylineQuestPinTemplate");
end

function StorylineQuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType)) then
		for _, questLineInfo in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
			if (not C_QuestLog.IsOnQuest(questLineInfo.questID) and (not questLineInfo.isHidden or IsTrackingHiddenQuests())) then
				local pin = self:GetMap():AcquirePin("StorylineQuestPinTemplate", questLineInfo.questID);
				pin:SetPosition(questLineInfo.x, questLineInfo.y);
				pin:Show();
			end
		end
	end
end

function StorylineQuestDataProviderMixin:OnShow()
	self:RegisterEvent("QUESTLINE_UPDATE");
	self:RequestQuestLinesForMap()
end

function StorylineQuestDataProviderMixin:OnHide()
	self:UnregisterEvent("QUESTLINE_UPDATE");
end

function StorylineQuestDataProviderMixin:OnMapChanged()
	self:RequestQuestLinesForMap()
	MapCanvasDataProviderMixin.OnMapChanged(self)
end

function StorylineQuestDataProviderMixin:OnEvent(event, ...)
	if (event == "QUESTLINE_UPDATE") then
		local requestRequired = ...;
		if(requestRequired) then
			self:RequestQuestLinesForMap()
		else
			self:RefreshAllData();
		end
	end
end

function StorylineQuestDataProviderMixin:RequestQuestLinesForMap()
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType)) then
		C_QuestLine.RequestQuestLinesForMap(mapID)
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
	if (questLineInfo.isDaily) then
		self.Texture:SetAtlas("QuestDaily", true);
	elseif (questLineInfo.isLegendary) then
		self.Texture:SetAtlas("QuestLegendary", true);
	elseif (questLineInfo.isHidden) then
		self.Texture:SetAtlas("TrivialQuests", true);
	elseif QuestUtil.ShouldQuestIconsUseCampaignAppearance(self.questID) then
		self.Texture:SetAtlas("Quest-Campaign-Available", true);
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
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(questLineInfo.questName);
		GameTooltip:AddLine(AVAILABLE_QUEST, 1, 1, 1, true);
		if (questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Below) then
			GameTooltip:AddLine(QUESTLINE_LOCATED_BELOW, 0.5, 0.5, 0.5, true);
		elseif (questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Above) then
			GameTooltip:AddLine(QUESTLINE_LOCATED_ABOVE, 0.5, 0.5, 0.5, true);
		end
		GameTooltip:Show();
	end
end

function StorylineQuestPinMixin:OnMouseLeave()
	GameTooltip:Hide();
end