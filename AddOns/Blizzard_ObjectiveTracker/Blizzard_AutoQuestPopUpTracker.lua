
AUTO_QUEST_POPUP_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable();
AUTO_QUEST_POPUP_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_AUTO_QUEST_POPUP;
AUTO_QUEST_POPUP_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_QUEST + OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED;
AUTO_QUEST_POPUP_TRACKER_MODULE.blockTemplate = "AutoQuestPopUpBlockTemplate";
AUTO_QUEST_POPUP_TRACKER_MODULE.blockType = "ScrollFrame";
AUTO_QUEST_POPUP_TRACKER_MODULE.freeBlocks = { };
AUTO_QUEST_POPUP_TRACKER_MODULE.usedBlocks = { };
AUTO_QUEST_POPUP_TRACKER_MODULE.Header = ObjectiveTrackerFrame.BlocksFrame.QuestHeader;		-- shares Quest header
AUTO_QUEST_POPUP_TRACKER_MODULE.blockOffsetX = -39;
AUTO_QUEST_POPUP_TRACKER_MODULE.blockOffsetY = -4;

local questItems = { };

function AUTO_QUEST_POPUP_TRACKER_MODULE:OnFreeBlock(block)
	block.init = nil;
end

function AutoQuestPopupTracker_OnFinishSlide(block)
	local blockContents = block.ScrollChild;
	blockContents.Shine:Show();
	blockContents.IconShine:Show();
	blockContents.Shine.Flash:Play();
	blockContents.IconShine.Flash:Play();
	-- this may have scrolled something partially offscreen
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_STATIC);
end

local SLIDE_DATA = { startHeight = 0, endHeight = 68, duration = 0.4, onFinishFunc = AutoQuestPopupTracker_OnFinishSlide };

function AUTO_QUEST_POPUP_TRACKER_MODULE:Update()
	self:BeginLayout();

	if( SplashFrame:IsShown() ) then
		self:EndLayout();
		return;
	end

	for i = 1, GetNumAutoQuestPopUps() do
		local questID, popUpType = GetAutoQuestPopUp(i);
		if ( not C_QuestLog.IsQuestBounty(questID) ) then
			local questTitle = C_QuestLog.GetTitleForQuestID(questID);
			if ( questTitle and questTitle ~= "" ) then
				local block = self:GetBlock(questID);
				-- fixed height, just add the block right away
				block.height = 68;
				if ( ObjectiveTracker_AddBlock(block) ) then
					if ( not block.init ) then
						local blockContents = block.ScrollChild;
						if ( popUpType == "COMPLETE" ) then
							blockContents.QuestionMark:Show();
							blockContents.Exclamation:Hide();
							if ( C_QuestLog.IsQuestTask(questID) ) then
								blockContents.TopText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE_TASK);
							else
								blockContents.TopText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE);
							end
							blockContents.BottomText:Hide();
							blockContents.TopText:SetPoint("TOP", 0, -15);
							if (blockContents.QuestName:GetStringWidth() > blockContents.QuestName:GetWidth()) then
								blockContents.QuestName:SetPoint("TOP", 0, -25);
							else
								blockContents.QuestName:SetPoint("TOP", 0, -29);
							end
							block.popUpType = "COMPLETED";
						elseif ( popUpType == "OFFER" ) then
							local blockContents = block.ScrollChild;
							blockContents.QuestionMark:Hide();
							local itemID = questItems[questID];
							if ( itemID ) then
                                local texture = select(10, GetItemInfo(itemID));
                                blockContents.Exclamation:SetTexCoord(0.078125, 0.921875, 0.078125, 0.921875);
                                blockContents.Exclamation:SetSize(35, 35);
                                SetPortraitToTexture(blockContents.Exclamation, texture);
                            else
                                blockContents.Exclamation:SetTexture("Interface\\QuestFrame\\AutoQuest-Parts");
                                blockContents.Exclamation:SetTexCoord(0.13476563, 0.17187500, 0.01562500, 0.53125000);
                                blockContents.Exclamation:SetSize(19, 33);
                            end
							blockContents.Exclamation:Show();
							blockContents.TopText:SetText(QUEST_WATCH_POPUP_QUEST_DISCOVERED);
							blockContents.BottomText:Show();
							blockContents.BottomText:SetText(QUEST_WATCH_POPUP_CLICK_TO_VIEW);
							blockContents.TopText:SetPoint("TOP", 0, -9);
							blockContents.QuestName:SetPoint("TOP", 0, -20);
							blockContents.FlashFrame:Hide();
							block.popUpType = "OFFER";
						end
						blockContents.QuestName:SetText(questTitle);
						ObjectiveTracker_SlideBlock(block, SLIDE_DATA);
						block.init = true;
					end
					block:Show();
				else
					block.used = nil;
					break;
				end
			end
		end
	end
	self:EndLayout();
end

function AutoQuestPopupTracker_AddPopUp(questID, popUpType, itemID)
	if ( AddAutoQuestPopUp(questID, popUpType) ) then
		questItems[questID] = itemID;
		ObjectiveTracker_Expand();
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED, questID);
		PlaySound(SOUNDKIT.UI_AUTO_QUEST_COMPLETE);
		return true;
	end
	return false;
end

function AutoQuestPopupTracker_RemovePopUp(questID)
	RemoveAutoQuestPopUp(questID);
	if GetNumAutoQuestPopUps() == 0 then
		wipe(questItems);
	end
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
end

function AutoQuestPopUpTracker_OnMouseDown(block)
	if ( block.popUpType == "OFFER" ) then
		ShowQuestOffer(block.id);
	else
		ShowQuestComplete(block.id);
	end
	AutoQuestPopupTracker_RemovePopUp(block.id);
end