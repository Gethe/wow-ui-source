function FCF_IsChatWindowIndexReserved(chatWindowIndex)
	return chatWindowIndex <= C_ChatInfo.GetNumReservedChatWindows();
end

function FCF_IsChatWindowIndexActive(chatWindowIndex)
	local shown = select(7, FCF_GetChatWindowInfo(chatWindowIndex));
	if shown then
		return true;
	end

	local chatFrame = FCF_GetChatFrameByID(chatWindowIndex);
	return (chatFrame and chatFrame.isDocked);
end

function FCF_IterateActiveChatWindows(callback)
	for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
		if ( FCF_IsChatWindowIndexActive(i) ) then
			local chatFrame = FCF_GetChatFrameByID(i);
			if callback(chatFrame, i) then
				break;
			end
		end
	end
end

function FCF_GetNextOpenChatWindowIndex()
	for i = C_ChatInfo.GetNumReservedChatWindows() + 1, Constants.ChatFrameConstants.MaxChatWindows do
		if ( not FCF_IsChatWindowIndexActive(i) ) then
			return i;
		end
	end

	return nil;
end

function FCF_CanOpenNewWindow()
	return FCF_GetNextOpenChatWindowIndex() ~= nil;
end

function AllowChatFramesToShow(chatFrame)
	-- This is InGame, and we always show while InGame. chatFrame is not referenced, only Glues.
	return true;
end

function FCFDockOverflow_CloseLists()
	local list = GENERAL_CHAT_DOCK.overflowButton.list;
	if ( list:IsShown() ) then
		list:Hide();
		return true;
	else
		return false;
	end
end

RegisterGameMenuEscHandler(GameMenuEscPriority.Menu, FCFDockOverflow_CloseLists);
