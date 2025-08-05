MAX_NUM_ITEMS = 10;
MAX_REQUIRED_ITEMS = 6;
QUEST_DESCRIPTION_GRADIENT_LENGTH = 30;
QUEST_DESCRIPTION_GRADIENT_CPS = 70;
QUESTINFO_FADE_IN = 0.5;

local QUEST_FRAME_MODEL_SCENE_ID = 309;

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
	self:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE");
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
			if (QuestObjectiveTracker:AddAutoQuestPopUp(GetQuestID(), "OFFER", questStartItemID)) then
                PlayAutoAcceptQuestSound();
            end
            CloseQuest();
            return;
		end

		if ( QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
			if (QuestObjectiveTracker:AddAutoQuestPopUp(GetQuestID(), "OFFER")) then
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
	elseif ( event == "QUEST_ITEM_UPDATE" ) then
		if ( QuestFrameDetailPanel:IsShown() ) then
			QuestInfo_ShowRewards();
			QuestDetailScrollFrame.ScrollBar:ScrollToBegin();
		elseif ( QuestFrameProgressPanel:IsShown() ) then
			QuestFrameProgressItems_Update()
			QuestProgressScrollFrame.ScrollBar:ScrollToBegin();
		elseif ( QuestFrameRewardPanel:IsShown() ) then
			QuestInfo_ShowRewards();
			QuestRewardScrollFrame.ScrollBar:ScrollToBegin();
		end
	elseif ( event == "QUEST_LOG_UPDATE" ) then
		-- just update if at greeting panel
		if ( QuestFrameGreetingPanel:IsShown() ) then
			QuestFrameGreetingPanel_OnShow(QuestFrameGreetingPanel);
		end
		return;
	elseif ( event == "LEARNED_SPELL_IN_SKILL_LINE" ) then
		if ( QuestInfoFrame.rewardsFrame:IsVisible() ) then
			QuestInfo_ShowRewards();
			QuestDetailScrollFrame.ScrollBar:ScrollToBegin();
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
	QuestFrame:SetTitle(UnitName("questnpc"));
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
	QuestRewardScrollFrame.ScrollBar:ScrollToBegin();
	local questPortrait, questPortraitText, questPortraitName = GetQuestPortraitTurnIn();
	if (questPortrait ~= 0) then
		local questPortraitMount = 0;
		local questPortraitModelSceneID = nil;
		local useCompactDescription = true;
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, 1, -42, useCompactDescription);
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
				MoneyFrame_Update(QuestFrame.dialog.MoneyFrame, money);
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

local function QuestFrameProgressPanel_SetupBG(self)
	local material, isDefaultMaterial = QuestFrame_GetMaterial();
	QuestFrame_SetMaterial(QuestFrameProgressPanel, material);
	if ( isDefaultMaterial ) then
		local theme = C_QuestLog.GetQuestDetailsTheme(GetQuestID());
		if ( theme and theme.background ) then
			self.Bg:SetAtlas(theme.background, true);
			return material;
		end
	end

	return material;
end

function QuestFrameProgressPanel_OnShow(self)
	local material, isDefaultMaterial = QuestFrame_GetMaterial();
	QuestFrameRewardPanel:Hide();
	QuestFrameDetailPanel:Hide();
	QuestFrameGreetingPanel:Hide();
	QuestFrame_HideQuestPortrait();
	QuestFrameProgressPanel_SetupBG(self);
	QuestProgressTitleText:SetText(GetTitleText());
	QuestFrame_SetTitleTextColor(QuestProgressTitleText, material);
	QuestProgressText:SetText(GetProgressText());
	QuestFrame_SetTextColor(QuestProgressText, material);
	QuestFrame_SetTitleTextColor(QuestProgressRequiredItemsText, material);

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

		local actualNumRequiredItems = 0;
		if not C_QuestOffer.GetHideRequiredItems() then
			-- Keep track of how many actual required items there are, in case we hide any of them.
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
			local requiredCurrencyInfo = C_QuestOffer.GetQuestRequiredCurrencyInfo(i);
			if requiredCurrencyInfo then
				SetItemButtonCount(requiredItem, requiredCurrencyInfo.requiredAmount);
				SetItemButtonTexture(requiredItem, requiredCurrencyInfo.texture);
				requiredItem:Show();
				_G[questItemName..buttonIndex.."Name"]:SetText(requiredCurrencyInfo.name);
			end
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
	QuestProgressScrollFrame.ScrollBar:ScrollToBegin();
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
			if QuestTextContrast.UseLightText() then
				questTitleButton:GetFontString():SetFixedColor(true);
				questTitleButton:GetFontString():SetTextColor(STONE_MATERIAL_TEXT_COLOR:GetRGB());
			else
				questTitleButton:GetFontString():SetFixedColor(false);
			end

			local activeQuestID = GetActiveQuestID(i);
			QuestUtil.ApplyQuestIconActiveToTextureForQuestID(questTitleButton.Icon, activeQuestID, isComplete);
			questTitleButton:SetHeight(math.max(questTitleButton:GetTextHeight() + 2, questTitleButton.Icon:GetHeight()));
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
			local isTrivial, frequency, isRepeatable, isLegendary, questID, isImportant, isMeta = GetAvailableQuestInfo(i - numActiveQuests);
			QuestUtil.ApplyQuestIconOfferToTextureForQuestID(questTitleButton.Icon, questID, isLegendary, frequency, isRepeatable, isImportant, isMeta);
			
			local title = GetAvailableTitle(i - numActiveQuests);
			if ( isTrivial ) then
				questTitleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, title);
				questTitleButton.Icon:SetVertexColor(0.5,0.5,0.5);
			else
				questTitleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title);
				questTitleButton.Icon:SetVertexColor(1,1,1);
			end
			if QuestTextContrast.UseLightText() then
				questTitleButton:GetFontString():SetFixedColor(true);
				questTitleButton:GetFontString():SetTextColor(STONE_MATERIAL_TEXT_COLOR:GetRGB());
			else
				questTitleButton:GetFontString():SetFixedColor(false);
			end
			questTitleButton:SetHeight(math.max(questTitleButton:GetTextHeight() + 2, questTitleButton.Icon:GetHeight()));
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
	QuestFrame.FriendshipStatusBar:Update();
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
		QuestObjectiveTracker:RemoveAutoQuestPopUp(GetQuestID());
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
	QuestNPCModelText:SetText(text or "");

	local descenderPadding = 5;
	QuestNPCModelTextScrollChildFrame:SetHeight(QuestNPCModelText:GetHeight() + descenderPadding);
