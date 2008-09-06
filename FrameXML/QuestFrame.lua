MAX_NUM_QUESTS = 32;
MAX_NUM_ITEMS = 10;
MAX_REQUIRED_ITEMS = 6;
QUEST_DESCRIPTION_GRADIENT_LENGTH = 30;
QUEST_DESCRIPTION_GRADIENT_CPS = 70;
QUESTINFO_FADE_IN = 0.5;

function QuestFrame_OnLoad(self)
	self:RegisterEvent("QUEST_GREETING");
	self:RegisterEvent("QUEST_DETAIL");
	self:RegisterEvent("QUEST_PROGRESS");
	self:RegisterEvent("QUEST_COMPLETE");
	self:RegisterEvent("QUEST_FINISHED");
	self:RegisterEvent("QUEST_ITEM_UPDATE");
end

function QuestFrame_OnEvent(self, event, ...)
	if ( event == "QUEST_FINISHED" ) then
		HideUIPanel(QuestFrame);
		return;
	end
	if ( (event == "QUEST_ITEM_UPDATE") and not QuestFrame:IsShown() ) then
		return;
	end

	QuestFrame_SetPortrait();
	ShowUIPanel(QuestFrame);
	if ( not QuestFrame:IsShown() ) then
		CloseQuest();
		return;
	end

	if ( event == "QUEST_GREETING" ) then
		QuestFrameGreetingPanel:Hide();
		QuestFrameGreetingPanel:Show();
	elseif ( event == "QUEST_DETAIL" ) then
		QuestFrameDetailPanel:Hide();
		QuestFrameDetailPanel:Show();
	elseif ( event == "QUEST_PROGRESS" ) then
		QuestFrameProgressPanel:Hide();
		QuestFrameProgressPanel:Show();
	elseif ( event == "QUEST_COMPLETE" ) then
		QuestFrameRewardPanel:Hide();
		QuestFrameRewardPanel:Show();
	elseif ( event == "QUEST_ITEM_UPDATE" ) then
		if ( QuestFrameDetailPanel:IsShown() ) then
			QuestFrameItems_Update("QuestDetail");
			QuestDetailScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameProgressPanel:IsShown() ) then
			QuestFrameProgressItems_Update()
			QuestProgressScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameRewardPanel:IsShown() ) then
			QuestFrameItems_Update("QuestReward");
			QuestRewardScrollFrameScrollBar:SetValue(0);
		end
	end
end

function QuestFrame_SetPortrait()
	QuestFrameNpcNameText:SetText(UnitName("questnpc"));
	if ( UnitExists("questnpc") ) then
		SetPortraitTexture(QuestFramePortrait, "questnpc");
	else
		QuestFramePortrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	end
	
end

function QuestFrameRewardPanel_OnShow()
	QuestFrameDetailPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	QuestFrameProgressPanel:Hide();
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameRewardPanel, material);
	QuestRewardTitleText:SetText(GetTitleText());
	QuestFrame_SetTitleTextColor(QuestRewardTitleText,material);
	QuestRewardText:SetText(GetRewardText());
	QuestFrame_SetTextColor(QuestRewardText, material);
	QuestFrameItems_Update("QuestReward");
	QuestRewardScrollFrameScrollBar:SetValue(0);
	if ( QUEST_FADING_DISABLE == "0" ) then
		QuestRewardScrollChildFrame:SetAlpha(0);
		UIFrameFadeIn(QuestRewardScrollChildFrame, QUESTINFO_FADE_IN);
	end
end

function QuestRewardCancelButton_OnClick()
	DeclineQuest();
	PlaySound("igQuestCancel");
end

function QuestRewardCompleteButton_OnClick()
	if ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
		QuestChooseRewardError();
	else
		local money = GetQuestMoneyToGet();
		if ( money and money > 0 ) then
			QuestFrame.dialog = StaticPopup_Show("CONFIRM_COMPLETE_EXPENSIVE_QUEST");
			if ( QuestFrame.dialog ) then
				MoneyFrame_Update(QuestFrame.dialog:GetName().."MoneyFrame", money);
			end
		else
			GetQuestReward(QuestFrameRewardPanel.itemChoice);
		end
	end
