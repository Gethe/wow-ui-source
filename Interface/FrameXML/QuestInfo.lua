local REWARDS_SECTION_OFFSET = 5;		-- vertical distance between sections
local REWARDS_ROW_OFFSET = 2;			-- vertical distance between rows within a section

function QuestInfoTimerFrame_OnUpdate(self, elapsed)
	if ( self.timeLeft ) then
		self.timeLeft = max(self.timeLeft - elapsed, 0);
		QuestInfoTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(self.timeLeft));
	end
end

function QuestInfoItem_OnClick(self)
	if ( self.type == "choice" ) then
		QuestInfoItemHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -8, 7);
		QuestInfoItemHighlight:Show();
		QuestInfoFrame.itemChoice = self:GetID();
	end
end

local ACTIVE_TEMPLATE;

function QuestInfo_Display(template, parentFrame, acceptButton, material, mapView)
	ACTIVE_TEMPLATE = template;

	if ( template.canHaveSealMaterial ) then
		local questFrame = parentFrame:GetParent():GetParent();
		if QuestUtil.QuestTextContrastEnabled() then
			questFrame.SealMaterialBG:Hide();
		else
			local questID;
			if ( template.questLog ) then
				questID = questFrame.questID;
			else
				questID = GetQuestID();
			end

			local theme = C_QuestLog.GetQuestDetailsTheme(questID);
			QuestInfoSealFrame.theme = theme;

			local hasValidBackground = theme and theme.background;
			questFrame.SealMaterialBG:SetShown(hasValidBackground);
			if hasValidBackground then
				questFrame.SealMaterialBG:SetAtlas(theme.background);
			end
		end
	end

	QuestInfoFrame.questLog = template.questLog;
	QuestInfoFrame.chooseItems = template.chooseItems;
	QuestInfoFrame.acceptButton = acceptButton;

	if ( QuestInfoFrame.mapView ~= mapView ) then
		QuestInfoFrame.mapView = mapView;
		if ( mapView ) then
			QuestInfoFrame.rewardsFrame = MapQuestInfoRewardsFrame;
			QuestInfoRewardsFrame:Hide();
		else
			QuestInfoFrame.rewardsFrame = QuestInfoRewardsFrame;
			MapQuestInfoRewardsFrame:Hide();
		end
	end
	if ( QuestInfoFrame.material ~= material ) then
		QuestInfoFrame.material = material;
		local textColor, titleTextColor = GetMaterialTextColors(material);
		-- headers
		QuestInfoTitleHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoDescriptionHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoObjectivesHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoRewardsFrame.Header:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		-- other text
		QuestInfoDescriptionText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoObjectivesText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoGroupSize:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		-- reward frame text
		QuestInfoRewardsFrame.ItemChooseText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardsFrame.QuestSessionBonusReward:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);

		QuestInfoRewardsFrame.spellHeaderPool.textR, QuestInfoRewardsFrame.spellHeaderPool.textG, QuestInfoRewardsFrame.spellHeaderPool.textB = textColor[1], textColor[2], textColor[3];
	end

	-- Quest titles (and maybe a few other things) can have hyperlinks, so ensure that the new parent of the element frames
	-- is able to handle them.
	if not parentFrame.questInfoHyperlinksInstalled then
		parentFrame.questInfoHyperlinksInstalled = true;
		assert(parentFrame:GetScript("OnHyperlinkEnter") == nil);
		parentFrame:SetHyperlinksEnabled(true);
		parentFrame:SetScript("OnHyperlinkEnter", QuestInfo_OnHyperlinkEnter);
		parentFrame:SetScript("OnHyperlinkLeave", QuestInfo_OnHyperlinkLeave);
	end

	local elementsTable = template.elements;
	local lastFrame;
	for i = 1, #elementsTable, 3 do
		local shownFrame, bottomShownFrame = elementsTable[i](parentFrame);
		if ( shownFrame ) then
			shownFrame:SetParent(parentFrame);
			shownFrame:ClearAllPoints();
			if ( lastFrame ) then
				shownFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", elementsTable[i+1], elementsTable[i+2]);
			else
				shownFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", elementsTable[i+1], elementsTable[i+2]);
			end
			lastFrame = bottomShownFrame or shownFrame;
		end
	end
end

local function QuestInfo_GetQuestID()
	if ( QuestInfoFrame.questLog ) then
		return C_QuestLog.GetSelectedQuest();
	else
		return GetQuestID();
	end
end

local function DecorateQuestTitle(title, useLargeIcon)
	return QuestUtils_DecorateQuestText(QuestInfo_GetQuestID(), title, useLargeIcon) or "";
end

-- NOTE: Also returns whether or not to do failure checking
local function QuestInfo_GetTitle()
	local useLargeIcon = true;
	if ( QuestInfoFrame.questLog ) then
		local title = C_QuestLog.GetTitleForQuestID(C_QuestLog.GetSelectedQuest());
		return DecorateQuestTitle(title, useLargeIcon), true;
	else
		local title = GetTitleText();
		return DecorateQuestTitle(title, useLargeIcon), false;
	end
end

function QuestInfo_AdjustTitleWidth(delta)
	QuestInfoTitleHeader:SetWidth(ACTIVE_TEMPLATE.contentWidth + delta);
end

function QuestInfo_ShowTitle()
	local title, doFailureBehavior = QuestInfo_GetTitle();

	if doFailureBehavior and IsCurrentQuestFailed() then
		title = QUEST_TITLE_FORMAT_FAILED:format(title);
	end

	QuestInfoTitleHeader:SetText(title);
	QuestInfoTitleHeader:SetWidth(ACTIVE_TEMPLATE.contentWidth);
	return QuestInfoTitleHeader;
