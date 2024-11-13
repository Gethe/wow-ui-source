function BonusObjectiveDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	if not mapID or self.hidePins then
		return;
	end

	local taskInfo = C_TaskQuest.GetQuestsOnMap(mapID);

	if taskInfo and #taskInfo > 0 then
		for i, info in ipairs(taskInfo) do
			if MapUtil.ShouldShowTask(mapID, info) and not QuestUtils_IsQuestWorldQuest(info.questID) then
				self:GetMap():AcquirePin("BonusObjectivePinTemplate", info);
			end
		end
	end
end