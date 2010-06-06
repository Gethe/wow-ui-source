local presenceIDs = {};
presenceIDs_debug = presenceIDs;	--Use BNet_GetPresenceID.

local BNToasts = { };
local BN_TOAST_TYPE_ONLINE = 1;
local BN_TOAST_TYPE_OFFLINE = 2;
local BN_TOAST_TYPE_BROADCAST = 3;
local BN_TOAST_TYPE_OLD_INVITES = 4;
local BN_TOAST_TYPE_NEW_INVITE = 5;
local BN_TOAST_TYPE_CONVERSATION = 6;
BN_TOAST_TOP_OFFSET = 34;
BN_TOAST_BOTTOM_OFFSET = -12;
BN_TOAST_RIGHT_OFFSET = 4;
BN_TOAST_LEFT_OFFSET = -4;
BN_TOAST_TOP_BUFFER = 20;	-- the minimum distance in pixels from the toast to the top edge of the screen
BN_TOAST_MAX_LINE_WIDTH = 196;
	
function BNet_OnLoad(self)
	self:RegisterEvent("BN_TOON_NAME_UPDATED");
	self:RegisterEvent("BN_NEW_PRESENCE");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	-- for toasts cvar
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	--DEBUG FIXME
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
	BNet_PopulateAllFriends();
end

