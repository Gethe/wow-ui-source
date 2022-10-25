local buttonTextureKits = {
	[2503] = "Centaur",
	[2507] = "Expedition",
	[2510] = "Valdrakken",
	[2511] = "Tuskarr",
};

local iconAtlasFormat = "majorFactions_icons_%s512";
local buttonAtlasFormat = "%s-landingpage-renownbutton-%s";
local buttonHoverAtlasFormat = "%s-landingpage-renownbutton-%s-hover";

LandingPageMajorFactionList = {};

function LandingPageMajorFactionList.Create(parent)
	local frameName = nil;
	return CreateFrame("Frame", frameName, parent, "LandingPageMajorFactionListTemplate");
end

----------------------------------- Major Faction List -----------------------------------

MajorFactionListMixin = {};

local MAJOR_FACTION_LIST_EVENTS = {
	"MAJOR_FACTION_UNLOCKED",
};

function MajorFactionListMixin:OnLoad()
	local padding = 0;
	local elementSpacing = 8;
	local view = CreateScrollBoxListLinearView(padding, padding, padding, padding, elementSpacing);
	view:SetElementInitializer("MajorFactionButtonTemplate", function(button, majorFactionData)
		button:Init(majorFactionData);
		-- Set the button as "selected" if the Renown Track is already open to this faction when we initialize the list
		if button.isUnlocked then
			button.UnlockedState:SetSelected(button.factionID == self.selectedFactionID);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	EventRegistry:RegisterCallback("MajorFactionRenownMixin.RenownTrackFactionChanged", self.OnRenownTrackFactionChanged, self);
end

function MajorFactionListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, MAJOR_FACTION_LIST_EVENTS);
	self:Refresh();

	if self.selectedFactionID then
		self:ScrollToSelectedFaction();
	end
end

function MajorFactionListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, MAJOR_FACTION_LIST_EVENTS);
end

function MajorFactionListMixin:OnEvent(event, ...)
	if event == "MAJOR_FACTION_UNLOCKED" then
		self:Refresh();
	end
end

function MajorFactionListMixin:Refresh()
	local factionList = {};

	local majorFactionIDs = C_MajorFactions.GetMajorFactionIDs(self.expansionFilter);
	for index, majorFactionID in ipairs(majorFactionIDs) do
		local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID);
		tinsert(factionList, majorFactionData);
	end

	local function AlphabeticalSort(faction1, faction2)
		return strcmputf8i(faction1.name, faction2.name) < 0;
	end
	table.sort(factionList, AlphabeticalSort);

	local dataProvider = CreateDataProvider(factionList);
	self.ScrollBox:SetDataProvider(dataProvider);
	self.ScrollBar:SetShown(self.ScrollBox:HasScrollableExtent());
end

function MajorFactionListMixin:SetExpansionFilter(expansionFilter)
	self.expansionFilter = expansionFilter;
end

function MajorFactionListMixin:OnRenownTrackFactionChanged(newMajorFactionID)
	if self.selectedFactionID ~= newMajorFactionID then
		self:SetSelectedFaction(newMajorFactionID);
	end
end

function MajorFactionListMixin:SetSelectedFaction(majorFactionID)
	local function SetSelected(majorFactionID, selected)
		local function FindFactionButton(majorFactionData)
			return majorFactionData.factionID == majorFactionID;
		end	

		local factionButton = self.ScrollBox:FindFrameByPredicate(FindFactionButton);
		if factionButton and factionButton.isUnlocked then
			factionButton.UnlockedState:SetSelected(selected);
		end
	end

	local oldSelectedFaction = self.selectedFactionID;
	self.selectedFactionID = majorFactionID;

	if self:IsShown() then
		SetSelected(oldSelectedFaction, false);
		SetSelected(self.selectedFactionID, true);
	end
end

function MajorFactionListMixin:ScrollToSelectedFaction()
	if not self.selectedFactionID then
		return;
	end

	local function FindSelectedFaction(majorFactionData)
		return majorFactionData.factionID == self.selectedFactionID;
	end

	self.ScrollBox:ScrollToElementDataByPredicate(FindSelectedFaction, ScrollBoxConstants.AlignBegin);
end

----------------------------------- Major Faction Button Base -----------------------------------

MajorFactionButtonMixin = {};

function MajorFactionButtonMixin:Init(majorFactionData)
	self.isUnlocked = majorFactionData.isUnlocked;
	self.factionID = majorFactionData.factionID;
	self.expansionID = majorFactionData.expansionID;
	self.bountySetID = majorFactionData.bountySetID;

	local expansionName = _G["EXPANSION_NAME" .. self.expansionID];
	self.UnlockedState.normalAtlas = buttonAtlasFormat:format(expansionName, buttonTextureKits[self.factionID]);
	self.UnlockedState.hoverAtlas = buttonHoverAtlasFormat:format(expansionName, buttonTextureKits[self.factionID]);

	self.UnlockedState.Background:SetAtlas(self.UnlockedState.normalAtlas, TextureKitConstants.UseAtlasSize);

	self.UnlockedState.Icon:SetAtlas(iconAtlasFormat:format(buttonTextureKits[self.factionID]), TextureKitConstants.IgnoreAtlasSize);
	self.UnlockedState.Icon:Show();

	self.LockedState:Refresh(majorFactionData);
	self.UnlockedState:Refresh(majorFactionData);
	self:UpdateState();
