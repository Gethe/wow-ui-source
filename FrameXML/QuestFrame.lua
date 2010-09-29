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
		
	if ( event == "QUEST_GREETING" ) then
		QuestFrameGreetingPanel:Hide();
		QuestFrameGreetingPanel:Show();
	elseif ( event == "QUEST_DETAIL" ) then
		if ( QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
			WatchFrameAutoQuest_AddPopUp(GetQuestID(), "OFFER");
			CloseQuest();
			return;
		else
			HideUIPanel(QuestLogDetailFrame);
			QuestFrameDetailPanel:Hide();
			QuestFrameDetailPanel:Show();
		end
	elseif ( event == "QUEST_PROGRESS" ) then
		HideUIPanel(QuestLogDetailFrame);
		QuestFrameProgressPanel:Hide();
		QuestFrameProgressPanel:Show();
	elseif ( event == "QUEST_COMPLETE" ) then
		HideUIPanel(QuestLogDetailFrame);
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
	end
	
	QuestFrame_SetPortrait();
	ShowUIPanel(QuestFrame);
	if ( not QuestFrame:IsShown() ) then
		QuestFrameGreetingPanel:Hide();
		QuestFrameDetailPanel:Hide();
		QuestFrameProgressPanel:Hide();
		QuestFrameRewardPanel:Hide();
		CloseQuest();
		return;
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
	QuestFrameRewardPanelBotRight:SetTexture("Interface\\QuestFrame\\UI-QuestGreeting-BotRight-blank");
	QuestInfo_Display(QUEST_TEMPLATE_REWARD, QuestRewardScrollChildFrame, QuestFrameCompleteQuestButton, material);
	QuestRewardScrollFrameScrollBar:SetValue(0);
	local questPortrait, questPortraitText, questPortraitName = GetQuestPortraitTurnIn();
	if (questPortrait ~= 0) then
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, questPortraitText, questPortraitName, -33, -62);
	else
		QuestFrame_HideQuestPortrait();
	end
end

function QuestRewardCancelButton_OnClick()
	DeclineQuest();
	PlaySound("igQuestCancel");
end

