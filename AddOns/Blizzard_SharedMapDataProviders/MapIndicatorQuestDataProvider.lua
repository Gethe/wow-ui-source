MapIndicatorQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapIndicatorQuestDataProviderMixin:OnShow()
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function MapIndicatorQuestDataProviderMixin:OnHide()
	self:UnregisterEvent("QUEST_LOG_UPDATE");
end

function MapIndicatorQuestDataProviderMixin:OnEvent(event, ...)
	if (event == "QUEST_LOG_UPDATE") then
		self:RefreshAllData();
	end
end

function MapIndicatorQuestDataProviderMixin:GetPinTemplate()
	return "MapIndicatorQuestPinTemplate";
end

function MapIndicatorQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function MapIndicatorQuestDataProviderMixin:RefreshAllData()
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID);

	if (questsOnMap) then
		for i, info in ipairs(questsOnMap) do
			if(info.isMapIndicatorQuest) then
				if (info.type == Enum.QuestTagType.Islands and not ShouldShowIslandsWeeklyPOI()) then
					break;
				else
					self:AddMapIndicatorQuest(info);
				end
			end
		end
	end
end

function MapIndicatorQuestDataProviderMixin:AddMapIndicatorQuest(info)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());

	pin.questID = info.questID;
	pin.numObjectives = C_QuestLog.GetNumQuestObjectives(pin.questID);
	pin.shouldShowObjectivesAsStatusBar = true;
	pin.questRewardTooltipStyle = TOOLTIP_QUEST_REWARDS_PRIORITIZE_CURRENCY_OVER_ITEM;

	local worldQuestType = info.type;
	local inProgress = false; --We don't want this to display like a normal quest that's in progress.
	local tagInfo = C_QuestLog.GetQuestTagInfo(pin.questID);

	local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(worldQuestType, inProgress, tagInfo.tradeSkillLineID, pin.questID);
	pin.Icon:SetAtlas(atlas);
	pin.Icon:SetSize(width, height);
	pin:SetPosition(info.x, info.y);
	pin:Show();
end

MapIndicatorQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);

function MapIndicatorQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self);
	self:SetScalingLimits(1, 0.8, 0.8);
end

function MapIndicatorQuestPinMixin:OnAcquired()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ACTIVE_QUEST");
end

function MapIndicatorQuestPinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function MapIndicatorQuestPinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end
