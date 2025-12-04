--! TODO "Current Season" behavior TBD. It matters more for seasonal content than for renown, so we may want to filter out anything not seasonal. Will revisit once Delves implemented
--! TODO some animations, sounds, reward checkmark behaivor, reward tracking behaviors in the progress view TBD.
--! TODO art, sound
--! TODO events, updates. E.g. if you gain rep with the panel open
--! TODO "new" labels

--[[
NOTE: Shadowlands Covenants were implemented differently from modern covenant/renown rep. If we ever plan to support that legacy content or support its setup, we will need to access those differently from how we access modern ones.
	  Right now, SL covenants and anything implemented like them are not supported.
]]

-------------------------------------[[ Locals ]]-------------------------------------------------------
local MAJOR_FACTION_ICON_ATLAS_FMT = "majorFactions_icons_%s512";
local SCROLL_BOX_EDGE_FADE_LENGTH = 50;
local MAX_REWARD_CARDS_TO_DISPLAY = 4;

local function ShowRenownRewardsTooltip(frame, factionID)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	RenownRewardUtil.AddMajorFactionLandingPageSummaryToTooltip(GameTooltip, factionID, GenerateClosure(ShowRenownRewardsTooltip, frame));
	GameTooltip_AddColoredLine(GameTooltip, JOURNEYS_TOOLTIP_VIEW_JOURNEY, GREEN_FONT_COLOR);
	GameTooltip:Show();
end

local function ShowParagonRewardsTooltip(frame, factionID)
	EmbeddedItemTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	ReputationUtil.AddParagonRewardsToTooltip(EmbeddedItemTooltip, factionID)
	GameTooltip_SetBottomText(EmbeddedItemTooltip, JOURNEYS_TOOLTIP_VIEW_JOURNEY, GREEN_FONT_COLOR);
	EmbeddedItemTooltip:Show();
end

local function GetJourneysForNavBar()
	local journeysList = {};

	local function SelectJourneyFromNavBar(majorFactionData)
		EncounterJournal.JourneysFrame:ResetView(majorFactionData);
	end

	for _, renown in ipairs(EncounterJournal.JourneysFrame.renownJourneyData) do
		tinsert(journeysList, {text = renown.name, id = renown.factionID, func = function() SelectJourneyFromNavBar(renown) end});
	end

	for _, encounter in ipairs(EncounterJournal.JourneysFrame.encountersJourneyData) do
		tinsert(journeysList, {text = encounter.name, id = encounter.factionID, func = function() SelectJourneyFromNavBar(encounter) end});
	end

	return journeysList;
end

-------------------------------------[[ Journeys Frame ]]-------------------------------------------------------
JourneysFrameMixin = {};

function JourneysFrameMixin:OnLoad()
	self:SetupJourneysList();
end

function JourneysFrameMixin:OnShow()
	NavBar_Reset(EncounterJournal.navBar);
	self:ResetView();
	self:Refresh();
end

function JourneysFrameMixin:Refresh()
	local dataProvider = CreateDataProvider();
	local renownIDs = C_MajorFactions.GetMajorFactionIDs(self.expansionFilter);
	self.dataProvider = dataProvider;
	self.renownJourneyData = {};
	self.encountersJourneyData = {};

	-- Collect Renown/Major Factions
	for _, id in ipairs(renownIDs) do
		if not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(id) then
			if C_MajorFactions.ShouldDisplayMajorFactionAsJourney(id) then
				tinsert(self.encountersJourneyData, C_MajorFactions.GetMajorFactionData(id));
			else
				tinsert(self.renownJourneyData, C_MajorFactions.GetMajorFactionData(id));
			end
		end
	end

	if #self.renownJourneyData >= 1 then
		self:AddCategoryHeader(JOURNEYS_RENOWN_LABEL);

		for _, renown in ipairs(self.renownJourneyData) do
			renown.isRenownJourney = true;
			dataProvider:Insert(renown);
		end
	end

	-- Collect non-Renown Journeys (Currently: Prey, Delves - categorized into Encounters)
	if #self.encountersJourneyData >= 1 then
		if #self.renownJourneyData >= 1 then
			self:AddDivider();
		end

		self:AddCategoryHeader(JOURNEYS_ENCOUNTERS_LABEL);

		for _, encounter in ipairs(self.encountersJourneyData) do
			dataProvider:Insert(encounter);
		end
	end

	self.JourneysList:SetEdgeFadeLength(SCROLL_BOX_EDGE_FADE_LENGTH);
	self.JourneysList:SetDataProvider(dataProvider);
