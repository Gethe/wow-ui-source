MAX_NUM_QUESTS = 25; -- The max number of QuestTitleButtons.
MAX_NUM_ITEMS = 10;
MAX_REQUIRED_ITEMS = 6;
QUEST_DESCRIPTION_GRADIENT_LENGTH = 30;
QUEST_DESCRIPTION_GRADIENT_CPS = 40;
QUESTINFO_FADE_IN = 1;

QUEST_FRAME_AUTO_ACCEPT_QUEST_ID = 0;
QUEST_FRAME_AUTO_ACCEPT_QUEST_START_ITEM_ID = 0;

function QuestFrame_OnLoad(self)
	self:RegisterEvent("QUEST_GREETING");
	self:RegisterEvent("QUEST_DETAIL");
	self:RegisterEvent("QUEST_PROGRESS");
	self:RegisterEvent("QUEST_COMPLETE");
	self:RegisterEvent("QUEST_FINISHED");
	self:RegisterEvent("QUEST_ITEM_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
end

function QuestFrame_OnEvent(self, event, ...)
	if ( event == "QUEST_FINISHED" ) then
		HideUIPanel(QuestFrame);
		return;
	end
	if ( event == "QUEST_ITEM_UPDATE" and not QuestFrame:IsShown() ) then
		return;
	end
	if (event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED") and not QuestFrame:IsShown() then
		return;
	end

	if ( event == "QUEST_GREETING" ) then
		QuestFrameGreetingPanel:Hide();
		QuestFrameGreetingPanel:Show();
	elseif ( event == "QUEST_DETAIL" ) then
		local questStartItemID = ...;
		QUEST_FRAME_AUTO_ACCEPT_QUEST_ID = 0;
        QUEST_FRAME_AUTO_ACCEPT_QUEST_START_ITEM_ID = 0;

        if(questStartItemID ~= nil and questStartItemID ~= 0) then
            QUEST_FRAME_AUTO_ACCEPT_QUEST_ID = GetQuestID();
            QUEST_FRAME_AUTO_ACCEPT_QUEST_START_ITEM_ID = questStartItemID;
            PlayAutoAcceptQuestSound();
            CloseQuest();
            return;
		end

		HideUIPanel(QuestLogPopupDetailFrame);
		QuestFrameDetailPanel:Hide();
		QuestFrameDetailPanel:Show();
	elseif ( event == "QUEST_PROGRESS" ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		QuestFrameProgressPanel:Hide();
		QuestFrameProgressPanel:Show();
	elseif ( event == "QUEST_COMPLETE" ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		QuestFrameCompleteQuestButton:Enable();
		QuestFrameRewardPanel:Hide();
		QuestFrameRewardPanel:Show();
	elseif ( event == "QUEST_ITEM_UPDATE" ) then
		if ( QuestFrameDetailPanel:IsShown() ) then
			QuestInfo_ShowRewards();
			QuestDetailScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameProgressPanel:IsShown() ) then
			QuestFrameProgressItems_Update()
			QuestProgressScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameRewardPanel:IsShown() ) then
			QuestInfo_ShowRewards();
			QuestRewardScrollFrameScrollBar:SetValue(0);
		end
	elseif ( event == "QUEST_LOG_UPDATE" ) then
		-- just update if at greeting panel
		if ( QuestFrameGreetingPanel:IsShown() ) then
			QuestFrameGreetingPanel_OnShow(QuestFrameGreetingPanel);
		end
		return;
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		if ( QuestInfoFrame.rewardsFrame:IsVisible() ) then
			QuestInfo_ShowRewards();
			QuestDetailScrollFrameScrollBar:SetValue(0);
		end
		return;
	end

	QuestFrame_SetPortrait();
	ShowUIPanel(QuestFrame);
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
	QuestInfo_Display(QUEST_TEMPLATE_REWARD, QuestRewardScrollChildFrame, QuestFrameCompleteQuestButton, material);
	QuestRewardScrollFrameScrollBar:SetValue(0);
	local questPortrait, questPortraitText, questPortraitName = GetQuestPortraitTurnIn();
	if (questPortrait ~= 0) then
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, 0, questPortraitText, questPortraitName, -3, -42);
	else
		QuestFrame_HideQuestPortrait();
	end
	if ( GetCVar("instantQuestText") == "0" ) then
		QuestRewardScrollChildFrame:SetAlpha(0);
		UIFrameFadeIn(QuestRewardScrollChildFrame, QUESTINFO_FADE_IN);
	end
end

function QuestRewardCancelButton_OnClick()
	DeclineQuest();
	PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
end

function QuestRewardCompleteButton_OnClick()
	if ( GetNumQuestChoices() == 1 ) then
		QuestInfoFrame.itemChoice = 1;
	end
	if ( QuestInfoFrame.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
		QuestChooseRewardError();
	else
		GetQuestReward(QuestInfoFrame.itemChoice);
		PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE);
	end
end

function QuestProgressCompleteButton_OnClick()
	CompleteQuest();
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
end

function QuestGoodbyeButton_OnClick()
	DeclineQuest();
	PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
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
	QuestFrame_HideQuestPortrait();
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
	if ( GetCVar("instantQuestText") == "0" ) then
		QuestProgressScrollChildFrame:SetAlpha(0);
		UIFrameFadeIn(QuestProgressScrollChildFrame, QUESTINFO_FADE_IN);
	end
end

function QuestFrameProgressItems_Update()
	local numRequiredItems = GetNumQuestItems();
	local numRequiredCurrencies = 0;--GetNumQuestCurrencies();
	local questItemName = "QuestProgressItem";
	local buttonIndex = 1;
	if ( numRequiredItems > 0 or GetQuestMoneyToGet() > 0 or numRequiredCurrencies > 0) then

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
			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredMoneyText", "BOTTOMLEFT", 0, -10);
		else
			QuestProgressRequiredMoneyText:Hide();
			QuestProgressRequiredMoneyFrame:Hide();

			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredItemsText", "BOTTOMLEFT", -3, -5);
		end

		-- Keep track of how many actual required items there are, in case we hide all of them.
		local actualNumRequiredItems = 0;
		for i=1, numRequiredItems do
			local hidden = IsQuestItemHidden(i);
			if (hidden == 0) then
				local requiredItem = _G[questItemName..buttonIndex];
				requiredItem.type = "required";
				requiredItem.objectType = "item";
				requiredItem:SetID(i);
				local name, texture, numItems = GetQuestItemInfo(requiredItem.type, i);
				SetItemButtonCount(requiredItem, numItems);
				SetItemButtonTexture(requiredItem, texture);
				requiredItem:Show();
				_G[questItemName..buttonIndex.."Name"]:SetText(name);
				buttonIndex = buttonIndex+1;
				actualNumRequiredItems = actualNumRequiredItems+1;
			end
		end

		-- Show the "Required Items" text if needed.
		if (actualNumRequiredItems + numRequiredCurrencies > 0) then
			QuestProgressRequiredItemsText:Show();
		else
			QuestProgressRequiredItemsText:Hide();
		end

		for i=1, numRequiredCurrencies do
			local requiredItem = _G[questItemName..buttonIndex];
			requiredItem.type = "required";
			requiredItem.objectType = "currency";
			requiredItem:SetID(i);
			local name, texture, numItems = GetQuestCurrencyInfo(requiredItem.type, i);
			SetItemButtonCount(requiredItem, numItems);
			SetItemButtonTexture(requiredItem, texture);
			requiredItem:Show();
			_G[questItemName..buttonIndex.."Name"]:SetText(name);
			buttonIndex = buttonIndex+1;
		end

	else
		QuestProgressRequiredMoneyText:Hide();
		QuestProgressRequiredMoneyFrame:Hide();
		QuestProgressRequiredItemsText:Hide();
	end
	for i=buttonIndex, MAX_REQUIRED_ITEMS do
		_G[questItemName..i]:Hide();
	end
	QuestProgressScrollFrameScrollBar:SetValue(0);
end

function QuestFrameGreetingPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameDetailPanel:Hide();
	QuestFrame_HideQuestPortrait();
	if ( GetCVar("instantQuestText") == "0" ) then
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
		for i=1, numActiveQuests do
			local questTitleButton = _G["QuestTitleButton"..i];
			local title, isComplete = GetActiveTitle(i);
			questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title);
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
		_G["QuestTitleButton"..(numActiveQuests + 1)]:SetPoint("TOPLEFT", "AvailableQuestsText", "BOTTOMLEFT", -10, -5);
		for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
			local questTitleButton = _G["QuestTitleButton"..i];
			questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i - numActiveQuests);
			questTitleButton.isActive = 0;
			questTitleButton:Show();
			if ( i > numActiveQuests + 1 ) then
				questTitleButton:SetPoint("TOPLEFT", "QuestTitleButton"..(i-1),"BOTTOMLEFT", 0, -2)
			end
		end
	end
	for i=(numActiveQuests + numAvailableQuests + 1), MAX_NUM_QUESTS do
		_G["QuestTitleButton"..i]:Hide();
	end
