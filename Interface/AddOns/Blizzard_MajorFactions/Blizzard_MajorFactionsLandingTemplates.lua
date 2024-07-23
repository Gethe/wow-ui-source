local iconAtlasFormat = "majorFactions_icons_%s512";
local buttonAtlasFormatsByExpansion = {
	[LE_EXPANSION_DRAGONFLIGHT] = {
		normalAtlas = "dragonflight-landingpage-renownbutton-%s",
		hoverAtlas = "dragonflight-landingpage-renownbutton-%s-hover",
		lockedAtlas = "dragonflight-landingpage-renownbutton-locked",
		progressBarBorderAtlas = "dragonflight-landingpage-radial-frame",
		progressBarFillAtlas = "dragonflight-landingpage-radial-%s",
	},
	[LE_EXPANSION_WAR_WITHIN] = {
		normalAtlas = "thewarwithin-landingpage-renownbutton-%s",
		hoverAtlas = nil, --Reuses normalAtlas in additive mode.
		lockedAtlas = "thewarwithin-landingpage-renownbutton-locked",
		progressBarBorderAtlas = "thewarwithin-landingpage-radial-frame",
		progressBarFillAtlas = "thewarwithin-landingpage-radial-%s",
	},
};

local factionIconSize = {
	["Default"] = 44,
	["Dream"] = 48,
	["flame"] = 64,
	["storm"] = 54,
	["candle"] = 58,
	["web"] = 58,
}

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
	local topPadding, bottomPadding, leftPadding, rightPadding = 5, 10, 0, 0;
	local elementSpacing = 4;
	local view = CreateScrollBoxListLinearView(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
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

	local function MajorFactionSort(faction1, faction2)
		-- Higher priority factions will be sorted to the top of the list.
		if faction1.uiPriority ~= faction2.uiPriority then
			return faction1.uiPriority > faction2.uiPriority;
		end

		return strcmputf8i(faction1.name, faction2.name) < 0;
	end
	table.sort(factionList, MajorFactionSort);

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
		local function FindFactionButton(button, majorFactionData)
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

	local atlasFormats = buttonAtlasFormatsByExpansion[majorFactionData.expansionID];
	self.LockedState.Background:SetAtlas(atlasFormats.lockedAtlas, TextureKitConstants.UseAtlasSize);
	self.LockedState.unlockDescription = majorFactionData.unlockDescription;
	self.UnlockedState.normalAtlas = atlasFormats.normalAtlas:format(majorFactionData.textureKit);
	
	-- Some expansions use a unique texture for hover, others reuse the normal texture.
	if atlasFormats.hoverAtlas then
		self.UnlockedState.hoverAtlas = atlasFormats.hoverAtlas:format(majorFactionData.textureKit);
	else
		self.UnlockedState.Hover:SetAtlas(self.UnlockedState.normalAtlas, TextureKitConstants.UseAtlasSize);
	end

	self.UnlockedState.Background:SetAtlas(self.UnlockedState.normalAtlas, TextureKitConstants.UseAtlasSize);

	local progressBarBorderAtlas = atlasFormats.progressBarBorderAtlas;
	self.UnlockedState.RenownProgressBar.Border:SetAtlas(progressBarBorderAtlas, TextureKitConstants.UseAtlasSize);
	local fillAtlas = atlasFormats.progressBarFillAtlas:format(majorFactionData.textureKit);

	local fillInfo = C_Texture.GetAtlasInfo(fillAtlas);
	if fillInfo then
		self.UnlockedState.RenownProgressBar:SetSwipeTexture(fillInfo.file or fillInfo.filename);

		local lowTexCoords =
		{
			x = fillInfo.leftTexCoord,
			y = fillInfo.topTexCoord,
		};
		local highTexCoords =
		{
			x = fillInfo.rightTexCoord,
			y = fillInfo.bottomTexCoord,
		};
		self.UnlockedState.RenownProgressBar:SetTexCoordRange(lowTexCoords, highTexCoords);
	end
	
	local iconSize = factionIconSize[majorFactionData.textureKit] or factionIconSize["Default"];
	self.UnlockedState.Icon:ClearAllPoints();
	self.UnlockedState.Icon:SetPoint("CENTER", self.UnlockedState.RenownProgressBar, "CENTER");
	self.UnlockedState.Icon:SetSize(iconSize, iconSize);
	self.UnlockedState.Icon:SetAtlas(iconAtlasFormat:format(majorFactionData.textureKit), TextureKitConstants.IgnoreAtlasSize);
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

function MajorFactionButtonLockedStateMixin:OnEnter()
	if self.unlockDescription then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, self.unlockDescription);
		GameTooltip:Show();
	end
end

function MajorFactionButtonLockedStateMixin:OnLeave()
	GameTooltip_Hide();
end

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
	self.Title:SetPoint("BOTTOMLEFT", self.RenownProgressBar, "RIGHT", 8, 0);

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

	-- Support two different methods of handling the hover image:
	-- 1. It has its own unique file to be applied to Background Texture.
	-- 2. It reuses the normal file in additive mode on the Hover Texture.
	if self.hoverAtlas then
		self.Background:SetAtlas(self.hoverAtlas, TextureKitConstants.UseAtlasSize);
	else
		self.Hover:SetShown(true);
	end

	self:RefreshTooltip();