function QuestRewardCompleteButton_OnClick()
	if ( QuestInfoFrame.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
		QuestChooseRewardError();
	else
		local money = GetQuestMoneyToGet();
		if ( money and money > 0 ) then
			QuestFrame.dialog = StaticPopup_Show("CONFIRM_COMPLETE_EXPENSIVE_QUEST");
			if ( QuestFrame.dialog ) then
				MoneyFrame_Update(QuestFrame.dialog:GetName().."MoneyFrame", money);
			end
		else
			GetQuestReward(QuestInfoFrame.itemChoice);
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
end

function QuestFrameProgressItems_Update()
	local numRequiredItems = GetNumQuestItems();
	local numRequiredCurrencies = GetNumQuestCurrencies();
	local questItemName = "QuestProgressItem";
	local buttonIndex = 1;
	if ( numRequiredItems > 0 or GetQuestMoneyToGet() > 0 or numRequiredCurrencies > 0) then
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
			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredMoneyText", "BOTTOMLEFT", 0, -10);
		else
			QuestProgressRequiredMoneyText:Hide();
			QuestProgressRequiredMoneyFrame:Hide();

			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredItemsText", "BOTTOMLEFT", -3, -5);
		end

		for i=1, numRequiredItems do	
			local requiredItem = _G[questItemName..buttonIndex];
			requiredItem.type = "required";
			requiredItem.rewardType = "item";
			requiredItem:SetID(i);
			local name, texture, numItems = GetQuestItemInfo(requiredItem.type, i);
			SetItemButtonCount(requiredItem, numItems);
			SetItemButtonTexture(requiredItem, texture);
			requiredItem:Show();
			_G[questItemName..buttonIndex.."Name"]:SetText(name);
			buttonIndex = buttonIndex+1;
		end
		
		for i=1, numRequiredCurrencies do	
			local requiredItem = _G[questItemName..buttonIndex];
			requiredItem.type = "required";
			requiredItem.rewardType = "currency";
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
			local questTitleButton = _G["QuestTitleButton"..i];
			local questTitleButtonIcon = _G[questTitleButton:GetName() .. "QuestIcon"];
			local title, isComplete = GetActiveTitle(i);
			if ( IsActiveQuestTrivial(i) ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, title);
				questTitleButtonIcon:SetVertexColor(0.75,0.75,0.75);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title);
				questTitleButtonIcon:SetVertexColor(1,1,1);
			end
			if ( isComplete ) then
				questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
			else
				questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\IncompleteQuestIcon");
			end
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
		for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests), 1 do
			local questTitleButton = _G["QuestTitleButton"..i];
			local questTitleButtonIcon = _G[questTitleButton:GetName() .. "QuestIcon"];
			local isTrivial, isDaily, isRepeatable = GetAvailableQuestInfo(i - numActiveQuests);
			if ( isDaily ) then
				questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\DailyQuestIcon");
			elseif ( isRepeatable ) then
				questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\DailyActiveQuestIcon");
			else
				questTitleButtonIcon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon");
			end
			if ( isTrivial ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButtonIcon:SetVertexColor(0.5,0.5,0.5);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButtonIcon:SetVertexColor(1,1,1);
			end
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
		_G["QuestTitleButton"..i]:Hide();
	end
end

function QuestFrame_OnShow()
	PlaySound("igQuestListOpen");
	if (TutorialFrame.id == 1 or TutorialFrame.id == 55 or TutorialFrame.id == 57) then
		TutorialFrame_Hide();
	end
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
	QuestFrameDetailPanelBotRight:SetTexture("Interface\\QuestFrame\\UI-QuestGreeting-BotRight");
	if ( QuestFrame.autoQuest ) then
		QuestFrameDeclineButton:Show();
		QuestFrameCloseButton:Enable();
		QuestFrame.autoQuest = nil;
	end
	CloseQuest();
	if (TUTORIAL_QUEST_ACCEPTED) then
		if (not IsTutorialFlagged(2)) then
			TriggerTutorial(2);
		end
		if (not IsTutorialFlagged(10) and (TUTORIAL_QUEST_ACCEPTED == TUTORIAL_QUEST_TO_WATCH)) then
			TriggerTutorial(10);
		end
		TUTORIAL_QUEST_ACCEPTED = nil
	end
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

function QuestFrame_ShowQuestPortrait(parentFrame, portrait, text, name, x, y)
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

	if (portrait == -1) then
		QuestNPCModel:SetUnit("player");
	else
		QuestNPCModel:SetDisplayInfo(portrait);
	end
end

function QuestFrame_HideQuestPortrait()
	QuestNPCModel:Hide();
end

function QuestFrameDetailPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	if ( QuestGetAutoAccept() ) then
		QuestFrameDetailPanelBotRight:SetTexture("Interface\\QuestFrame\\UI-QuestGreeting-BotRight-blank");
		QuestFrameDeclineButton:Hide();
		QuestFrameCloseButton:Disable();
		QuestFrame.autoQuest = true;
	end		
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameDetailPanel, material);
	QuestInfo_Display(QUEST_TEMPLATE_DETAIL1, QuestDetailScrollChildFrame, QuestFrameAcceptButton, material);
	QuestInfo_Display(QUEST_TEMPLATE_DETAIL2, QuestInfoFadingFrame, QuestFrameAcceptButton, material);
	QuestDetailScrollFrameScrollBar:SetValue(0);
	local questPortrait, questPortraitText, questPortraitName = GetQuestPortraitGiver();
	if (questPortrait ~= 0) then
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, questPortraitText, questPortraitName, -33, -62);
	else
		QuestFrame_HideQuestPortrait();
	end
end

function QuestDetailAcceptButton_OnClick()
	if ( QuestFlagsPVP() ) then
		QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST");
	else
		if ( QuestFrame.autoQuest ) then
			HideUIPanel(QuestFrame);
		else
			AcceptQuest();		
		end
	end
end

function QuestDetailDeclineButton_OnClick()
	DeclineQuest();
	PlaySound("igQuestCancel");
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