end

function QuestFrame_OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	NPCFriendshipStatusBar_Update(QuestFrame);
end

function QuestFrame_OnHide()
	QuestFrameGreetingPanel:Hide();
	QuestFrameDetailPanel:Hide();
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrame_HideQuestPortrait();
	if ( QuestFrame.dialog ) then
		QuestFrame.dialog:Hide();
		QuestFrame.dialog = nil;
	end
	if ( QuestFrame.autoQuest ) then
		QuestFrameDeclineButton:Show();
		QuestFrameCloseButton:Enable();
		PlayAutoAcceptQuestSound();
		QuestFrame.autoQuest = nil;
	end
	CloseQuest();
	if (TUTORIAL_QUEST_ACCEPTED) then
		if (not IsTutorialFlagged(2)) then
			local _, raceName  = UnitRace("player");
			if ( strupper(raceName) ~= "PANDAREN" ) then
				TriggerTutorial(2);
			end
		end
		if (not IsTutorialFlagged(10) and (TUTORIAL_QUEST_ACCEPTED == TUTORIAL_QUEST_TO_WATCH)) then
			TriggerTutorial(10);
		end
		TUTORIAL_QUEST_ACCEPTED = nil
	end
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
end

function QuestTitleButton_OnClick(self)
	if ( self.isActive == 1 ) then
		SelectActiveQuest(self:GetID());
	else
		SelectAvailableQuest(self:GetID());
	end
	PlaySound(SOUNDKIT.IG_QUEST_LIST_SELECT);
