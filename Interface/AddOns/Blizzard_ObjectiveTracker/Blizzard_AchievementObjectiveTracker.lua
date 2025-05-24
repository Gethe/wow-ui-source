local settings = {
	headerText = TRACKER_HEADER_ACHIEVEMENTS,
	events = { "CONTENT_TRACKING_UPDATE", "TRACKED_ACHIEVEMENT_UPDATE", "TRACKED_ACHIEVEMENT_LIST_CHANGED", "ACHIEVEMENT_EARNED" },
	timedCriteria = { },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
};

AchievementObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local ARENA_CATEGORY = 165;
local MAX_CRITERIA_PER_ACHIEVEMENT = 5;
local TIMED_CRITERIA = { };

function AchievementObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "CONTENT_TRACKING_UPDATE" then
		local trackableType, id, added = ...;
		if trackableType == Enum.ContentTrackingType.Achievement then
			if added then
				self:SetNeedsFanfare(id);
			end
			self:MarkDirty();
		end
	elseif event == "TRACKED_ACHIEVEMENT_UPDATE" then
		local achievementID, criteriaID, elapsed, duration = ...;
		if elapsed and duration then
			-- we're already handling timer bars for achievements with visible criteria
			-- we use this system to handle timer bars for the rest
			local numCriteria = GetAchievementNumCriteria(achievementID);
			if numCriteria == 0 then
				local timedCriteria = self.timedCriteria[criteriaID] or {};
				timedCriteria.achievementID = achievementID;
				timedCriteria.startTime = GetTime() - elapsed;
				timedCriteria.duration = duration;
				self.timedCriteria[criteriaID] = timedCriteria;
			end
		end
		self:MarkDirty();
	elseif event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" then
		self:MarkDirty();
	elseif event == "ACHIEVEMENT_EARNED" then
		local achievementID = ...;
		local block = self:GetExistingBlock(achievementID);
		if block then
			block:PlayTurnInAnimation();
		end
	end
end

function AchievementObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	local achievementID = block.id;
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local achievementLink = GetAchievementLink(achievementID);
		if achievementLink then
			ChatEdit_InsertLink(achievementLink);
		end
	elseif mouseButton ~= "RightButton" then
		if not AchievementFrame then
			AchievementFrame_LoadUI();
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			self:UntrackAchievement(achievementID);
		elseif not AchievementFrame:IsShown() then
			AchievementFrame_ToggleAchievementFrame();
			AchievementFrame_SelectAchievement(achievementID);
		else
			if AchievementFrameAchievements.selection ~= achievementID then
				AchievementFrame_SelectAchievement(achievementID);
			else
				AchievementFrame_ToggleAchievementFrame();
			end
		end
	else
		MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
			rootDescription:SetTag("MENU_ACHIEVEMENT_TRACKER", block);

			local _, achievementName = GetAchievementInfo(block.id);
			rootDescription:CreateTitle(achievementName);
			rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, function()
				OpenAchievementFrameToAchievement(block.id);
			end);
			rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
				self:UntrackAchievement(block.id);
			end);
		end);
	end
end

function AchievementObjectiveTrackerMixin:UntrackAchievement(achievementID)
	C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID, Enum.ContentTrackingStopType.Manual);
	if AchievementFrameAchievements_ForceUpdate then
		AchievementFrameAchievements_ForceUpdate();
	end
end

function AchievementObjectiveTrackerMixin:LayoutContents()
	local _, instanceType = IsInInstance();
	local displayOnlyArena = CompactArenaFrame and CompactArenaFrame:IsShown() and (instanceType == "arena");
	local trackedAchievements = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement);

	for i = 1, #trackedAchievements do
		local achievementID = trackedAchievements[i];
		local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
		-- check filters
		local showAchievement = true;
		if wasEarnedByMe then
			showAchievement = false;
		elseif displayOnlyArena then
			if GetAchievementCategory(achievementID) ~= ARENA_CATEGORY then
				showAchievement = false;
			end
		end

		if showAchievement then
			if not self:AddAchievement(achievementID, achievementName, description) then
				return;
			end
		end
	end
end

function AchievementObjectiveTrackerMixin:AddAchievement(achievementID, achievementName, description)
	local block = self:GetBlock(achievementID);
	block:SetHeader(achievementName);
	-- criteria
	local numCriteria = GetAchievementNumCriteria(achievementID);
	if numCriteria > 0 then
		local numShownCriteria = 0;
		for criteriaIndex = 1, numCriteria do
			local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
			local colorStyle = eligible and OBJECTIVE_TRACKER_COLOR["Normal"] or OBJECTIVE_TRACKER_COLOR["Failed"];
			if criteriaCompleted or (numShownCriteria > MAX_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted) then
				-- Do not display this one
			elseif numShownCriteria == MAX_CRITERIA_PER_ACHIEVEMENT and numCriteria > (MAX_CRITERIA_PER_ACHIEVEMENT + 1) then
				-- We ran out of space to display incomplete criteria >_<
				block:AddObjective("Extra", "...", nil, nil, OBJECTIVE_DASH_STYLE_HIDE);
				numShownCriteria = numShownCriteria + 1;
			else
				if description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then
					-- progress bar
					if string.find(strlower(quantityString), "interface\\moneyframe") then	-- no easy way of telling it's a money progress bar
						criteriaString = quantityString.."\n"..description;
					else
						-- remove spaces so it matches the quest look, x/y
						criteriaString = string.gsub(quantityString, " / ", "/").." "..description;
					end
				else
					-- for meta criteria look up the achievement name
					if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
						local _;
						_, criteriaString = GetAchievementInfo(assetID);
					end
				end
				local line = block:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, colorStyle);
				numShownCriteria = numShownCriteria + 1;
				-- timer bar
				if duration and elapsed and elapsed < duration then
					block:AddTimerBar(duration, GetTime() - elapsed);
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
		for timedCriteriaID, timedCriteria in pairs(self.timedCriteria) do
			if timedCriteria.achievementID == achievementID then
				local elapsed = GetTime() - timedCriteria.startTime;
				if elapsed <= timedCriteria.duration then
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
		local line = block:AddObjective(1, description, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, colorStyle);
		if timerShown then
			block:AddTimerBar(timerCriteriaDuration, timerCriteriaStartTime);
		end
	end
	
	return self:LayoutBlock(block);
end