end

function QuestProgressCompleteButton_OnClick()
	CompleteQuest();
	--PlaySound("igQuestListComplete");
end

function QuestGoodbyeButton_OnClick()
	DeclineQuest();
	PlaySound("igQuestCancel");
end

function QuestRewardItem_OnClick(self)
	if ( self.type == "choice" ) then
		QuestRewardItemHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -8, 7);
		QuestRewardItemHighlight:Show();
		QuestFrameRewardPanel.itemChoice = self:GetID();
	end
end

function QuestFrameProgressPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameDetailPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameProgressPanel, material);
	QuestProgressTitleText:SetText(GetTitleText());
	QuestFrame_SetTitleTextColor(QuestProgressTitleText, material);
	QuestProgressText:SetText(GetProgressText());
	QuestFrame_SetTextColor(QuestProgressText, material);
	if ( IsQuestCompletable() ) then
		QuestFrameCompleteButton:Enable();
	else
		QuestFrameCompleteButton:Disable();
	end
	QuestFrameProgressItems_Update();
	if ( QUEST_FADING_DISABLE == "0" ) then
		QuestProgressScrollChildFrame:SetAlpha(0);
		UIFrameFadeIn(QuestProgressScrollChildFrame, QUESTINFO_FADE_IN);
	end
end

function QuestFrameProgressItems_Update()
	local numRequiredItems = GetNumQuestItems();
	local questItemName = "QuestProgressItem";
	if ( numRequiredItems > 0 or GetQuestMoneyToGet() > 0 ) then
		QuestProgressRequiredItemsText:Show();
		
		-- If there's money required then anchor and display it
		if ( GetQuestMoneyToGet() > 0 ) then
			MoneyFrame_Update("QuestProgressRequiredMoneyFrame", GetQuestMoneyToGet());
			
			if ( GetQuestMoneyToGet() > GetMoney() ) then
				-- Not enough money
				QuestProgressRequiredMoneyText:SetTextColor(0, 0, 0);
				SetMoneyFrameColor("QuestProgressRequiredMoneyFrame", "red");
			else
				QuestProgressRequiredMoneyText:SetTextColor(0.2, 0.2, 0.2);
				SetMoneyFrameColor("QuestProgressRequiredMoneyFrame", "white");
			end
			QuestProgressRequiredMoneyText:Show();
			QuestProgressRequiredMoneyFrame:Show();

			-- Reanchor required item
			getglobal(questItemName..1):SetPoint("TOPLEFT", "QuestProgressRequiredMoneyText", "BOTTOMLEFT", 0, -10);
		else
			QuestProgressRequiredMoneyText:Hide();
			QuestProgressRequiredMoneyFrame:Hide();

			getglobal(questItemName..1):SetPoint("TOPLEFT", "QuestProgressRequiredItemsText", "BOTTOMLEFT", -3, -5);
		end


		
		for i=1, numRequiredItems, 1 do	
			local requiredItem = getglobal(questItemName..i);
			requiredItem.type = "required";
			local name, texture, numItems = GetQuestItemInfo(requiredItem.type, i);
			SetItemButtonCount(requiredItem, numItems);
			SetItemButtonTexture(requiredItem, texture);
			requiredItem:Show();
			getglobal(questItemName..i.."Name"):SetText(name);
			
		end
	else
		QuestProgressRequiredMoneyText:Hide();
		QuestProgressRequiredMoneyFrame:Hide();
		QuestProgressRequiredItemsText:Hide();
	end
	for i=numRequiredItems + 1, MAX_REQUIRED_ITEMS, 1 do
		getglobal(questItemName..i):Hide();
	end
	QuestProgressScrollFrameScrollBar:SetValue(0);
end

function QuestFrameGreetingPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameDetailPanel:Hide();
	if ( QUEST_FADING_DISABLE == "0" ) then
		QuestGreetingScrollChildFrame:SetAlpha(0);
		UIFrameFadeIn(QuestGreetingScrollChildFrame, QUESTINFO_FADE_IN);
	end
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameGreetingPanel, material);
	GreetingText:SetText(GetGreetingText());
	QuestFrame_SetTextColor(GreetingText, material);
	QuestFrame_SetTitleTextColor(CurrentQuestsText, material);
	QuestFrame_SetTitleTextColor(AvailableQuestsText, material);
	local numActiveQuests = GetNumActiveQuests();
	local numAvailableQuests = GetNumAvailableQuests();
	if ( numActiveQuests == 0 ) then
		CurrentQuestsText:Hide();
		QuestGreetingFrameHorizontalBreak:Hide();
	else 
		CurrentQuestsText:SetPoint("TOPLEFT", "GreetingText", "BOTTOMLEFT", 0, -10);
		CurrentQuestsText:Show();
		QuestTitleButton1:SetPoint("TOPLEFT", "CurrentQuestsText", "BOTTOMLEFT", -10, -5);
		for i=1, numActiveQuests, 1 do
			local questTitleButton = getglobal("QuestTitleButton"..i);
			local questTitleButtonIcon = getglobal(questTitleButton:GetName() .. "QuestIcon");
			if ( IsActiveQuestTrivial(i) ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, GetActiveTitle(i));
				questTitleButtonIcon:SetVertexColor(0.5,0.5,0.5);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, GetActiveTitle(i));
				questTitleButtonIcon:SetVertexColor(1,1,1);
			end
			questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon"); 
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i);
			questTitleButton.isActive = 1;
			questTitleButton:Show();
			if ( i > 1 ) then
				questTitleButton:SetPoint("TOPLEFT", "QuestTitleButton"..(i-1),"BOTTOMLEFT", 0, -2)
			end
		end
	end
	if ( numAvailableQuests == 0 ) then
		AvailableQuestsText:Hide();
		QuestGreetingFrameHorizontalBreak:Hide();
	else
		if ( numActiveQuests > 0 ) then
			QuestGreetingFrameHorizontalBreak:SetPoint("TOPLEFT", "QuestTitleButton"..numActiveQuests, "BOTTOMLEFT",22,-10);
			QuestGreetingFrameHorizontalBreak:Show();
			AvailableQuestsText:SetPoint("TOPLEFT", "QuestGreetingFrameHorizontalBreak", "BOTTOMLEFT", -12, -10);
		else
			AvailableQuestsText:SetPoint("TOPLEFT", "GreetingText", "BOTTOMLEFT", 0, -10);
		end
		AvailableQuestsText:Show();
		getglobal("QuestTitleButton"..(numActiveQuests + 1)):SetPoint("TOPLEFT", "AvailableQuestsText", "BOTTOMLEFT", -10, -5);
		for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests), 1 do
			local questTitleButton = getglobal("QuestTitleButton"..i);
			local questTitleButtonIcon = getglobal(questTitleButton:GetName() .. "QuestIcon");
			if ( IsAvailableQuestTrivial(i - numActiveQuests) ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButtonIcon:SetVertexColor(0.5,0.5,0.5);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButtonIcon:SetVertexColor(1,1,1);
			end
			questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon"); 
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i - numActiveQuests);
			questTitleButton.isActive = 0;
			questTitleButton:Show();
			if ( i > numActiveQuests + 1 ) then
				questTitleButton:SetPoint("TOPLEFT", "QuestTitleButton"..(i-1),"BOTTOMLEFT", 0, -2)
			end
		end
	end
	for i=(numActiveQuests + numAvailableQuests + 1), MAX_NUM_QUESTS, 1 do
		getglobal("QuestTitleButton"..i):Hide();
	end
end

