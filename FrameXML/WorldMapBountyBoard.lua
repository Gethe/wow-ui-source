WorldMapBountyBoardMixin = {};

function WorldMapBountyBoardMixin:OnLoad()
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self.bountyObjectivePool = CreateFramePool("FRAME", self, "WorldMapBountyBoardObjectiveTemplate");
	self.bountyTabPool = CreateFramePool("BUTTON", self, "WorldMapBountyBoardTabTemplate");

	self.BountyName:SetFontObjectsToTry(Game13Font_o1, Game12Font_o1, Game11Font_o1);

	self.minimumTabsToDisplay = 3;
end

function WorldMapBountyBoardMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		if not self:GetParent() or self:GetParent():IsVisible() then
			self:Refresh();
		end
	end
end

function WorldMapBountyBoardMixin:OnShow()
	if not self.isRefreshing then
		self:Refresh();
	end
end

function WorldMapBountyBoardMixin:SetMapAreaID(mapAreaID)
	if self.mapAreaID ~= mapAreaID then
		self.mapAreaID = mapAreaID;
		self:Refresh();
	end
end

function WorldMapBountyBoardMixin:GetDisplayLocation()
	return self.displayLocation;
end

function WorldMapBountyBoardMixin:SetSelectedBountyChangedCallback(selectedBountyChangedCallback)
	self.selectedBountyChangedCallback = selectedBountyChangedCallback;
end

function WorldMapBountyBoardMixin:IsWorldQuestCriteriaForSelectedBounty(questID)
	if self.bounties and self.selectedBountyIndex then
		local bounty = self.bounties[self.selectedBountyIndex];
		if bounty and IsQuestCriteriaForBounty(questID, bounty.questID) then
			return true;
		end
	end
	return false;
end

function WorldMapBountyBoardMixin:Clear()
	self.selectedBountyIndex = nil;
	self:Hide();
end

WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE = 1;
WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_BY_QUEST = 2;
WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NO_BOUNTIES = 3;

function WorldMapBountyBoardMixin:Refresh()
	assert(not self.isRefreshing);
	self.isRefreshing = true;

	self.firstCompletedTab = nil;
	self.TutorialBox:Hide();

	self.bountyTabPool:ReleaseAll();
	self.bountyObjectivePool:ReleaseAll();

	if not self.mapAreaID then
		self:Clear();
		self.isRefreshing = false;
		return;
	end

	self.bounties, self.displayLocation, self.lockedQuestID = GetQuestBountyInfoForMapID(self.mapAreaID, self.bounties);

	if not self.displayLocation then
		self:Clear();
		self.isRefreshing = false;
		return;
	end

	if self.lockedQuestID then
		self:SetLockedType(WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_BY_QUEST);
	elseif #self.bounties == 0 then
		self:SetLockedType(WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NO_BOUNTIES);

		self.selectedBountyIndex = nil;

		self:RefreshBountyTabs();
	else
		self:SetLockedType(WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE);
		self.selectedBountyIndex = self.bounties[self.selectedBountyIndex] and self.selectedBountyIndex or 1;

		self:RefreshBountyTabs();
		self:RefreshSelectedBounty();
	end

	self:Show();

	self:TryShowingIntroTutorial();
	self:TryShowingCompletionTutorial();

	self.isRefreshing = false;
end

