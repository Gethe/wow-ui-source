local REWARDS_SECTION_OFFSET = 5;		-- vertical distance between sections

local SEAL_QUESTS = {
	[40519] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_VARIAN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},
	[43926] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_VOLJIN.."|r", sealAtlas = "Quest-Horde-WaxSeal"},
	[47221] = { bgAtlas = "QuestBG-TheHandofFate", },
	[47835] = { bgAtlas = "QuestBG-TheHandofFate", },
	[49929] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal" },
	[49930] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal" },
	[50476] = { bgAtlas = "QuestBG-Horde", sealAtlas = "Quest-Horde-WaxSeal" },
	-- BfA start quests
	[46727] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal" },
	[50668] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal"},

	[51795] = { bgAtlas = "QuestBG-Alliance" },
	[52058] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},

	[51796] = { bgAtlas = "QuestBG-Horde" },

	[53372] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal"},
	[53370] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},
};

local EXCEPTION_QUESTS = {
	[53029] = true,
	[53026] = true,
	[51211] = true,
	[52428] = true,
};

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
		local questID;
		if ( template.questLog ) then
			questID = questFrame.questID;
		else
			questID = GetQuestID();
		end
		local sealQuestInfo = SEAL_QUESTS[questID];
		local sealMaterialBG = questFrame.SealMaterialBG;
		sealMaterialBG:Hide();
		QuestInfoSealFrame.sealInfo = nil;
		if ( sealQuestInfo ) then
			sealMaterialBG:SetAtlas(sealQuestInfo.bgAtlas);
			sealMaterialBG:Show();

			if sealQuestInfo.text or sealQuestInfo.sealAtlas then
				QuestInfoSealFrame.sealInfo = sealQuestInfo;
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
		QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);

		QuestInfoRewardsFrame.spellHeaderPool.textR, QuestInfoRewardsFrame.spellHeaderPool.textG, QuestInfoRewardsFrame.spellHeaderPool.textB = textColor[1], textColor[2], textColor[3];
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

function QuestInfo_ShowTitle()
	local questTitle;
	if ( QuestInfoFrame.questLog ) then
		questTitle = GetQuestLogTitle(GetQuestLogSelection());
		if ( not questTitle ) then
			questTitle = "";
		end
		if ( IsCurrentQuestFailed() ) then
			questTitle = questTitle.." - ("..FAILED..")";
		end
	else
		questTitle = GetTitleText();
	end
	QuestInfoTitleHeader:SetText(questTitle);
	QuestInfoTitleHeader:SetWidth(ACTIVE_TEMPLATE.contentWidth);
	return QuestInfoTitleHeader;
end

function QuestInfo_ShowType()
	local questID = select(8, GetQuestLogTitle(GetQuestLogSelection()));
	local questTypeMarkup = QuestUtils_GetQuestTypeTextureMarkupString(questID);
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
	QuestInfoDescriptionText:SetWidth(270); -- Hardcoding this value since it's different for 1.12.
	return QuestInfoDescriptionText;
end

function QuestInfo_ShowObjectives()
	local numObjectives = GetNumQuestLeaderBoards();
	local objective;
	local text, type, finished;
	local objectivesTable = QuestInfoObjectivesFrame.Objectives;
	local numVisibleObjectives = 0;
	for i = 1, numObjectives do
		text, type, finished = GetQuestLogLeaderBoard(i);
		if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
			numVisibleObjectives = numVisibleObjectives+1;
			objective = objectivesTable[numVisibleObjectives];
			if ( not objective ) then
				objective = QuestInfoObjectivesFrame:CreateFontString("QuestInfoObjective"..numVisibleObjectives, "BACKGROUND", "QuestFontNormalSmall");
				objective:SetPoint("TOPLEFT", objectivesTable[numVisibleObjectives - 1], "BOTTOMLEFT", 0, -2);
				objective:SetJustifyH("LEFT");
				objective:SetWidth(285);
				objectivesTable[numVisibleObjectives] = objective;
			end
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
	local requiredMoney = GetQuestLogRequiredMoney();
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
	--[[local groupNum;
	if ( QuestInfoFrame.questLog ) then
		groupNum = GetQuestLogGroupNum();
	else
		groupNum = GetSuggestedGroupNum();
	end
	if ( groupNum > 0 ) then
		local suggestedGroupString = format(QUEST_SUGGESTED_GROUP_NUM, groupNum);
		QuestInfoGroupSize:SetText(suggestedGroupString);
		QuestInfoGroupSize:Show();
		return QuestInfoGroupSize;
	else
		QuestInfoGroupSize:Hide();
		return nil;
	end]]
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
	QuestInfoObjectivesText:SetWidth(270); -- Hardcoding this value since it's different for 1.12.
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
	-- Temporary anchor to ensure :IsTruncated will work for the seal text.
	frame:SetPoint("CENTER", parentFrame or UIParent);
	if frame.sealInfo then
		if frame.sealInfo.text then
			frame.Text:SetText(frame.sealInfo.text);
			frame.Text:Show();
		else
			frame.Text:Hide();
		end

		if frame.sealInfo.sealAtlas then
			frame.Texture:SetAtlas(frame.sealInfo.sealAtlas, true);
			frame.Texture:SetPoint("TOPLEFT", ACTIVE_TEMPLATE.sealXOffset, ACTIVE_TEMPLATE.sealYOffset);
			frame.Texture:Show();
		else
			frame.Texture:Hide();
		end
		frame:Show();
		return frame;
	else
		frame:Hide();
		return nil;
	end
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

