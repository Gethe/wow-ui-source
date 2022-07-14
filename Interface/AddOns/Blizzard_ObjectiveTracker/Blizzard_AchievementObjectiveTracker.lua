
local ARENA_CATEGORY = 165;
local MAX_CRITERIA_PER_ACHIEVEMENT = 5;

ACHIEVEMENT_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("ACHIEVEMENT_TRACKER_MODULE");
ACHIEVEMENT_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_ACHIEVEMENT;
ACHIEVEMENT_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT + OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED;
ACHIEVEMENT_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.AchievementHeader, TRACKER_HEADER_ACHIEVEMENTS, OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED);

local TIMED_CRITERIA = { };

function ACHIEVEMENT_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local achievementLink = GetAchievementLink(block.id);
		if ( achievementLink ) then
			ChatEdit_InsertLink(achievementLink);
		end
	elseif ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			AchievementObjectiveTracker_UntrackAchievement(_, block.id);
		elseif ( not AchievementFrame:IsShown() ) then
			AchievementFrame_ToggleAchievementFrame();
			AchievementFrame_SelectAchievement(block.id);
		else
			if ( AchievementFrameAchievements.selection ~= block.id ) then
				AchievementFrame_SelectAchievement(block.id);
			else
				AchievementFrame_ToggleAchievementFrame();
			end
		end
	else
		ObjectiveTracker_ToggleDropDown(block, AchievementObjectiveTracker_OnOpenDropDown);
	end
end

function ACHIEVEMENT_TRACKER_MODULE:GetDebugReportInfo(block)
	return { debugType = "TrackedAchievement", achievementID = block.id, };
end

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

function AchievementObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;
	local _, achievementName, _, completed, _, _, _, _, _, icon = GetAchievementInfo(block.id);

	local info = UIDropDownMenu_CreateInfo();
	info.text = achievementName;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_ACHIEVEMENT;
	info.func = function (button, ...) OpenAchievementFrameToAchievement(...); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = AchievementObjectiveTracker_UntrackAchievement;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function AchievementObjectiveTracker_UntrackAchievement(dropDownButton, achievementID)
	RemoveTrackedAchievement(achievementID);
	if ( AchievementFrame ) then
		AchievementFrameAchievements_ForceUpdate();
	end
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************

function ACHIEVEMENT_TRACKER_MODULE:Update()

	self:BeginLayout();

	local _, instanceType = IsInInstance();
	local displayOnlyArena = ArenaEnemyFrames and ArenaEnemyFrames:IsShown() and (instanceType == "arena");
	local trackedAchievements = { GetTrackedAchievements() };

	for i = 1, #trackedAchievements do
		local achievementID = trackedAchievements[i];
		local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
		-- check filters
		local showAchievement = true;
		if ( wasEarnedByMe ) then
			showAchievement = false;
		elseif ( displayOnlyArena ) then
			if ( GetAchievementCategory(achievementID) ~= ARENA_CATEGORY ) then
				showAchievement = false;
			end
		end

		if ( showAchievement ) then
			local block = self:GetBlock(achievementID);
			self:SetBlockHeader(block, achievementName);
			-- criteria
			local numCriteria = GetAchievementNumCriteria(achievementID);
			if ( numCriteria > 0 ) then
				local numShownCriteria = 0;
				for criteriaIndex = 1, numCriteria do
					local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
					local colorStyle = eligible and OBJECTIVE_TRACKER_COLOR["Normal"] or OBJECTIVE_TRACKER_COLOR["Failed"];
					if ( criteriaCompleted or ( numShownCriteria > MAX_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted ) ) then
						-- Do not display this one
					elseif ( numShownCriteria == MAX_CRITERIA_PER_ACHIEVEMENT and numCriteria > (MAX_CRITERIA_PER_ACHIEVEMENT + 1) ) then
						-- We ran out of space to display incomplete criteria >_<
						self:AddObjective(block, "Extra", "...", nil, nil, OBJECTIVE_DASH_STYLE_HIDE);
						numShownCriteria = numShownCriteria + 1;
					else
						if ( description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
							-- progress bar
							if ( string.find(strlower(quantityString), "interface\\moneyframe") ) then	-- no easy way of telling it's a money progress bar
								criteriaString = quantityString.."\n"..description;
							else
								-- remove spaces so it matches the quest look, x/y
								criteriaString = string.gsub(quantityString, " / ", "/").." "..description;
							end
						else
							-- for meta criteria look up the achievement name
							if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
								_, criteriaString = GetAchievementInfo(assetID);
							end
						end
						local line = self:AddObjective(block, criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, colorStyle);
						numShownCriteria = numShownCriteria + 1;
						-- timer bar
						if ( duration and elapsed and elapsed < duration ) then
							self:AddTimerBar(block, line, duration, GetTime() - elapsed);
						elseif ( line.TimerBar ) then
							self:FreeTimerBar(block, line);
						end
					end
				end
			else
				-- single criteria type of achievement
				-- check if we're supposed to show a timer bar for this
				local timerShown = false;
				local timerFailed = false;
				local timerCriteriaDuration = 0;
				local timerCriteriaStartTime = 0;
				for timedCriteriaID, timedCriteria in next, TIMED_CRITERIA do
					if ( timedCriteria.achievementID == achievementID ) then
						local elapsed = GetTime() - timedCriteria.startTime;
						if ( elapsed <= timedCriteria.duration ) then
							timerCriteriaDuration = timedCriteria.duration;
							timerCriteriaStartTime = timedCriteria.startTime;
							timerShown = true;
						else
							timerFailed = true;
						end
						break;
					end
				end
				local colorStyle = (not timerFailed and IsAchievementEligible(achievementID)) and OBJECTIVE_TRACKER_COLOR["Normal"] or OBJECTIVE_TRACKER_COLOR["Failed"];
				local line = self:AddObjective(block, 1, description, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, colorStyle);
				if ( timerShown ) then
					self:AddTimerBar(block, line, timerCriteriaDuration, timerCriteriaStartTime);
				elseif ( line.TimerBar ) then
					self:FreeTimerBar(block, line);
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

function AchievementObjectiveTracker_OnAchievementUpdate(achievementID, criteriaID, elapsed, duration)
	if ( not elapsed or not duration ) then
		-- Don't do anything
	else
		-- we're already handling timer bars for achievements with visible criteria
		-- we use this system to handle timer bars for the rest
		local numCriteria = GetAchievementNumCriteria(achievementID);
		if ( numCriteria == 0 ) then
			local timedCriteria = TIMED_CRITERIA[criteriaID] or {};
			timedCriteria.achievementID = achievementID;
			timedCriteria.startTime = GetTime() - elapsed;
			timedCriteria.duration = duration;
			TIMED_CRITERIA[criteriaID] = timedCriteria;
		end
	end
	if ( IsTrackedAchievement(achievementID) ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT);
	else
		TIMED_CRITERIA[criteriaID] = nil;
	end
end