end

function QuestInfo_ShowType()
	local questTypeMarkup = QuestUtils_GetQuestTypeTextureMarkupString(C_QuestLog.GetSelectedQuest());
	local showType = questTypeMarkup ~= nil;

	QuestInfoQuestType:SetShown(showType);

	if ( showType ) then
		QuestInfoQuestType:SetText(questTypeMarkup);
		return QuestInfoQuestType;
	end
end

function QuestInfo_ShowDescriptionText()
	local questDescription;
	if ( QuestInfoFrame.questLog ) then
		questDescription = GetQuestLogQuestText();
	else
		questDescription = GetQuestText();
	end
	QuestInfoDescriptionText:SetText(questDescription);
	QuestInfoDescriptionText:SetWidth(ACTIVE_TEMPLATE.contentWidth);
	return QuestInfoDescriptionText;
end

function QuestInfo_ShowObjectives()
	local questID = QuestInfo_GetQuestID();
	local numObjectives = GetNumQuestLeaderBoards();
	local objective;
	local text, type, finished;
	local objectivesTable = QuestInfoObjectivesFrame.Objectives;
	local numVisibleObjectives = 0;

	local function AcquireObjective(index)
		local newObjective = objectivesTable[index];

		if ( not newObjective ) then
			newObjective = QuestInfoObjectivesFrame:CreateFontString("QuestInfoObjective"..index, "BACKGROUND", "QuestFontNormalSmall");
			newObjective:SetPoint("TOPLEFT", objectivesTable[index - 1], "BOTTOMLEFT", 0, -2);
			newObjective:SetJustifyH("LEFT");
			newObjective:SetWidth(285);
			objectivesTable[index] = newObjective;
		end

		return newObjective;
	end

	local waypointText = C_QuestLog.GetNextWaypointText(questID);
	if ( waypointText ) then
		numVisibleObjectives = numVisibleObjectives + 1;
		objective = AcquireObjective(numVisibleObjectives);
		objective:SetText(WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL:format(waypointText));
		objective:SetTextColor(0, 0, 0);
		objective:SetWidth(ACTIVE_TEMPLATE.contentWidth);
		objective:Show();
	end

	for i = 1, numObjectives do
		text, type, finished = GetQuestLogLeaderBoard(i);
		if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
			numVisibleObjectives = numVisibleObjectives+1;
			objective = AcquireObjective(numVisibleObjectives);
			if ( not text or strlen(text) == 0 ) then
				text = type;
			end
			if ( finished ) then
				objective:SetTextColor(0.2, 0.2, 0.2);
				text = text.." ("..COMPLETE..")";
			else
				objective:SetTextColor(0, 0, 0);
			end
			objective:SetText(text);
			objective:SetWidth(ACTIVE_TEMPLATE.contentWidth);
			objective:Show();
		end
	end
	for i = numVisibleObjectives + 1, #objectivesTable do
		objectivesTable[i]:Hide();
	end
	if ( objective ) then
		QuestInfoObjectivesFrame:Show();
		return QuestInfoObjectivesFrame, objective;
	else
		QuestInfoObjectivesFrame:Hide();
		return nil;
	end
end

function QuestInfo_ShowSpecialObjectives()
	-- Show objective spell
	local spellID, spellName, spellTexture, finished;
	if ( QuestInfoFrame.questLog) then
		spellID, spellName, spellTexture, finished = GetQuestLogCriteriaSpell();
	else
		spellID, spellName, spellTexture, finished = GetCriteriaSpell();
	end

	local lastFrame = nil;
	local totalHeight = 0;

	if (spellID) then
		QuestInfoSpellObjectiveFrame.Icon:SetTexture(spellTexture);
		QuestInfoSpellObjectiveFrame.Name:SetText(spellName);
		QuestInfoSpellObjectiveFrame.spellID = spellID;

		QuestInfoSpellObjectiveFrame:ClearAllPoints();
		if (lastFrame) then
			QuestInfoSpellObjectiveLearnLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -4);
			totalHeight = totalHeight + 4;
		else
			QuestInfoSpellObjectiveLearnLabel:SetPoint("TOPLEFT", 0, 0);
		end

		QuestInfoSpellObjectiveFrame:SetPoint("TOPLEFT", QuestInfoSpellObjectiveLearnLabel, "BOTTOMLEFT", 0, -4);

		if (finished and QuestInfoFrame.questLog) then -- don't show as completed for the initial offer, as it won't update properly
			QuestInfoSpellObjectiveLearnLabel:SetText(LEARN_SPELL_OBJECTIVE.." ("..COMPLETE..")");
			QuestInfoSpellObjectiveLearnLabel:SetTextColor(0.2, 0.2, 0.2);
		else
			QuestInfoSpellObjectiveLearnLabel:SetText(LEARN_SPELL_OBJECTIVE);
			QuestInfoSpellObjectiveLearnLabel:SetTextColor(0, 0, 0);
		end

		QuestInfoSpellObjectiveLearnLabel:Show();
		QuestInfoSpellObjectiveFrame:Show();
		totalHeight = totalHeight + QuestInfoSpellObjectiveFrame:GetHeight() + QuestInfoSpellObjectiveLearnLabel:GetHeight();
		lastFrame = QuestInfoSpellObjectiveFrame;
	else
		QuestInfoSpellObjectiveFrame:Hide();
		QuestInfoSpellObjectiveLearnLabel:Hide();
	end

	if (lastFrame) then
		QuestInfoSpecialObjectivesFrame:SetHeight(totalHeight);
		QuestInfoSpecialObjectivesFrame:Show();
		return QuestInfoSpecialObjectivesFrame;
	else
		QuestInfoSpecialObjectivesFrame:Hide();
		return nil;
	end
