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
		HideUIPanel(QuestLogDetailFrame);
		QuestFrameDetailPanel:Hide();
		QuestFrameDetailPanel:Show();
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
	QuestInfo_Display(QUEST_TEMPLATE_REWARD, QuestRewardScrollChildFrame, QuestFrameCompleteQuestButton, QuestFrameCancelButton, material);
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
			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredMoneyText", "BOTTOMLEFT", 0, -10);
		else
			QuestProgressRequiredMoneyText:Hide();
			QuestProgressRequiredMoneyFrame:Hide();

			_G[questItemName..1]:SetPoint("TOPLEFT", "QuestProgressRequiredItemsText", "BOTTOMLEFT", -3, -5);
		end


		
		for i=1, numRequiredItems, 1 do	
			local requiredItem = _G[questItemName..i];
			requiredItem.type = "required";
			local name, texture, numItems = GetQuestItemInfo(requiredItem.type, i);
			SetItemButtonCount(requiredItem, numItems);
			SetItemButtonTexture(requiredItem, texture);
			requiredItem:Show();
			_G[questItemName..i.."Name"]:SetText(name);
			
		end
	else
		QuestProgressRequiredMoneyText:Hide();
		QuestProgressRequiredMoneyFrame:Hide();
		QuestProgressRequiredItemsText:Hide();
	end
	for i=numRequiredItems + 1, MAX_REQUIRED_ITEMS, 1 do
		_G[questItemName..i]:Hide();
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
	if ( QuestFrame.autoQuest ) then
		QuestFrameDetailPanelBotRight:SetTexture("Interface\\QuestFrame\\UI-QuestGreeting-BotRight");
		QuestFrameDeclineButton:Show();
		QuestFrame.autoQuest = nil;
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

function QuestFrameDetailPanel_OnShow()
	QuestFrameRewardPanel:Hide();
	QuestFrameProgressPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	if ( QuestGetAutoAccept() ) then
		QuestFrameDetailPanelBotRight:SetTexture("Interface\\QuestFrame\\UI-QuestGreeting-BotRight-blank");
		QuestFrameDeclineButton:Hide();
		QuestFrame.autoQuest = true;
	end		
	local material = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameDetailPanel, material);
	QuestInfo_Display(QUEST_TEMPLATE_DETAIL1, QuestDetailScrollChildFrame, QuestFrameAcceptButton, nil, material);
	QuestInfo_Display(QUEST_TEMPLATE_DETAIL2, QuestInfoFadingFrame, QuestFrameAcceptButton, nil, material);
	QuestDetailScrollFrameScrollBar:SetValue(0);
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