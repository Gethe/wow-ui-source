function ScenarioQueueFrame_Update()
	local mode, submode = GetLFGMode(LE_LFG_CATEGORY_SCENARIO);
	local checkedList;
	if ( LFD_IsEmpowered() and mode ~= "queued" and mode ~= "suspended") then
		checkedList = LFGEnabledList;
	else
		checkedList = LFGQueuedForList[LE_LFG_CATEGORY_SCENARIO];
	end

	ScenariosList = GetScenariosChoiceOrder(ScenariosList);

	LFGQueueFrame_UpdateLFGDungeonList(ScenariosList, ScenariosHiddenByCollapseList, checkedList, SCENARIOS_CURRENT_FILTER);
	 
	ScenarioQueueFrameSpecific_Update();
end
