MAX_REPUTATIONS = 10;

function QuestInfoFadingFrame_OnUpdate(self, elapsed)
	if ( self.fading ) then
		self.fadingProgress = self.fadingProgress + (elapsed * QUEST_DESCRIPTION_GRADIENT_CPS);
		PlaySound("WriteQuest");
		if ( not QuestInfoDescriptionText:SetAlphaGradient(self.fadingProgress, QUEST_DESCRIPTION_GRADIENT_LENGTH) ) then
			self.fading = nil;
			if ( QUEST_FADING_DISABLE == "0" ) then
				UIFrameFadeIn(self, QUESTINFO_FADE_IN );
			else
				self:SetAlpha(1);
			end
			QuestInfoFrame.acceptButton:Enable();
		end
	end
end

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

function QuestInfo_Display(template, parentFrame, acceptButton, cancelButton, material)
	local lastFrame = nil;
	local shownFrame = nil;	
	local elementsTable = template.elements;
	
	QuestInfoFrame.questLog = template.questLog;
	QuestInfoFrame.chooseItems = template.chooseItems;
	QuestInfoFrame.tooltip = template.tooltip;	
	QuestInfoFrame.acceptButton = acceptButton;
	QuestInfoFrame.cancelButton = cancelButton;
	
	if ( QuestInfoFrame.material ~= material ) then
		QuestInfoFrame.material = material;	
		local textColor, titleTextColor = GetMaterialTextColors(material);	
		-- headers
		QuestInfoTitleHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoDescriptionHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoObjectivesHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		QuestInfoRewardsHeader:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
		-- other text
		QuestInfoDescriptionText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoObjectivesText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoGroupSize:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoRewardText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		-- reward frame text
		QuestInfoItemChooseText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoItemReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoSpellLearnText:SetTextColor(textColor[1], textColor[2], textColor[3]);		
		QuestInfoHonorFrameReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoArenaPointsFrameReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoTalentFrameReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		QuestInfoXPFrameReceiveText:SetTextColor(textColor[1], textColor[2], textColor[3]);
	end
	
	for i = 1, #elementsTable, 3 do
		shownFrame, bottomShownFrame = elementsTable[i]();
		if ( shownFrame ) then
			shownFrame:SetParent(parentFrame);
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
	return QuestInfoTitleHeader;
end

function QuestInfo_ShowDescriptionText()
	local questDescription;
	if ( QuestInfoFrame.questLog ) then
		questDescription = GetQuestLogQuestText();
	else
		questDescription = GetQuestText();
	end	
	QuestInfoDescriptionText:SetText(questDescription);
	QuestInfoDescriptionText:SetAlphaGradient(0, 0);	
	return QuestInfoDescriptionText;
end

function QuestInfo_ShowObjectives()
	local numObjectives = GetNumQuestLeaderBoards();
	local objective;
	local text, type, finished;
	for i = 1, numObjectives do
		objective = _G["QuestInfoObjective"..i];
		text, type, finished = GetQuestLogLeaderBoard(i);
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
		objective:Show();
	end
	for i = numObjectives + 1, MAX_OBJECTIVES do
		_G["QuestInfoObjective"..i]:Hide();
	end
	if ( objective ) then
		QuestInfoObjectivesFrame:Show();
		return QuestInfoObjectivesFrame, objective;
	else
		QuestInfoObjectivesFrame:Hide();
		return nil;
	end
end