function QuestFrame_OnShow()
	PlaySound("igQuestListOpen");
end

function QuestFrame_OnHide()
	QuestFrameGreetingPanel:Hide();
	QuestFrameDetailPanel:Hide();
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	if ( QuestFrame.dialog ) then
		QuestFrame.dialog:Hide();
		QuestFrame.dialog = nil;
	end
	CloseQuest();
	PlaySound("igQuestListClose");
end

function QuestTitleButton_OnClick(self)
	if ( self.isActive == 1 ) then
		SelectActiveQuest(self:GetID());
	else
		SelectAvailableQuest(self:GetID());
	end
	PlaySound("igQuestListSelect");
end

function QuestMoneyFrame_OnLoad (self)
	MoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
end

function QuestHonorFrame_Update(honorFrame, honor)
	if (honorFrame and honor) then
		getglobal(honorFrame.."Points"):SetText(honor);
		local factionGroup = UnitFactionGroup("player");
		local icon = getglobal(honorFrame.."Icon");
		if ( factionGroup ) then
			icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			icon:Show();
		else
			icon:Hide();
		end
	end
end

function QuestTalentFrame_Update(talentFrame, talents)
	if (talentFrame and talents) then
		getglobal(talentFrame.."Points"):SetText(talents);
	end
end