end

function QuestInfo_ShowTimer()
	local timeLeft = GetQuestLogTimeLeft();
	QuestInfoTimerFrame.timeLeft = timeLeft;
	if ( timeLeft ) then
		QuestInfoTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(timeLeft));
		QuestInfoTimerText:SetWidth(ACTIVE_TEMPLATE.contentWidth);
		QuestInfoTimerFrame:SetHeight(QuestInfoTimerFrame:GetTop() - QuestInfoTimerText:GetTop() + QuestInfoTimerText:GetHeight());
		QuestInfoTimerFrame:Show();
		return QuestInfoTimerFrame;
	else
		QuestInfoTimerFrame:Hide();
		return nil;
	end
end

function QuestInfo_ShowRequiredMoney()
	local requiredMoney = C_QuestLog.GetRequiredMoney();
	if ( requiredMoney > 0 ) then
		MoneyFrame_Update("QuestInfoRequiredMoneyDisplay", requiredMoney);
		if ( requiredMoney > GetMoney() ) then
			-- Not enough money
			QuestInfoRequiredMoneyText:SetTextColor(0, 0, 0);
			SetMoneyFrameColor("QuestInfoRequiredMoneyDisplay", "red");
		else
			QuestInfoRequiredMoneyText:SetTextColor(0.2, 0.2, 0.2);
			SetMoneyFrameColor("QuestInfoRequiredMoneyDisplay", "white");
		end
		QuestInfoRequiredMoneyFrame:Show();
		return QuestInfoRequiredMoneyFrame;
	else
		QuestInfoRequiredMoneyFrame:Hide();
		return nil;
	end
end

function QuestInfo_ShowGroupSize()
	local groupNum;
	if ( QuestInfoFrame.questLog ) then
		groupNum = C_QuestLog.GetSuggestedGroupSize(C_QuestLog.GetSelectedQuest());
	else
		groupNum = GetSuggestedGroupSize();
	end
	if ( groupNum > 0 ) then
		local suggestedGroupString = format(QUEST_SUGGESTED_GROUP_NUM, groupNum);
		QuestInfoGroupSize:SetText(suggestedGroupString);
		QuestInfoGroupSize:Show();
		return QuestInfoGroupSize;
	else
		QuestInfoGroupSize:Hide();
		return nil;
	end
end

function QuestInfo_ShowDescriptionHeader()
	return QuestInfoDescriptionHeader;
end

function QuestInfo_ShowObjectivesHeader()
	return QuestInfoObjectivesHeader;
end

function QuestInfo_ShowObjectivesText()
	local questObjectives, _;
	if ( QuestInfoFrame.questLog ) then
		_, questObjectives = GetQuestLogQuestText();
	else
		questObjectives = GetObjectiveText();
	end
	QuestInfoObjectivesText:SetText(questObjectives);
	QuestInfoObjectivesText:SetWidth(ACTIVE_TEMPLATE.contentWidth);
	return QuestInfoObjectivesText;
end

function QuestInfo_ShowSpacer()
	return QuestInfoSpacerFrame;
end

function QuestInfo_ShowAnchor()
	return QuestInfoAnchor;
end

function QuestInfo_ShowRewardText()
	QuestInfoRewardText:SetText(GetRewardText());
	return QuestInfoRewardText;
end

function QuestInfo_ShowSeal(parentFrame)
	local frame = QuestInfoSealFrame;
	local theme = frame.theme;
	local hasAnyPartOfTheSeal = theme and (theme.signature ~= "" or theme.seal);
	frame:SetShown(hasAnyPartOfTheSeal);

	if hasAnyPartOfTheSeal then
		-- Temporary anchor to ensure :IsTruncated will work for the seal text.
		frame:SetPoint("CENTER", parentFrame or UIParent);

		frame.Text:SetText(theme.signature);
		frame.Texture:SetShown(theme.seal ~= nil);
		if theme.seal then
			frame.Texture:SetAtlas(theme.seal, true);
			frame.Texture:SetPoint("TOPLEFT", ACTIVE_TEMPLATE.sealXOffset, ACTIVE_TEMPLATE.sealYOffset);
		end

		return frame;
	end

	return nil;
end

function QuestInfo_GetRewardButton(rewardsFrame, index)
	local rewardButtons = rewardsFrame.RewardButtons;
	if ( not rewardButtons[index] ) then
		local button = CreateFrame("BUTTON", "$parentQuestInfoItem"..index, rewardsFrame, rewardsFrame.buttonTemplate);
		rewardButtons[index] = button;
	end
	return rewardButtons[index];
end

QUEST_SPELL_REWARD_TYPE_FOLLOWER = 1;
QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL = 2;
QUEST_SPELL_REWARD_TYPE_ABILITY = 3;
QUEST_SPELL_REWARD_TYPE_AURA = 4;
QUEST_SPELL_REWARD_TYPE_SPELL = 5;
QUEST_SPELL_REWARD_TYPE_UNLOCK = 6;
QUEST_SPELL_REWARD_TYPE_COMPANION = 7;