end

function JourneysFrameMixin:AddDivider()
	self.dataProvider:Insert({divider = true});
end

function JourneysFrameMixin:AddCategoryHeader(categoryString)
	self.dataProvider:Insert({category = categoryString});
end

function JourneysFrameMixin:SetupJourneysList()
	local topPadding = 15;
	local bottomPadding = 10;
	local leftPadding = 10;
	local rightPadding = 10;
	local horizSpacing = 5;
	local vertSpacing = 5;
	local view = CreateScrollBoxListSequenceView(topPadding, bottomPadding, leftPadding, rightPadding, horizSpacing, vertSpacing);

	local function CategoryNameInitializer(frame, elementData)
		frame.CategoryName:SetText(elementData.category);
	end

	local function SetParagonInfo(factionID, button)
		local currentValue, threshold, rewardQuestID, hasRewardPending, _, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID);

		if rewardQuestID then
			local itemID = select(6, GetQuestLogRewardInfo(1, rewardQuestID));

			if itemID then
				local item = Item:CreateFromItemID(itemID);

				item:ContinueOnItemLoad(function()
					local itemName, itemLink, _, _, _, _, _, _, _, itemIcon, _, _, _, _, _, _, _, itemDescription = C_Item.GetItemInfo(itemID);

					button.majorFactionData.paragonInfo = {
						["value"] = currentValue,
						["threshold"] = threshold,
						["level"] = paragonStorageLevel,
						["rewardInfo"] = {
							["name"] = itemName,
							["icon"] = itemIcon,
							["description"] = itemDescription,
							["isWarbandItem"] = C_Item.IsItemBindToAccount(itemLink),
						},
					};
				end);
			end
		end
	end

	local function RenownCardInitializer(button, elementData)
		button.majorFactionData = elementData;
		button.journeysFrame = self;

		button.RenownCardIcon:SetAtlas(MAJOR_FACTION_ICON_ATLAS_FMT:format(elementData.textureKit)); --! TODO not final
		button.RenownCardFactionName:SetText(elementData.name);

		if C_Reputation.IsFactionParagon(elementData.factionID) then
			SetParagonInfo(elementData.factionID, button);
		end

		if button.majorFactionData.paragonInfo and button.majorFactionData.paragonInfo.level ~= 0 then

			button.RenownCardFactionLevel:SetText(JOURNEYS_MAX_LEVEL_LABEL:format(elementData.renownLevel + button.majorFactionData.paragonInfo.level));
			-- TODO: Reference: MajorFactionRenownProgressBarMixin:UpdateBar() and MajorFactionRenownTrackProgressBarMixin:RefreshBar()
			-- TODO: will want to set up the swipe texture and all that at some point, otherwise we're stuck with the red swipe that doesn't quite fit
			local paragonInfo = button.majorFactionData.paragonInfo;
			CooldownFrame_SetDisplayAsPercentage(button.RenownCardProgressBar, (paragonInfo.value - (paragonInfo.threshold * paragonInfo.level)) / paragonInfo.threshold);
		else
			button.RenownCardFactionLevel:SetText(JOURNEYS_LEVEL_LABEL:format(elementData.renownLevel));
			-- TODO: Reference: MajorFactionRenownProgressBarMixin:UpdateBar() and MajorFactionRenownTrackProgressBarMixin:RefreshBar()
			-- TODO: will want to set up the swipe texture and all that at some point, otherwise we're stuck with the red swipe that doesn't quite fit
			CooldownFrame_SetDisplayAsPercentage(button.RenownCardProgressBar, elementData.renownReputationEarned / elementData.renownLevelThreshold);
		end
	end

	local function JourneyCardInitializer(button, elementData)
		button.majorFactionData = elementData;
		button.journeysFrame = self;

		button.JourneyHighlightBG:SetAtlas(elementData.textureKit); --! TODO not final, may need a FMT string like we do above
		button.JourneyCardName:SetText(elementData.name);

		if C_Reputation.IsFactionParagon(elementData.factionID) then
			SetParagonInfo(elementData.factionID, button);
		end

		if button.majorFactionData.paragonInfo and button.majorFactionData.paragonInfo.level ~= 0 then
			local paragonInfo = button.majorFactionData.paragonInfo;

			button.JourneyCardLevel:SetText(JOURNEYS_MAX_LEVEL_LABEL:format(elementData.renownLevel + paragonInfo.level));
			-- TODO Reference: CommentatorUnitFrameMixin:SetHP()
			-- TODO: Will want to set up the bar texture and all that at some point
			button.JourneyCardProgressBar:SetMinMaxValues(0, paragonInfo.threshold);
			button.JourneyCardProgressBar:SetValue(paragonInfo.value - (paragonInfo.threshold * paragonInfo.level));
		else
			button.JourneyCardLevel:SetText(JOURNEYS_LEVEL_LABEL:format(elementData.renownLevel));
			-- TODO Reference: CommentatorUnitFrameMixin:SetHP()
			-- TODO: Will want to set up the bar texture and all that at some point
			button.JourneyCardProgressBar:SetMinMaxValues(0, elementData.renownLevelThreshold);
			button.JourneyCardProgressBar:SetValue(elementData.renownReputationEarned);
		end
	end

	view:SetElementFactory(function(factory, elementData)
		if elementData.category then
			factory("JourneysListCategoryNameTemplate", CategoryNameInitializer);
		elseif elementData.divider then
			factory("JourneysListCategoryDividerTemplate", nop);
		elseif elementData.isRenownJourney then
			factory("RenownCardButtonTemplate", RenownCardInitializer);
		else
			factory("JourneyCardButtonTemplate", JourneyCardInitializer);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.JourneysList, self.ScrollBar, view);