end

function QuestMoneyFrame_OnLoad(self)
	MoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
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
	local spacerFrame;
	if ( isQuestLog == 1 ) then
		numQuestRewards = GetNumQuestLogRewards();
		numQuestChoices = GetNumQuestLogChoices();
		numQuestSpellRewards = GetNumQuestLogRewardSpells();
		money = GetQuestLogRewardMoney();
		spacerFrame = QuestLogSpacerFrame;
	else
		numQuestRewards = GetNumQuestRewards();
		numQuestChoices = GetNumQuestChoices();
		numQuestSpellRewards = GetNumRewardSpells();
		money = GetRewardMoney();
		spacerFrame = QuestSpacerFrame;
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards;
	local questItemName = questState.."Item";
	local material = QuestFrame_GetMaterial();
	local questItemReceiveText = _G[questState.."ItemReceiveText"];
	if ( totalRewards == 0 and money == 0 ) then
		_G[questState.."RewardTitleText"]:Hide();
	else
		_G[questState.."RewardTitleText"]:Show();
		QuestFrame_SetTitleTextColor(_G[questState.."RewardTitleText"], material);
		QuestFrame_SetAsLastShown(_G[questState.."RewardTitleText"], spacerFrame);
	end
	if ( money == 0 ) then
		_G[questState.."MoneyFrame"]:Hide();
	else
		_G[questState.."MoneyFrame"]:Show();
		QuestFrame_SetAsLastShown(_G[questState.."MoneyFrame"], spacerFrame);
		MoneyFrame_Update(questState.."MoneyFrame", money);
	end
	
	-- Hide unused rewards
	for i=totalRewards + 1, MAX_NUM_ITEMS, 1 do
		_G[questItemName..i]:Hide();
	end

	local questItem, name, texture, isTradeskillSpell, quality, isUsable, numItems = 1;
	local rewardsCount = 0;
	
	-- Setup choosable rewards
	if ( numQuestChoices > 0 ) then
		local itemChooseText = _G[questState.."ItemChooseText"];
		itemChooseText:Show();
		QuestFrame_SetTextColor(itemChooseText, material);
		QuestFrame_SetAsLastShown(itemChooseText, spacerFrame);
		
		local index;
		local baseIndex = rewardsCount;
		for i=1, numQuestChoices, 1 do	
			index = i + baseIndex;
			questItem = _G[questItemName..index];
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
			_G[questItemName..index.."Name"]:SetText(name);
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
		_G[questState.."ItemChooseText"]:Hide();
	end
	
	-- Setup spell rewards
	if ( numQuestSpellRewards > 0 ) then
		local learnSpellText = _G[questState.."SpellLearnText"];
		learnSpellText:Show();
		QuestFrame_SetTextColor(learnSpellText, material);
		QuestFrame_SetAsLastShown(learnSpellText, spacerFrame);

		--Anchor learnSpellText if there were choosable rewards
		if ( rewardsCount > 0 ) then
			learnSpellText:SetPoint("TOPLEFT", questItemName..rewardsCount, "BOTTOMLEFT", 3, -5);
		else
			learnSpellText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 0, -5);
		end

		-- In Classic, there's only ever one spell reward per quest,
		-- so we can just hardcode index 1.
		if ( isQuestLog == 1 ) then
			texture, name, isTradeskillSpell = GetQuestLogRewardSpell(1);
		else
			texture, name, isTradeskillSpell = GetRewardSpell(1);
		end
		
		if ( isTradeskillSpell ) then
			learnSpellText:SetText(REWARD_TRADESKILL_SPELL);
		else
			learnSpellText:SetText(REWARD_SPELL);
		end
		
		rewardsCount = rewardsCount + 1;
		questItem = _G[questItemName..rewardsCount];
		questItem:SetID(1);
		questItem:Show();
		-- For the tooltip
		questItem.rewardType = "spell";
		SetItemButtonCount(questItem, 0);
		SetItemButtonTexture(questItem, texture);
		_G[questItemName..rewardsCount.."Name"]:SetText(name);
		questItem:SetPoint("TOPLEFT", learnSpellText, "BOTTOMLEFT", -3, -5);
	else
		_G[questState.."SpellLearnText"]:Hide();
	end
	
	-- Setup mandatory rewards
	if ( numQuestRewards > 0 or money > 0) then
		QuestFrame_SetTextColor(questItemReceiveText, material);
		-- Anchor the reward text differently if there are choosable rewards
		if ( numQuestSpellRewards > 0  ) then
			questItemReceiveText:SetText(REWARD_ITEMS);
			questItemReceiveText:SetPoint("TOPLEFT", questItemName..rewardsCount, "BOTTOMLEFT", 3, -5);		
		elseif ( numQuestChoices > 0  ) then
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
		-- Setup mandatory rewards
		local index;
		local baseIndex = rewardsCount;
		for i=1, numQuestRewards, 1 do
			index = i + baseIndex;
			questItem = _G[questItemName..index];
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
			_G[questItemName..index.."Name"]:SetText(name);
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