end

function MajorFactionButtonMixin:UpdateState()
	self.LockedState:SetShown(not self.isUnlocked);
	self.UnlockedState:SetShown(self.isUnlocked);
end

----------------------------------- Major Faction Button Locked State -----------------------------------

MajorFactionButtonLockedStateMixin = {};

function MajorFactionButtonLockedStateMixin:Refresh(majorFactionData)
	self.Title:SetText(majorFactionData.name or "");
end

----------------------------------- Major Faction Button Unlocked State -----------------------------------

local MAJOR_FACTION_BUTTON_UNLOCKED_STATE_EVENTS = {
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"UPDATE_FACTION",
};

MajorFactionButtonUnlockedStateMixin = {};

function MajorFactionButtonUnlockedStateMixin:Refresh(majorFactionData)
	self.Title:SetText(majorFactionData.name or "");
	self.RenownLevel:SetText(MAJOR_FACTION_BUTTON_RENOWN_LEVEL:format(majorFactionData.renownLevel or 0));

	local isCapped = C_MajorFactions.HasMaximumRenown(majorFactionData.factionID);
	local currentValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
	local maxValue = majorFactionData.renownLevelThreshold;
	self.RenownProgressBar:UpdateBar(currentValue, maxValue);
	self.RenownProgressBar:Show();

	C_Reputation.RequestFactionParagonPreloadRewardData(majorFactionData.factionID);
end

function MajorFactionButtonUnlockedStateMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, MAJOR_FACTION_BUTTON_UNLOCKED_STATE_EVENTS);

	if self:GetParent().isUnlocked then
		local cvarName = "lastRenownForMajorFaction" .. self:GetParent().factionID;
		local lastRenownLevel = tonumber(GetCVar(cvarName)) or 1;
		local newFactionUnlock = lastRenownLevel == 0;
		--if newFactionUnlock then
		--	self:PlayUnlockCelebration();
		--end
	end
end

function MajorFactionButtonUnlockedStateMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, MAJOR_FACTION_BUTTON_UNLOCKED_STATE_EVENTS);

	--if self.isPlayingUnlockCelebration == true then
	--	self:StopUnlockCelebration();
	--end
end

function MajorFactionButtonUnlockedStateMixin:OnEvent(event, ...)
	if event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" then
		local changedFactionID, newRenownLevel, oldRenownLevel = ...;
		local factionID = self:GetParent().factionID;
		if factionID == changedFactionID then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);

			self:Refresh(majorFactionData);
		end
	elseif event == "UPDATE_FACTION" then
		local majorFactionData = C_MajorFactions.GetMajorFactionData(self:GetParent().factionID);

		self:Refresh(majorFactionData);
	end
end

function MajorFactionButtonUnlockedStateMixin:OnEnter()
	self.WatchFactionButton:Show();

	self.Background:SetAtlas(self.hoverAtlas, TextureKitConstants.UseAtlasSize);

	self:RefreshTooltip();
end

function MajorFactionButtonUnlockedStateMixin:OnLeave()
	self.Background:SetAtlas(self.normalAtlas, TextureKitConstants.UseAtlasSize);

	GameTooltip_Hide();
end

function MajorFactionButtonUnlockedStateMixin:OnClick()
	if MajorFactionRenownFrame and MajorFactionRenownFrame:IsShown() then
		-- Close the renown track if it is already open for this faction
		if self.isSelected then
			ToggleMajorFactionRenown();
			return;
		end

		-- Otherwise request that the renown track switch to this faction
		HideUIPanel(MajorFactionRenownFrame);
		EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", self:GetParent().factionID);
		ShowUIPanel(MajorFactionRenownFrame);
	else
		EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", self:GetParent().factionID);
		ToggleMajorFactionRenown();
	end
end

-- We only want to hide the WatchFactionButton when our mouse is completely off the main button
function MajorFactionButtonUnlockedStateMixin:OnUpdate()
	local mouseOver = RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self);
	if not mouseOver then
		self.WatchFactionButton:Hide();
	end
end

function MajorFactionButtonUnlockedStateMixin:SetSelected(selected)
	self.isSelected = selected;
	--self.SelectedTexture:SetShown(selected);
end

function MajorFactionButtonUnlockedStateMixin:RefreshTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if C_Reputation.IsFactionParagon(self:GetParent().factionID) then
		self:SetUpParagonRewardsTooltip();
	else
		self:SetUpRenownRewardsTooltip();
	end
	GameTooltip:Show();