function QuestFrameItems_Update(questState)
	local isQuestLog = 0;
	if ( questState == "QuestLog" ) then
		isQuestLog = 1;
	end
	local numQuestRewards;
	local numQuestChoices;
	local numQuestSpellRewards = 0;
	local money;
	local honor;
	local talents;
	local playerTitle;
	local spacerFrame;
	if ( isQuestLog == 1 ) then
		numQuestRewards = GetNumQuestLogRewards();
		numQuestChoices = GetNumQuestLogChoices();
		if ( GetQuestLogRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetQuestLogRewardMoney();
		honor = GetQuestLogRewardHonor();
		talents = GetQuestLogRewardTalents();
		playerTitle = GetQuestLogRewardTitle();
		spacerFrame = QuestLogSpacerFrame;
	else
		numQuestRewards = GetNumQuestRewards();
		numQuestChoices = GetNumQuestChoices();
		if ( GetRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetRewardMoney();
		honor = GetRewardHonor();
		talents = GetRewardTalents();
		playerTitle = GetRewardTitle();
		spacerFrame = QuestSpacerFrame;
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards;
	local questItemName = questState.."Item";
	local material = QuestFrame_GetMaterial();
	local questItemReceiveText = getglobal(questState.."ItemReceiveText")
	local honorFrame = getglobal(questState.."HonorFrame");
	local talentFrame = getglobal(questState.."TalentFrame");
	local moneyFrame = getglobal(questState.."MoneyFrame");
	local playerTitleFrame = getglobal(questState.."PlayerTitleFrame");
	
	if ( totalRewards == 0 and money == 0 and honor == 0 and talents == 0 and not playerTitle ) then
		getglobal(questState.."RewardTitleText"):Hide();
	else
		getglobal(questState.."RewardTitleText"):Show();
		QuestFrame_SetTitleTextColor(getglobal(questState.."RewardTitleText"), material);
		QuestFrame_SetAsLastShown(getglobal(questState.."RewardTitleText"), spacerFrame);
	end
	if ( money == 0 ) then
		moneyFrame:Hide();
	else
		moneyFrame:Show();
		QuestFrame_SetAsLastShown(moneyFrame, spacerFrame);
		MoneyFrame_Update(questState.."MoneyFrame", money);
	end
	if (honor == 0) then
		honorFrame:Hide();
	else
		honorFrame:Show();
		QuestHonorFrame_Update(questState.."HonorFrame", honor);
		QuestFrame_SetAsLastShown(honorFrame, spacerFrame);
	end

	if ( not playerTitle ) then
		playerTitleFrame:Hide();
	else
		local anchorFrame;
		if ( talents ~= 0 ) then
			anchorFrame = talentFrame;
		elseif ( honor ~= 0 ) then
			anchorFrame = honorFrame;
		elseif ( money ~= 0 ) then
			anchorFrame = moneyFrame;
		else
			anchorFrame = getglobal(questState.."RewardTitleText");
		end
		playerTitleFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -5);
		getglobal(questState.."PlayerTitleFrameTitle"):SetText(playerTitle);
		playerTitleFrame:Show();
		QuestFrame_SetAsLastShown(playerTitleFrame, spacerFrame);
	end

	-- Hide unused rewards
	for i=totalRewards + 1, MAX_NUM_ITEMS, 1 do
		getglobal(questItemName..i):Hide();
	end

	local questItem, name, texture, isTradeskillSpell, isSpellLearned, quality, isUsable, numItems = 1;
	local rewardsCount = 0;
	
	-- Setup choosable rewards
	if ( numQuestChoices > 0 ) then
		local itemChooseText = getglobal(questState.."ItemChooseText");
		itemChooseText:Show();
		QuestFrame_SetTextColor(itemChooseText, material);
		QuestFrame_SetAsLastShown(itemChooseText, spacerFrame);
		
		local index;
		local baseIndex = rewardsCount;
		for i=1, numQuestChoices, 1 do	
			index = i + baseIndex;
			questItem = getglobal(questItemName..index);
			questItem.type = "choice";
			numItems = 1;
			if ( isQuestLog == 1 ) then
				name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
			end
			questItem:SetID(i)
			questItem:Show();
			-- For the tooltip
			questItem.rewardType = "item"
			QuestFrame_SetAsLastShown(questItem, spacerFrame);
			getglobal(questItemName..index.."Name"):SetText(name);
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
					questItem:SetPoint("TOPLEFT", questItemName..(index - 2), "BOTTOMLEFT", 0, -2);
				else
					questItem:SetPoint("TOPLEFT", questItemName..(index - 1), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", itemChooseText, "BOTTOMLEFT", -3, -5);
			end
			rewardsCount = rewardsCount + 1;
		end
	else
		getglobal(questState.."ItemChooseText"):Hide();
	end
	
	-- Setup spell rewards
	if ( numQuestSpellRewards > 0 ) then
		local learnSpellText = getglobal(questState.."SpellLearnText");
		learnSpellText:Show();
		QuestFrame_SetTextColor(learnSpellText, material);
		QuestFrame_SetAsLastShown(learnSpellText, spacerFrame);

		--Anchor learnSpellText if there were choosable rewards
		if ( rewardsCount > 0 ) then
			local rewardPoint;
			if ( mod(rewardsCount, 2) == 0 ) then
				rewardPoint = rewardsCount - 1;
			else
				rewardPoint = rewardsCount;
			end
			learnSpellText:SetPoint("TOPLEFT", questItemName..rewardPoint, "BOTTOMLEFT", 3, -5);
		else
			learnSpellText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 0, -5);
		end

		if ( isQuestLog == 1 ) then
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
		questItem = getglobal(questItemName..rewardsCount);
		questItem:Show();
		-- For the tooltip
		questItem.rewardType = "spell";
		SetItemButtonCount(questItem, 0);
		SetItemButtonTexture(questItem, texture);
		getglobal(questItemName..rewardsCount.."Name"):SetText(name);
		questItem:SetPoint("TOPLEFT", learnSpellText, "BOTTOMLEFT", -3, -5);
	else
		getglobal(questState.."SpellLearnText"):Hide();
	end
	
	talentFrame:Hide();
	-- Setup mandatory rewards
	if ( numQuestRewards > 0 or money > 0 or honor > 0 or talents > 0 ) then
		QuestFrame_SetTextColor(questItemReceiveText, material);
		-- Anchor the reward text differently if there are choosable rewards
		if ( numQuestSpellRewards > 0 ) then
			questItemReceiveText:SetText(REWARD_ITEMS);
			questItemReceiveText:SetPoint("TOPLEFT", questItemName..rewardsCount, "BOTTOMLEFT", 3, -5);		
		elseif ( numQuestChoices > 0 ) then
			questItemReceiveText:SetText(REWARD_ITEMS);
			local index = numQuestChoices;
			if ( mod(index, 2) == 0 ) then
				index = index - 1;
			end
			questItemReceiveText:SetPoint("TOPLEFT", questItemName..index, "BOTTOMLEFT", 3, -5);
		else 
			questItemReceiveText:SetText(REWARD_ITEMS_ONLY);
			questItemReceiveText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 3, -5);
		end
		questItemReceiveText:Show();
		QuestFrame_SetAsLastShown(questItemReceiveText, spacerFrame);
		
		if (talents ~= 0) then
			if ( honor ~= 0 ) then
				talentFrame:SetPoint("TOPLEFT", honorFrame, "BOTTOMLEFT", 0, -5);
			end
			talentFrame:Show();
			QuestTalentFrame_Update(questState.."TalentFrame", talents);
			QuestFrame_SetAsLastShown(talentFrame, spacerFrame);
		end
	
		-- Setup mandatory rewards
		local index;
		local baseIndex = rewardsCount;
		for i=1, numQuestRewards, 1 do
			index = i + baseIndex;
			questItem = getglobal(questItemName..index);
			questItem.type = "reward";
			numItems = 1;
			if ( isQuestLog == 1 ) then
				name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i);
			else
				name, texture, numItems, quality, isUsable = GetQuestItemInfo(questItem.type, i);
			end
			questItem:SetID(i)
			questItem:Show();
			-- For the tooltip
			questItem.rewardType = "item";
			QuestFrame_SetAsLastShown(questItem, spacerFrame);
			getglobal(questItemName..index.."Name"):SetText(name);
			SetItemButtonCount(questItem, numItems);
			SetItemButtonTexture(questItem, texture);
			if ( isUsable ) then
				SetItemButtonTextureVertexColor(questItem, 1.0, 1.0, 1.0);
				SetItemButtonNameFrameVertexColor(questItem, 1.0, 1.0, 1.0);
			else
				SetItemButtonTextureVertexColor(questItem, 0.5, 0, 0);
				SetItemButtonNameFrameVertexColor(questItem, 1.0, 0, 0);
			end
			
			if ( i > 1 ) then
				if ( mod(i,2) == 1 ) then
					questItem:SetPoint("TOPLEFT", questItemName..(index - 2), "BOTTOMLEFT", 0, -2);
				else
					questItem:SetPoint("TOPLEFT", questItemName..(index - 1), "TOPRIGHT", 1, 0);
				end
			elseif ( talents > 0 ) then
				questItem:SetPoint("TOPLEFT", talentFrame, "BOTTOMLEFT", -3, -5);
			elseif ( honor > 0 ) then
				questItem:SetPoint("TOPLEFT", questState.."HonorFrame", "BOTTOMLEFT", -3, -5);
			else
				questItem:SetPoint("TOPLEFT", questState.."ItemReceiveText", "BOTTOMLEFT", -3, -5);
			end
			rewardsCount = rewardsCount + 1;
		end
	else	
		questItemReceiveText:Hide();
	end
	if ( questState == "QuestReward" ) then
		QuestFrameCompleteQuestButton:Enable();
		QuestFrameRewardPanel.itemChoice = 0;
		QuestRewardItemHighlight:Hide();
	end