end

function MajorFactionButtonUnlockedStateMixin:OnLeave()
	-- Undo the logic from OnEnter depending on which method it used.
	if self.hoverAtlas then
		self.Background:SetAtlas(self.normalAtlas, TextureKitConstants.UseAtlasSize);
	else
		self.Hover:SetShown(false);
	end

	-- Hide the renown progress tooltip or the paragon progress tooltip (whichever is up)
	if GameTooltip:GetOwner() == self then
		GameTooltip_Hide();
	elseif EmbeddedItemTooltip:GetOwner() == self then
		EmbeddedItemTooltip_Hide(EmbeddedItemTooltip);
	end
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
	local mouseOver = RegionUtil.IsAnyDescendantOfOrSame(GetMouseFoci(), self);
	if not mouseOver then
		self.WatchFactionButton:Hide();
	end
end

function MajorFactionButtonUnlockedStateMixin:SetSelected(selected)
	self.isSelected = selected;
	--self.SelectedTexture:SetShown(selected);
end

function MajorFactionButtonUnlockedStateMixin:RefreshTooltip()
	if C_Reputation.IsFactionParagon(self:GetParent().factionID) then
		self:ShowParagonRewardsTooltip();
	else
		self:ShowRenownRewardsTooltip();
	end
end

local function TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return;
	end

	local wrapText = false;
	GameTooltip_AddColoredLine(tooltip, REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, wrapText);
end

function MajorFactionButtonUnlockedStateMixin:ShowRenownRewardsTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local factionID = self:GetParent().factionID;
	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
	local tooltipTitle = majorFactionData.name;
	GameTooltip_SetTitle(GameTooltip, tooltipTitle, HIGHLIGHT_FONT_COLOR);
	TryAppendAccountReputationLineToTooltip(GameTooltip, factionID);

	if not C_MajorFactions.HasMaximumRenown(factionID) then
		GameTooltip_AddNormalLine(GameTooltip, MAJOR_FACTION_RENOWN_CURRENT_PROGRESS:format(majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold));
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, C_MajorFactions.GetCurrentRenownLevel(factionID) + 1);
		if #nextRenownRewards > 0 then
			self:AddRenownRewardsToTooltip(nextRenownRewards);
		end
	end

	GameTooltip_AddColoredLine(GameTooltip, MAJOR_FACTION_BUTTON_TOOLTIP_VIEW_RENOWN, GREEN_FONT_COLOR);
	GameTooltip:Show();
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

function MajorFactionButtonUnlockedStateMixin:ShowParagonRewardsTooltip()
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local factionID = self:GetParent().factionID;
	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
	local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);

	if tooLowLevelForParagon then
		GameTooltip_SetTitle(EmbeddedItemTooltip, PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL, NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(EmbeddedItemTooltip, MAJOR_FACTION_MAX_RENOWN_REACHED, HIGHLIGHT_FONT_COLOR);
		local description = PARAGON_REPUTATION_TOOLTIP_TEXT:format(majorFactionData.name);
		if hasRewardPending then
			local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID);
			local text = GetQuestLogCompletionText(questIndex);
			if text and text ~= "" then
				description = text;
			end
		end
		TryAppendAccountReputationLineToTooltip(EmbeddedItemTooltip, factionID);

		GameTooltip_AddNormalLine(EmbeddedItemTooltip, description);

		if not hasRewardPending then
			local value = mod(currentValue, threshold);
			-- Show overflow if a reward is pending
			if hasRewardPending then
				value = value + threshold;
			end
			GameTooltip_ShowProgressBar(EmbeddedItemTooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));
		end
		GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip, rewardQuestID);
	end
	GameTooltip_SetBottomText(EmbeddedItemTooltip, MAJOR_FACTION_BUTTON_TOOLTIP_VIEW_RENOWN, GREEN_FONT_COLOR);
	EmbeddedItemTooltip:Show();
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

function MajorFactionWatchFactionButtonMixin:OnLoad()
	-- Need to make sure the checkbox + label fit in the top right corner
	self:ClearAllPoints();
	local totalWidth = self:GetWidth() + self.Label:GetStringWidth();
	local padding = 2;
	local xOffset, yOffset = (totalWidth + padding) * -1, -8;
	self:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", xOffset, yOffset);
end

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
	local watchedfactionData = C_Reputation.GetWatchedFactionData();

	local baseButton = self:GetParent():GetParent();
	self:SetChecked(watchedfactionData and watchedfactionData.factionID == baseButton.factionID);
end

function MajorFactionWatchFactionButtonMixin:OnClick()
	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
	PlaySound(clickSound);
	
	local baseButton = self:GetParent():GetParent();
	local factionID = self:GetChecked() and baseButton.factionID or 0;
	C_Reputation.SetWatchedFactionByID(factionID);
	StatusTrackingBarManager:UpdateBarsShown();
end