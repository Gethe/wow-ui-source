local BNToasts = { };
local BNToastEvents = {
	showToastOnline = { "BN_FRIEND_ACCOUNT_ONLINE" },
	showToastOffline = { "BN_FRIEND_ACCOUNT_OFFLINE" },
	showToastBroadcast = { "BN_CUSTOM_MESSAGE_CHANGED" },
	showToastFriendRequest = { "BN_FRIEND_INVITE_ADDED", "BN_FRIEND_INVITE_LIST_INITIALIZED" },
	showToastConversation = { "BN_CHAT_CHANNEL_JOINED" },
};
local BN_TOAST_TYPE_ONLINE = 1;
local BN_TOAST_TYPE_OFFLINE = 2;
local BN_TOAST_TYPE_BROADCAST = 3;
local BN_TOAST_TYPE_PENDING_INVITES = 4;
local BN_TOAST_TYPE_NEW_INVITE = 5;
local BN_TOAST_TYPE_CONVERSATION = 6;
BN_TOAST_TOP_OFFSET = 40;
BN_TOAST_BOTTOM_OFFSET = -12;
BN_TOAST_RIGHT_OFFSET = -1;
BN_TOAST_LEFT_OFFSET = 1;
BN_TOAST_TOP_BUFFER = 20;	-- the minimum distance in pixels from the toast to the top edge of the screen
BN_TOAST_MAX_LINE_WIDTH = 196;

BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_SC2 = "S2";
BNET_CLIENT_D3 = "D3";

function BNet_OnLoad(self)
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("BN_BLOCK_FAILED_TOO_MANY");
end

function BNet_OnEvent(self, event, ...)
	if ( event == "BN_CONNECTED" ) then
		SynchronizeBNetStatus();
	elseif ( event == "BN_DISCONNECTED" ) then
		table.wipe(BNToasts);
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVar("conversationMode") == "popout" or GetCVar("conversationMode") == "popout_and_inline" ) then
			BNet_ReopenClosedConversations();
		end
		self:UnregisterEvent("VARIABLES_LOADED");
	elseif ( event == "BN_BLOCK_FAILED_TOO_MANY" ) then
		local blockType = ...;
		if ( blockType == "RID" ) then
			StaticPopup_Show("BN_BLOCK_FAILED_TOO_MANY_RID");
		elseif ( blockType == "CID" ) then
			StaticPopup_Show("BN_BLOCK_FAILED_TOO_MANY_CID");
		end
	end
end

function BNet_ReopenClosedConversations()
	for i=1, BNGetMaxNumConversations() do
		if ( BNGetConversationInfo(i) == "conversation" ) then
			if ( FCFManager_GetNumDedicatedFrames("BN_CONVERSATION", i) == 0 ) then
				FCF_OpenTemporaryWindow("BN_CONVERSATION", i);
			end
		end
	end
end

function BNet_GetPresenceID(name)
	return GetAutoCompletePresenceID(name);
end

-- BNET toast
function BNToastFrame_OnEvent(self, event, arg1)
	if ( event == "BN_FRIEND_ACCOUNT_ONLINE" ) then	
		BNToastFrame_AddToast(BN_TOAST_TYPE_ONLINE, arg1);
	elseif ( event == "BN_FRIEND_ACCOUNT_OFFLINE" ) then
		if ( BNet_ShouldProcessOfflineEvents() ) then
			BNToastFrame_AddToast(BN_TOAST_TYPE_OFFLINE, arg1);
		end
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		if ( arg1 ) then
			BNToastFrame_AddToast(BN_TOAST_TYPE_BROADCAST, arg1);
		end
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		BNToastFrame_AddToast(BN_TOAST_TYPE_NEW_INVITE);
	elseif ( event == "BN_CHAT_CHANNEL_JOINED" ) then
		BNToastFrame_AddToast(BN_TOAST_TYPE_CONVERSATION, arg1);
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		BNToastFrame_AddToast(BN_TOAST_TYPE_PENDING_INVITES, arg1);
	elseif( event == "VARIABLES_LOADED" ) then
		BNet_SetToastDuration(GetCVar("toastDuration"));
		if ( GetCVarBool("showToastWindow") ) then
			BNet_EnableToasts();
		end
	end
