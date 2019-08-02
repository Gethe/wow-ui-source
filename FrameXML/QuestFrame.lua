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

		if ( QuestIsFromAdventureMap() ) then
			HideUIPanel(QuestLogPopupDetailFrame);
			return;
		end

        if(questStartItemID ~= nil and questStartItemID ~= 0) then
			if (AutoQuestPopupTracker_AddPopUp(GetQuestID(), "OFFER", questStartItemID)) then
                PlayAutoAcceptQuestSound();
            end
            CloseQuest();
            return;
		end

		if ( QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
			if (AutoQuestPopupTracker_AddPopUp(GetQuestID(), "OFFER")) then
				PlayAutoAcceptQuestSound();
			end
			CloseQuest();
			return;
		else
			HideUIPanel(QuestLogPopupDetailFrame);
			QuestFrameDetailPanel:Hide();
			QuestFrameDetailPanel:Show();
		end
	elseif ( event == "QUEST_PROGRESS" ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		QuestFrameProgressPanel:Hide();
		QuestFrameProgressPanel:Show();
	elseif ( event == "QUEST_COMPLETE" ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		QuestFrameCompleteQuestButton:Enable();
		QuestFrameRewardPanel:Hide();
		QuestFrameRewardPanel:Show();
		QuestFrame.Indicators:SetQuest(GetQuestID());
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
	if( not SplashFrame:IsShown() )then
		QuestFrame_SetPortrait();
		ShowUIPanel(QuestFrame);
	end
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
	QuestInfo_Display(QUEST_TEMPLATE_REWARD, QuestRewardScrollChildFrame, QuestFrameCompleteQuestButton, material);
	QuestRewardScrollFrameScrollBar:SetValue(0);
	local questPortrait, questPortraitText, questPortraitName = GetQuestPortraitTurnIn();
	if (questPortrait ~= 0) then
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, 0, questPortraitText, questPortraitName, -3, -42);
	else
		QuestFrame_HideQuestPortrait();
	end
end

function QuestRewardCancelButton_OnClick()
	HideUIPanel(QuestFrame);
	PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
end

function QuestRewardCompleteButton_OnClick()
	if ( GetNumQuestChoices() == 1 ) then
		QuestInfoFrame.itemChoice = 1;
	end
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
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
end

function QuestGoodbyeButton_OnClick()
	HideUIPanel(QuestFrame);
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
end

function QuestFrameProgressItems_Update()
	local numRequiredItems = GetNumQuestItems();
	local numRequiredCurrencies = GetNumQuestCurrencies();
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

function QuestFrameGreetingPanel_OnLoad(self)
	self.titleButtonPool = CreateFramePool("BUTTON", self, "QuestTitleButtonTemplate");
end

function QuestFrameGreetingPanel_OnShow()
	QuestFrameGreetingPanel.titleButtonPool:ReleaseAll();

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
	local lastTitleButton = nil;
	if ( numActiveQuests == 0 ) then
		CurrentQuestsText:Hide();
		QuestGreetingFrameHorizontalBreak:Hide();
	else
		CurrentQuestsText:SetPoint("TOPLEFT", "GreetingText", "BOTTOMLEFT", 0, -10);
		CurrentQuestsText:Show();
		for i=1, numActiveQuests do
			local questTitleButton = QuestFrameGreetingPanel.titleButtonPool:Acquire();
			local title, isComplete = GetActiveTitle(i);
			if ( IsActiveQuestTrivial(i) ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, title);
				questTitleButton.Icon:SetVertexColor(0.75,0.75,0.75);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title);
				questTitleButton.Icon:SetVertexColor(1,1,1);
			end
			if ( isComplete ) then
				if ( IsActiveQuestLegendary(i) ) then
					questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\ActiveLegendaryQuestIcon");
				else
					questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
				end
			else
				questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\IncompleteQuestIcon");
			end
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i);
			questTitleButton.isActive = 1;
			questTitleButton:Show();
			if ( lastTitleButton ) then
				questTitleButton:SetPoint("TOPLEFT", lastTitleButton,"BOTTOMLEFT", 0, -2);
			else
				questTitleButton:SetPoint("TOPLEFT", "CurrentQuestsText", "BOTTOMLEFT", -10, -5);
			end
			questTitleButton:Show();
			lastTitleButton = questTitleButton;
		end
	end
	if ( numAvailableQuests == 0 ) then
		AvailableQuestsText:Hide();
		QuestGreetingFrameHorizontalBreak:Hide();
	else
		if ( numActiveQuests > 0 ) then
			QuestGreetingFrameHorizontalBreak:SetPoint("TOPLEFT", lastTitleButton, "BOTTOMLEFT",22,-10);
			QuestGreetingFrameHorizontalBreak:Show();
			AvailableQuestsText:SetPoint("TOPLEFT", "QuestGreetingFrameHorizontalBreak", "BOTTOMLEFT", -12, -10);
		else
			AvailableQuestsText:SetPoint("TOPLEFT", "GreetingText", "BOTTOMLEFT", 0, -10);
		end
		AvailableQuestsText:Show();
		lastTitleButton = nil;
		for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
			local questTitleButton = QuestFrameGreetingPanel.titleButtonPool:Acquire();
			local isTrivial, frequency, isRepeatable, isLegendary = GetAvailableQuestInfo(i - numActiveQuests);
			if ( isLegendary ) then
				questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\AvailableLegendaryQuestIcon");
			elseif ( frequency == LE_QUEST_FREQUENCY_DAILY or frequency == LE_QUEST_FREQUENCY_WEEKLY ) then
				questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\DailyQuestIcon");
			elseif ( isRepeatable ) then
				questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\DailyActiveQuestIcon");
			else
				questTitleButton.Icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon");
			end
			if ( isTrivial ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButton.Icon:SetVertexColor(0.5,0.5,0.5);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, GetAvailableTitle(i - numActiveQuests));
				questTitleButton.Icon:SetVertexColor(1,1,1);
			end
			questTitleButton:SetHeight(questTitleButton:GetTextHeight() + 2);
			questTitleButton:SetID(i - numActiveQuests);
			questTitleButton.isActive = 0;
			questTitleButton:Show();
			if ( lastTitleButton ) then
				questTitleButton:SetPoint("TOPLEFT", lastTitleButton,"BOTTOMLEFT", 0, -2);
			else
				questTitleButton:SetPoint("TOPLEFT", "AvailableQuestsText", "BOTTOMLEFT", -10, -5);
			end
			questTitleButton:Show();
			lastTitleButton = questTitleButton;
		end
	end
end

function QuestFrame_OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	if (TutorialFrame.id == 1 or TutorialFrame.id == 55 or TutorialFrame.id == 57) then
		TutorialFrame_Hide();
	end
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
	if ( QuestGetAutoAccept() ) then
		QuestFrameDeclineButton:Hide();
		QuestFrameCloseButton:Disable();
		QuestFrame.autoQuest = true;
	else
		QuestFrameDeclineButton:Show();
	end
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

	QuestFrame.Indicators:SetQuest(GetQuestID());
end

function QuestDetailAcceptButton_OnClick()
	if ( QuestFlagsPVP() ) then
		QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST");
	else
		if ( QuestFrame.autoQuest ) then
			AcknowledgeAutoAcceptQuest();
		else
			AcceptQuest();
		end
	end
end

function QuestDetailDeclineButton_OnClick()
	HideUIPanel(QuestFrame);
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