end

function QuestFrameDetailPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameDetailPanel, material);
	QuestTitleText:SetText(GetTitleText());
	QuestFrame_SetTitleTextColor(QuestTitleText, material);
	QuestDescription:SetText(GetQuestText());
	QuestFrame_SetTextColor(QuestDescription, material);
	QuestFrame_SetTitleTextColor(QuestDetailObjectiveTitleText, material);
	local suggestedGroup = GetSuggestedGroupNum();
	if ( suggestedGroup > 0 ) then
		local suggestedGroupString = format(QUEST_SUGGESTED_GROUP_NUM, suggestedGroup);
		local questObjective = GetObjectiveText().."\n\n"..suggestedGroupString;
		QuestObjectiveText:SetText(questObjective);
	else
		QuestObjectiveText:SetText(GetObjectiveText());
	end
	QuestFrame_SetTextColor(QuestObjectiveText, material);
	QuestFrame_SetAsLastShown(QuestObjectiveText, QuestSpacerFrame);
	QuestFrameItems_Update("QuestDetail");
	QuestDetailScrollFrameScrollBar:SetValue(0);

	-- Hide Objectives and rewards until the text is completely displayed
	TextAlphaDependentFrame:SetAlpha(0);
	QuestFrameAcceptButton:Disable();

	QuestFrameDetailPanel.fading = 1;
	QuestFrameDetailPanel.fadingProgress = 0;
	QuestDescription:SetAlphaGradient(0, QUEST_DESCRIPTION_GRADIENT_LENGTH);
	if ( QUEST_FADING_DISABLE == "1" ) then
		QuestFrameDetailPanel.fadingProgress = 1024;
	end