QUEST_INFO_SPELL_REWARD_ORDERING = {
	QUEST_SPELL_REWARD_TYPE_FOLLOWER,
	QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL,
	QUEST_SPELL_REWARD_TYPE_ABILITY,
	QUEST_SPELL_REWARD_TYPE_AURA,
	QUEST_SPELL_REWARD_TYPE_SPELL,
	QUEST_SPELL_REWARD_TYPE_UNLOCK,
};

QUEST_INFO_SPELL_REWARD_TO_HEADER = {
	[QUEST_SPELL_REWARD_TYPE_FOLLOWER] = REWARD_FOLLOWER,
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

	local spellGetter;
	if ( QuestInfoFrame.questLog ) then
		local questID = select(8, GetQuestLogTitle(GetQuestLogSelection()));
		if C_QuestLog.ShouldShowQuestRewards(questID) then
		numQuestRewards = GetNumQuestLogRewards();
		numQuestChoices = GetNumQuestLogChoices();
		numQuestCurrencies = GetNumQuestLogRewardCurrencies();
		money = GetQuestLogRewardMoney();
		skillName, skillIcon, skillPoints = GetQuestLogRewardSkillPoints();
		-- Don't show XP rewards in Classic.
		xp = 0; -- GetQuestLogRewardXP();
		artifactXP, artifactCategory = GetQuestLogRewardArtifactXP();
		honor = GetQuestLogRewardHonor();
		playerTitle = GetQuestLogRewardTitle();
		ProcessQuestLogRewardFactions();
		numSpellRewards = GetNumQuestLogRewardSpells();
		spellGetter = GetQuestLogRewardSpell;
		end
	else
		numQuestRewards = GetNumQuestRewards();
		numQuestChoices = GetNumQuestChoices();
		numQuestCurrencies = 0;--GetNumRewardCurrencies();
		money = GetRewardMoney();
		skillName, skillIcon, skillPoints = 0, 0, 0;--GetRewardSkillPoints();
		-- Don't show XP rewards in Classic.
		xp = 0; --GetRewardXP();
		artifactXP, artifactCategory = 0, nil;--GetRewardArtifactXP();
		honor = 0;--GetRewardHonor();
		playerTitle = nil;--GetRewardTitle();
		numSpellRewards = GetNumRewardSpells();
		spellGetter = GetRewardSpell;
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
	if ( totalRewards == 0 and money == 0 and xp == 0 and not playerTitle and numQuestSpellRewards == 0 and artifactXP == 0 ) then
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
	local lastFrame = rewardsFrame.Header;

	local totalHeight = rewardsFrame.Header:GetHeight();
	local buttonHeight = rewardsFrame.RewardButtons[1]:GetHeight();

	rewardsFrame.ArtifactXPFrame:ClearAllPoints();
	if ( artifactXP > 0 ) then
		local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
		rewardsFrame.ArtifactXPFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
		rewardsFrame.ArtifactXPFrame.Name:SetText(BreakUpLargeNumbers(artifactXP));
		rewardsFrame.ArtifactXPFrame.Icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark");
		rewardsFrame.ArtifactXPFrame:Show();

		lastFrame = rewardsFrame.ArtifactXPFrame;
		totalHeight = totalHeight + rewardsFrame.ArtifactXPFrame:GetHeight() + REWARDS_SECTION_OFFSET;
	else
		rewardsFrame.ArtifactXPFrame:Hide();
	end

	-- Setup choosable rewards
	rewardsFrame.ItemChooseText:ClearAllPoints();
	if ( numQuestChoices > 0 ) then
		rewardsFrame.ItemChooseText:Show();
		rewardsFrame.ItemChooseText:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);

		local index;
		local baseIndex = rewardsCount;
		for i = 1, numQuestChoices do
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.type = "choice";
			questItem.objectType = "item";
			numItems = 1;
			if ( QuestInfoFrame.questLog ) then
				name, texture, numItems, quality, isUsable, itemID = GetQuestLogChoiceInfo(i);
				SetItemButtonQuality(questItem, quality, itemID);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
				SetItemButtonQuality(questItem, quality, GetQuestItemLink(questItem.type, i));
			end
			questItem:SetID(i)
			questItem:Show();
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
			if ( i > 1 ) then
				if ( mod(i,2) == 1 ) then
					questItem:SetPoint("TOPLEFT", rewardButtons[index - 2], "BOTTOMLEFT", 0, -2);
					lastFrame = questItem;
					totalHeight = totalHeight + buttonHeight + 2;
				else
					questItem:SetPoint("TOPLEFT", rewardButtons[index - 1], "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", rewardsFrame.ItemChooseText, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
				lastFrame = questItem;
				totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
			end
			rewardsCount = rewardsCount + 1;
		end
		if ( numQuestChoices == 1 ) then
			QuestInfoFrame.chooseItems = nil
			rewardsFrame.ItemChooseText:SetText(REWARD_ITEMS_ONLY);
		elseif ( QuestInfoFrame.chooseItems ) then
			rewardsFrame.ItemChooseText:SetText(REWARD_CHOOSE);
		else
			rewardsFrame.ItemChooseText:SetText(REWARD_CHOICES);
		end
		totalHeight = totalHeight + rewardsFrame.ItemChooseText:GetHeight() + REWARDS_SECTION_OFFSET;
	else
		rewardsFrame.ItemChooseText:Hide();
	end

	rewardsFrame.spellRewardPool:ReleaseAll();
	rewardsFrame.followerRewardPool:ReleaseAll();
	rewardsFrame.spellHeaderPool:ReleaseAll();

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
					AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_FOLLOWER, rewardSpellIndex);
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
						header:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
						if rewardsFrame.spellHeaderPool.textR and rewardsFrame.spellHeaderPool.textG and rewardsFrame.spellHeaderPool.textB then
							header:SetVertexColor(rewardsFrame.spellHeaderPool.textR, rewardsFrame.spellHeaderPool.textG, rewardsFrame.spellHeaderPool.textB);
						end
						header:Show();

						totalHeight = totalHeight + header:GetHeight() + REWARDS_SECTION_OFFSET;
						lastFrame = header;
					end

					local anchorFrame;
					if garrFollowerID then
						local followerFrame = rewardsFrame.followerRewardPool:Acquire();
						local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID);
						followerFrame.Name:SetText(followerInfo.name);
						followerFrame.Class:SetAtlas(followerInfo.classAtlas);
						followerFrame.PortraitFrame:SetupPortrait(followerInfo);
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

					anchorFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
					totalHeight = totalHeight + anchorFrame:GetHeight() + REWARDS_SECTION_OFFSET;

					lastFrame = anchorFrame;
				end
			end
		end
	end

	-- Title reward
	if ( playerTitle ) then
		rewardsFrame.PlayerTitleText:Show();
		rewardsFrame.PlayerTitleText:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
		totalHeight = totalHeight +  rewardsFrame.PlayerTitleText:GetHeight() + REWARDS_SECTION_OFFSET;
		rewardsFrame.TitleFrame:SetPoint("TOPLEFT", rewardsFrame.PlayerTitleText, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
		rewardsFrame.TitleFrame.Name:SetText(playerTitle);
		rewardsFrame.TitleFrame:Show();
		lastFrame = rewardsFrame.TitleFrame;
		totalHeight = totalHeight +  rewardsFrame.TitleFrame:GetHeight() + REWARDS_SECTION_OFFSET;
	else
		rewardsFrame.PlayerTitleText:Hide();
		rewardsFrame.TitleFrame:Hide();
	end

	-- Setup mandatory rewards
	if ( numQuestRewards > 0 or numQuestCurrencies > 0 or money > 0 or xp > 0 ) then
		-- receive text, will either say "You will receive" or "You will also receive"
		local questItemReceiveText = rewardsFrame.ItemReceiveText;
		if ( numQuestChoices > 0 or numQuestSpellRewards > 0 or playerTitle ) then
			questItemReceiveText:SetText(REWARD_ITEMS);
		else
			questItemReceiveText:SetText(REWARD_ITEMS_ONLY);
		end
		questItemReceiveText:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
		questItemReceiveText:Show();
		totalHeight = totalHeight + questItemReceiveText:GetHeight() + REWARDS_SECTION_OFFSET;
		lastFrame = questItemReceiveText;

		-- Money and XP
		if ( QuestInfoFrame.mapView ) then
			if ( xp > 0 ) then
				rewardsFrame.XPFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
				rewardsFrame.XPFrame.Name:SetText(BreakUpLargeNumbers(xp));
				rewardsFrame.XPFrame:Show();
				lastFrame = rewardsFrame.XPFrame;
				totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
			else
				rewardsFrame.XPFrame:Hide();
			end
			if ( money > 0 ) then
				if ( xp > 0 ) then
					rewardsFrame.MoneyFrame:SetPoint("TOPLEFT", rewardsFrame.XPFrame, "TOPRIGHT", 2, 0);
				else
					rewardsFrame.MoneyFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
					lastFrame = rewardsFrame.MoneyFrame;
					totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
				end
				rewardsFrame.MoneyFrame.Name:SetText(GetMoneyString(money));
				rewardsFrame.MoneyFrame:Show();
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
			if ( QuestInfo_ToggleRewardElement(rewardsFrame.XPFrame, BreakUpLargeNumbers(xp), lastFrame) ) then
				lastFrame = rewardsFrame.XPFrame;
				totalHeight = totalHeight + rewardsFrame.XPFrame:GetHeight() + REWARDS_SECTION_OFFSET;
			end
		end
		-- Skill Point rewards
		if ( QuestInfo_ToggleRewardElement(rewardsFrame.SkillPointFrame, skillPoints, lastFrame) ) then
			lastFrame = rewardsFrame.SkillPointFrame;
			rewardsFrame.SkillPointFrame.Icon:SetTexture(skillIcon);
			if (skillName) then
				rewardsFrame.SkillPointFrame.Name:SetFormattedText(BONUS_SKILLPOINTS, skillName);
				rewardsFrame.SkillPointFrame.tooltip = format(BONUS_SKILLPOINTS_TOOLTIP, skillPoints, skillName);
			else
				rewardsFrame.SkillPointFrame.tooltip = nil;
				rewardsFrame.SkillPointFrame.Name:SetText("");
			end
			totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
		end
		-- Item rewards
		local index;
		local baseIndex = rewardsCount;
		local buttonIndex = 0;
		for i = 1, numQuestRewards, 1 do
			buttonIndex = buttonIndex + 1;
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.type = "reward";
			questItem.objectType = "item";
			if ( QuestInfoFrame.questLog ) then
				name, texture, numItems, quality, isUsable, itemID = GetQuestLogRewardInfo(i);
				SetItemButtonQuality(questItem, quality, itemID);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
				SetItemButtonQuality(questItem, quality, GetQuestItemLink(questItem.type, i));
			end
			questItem:SetID(i)
			questItem:Show();
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

			if ( buttonIndex > 1 ) then
				if ( mod(buttonIndex,2) == 1 ) then
					questItem:SetPoint("TOPLEFT", rewardButtons[index - 2], "BOTTOMLEFT", 0, -2);
					lastFrame = questItem;
					totalHeight = totalHeight + buttonHeight + 2;
				else
					questItem:SetPoint("TOPLEFT", rewardButtons[index - 1], "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
				lastFrame = questItem;
				totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
			end
			rewardsCount = rewardsCount + 1;
		end

		-- currency
		baseIndex = rewardsCount;
		local foundCurrencies = 0;
		buttonIndex = buttonIndex + 1;
		--[[for i = 1, GetMaxRewardCurrencies(), 1 do
			index = i + baseIndex;
			questItem = QuestInfo_GetRewardButton(rewardsFrame, index);
			questItem.type = "reward";
			questItem.objectType = "currency";
			local currencyID;
			if ( QuestInfoFrame.questLog ) then
				name, texture, numItems, currencyID, quality = GetQuestLogRewardCurrencyInfo(i);
			else
				name, texture, numItems, quality = GetQuestCurrencyInfo(questItem.type, i);
				currencyID = GetQuestCurrencyID(questItem.type, i);
			end
			if (name and texture and numItems) then
				name, texture, numItems, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality); 
				questItem:SetID(i)
				questItem:Show();
				-- For the tooltip
				questItem.Name:SetText(name);
				SetItemButtonCount(questItem, numItems, true);
				local currencyColor = GetColorForCurrencyReward(currencyID, numItems);
				questItem.Count:SetTextColor(currencyColor:GetRGB());
				SetItemButtonTexture(questItem, texture);
				SetItemButtonTextureVertexColor(questItem, 1.0, 1.0, 1.0);
				SetItemButtonNameFrameVertexColor(questItem, 1.0, 1.0, 1.0);
				SetItemButtonQuality(questItem, quality, currencyID);

				if ( buttonIndex > 1 ) then
					if ( mod(buttonIndex,2) == 1 ) then
						questItem:SetPoint("TOPLEFT", rewardButtons[index - 2], "BOTTOMLEFT", 0, -2);
						lastFrame = questItem;
						totalHeight = totalHeight + buttonHeight + 2;
					else
						questItem:SetPoint("TOPLEFT", rewardButtons[index - 1], "TOPRIGHT", 1, 0);
					end
				else
					questItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
					lastFrame = questItem;
					totalHeight = totalHeight + buttonHeight + REWARDS_SECTION_OFFSET;
				end
				rewardsCount = rewardsCount + 1;
				foundCurrencies = foundCurrencies + 1;
				buttonIndex = buttonIndex + 1;
				if (foundCurrencies == numQuestCurrencies) then
					break;
				end
			end
		end]]

        rewardsFrame.HonorFrame:ClearAllPoints();
        if ( honor > 0 ) then
            local icon;
            if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
                icon = "Interface\\Icons\\PVPCurrency-Honor-Horde";
            else
                icon = "Interface\\Icons\\PVPCurrency-Honor-Alliance";
            end

            rewardsFrame.HonorFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
            rewardsFrame.HonorFrame.Count:SetText(BreakUpLargeNumbers(honor));
            rewardsFrame.HonorFrame.Name:SetText(HONOR);
            rewardsFrame.HonorFrame.Icon:SetTexture(icon);
            rewardsFrame.HonorFrame:Show();

            lastFrame = rewardsFrame.HonorFrame;
            totalHeight = totalHeight + rewardsFrame.HonorFrame:GetHeight() + REWARDS_SECTION_OFFSET;
        else
            rewardsFrame.HonorFrame:Hide();
        end
	else
		rewardsFrame.ItemReceiveText:Hide();
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
	return rewardsFrame, lastFrame;
end

function QuestInfo_ToggleRewardElement(frame, value, anchor)
	if ( value and tonumber(value) ~= 0 ) then
		frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -REWARDS_SECTION_OFFSET);
		frame.ValueText:SetText(value);
		frame:Show();
		return true;
	else
		frame:Hide();
	end
