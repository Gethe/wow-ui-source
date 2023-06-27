
MONTHLY_ACTIVITIES_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("MONTHLY_ACTIVITIES_TRACKER_MODULE");
MONTHLY_ACTIVITIES_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_MONTHLY_ACTIVITIES;
MONTHLY_ACTIVITIES_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.MonthlyActivitiesHeader, TRACKER_HEADER_MONTHLY_ACTIVITIES, OBJECTIVE_TRACKER_UPDATE_MONTHLY_ACTIVITY_ADDED);

function MONTHLY_ACTIVITIES_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(block.id);
		ChatEdit_InsertLink(perksActivityLink);
	elseif ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( not EncounterJournal ) then
			EncounterJournal_LoadUI();
		end
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(_, block.id);
		else
			MonthlyActivitiesFrame_OpenFrameToActivity(block.id);
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		ObjectiveTracker_ToggleDropDown(block, MonthlyActivitiesObjectiveTracker_OnOpenDropDown);
	end
end

function MONTHLY_ACTIVITIES_TRACKER_MODULE:GetDebugReportInfo(block)
	return { debugType = "TrackedPerksAcitivity", perksActivityID = block.id, };
end

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

function MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(activityID)
	if ( not EncounterJournal ) then
		EncounterJournal_LoadUI();
	end
	MonthlyActivitiesFrame_OpenFrameToActivity(activityID);
end

function MonthlyActivitiesObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;

	local info = UIDropDownMenu_CreateInfo();
	info.text = block.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
	info.func = function (button, ...) MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(...); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = MonthlyActivitiesObjectiveTracker_UntrackPerksActivity;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function MonthlyActivitiesObjectiveTracker_UntrackPerksActivity(dropDownButton, perksActivityID)
	C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID);
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function MONTHLY_ACTIVITIES_TRACKER_MODULE:Update()

	self:BeginLayout();

	local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;

	for i = 1, #trackedActivities do
		local activityID = trackedActivities[i];
		local activityInfo = C_PerksActivities.GetPerksActivityInfo(activityID);
		if activityInfo and not activityInfo.completed then
			local activityName = activityInfo.activityName;
			local requirements = activityInfo.requirementsList;

			local block = self:GetBlock(activityID);
			block.name = activityName;
			self:SetBlockHeader(block, activityName);
			-- criteria
			for index, requirement in ipairs(requirements) do
				if not requirement.completed then
					local criteriaString = requirement.requirementText;
					criteriaString = string.gsub(criteriaString, " / ", "/");
					self:AddObjective(block, index, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, OBJECTIVE_TRACKER_COLOR["Normal"]);
				end
			end
			block:SetHeight(block.height);

			if ( ObjectiveTracker_AddBlock(block) ) then
				block:Show();
				self:FreeUnusedLines(block);
			else
				block.used = false;
				break;
			end
		end
	end

	self:EndLayout();
end

function MonthlyActivitiesObjectiveTracker_OnActivityCompleted(perksActivityID)
	local trackedActivities = C_PerksActivities.GetTrackedPerksActivities().trackedIDs;
	for i = 1, #trackedActivities do
		local activityID = trackedActivities[i];
		if ( activityID == perksActivityID ) then
			PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETING_ACTIVITIES);
			break;
		end
	end
end