end

function BNet_EnableToasts()
	local frame = BNToastFrame;
	for cvar, events in pairs(BNToastEvents) do
		if ( GetCVarBool(cvar) ) then
			for _, event in pairs(events) do
				frame:RegisterEvent(event);
			end
		end
	end
end

function BNet_DisableToasts()
	local frame = BNToastFrame;
	frame:UnregisterAllEvents();
	table.wipe(BNToasts);
	frame:Hide();
end

function BNet_UpdateToastEvent(cvar, value)
	if ( GetCVarBool("showToastWindow") ) then
		local frame = BNToastFrame;
		local events = BNToastEvents[cvar];
		if ( value == "1" ) then
			for _, event in pairs(events) do
				frame:RegisterEvent(event);
			end
		else
			for _, event in pairs(events) do
				frame:UnregisterEvent(event);
			end
		end
	end
end

function BNet_SetToastDuration(duration)
	BNToastFrame.duration = duration;
end

function BNToastFrame_Show()
	local toastType = BNToasts[1].toastType;
	local toastData = BNToasts[1].toastData;
	tremove(BNToasts, 1);
	local topLine = BNToastFrameTopLine;
	local middleLine = BNToastFrameMiddleLine;
	local bottomLine = BNToastFrameBottomLine;
	if ( toastType == BN_TOAST_TYPE_NEW_INVITE ) then
		BNToastFrameIconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		topLine:Hide();
		middleLine:Hide();
		bottomLine:Hide();
		BNToastFrameDoubleLine:Show();
		BNToastFrameDoubleLine:SetText(BN_TOAST_NEW_INVITE);
	elseif ( toastType == BN_TOAST_TYPE_PENDING_INVITES ) then
		BNToastFrameIconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		topLine:Hide();
		middleLine:Hide();
		bottomLine:Hide();
		BNToastFrameDoubleLine:Show();
		BNToastFrameDoubleLine:SetFormattedText(BN_TOAST_PENDING_INVITES, toastData);
	elseif ( toastType == BN_TOAST_TYPE_ONLINE ) then
		local presenceID, presenceName = BNGetFriendInfoByID(toastData);
		-- don't display a toast if we didn't get the data in time
		if ( not presenceName ) then
			return;
		end
		
		local _, toonName, client = BNGetToonInfo(presenceID);
		if (toonName and toonName ~= "") then
			toonName = BNet_GetClientEmbeddedTexture(client, 14, 14, 0, -1)..toonName;
			middleLine:SetFormattedText(toonName);
			middleLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
			middleLine:Show();
		else
			middleLine:Hide();
		end
		
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetText(presenceName);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText(BN_TOAST_ONLINE);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		BNToastFrameDoubleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_OFFLINE ) then
		local presenceID, presenceName = BNGetFriendInfoByID(toastData);
		-- don't display a toast if we didn't get the data in time
		if ( not presenceName ) then
			return;
		end
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetFormattedText(presenceName);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText(BN_TOAST_OFFLINE);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		BNToastFrameDoubleLine:Hide();
		middleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_CONVERSATION ) then
		BNToastFrameIconTexture:SetTexCoord(0.5, 0.75, 0, 0.5);
		topLine:Show();
		topLine:SetText(BN_TOAST_CONVERSATION);
		topLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText("["..string.format(CONVERSATION_NAME, MAX_WOW_CHAT_CHANNELS + toastData).."]");
		bottomLine:SetTextColor(ChatTypeInfo["BN_CONVERSATION"].r, ChatTypeInfo["BN_CONVERSATION"].g, ChatTypeInfo["BN_CONVERSATION"].b);
		BNToastFrameDoubleLine:Hide();
		middleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_BROADCAST ) then
		local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText = BNGetFriendInfoByID(toastData);
		if ( not messageText or messageText == "" ) then
			return;
		end	
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0, 0.5);
		topLine:Show();
		topLine:SetText(presenceName);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetWidth(0);
		bottomLine:SetText(messageText);
		if ( bottomLine:GetWidth() > BN_TOAST_MAX_LINE_WIDTH ) then
			bottomLine:SetWidth(BN_TOAST_MAX_LINE_WIDTH);
			BNToastFrame.tooltip = messageText;
		end
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		BNToastFrameDoubleLine:Hide();
		middleLine:Hide();
	end
	
	if (middleLine:IsShown() and bottomLine:IsShown()) then
		bottomLine:SetPoint("TOPLEFT", middleLine, "BOTTOMLEFT", 0, -4);
		BNToastFrame:SetHeight(63);
	else
		bottomLine:SetPoint("TOPLEFT", topLine, "BOTTOMLEFT", 0, -4);
		BNToastFrame:SetHeight(50);
	end

	local frame = BNToastFrame;
	BNToastFrame_UpdateAnchor(true);
	frame:Show();
	PlaySoundKitID(18019);
	frame.toastType = toastType;
	frame.toastData = toastData;
	frame.animIn:Play();
	BNToastFrameGlowFrame.glow:Show();
	BNToastFrameGlowFrame.glow.animIn:Play();
	frame.waitAndAnimOut:Stop();	--Just in case it's already animating out, but we want to reinstate it.
	if ( frame:IsMouseOver() ) then
		frame.waitAndAnimOut.animOut:SetStartDelay(1);
	else
		frame.waitAndAnimOut.animOut:SetStartDelay(frame.duration);
		frame.waitAndAnimOut:Play();
	end