end

function QuestFrame_ShowQuestPortrait(parentFrame, portraitDisplayID, mountPortraitDisplayID, modelSceneID, text, name, x, y, useCompactDescription)
	QuestModelScene:SetParent(parentFrame);
	QuestModelScene:SetFrameStrata("HIGH");
	QuestModelScene:SetFrameLevel(1000);
	QuestModelScene:ClearAllPoints();
	QuestModelScene:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y);
	QuestModelScene:ClearScene();
	QuestModelScene:TransitionToModelSceneID(modelSceneID or QUEST_FRAME_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
	QuestModelScene:Show();
	QuestFrame_UpdatePortraitText(text);

	if (useCompactDescription) then
		local compactDescriptionHeight = 165;
		QuestModelScene.ModelTextFrame:SetHeight(compactDescriptionHeight);
	else
		local defaultDescriptionHeight = 216;
		QuestModelScene.ModelTextFrame:SetHeight(defaultDescriptionHeight);
	end

	if (name and name ~= "") then
		QuestNPCModelNameText:Show();
		QuestNPCModelNameText:SetText(name);
	else
		QuestNPCModelNameText:Hide();
	end

	if (portraitDisplayID == -1) then
		local actor = QuestModelScene:GetPlayerActor("player");
		local sheathWeapons = false;
		actor:SetModelByUnit("player", sheathWeapons);
	else
		local mount, rider;
		local mountTag = "mount";
		local riderTag = "rider";

		if mountPortraitDisplayID > 0 then
			mount = QuestModelScene:GetActorByTag(mountTag);
			mount:SetModelByCreatureDisplayID(mountPortraitDisplayID);
		else
			-- these is no mount, so use the mount actor as the main actor for the rider
			riderTag = mountTag;
		end

		if portraitDisplayID > 0 then
			rider = QuestModelScene:GetActorByTag(riderTag);
			rider:SetModelByCreatureDisplayID(portraitDisplayID);
		end
		if mount and rider then
			local defaultMountAnimation = 91;
			local spellVisualKitID = 0;
			mount:AttachToMount(rider, defaultMountAnimation, spellVisualKitID);
		end
	end
end

function QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame)
	optPortraitOwnerCheckFrame = optPortraitOwnerCheckFrame or QuestModelScene:GetParent();
	if optPortraitOwnerCheckFrame == QuestModelScene:GetParent() then
		QuestModelScene:Hide();
		QuestModelScene:SetParent(nil);
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
	
	QuestDetailScrollFrame.ScrollBar:ScrollToBegin();

	local questPortrait, questPortraitText, questPortraitName, questPortraitMount, questPortraitModelSceneID = GetQuestPortraitGiver();
	if (questPortrait ~= 0) then
		local useCompactDescription = true;
		QuestFrame_ShowQuestPortrait(QuestFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, 1, -42, useCompactDescription);
	else
		QuestFrame_HideQuestPortrait();
	end
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
	local hasMaterial = material ~= "Parchment";
	frame.MaterialTopLeft:SetShown(hasMaterial);
	frame.MaterialTopRight:SetShown(hasMaterial);
	frame.MaterialBotLeft:SetShown(hasMaterial);
	frame.MaterialBotRight:SetShown(hasMaterial);

	if hasMaterial then
		frame.MaterialTopLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopLeft");
		frame.MaterialTopRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopRight");
		frame.MaterialBotLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotLeft");
		frame.MaterialBotRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotRight");
	end
	frame.Bg:SetAtlas(QuestTextContrast.GetDefaultBackgroundAtlas());
end

function QuestFrame_GetMaterial()
	local questTextContrastEnabled = QuestTextContrast.IsEnabled();
	local material = GetQuestBackgroundMaterial();
	if questTextContrastEnabled or not material then
		return "Parchment", not questTextContrastEnabled;
	end

	return material, false;
end

function QuestFrame_SetTitleTextColor(fontString, material)
	local temp, materialTitleTextColor = GetMaterialTextColors(material);
	if QuestTextContrast.UseLightText() then
		temp, materialTitleTextColor = GetMaterialTextColors("Stone");
	end
	fontString:SetTextColor(materialTitleTextColor[1], materialTitleTextColor[2], materialTitleTextColor[3]);
end

function QuestFrame_SetTextColor(fontString, material)
	local materialTextColor = GetMaterialTextColors(material);
	if QuestTextContrast.UseLightText() then
		materialTextColor = GetMaterialTextColors("Stone");
	end
	fontString:SetTextColor(materialTextColor[1], materialTextColor[2], materialTextColor[3]);
end