function BNet_OnEvent(self, event, ...)
	if ( event == "BN_TOON_NAME_UPDATED" ) then
		local presenceID, name = ...;
		BNet_AddPresence(presenceID, name);
	elseif ( event == "BN_NEW_PRESENCE" ) then
		local presenceID, name = ...;
		BNet_AddPresence(presenceID, name);
	elseif ( event == "BN_FRIEND_INFO_CHANGED" ) then --DEBUG FIXME
		local index = ...;
		if ( index ) then
			local presenceID, givenName, surName = BNGetFriendInfo(index);
			BNet_AddPresence(presenceID, givenName.." "..surName);
		end
	elseif ( event == "BN_FRIEND_ACCOUNT_ONLINE" ) then	
		local presenceID = ...;
		BNToastFrame_AddToast(BN_TOAST_TYPE_ONLINE, presenceID);
	elseif ( event == "BN_FRIEND_ACCOUNT_OFFLINE" ) then
		local presenceID = ...;
		BNToastFrame_AddToast(BN_TOAST_TYPE_OFFLINE, presenceID);
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		local presenceID = ...;
		if ( presenceID ) then
			BNToastFrame_AddToast(BN_TOAST_TYPE_BROADCAST, presenceID);
		end
	elseif ( event == "BN_CHAT_CHANNEL_JOINED" ) then
		local channel = ...;
		BNToastFrame_AddToast(BN_TOAST_TYPE_CONVERSATION, channel);
	elseif ( event == "BN_CHAT_CHANNEL_LEFT" ) then
		local channel = ...;
		BNToastFrame_RemoveToast(BN_TOAST_TYPE_CONVERSATION, channel);	
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		BNToastFrame_AddToast(BN_TOAST_TYPE_NEW_INVITE);
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		local count = ...;
		BNToastFrame_AddToast(presenceID, BN_TOAST_TYPE_OLD_INVITES, count);
	elseif ( event == "BN_CONNECTED" ) then
		SynchronizeBNetStatus();
	elseif ( event == "BN_DISCONNECTED" ) then
		table.wipe(BNToasts);
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("battlenetToasts") ) then
			BNet_EnableToasts(self);
		end
	elseif (event == "CVAR_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 == "SHOW_BATTLENET_TOASTS" ) then
			if ( GetCVarBool("battlenetToasts") ) then
				BNet_EnableToasts(self);
			else
				BNet_DisableToasts(self);
			end
		end
	end
end

function BNet_AddPresence(presenceID, name)
	--print(format("Adding Presence; ID - %d, Name - %s", presenceID, name));
	presenceIDs[strlower(name)] = presenceID;
end

function BNet_GetPresenceID(name)
	return presenceIDs[strlower(name)];
end

--DEBUG FIXME
function BNet_PopulateAllFriends()
	local numFriends = BNGetNumFriends();
	for i=1, numFriends do
		local presenceID, givenName, surName = BNGetFriendInfo(i);
		if ( givenName and surName ) then
			BNet_AddPresence(presenceID, givenName.." "..surName);
		end
	end
end

-- BNET toast
function BNet_EnableToasts(self)
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
	self:RegisterEvent("BN_CUSTOM_MESSAGE_CHANGED");
	self:RegisterEvent("BN_FRIEND_INVITE_ADDED");
	self:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED");
end

function BNet_DisableToasts(self)
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
	self:UnregisterEvent("BN_CUSTOM_MESSAGE_CHANGED");
	self:UnregisterEvent("BN_FRIEND_INVITE_ADDED");
	self:UnregisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED");
	table.wipe(BNToasts);
	BNToastFrame:Hide();
end

function BNToastFrame_Show()
	local toastType = BNToasts[1].toastType;
	local toastData = BNToasts[1].toastData;
	tremove(BNToasts, 1);
	local topLine = BNToastFrameTopLine;
	local bottomLine = BNToastFrameBottomLine;
	if ( toastType == BN_TOAST_TYPE_NEW_INVITE ) then
		BNToastFrameIconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		topLine:Hide();
		bottomLine:Hide();
		BNToastFrameDoubleLine:Show();
		BNToastFrameDoubleLine:SetText(BN_TOAST_NEW_INVITE);
	elseif ( toastType == BN_TOAST_TYPE_OLD_INVITES ) then
		BNToastFrameIconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		topLine:Hide();
		bottomLine:Hide();
		BNToastFrameDoubleLine:Show();
		BNToastFrameDoubleLine:SetFormattedText(BN_TOAST_OLD_INVITES, toastData);
	elseif ( toastType == BN_TOAST_TYPE_ONLINE ) then
		local presenceID, givenName, surname = BNGetFriendInfoByID(toastData);
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetFormattedText(BATTLENET_NAME_FORMAT, givenName, surname);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText(BN_TOAST_ONLINE);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		BNToastFrameDoubleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_OFFLINE ) then
		local presenceID, givenName, surname = BNGetFriendInfoByID(toastData);
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetFormattedText(BATTLENET_NAME_FORMAT, givenName, surname);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText(BN_TOAST_OFFLINE);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		BNToastFrameDoubleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_CONVERSATION ) then
		BNToastFrameIconTexture:SetTexCoord(0.5, 0.75, 0, 0.5);
		topLine:Show();
		topLine:SetText(BN_TOAST_CONVERSATION);
		topLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText("["..string.format(CONVERSATION_NAME, MAX_WOW_CHAT_CHANNELS + toastData).."]");
		bottomLine:SetTextColor(ChatTypeInfo["BN_CONVERSATION"].r, ChatTypeInfo["BN_CONVERSATION"].g, ChatTypeInfo["BN_CONVERSATION"].b);
		BNToastFrameDoubleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_BROADCAST ) then
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText = BNGetFriendInfoByID(toastData);
		if ( not messageText or messageText == "" ) then
			return;
		end	
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0, 0.5);
		topLine:Show();
		topLine:SetFormattedText(BATTLENET_NAME_FORMAT, givenName, surname);
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
	end

	local frame = BNToastFrame;
	BNToastFrame_UpdateAnchor(true);
	frame:Show();
	frame.toastType = toastType;
	frame.toastData = toastData;
	frame.animIn:Play();
	BNToastFrameGlowFrame.glow.animIn:Play();
	frame.waitAndAnimOut:Stop();	--Just in case it's already animating out, but we want to reinstate it.
	if ( frame:IsMouseOver() ) then
		frame.waitAndAnimOut.animOut:SetStartDelay(1);
	else
		frame.waitAndAnimOut.animOut:SetStartDelay(4.05);
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
			toastFrame:SetPoint("TOP"..toastFrame.buttonSide, chatFrame.buttonFrame, "BOTTOM"..toastFrame.buttonSide, xOffset, BN_TOAST_BOTTOM_OFFSET);
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
	if ( toastType == BN_TOAST_TYPE_NEW_INVITE or toastType == BN_TOAST_TYPE_OLD_INVITES ) then
		ToggleFriendsFrame(1);
		if ( BNGetNumFriendInvites() > 0 ) then
			FriendsTabHeaderTab3:Click();
		end	
	elseif ( toastType == BN_TOAST_TYPE_CONVERSATION ) then
		ChatFrame_OpenChat("/"..(toastData + MAX_WOW_CHAT_CHANNELS), DEFAULT_CHAT_FRAME);
	elseif ( toastType == BN_TOAST_TYPE_ONLINE or toastType == BN_TOAST_TYPE_BROADCAST ) then
		local presenceID, givenName, surname = BNGetFriendInfoByID(toastData);
		ChatFrame_SendTell(string.format(BATTLENET_NAME_FORMAT, givenName, surname));
	end
end

function SynchronizeBNetStatus()
	if ( BNConnected() ) then
		local wowAFK = (UnitIsAFK("player") == 1);
		local wowDND = (UnitIsDND("player") == 1);
		local _, _, _, bnetAFK, bnetDND = BNGetInfo();
		if ( wowAFK ~= bnetAFK ) then
			BNSetAFK(wowAFK);
		end
		if ( wowDND ~= bnetDND ) then
			BNSetDND(wowDND);
		end
	end
end