end

function BNToastFrame_Close()
	BNToastFrame.tooltip = nil;
	BNToastFrame:Hide();
end

function BNToastFrame_OnUpdate()
	if ( next(BNToasts) and not BNToastFrame:IsShown() ) then
		BNToastFrame_Show();
	end
end

function BNToastFrame_AddToast(toastType, toastData)
	local toast = { };
	toast.toastType = toastType;
	toast.toastData = toastData;
	BNToastFrame_RemoveToast(toastType, toastData);
	tinsert(BNToasts, toast);
end

function BNToastFrame_RemoveToast(toastType, toastData)
	for i = 1, #BNToasts do
		if ( BNToasts[i].toastType == toastType and BNToasts[i].toastData == toastData ) then
			tremove(BNToasts, i);
			break;
		end
	end
end

function BNToastFrame_UpdateAnchor(forceAnchor)
	local chatFrame = DEFAULT_CHAT_FRAME;
	local toastFrame = BNToastFrame;
	local offscreen = chatFrame.buttonFrame:GetTop() + BNToastFrame:GetHeight() + BN_TOAST_TOP_OFFSET + BN_TOAST_TOP_BUFFER > GetScreenHeight();

	if ( chatFrame.buttonSide ~= toastFrame.buttonSide ) then
		forceAnchor = true;
	end
	if ( offscreen and toastFrame.topSide ) then
		forceAnchor = true;
		toastFrame.topSide = false;
	elseif ( not offscreen and not toastFrame.topSide ) then
		forceAnchor = true;
		toastFrame.topSide = true;
	end
	if ( forceAnchor ) then
		toastFrame:ClearAllPoints();
		toastFrame.buttonSide = chatFrame.buttonSide;
		local xOffset = BN_TOAST_LEFT_OFFSET;
		if ( toastFrame.buttonSide == "right" ) then
			xOffset = BN_TOAST_RIGHT_OFFSET;
		end
		if ( toastFrame.topSide ) then
			toastFrame:SetPoint("BOTTOM"..toastFrame.buttonSide, chatFrame.buttonFrame, "TOP"..toastFrame.buttonSide, xOffset, BN_TOAST_TOP_OFFSET);
		else
			local yOffset = BN_TOAST_BOTTOM_OFFSET;
			if ( GetCVar("chatStyle") == "im" ) then
				yOffset = yOffset - 20;
			end
			toastFrame:SetPoint("TOP"..toastFrame.buttonSide, chatFrame.buttonFrame, "BOTTOM"..toastFrame.buttonSide, xOffset, yOffset);
		end
	end
end