function QuestFrame_UpdatePortraitText(text)
	if (text and text ~= "") then
		QuestNPCModelTextFrame:Show();
		QuestNPCModelText:SetText(text);
		QuestNPCModelText:SetWidth(178);
		if (QuestNPCModelText:GetHeight() > QuestNPCModelTextScrollFrame:GetHeight()) then
			QuestNPCModelTextScrollChildFrame:SetHeight(QuestNPCModelText:GetHeight()+10);
			QuestNPCModelText:SetWidth(162);
		else
			QuestNPCModelTextScrollChildFrame:SetHeight(QuestNPCModelText:GetHeight());
		end
	else
		QuestNPCModelTextFrame:Hide();
	end
end

function QuestFrame_ShowQuestPortrait(parentFrame, portraitDisplayID, mountPortraitDisplayID, text, name, x, y)
	QuestNPCModel:SetParent(parentFrame);
	QuestNPCModel:ClearAllPoints();
	QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y);
	QuestNPCModel:Show();
	QuestFrame_UpdatePortraitText(text);

	if (name and name ~= "") then
		QuestNPCModelNameplate:Show();
		QuestNPCModelBlankNameplate:Hide();
		QuestNPCModelNameText:Show();
		QuestNPCModelNameText:SetText(name);
	else
		QuestNPCModelNameplate:Hide();
		QuestNPCModelBlankNameplate:Show();
		QuestNPCModelNameText:Hide();
	end

	if (portraitDisplayID == -1) then
		QuestNPCModel:SetUnit("player");
	else
		QuestNPCModel:SetDisplayInfo(portraitDisplayID, mountPortraitDisplayID);
	end
