MAX_NUM_QUESTS = 32;
MAX_NUM_ITEMS = 10;
MAX_REQUIRED_ITEMS = 6;
QUEST_FADING_ENABLE = 1;
QUEST_DESCRIPTION_GRADIENT_LENGTH = 30;
QUEST_DESCRIPTION_GRADIENT_CPS = 40;
QUESTINFO_FADE_IN = 1;

function QuestFrame_OnLoad()
	this:RegisterEvent("QUEST_GREETING");
	this:RegisterEvent("QUEST_DETAIL");
	this:RegisterEvent("QUEST_PROGRESS");
	this:RegisterEvent("QUEST_COMPLETE");
	this:RegisterEvent("QUEST_FINISHED");
	this:RegisterEvent("QUEST_ITEM_UPDATE");
end

function QuestFrame_OnEvent(event)
	if ( event == "QUEST_FINISHED" ) then
		HideUIPanel(QuestFrame);
		return;
	end
	if ( (event == "QUEST_ITEM_UPDATE") and not QuestFrame:IsVisible() ) then
		return;
	end

	QuestFrame_SetPortrait();
	ShowUIPanel(QuestFrame);
	if ( not QuestFrame:IsVisible() ) then
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
		if ( QuestFrameDetailPanel:IsVisible() ) then
			QuestFrameItems_Update("QuestDetail");
			QuestDetailScrollFrame:UpdateScrollChildRect();
			QuestDetailScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameProgressPanel:IsVisible() ) then
			QuestFrameProgressItems_Update()
			QuestProgressScrollFrame:UpdateScrollChildRect();
			QuestProgressScrollFrameScrollBar:SetValue(0);
		elseif ( QuestFrameRewardPanel:IsVisible() ) then
			QuestFrameItems_Update("QuestReward");
			QuestRewardScrollFrame:UpdateScrollChildRect();
			QuestRewardScrollFrameScrollBar:SetValue(0);
		end
	end
end

function QuestFrame_SetPortrait()
	QuestFrameNpcNameText:SetText(UnitName("npc"));
	if ( UnitExists("npc") ) then
		SetPortraitTexture(QuestFramePortrait, "npc");
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
	QuestRewardScrollFrame:UpdateScrollChildRect();
	QuestRewardScrollFrameScrollBar:SetValue(0);
	if ( QUEST_FADING_ENABLE ) then
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
		GetQuestReward(QuestFrameRewardPanel.itemChoice);
		PlaySound("igQuestListComplete");
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

function QuestItem_OnClick()
	if ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetQuestItemLink(this.type, this:GetID()));
		end
	end
end

function QuestRewardItem_OnClick()
	if ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetQuestItemLink(this.type, this:GetID()));
		end
		return;
	end

	if ( this.type == "choice" ) then
		QuestRewardItemHighlight:SetPoint("TOPLEFT", this:GetName(), "TOPLEFT", -8, 7);
		QuestRewardItemHighlight:Show();
		QuestFrameRewardPanel.itemChoice = this:GetID();
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
	if ( QUEST_FADING_ENABLE ) then
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
			QuestLogRequiredMoneyText:SetPoint("TOPLEFT", "QuestProgressRequiredMoneyText", "BOTTOMLEFT", -3, -4);
			MoneyFrame_Update("QuestProgressRequiredMoneyFrame", GetQuestMoneyToGet());
			
			if ( GetQuestMoneyToGet() > GetMoney() ) then
				-- Not enough money
				QuestProgressRequiredMoneyText:SetTextColor(0, 0, 0);
				SetMoneyFrameColor("QuestProgressRequiredMoneyFrame", 1.0, 0.1, 0.1);
			else
				QuestProgressRequiredMoneyText:SetTextColor(0.2, 0.2, 0.2);
				SetMoneyFrameColor("QuestProgressRequiredMoneyFrame", 1.0, 1.0, 1.0);
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
	QuestProgressScrollFrame:UpdateScrollChildRect();
	QuestProgressScrollFrameScrollBar:SetValue(0);
end

function QuestFrameGreetingPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameDetailPanel:Hide();
	if ( QUEST_FADING_ENABLE ) then
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
			questTitleButton:SetText(GetActiveTitle(i));
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i);
			questTitleButton.isActive = 1;
			questTitleButton:Show();
			if ( i > 1 ) then
				questTitleButton:SetPoint("TOPLEFT", "QuestTitleButton"..(i-1),"BOTTOMLEFT", 0, 0)
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
			questTitleButton:SetText(GetAvailableTitle(i - numActiveQuests));
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i - numActiveQuests);
			questTitleButton.isActive = 0;
			questTitleButton:Show();
			if ( i > numActiveQuests + 1 ) then
				questTitleButton:SetPoint("TOPLEFT", "QuestTitleButton"..(i-1),"BOTTOMLEFT", 0, 0)
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
	CloseQuest();
	PlaySound("igQuestListClose");
end

function QuestTitleButton_OnClick()
	if ( this.isActive == 1 ) then
		SelectActiveQuest(this:GetID());
	else
		SelectAvailableQuest(this:GetID());
	end
	PlaySound("igQuestListSelect");
end

function QuestMoneyFrame_OnLoad()
	MoneyFrame_OnLoad();
	MoneyFrame_SetType("STATIC");
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
		if ( GetQuestLogRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetQuestLogRewardMoney();
		spacerFrame = QuestLogSpacerFrame;
	else
		numQuestRewards = GetNumQuestRewards();
		numQuestChoices = GetNumQuestChoices();
		if ( GetRewardSpell() ) then
			numQuestSpellRewards = 1;
		end
		money = GetRewardMoney();
		spacerFrame = QuestSpacerFrame;
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards;
	local questItemName = questState.."Item";
	local material = QuestFrame_GetMaterial();
	local  questItemReceiveText = getglobal(questState.."ItemReceiveText")
	if ( totalRewards == 0 and money == 0 ) then
		getglobal(questState.."RewardTitleText"):Hide();
	else
		getglobal(questState.."RewardTitleText"):Show();
		QuestFrame_SetTitleTextColor(getglobal(questState.."RewardTitleText"), material);
		QuestFrame_SetAsLastShown(getglobal(questState.."RewardTitleText"), spacerFrame);
	end
	if ( money == 0 ) then
		getglobal(questState.."MoneyFrame"):Hide();
	else
		getglobal(questState.."MoneyFrame"):Show();
		QuestFrame_SetAsLastShown(getglobal(questState.."MoneyFrame"), spacerFrame);
		MoneyFrame_Update(questState.."MoneyFrame", money);
	end
	
	for i=totalRewards + 1, MAX_NUM_ITEMS, 1 do
		getglobal(questItemName..i):Hide();
	end
	local questItem, name, texture, quality, isUsable, numItems = 1;
	if ( numQuestChoices > 0 ) then
		getglobal(questState.."ItemChooseText"):Show();
		QuestFrame_SetTextColor(getglobal(questState.."ItemChooseText"), material);
		QuestFrame_SetAsLastShown(getglobal(questState.."ItemChooseText"), spacerFrame);
		for i=1, numQuestChoices, 1 do	
			questItem = getglobal(questItemName..i);
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
			getglobal(questItemName..i.."Name"):SetText(name);
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
					questItem:SetPoint("TOPLEFT", questItemName..(i - 2), "BOTTOMLEFT", 0, -2);
				else
					questItem:SetPoint("TOPLEFT", questItemName..(i - 1), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", questState.."ItemChooseText", "BOTTOMLEFT", -3, -5);
			end
			
		end
	else
		getglobal(questState.."ItemChooseText"):Hide();
	end
	local rewardsCount = 0;
	if ( numQuestRewards > 0 or money > 0 or numQuestSpellRewards > 0) then
		QuestFrame_SetTextColor(questItemReceiveText, material);
		-- Anchor the reward text differently if there are choosable rewards
		if ( numQuestChoices > 0  ) then
			questItemReceiveText:SetText(TEXT(REWARD_ITEMS));
			local index = numQuestChoices;
			if ( mod(index, 2) == 0 ) then
				index = index - 1;
			end
			questItemReceiveText:SetPoint("TOPLEFT", questItemName..index, "BOTTOMLEFT", 3, -5);
		else 
			questItemReceiveText:SetText(TEXT(REWARD_ITEMS_ONLY));
			questItemReceiveText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 3, -5);
		end
		questItemReceiveText:Show();
		QuestFrame_SetAsLastShown(questItemReceiveText, spacerFrame);
		-- Setup mandatory rewards
		for i=1, numQuestRewards, 1 do
			questItem = getglobal(questItemName..(i + numQuestChoices));
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
			getglobal(questItemName..(i + numQuestChoices).."Name"):SetText(name);
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
					questItem:SetPoint("TOPLEFT", questItemName..((i + numQuestChoices) - 2), "BOTTOMLEFT", 0, -2);
				else
					questItem:SetPoint("TOPLEFT", questItemName..((i + numQuestChoices) - 1), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", questState.."ItemReceiveText", "BOTTOMLEFT", -3, -5);
			end
			rewardsCount = rewardsCount + 1;
		end
		-- Setup spell reward
		if ( numQuestSpellRewards > 0 ) then
			if ( isQuestLog == 1 ) then
				texture, name = GetQuestLogRewardSpell();
			else
				texture, name = GetRewardSpell();
			end
			questItem = getglobal(questItemName..(rewardsCount + numQuestChoices + 1));
			questItem:Show();
			-- For the tooltip
			questItem.rewardType = "spell";
			SetItemButtonTexture(questItem, texture);
			getglobal(questItemName..(rewardsCount + numQuestChoices + 1).."Name"):SetText(name);
			if ( rewardsCount > 0 ) then
				if ( mod(rewardsCount,2) == 0 ) then
					questItem:SetPoint("TOPLEFT", questItemName..((rewardsCount + numQuestChoices) - 1), "BOTTOMLEFT", 0, -2);
				else
					questItem:SetPoint("TOPLEFT", questItemName..((rewardsCount + numQuestChoices)), "TOPRIGHT", 1, 0);
				end
			else
				questItem:SetPoint("TOPLEFT", questState.."ItemReceiveText", "BOTTOMLEFT", -3, -5);
			end
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
	QuestObjectiveText:SetText(GetObjectiveText());
	QuestFrame_SetTextColor(QuestObjectiveText, material);
	QuestFrame_SetAsLastShown(QuestObjectiveText, QuestSpacerFrame);
	QuestFrameItems_Update("QuestDetail");
	QuestDetailScrollFrame:UpdateScrollChildRect();
	QuestDetailScrollFrameScrollBar:SetValue(0);

	-- Hide Objectives and rewards until the text is completely displayed
	TextAlphaDependentFrame:SetAlpha(0);
	QuestFrameAcceptButton:Disable();

	QuestFrameDetailPanel.fading = 1;
	QuestFrameDetailPanel.fadingProgress = 0;
	QuestDescription:SetAlphaGradient(0, QUEST_DESCRIPTION_GRADIENT_LENGTH);
	if ( not QUEST_FADING_ENABLE ) then
		QuestFrameDetailPanel.fadingProgress = 1024;
	end
end

function QuestFrameDetailPanel_OnUpdate(elapsed)
	if ( this.fading ) then
		this.fadingProgress = this.fadingProgress + (elapsed * QUEST_DESCRIPTION_GRADIENT_CPS);
		PlaySound("WriteQuest");
		if ( not QuestDescription:SetAlphaGradient(this.fadingProgress, QUEST_DESCRIPTION_GRADIENT_LENGTH) ) then
			this.fading = nil;
			-- Show Quest Objectives and Rewards
			if ( QUEST_FADING_ENABLE ) then
				UIFrameFadeIn(TextAlphaDependentFrame, QUESTINFO_FADE_IN );
			else
				TextAlphaDependentFrame:SetAlpha(1);
			end
			QuestFrameAcceptButton:Enable();
		end
	end
end

function QuestDetailAcceptButton_OnClick()
	AcceptQuest();
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
	local materialTitleTextColor = MATERIAL_TITLETEXT_COLOR_TABLE[material];
	fontString:SetTextColor(materialTitleTextColor[1], materialTitleTextColor[2], materialTitleTextColor[3]);
end

function QuestFrame_SetTextColor(fontString, material)
	local materialTextColor = MATERIAL_TEXT_COLOR_TABLE[material];
	fontString:SetTextColor(materialTextColor[1], materialTextColor[2], materialTextColor[3]);
end