end

function JourneysFrameMixin:ResetView(majorFactionData, majorfactionID)
	if not majorFactionData and majorfactionID then
		majorFactionData = C_MajorFactions.GetMajorFactionData(majorfactionID);

		if not C_MajorFactions.ShouldDisplayMajorFactionAsJourney(majorfactionID) then
			majorFactionData.isRenownJourney = true;
		end
	end

	if majorFactionData and self.JourneysList:IsShown() then
		-- Main list of journeys shown, drill down into rewards/progress
		self.JourneysList:Hide();
		self.ScrollBar:Hide();

		self.JourneyProgress.majorFactionData = majorFactionData;
		self.JourneyProgress:Show();
	elseif majorFactionData and self.JourneyProgress:IsShown() then
		-- Progress shown, looks like we selected something from the navbar or other link. Switch to the new one.
		NavBar_Reset(EncounterJournal.navBar);
		self.JourneyProgress.majorFactionData = majorFactionData;
		self.JourneyProgress:Refresh();
	elseif majorFactionData and self.JourneyOverview:IsShown() then
		-- Overview shown, looks like we selected something from the navbar or other link. Go to the progress page for selected journey
		self.JourneyOverview:Hide();
		NavBar_Reset(EncounterJournal.navBar);
		self.JourneyProgress.majorFactionData = majorFactionData;
		self.JourneyProgress:Show();
	else
		-- Fallback state or Home button clicked, reset and go back to main list
		self.JourneyProgress.majorFactionData = {};
		self.JourneyProgress:Hide();

		self.JourneyOverview.majorFactionData = {};
		self.JourneyOverview:Hide();

		self.JourneysList:Show();
		self.ScrollBar:Show();
	end

	EncounterJournal.instanceSelect.bg:SetAtlas("ui-journeys-bg", TextureKitConstants.UseAtlasSize);
	EncounterJournal.instanceSelect.bg:Show();
	EncounterJournal.instanceSelect.evergreenBg:Hide();

	if majorFactionData then
		EventRegistry:TriggerEvent("JourneysFrameMixin.FactionChanged", majorFactionData.factionID);
	end
end

-------------------------------------[[ Renown Card Button ]]-------------------------------------------------------
RenownCardButtonMixin = {};

function RenownCardButtonMixin:OnEnter()
	if self.majorFactionData and self.majorFactionData.factionID then
		if C_Reputation.IsFactionParagonForCurrentPlayer(self.majorFactionData.factionID) then
			ShowParagonRewardsTooltip(self, self.majorFactionData.factionID);
		else
			ShowRenownRewardsTooltip(self, self.majorFactionData.factionID);
		end
	end

	if self.WatchedFactionToggleFrame then
		self.WatchedFactionToggleFrame:Show();
	end
