WorldMapBountyBoardMixin = {};

function WorldMapBountyBoardMixin:OnLoad()
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self.bountyObjectivePool = CreateFramePool("FRAME", self, "WorldMapBountyBoardObjectiveTemplate");
	self.bountyTabPool = CreateFramePool("BUTTON", self, "WorldMapBountyBoardTabTemplate");

	self.BountyName:SetFontObjectsToTry(Game13Font_o1, Game12Font_o1, Game11Font_o1);
end

function WorldMapBountyBoardMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		if not self:GetParent() or self:GetParent():IsVisible() then
			self:Refresh();
		end
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

function WorldMapBountyBoardMixin:Refresh()
	if not self.mapAreaID then
		self.selectedBountyIndex = nil;
		self:Hide();
		return;
	end

	self.bounties, self.displayLocation = GetQuestBountyInfoForMapID(self.mapAreaID, self.bounties);

	if #self.bounties == 0 or self.displayLocation == nil then
		self.selectedBountyIndex = nil;
		self:Hide();
		return;
	end

	self.selectedBountyIndex = self.selectedBountyIndex or 1;

	self:RefreshBountyTabs();
	self:RefreshSelectedBounty();
	self:Show();
end

function WorldMapBountyBoardMixin:RefreshBountyTabs()
	self.bountyTabPool:ReleaseAll();

	if #self.bounties == 0 then
		return;
	end

	local TAB_WIDTH = 42;
	local PADDING = 0;

	local startX = -((#self.bounties - 1) * (TAB_WIDTH + PADDING)) / 2;
	for bountyIndex, bounty in ipairs(self.bounties) do
		local tab = self.bountyTabPool:Acquire();
		local selected = self.selectedBountyIndex == bountyIndex;
		tab:SetNormalAtlas(selected and "worldquest-tracker-ring-selected" or "worldquest-tracker-ring");
		tab:SetHighlightAtlas("worldquest-tracker-ring-selected");
		tab.CheckMark:SetShown(IsQuestComplete(bounty.questID));
		tab.Icon:SetTexture(bounty.icon);
		tab.bountyIndex = bountyIndex;

		local offsetX = (PADDING + TAB_WIDTH) * (bountyIndex - 1);
		tab:SetPoint("CENTER", self.TrackerBackground, "CENTER", startX + offsetX, 42);

		tab:Show();
	end
end

function WorldMapBountyBoardMixin:RefreshSelectedBounty()
	self.bountyObjectivePool:ReleaseAll();

	if self.selectedBountyIndex then
		local bountyData = self.bounties[self.selectedBountyIndex];
		local questIndex = GetQuestLogIndexByID(bountyData.questID);
		if questIndex > 0 then
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(questIndex);
			if title then
				self.BountyName:SetText(title);

				for rewardIndex = 1, GetNumQuestLogRewards(bountyData.questID) do
					local name, texture, numItems, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, bountyData.questID);
					if name and texture then
						self.RewardFrame.Icon:SetTexture(texture);
						break; -- Just one for now
					end
				end

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

	local SUB_OBJECTIVE_FRAME_WIDTH = 35;

	local percentFull = (numTotal - 1) / (MAX_BOUNTY_OBJECTIVES - 1);
	local padding = Lerp(3, -9, percentFull);
	local startingOffsetX = Lerp(0, -20, percentFull) - ((SUB_OBJECTIVE_FRAME_WIDTH + padding) * (numTotal - 1)) / 2;

	for bountyObjectiveIndex = 1, numTotal do
		local bountyObjectiveFrame = self.bountyObjectivePool:Acquire();
		bountyObjectiveFrame:Show();

		local complete = bountyObjectiveIndex <= numCompleted;
		bountyObjectiveFrame.MarkerTexture:SetAtlas(complete and "worldquest-tracker-questmarker" or "worldquest-tracker-questmarker-gray", true);
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

function WorldMapBountyBoardMixin:ShowBountyTooltip(bountyIndex)
	local bountyData = self.bounties[bountyIndex];
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local questIndex = GetQuestLogIndexByID(bountyData.questID);
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questIndex);
	if title then
		WorldMapTooltip:SetText(title, HIGHLIGHT_FONT_COLOR:GetRGB());

		local _, questDescription = GetQuestLogQuestText(questIndex);
		WorldMapTooltip:AddLine(questDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

		for objectiveIndex = 1, bountyData.numObjectives do
			local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(bountyData.questID, objectiveIndex, false);
			if objectiveText and #objectiveText > 0 then
				local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
			end
		end

		WorldMap_AddQuestRewardsToTooltip(bountyData.questID);
		WorldMapTooltip:Show();
	else
		WorldMapTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
		WorldMapTooltip:Show();
	end
end

function WorldMapBountyBoardMixin:OnEnter()
	if self.selectedBountyIndex then
		self:ShowBountyTooltip(self.selectedBountyIndex);
	end
end

function WorldMapBountyBoardMixin:OnLeave()
	WorldMapTooltip:Hide();
end

function WorldMapBountyBoardMixin:OnTabEnter(tab)
	self:ShowBountyTooltip(tab.bountyIndex);
end

function WorldMapBountyBoardMixin:OnTabLeave(tab)
	self:OnLeave();
end

function WorldMapBountyBoardMixin:OnTabClick(tab)
	self:SetSelectedBountyIndex(tab.bountyIndex);
end