end

--[[
	AlphaDependentText
	When instant quest text is disabled, some parts of quest text don't show up until the quest text has finished scrolling.
	These functions control those elements.
]]

function QuestInfo_ShowAlphaDependentText(parent)
	if (not parent.alphaDependentText) then
		return;
	end
	for index,frame in ipairs(parent.alphaDependentText) do
		frame:SetAlpha(1);
	end
end

function QuestInfo_HideAlphaDependentText(parent)
	if (not parent.alphaDependentText) then
		return;
	end
	for index,frame in ipairs(parent.alphaDependentText) do
		frame:SetAlpha(0);
	end
end

function QuestInfo_FadeInAlphaDependentText(parent, fadeTime)
	if (not parent.alphaDependentText) then
		return;
	end
	for index,frame in ipairs(parent.alphaDependentText) do
		if (frame:IsShown()) then
			UIFrameFadeIn(frame, fadeTime );
		end
	end
end

QUEST_TEMPLATE_DETAIL = { questLog = nil, chooseItems = nil, contentWidth = 275,
	canHaveSealMaterial = true, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 5, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowObjectivesHeader, 0, -15,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowSpecialObjectives, 0, -10,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowRewards, 0, -15,
		QuestInfo_ShowSpacer, 0, -15,
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
		QuestInfo_ShowDescriptionHeader, 0, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_REWARD = { questLog = nil, chooseItems = true, contentWidth = 285,
	canHaveSealMaterial = true, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 5, -10,
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
		QuestInfo_ShowDescriptionHeader, 0, -10,
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
	if ( QuestInfoFrame.questLog ) then
		if (self.objectType == "item") then
			GameTooltip:SetQuestLogItem(self.type, self:GetID());
			GameTooltip_ShowCompareItem(GameTooltip);
		elseif (self.objectType == "currency") then
			GameTooltip:SetQuestLogCurrency(self.type, self:GetID());
		end
	else
		if (self.objectType == "item") then
			GameTooltip:SetQuestItem(self.type, self:GetID());
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