end

function RenownCardButtonMixin:OnLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip_Hide();
	elseif EmbeddedItemTooltip:GetOwner() == self then
		EmbeddedItemTooltip_Hide(EmbeddedItemTooltip);
	end

	if self.WatchedFactionToggleFrame and self.WatchedFactionToggleFrame:IsShown() then
		self.WatchedFactionToggleFrame:Hide();
	end
end

function RenownCardButtonMixin:OnClick()
	self.journeysFrame:ResetView(self.majorFactionData);
end

-------------------------------------[[ "Other" Journey Button ]]-------------------------------------------------------
JourneyCardButtonMixin = CreateFromMixins(RenownCardButtonMixin);

-------------------------------------[[ Journey "Progress" Frame ]]-------------------------------------------------------
JourneyProgressFrameMixin = {};

function JourneyProgressFrameMixin:OnLoad()
	local function RewardResetter(framePool, frame)
		frame.RewardCardName:SetText("");
		frame.RewardCardIcon:SetTexture(nil);
		Pool_HideAndClearAnchors(framePool, frame);
	end

	self.rewardPool = CreateFramePool("FRAME", self, "JourneyProgressRewardCardTemplate", RewardResetter);
end

function JourneyProgressFrameMixin:OnShow()
	self:Refresh();
	self:UpdateLastSeenLevel();
end

function JourneyProgressFrameMixin:UpdateLastSeenLevel()
	if not self.majorFactionData or not self.majorFactionData.factionID then
		return;
	end

	local majorFactionRenownMap = GetCVarTable("majorFactionRenownMap");
	local lastSeenRenownLevel = tonumber(majorFactionRenownMap[self.majorFactionData.factionID]) or 0;
	-- We should only update the CVar when the value is higher than what we have stored
	-- For cases where renown is account wide, we want to remember the highest level you've seen on any character
	local shouldOverwriteLastSeenRenown = self.actualLevel > lastSeenRenownLevel;
	if shouldOverwriteLastSeenRenown then
		majorFactionRenownMap[self.majorFactionData.factionID] = self.actualLevel;
		SetCVarTable("majorFactionRenownMap", majorFactionRenownMap);
	end
end

function JourneyProgressFrameMixin:OnMouseWheel(direction)
	local centerIndex = self.track:GetCenterIndex();
	centerIndex = centerIndex + (direction * -1);
	local forceRefresh = false;
	local skipSound = false;
	local overrideStopSound = SOUNDKIT.UI_MAJOR_FACTION_RENOWN_SLIDE_START;
	self.track:SetSelection(centerIndex, forceRefresh, skipSound, overrideStopSound);
end

function JourneyProgressFrameMixin:Refresh()
	if self.majorFactionData.isRenownJourney then
		self.OverviewBtn:Show();
	else
		self.OverviewBtn:Hide();
	end

	local buttonData = {
		id = self.majorFactionData and self.majorFactionData.factionID or 0,
		name = self.majorFactionData and self.majorFactionData.name or "",
		listFunc = GetJourneysForNavBar,
	};
	NavBar_AddButton(EncounterJournal.navBar, buttonData);

	self.JourneyName:SetText(self.majorFactionData.name);
	self:CheckLockedState();
	self:SetupRewardTrack();
	self:GetLevels();

	local forceRefresh = true;
	self:SelectLevel(not self.isLocked and self.actualLevel or 1, forceRefresh);
end

function JourneyProgressFrameMixin:CheckLockedState()
	if not self.majorFactionData.isUnlocked then
		self.isLocked = true;
		self.LockedStateFrame:Show();
		self.ProgressDetailsFrame:Hide();
		self.DelveRewardProgressBar:Hide();
	else
		self.isLocked = false;
		self.LockedStateFrame:Hide();
		self:SetupProgressDetails();
		self.ProgressDetailsFrame:Show();
		self.DelveRewardProgressBar:Show();
	end
end