end

function QuestFrameDetailPanel_OnUpdate(self, elapsed)
	if ( self.fading ) then
		self.fadingProgress = self.fadingProgress + (elapsed * QUEST_DESCRIPTION_GRADIENT_CPS);
		PlaySound("WriteQuest");
		if ( not QuestDescription:SetAlphaGradient(self.fadingProgress, QUEST_DESCRIPTION_GRADIENT_LENGTH) ) then
			self.fading = nil;
			-- Show Quest Objectives and Rewards
			if ( QUEST_FADING_DISABLE == "0" ) then
				UIFrameFadeIn(TextAlphaDependentFrame, QUESTINFO_FADE_IN );
			else
				TextAlphaDependentFrame:SetAlpha(1);
			end
			QuestFrameAcceptButton:Enable();
		end
	end
end

function QuestDetailAcceptButton_OnClick()
	if ( QuestFlagsPVP() ) then
		QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST");
	else
		AcceptQuest();
	end
end

function QuestDetailDeclineButton_OnClick()
	DeclineQuest();
	PlaySound("igQuestCancel");
end

function QuestFrame_SetMaterial(frame, material)
	if ( material == "Parchment" ) then
		getglobal(frame:GetName().."MaterialTopLeft"):Hide();
		getglobal(frame:GetName().."MaterialTopRight"):Hide();
		getglobal(frame:GetName().."MaterialBotLeft"):Hide();
		getglobal(frame:GetName().."MaterialBotRight"):Hide();
	else
		getglobal(frame:GetName().."MaterialTopLeft"):Show();
		getglobal(frame:GetName().."MaterialTopRight"):Show();
		getglobal(frame:GetName().."MaterialBotLeft"):Show();
		getglobal(frame:GetName().."MaterialBotRight"):Show();
		getglobal(frame:GetName().."MaterialTopLeft"):SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopLeft");
		getglobal(frame:GetName().."MaterialTopRight"):SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopRight");
		getglobal(frame:GetName().."MaterialBotLeft"):SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotLeft");
		getglobal(frame:GetName().."MaterialBotRight"):SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotRight");
	end
end

function QuestFrame_GetMaterial()
	local material = GetQuestBackgroundMaterial();
	if ( not material ) then
		material = "Parchment";
	end
	return material;
end

function QuestFrame_SetTitleTextColor(fontString, material)
	local temp, materialTitleTextColor = GetMaterialTextColors(material);
	fontString:SetTextColor(materialTitleTextColor[1], materialTitleTextColor[2], materialTitleTextColor[3]);
end

function QuestFrame_SetTextColor(fontString, material)
	local materialTextColor = GetMaterialTextColors(material);
	fontString:SetTextColor(materialTextColor[1], materialTextColor[2], materialTextColor[3]);
end