QUEST_INFO_SPELL_REWARD_ORDERING = {
	QUEST_SPELL_REWARD_TYPE_FOLLOWER,
	QUEST_SPELL_REWARD_TYPE_COMPANION,
	QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL,
	QUEST_SPELL_REWARD_TYPE_ABILITY,
	QUEST_SPELL_REWARD_TYPE_AURA,
	QUEST_SPELL_REWARD_TYPE_SPELL,
	QUEST_SPELL_REWARD_TYPE_UNLOCK,
};

QUEST_INFO_SPELL_REWARD_TO_HEADER = {
	[QUEST_SPELL_REWARD_TYPE_FOLLOWER] = REWARD_FOLLOWER,
	[QUEST_SPELL_REWARD_TYPE_COMPANION] = REWARD_COMPANION,
	[QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL] = REWARD_TRADESKILL_SPELL,
	[QUEST_SPELL_REWARD_TYPE_ABILITY] = REWARD_ABILITY,
	[QUEST_SPELL_REWARD_TYPE_AURA] = REWARD_AURA,
	[QUEST_SPELL_REWARD_TYPE_SPELL] = REWARD_SPELL,
	[QUEST_SPELL_REWARD_TYPE_UNLOCK] = REWARD_UNLOCK,
};

local function AddSpellToBucket(spellBuckets, type, rewardSpellIndex)
	if not spellBuckets[type] then
		spellBuckets[type] = {};
	end

	table.insert(spellBuckets[type], rewardSpellIndex);
end

local function QuestInfo_ShowRewardAsItemCommon(questItem, index, questLogQueryFunction)
	local name, texture, numItems, quality, isUsable, itemID;

	if ( QuestInfoFrame.questLog ) then
		name, texture, numItems, quality, isUsable, itemID = questLogQueryFunction(index);
		SetItemButtonQuality(questItem, quality, itemID);
	else
		name, texture, numItems, quality, isUsable, itemID = GetQuestItemInfo(questItem.type, index);
		SetItemButtonQuality(questItem, quality, GetQuestItemLink(questItem.type, index));
	end

	questItem.objectType = "item";
	questItem:SetID(index);
	questItem:Show();

	local item = Item:CreateFromItemID(itemID);
	item:ContinueOnItemLoad(function()
		if ( QuestInfoFrame.questLog ) then
			name, texture, numItems, quality, isUsable = questLogQueryFunction(index);
			SetItemButtonQuality(questItem, quality, itemID);
		else
			name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, index);
			SetItemButtonQuality(questItem, quality, GetQuestItemLink(questItem.type, index));
		end

		-- For the tooltip
		questItem.Name:SetText(name);
		SetItemButtonCount(questItem, numItems);
		SetItemButtonTexture(questItem, texture);
		if ( isUsable ) then
			SetItemButtonTextureVertexColor(questItem, 1.0, 1.0, 1.0);
			SetItemButtonNameFrameVertexColor(questItem, 1.0, 1.0, 1.0);
		else
			SetItemButtonTextureVertexColor(questItem, 0.9, 0, 0);
			SetItemButtonNameFrameVertexColor(questItem, 0.9, 0, 0);
		end
	end);
end

local function QuestInfo_ShowRewardAsItem(questItem, index)
	QuestInfo_ShowRewardAsItemCommon(questItem, index, GetQuestLogChoiceInfo);
end

local function QuestInfo_ShowFixedRewardAsItem(questItem, index)
	QuestInfo_ShowRewardAsItemCommon(questItem, index, GetQuestLogRewardInfo);
end

local function QuestInfo_ShowRewardAsCurrency(questItem, index, isChoice)
	local name, texture, quality, amount, currencyID;
	if ( QuestInfoFrame.questLog ) then
		name, texture, amount, currencyID, quality = GetQuestLogRewardCurrencyInfo(index, questItem.questID, isChoice);
	else
		name, texture, amount, quality = GetQuestCurrencyInfo(questItem.type, index);
		currencyID = GetQuestCurrencyID(questItem.type, index);
	end
	name, texture, amount, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, amount, name, texture, quality);

	questItem.objectType = "currency";
	questItem:SetID(index)
	-- For the tooltip
	questItem.Name:SetText(name);
	SetItemButtonCount(questItem, amount, true);
	local currencyColor = GetColorForCurrencyReward(currencyID, amount);
	questItem.Count:SetTextColor(currencyColor:GetRGB());
	SetItemButtonTexture(questItem, texture);
	SetItemButtonTextureVertexColor(questItem, 1.0, 1.0, 1.0);
	SetItemButtonNameFrameVertexColor(questItem, 1.0, 1.0, 1.0);
	SetItemButtonQuality(questItem, quality, currencyID);
end

