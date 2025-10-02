function ChatFrameUtil.InsertLink(text)
	if ( not text ) then
		return false;
	end

	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		local cursorPosition = MacroFrameText:GetCursorPosition();
		if (cursorPosition == 0 or strsub(MacroFrameText:GetText(), cursorPosition, cursorPosition) == "\n" ) then
			if ( item ) then
				if ( C_Item.GetItemSpell(text) ) then
					MacroFrameText:Insert(SLASH_USE1.." "..item.."\n");
				else
					MacroFrameText:Insert(SLASH_EQUIP1.." "..item.."\n");
				end
			else
				MacroFrameText:Insert(SLASH_CAST1.." "..text.."\n");
			end
		else
			MacroFrameText:Insert(item or text);
		end
		return true;
	end

	if ( ProfessionsFrame and ProfessionsFrame.CraftingPage.RecipeList.SearchBox:HasFocus() )  then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			ProfessionsFrame.CraftingPage.RecipeList.SearchBox:SetText(item);
			return true;
		end
	end
	if ( CommunitiesFrame and CommunitiesFrame.ChatEditBox:HasFocus() ) then
		CommunitiesFrame.ChatEditBox:Insert(text);
		return true;
	end

	local activeWindow = ChatFrameUtil.GetActiveWindow();
	if ( activeWindow ) then
		activeWindow:Insert(text);
		activeWindow:SetFocus();
		return true;
	end
	if ( AuctionHouseFrame and AuctionHouseFrame:IsVisible() ) then
		local item;
		if ( strfind(text, "battlepet:") ) then
			local petName = strmatch(text, "%[(.+)%]");
			item = petName;
		elseif ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			if ( AuctionHouseFrame:SetSearchText(item) ) then
				return true;
			end
		end
	end

	return false;
end

function ChatFrameUtil.DisplayLevelUp(chatFrame, oldLevel, newLevel, real)
	if real and oldLevel ~= 0 and newLevel ~= 0 then
		if newLevel > oldLevel then
			local chatLinkLevelToastsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ChatLinkLevelToastsDisabled) or C_PlayerInfo.IsPlayerNPERestricted();
			local levelstring = not chatLinkLevelToastsDisabled and format(LEVEL_UP, newLevel, newLevel) or format(LEVEL_UP_NO_LINK, newLevel);
			local info = ChatTypeInfo["SYSTEM"];
			chatFrame:AddMessage(levelstring, info.r, info.g, info.b, info.id);
		end
	end
end

function ChatFrameUtil.GetChannelShortcutName(index)
	if not tonumber(index) and type(index) == "string" then
		index = GetChannelName(index);
	end

	return C_ChatInfo.GetChannelShortcut(index);
end

function ChatFrameUtil.GetMentorChannelStatus(entityStatus, channelRuleSet)
	if entityStatus == Enum.PlayerMentorshipStatus.Mentor then
		local shouldShowGuideStatus = C_PlayerMentorship.IsActivePlayerConsideredNewcomer() or (IsActivePlayerGuide() and channelRuleSet == Enum.ChatChannelRuleset.Mentor);
		if shouldShowGuideStatus then
			return Enum.PlayerMentorshipStatus.Mentor;
		end
	elseif entityStatus == Enum.PlayerMentorshipStatus.Newcomer then
		if IsActivePlayerGuide() then
			return Enum.PlayerMentorshipStatus.Newcomer;
		end
	end

	return Enum.PlayerMentorshipStatus.None;
end

function ChatFrameUtil.ShowNewcomerGraduation(s)
	local localID = C_ChatInfo.GetGeneralChannelLocalID();
	local slashCmd;

	if localID then
		slashCmd = ChatFrameUtil.GetSlashCommandForChannelOpenChat(localID);
	else
		slashCmd = ("%s %s"):format(SLASH_JOIN1, C_ChatInfo.GetChannelShortcutForChannelID(C_ChatInfo.GetGeneralChannelID()));
	end

	ChatFrameUtil.DisplaySystemMessageInPrimary(s:format(slashCmd));
end

function ChatFrameUtil.CheckShowNewcomerGraduation(isFromGraduationEvent)
	local hasShownGraduation = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION);
	if not hasShownGraduation and isFromGraduationEvent then
		ChatFrameUtil.ShowNewcomerGraduation(NPEV2_CHAT_NEWCOMER_GRADUATION);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION, true);
	elseif hasShownGraduation and not isFromGraduationEvent and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION_REMINDER) then
		ChatFrameUtil.ShowNewcomerGraduation(NPEV2_CHAT_NEWCOMER_GRADUATION_REMINDER);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION_REMINDER, true);
	end
end

-- NOTE: The leave channel event happens before the channel info is removed from the client, so excludeChannels that you're leaving if you don't
-- want to count them.
function ChatFrameUtil.GetFirstChannelIDOfChannelMatchingRuleset(ruleset, excludeChannel)
	for i = 1, GetNumDisplayChannels() do
		local localID, _, active = select(4, GetChannelDisplayInfo(i));
		if active and localID and localID > 0 and localID ~= excludeChannel then
			if C_ChatInfo.GetChannelRuleset(localID) == ruleset then
				return localID;
			end
		end
	end

	return nil;
end

function ChatFrameUtil.HasNewcomerChannelEnabled(chatFrame)
	for i, channelID in ipairs(chatFrame.zoneChannelList) do
		if C_ChatInfo.GetChannelRulesetForChannelID(channelID) == Enum.ChatChannelRuleset.Mentor then
			return true;
		end
	end
	return false;
end

function ChatFrameUtil.GetNewcomerChatTarget(chatFrame)
	if IsActivePlayerNewcomer() then
		if ChatFrameUtil.HasNewcomerChannelEnabled(chatFrame) then
			local localID = ChatFrameUtil.GetFirstChannelIDOfChannelMatchingRuleset(Enum.ChatChannelRuleset.Mentor);
			if localID then
				return "CHANNEL", localID;
			end
		end
	end
end

function DoesActivePlayerHaveMentorStatus()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.IsActivePlayerConsideredNewcomer() or (C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) ~= Enum.PlayerMentorshipStatus.None);
end

function IsActivePlayerGuide()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) == Enum.PlayerMentorshipStatus.Mentor;
end

function IsActivePlayerNewcomer()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) == Enum.PlayerMentorshipStatus.Newcomer;
end
