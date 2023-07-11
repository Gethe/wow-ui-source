StorylineQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function StorylineQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("StorylineQuestPinTemplate");
end

local function GetStoryLinePinType(questLineInfo)
	if questLineInfo then
		if (questLineInfo.isDaily) then
			return "Daily";
		elseif (questLineInfo.isHidden) then
			return "Trivial";
		elseif QuestUtil.ShouldQuestIconsUseCampaignAppearance(questLineInfo.questID) then
			return "Campaign";
		elseif (questLineInfo.isImportant) then
			return "Important";
		elseif (questLineInfo.isLegendary) then
			return "Legendary";
		end
	end

	return "Normal";
end

function StorylineQuestDataProviderMixin:ShouldShowQuestLine(questLineInfo)
	return questLineInfo and (not C_QuestLog.IsOnQuest(questLineInfo.questID) and (not questLineInfo.isHidden or C_Minimap.IsTrackingHiddenQuests()));
end

function StorylineQuestDataProviderMixin:CheckAddPin(questLineInfo)
	if self:ShouldShowQuestLine(questLineInfo) then
		local pin = self:GetMap():AcquirePin("StorylineQuestPinTemplate", questLineInfo, GetStoryLinePinType(questLineInfo));
		pin:SetPosition(questLineInfo.x, questLineInfo.y);
		pin:Show();
	end
end

function StorylineQuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType)) then
		for _, questLineInfo in pairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
			self:CheckAddPin(questLineInfo);
		end

		local forceVisibleQuests = C_QuestLine.GetForceVisibleQuests(mapID);
		for index, questID in ipairs(forceVisibleQuests) do
			self:CheckAddPin(C_QuestLine.GetQuestLineInfo(questID, mapID));
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

local storyLinePinData =
{
	Trivial = { level = 1, atlas = "TrivialQuests", },
	Daily =	{ level = 2, atlas = "QuestDaily", },
	Normal = { level = 3, atlas = "QuestNormal", },
	Campaign = { level = 4, atlas = "Quest-Campaign-Available", },
	Important = { level = 5, atlas = "Quest-Important-Available", },
	Legendary = { level = 6, atlas = "UI-QuestPoiLegendary-QuestBang", },
};

local function GetStoryLinePinLevel(questType)
	local info = storyLinePinData[questType];
	return info and info.level or 0;
end

local function GetStoryLinePinAtlas(questType)
	local info = storyLinePinData[questType];
	return info and info.atlas or "QuestNormal";
end

function StorylineQuestPinMixin:OnAcquired(questLineInfo, questType)
	self.questID = questLineInfo.questID;
	self.questType = questType;
	self.mapID = self:GetMap():GetMapID();

	self:SetFrameLevelType(questType);

	self.Texture:SetAtlas(GetStoryLinePinAtlas(questType));
	self.Below:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Below);
	self.Above:SetShown(questLineInfo.floorLocation == Enum.QuestLineFloorLocation.Above);
	self.Texture:SetDesaturated(questLineInfo.floorLocation ~= Enum.QuestLineFloorLocation.Same);
end

function StorylineQuestPinMixin:SetFrameLevelType(questType)
	self:UseFrameLevelType("PIN_FRAME_LEVEL_STORY_LINE", GetStoryLinePinLevel(questType));
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