function QuestInfo_DoReputations(anchor)
	local numReputations = GetNumQuestLogRewardFactions();
	local factionName, amount, factionId, isHeader;
	local index = 0;
	for i = 1, numReputations do		
		factionId, amount = GetQuestLogRewardFactionInfo(i);
		factionName, _, _, _, _, _, _, _, isHeader, _, hasRep = GetFactionInfoByID(factionId);
		if ( factionName and ( not isHeader or hasRep ) ) then
			index = index + 1;
			amount = floor(amount / 100);
			if ( amount < 0 ) then
				amount = "|cffff4400"..amount.."|r";
			end
			_G["QuestInfoReputation"..index.."Faction"]:SetText(format(REWARD_REPUTATION, factionName));
			_G["QuestInfoReputation"..index.."Amount"]:SetText(amount);
			_G["QuestInfoReputation"..index]:Show();
		end
	end
	if ( index > 0 ) then
		for i = index + 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation"..i]:Hide();
		end
		QuestInfoReputationsFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
		QuestInfoReputationsFrame:SetHeight(index * 17 + QuestInfoReputationText:GetHeight() + 4);
		QuestInfoReputationsFrame:Show();
		return QuestInfoReputationsFrame;
	else
		QuestInfoReputationsFrame:Hide();
		return anchor;
	end
end

function QuestInfo_ShowTimer()
	local timeLeft = GetQuestLogTimeLeft();
	QuestInfoTimerFrame.timeLeft = timeLeft;
	if ( timeLeft ) then
		QuestInfoTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(timeLeft));
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
	local groupNum;
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
	end
end

function QuestInfo_ShowDescriptionHeader()
	return QuestInfoDescriptionHeader;
end

function QuestInfo_ShowObjectivesHeader()
	return QuestInfoObjectivesHeader;
end

function QuestInfo_ShowObjectivesText()
	local questObjectives;
	if ( QuestInfoFrame.questLog ) then
		_, questObjectives = GetQuestLogQuestText();
	else
		questObjectives = GetObjectiveText();
	end
	QuestInfoObjectivesText:SetText(questObjectives);
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