function QuestInfo_ShowRewards()
	local numQuestRewards = 0;
	local numQuestChoices = 0;
	local numQuestCurrencies = 0;
	local numQuestSpellRewards = 0;
	local money = 0;
	local skillName;
	local skillPoints;
	local skillIcon;
	local xp = 0;
	local artifactXP = 0;
	local artifactCategory;
	local honor = 0;
	local playerTitle;
	local totalHeight = 0;
	local numSpellRewards = 0;
	local rewardsFrame = QuestInfoFrame.rewardsFrame;
	local hasWarModeBonus = false;

	local spellGetter;
	local questID;
	if ( QuestInfoFrame.questLog ) then
		questID = C_QuestLog.GetSelectedQuest();
		if C_QuestLog.ShouldShowQuestRewards(questID) then
			numQuestRewards = GetNumQuestLogRewards();
			numQuestChoices = GetNumQuestLogChoices(questID, true);
			numQuestCurrencies = GetNumQuestLogRewardCurrencies();
			money = GetQuestLogRewardMoney();
			skillName, skillIcon, skillPoints = GetQuestLogRewardSkillPoints();
			xp = GetQuestLogRewardXP();
			artifactXP, artifactCategory = GetQuestLogRewardArtifactXP();
			honor = GetQuestLogRewardHonor();
			playerTitle = GetQuestLogRewardTitle();
			ProcessQuestLogRewardFactions();
			numSpellRewards = GetNumQuestLogRewardSpells();
			spellGetter = GetQuestLogRewardSpell;
			hasWarModeBonus = C_QuestLog.QuestHasWarModeBonus(questID)
		end
	else
		questID = GetQuestID();
		if ( QuestFrameRewardPanel:IsShown() or C_QuestLog.ShouldShowQuestRewards(questID) ) then
			numQuestRewards = GetNumQuestRewards();
			numQuestChoices = GetNumQuestChoices();
			numQuestCurrencies = GetNumRewardCurrencies();
			money = GetRewardMoney();
			skillName, skillIcon, skillPoints = GetRewardSkillPoints();
			xp = GetRewardXP();
			artifactXP, artifactCategory = GetRewardArtifactXP();
			honor = GetRewardHonor();
			playerTitle = GetRewardTitle();
			numSpellRewards = GetNumRewardSpells();
			spellGetter = GetRewardSpell;
			hasWarModeBonus = C_QuestLog.QuestCanHaveWarModeBonus(questID);
		end
	end

	for rewardSpellIndex = 1, numSpellRewards do
		local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, genericUnlock, spellID = spellGetter(rewardSpellIndex);
		local knownSpell = IsSpellKnownOrOverridesKnown(spellID);

		-- only allow the spell reward if user can learn it
		if ( texture and not knownSpell and (not isBoostSpell or IsCharacterNewlyBoosted()) and (not garrFollowerID or not C_Garrison.IsFollowerCollected(garrFollowerID)) ) then
			numQuestSpellRewards = numQuestSpellRewards + 1;
		end
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestCurrencies;
	if ( totalRewards == 0 and money == 0 and xp == 0 and not playerTitle and numQuestSpellRewards == 0 and artifactXP == 0 and honor == 0 ) then
		rewardsFrame:Hide();
		return nil;
	end

	-- Hide unused rewards
	local rewardButtons = rewardsFrame.RewardButtons;
	for i = totalRewards + 1, #rewardButtons do
		rewardButtons[i]:ClearAllPoints();
		rewardButtons[i]:Hide();
	end

	local questItem, name, texture, quality, isUsable, numItems, itemID;
	local rewardsCount = 0;

	local totalHeight = rewardsFrame.Header:GetHeight();
	local buttonHeight = rewardsFrame.RewardButtons[1]:GetHeight();

	-- [[ anchoring ]]
	local startNewSection = true;
	local useOneElementPerRow = false;		-- default is 2 elements per row
	local function BeginRewardsSection(largeElements)
		startNewSection = true;
		useOneElementPerRow = not not largeElements;
	end

	local lastAnchorElement = rewardsFrame.Header;
	local rightSideElementPlaced = false;
	local function AddRewardElement(rewardElement)
		if not startNewSection and not rightSideElementPlaced and not useOneElementPerRow then
			-- continue on same row
			rewardElement:SetPoint("TOPLEFT", lastAnchorElement, "TOPRIGHT", 1, 0);
			rightSideElementPlaced = true;
		else
			-- make new row
			local spacing = startNewSection and REWARDS_SECTION_OFFSET or REWARDS_ROW_OFFSET;
			rewardElement:SetPoint("TOPLEFT", lastAnchorElement, "BOTTOMLEFT", 0, -spacing);
			local isItemButton = rewardElement.smallItemButton or rewardElement.largeItemButton;
			local addedHeight = isItemButton and buttonHeight or rewardElement:GetHeight();
			totalHeight = totalHeight + addedHeight + spacing;
			lastAnchorElement = rewardElement;
			-- there's no frame on the right side of this row yet
			rightSideElementPlaced = false;
			-- inside a section now
			startNewSection = false;
		end
		rewardElement:Show();
	end

	local function AddHeaderElement(rewardElement)
		local largeElements = true;
		BeginRewardsSection(largeElements);
		AddRewardElement(rewardElement);
	end
	-- [[ anchoring ]]

	rewardsFrame.ArtifactXPFrame:ClearAllPoints();
	if ( artifactXP > 0 ) then
		local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
		rewardsFrame.ArtifactXPFrame.Name:SetText(BreakUpLargeNumbers(artifactXP));
		rewardsFrame.ArtifactXPFrame.Icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark");
		rewardsFrame.ArtifactXPFrame:Show();
		AddRewardElement(rewardsFrame.ArtifactXPFrame);
	else
		rewardsFrame.ArtifactXPFrame:Hide();
	end

	-- Setup choosable rewards
	rewardsFrame.ItemChooseText:ClearAllPoints();
	if ( numQuestChoices > 0 ) then
		rewardsFrame.ItemChooseText:Show();
		if ( numQuestChoices == 1 ) then
			QuestInfoFrame.chooseItems = nil
			rewardsFrame.ItemChooseText:SetText(REWARD_ITEMS_ONLY);
		elseif ( QuestInfoFrame.chooseItems ) then
			rewardsFrame.ItemChooseText:SetText(REWARD_CHOOSE);
		else
			rewardsFrame.ItemChooseText:SetText(REWARD_CHOICES);
		end
		AddHeaderElement(rewardsFrame.ItemChooseText);

		BeginRewardsSection();
		local index;
		local baseIndex = rewardsCount;
		for i = 1, numQuestChoices do
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.questID = questID;
			questItem.type = "choice";
			numItems = 1;

			local lootType = 0; -- LOOT_LIST_ITEM
			if ( QuestInfoFrame.questLog ) then
				lootType = GetQuestLogChoiceInfoLootType(i);
			else
				lootType = GetQuestItemInfoLootType(questItem.type, i);
			end

			if (lootType == 0) then -- LOOT_LIST_ITEM
				QuestInfo_ShowRewardAsItem(questItem, i);
			elseif (lootType == 1) then -- LOOT_LIST_CURRENCY
				QuestInfo_ShowRewardAsCurrency(questItem, i, true);
			end

			AddRewardElement(questItem);
			rewardsCount = rewardsCount + 1;
		end
	else
		rewardsFrame.ItemChooseText:Hide();
	end

	rewardsFrame.spellRewardPool:ReleaseAll();
	rewardsFrame.followerRewardPool:ReleaseAll();
	rewardsFrame.spellHeaderPool:ReleaseAll();
	rewardsFrame.WarModeBonusFrame:Hide();

	-- Setup spell rewards
	if ( numQuestSpellRewards > 0 ) then
		local spellBuckets = {};

		for rewardSpellIndex = 1, numSpellRewards do
			local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, genericUnlock, spellID = spellGetter(rewardSpellIndex);
			local knownSpell = IsSpellKnownOrOverridesKnown(spellID);
			if texture and not knownSpell and (not isBoostSpell or IsCharacterNewlyBoosted()) and (not garrFollowerID or not C_Garrison.IsFollowerCollected(garrFollowerID)) then
				if ( isTradeskillSpell ) then
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL, rewardSpellIndex);
				elseif ( isBoostSpell ) then
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_ABILITY, rewardSpellIndex);
				elseif ( garrFollowerID ) then
					local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID);
					if followerInfo.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0 then
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_COMPANION, rewardSpellIndex);
					else
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_FOLLOWER, rewardSpellIndex);
					end
				elseif ( isSpellLearned ) then
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_SPELL, rewardSpellIndex);
				elseif ( genericUnlock ) then
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_UNLOCK, rewardSpellIndex);
				else
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_AURA, rewardSpellIndex);
				end
			end
		end

		for orderIndex, spellBucketType in ipairs(QUEST_INFO_SPELL_REWARD_ORDERING) do
			local spellBucket = spellBuckets[spellBucketType];
			if spellBucket then
				for i, rewardSpellIndex in ipairs(spellBucket) do
					local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID = spellGetter(rewardSpellIndex);
					-- hideSpellLearnText is a quest flag
					if i == 1 and not hideSpellLearnText then
						local header = rewardsFrame.spellHeaderPool:Acquire();
						header:SetText(QUEST_INFO_SPELL_REWARD_TO_HEADER[spellBucketType]);
						if rewardsFrame.spellHeaderPool.textR and rewardsFrame.spellHeaderPool.textG and rewardsFrame.spellHeaderPool.textB then
							header:SetVertexColor(rewardsFrame.spellHeaderPool.textR, rewardsFrame.spellHeaderPool.textG, rewardsFrame.spellHeaderPool.textB);
						end
						header:Show();
						AddHeaderElement(header);
					end

					if i == 1 then
						local largeElements = not QuestInfoFrame.mapView;
						BeginRewardsSection(largeElements);
					end

					local anchorFrame;
					if garrFollowerID then
						local followerFrame = rewardsFrame.followerRewardPool:Acquire();
						local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID);
						followerFrame.Name:SetText(followerInfo.name);

						local adventureCompanion = followerInfo.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0;
						followerFrame.AdventuresFollowerPortraitFrame:SetShown(adventureCompanion);
						followerFrame.PortraitFrame:SetShown(not adventureCompanion);

						if adventureCompanion then
							followerFrame.AdventuresFollowerPortraitFrame:SetupPortrait(followerInfo)
						else
							followerFrame.PortraitFrame:SetupPortrait(followerInfo);
							followerFrame.Class:SetAtlas(followerInfo.classAtlas);
						end
						followerFrame.ID = garrFollowerID;
						followerFrame:Show();

						anchorFrame = followerFrame;
					else
						local spellRewardFrame = rewardsFrame.spellRewardPool:Acquire();
						spellRewardFrame.Icon:SetTexture(texture);
						spellRewardFrame.Name:SetText(name);
						spellRewardFrame.rewardSpellIndex = rewardSpellIndex;
						spellRewardFrame:Show();

						anchorFrame = spellRewardFrame;
					end
					AddRewardElement(anchorFrame);
				end
			end
		end
	end

	-- Title reward
	if ( playerTitle ) then
		AddHeaderElement(rewardsFrame.PlayerTitleText);

		rewardsFrame.TitleFrame.Name:SetText(playerTitle);
		BeginRewardsSection();
		AddRewardElement(rewardsFrame.TitleFrame);
	else
		rewardsFrame.PlayerTitleText:Hide();
		rewardsFrame.TitleFrame:Hide();
	end

	-- Setup mandatory rewards
	local hasChanceForQuestSessionBonusReward = C_QuestLog.QuestHasQuestSessionBonus(questID);
	if ( numQuestRewards > 0 or numQuestCurrencies > 0 or money > 0 or xp > 0 or honor > 0 or hasChanceForQuestSessionBonusReward ) then
		-- receive text, will either say "You will receive" or "You will also receive"
		local questItemReceiveText = rewardsFrame.ItemReceiveText;
		if ( numQuestChoices > 0 or numQuestSpellRewards > 0 or playerTitle ) then
			questItemReceiveText:SetText(REWARD_ITEMS);
		else
			questItemReceiveText:SetText(REWARD_ITEMS_ONLY);
		end
		AddHeaderElement(questItemReceiveText);

		-- Money and XP
		if ( QuestInfoFrame.mapView ) then
			BeginRewardsSection();
			if ( xp > 0 ) then
				rewardsFrame.XPFrame.Name:SetText(BreakUpLargeNumbers(xp));
				AddRewardElement(rewardsFrame.XPFrame);
			else
				rewardsFrame.XPFrame:Hide();
			end
			if ( money > 0 ) then
				rewardsFrame.MoneyFrame.Name:SetText(GetMoneyString(money));
				AddRewardElement(rewardsFrame.MoneyFrame);
			else
				rewardsFrame.MoneyFrame:Hide();
			end
		else
			-- Money rewards
			if ( money > 0 ) then
				MoneyFrame_Update(rewardsFrame.MoneyFrame, money);
				rewardsFrame.MoneyFrame:Show();
			else
				rewardsFrame.MoneyFrame:Hide();
			end
			-- XP rewards
			if xp > 0 then
				rewardsFrame.XPFrame.ValueText:SetText(BreakUpLargeNumbers(xp));
				AddRewardElement(rewardsFrame.XPFrame);
			else
				rewardsFrame.XPFrame:Hide();
			end
		end
		-- Skill Point rewards
		if skillPoints then
			rewardsFrame.SkillPointFrame.ValueText:SetText(skillPoints);
			rewardsFrame.SkillPointFrame.Icon:SetTexture(skillIcon);
			if (skillName) then
				rewardsFrame.SkillPointFrame.Name:SetFormattedText(BONUS_SKILLPOINTS, skillName);
				rewardsFrame.SkillPointFrame.tooltip = format(BONUS_SKILLPOINTS_TOOLTIP, skillPoints, skillName);
			else
				rewardsFrame.SkillPointFrame.tooltip = nil;
				rewardsFrame.SkillPointFrame.Name:SetText("");
			end
			AddRewardElement(rewardsFrame.SkillPointFrame);
		else
			rewardsFrame.SkillPointFrame:Hide();
		end

		BeginRewardsSection();

		-- Item rewards
		local index;
		local baseIndex = rewardsCount;
		local buttonIndex = 0;
		for i = 1, numQuestRewards, 1 do
			buttonIndex = buttonIndex + 1;
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.questID = questID;
			questItem.type = "reward";
			questItem.objectType = "item";

			QuestInfo_ShowFixedRewardAsItem(questItem, i);

			AddRewardElement(questItem);
			rewardsCount = rewardsCount + 1;
		end

		-- currency
		baseIndex = rewardsCount;
		local foundCurrencies = 0;
		for i = 1, numQuestCurrencies, 1 do
			buttonIndex = buttonIndex + 1;
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.questID = questID;
			questItem.type = "reward";
			questItem.objectType = "currency";

			QuestInfo_ShowRewardAsCurrency(questItem, i, false);

			AddRewardElement(questItem);
			rewardsCount = rewardsCount + 1;
			foundCurrencies = foundCurrencies + 1;
			if (foundCurrencies == numQuestCurrencies) then
				break;
			end
		end

		-- warmode bonus
		if hasWarModeBonus and C_PvP.IsWarModeDesired() then
			rewardsFrame.WarModeBonusFrame.Count:SetFormattedText(PLUS_PERCENT_FORMAT, C_PvP.GetWarModeRewardBonus());
			AddRewardElement(rewardsFrame.WarModeBonusFrame);
		end

        rewardsFrame.HonorFrame:ClearAllPoints();
        if ( honor > 0 ) then
            local icon;
            if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
                icon = "Interface\\Icons\\PVPCurrency-Honor-Horde";
            else
                icon = "Interface\\Icons\\PVPCurrency-Honor-Alliance";
            end
            rewardsFrame.HonorFrame.Count:SetText(BreakUpLargeNumbers(honor));
            rewardsFrame.HonorFrame.Name:SetText(HONOR);
            rewardsFrame.HonorFrame.Icon:SetTexture(icon);
			BeginRewardsSection();
			AddRewardElement(rewardsFrame.HonorFrame);
        else
            rewardsFrame.HonorFrame:Hide();
        end

        -- Bonus reward chance for quest sessions
        if hasChanceForQuestSessionBonusReward then
			rewardsCount = rewardsCount + 1;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, rewardsCount);

			-- TODO: Go lookup the mouseover behavior to see how tooltips are created, probably need to use a specific tooltip:Set* function.
			questItem.type = "reward";
			questItem.objectType = "questSessionBonusReward";

			local QUEST_SESSION_BONUS_REWARD_ITEM_ID = 171305;
			local QUEST_SESSION_BONUS_REWARD_ITEM_COUNT = 1;
			local item = Item:CreateFromItemID(QUEST_SESSION_BONUS_REWARD_ITEM_ID);
			if item then
				item:ContinueOnItemLoad(function()
					questItem.Name:SetText(item:GetItemName());
					SetItemButtonCount(questItem, QUEST_SESSION_BONUS_REWARD_ITEM_COUNT);
					SetItemButtonTexture(questItem, item:GetItemIcon());
					SetItemButtonQuality(questItem, item:GetItemQuality(), QUEST_SESSION_BONUS_REWARD_ITEM_ID);
					SetItemButtonTextureVertexColor(questItem, 1.0, 1.0, 1.0);
					SetItemButtonNameFrameVertexColor(questItem, 1.0, 1.0, 1.0);
				end);
			end

			questItem:SetID(QUEST_SESSION_BONUS_REWARD_ITEM_ID);

			AddHeaderElement(rewardsFrame.QuestSessionBonusReward);
			AddRewardElement(questItem);
        else
        	rewardsFrame.QuestSessionBonusReward:Hide();
        end
	else
		rewardsFrame.ItemReceiveText:Hide();
		rewardsFrame.QuestSessionBonusReward:Hide();
		rewardsFrame.MoneyFrame:Hide();
		rewardsFrame.XPFrame:Hide();
		rewardsFrame.SkillPointFrame:Hide();
        rewardsFrame.HonorFrame:Hide();
	end

	-- deselect item
	QuestInfoFrame.itemChoice = 0;
	if ( rewardsFrame.ItemHighlight ) then
		rewardsFrame.ItemHighlight:Hide();
	end
	rewardsFrame:Show();
	rewardsFrame:SetHeight(totalHeight);
	return rewardsFrame, lastAnchorElement;