function JourneyProgressFrameMixin:SetupProgressDetails()
	local progressFrame = self.ProgressDetailsFrame;
	local level;
	local threshold;
	local progress;

	if self.majorFactionData.paragonInfo then
		level = self.majorFactionData.renownLevel + self.majorFactionData.paragonInfo.level;
		threshold = self.majorFactionData.paragonInfo.threshold;
		progress = self.majorFactionData.paragonInfo.value - (threshold * self.majorFactionData.paragonInfo.level);
	else
		level = self.majorFactionData.renownLevel;
		threshold = self.majorFactionData.renownLevelThreshold;
		progress = self.majorFactionData.renownReputationEarned;
	end

	progressFrame.JourneyLevel:SetText(level);
	progressFrame.JourneyLevelProgress:SetText(JOURNEYS_CURRENT_PROGRESS:format(progress, threshold));
	self.DelveRewardProgressBar:SetMinMaxValues(0, threshold);
	self.DelveRewardProgressBar:SetValue(progress);
end

function JourneyProgressFrameMixin:GetLevels()
	local renownLevel = C_MajorFactions.GetCurrentRenownLevel(self.majorFactionData.factionID);
	self.actualLevel = renownLevel;
	local majorFactionRenownMap = GetCVarTable("majorFactionRenownMap");
	local lastRenownLevel = tonumber(majorFactionRenownMap[self.majorFactionData.factionID]) or 1;
	if lastRenownLevel < renownLevel then
		renownLevel = lastRenownLevel;
	end
	self.displayLevel = renownLevel;
end

function JourneyProgressFrameMixin:SelectLevel(level, forceRefresh)
	local selectionIndex;
	local elements = self.track:GetElements();
	for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	self.track:SetSelection(selectionIndex, forceRefresh);
end

