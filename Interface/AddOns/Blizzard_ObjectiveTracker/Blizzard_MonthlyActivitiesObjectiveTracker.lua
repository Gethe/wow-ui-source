local settings = {
	headerText = TRACKER_HEADER_MONTHLY_ACTIVITIES,
	events = { "PERKS_ACTIVITY_COMPLETED", "PERKS_ACTIVITIES_TRACKED_UPDATED", "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED" },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
};

MonthlyActivitiesObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function MonthlyActivitiesObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "PERKS_ACTIVITY_COMPLETED" then
		local perksActivityID = ...;
		local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;
		for i = 1, #trackedActivities do
			local activityID = trackedActivities[i];
			if activityID == perksActivityID then
				PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES);
				local block = self:GetExistingBlock(activityID);
				if block then
					block:PlayTurnInAnimation();
				end
				break;
			end
		end
	elseif event == "PERKS_ACTIVITIES_TRACKED_UPDATED" then
		self:MarkDirty();
	elseif event == "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED" then
		local perksActivityID, added = ...;
		if added then
			self:SetNeedsFanfare(perksActivityID);
		end
		self:MarkDirty();
	end
end

function MonthlyActivitiesObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(block.id);
		ChatEdit_InsertLink(perksActivityLink);
	elseif mouseButton ~= "RightButton" then
		CloseDropDownMenus();
		if not EncounterJournal then
			EncounterJournal_LoadUI();
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			self:UntrackPerksActivity(block.id);
		else
			MonthlyActivitiesFrame_OpenFrameToActivity(block.id);
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		self:ToggleDropDown(block);
	end
end

function MonthlyActivitiesObjectiveTrackerMixin:InitDropDown(block)
	local info = UIDropDownMenu_CreateInfo();
	info.text = block.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = function (button, ...) self:OpenFrameToActivity(...); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = function (button, ...) self:UntrackPerksActivity(...); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function MonthlyActivitiesObjectiveTrackerMixin:OpenFrameToActivity(activityID)
	if not EncounterJournal then
		EncounterJournal_LoadUI();
	end
	MonthlyActivitiesFrame_OpenFrameToActivity(activityID);
end

function MonthlyActivitiesObjectiveTrackerMixin:UntrackPerksActivity(activityID)
	C_PerksActivities.RemoveTrackedPerksActivity(activityID);
end

function MonthlyActivitiesObjectiveTrackerMixin:LayoutContents()
	local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;

	for i = 1, #trackedActivities do
		local activityID = trackedActivities[i];
		local activityInfo = C_PerksActivities.GetPerksActivityInfo(activityID);
		if activityInfo and not activityInfo.completed then
			if not self:AddActivity(activityInfo) then
				return;
			end
		end
	end
end

function MonthlyActivitiesObjectiveTrackerMixin:AddActivity(activityInfo)
	local activityName = activityInfo.activityName;
	local requirements = activityInfo.requirementsList;

	local block = self:GetBlock(activityInfo.ID);
	block.name = activityName;
	block:SetHeader(activityName);
	-- criteria
	for index, requirement in ipairs(requirements) do
		if not requirement.completed then
			local criteriaString = requirement.requirementText;
			criteriaString = string.gsub(criteriaString, " / ", "/");
			block:AddObjective(index, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, OBJECTIVE_TRACKER_COLOR["Normal"]);
		end
	end
	
	return self:LayoutBlock(block);
end