end

function QuestInfo_OnHyperlinkEnter(self, link, text, region, left, bottom, width, height)
	local linkType, linkData = ExtractLinkData(link);
	local title, body;
	if linkType == "questReplay" then
		title = QUEST_SESSION_REPLAY_TOOLTIP_TITLE_ENABLED;
		body = QUEST_SESSION_REPLAY_TOOLTIP_BODY_ENABLED;
	elseif linkType == "questDisabled" then
		title = QUEST_SESSION_ON_HOLD_TOOLTIP_TITLE;
		body = QUEST_SESSION_ON_HOLD_TOOLTIP_TEXT;
	end

	if title and body then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, title);
		GameTooltip_AddNormalLine(GameTooltip, body);
		GameTooltip:Show();
	end
end

function QuestInfo_OnHyperlinkLeave(self)
	GameTooltip:Hide();
end

QUEST_TEMPLATE_DETAIL = { questLog = nil, chooseItems = nil, contentWidth = 275,
	canHaveSealMaterial = true, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 10, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowObjectivesHeader, 0, -15,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowSpecialObjectives, 0, -10,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowRewards, 0, -15,
		QuestInfo_ShowSpacer, 0, -20,
	}
}

QUEST_TEMPLATE_LOG = { questLog = true, chooseItems = nil, contentWidth = 285,
	canHaveSealMaterial = true, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 5, -5,
		QuestInfo_ShowType, 0, -5,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowTimer, 0, -10,
		QuestInfo_ShowObjectives, 0, -10,
		QuestInfo_ShowSpecialObjectives, 0, -10,
		QuestInfo_ShowRequiredMoney, 0, 0,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowDescriptionHeader, 0, -20,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_REWARD = { questLog = nil, chooseItems = true, contentWidth = 285,
	canHaveSealMaterial = true, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 10, -10,
		QuestInfo_ShowRewardText, 0, -5,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_MAP_DETAILS = { questLog = true, chooseItems = nil, contentWidth = 244,
	canHaveSealMaterial = true, sealXOffset = 156, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 5, -5,
		QuestInfo_ShowType, 0, -5,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowTimer, 0, -10,
		QuestInfo_ShowObjectives, 0, -10,
		QuestInfo_ShowSpecialObjectives, 0, -10,
		QuestInfo_ShowRequiredMoney, 0, 0,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowDescriptionHeader, 0, -20,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowSpacer, 0, 0,
	}
}

QUEST_TEMPLATE_MAP_REWARDS = { questLog = true, chooseItems = nil, contentWidth = 244,
	elements = {
		QuestInfo_ShowRewards, 8, -42,
	}
}

function QuestInfoRewardItemCodeTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local showCollectionText = false;

	if (self.objectType == "questSessionBonusReward") then
		GameTooltip:SetItemByID(self:GetID());
		GameTooltip_ShowCompareItem(GameTooltip);
	elseif ( QuestInfoFrame.questLog ) then
		if (self.objectType == "item") then
			local questID = nil;
			GameTooltip:SetQuestLogItem(self.type, self:GetID(), questID, showCollectionText);
			GameTooltip_ShowCompareItem(GameTooltip);
		elseif (self.objectType == "currency") then
			GameTooltip:SetQuestLogCurrency(self.type, self:GetID());
		end
	else
		if (self.objectType == "item") then
			GameTooltip:SetQuestItem(self.type, self:GetID(), showCollectionText);
			GameTooltip_ShowCompareItem(GameTooltip);
		elseif (self.objectType == "currency") then
			GameTooltip:SetQuestCurrency(self.type, self:GetID());
		end
	end

	CursorUpdate(self);
	self.UpdateTooltip = QuestInfoRewardItemCodeTemplate_OnEnter;
end

function QuestInfoRewardItemCodeTemplate_OnClick(self, button)
	if ( IsModifiedClick() and self.objectType == "item") then
		if ( QuestInfoFrame.questLog ) then
			HandleModifiedItemClick(GetQuestLogItemLink(self.type, self:GetID()));
		else
			HandleModifiedItemClick(GetQuestItemLink(self.type, self:GetID()));
		end
	else
		if ( QuestInfoFrame.chooseItems ) then
			QuestInfoItem_OnClick(self);
		end
	end
end