--! TODO wip, required function but no behavior yet (haven't done animations yet, not sure if reusing old ones)
function JourneyProgressFrameMixin:CancelLevelEffect()
end

function JourneyProgressFrameMixin:SetupRewardTrack()
	self.renownLevelsInfo = C_MajorFactions.GetRenownLevels(self.majorFactionData.factionID);
	self.maxLevel = self.renownLevelsInfo[#self.renownLevelsInfo].level;

	for level, levelInfo in ipairs(self.renownLevelsInfo) do
		levelInfo.rewardInfo = C_MajorFactions.GetRenownRewardsForLevel(self.majorFactionData.factionID, level);
	end

	-- NOTE -> Renown uses a certain prog bar/template, and encounters (Delves/Prey for now) use a different one. This could be configured in data with flags, but for now just handle it like we do the buttons
	if self.majorFactionData.isRenownJourney then
		self.EncounterRewardProgressFrame:Hide();
		self.RenownTrackFrame:Init(self.renownLevelsInfo, self.majorFactionData.paragonInfo);
		self.RenownTrackFrame:Show();
		self.track = self.RenownTrackFrame;
		self.DividerTexture:SetPoint("TOP", self.track, "BOTTOM", 0, -15);
	else
		self.RenownTrackFrame:Hide();
		self.EncounterRewardProgressFrame:Init(self.renownLevelsInfo, self.majorFactionData.paragonInfo);
		self.EncounterRewardProgressFrame:Show();
		self.track = self.EncounterRewardProgressFrame;
		self.DividerTexture:SetPoint("TOP", self.track, "BOTTOM", 0, 0);
	end
end

function JourneyProgressFrameMixin:OnTrackUpdate(leftIndex, centerIndex, rightIndex, isMoving)
	local elements = self.track:GetElements();
	local selectedElement = elements[centerIndex];
	local selectedLevel = selectedElement:GetLevel();
	for i = leftIndex, rightIndex do
		local selected = not self.moving and centerIndex == i;
		local frame = elements[i];
		frame:Refresh(self.actualLevel, self.displayLevel, selected);
		local alpha = self.track:GetDesiredAlphaForIndex(i);
		frame:ApplyAlpha(alpha);
	end

	self.rewardPool:ReleaseAll();
	self.DelvesCompanionConfigurationFrame.CompanionConfigBtn:Hide();
	self.DelvesCompanionConfigurationFrame:Hide();

	-- If player companion ID set, we're looking at a Delve, so show those options. Otherwise show reward details.
	if self.majorFactionData.playerCompanionID and self.majorFactionData.playerCompanionID ~= 0 then
		local companionFactionID = C_DelvesUI.GetFactionForCompanion(self.majorFactionData.playerCompanionID);
		local companionFactionInfo = C_Reputation.GetFactionDataByID(companionFactionID);
		self.DelvesCompanionConfigurationFrame.CompanionConfigBtn.CompanionName:SetText(companionFactionInfo and companionFactionInfo.name or "");

		SetPortraitTextureFromCreatureDisplayID(self.DelvesCompanionConfigurationFrame.CompanionConfigBtn.Icon, C_DelvesUI.GetCreatureDisplayInfoForCompanion(self.majorFactionData.playerCompanionID));
		self.DelvesCompanionConfigurationFrame:Show();
		self.DelvesCompanionConfigurationFrame.CompanionConfigBtn:Show();
		self.DividerTexture:Show();
	elseif not C_MajorFactions.ShouldDisplayMajorFactionAsJourney(self.majorFactionData.factionID) then
		self:SetRewards(selectedLevel);
		self.DividerTexture:Show();
	else
		self.DividerTexture:Hide();
	end
end

function JourneyProgressFrameMixin:SetRewards(level)
	local rewardInfo = self.renownLevelsInfo[level].rewardInfo;
	local lastReward;
	local firstRewardOfRow;

	for idx, reward in ipairs(rewardInfo) do
		if idx <= MAX_REWARD_CARDS_TO_DISPLAY then
			local rewardFrame = self.rewardPool:Acquire();

			if reward.rewardType then
				local rewardIsItem = reward.rewardType == Enum.RenownRewardDisplayType.Item;
				local rewardIsMount = reward.rewardType == Enum.RenownRewardDisplayType.Mount;
				local rewardIsTitle =  reward.rewardType == Enum.RenownRewardDisplayType.Title;
				local rewardIsCurrency = reward.rewardType == Enum.RenownRewardDisplayType.Currency;

				if rewardIsItem or rewardIsMount or rewardIsTitle then
					rewardFrame.RewardCardIconBorderDefault:SetAtlas("talents-node-circle-gray"); --! TODO not final art
					rewardFrame.TextureMask:SetAtlas("CircleMask");
					rewardFrame.TextureMask:Show();
				elseif rewardIsCurrency then
					rewardFrame.RewardCardIconBorderDefault:SetAtlas("covenantsanctum-renown-hexagon-border-standard"); --! TODO not final art
					rewardFrame.TextureMask:SetAtlas("talents-node-choice-mask");
					rewardFrame.TextureMask:Show();
				else
					rewardFrame.RewardCardIconBorderDefault:SetAtlas("UI-Frame-IconBorder");
					rewardFrame.TextureMask:Hide();
				end
			else
				rewardFrame.RewardCardIconBorderDefault:SetAtlas("UI-Frame-IconBorder");
				rewardFrame.TextureMask:Hide();
			end

			rewardFrame.RewardCardName:SetText(reward.name);
			rewardFrame.RewardCardIcon:SetTexture(reward.icon);

			rewardFrame:SetScript("OnEnter", function(frame)
				GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
				GameTooltip_SetTitle(GameTooltip, reward.name);

				if reward.isAccountUnlock then
					local wrapText = false;
					GameTooltip_AddColoredLine(GameTooltip, RENOWN_REWARD_ACCOUNT_UNLOCK_LABEL, ACCOUNT_WIDE_FONT_COLOR, wrapText);
				end

				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddNormalLine(GameTooltip, reward.description);
				GameTooltip:Show();
			end);

			rewardFrame:SetScript("OnLeave", function(frame)
				if GameTooltip:GetOwner() == frame then
					GameTooltip_Hide();
				end
			end);

			if #rewardInfo == 1 then
				rewardFrame:SetPoint("TOP", self.DividerTexture, "BOTTOM", 15, -50);
				rewardFrame:SetPoint("CENTER", self, "CENTER");
			elseif #rewardInfo == 2 then
				if idx == 1 then
					firstRewardOfRow = rewardFrame;
					rewardFrame:SetPoint("TOP", self.DividerTexture, "BOTTOM", 15, -20);
					rewardFrame:SetPoint("CENTER", self, "CENTER");
				else
					rewardFrame:SetPoint("TOP", firstRewardOfRow, "BOTTOM", 0, -15);
				end
			elseif #rewardInfo > 2 then
				local isFirst = idx == 1;
				local isEndOfRow = idx % 2 == 0;

				if isFirst then
					firstRewardOfRow = rewardFrame;
					rewardFrame:SetPoint("TOPLEFT", self.Divider, "BOTTOMLEFT", 15, -15);
				elseif isEndOfRow then
					rewardFrame:SetPoint("TOPLEFT", lastReward, "TOPRIGHT", 25, 0);
				else
					rewardFrame:SetPoint("TOPLEFT", firstRewardOfRow, "BOTTOMLEFT", 0, -10);
				end
			end
			lastReward = rewardFrame;
			rewardFrame:Show();
		end
	end
end

-------------------------------------[[ Journey "Progress" Locked State Frame ]]-------------------------------------------------------
JourneysLockedStateMixin = {};

function JourneysLockedStateMixin:OnShow()
	self.JourneyLockedText:SetScript("OnEnter", self.ShowUnlockDescriptionTooltip);
	self.JourneyLockedText:SetScript("OnLeave", self.HideUnlockDescriptionTooltip);
	self.LockIcon:SetScript("OnEnter", self.ShowUnlockDescriptionTooltip);
	self.LockIcon:SetScript("OnLeave", self.HideUnlockDescriptionTooltip);
end

function JourneysLockedStateMixin:UpdateState()
	if not self:GetParent().majorFactionData.isUnlocked then
		self.JourneyLockedText:Show();
		self.LockIcon:Show();
	else
		self.JourneyLockedText:Hide();
		self.LockIcon:Hide();
	end
end

function JourneysLockedStateMixin:ShowUnlockDescriptionTooltip()
	local journeysFrame = self:GetParent():GetParent();

	if journeysFrame.majorFactionData and journeysFrame.majorFactionData.unlockDescription then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		GameTooltip_AddColoredLine(GameTooltip, journeysFrame.majorFactionData.unlockDescription, RED_FONT_COLOR);
		GameTooltip:Show();
	end
end

function JourneysLockedStateMixin:HideUnlockDescriptionTooltip()
	if GameTooltip:GetOwner() == self then
		GameTooltip_Hide();
	end
end

-------------------------------------[[ Journey Overview Button ]]-------------------------------------------------------
JourneyOverviewBtnMixin = {};

function JourneyOverviewBtnMixin:OnClick()
	local journeysFrame = EncounterJournal.JourneysFrame;

	if journeysFrame.JourneyProgress:IsShown() then
		journeysFrame.JourneyProgress:Hide();
		journeysFrame.JourneyOverview.majorFactionData = self:GetParent().majorFactionData;
		journeysFrame.JourneyOverview:Show();
	elseif journeysFrame.JourneyOverview:IsShown() then
		journeysFrame.JourneyOverview:Hide();
		NavBar_Reset(EncounterJournal.navBar);
		journeysFrame.JourneyProgress.majorFactionData = self:GetParent().majorFactionData;
		journeysFrame.JourneyProgress:Show();
	end
end

-------------------------------------[[ Journey Overview Frame ]]-------------------------------------------------------
JourneyOverviewFrameMixin = {};

function JourneyOverviewFrameMixin:OnShow()
	self.JourneyIcon:SetAtlas(MAJOR_FACTION_ICON_ATLAS_FMT:format(self.majorFactionData.textureKit)) --! TODO not final
	self.JourneyName:SetText(self.majorFactionData.name);

	if C_Reputation.IsAccountWideReputation(self.majorFactionData.factionID) then
		self.JourneyWarbandLabel:Show();
		self.JourneyDescription:SetPoint("TOP", self.JourneyWarbandLabel, "BOTTOM", 0, -10);
	else
		self.JourneyWarbandLabel:Hide();
		self.JourneyDescription:SetPoint("TOP", self.JourneyName, "BOTTOM", 0, -10);
	end

	local padding = 15;
	self.JourneyDescription:SetText(self.majorFactionData.description);
	self.JourneyDescription:SetHeight(self.JourneyDescription:GetStringHeight() + padding);

	self:SetupHighlights();
end

function JourneyOverviewFrameMixin:SetupHighlights()
	if #self.majorFactionData.highlights >= 1 then
		self.Highlights.highlightsList = self.majorFactionData.highlights;
		self.Divider:Show();
		self.HighlightLabel:Show();
		self.Highlights:Show();
	else
		self.Divider:Hide();
		self.HighlightLabel:Hide();
		self.Highlights:Hide();
	end
end

-------------------------------------[[ Journey Overview Highlights Frame ]]-------------------------------------------------------
JourneyOverviewHighlightsFrameMixin = {};

function JourneyOverviewHighlightsFrameMixin:OnLoad()
	local function HighlightResetter(framePool, frame)
		frame.HighlightText:SetText("");
		Pool_HideAndClearAnchors(framePool, frame);
	end

	self.highlightPool = CreateFramePool("FRAME", self, "JourneyOverviewHighlightTemplate", HighlightResetter);
end

function JourneyOverviewHighlightsFrameMixin:OnShow()
	self.highlightPool:ReleaseAll();

	local lastHighlight;
	local firstHighlightOfRow;
	for idx, highlight in ipairs(self.highlightsList) do
		local highlightFrame = self.highlightPool:Acquire();

		highlightFrame.HighlightText:SetText(highlight);

		local isFirst = idx == 1;
		local isEndOfRow = idx % 4 == 0;
		if isFirst then
			firstHighlightOfRow = highlightFrame;
			highlightFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 0);
		elseif isEndOfRow then
			highlightFrame:SetPoint("TOPLEFT", firstHighlightOfRow, "BOTTOMLEFT", 0, -20);
		else
			highlightFrame:SetPoint("TOPLEFT", lastHighlight, "TOPRIGHT", 15, 0);
		end

		lastHighlight = highlightFrame;
		highlightFrame:Show();
	end
end

-------------------------------------[[ Journey Companion Config Button ]]-------------------------------------------------------
JourneyCompanionConfigBtnMixin = {};

-- In order to be able to use companion config, players need to have unlocked a companion and have it set with a proper trait config
function JourneyCompanionConfigBtnMixin:SetCompanionEnabledState()
	local progressFrame = self:GetParent():GetParent();

	if progressFrame and progressFrame.majorFactionData and progressFrame.majorFactionData.playerCompanionID then
		local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(progressFrame.majorFactionData.playerCompanionID);

		if C_Traits.GetConfigIDByTreeID(traitTreeID) then
			self.enabled = true;
		else
			self.enabled = false;
		end
	else
		self.enabled = false;
	end
	self:SetEnabled(self.enabled);
end

function JourneyCompanionConfigBtnMixin:OnShow()
	self:SetCompanionEnabledState();
end

function JourneyCompanionConfigBtnMixin:ToggleCompanionConfig()
	if not DelvesCompanionConfigurationFrame:IsShown() then
		local playerCompanionID = self:GetParent():GetParent().majorFactionData.playerCompanionID;
		DelvesCompanionConfigurationFrame.playerCompanionID = playerCompanionID;
		ShowUIPanel(DelvesCompanionConfigurationFrame);
	else
		HideUIPanel(DelvesCompanionConfigurationFrame);
	end
end

function JourneyCompanionConfigBtnMixin:OnEnter()
	if not self.enabled then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, DELVES_COMPANION_NOT_ENABLED_TOOLTIP); --! TODO will need to update this string
		GameTooltip:Show();
	end
end

function JourneyCompanionConfigBtnMixin:OnClick()
	if self.enabled then
		self:ToggleCompanionConfig();
	end
end

-------------------------------------[[ Watched Faction Toggle ]]-------------------------------------------------------
WatchedFactionToggleFrameMixin = {};

function WatchedFactionToggleFrameMixin:OnShow()
	self.renownCard = self:GetParent():GetParent();
	local majorFactionData = self.renownCard.majorFactionData;

	self.factionID = majorFactionData and majorFactionData.factionID or 0;

	local factionData = C_Reputation.GetFactionDataByID(self.factionID);
	self:SetChecked(factionData and factionData.isWatched or false);
end

function WatchedFactionToggleFrameMixin:OnClick()
	C_Reputation.SetWatchedFactionByID(self:GetChecked() and self.factionID or 0);

	StatusTrackingBarManager:UpdateBarsShown();

	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
	PlaySound(clickSound);
end

function WatchedFactionToggleFrameMixin:OnEnter()
	self:SetPropagateMouseClicks(false);
	self.renownCard:OnEnter();
end

function WatchedFactionToggleFrameMixin:OnLeave()
	self.renownCard:OnLeave();
end