function WorldMapBountyBoardMixin:SetLockedType(lockedType)
	self.lockedType = lockedType;

	self.DesaturatedTrackerBackground:SetShown(self.lockedType ~= WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE);
	self.Locked:SetShown(self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_BY_QUEST);

	if self.lockedType ~= WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE then
		self.BountyName:SetText(BOUNTY_BOARD_LOCKED_TITLE);
		self.BountyName:SetVertexColor(.5, .5, .5);

		self:ShowQuestObjectiveMarkers(0, 5, .3);
	else
		self.BountyName:SetVertexColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function WorldMapBountyBoardMixin:AnchorBountyTab(tab)
	local TAB_WIDTH = 44;
	local PADDING = -7;
	local startX = -((math.max(#self.bounties, self.minimumTabsToDisplay)  - 1) * (TAB_WIDTH + PADDING)) / 2;

	local offsetX = (PADDING + TAB_WIDTH) * (tab.bountyIndex - 1);
	tab:SetPoint("CENTER", self.TrackerBackground, "CENTER", startX + offsetX, 43);
end

function WorldMapBountyBoardMixin:RefreshBountyTabs()
	self.bountyTabPool:ReleaseAll();

	if self.lockedType ~= WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE and self.lockedType ~= WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NO_BOUNTIES then
		return;
	end

	for bountyIndex, bounty in ipairs(self.bounties) do
		local tab = self.bountyTabPool:Acquire();
		local selected = self.selectedBountyIndex == bountyIndex;
		tab:SetNormalAtlas(selected and "worldquest-tracker-ring-selected" or "worldquest-tracker-ring");
		if selected then 
			tab:SetHighlightTexture(nil);
		else
			tab:SetHighlightAtlas("worldquest-tracker-ring");
			tab:GetHighlightTexture():SetAlpha(0.4);
		end		
		if IsQuestComplete(bounty.questID) then
			tab.CheckMark:Show();
			if not self.firstCompletedTab then
				self.firstCompletedTab = tab;
			end
		else
			tab.CheckMark:Hide();
		end
		
		tab.Icon:SetTexture(bounty.icon);
		tab.Icon:Show();
		tab.EmptyIcon:Hide();
		tab.bountyIndex = bountyIndex;
		tab.isEmpty = false;

		self:AnchorBountyTab(tab);
		tab:Show();
	end

	for bountyIndex = #self.bounties + 1, self.minimumTabsToDisplay do
		local tab = self.bountyTabPool:Acquire();

		tab:SetNormalAtlas("worldquest-tracker-ring");
		tab:SetHighlightTexture(nil);
		tab.CheckMark:Hide();
		tab.Icon:Hide();
		tab.EmptyIcon:Show();
		tab.bountyIndex = bountyIndex;
		tab.isEmpty = true;

		self:AnchorBountyTab(tab);
		tab:Show();
	end
end

function WorldMapBountyBoardMixin:RefreshSelectedBounty()
	self.bountyObjectivePool:ReleaseAll();

	if self.lockedType ~= WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE then
		return;
	end

	if self.selectedBountyIndex then
		local bountyData = self.bounties[self.selectedBountyIndex];
		local questIndex = GetQuestLogIndexByID(bountyData.questID);
		if questIndex > 0 then
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(questIndex);
			if title then
				self.BountyName:SetText(title);

				self:RefreshSelectedBountyObjectives(bountyData);
				return;
			end
		end
	end

	self.BountyName:SetText(RETRIEVING_DATA);
	self.BountyName:SetVertexColor(RED_FONT_COLOR:GetRGB());
end

MAX_BOUNTY_OBJECTIVES = 7;
function WorldMapBountyBoardMixin:RefreshSelectedBountyObjectives(bountyData)
	local numCompleted, numTotal = self:CalculateBountySubObjectives(bountyData);

	if numTotal == 0 then
		return;
	end

	self:ShowQuestObjectiveMarkers(numCompleted, numTotal);
end

function WorldMapBountyBoardMixin:ShowQuestObjectiveMarkers(numCompleted, numTotal, alpha)
	local SUB_OBJECTIVE_FRAME_WIDTH = 35;

	local percentFull = (numTotal - 1) / (MAX_BOUNTY_OBJECTIVES - 1);
	local padding = Lerp(3, -9, percentFull);
	local startingOffsetX = -((SUB_OBJECTIVE_FRAME_WIDTH + padding) * (numTotal - 1)) / 2;

	self.bountyObjectivePool:ReleaseAll();
	for bountyObjectiveIndex = 1, numTotal do
		local bountyObjectiveFrame = self.bountyObjectivePool:Acquire();
		bountyObjectiveFrame:Show();

		local complete = bountyObjectiveIndex <= numCompleted;
		bountyObjectiveFrame.MarkerTexture:SetAtlas(complete and "worldquest-tracker-questmarker" or "worldquest-tracker-questmarker-gray", true);
		bountyObjectiveFrame.MarkerTexture:SetAlpha(alpha or 1.0);
		bountyObjectiveFrame.CheckMarkTexture:SetShown(complete);

		local offsetX = (padding + SUB_OBJECTIVE_FRAME_WIDTH) * (bountyObjectiveIndex - 1);
		bountyObjectiveFrame:SetPoint("CENTER", self.TrackerBackground, "CENTER", startingOffsetX + offsetX, -11);
	end
end

function WorldMapBountyBoardMixin:CalculateBountySubObjectives(bountyData)
	local numCompleted = 0;
	local numTotal = 0;

	for objectiveIndex = 1, bountyData.numObjectives do
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(bountyData.questID, objectiveIndex, false);
		if objectiveText and #objectiveText > 0 and numRequired > 0 then
			for objectiveSubIndex = 1, numRequired do
				if objectiveSubIndex <= numFulfilled then
					numCompleted = numCompleted + 1;
				end
				numTotal = numTotal + 1;

				if numTotal >= MAX_BOUNTY_OBJECTIVES then
					return numCompleted, numTotal;
				end
			end
		end
	end

	return numCompleted, numTotal;
end

function WorldMapBountyBoardMixin:SetSelectedBountyIndex(selectedBountyIndex)
	if self.selectedBountyIndex ~= selectedBountyIndex then
		self.selectedBountyIndex = selectedBountyIndex;
		PlaySound("UI_WorldQuest_Map_Select");
		self:RefreshBountyTabs();
		self:RefreshSelectedBounty();
		if self.selectedBountyChangedCallback then
			self.selectedBountyChangedCallback(self);
		end
	end
end

function WorldMapBountyBoardMixin:GetSelectedBountyIndex()
	return self.selectedBountyIndex;
end

local function AddObjectives(questID, numObjectives)
	for objectiveIndex = 1, numObjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false);
		if objectiveText and #objectiveText > 0 then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end
end

function WorldMapBountyBoardMixin:ShowBountyTooltip(bountyIndex)
	local bountyData = self.bounties[bountyIndex];
	self:SetTooltipOwner();

	local questIndex = GetQuestLogIndexByID(bountyData.questID);
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questIndex);
	if title then
		WorldMapTooltip:SetText(title, HIGHLIGHT_FONT_COLOR:GetRGB());

		WorldMap_AddQuestTimeToTooltip(bountyData.questID);

		local _, questDescription = GetQuestLogQuestText(questIndex);
		WorldMapTooltip:AddLine(questDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

		AddObjectives(bountyData.questID, bountyData.numObjectives);

		WorldMap_AddQuestRewardsToTooltip(bountyData.questID);
		WorldMapTooltip:Show();
	else
		WorldMapTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
		WorldMapTooltip:Show();
	end
end

function WorldMapBountyBoardMixin:SetTooltipOwner()
	local x = self:GetRight();
	if x >= GetScreenWidth() / 2 then
		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT", -100, -50);
	else
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -50);
	end	
end

function WorldMapBountyBoardMixin:ShowLockedByQuestTooltip()
	local questIndex = GetQuestLogIndexByID(self.lockedQuestID);
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questIndex);
	if title then
		self:SetTooltipOwner();

		WorldMapTooltip:SetText(BOUNTY_BOARD_LOCKED_TITLE, HIGHLIGHT_FONT_COLOR:GetRGB());

		local _, questDescription = GetQuestLogQuestText(questIndex);
		WorldMapTooltip:AddLine(questDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

		AddObjectives(self.lockedQuestID, GetNumQuestLeaderBoards(questIndex));

		WorldMapTooltip:Show();
	end
end

function WorldMapBountyBoardMixin:ShowLockedByNoBountiesTooltip(bountyIndex)
	self:SetTooltipOwner();

	local tooltipText;
	if bountyIndex then
		local daysUntilNext = bountyIndex - #self.bounties;
		tooltipText = _G["BOUNTY_BOARD_NO_BOUNTIES_DAYS_" .. daysUntilNext] or BOUNTY_BOARD_NO_BOUNTIES;
	else
		tooltipText = BOUNTY_BOARD_NO_BOUNTIES;
	end
	WorldMapTooltip:SetText(tooltipText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

	WorldMapTooltip:Show();
end

function WorldMapBountyBoardMixin:OnEnter()
	if self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE then
		if self.selectedBountyIndex then
			self:ShowBountyTooltip(self.selectedBountyIndex);
		end
	elseif self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_BY_QUEST then
		self:ShowLockedByQuestTooltip();
	elseif self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NO_BOUNTIES then
		self:ShowLockedByNoBountiesTooltip(nil);
	end
end

function WorldMapBountyBoardMixin:OnLeave()
	WorldMapTooltip:Hide();
end

function WorldMapBountyBoardMixin:OnTabEnter(tab)
	if tab.isEmpty then
		self:ShowLockedByNoBountiesTooltip(tab.bountyIndex);
	else
		self:ShowBountyTooltip(tab.bountyIndex);
	end
end

function WorldMapBountyBoardMixin:OnTabLeave(tab)
	self:OnLeave();
end

function WorldMapBountyBoardMixin:OnTabClick(tab)
	if not tab.isEmpty then
		self:SetSelectedBountyIndex(tab.bountyIndex);
	end
end

function WorldMapBountyBoardMixin:TryShowingIntroTutorial()
	if self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE then
		if not self.TutorialBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOUNTY_INTRO) then
			self.TutorialBox.activeTutorial = LE_FRAME_TUTORIAL_BOUNTY_INTRO;

			self.TutorialBox.Text:SetText(BOUNTY_TUTORIAL_INTRO);

			if self:GetDisplayLocation() == LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_RIGHT or self:GetDisplayLocation() == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_RIGHT then
				SetClampedTextureRotation(self.TutorialBox.Arrow.Arrow, 270);
				SetClampedTextureRotation(self.TutorialBox.Arrow.Glow, 270);

				self.TutorialBox.Arrow:ClearAllPoints();
				self.TutorialBox.Arrow:SetPoint("TOPLEFT", self.TutorialBox, "TOPRIGHT", -4, -15);

				self.TutorialBox.Arrow.Glow:ClearAllPoints();
				self.TutorialBox.Arrow.Glow:SetPoint("CENTER", self.TutorialBox.Arrow.Arrow, "CENTER", 2, 0);

				self.TutorialBox:ClearAllPoints();
				self.TutorialBox:SetPoint("RIGHT", self, "LEFT", 10, -15);
			else
				SetClampedTextureRotation(self.TutorialBox.Arrow.Arrow, 90);
				SetClampedTextureRotation(self.TutorialBox.Arrow.Glow, 90);

				self.TutorialBox.Arrow:ClearAllPoints();
				self.TutorialBox.Arrow:SetPoint("TOPLEFT", self.TutorialBox, "TOPLEFT", -17, -15);

				self.TutorialBox.Arrow.Glow:ClearAllPoints();
				self.TutorialBox.Arrow.Glow:SetPoint("CENTER", self.TutorialBox.Arrow.Arrow, "CENTER", -3, 0);

				self.TutorialBox:ClearAllPoints();
				self.TutorialBox:SetPoint("LEFT", self, "RIGHT", -10, -15);
			end

			self.TutorialBox:Show();
		end
	end
end

function WorldMapBountyBoardMixin:TryShowingCompletionTutorial()
	if self.lockedType == WORLD_MAP_BOUNTY_BOARD_LOCK_TYPE_NONE and self.firstCompletedTab then
		if not self.TutorialBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOUNTY_FINISHED) then
			self.TutorialBox.activeTutorial = LE_FRAME_TUTORIAL_BOUNTY_FINISHED;

			self.TutorialBox.Text:SetText(BOUNTY_TUTORIAL_BOUNTY_FINISHED);

			SetClampedTextureRotation(self.TutorialBox.Arrow.Arrow, 0);
			SetClampedTextureRotation(self.TutorialBox.Arrow.Glow, 0);

			self.TutorialBox.Arrow:ClearAllPoints();
			self.TutorialBox.Arrow:SetPoint("TOP", self.TutorialBox, "BOTTOM", 0, 4);

			self.TutorialBox.Arrow.Glow:ClearAllPoints();
			self.TutorialBox.Arrow.Glow:SetPoint("TOP", self.TutorialBox.Arrow, "TOP", 0, 0);

			self.TutorialBox:ClearAllPoints();
			self.TutorialBox:SetPoint("BOTTOM", self.firstCompletedTab, "TOP", 0, 14);

			self.TutorialBox:Show();
		end
	end
end