end

function MajorFactionButtonUnlockedStateMixin:SetUpRenownRewardsTooltip()
	local majorFactionData = C_MajorFactions.GetMajorFactionData(self:GetParent().factionID);
	local tooltipTitle = majorFactionData.name;
	GameTooltip_SetTitle(GameTooltip, tooltipTitle, NORMAL_FONT_COLOR);

	local factionID = self:GetParent().factionID;
	if not C_MajorFactions.HasMaximumRenown(factionID) then
		GameTooltip_AddNormalLine(GameTooltip, MAJOR_FACTION_RENOWN_CURRENT_PROGRESS:format(majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold));
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, C_MajorFactions.GetCurrentRenownLevel(factionID) + 1);
		if #nextRenownRewards > 0 then
			self:AddRenownRewardsToTooltip(nextRenownRewards);
		end
	end

	GameTooltip_AddColoredLine(GameTooltip, MAJOR_FACTION_BUTTON_TOOLTIP_VIEW_RENOWN, GREEN_FONT_COLOR);
end

function MajorFactionButtonUnlockedStateMixin:AddRenownRewardsToTooltip(renownRewards)
	GameTooltip_AddHighlightLine(GameTooltip, MAJOR_FACTION_BUTTON_TOOLTIP_NEXT_REWARDS);

	for i, rewardInfo in ipairs(renownRewards) do
		local renownRewardString;
		local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.RefreshTooltip, self));
		if icon then
			local file, width, height = icon, 16, 16;
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height);
			renownRewardString = rewardTexture .. " " .. name;
		end
		local wrapText = false;
		GameTooltip_AddNormalLine(GameTooltip, renownRewardString, wrapText);
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
end

function MajorFactionButtonUnlockedStateMixin:SetUpParagonRewardsTooltip()
	local factionID = self:GetParent().factionID;
	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
	local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);

	if tooLowLevelForParagon then
		GameTooltip_SetTitle(GameTooltip, PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL, NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(GameTooltip, MAJOR_FACTION_MAX_RENOWN_REACHED, NORMAL_FONT_COLOR);
		local description = PARAGON_REPUTATION_TOOLTIP_TEXT:format(majorFactionData.name);
		if hasRewardPending then
			local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID);
			local text = GetQuestLogCompletionText(questIndex);
			if text and text ~= "" then
				description = text;
			end
		end

		GameTooltip_AddHighlightLine(GameTooltip, description);

		if not hasRewardPending then
			local value = mod(currentValue, threshold);
			-- Show overflow if a reward is pending
			if hasRewardPending then
				value = value + threshold;
			end
			GameTooltip_ShowProgressBar(GameTooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));
		end
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, rewardQuestID);
	end
end

function MajorFactionButtonUnlockedStateMixin:PlayUnlockCelebration()
	self.UnlockFlash:Show();
	self.UnlockFlash.Anim:Restart();
	self.isPlayingUnlockCelebration = true;
end

function MajorFactionButtonUnlockedStateMixin:StopUnlockCelebration()
	self.UnlockFlash:Hide();
	self.UnlockFlash.Anim:Stop();
	self.isPlayingUnlockCelebration = false;
end

----------------------------------- Major Faction Button Unlocked State Renown Progress Bar -----------------------------------

MajorFactionRenownProgressBarMixin = {};

function MajorFactionRenownProgressBarMixin:UpdateBar(currentValue, maxValue)
	if not currentValue or not maxValue or maxValue == 0 then
		return;
	end

	CooldownFrame_SetDisplayAsPercentage(self, currentValue / maxValue);
end

----------------------------------- Major Faction Button Unlocked State Watch Faction Button -----------------------------------

local MAJOR_FACTION_WATCH_FACTION_BUTTON_EVENTS = {
	"UPDATE_FACTION",
}

MajorFactionWatchFactionButtonMixin = {};

function MajorFactionWatchFactionButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, MAJOR_FACTION_WATCH_FACTION_BUTTON_EVENTS);
	self:UpdateState();
end

function MajorFactionWatchFactionButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, MAJOR_FACTION_WATCH_FACTION_BUTTON_EVENTS);
end

function MajorFactionWatchFactionButtonMixin:OnEvent(event)
	if event == "UPDATE_FACTION" then
		self:UpdateState();
	end
end

function MajorFactionWatchFactionButtonMixin:UpdateState()
	local watchedfactionID = select(6, GetWatchedFactionInfo());

	local baseButton = self:GetParent():GetParent();
	self:SetChecked(watchedfactionID == baseButton.factionID);
end

function MajorFactionWatchFactionButtonMixin:OnClick()
	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
	PlaySound(clickSound);
	
	local baseButton = self:GetParent():GetParent();
	local factionID = self:GetChecked() and baseButton.factionID or 0;
	C_Reputation.SetWatchedFaction(factionID);
	StatusTrackingBarManager:UpdateBarsShown();
end