function QuestInfo_ShowRewards()
	local numQuestRewards;
	local numQuestChoices;
	local numQuestSpellRewards = 0;
	local money;
	local honor;
	local arenaPoints;
	local talents;
	local xp;
	local playerTitle;

	if ( QuestInfoFrame.questLog ) then
		numQuestRewards = GetNumQuestLogRewards();
		numQuestChoices = GetNumQuestLogChoices();
		if ( GetQuestLogRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetQuestLogRewardMoney();
		honor = GetQuestLogRewardHonor();
		arenaPoints = GetQuestLogRewardArenaPoints();
		talents = GetQuestLogRewardTalents();
		xp = GetQuestLogRewardXP();
		playerTitle = GetQuestLogRewardTitle();
		ProcessQuestLogRewardFactions();
	else
		numQuestRewards = GetNumQuestRewards();
		numQuestChoices = GetNumQuestChoices();
		if ( GetRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetRewardMoney();
		honor = GetRewardHonor();
		arenaPoints = GetRewardArenaPoints();
		talents = GetRewardTalents();
		xp = GetRewardXP();
		playerTitle = GetRewardTitle();
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards;	
	if ( totalRewards == 0 and money == 0 and honor == 0 and arenaPoints == 0 and talents == 0 and xp == 0 and not playerTitle ) then
		QuestInfoRewardsFrame:Hide();
		return nil;
	end
		
	-- Hide unused rewards
	for i = totalRewards + 1, MAX_NUM_ITEMS, 1 do
		_G["QuestInfoItem"..i]:Hide();
	end
	-- Hide non-icon rewards (for now)
	QuestInfoMoneyFrame:Hide();
	QuestInfoHonorFrame:Hide();
	QuestInfoArenaPointsFrame:Hide();	
	QuestInfoTalentFrame:Hide();
	QuestInfoXPFrame:Hide();
	QuestInfoPlayerTitleFrame:Hide();	
	
	local questItem, name, texture, isTradeskillSpell, isSpellLearned, quality, isUsable, numItems;
	local rewardsCount = 0;
	local lastFrame = QuestInfoRewardsHeader;
	local questItemReceiveText = QuestInfoItemReceiveText;
	questItemReceiveText:SetText(REWARD_ITEMS_ONLY);
	
	-- Setup choosable rewards
	if ( numQuestChoices > 0 ) then
		local itemChooseText = QuestInfoItemChooseText;
		questItemReceiveText:SetText(REWARD_ITEMS);		
		itemChooseText:Show();
		
		local index;
		local baseIndex = rewardsCount;
		for i = 1, numQuestChoices, 1 do	
			index = i + baseIndex;
			questItem = _G["QuestInfoItem"..index];
			questItem.type = "choice";
			numItems = 1;
			if ( QuestInfoFrame.questLog ) then
				name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
			end
			questItem:SetID(i)
			questItem:Show();
			-- For the tooltip
			questItem.rewardType = "item"
			_G["QuestInfoItem"..index.."Name"]:SetText(name);
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
					questItem:SetPoint("TOPLEFT", "QuestInfoItem"..(index - 2), "BOTTOMLEFT", 0, -2);
					lastFrame = questItem;
				else
					questItem:SetPoint("TOPLEFT", "QuestInfoItem"..(index - 1), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", itemChooseText, "BOTTOMLEFT", -3, -5);
				lastFrame = questItem;
			end
			rewardsCount = rewardsCount + 1;
		end
		if ( QuestInfoFrame.chooseItems ) then
			itemChooseText:SetText(REWARD_CHOOSE);
		else
			itemChooseText:SetText(REWARD_CHOICES);
		end
	else
		QuestInfoItemChooseText:Hide();
	end
	
	-- Setup spell rewards
	if ( numQuestSpellRewards > 0 ) then
		questItemReceiveText:SetText(REWARD_ITEMS);
		local learnSpellText = QuestInfoSpellLearnText;
		learnSpellText:Show();
		learnSpellText:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 3, -5);

		if ( QuestInfoFrame.questLog ) then
			texture, name, isTradeskillSpell, isSpellLearned = GetQuestLogRewardSpell();
		else
			texture, name, isTradeskillSpell, isSpellLearned = GetRewardSpell();
		end
		
		if ( isTradeskillSpell ) then
			learnSpellText:SetText(REWARD_TRADESKILL_SPELL);
		elseif ( not isSpellLearned ) then
			learnSpellText:SetText(REWARD_AURA);
		else
			learnSpellText:SetText(REWARD_SPELL);
		end
		
		rewardsCount = rewardsCount + 1;
		questItem = _G["QuestInfoItem"..rewardsCount];
		questItem:Show();
		-- For the tooltip
		questItem.rewardType = "spell";
		SetItemButtonCount(questItem, 0);
		SetItemButtonTexture(questItem, texture);
		_G["QuestInfoItem"..rewardsCount.."Name"]:SetText(name);
		questItem:SetPoint("TOPLEFT", learnSpellText, "BOTTOMLEFT", -3, -5);
		lastFrame = questItem;
	else
		QuestInfoSpellLearnText:Hide();
	end
	
	-- Setup mandatory rewards
	if ( numQuestRewards > 0 or money > 0 or honor > 0 or arenaPoints > 0 or talents > 0 or xp > 0 or playerTitle ) then
		questItemReceiveText:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 3, -5);
		questItemReceiveText:Show();		
		lastFrame = questItemReceiveText;
		-- Money rewards
		if ( money > 0 ) then
			MoneyFrame_Update("QuestInfoMoneyFrame", money);
			QuestInfoMoneyFrame:Show();
		end
		-- XP rewards
		lastFrame = QuestInfo_ToggleRewardElement("QuestInfoXPFrame", xp, "Points", lastFrame);		
		-- Honor rewards
		lastFrame = QuestInfo_ToggleRewardElement("QuestInfoHonorFrame", honor, "Points", lastFrame);
		-- Arena point rewards
		lastFrame = QuestInfo_ToggleRewardElement("QuestInfoArenaPointsFrame", arenaPoints, "Points", lastFrame);		
		-- Talent rewards
		lastFrame = QuestInfo_ToggleRewardElement("QuestInfoTalentFrame", talents, "Points", lastFrame);
		-- Title reward
		lastFrame = QuestInfo_ToggleRewardElement("QuestInfoPlayerTitleFrame", playerTitle, "Title", lastFrame);
		-- Item rewards
		local index;
		local baseIndex = rewardsCount;
		for i = 1, numQuestRewards, 1 do
			index = i + baseIndex;
			questItem = _G["QuestInfoItem"..index];
			questItem.type = "reward";
			numItems = 1;
			if ( QuestInfoFrame.questLog ) then
				name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
			end
			questItem:SetID(i)
			questItem:Show();
			-- For the tooltip
			questItem.rewardType = "item";
			_G["QuestInfoItem"..index.."Name"]:SetText(name);
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
					questItem:SetPoint("TOPLEFT", "QuestInfoItem"..(index - 2), "BOTTOMLEFT", 0, -2);
					lastFrame = questItem;
				else
					questItem:SetPoint("TOPLEFT", "QuestInfoItem"..(index - 1), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", -3, -5);
				lastFrame = questItem;
			end
			rewardsCount = rewardsCount + 1;
		end
	else	
		questItemReceiveText:Hide();
	end

	-- deselect item
	QuestInfoFrame.itemChoice = 0;
	QuestInfoItemHighlight:Hide();
	
	QuestInfoRewardsFrame:Show();
	return QuestInfoRewardsFrame, lastFrame;
end

function QuestInfo_ShowFadingFrame()
		QuestInfoFadingFrame:SetAlpha(0);		
		QuestInfoFrame.acceptButton:Disable();
		QuestInfoFadingFrame.fading = 1;
		QuestInfoFadingFrame.fadingProgress = 0;
		QuestInfoDescriptionText:SetAlphaGradient(0, QUEST_DESCRIPTION_GRADIENT_LENGTH);
		if ( QUEST_FADING_DISABLE == "1" ) then
			QuestInfoFadingFrame.fadingProgress = 1024;
		end
	return QuestInfoFadingFrame;
end

function QuestInfo_ToggleRewardElement(frameName, value, stringName, anchor)
	local frame = _G[frameName];
	if ( value and value ~= 0 ) then
		frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
		if ( stringName ) then
			_G[frameName..stringName]:SetText(value);
		end
		frame:Show();
		return frame;
	else
		return anchor;
	end
end

QUEST_TEMPLATE_DETAIL1 = { questLog = nil, chooseItems = nil, tooltip = nil,
	elements = {
		QuestInfo_ShowTitle, 5, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowFadingFrame, 0, -5
	}
}

QUEST_TEMPLATE_DETAIL2 = { questLog = nil, chooseItems = nil, tooltip = "GameTooltip", 
	elements = {
		QuestInfo_ShowObjectivesHeader, 0, -10,	
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowRewards, 0, -15,
		QuestInfo_ShowSpacer, 0, -15
	}
}

QUEST_TEMPLATE_LOG = { questLog = true, chooseItems = nil, tooltip = "GameTooltip",
	elements = {
		QuestInfo_ShowTitle, 5, -5,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowTimer, 0, -10,
		QuestInfo_ShowObjectives, 0, -10,
		QuestInfo_ShowRequiredMoney, 0, 0,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowDescriptionHeader, 0, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_REWARD = { questLog = nil, chooseItems = true, tooltip = "GameTooltip",
	elements = {
		QuestInfo_ShowTitle, 5, -10,
		QuestInfo_ShowRewardText, 0, -5,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_MAP1 = { questLog = true, chooseItems = nil, fadingText = nil, tooltip = nil,
	elements = {
		QuestInfo_ShowTitle, 30, -10,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowDescriptionHeader, 0, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSpacer, 0, -10
	}
}

QUEST_TEMPLATE_MAP2 = { questLog = true, chooseItems = nil, fadingText = nil, tooltip = "WorldMapTooltip",
	elements = {
		QuestInfo_ShowRewards, 30, -10,
		QuestInfo_ShowAnchor, 5, 0,
	}
}