function BNToastFrame_OnClick(self)	
	-- hide the tooltip if necessary
	if ( BNToastFrame.tooltip and GameTooltip:GetOwner() == BNToastFrame ) then
		GameTooltip:Hide();
	end
	BNToastFrame_Close();
	local toastType = BNToastFrame.toastType;
	local toastData = BNToastFrame.toastData;
	if ( toastType == BN_TOAST_TYPE_NEW_INVITE or toastType == BN_TOAST_TYPE_PENDING_INVITES ) then
		if ( not FriendsFrame:IsShown() ) then
			ToggleFriendsFrame(1);
		end
		FriendsTabHeaderTab3:Click();
	elseif ( toastType == BN_TOAST_TYPE_CONVERSATION ) then
		-- clicking the toast should switch to the chat tab for this conversation, or if not found (usually if using in-line option) switch to any tab displaying conversations
		local chatFrame = DEFAULT_CHAT_FRAME;
		for _, frameName in pairs(CHAT_FRAMES) do
			local frame = _G[frameName];
			local channel = tostring(toastData);
			if ( frame.chatType == "BN_CONVERSATION" and frame.chatTarget == channel ) then
				chatFrame = frame;
				break;
			else
				if ( frame:IsEventRegistered("CHAT_MSG_BN_CONVERSATION") ) then
					chatFrame = frame;
				end
			end
		end
		_G[chatFrame:GetName().."Tab"]:Click();
		--ChatFrame_OpenChat("/"..(toastData + MAX_WOW_CHAT_CHANNELS), chatFrame);
	elseif ( toastType == BN_TOAST_TYPE_ONLINE or toastType == BN_TOAST_TYPE_BROADCAST ) then
		local presenceID, presenceName = BNGetFriendInfoByID(toastData);
		if ( presenceName ) then	--This player may have been removed from our friends list, so we may not have a name.
			ChatFrame_SendSmartTell(presenceName);
		end
	end
end

function SynchronizeBNetStatus()
	if ( BNFeaturesEnabledAndConnected() ) then
		local wowAFK = (IsChatAFK());
		local wowDND = (IsChatDND());
		local _, _, _, _, bnetAFK, bnetDND = BNGetInfo();
		if ( wowAFK ~= bnetAFK ) then
			BNSetAFK(wowAFK);
		end
		if ( wowDND ~= bnetDND ) then
			BNSetDND(wowDND);
		end
	end
end

function BNet_InitiateReport(presenceID, reportType)
	local reportFrame = BNetReportFrame;
	if ( reportFrame:IsShown() ) then
		StaticPopupSpecial_Hide(reportFrame);
	end
	CloseDropDownMenus();
	-- set up
	local fullName;
	if ( not presenceID ) then
		-- invite
		presenceID, fullName = BNGetFriendInviteInfo(UIDROPDOWNMENU_MENU_VALUE);
	else
		local _, presenceName, battleTag, isBattleTagPresence, toonName = BNGetFriendInfoByID(presenceID);
		if ( presenceName ) then
			if ( toonName ) then
				fullName = presenceName.." ("..toonName..")";
			else
				fullName = presenceName;
			end
		else
			local _, toonName = BNGetToonInfo(presenceID);
			fullName = toonName;
		end
	end
	reportFrame.presenceID = presenceID;
	reportFrame.type = reportType;
	reportFrame.name = fullName;
	BNetReportFrameCommentBox:SetText("");
	
	if ( reportType == "SPAM" or reportType == "NAME" ) then
		StaticPopup_Show("CONFIRM_BNET_REPORT", format(_G["BNET_REPORT_CONFIRM_"..reportType], fullName));
	elseif ( reportType == "ABUSE" ) then
		BNetReportFrameName:SetText(fullName);
		StaticPopupSpecial_Show(reportFrame);
	end
end

function BNet_ConfirmReport()
	StaticPopup_Show("CONFIRM_BNET_REPORT", format(_G["BNET_REPORT_CONFIRM_"..BNetReportFrame.type], BNetReportFrame.name));
end