end

function QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame)
	optPortraitOwnerCheckFrame = optPortraitOwnerCheckFrame or QuestNPCModel:GetParent();
	if optPortraitOwnerCheckFrame == QuestNPCModel:GetParent() then
		QuestNPCModel:Hide();
		QuestNPCModel:SetParent(nil);
	end
end

function QuestFrameDetailPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	QuestFrameDeclineButton:Show();

	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameDetailPanel, material);
	QuestInfo_Display(QUEST_TEMPLATE_DETAIL, QuestDetailScrollChildFrame, QuestFrameAcceptButton, material);
	QuestDetailScrollFrameScrollBar:SetValue(0);
	local questPortrait, questPortraitText, questPortraitName, questPortraitMount = GetQuestPortraitGiver();
	if (questPortrait ~= 0) then
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, questPortraitMount, questPortraitText, questPortraitName, -3, -42);
	else
		QuestFrame_HideQuestPortrait();
	end

	QuestDetailScrollChildFrame.alphaDependentText = {
		QuestInfoQuestType,
		QuestInfoObjectivesText,
		QuestInfoRewardsFrame,
		QuestInfoRewardText,
		QuestInfoRequiredMoneyText,
		QuestInfoGroupSize,
		QuestInfoAnchor,
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader
	};

	-- Hide Objectives and rewards until the text is completely displayed
	QuestInfo_HideAlphaDependentText(QuestDetailScrollChildFrame);
	QuestFrameAcceptButton:Disable();

	QuestFrameDetailPanel.fading = 1;
	QuestFrameDetailPanel.fadingProgress = 0;
	QuestInfoDescriptionText:SetAlphaGradient(0, QUEST_DESCRIPTION_GRADIENT_LENGTH);
	if ( GetCVar("instantQuestText") ~= "0" ) then
		QuestFrameDetailPanel.fadingProgress = 1024;
	end
end

function QuestFrameDetailPanel_OnHide(self)
	QuestInfo_ShowAlphaDependentText(QuestDetailScrollChildFrame);
	QuestFrameDetailPanel.fading = 0;
end

function QuestFrameDetailPanel_OnUpdate(self, elapsed)
	if ( self.fading ) then
		self.fadingProgress = self.fadingProgress + (elapsed * QUEST_DESCRIPTION_GRADIENT_CPS);
		PlaySound(SOUNDKIT.IG_WRITE_QUEST);
		if ( not QuestInfoDescriptionText:SetAlphaGradient(self.fadingProgress, QUEST_DESCRIPTION_GRADIENT_LENGTH) ) then
			self.fading = nil;
			-- Show Quest Objectives and Rewards
			if ( GetCVar("instantQuestText") == "0" ) then
				QuestInfo_FadeInAlphaDependentText(QuestDetailScrollChildFrame, QUESTINFO_FADE_IN)
			else
				QuestInfo_ShowAlphaDependentText(QuestDetailScrollChildFrame);
			end
			QuestFrameAcceptButton:Enable();
		end
	end
end

function QuestDetailAcceptButton_OnClick()
	if ( QuestFrame.autoQuest ) then
		AcknowledgeAutoAcceptQuest();
	else
		AcceptQuest();
	end
end

function QuestDetailDeclineButton_OnClick()
	DeclineQuest();
	PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
end

function QuestFrame_SetMaterial(frame, material)
	if ( material == "Parchment" ) then
		_G[frame:GetName().."MaterialTopLeft"]:Hide();
		_G[frame:GetName().."MaterialTopRight"]:Hide();
		_G[frame:GetName().."MaterialBotLeft"]:Hide();
		_G[frame:GetName().."MaterialBotRight"]:Hide();
	else
		_G[frame:GetName().."MaterialTopLeft"]:Show();
		_G[frame:GetName().."MaterialTopRight"]:Show();
		_G[frame:GetName().."MaterialBotLeft"]:Show();
		_G[frame:GetName().."MaterialBotRight"]:Show();
		_G[frame:GetName().."MaterialTopLeft"]:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopLeft");
		_G[frame:GetName().."MaterialTopRight"]:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopRight");
		_G[frame:GetName().."MaterialBotLeft"]:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotLeft");
		_G[frame:GetName().."MaterialBotRight"]:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotRight");
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