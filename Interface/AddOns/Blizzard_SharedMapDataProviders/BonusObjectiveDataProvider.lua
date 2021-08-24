BonusObjectiveDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function BonusObjectiveDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BonusObjectivePinTemplate");
end

function BonusObjectiveDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	-- TODO:: This should be converted over once we have the quest log integrated with the new world map. 
	if QuestMapFrame.DetailsFrame.questID then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);

	if taskInfo and #taskInfo > 0 then
		for i, info in ipairs(taskInfo) do
			if MapUtil.ShouldShowTask(mapID, info) and not QuestUtils_IsQuestWorldQuest(info.questId) then
				self:GetMap():AcquirePin("BonusObjectivePinTemplate", info);
			end
		end
	end
end

--[[ Bonus Objective Pin ]]--
BonusObjectivePinMixin = CreateFromMixins(MapCanvasPinMixin);

function BonusObjectivePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.825, 0.85);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function BonusObjectivePinMixin:OnAcquired(taskInfo)
	self:SetPosition(taskInfo.x, taskInfo.y);
	self.questID = taskInfo.questId;
	self.numObjectives = taskInfo.numObjectives;
end

function BonusObjectivePinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function BonusObjectivePinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end