function BNet_SendReport()
	local reportFrame = BNetReportFrame;
	local comments = BNetReportFrameCommentBox:GetText();
	BNReportPlayer(reportFrame.presenceID, reportFrame.type, comments);
end



--This is used to track time played for an alert in Korea
--This is used to track time played for an alert in Korea
--This is used to track time played for an alert in Korea


function TimeAlert_OnEvent(self, event, arg1)
	if( not TimeAlertFrame:IsShown() ) then
		TimeAlert_Start(arg1);
	end
end

function TimeAlert_Start(time)
	TimeAlertFrame:Show();
	TimeAlertFrame.animIn:Play();
	TimeAlertFrame:SetScript("OnUpdate", TimeAlert_OnUpdate);
	TimeAlertFrame.timer = time / 1000;

	BNToastFrame_UpdateAnchor(true);
end


function TimeAlert_Close()
	TimeAlertFrame:SetScript("OnUpdate", nil);
	TimeAlertFrame:Hide();
end

function TimeAlert_OnUpdate(self, elapsed)
	TimeAlertFrame.timer = TimeAlertFrame.timer - elapsed;
	if ( TimeAlertFrame.timer < 0 ) then
		TimeAlertFrame.animOut:Play();
		TimeAlertFrame.timer = 1000000;
	end
	
	TimeAlertFrameText:SetFormattedText(TIME_PLAYED_ALERT, SecondsToTime(GetSessionTime(), true, true));
	TimeAlertFrame:SetHeight(TimeAlertFrameBG:GetHeight());
	
	BNToastFrame_UpdateAnchor();
	if ( BNToastFrame.topSide ) then
		if ( BNToastFrame:IsShown() ) then
			TimeAlertFrame:SetPoint("BOTTOM", BNToastFrame, "TOP", 0, 10);
		else
			TimeAlertFrame:SetPoint("BOTTOM", BNToastFrame, "BOTTOM", 0, 0);
		end
	else
		if ( BNToastFrame:IsShown() ) then
			TimeAlertFrame:SetPoint("TOP", BNToastFrame, "BOTTOM", 0, -10);
		else
			TimeAlertFrame:SetPoint("TOP", BNToastFrame, "TOP", 0, 0);
		end
	end
end

function BNet_ShouldProcessOfflineEvents()
	-- can process if we're not logging out
	if ( not IsLoggingOut() ) then
		return true;
	end
	-- if the logout timer is up, we should only process if there is more than 1 second left
	local frameName = StaticPopup_Visible("CAMP");
	if ( frameName ) then
		if ( _G[frameName].timeleft ) > 1 then
			return true;
		else
			return false;
		end
	end
	-- ugh, why are there 2 of these?
	frameName = StaticPopup_Visible("QUIT");
	if ( frameName ) then
		if ( _G[frameName].timeleft ) > 1 then
			return true;
		else
			return false;
		end
	end
	-- no logout timers up, must be instant logout
	return false;
end

function BNet_GetClientEmbeddedTexture(client, width, height, xOffset, yOffset)
	if ( not height ) then
		height = width;
		xOffset = 0;
		yOffset = 0;
	end
	local textureString;
	if ( client == BNET_CLIENT_WOW ) then
		textureString = "WOW";
	elseif ( client == BNET_CLIENT_SC2 ) then
		textureString = "SC2";
	elseif ( client == BNET_CLIENT_D3 ) then
		textureString = "D3";
	else
		textureString = "Battlenet";
	end
	return string.format("|TInterface\\ChatFrame\\UI-ChatIcon-%s:%d:%d:%d:%d|t", textureString, width, height, xOffset, yOffset);
end

function BNet_GetClientTexture(client)
	if ( client == BNET_CLIENT_WOW ) then
		return "Interface\\FriendsFrame\\Battlenet-WoWicon";
	elseif ( client == BNET_CLIENT_SC2 ) then
		return "Interface\\FriendsFrame\\Battlenet-Sc2icon";
	elseif ( client == BNET_CLIENT_D3 ) then
		return "Interface\\FriendsFrame\\Battlenet-D3icon";
	else
		return "Interface\\FriendsFrame\\Battlenet-Battleneticon";
	end
end