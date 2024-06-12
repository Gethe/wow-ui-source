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
	for i = 1, NUM_CHAT_WINDOWS do
		if ( FCF_IsChatWindowIndexActive(i) ) then
			local chatFrame = FCF_GetChatFrameByID(i);
			if callback(chatFrame, i) then
				break;
			end
		end
	end
end

function FCF_GetNextOpenChatWindowIndex()
	for i = C_ChatInfo.GetNumReservedChatWindows() + 1, NUM_CHAT_WINDOWS do
		if ( not FCF_IsChatWindowIndexActive(i) ) then
			return i;
		end
	end

	return nil;
end

function FCF_CanOpenNewWindow()
	return FCF_GetNextOpenChatWindowIndex() ~= nil;
end