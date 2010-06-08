-- CHAT PROTOTYPE STUFF
SELECTED_DOCK_FRAME = nil;
DOCKED_CHAT_FRAMES = {};
DOCK_COPY = {};

MOVING_CHATFRAME = nil;

CHAT_TAB_SHOW_DELAY = 0.2;
CHAT_TAB_HIDE_DELAY = 1;
CHAT_FRAME_FADE_TIME = 0.15;
CHAT_FRAME_FADE_OUT_TIME = 2.0;
CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0.2;

CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1.0;
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0.4;
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1.0;
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1.0;
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.6;
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.2;

DEFAULT_CHATFRAME_ALPHA = 0.25;
DEFAULT_CHATFRAME_COLOR = {r = 0, g = 0, b = 0};

CHAT_FRAME_NORMAL_MIN_HEIGHT = 120;
CHAT_FRAME_BIGGER_MIN_HEIGHT = 147;
CHAT_FRAME_MIN_WIDTH = 296;

CURRENT_CHAT_FRAME_ID = nil;

CHAT_FRAME_TEXTURES = {
	"Background",
	"TopLeftTexture",
	"BottomLeftTexture",
	"TopRightTexture",
	"BottomRightTexture",
	"LeftTexture",
	"RightTexture",
	"BottomTexture",
	"TopTexture",
	--"ResizeButton",
	
	"ButtonFrameBackground",
	"ButtonFrameTopLeftTexture",
	"ButtonFrameBottomLeftTexture",
	"ButtonFrameTopRightTexture",
	"ButtonFrameBottomRightTexture",
	"ButtonFrameLeftTexture",
	"ButtonFrameRightTexture",
	"ButtonFrameBottomTexture",
	"ButtonFrameTopTexture",
}

CHAT_FRAMES = {};

function FloatingChatFrame_OnLoad(self)
	--IMPORTANT NOTE: This function isn't run by ChatFrame1.
	tinsert(CHAT_FRAMES, self:GetName());
	
	FCF_SetTabPosition(self, 0);
	FloatingChatFrame_Update(self:GetID());
	
	FCFTab_UpdateColors(_G[self:GetName().."Tab"], true);
	self:SetClampRectInsets(-35, 35, 26, -50);
	
	local chatTab = _G[self:GetName().."Tab"];
	chatTab.mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA;
	chatTab.noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA;
end

function FloatingChatFrame_OnEvent(self, event, ...)
	if ( (event == "UPDATE_CHAT_WINDOWS") or (event == "UPDATE_FLOATING_CHAT_WINDOWS") ) then
		FloatingChatFrame_Update(self:GetID(), 1);
		self.isInitialized = 1;
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		local chatType, r, g, b = ...;
		if ( self.isTemporary and self.chatType == chatType ) then
			local tab = _G[self:GetName().."Tab"];
			tab.selectedColorTable.r, tab.selectedColorTable.g, tab.selectedColorTable.b = r, g, b;
			FCFTab_UpdateColors(tab, not self.isDocked or self == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));
		end
	end
end

function FloatingChatFrame_OnMouseScroll(self, delta)
	if ( delta > 0 ) then
		self:ScrollUp();
	else
		self:ScrollDown();
	end
end

function FCF_GetChatWindowInfo(id)
	if ( id > NUM_CHAT_WINDOWS ) then
		local frame = _G["ChatFrame"..id];
		local tab = _G["ChatFrame"..id.."Tab"];
		local background = _G["ChatFrame"..id.."Background"];
		
		if ( frame and tab and background ) then
			local r, g, b, a = background:GetVertexColor();
			
			return tab:GetText(), select(2, frame:GetFont()), r, g, b, a, frame:IsShown(), frame.isLocked, frame.isDocked, frame.isUninteractable;
			--This is a temporary chat window. Pass this to whatever handles those options.
		end
	else
		return GetChatWindowInfo(id);
	end
end

function FCF_CopyChatSettings(copyTo, copyFrom)
	local name, fontSize, r, g, b, a, shown, locked, docked, uninteractable = FCF_GetChatWindowInfo(copyFrom:GetID());
	FCF_SetWindowColor(copyTo, r, g, b, 1);
	FCF_SetWindowAlpha(copyTo, a, 1);
	--If we're copying to a docked window, we don't want to copy locked.
	if ( not copyTo.isDocked ) then
		FCF_SetLocked(copyTo, locked);
	end
	FCF_SetUninteractable(copyTo, uninteractable);
	FCF_SetChatWindowFontSize(nil, copyTo, fontSize);
end

function FloatingChatFrame_Update(id, onUpdateEvent)
	local chatFrame = _G["ChatFrame"..id];
	local chatTab = _G["ChatFrame"..id.."Tab"];
	
	local name, fontSize, r, g, b, a, shown, locked, docked, uninteractable = FCF_GetChatWindowInfo(id);
	
	-- Set Tab Name
	FCF_SetWindowName(chatFrame, name, 1)

	if ( onUpdateEvent ) then
		-- Set Frame Color and Alpha
		FCF_SetWindowColor(chatFrame, r, g, b, 1);
		FCF_SetWindowAlpha(chatFrame, a, 1);
		FCF_SetLocked(chatFrame, locked);
		FCF_SetUninteractable(chatFrame, uninteractable);
	end

	if ( shown ) then
		if ( not chatFrame.minimized ) then
			chatFrame:Show();
		end
		FCF_SetTabPosition(chatFrame, 0);
	else
		if ( not chatFrame.isDocked ) then
			chatFrame:Hide();
			chatTab:Hide();
		end
	end
	
	if ( docked ) then
		FCF_DockFrame(chatFrame, docked, (id == 1));
	else
		if ( shown ) then
			FCF_UnDockFrame(chatFrame);
			if ( not chatFrame.minimized ) then
				chatTab:Show();
			end
		else
			FCF_Close(chatFrame);
		end
	end
	
	if ( not chatFrame.isTemporary and (chatFrame == DEFAULT_CHAT_FRAME or not chatFrame.isDocked)) then
		FCF_RestorePositionAndDimensions(chatFrame);
	end

	FCF_UpdateButtonSide(chatFrame);
end

-- Channel Dropdown
function FCFOptionsDropDown_OnLoad(self)
	CURRENT_CHAT_FRAME_ID = self:GetParent():GetID();
	UIDropDownMenu_Initialize(self, FCFOptionsDropDown_Initialize, "MENU");
	UIDropDownMenu_SetButtonWidth(self, 50);
	UIDropDownMenu_SetWidth(self, 50);
end

function FCFOptionsDropDown_Initialize(dropDown)
	-- Window preferences
	local name, fontSize, r, g, b, a, shown = FCF_GetChatWindowInfo(FCF_GetCurrentChatFrameID());
	local info;

	local chatFrame = FCF_GetCurrentChatFrame();
	local isTemporary = chatFrame and chatFrame.isTemporary;
	
	-- If level 2
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		-- If this is the font size menu then create dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == FONT_SIZE ) then
			-- Add the font heights from the font height table
			local value;
			for i=1, #CHAT_FONT_HEIGHTS do
				value = CHAT_FONT_HEIGHTS[i];
				info = UIDropDownMenu_CreateInfo();
				info.text = format(FONT_SIZE_TEMPLATE, value);
				info.value = value;
				info.func = FCF_SetChatWindowFontSize;

				local fontFile, fontHeight, fontFlags = FCF_GetCurrentChatFrame():GetFont();
				if ( value == floor(fontHeight+0.5) ) then
					info.checked = 1;
				end

				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			return;
		end
		return;
	end
	-- Window options
	info = UIDropDownMenu_CreateInfo();
	if ( FCF_GetCurrentChatFrame(dropDown) and FCF_GetCurrentChatFrame(dropDown).isLocked ) then
		info.text = UNLOCK_WINDOW;
	else
		info.text = LOCK_WINDOW;
	end
	info.func = FCF_ToggleLock;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	--Add Uninteractable button
	info = UIDropDownMenu_CreateInfo();
	if ( FCF_GetCurrentChatFrame(dropDown) and FCF_GetCurrentChatFrame(dropDown).isUninteractable) then
		info.text = MAKE_INTERACTABLE;
	else
		info.text = MAKE_UNINTERACTABLE;
	end
	info.func = FCF_ToggleUninteractable;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	if ( not isTemporary ) then
		-- Add name button
		info = UIDropDownMenu_CreateInfo();
		info.text = RENAME_CHAT_WINDOW;
		info.func = FCF_RenameChatWindow_Popup;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
	
	if ( chatFrame == DEFAULT_CHAT_FRAME ) then
		-- Create new chat window
		info = UIDropDownMenu_CreateInfo();
		info.text = NEW_CHAT_WINDOW;
		info.func = FCF_NewChatWindow;
		info.notCheckable = 1;
		if (FCF_GetNumActiveChatFrames() == NUM_CHAT_WINDOWS ) then
			info.disabled = 1;
		end
		UIDropDownMenu_AddButton(info);

		-- Reset Chat windows to default
		info = UIDropDownMenu_CreateInfo();
		info.text = RESET_ALL_WINDOWS;
		info.func = FCF_ResetAllWindows;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end

	-- Close current chat window
	if ( chatFrame and shown and (chatFrame ~= DEFAULT_CHAT_FRAME and not IsCombatLog(chatFrame)) ) then
		if ( not chatFrame.isTemporary ) then
			info = UIDropDownMenu_CreateInfo();
			info.text = CLOSE_CHAT_WINDOW;
			info.func = FCF_PopInWindow;
			info.arg1 = FCF_GetCurrentChatFrame(dropDown);
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
		elseif ( chatFrame.isTemporary and (chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER") ) then
			info = UIDropDownMenu_CreateInfo();
			info.text = CLOSE_CHAT_WHISPER_WINDOW;
			info.func = FCF_PopInWindow;
			info.arg1 = FCF_GetCurrentChatFrame(dropDown);
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
		elseif ( chatFrame.isTemporary and (chatFrame.chatType == "BN_CONVERSATION" ) ) then
			if ( GetCVar("conversationMode") == "popout" ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = CLOSE_AND_LEAVE_CHAT_CONVERSATION_WINDOW;
				info.func = FCF_LeaveConversation;
				info.arg1 = FCF_GetCurrentChatFrame(dropDown);
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			else
				info = UIDropDownMenu_CreateInfo();
				info.text = CLOSE_CHAT_CONVERSATION_WINDOW;
				info.func = FCF_PopInWindow;
				info.arg1 = FCF_GetCurrentChatFrame(dropDown);
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		else
			error(format("Unhandled temporary window type. chatType: %s, chatTarget %s", tostring(chatFrame.chatType), tostring(chatFrame.chatTarget)));
		end
	end

	-- Display header
	info = UIDropDownMenu_CreateInfo();
	info.text = DISPLAY;
	info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Font size
	info = UIDropDownMenu_CreateInfo();
	info.text = FONT_SIZE;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Set Background color
	info = UIDropDownMenu_CreateInfo();
	info.text = BACKGROUND;
	info.hasColorSwatch = 1;
	info.r = r;
	info.g = g;
	info.b = b;
	-- Done because the slider is reversed
	if ( a ) then
		a = 1- a;
	end
	info.opacity = a;
	info.swatchFunc = FCF_SetChatWindowBackGroundColor;
	info.func = UIDropDownMenuButton_OpenColorPicker;
	--info.notCheckable = 1;
	info.hasOpacity = 1;
	info.opacityFunc = FCF_SetChatWindowOpacity;
	info.cancelFunc = FCF_CancelWindowColorSettings;
	UIDropDownMenu_AddButton(info);

	if ( not isTemporary ) then
		-- Filter header
		info = UIDropDownMenu_CreateInfo();
		info.text = FILTERS;
		--info.notClickable = 1;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		-- Configure settings
		info = UIDropDownMenu_CreateInfo();
		info.text = CHAT_CONFIGURATION;
		info.func = function() ShowUIPanel(ChatConfigFrame); end;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
end
--[[
function FCFDropDown_LoadServerChannels(...)
	local checked;
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local info, channel;

	-- Server Channels header
	info = UIDropDownMenu_CreateInfo();
	info.text = SERVER_CHANNELS;
	info.notClickable = 1;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	for i=1, select("#", ...) do
		checked = nil;
		channel = select(i, ...);
		if ( channelList ) then
			for index, value in pairs(channelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end
		if ( zoneChannelList ) then
			for index, value in pairs(zoneChannelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end

		info.text = channel;
		info.value = channel;
		info.func = FCFServerChannelsDropDown_OnClick;
		info.checked = checked;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function FCFServerChannelsDropDown_OnClick()
	if ( UIDropDownMenuButton_GetChecked() ) then
		ChatFrame_RemoveChannel(FCF_GetCurrentChatFrame(), UIDropDownMenuButton_GetName());
	else
		JoinPermanentChannel(UIDropDownMenuButton_GetName(), nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), UIDropDownMenuButton_GetName());
	end
end
]]
function FCFDropDown_LoadChannels(...)
	local checked;
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local info = UIDropDownMenu_CreateInfo();
	local channel, tag;
	for i=1, select("#", ...), 2 do
		checked = nil;
		tag = "CHANNEL"..select(i, ...);
		channel = select(i+1, ...);
		if ( channelList ) then
			for index, value in pairs(channelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end
		if ( zoneChannelList ) then
			for index, value in pairs(zoneChannelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end
		info.text = channel;
		info.value = tag;
		info.func = FCFChannelDropDown_OnClick;
		info.checked = checked;
		info.keepShownOnClick = 1;
		-- Color the chat channel
		local color = ChatTypeInfo[tag];
		info.hasColorSwatch = 1;
		info.r = color.r;
		info.g = color.g;
		info.b = color.b;
		-- Set the function the color picker calls
		info.swatchFunc = FCF_SetChatTypeColor;
		info.cancelFunc = FCF_CancelFontColorSettings;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function FCFChannelDropDown_OnClick()
	if ( UIDropDownMenuButton_GetChecked() ) then
		ChatFrame_RemoveChannel(FCF_GetCurrentChatFrame(), UIDropDownMenuButton_GetName());
	else
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), UIDropDownMenuButton_GetName());
	end
end

-- Used to display chattypegroups
function FCFDropDown_LoadChatTypes(menuChatTypeGroups)
	local checked, chatTypeInfo;
	local messageTypeList = FCF_GetCurrentChatFrame().messageTypeList;
	local info, group;
	for index, value in pairs(menuChatTypeGroups) do
		checked = nil;
		if ( messageTypeList ) then
			for joinedIndex, joinedValue in pairs(messageTypeList) do
				if ( value == joinedValue ) then
					checked = 1;
				end
			end
		end
		info = UIDropDownMenu_CreateInfo();
		info.value = value;
		info.func = FCFMessageTypeDropDown_OnClick;
		info.checked = checked;
		-- Set to keep shown on button click
		info.keepShownOnClick = 1;
		
		-- If more than one message type in a Chat Type Group need to show an expand arrow
		group = ChatTypeGroup[value];
		if ( getn(group) > 1 ) then
			info.text = _G[value];
			info.hasArrow = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		else
			info.text = _G[group[1]];
			chatTypeInfo = ChatTypeInfo[FCF_StripChatMsg(group[1])];
			-- If no chatTypeInfo then don't display
			if ( chatTypeInfo ) then
				-- Set the function to be called when a color is set
				info.swatchFunc = FCF_SetChatTypeColor;
				-- Set the swatch color info
				info.hasColorSwatch = 1;
				info.r = chatTypeInfo.r;
				info.g = chatTypeInfo.g;
				info.b = chatTypeInfo.b;
				info.cancelFunc = FCF_CancelFontColorSettings;	
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

--  Used to display chatsubtypes
function FCF_LoadChatSubTypes(chatGroup)
	if ( chatGroup ) then
		chatGroup = ChatTypeGroup[chatGroup];
	else
		chatGroup = ChatTypeGroup[UIDROPDOWNMENU_MENU_VALUE];
	end
	if ( chatGroup ) then
		local info = UIDropDownMenu_CreateInfo();
		local chatTypeInfo
		for index, value in pairs(chatGroup) do
			chatTypeInfo = ChatTypeInfo[FCF_StripChatMsg(value)];
			if ( chatTypeInfo ) then
				info.text = _G[value];
				info.value = FCF_StripChatMsg(value);
				-- Disable the button and color the text white
				info.notClickable = 1;
				-- Set to be notcheckable
				info.notCheckable = 1;
				-- Set the function to be called when a color is set
				info.swatchFunc = FCF_SetChatTypeColor;
				-- Set the swatch color info
				info.hasColorSwatch = 1;
				info.r = chatTypeInfo.r;
				info.g = chatTypeInfo.g;
				info.b = chatTypeInfo.b;
				-- Set function called when cancel is clicked in the colorpicker
				info.cancelFunc = FCF_CancelFontColorSettings;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

function FCFMessageTypeDropDown_OnClick(self)
	if ( UIDropDownMenuButton_GetChecked() ) then
		ChatFrame_RemoveMessageGroup(FCF_GetCurrentChatFrame(), self.value);
	else
		ChatFrame_AddMessageGroup(FCF_GetCurrentChatFrame(), self.value);
	end
end

function FCF_OpenNewWindow(name)
	local count = 1;
	local chatFrame, chatTab;
	
	for i=1, NUM_CHAT_WINDOWS do
		local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(i);
		chatFrame = _G["ChatFrame"..i];
		chatTab = _G["ChatFrame"..i.."Tab"];
		if ( (not shown and not chatFrame.isDocked) or (count == NUM_CHAT_WINDOWS) ) then
			if ( not name or name == "" ) then
				name = format(CHAT_NAME_TEMPLATE, i);			
			end
			
			-- initialize the frame
			FCF_SetWindowName(chatFrame, name);
			FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
			FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
			SetChatWindowLocked(i, nil);

			-- clear stale messages
			chatFrame:Clear();

			-- Listen to the standard messages
			ChatFrame_RemoveAllMessageGroups(chatFrame);
			ChatFrame_RemoveAllChannels(chatFrame);
			ChatFrame_ReceiveAllPrivateMessages(chatFrame);
			ChatFrame_ReceiveAllBNConversations(chatFrame);
			
			ChatFrame_AddMessageGroup(chatFrame, "SAY");
			ChatFrame_AddMessageGroup(chatFrame, "YELL");
			ChatFrame_AddMessageGroup(chatFrame, "GUILD");
			ChatFrame_AddMessageGroup(chatFrame, "WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "BN_WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY_LEADER");
			ChatFrame_AddMessageGroup(chatFrame, "CHANNEL");

			--Clear the edit box history.
			chatFrame.editBox:ClearHistory();
			
			-- Show the frame and tab
			chatFrame:Show();
			chatTab:Show();
			SetChatWindowShown(i, 1);
			
			-- Dock the frame by default
			FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), true);
			FCF_FadeInChatFrame(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));
			return chatFrame;
		end
		count = count + 1;
	end
end

function FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	--If the frame was already registered, unregister it.
	if ( chatFrame.isRegistered ) then
		FCFManager_UnregisterDedicatedFrame(chatFrame, chatFrame.chatType, chatFrame.chatTarget);
		chatFrame.isRegistered = false;
	end
	
	--Set the title text
	local name;
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		name = chatTarget;
	elseif ( chatType == "BN_CONVERSATION" ) then
		name = format(CONVERSATION_NAME, tonumber(chatTarget) + MAX_WOW_CHAT_CHANNELS);
	end
	FCF_SetWindowName(chatFrame, name);
	
	
	--Set up the window to receive the message types we want.
	chatFrame.chatType = chatType;
	chatFrame.chatTarget = chatTarget;
	
	ChatFrame_RemoveAllMessageGroups(chatFrame);
	ChatFrame_RemoveAllChannels(chatFrame);
	ChatFrame_ReceiveAllPrivateMessages(chatFrame);
	ChatFrame_ReceiveAllBNConversations(chatFrame);
	
	ChatFrame_AddMessageGroup(chatFrame, chatType);
	
	chatFrame.editBox:SetAttribute("chatType", chatType);
	chatFrame.editBox:SetAttribute("stickyType", chatType);
	
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		chatFrame.editBox:SetAttribute("tellTarget", chatTarget);
		ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget);
	elseif ( chatType == "BN_CONVERSATION" ) then
		chatFrame.editBox:SetAttribute("channelTarget", chatTarget);
		ChatFrame_AddBNConversationTarget(chatFrame, chatTarget);
	end
	
	-- Set up the colors
	local info = ChatTypeInfo[chatType];
	chatTab.selectedColorTable = { r = info.r, g = info.g, b = info.b };
	FCFTab_UpdateColors(chatTab, not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));
	
	--If it's a conversation, create the conversation button
	if ( chatType == "BN_CONVERSATION" or chatType == "BN_WHISPER" ) then
		if ( chatFrame.conversationButton ) then
			BNConversationButton_UpdateTarget(chatFrame.conversationButton);
			chatFrame.conversationButton:Show();
		else
			CreateFrame("Button", chatFrame:GetName().."ConversationButton", chatFrame.buttonFrame, "BNConversationRosterButtonTemplate", chatFrame:GetID());
		end
		if ( chatFrame:GetHeight() < CHAT_FRAME_BIGGER_MIN_HEIGHT ) then
			chatFrame:SetHeight(CHAT_FRAME_BIGGER_MIN_HEIGHT);
		end
		chatFrame:SetMinResize(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_BIGGER_MIN_HEIGHT);
	else
		if ( chatFrame.conversationButton ) then
			chatFrame.conversationButton:Hide();
		end
		chatFrame:SetMinResize(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT);
	end
	
	--If it's a conversation, get it ready to convert to a whisper if needed.
	if ( chatType == "BN_CONVERSATION" ) then
		chatFrame:RegisterEvent("BN_CHAT_CHANNEL_CLOSED");
	else
		chatFrame:UnregisterEvent("BN_CHAT_CHANNEL_CLOSED");
	end
	
	--Set the icon
	local conversationIcon;
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		conversationIcon = "Interface\\ChatFrame\\UI-ChatWhisperIcon";
	else
		conversationIcon = "Interface\\ChatFrame\\UI-ChatConversationIcon";
	end
	
	chatTab.conversationIcon:SetTexture(conversationIcon);
	if ( chatFrame.minFrame ) then
		chatFrame.minFrame.conversationIcon:SetTexture(conversationIcon);
	end
	
	--Register this frame
	FCFManager_RegisterDedicatedFrame(chatFrame, chatType, chatTarget);
	chatFrame.isRegistered = true;
	
	--The window name may have been updated, so update the dock and tabs.
	FCF_DockUpdate();
end

local maxTempIndex = NUM_CHAT_WINDOWS + 1;
function FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local chatFrame, chatTab, conversationIcon;
	for _, chatFrameName in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName];
		if ( frame.isTemporary ) then
			if ( not frame.inUse and not frame.isDocked ) then
				chatFrame = frame;
				chatTab = _G[chatFrame:GetName().."Tab"];
				break;
			end
		end
	end
	
	if ( not chatFrame ) then
		chatTab = CreateFrame("Button", "ChatFrame"..maxTempIndex.."Tab", UIParent, "ChatTabTemplate", maxTempIndex);
		
		conversationIcon = chatTab:CreateTexture(chatTab:GetName().."ConversationIcon", "ARTWORK", "ChatTabConversationIconTemplate");
		conversationIcon:ClearAllPoints();
		conversationIcon:SetPoint("RIGHT", chatTab:GetFontString(), "LEFT", 0, -2);
		chatTab.conversationIcon = conversationIcon;
		
		local tabText = _G[chatTab:GetName().."Text"];
		tabText:SetPoint("LEFT", chatTab.leftTexture, "RIGHT", 10, -6);
		tabText:SetJustifyH("LEFT");
		chatTab.sizePadding = 10;
		
		chatFrame = CreateFrame("ScrollingMessageFrame", "ChatFrame"..maxTempIndex, UIParent, "FloatingChatFrameTemplate", maxTempIndex);
		
		if ( GetCVarBool("chatMouseScroll") ) then
			chatFrame:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll);
			chatFrame:EnableMouseWheel(true);
		end

		maxTempIndex = maxTempIndex + 1;		
	end
	
	--Copy chat settings from the source frame.
	FCF_CopyChatSettings(chatFrame, sourceChatFrame or DEFAULT_CHAT_FRAME);

	-- clear stale messages
	chatFrame:Clear();
	chatFrame.inUse = true;
	chatFrame.isTemporary = true;
	
	FCF_SetTemporaryWindowType(chatFrame, chatType, chatTarget);
	
	--Clear the edit box history.
	chatFrame.editBox:ClearHistory();
	
	if ( sourceChatFrame ) then
		--Stop displaying this type of chat in the old chat frame.
		if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
			ChatFrame_ExcludePrivateMessageTarget(sourceChatFrame, chatTarget);
		elseif ( chatType == "BN_CONVERSATION" ) then
			ChatFrame_ExcludeBNConversationTarget(sourceChatFrame, chatTarget);
		end
	
		--Copy over messages
		local accessID = ChatHistory_GetAccessID(chatType, chatTarget);
		for i = 1, sourceChatFrame:GetNumMessages(accessID) do
			local text, accessID, lineID, extraData = sourceChatFrame:GetMessageInfo(i, accessID);
			local cType, cTarget = ChatHistory_GetChatType(extraData);

			local info = ChatTypeInfo[cType];
			chatFrame:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData);
		end
		--Remove the messages from the old frame.
		sourceChatFrame:RemoveMessagesByAccessID(accessID);
	end
	
	--Close the Editbox
	ChatEdit_DeactivateChat(chatFrame.editBox);
	
	-- Show the frame and tab
	chatFrame:Show();
	chatTab:Show();
	
	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), selectWindow);
	return chatFrame;
end

function FCF_GetNumActiveChatFrames()
	local count = 0;
	local chatFrame;
	for i=1, NUM_CHAT_WINDOWS do
		local _, _, _, _, _, _, shown = FCF_GetChatWindowInfo(i);
		chatFrame = _G["ChatFrame"..i];
		if ( chatFrame ) then
			if ( shown or chatFrame.isDocked ) then
				count = count + 1;
			end
		end
	end
	return count;
end

function FCF_RenameChatWindow_Popup()
	local dialog = StaticPopup_Show("NAME_CHAT");
	dialog.data = FCF_GetCurrentChatFrameID();
end

function FCF_NewChatWindow()
	StaticPopup_Show("NAME_CHAT");
end

function FCF_ResetAllWindows()
	StaticPopup_Show("RESET_CHAT");
end

--[[function FCF_ChatChannels()
	ToggleFriendsFrame(4);
end]]--

function FCF_SetWindowName(frame, name, doNotSave)
	if ( not name or name == "") then
		-- Hack to initialize the chat window names, since globalstrings are not available on init
		if ( frame:GetID() == 1 ) then
			name = GENERAL;
			doNotSave = nil;
		elseif ( frame:GetID() == 2 ) then
			name = COMBAT_LOG;
			doNotSave = nil;
		else
			name = format(CHAT_NAME_TEMPLATE, frame:GetID());
		end
	else
		FCFDock_SetDirty(GENERAL_CHAT_DOCK);
	end
	frame.name = name;
	local tab = _G[frame:GetName().."Tab"];
	tab:SetText(name);
	PanelTemplates_TabResize(tab, tab.sizePadding or 0);
	-- Save this off so we know how big the tab should always be, even if it gets shrunken on the dock.
	tab.textWidth = _G[tab:GetName().."Text"]:GetWidth();
	if ( not doNotSave ) then
		SetChatWindowName(frame:GetID(), name);
	end
	if ( frame.minFrame ) then
		frame.minFrame:SetText(name);
	end
end

function FCF_SetWindowColor(frame, r, g, b, doNotSave)
	local name = frame:GetName();
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		--NOTE - If this is changed, please change the equivalent code in GMChatFrame_OnLoad.
		local object = _G[name..value];
		local objectType = object:GetObjectType();
		if ( objectType == "Button" ) then
			object:GetNormalTexture():SetVertexColor(r, g, b);
			object:GetHighlightTexture():SetVertexColor(r, g, b);
			object:GetPushedTexture():SetVertexColor(r, g, b);
		elseif ( objectType == "Texture" ) then
			_G[name..value]:SetVertexColor(r,g,b);
		else
			--error("Unhandled frame type...");
		end
	end
	if ( not doNotSave ) then
		SetChatWindowColor(frame:GetID(), r, g, b);
	end
end

function FCF_SetWindowAlpha(frame, alpha, doNotSave)
	local name = frame:GetName();
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		_G[name..value]:SetAlpha(alpha);
	end
	if ( not doNotSave ) then
		SetChatWindowAlpha(frame:GetID(), alpha);
	end
	-- Remember the alpha
	frame.oldAlpha = alpha;
end

function FCF_GetCurrentChatFrameID()
	return CURRENT_CHAT_FRAME_ID;
end

function FCF_GetCurrentChatFrame(child)
	local currentChatFrame = nil;
	if ( CURRENT_CHAT_FRAME_ID ) then
		currentChatFrame = _G["ChatFrame"..CURRENT_CHAT_FRAME_ID];
	end
	if ( not currentChatFrame and child ) then
		currentChatFrame = _G["ChatFrame"..child:GetParent():GetID()];
	end
	return currentChatFrame;
end

function FCF_SetChatTypeColor()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	ChangeChatColor(UIDROPDOWNMENU_MENU_VALUE, r, g, b);
end

function FCF_SetChatWindowBackGroundColor()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	FCF_SetWindowColor(FCF_GetCurrentChatFrame(), r, g, b)
	SetChatWindowColor(FCF_GetCurrentChatFrameID(), r, g, b);
end

function FCF_SetChatWindowOpacity()
	local alpha = 1.0 - OpacitySliderFrame:GetValue();
	FCF_SetWindowAlpha(FCF_GetCurrentChatFrame(), alpha);
end

function FCF_SetChatWindowFontSize(self, chatFrame, fontSize)
	if ( not chatFrame ) then
		chatFrame = FCF_GetCurrentChatFrame();
	end
	if ( not fontSize ) then
		fontSize = self.value;
	end
	local fontFile, unused, fontFlags = chatFrame:GetFont();
	chatFrame:SetFont(fontFile, fontSize, fontFlags);
	if ( GMChatFrame and chatFrame == DEFAULT_CHAT_FRAME ) then
		GMChatFrame:SetFont(fontFile, fontSize, fontFlags);
	end
	SetChatWindowSize(chatFrame:GetID(), fontSize);
end

function FCF_CancelFontColorSettings(previousValues)
	if ( previousValues.r ) then
		ChangeChatColor(UIDROPDOWNMENU_MENU_VALUE, previousValues.r, previousValues.g, previousValues.b);
	end
end

function FCF_CancelWindowColorSettings(previousValues)
	if ( previousValues.r ) then
		FCF_SetWindowColor(FCF_GetCurrentChatFrame(), previousValues.r, previousValues.g, previousValues.b)
		SetChatWindowColor(FCF_GetCurrentChatFrameID(), previousValues.r, previousValues.g, previousValues.b);
	end
	if ( previousValues.opacity ) then
		FCF_SetWindowAlpha(FCF_GetCurrentChatFrame(), 1 - previousValues.opacity);
	end
end

function FCF_StripChatMsg(string)
	if ( strsub(string,1,8) == "CHAT_MSG" ) then
		return strsub(string,10);
	else
		return string;
	end
end

function FCF_ToggleLock()
	local chatFrame = FCF_GetCurrentChatFrame();
	if ( chatFrame.isLocked ) then
		-- If unlocking a docked frame then undock it and center it on the screen
		if ( chatFrame.isDocked and chatFrame ~= DEFAULT_CHAT_FRAME ) then
			FCF_UnDockFrame(chatFrame);
			chatFrame:ClearAllPoints();
			chatFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
			FCF_SetTabPosition(chatFrame, 0);
			chatFrame:Show();
		end
		FCF_SetLocked(chatFrame, nil);
	else
		FCF_SetLocked(chatFrame, 1);
	end
end

function FCF_SetLocked(chatFrame, isLocked)
	chatFrame.isLocked = isLocked;
	if ( chatFrame.isUninteractable or isLocked ) then
		chatFrame.resizeButton:Hide();
	else
		chatFrame.resizeButton:Show();
		--chatFrame.resizeButton:SetAlpha(_G[chatFrame:GetName().."Background"]:GetAlpha());
	end
	SetChatWindowLocked(chatFrame:GetID(), isLocked);
end

function FCF_ToggleUninteractable()
	local chatFrame = FCF_GetCurrentChatFrame();
	if ( chatFrame.isUninteractable ) then
		FCF_SetExpandedUninteractable(chatFrame, false)
	else
		FCF_SetExpandedUninteractable(chatFrame, true)
	end
end

function FCF_SetExpandedUninteractable(chatFrame, isUninteractable)
	if ( chatFrame.isDocked ) then
		for _, frame in pairs(GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES) do
			FCF_SetUninteractable(frame, isUninteractable);
		end
	else
		FCF_SetUninteractable(chatFrame, isUninteractable);
	end
end

function FCF_SetUninteractable(chatFrame, isUninteractable)	--No, uninteractable is not really a word.
	chatFrame.isUninteractable = isUninteractable;
	SetChatWindowUninteractable(chatFrame:GetID(), isUninteractable);
	if ( not chatFrame.overrideHyperlinksEnabled ) then
		chatFrame:SetHyperlinksEnabled(not isUninteractable);
	end
	local chatFrameName = chatFrame:GetName();
	if ( isUninteractable or chatFrame.isLocked ) then
		_G[chatFrameName.."ResizeButton"]:Hide();
	else
		_G[chatFrameName.."ResizeButton"]:Show();
	end
end

function FCF_FadeInChatFrame(chatFrame)
	local frameName = chatFrame:GetName();
	chatFrame.hasBeenFaded = true;
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		local object = _G[frameName..value];
		if ( object:IsShown() ) then
			UIFrameFadeIn(object, CHAT_FRAME_FADE_TIME, object:GetAlpha(), max(chatFrame.oldAlpha, DEFAULT_CHATFRAME_ALPHA));
		end
	end
	if ( chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
		for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
			if ( frame ~= chatFrame ) then
				FCF_FadeInChatFrame(frame);
			end
		end
		if ( GENERAL_CHAT_DOCK.overflowButton:IsShown() ) then
			UIFrameFadeIn(GENERAL_CHAT_DOCK.overflowButton, CHAT_FRAME_FADE_TIME, GENERAL_CHAT_DOCK.overflowButton:GetAlpha(), CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA);
		end
	end
	
	local chatTab = _G[frameName.."Tab"];
	UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, chatTab:GetAlpha(), chatTab.mouseOverAlpha);
	
	--Fade in the button frame
	if ( not chatFrame.isDocked ) then
		UIFrameFadeIn(chatFrame.buttonFrame, CHAT_FRAME_FADE_TIME, chatFrame.buttonFrame:GetAlpha(), 1);
	end
end

function FCF_FadeOutChatFrame(chatFrame)
	local frameName = chatFrame:GetName();
	chatFrame.hasBeenFaded = nil;
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		-- Fade out chat frame
		local object = _G[frameName..value];
		if ( object:IsShown() ) then
			UIFrameFadeOut(object, CHAT_FRAME_FADE_OUT_TIME, max(object:GetAlpha(), chatFrame.oldAlpha), chatFrame.oldAlpha);
		end
	end
	if ( chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
		for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
			if ( frame ~= chatFrame ) then
				FCF_FadeOutChatFrame(frame);
			end
		end
		if ( GENERAL_CHAT_DOCK.overflowButton:IsShown() ) then
			UIFrameFadeOut(GENERAL_CHAT_DOCK.overflowButton, CHAT_FRAME_FADE_OUT_TIME, GENERAL_CHAT_DOCK.overflowButton:GetAlpha(), CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA);
		end
	end
	
	local chatTab = _G[frameName.."Tab"];
	UIFrameFadeOut(chatTab, CHAT_FRAME_FADE_OUT_TIME, chatTab:GetAlpha(), chatTab.noMouseAlpha);
	
	--Fade out the ButtonFrame
	if ( not chatFrame.isDocked ) then
		UIFrameFadeOut(chatFrame.buttonFrame, CHAT_FRAME_FADE_OUT_TIME, chatFrame.buttonFrame:GetAlpha(), CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA);
	end
end
	
local LAST_CURSOR_X, LAST_CURSOR_Y;
function FCF_OnUpdate(elapsed)
	local cursorX, cursorY = GetCursorPosition();
	
	local overSomething = false;
	for _, frameName in pairs(CHAT_FRAMES) do
		local chatFrame = _G[frameName];
		if ( chatFrame:IsShown() ) then
			local topOffset = 28;
			if ( IsCombatLog(chatFrame) ) then
				topOffset = topOffset + CombatLogQuickButtonFrame_Custom:GetHeight();
			end
			--Items that will always cause the frame to fade in.
			if ( MOVING_CHATFRAME or chatFrame.resizeButton:GetButtonState() == "PUSHED" or (chatFrame.isDocked and GENERAL_CHAT_DOCK.overflowButton.list:IsShown())) then	
				overSomething = true;
				chatFrame.mouseOutTime = 0;
				if ( not chatFrame.hasBeenFaded ) then
					overSomething = true;
					FCF_FadeInChatFrame(chatFrame);
				end
			--Things that will cause the frame to fade in if the mouse is stationary.
			elseif ( chatFrame:IsMouseOver(topOffset, -2, -2, 2) or	--This should be slightly larger than the hit rect insets to give us some wiggle room.
				(chatFrame.isDocked and FriendsMicroButton:IsMouseOver()) or
				(chatFrame.buttonFrame:IsMouseOver())) then
				overSomething = true;
				chatFrame.mouseOutTime = 0;
				if ( cursorX == LAST_CURSOR_X and cursorY == LAST_CURSOR_Y and not chatFrame.hasBeenFaded ) then
					chatFrame.mouseInTime = (chatFrame.mouseInTime or 0) + elapsed;
					if ( chatFrame.mouseInTime > CHAT_TAB_SHOW_DELAY ) then
						FCF_FadeInChatFrame(chatFrame);
					end
				else
					chatFrame.mouseInTime = 0;
				end
			elseif ( chatFrame:IsShown() and chatFrame.hasBeenFaded ) then
				chatFrame.mouseInTime = 0;
				chatFrame.mouseOutTime = (chatFrame.mouseOutTime or 0) + elapsed;
				if ( chatFrame.mouseOutTime > CHAT_TAB_HIDE_DELAY ) then
					FCF_FadeOutChatFrame(chatFrame);
				end
			end
		end
	end
	
	LAST_CURSOR_X, LAST_CURSOR_Y = cursorX, cursorY;
end

function FCF_SavePositionAndDimensions(chatFrame)
	local centerX = chatFrame:GetLeft() + chatFrame:GetWidth() / 2;
	local centerY = chatFrame:GetBottom() + chatFrame:GetHeight() / 2;
	
	local horizPoint, vertPoint;
	local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight();
	local xOffset, yOffset;
	if ( centerX > screenWidth / 2 ) then
		horizPoint = "RIGHT";
		xOffset = (chatFrame:GetRight() - screenWidth)/screenWidth;
	else
		horizPoint = "LEFT";
		xOffset = chatFrame:GetLeft()/screenWidth;
	end
	
	if ( centerY > screenHeight / 2 ) then
		vertPoint = "TOP";
		yOffset = (chatFrame:GetTop() - screenHeight)/screenHeight;
	else
		vertPoint = "BOTTOM";
		yOffset = chatFrame:GetBottom()/screenHeight;
	end
	
	SetChatWindowSavedPosition(chatFrame:GetID(), vertPoint..horizPoint, xOffset, yOffset);
	SetChatWindowSavedDimensions(chatFrame:GetID(), chatFrame:GetWidth(), chatFrame:GetHeight());
end

function FCF_RestorePositionAndDimensions(chatFrame)
	local width, height = GetChatWindowSavedDimensions(chatFrame:GetID());
	if ( width and height ) then
		chatFrame:SetSize(width, height);
	end
	
	local point, xOffset, yOffset = GetChatWindowSavedPosition(chatFrame:GetID());
	if ( point ) then
		chatFrame:ClearAllPoints();
		chatFrame:SetPoint(point, xOffset * GetScreenWidth(), yOffset * GetScreenHeight());
		chatFrame:SetUserPlaced(true);
	else
		chatFrame:SetUserPlaced(false);
	end
end

-- Docking handling functions
function FCF_StopDragging(chatFrame)
	chatFrame:StopMovingOrSizing();

	_G[chatFrame:GetName().."Tab"]:UnlockHighlight();
	
	FCFDock_HideInsertHighlight(GENERAL_CHAT_DOCK);
	
	if ( GENERAL_CHAT_DOCK:IsMouseOver(10, -10, 0, 10) ) then
		local mouseX, mouseY = GetCursorPosition();
		mouseX, mouseY = mouseX / UIParent:GetScale(), mouseY / UIParent:GetScale();
		FCF_DockFrame(chatFrame, FCFDock_GetInsertIndex(GENERAL_CHAT_DOCK, chatFrame, mouseX, mouseY), true);
	else
		FCF_SetTabPosition(chatFrame, 0);
	end
	
	FCF_SavePositionAndDimensions(chatFrame);

	MOVING_CHATFRAME = nil;
end

function FCFTab_OnUpdate(self, elapsed)
	local cursorX, cursorY = GetCursorPosition();
	cursorX, cursorY = cursorX / UIParent:GetScale(), cursorY / UIParent:GetScale();
	local chatFrame = _G["ChatFrame"..self:GetID()];
	if ( chatFrame ~= GENERAL_CHAT_DOCK.primary and GENERAL_CHAT_DOCK:IsMouseOver(10, -10, 0, 10) ) then
		FCFDock_PlaceInsertHighlight(GENERAL_CHAT_DOCK, chatFrame, cursorX, cursorY);
	else
		FCFDock_HideInsertHighlight(GENERAL_CHAT_DOCK);
	end
	
	FCF_UpdateButtonSide(chatFrame);
	if ( chatFrame == GENERAL_CHAT_DOCK.primary ) then
		for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
			FCF_SetButtonSide(frame, FCF_GetButtonSide(GENERAL_CHAT_DOCK.primary));
		end
	end
	
	if ( not IsMouseButtonDown(self.dragButton) ) then
		FCFTab_OnDragStop(self, self.dragButton);
		self.dragButton = nil;
		self:SetScript("OnUpdate", nil);
	end

	if ( BNToastFrame and BNToastFrame:IsShown() ) then
		BNToastFrame_UpdateAnchor();
	end	
end

function FCFTab_OnDragStop(self, button)
	FCF_StopDragging(_G["ChatFrame"..self:GetID()]);
end

DEFAULT_TAB_SELECTED_COLOR_TABLE = { r = 1, g = 0.5, b = 0.25 };

function FCFTab_UpdateColors(self, selected)
	if ( selected ) then
		self.leftSelectedTexture:Show();
		self.middleSelectedTexture:Show();
		self.rightSelectedTexture:Show();
	else
		self.leftSelectedTexture:Hide();
		self.middleSelectedTexture:Hide();
		self.rightSelectedTexture:Hide();
	end
	
	local colorTable = self.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;
	
	if ( self.selectedColorTable ) then
		self:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	self.leftSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.middleSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.rightSelectedTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	
	self.leftHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.middleHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.rightHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	
	if ( self.conversationIcon ) then
		self.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	end
	
	local minimizedFrame = _G["ChatFrame"..self:GetID().."Minimized"];
	if ( minimizedFrame ) then
		minimizedFrame.selectedColorTable = self.selectedColorTable;
		FCFMin_UpdateColors(minimizedFrame);
	end
end

function FCFTab_UpdateAlpha(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	if ( not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
		chatTab.mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA;
		chatTab.noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA;
	else
		if ( chatTab.alerting ) then
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA;
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA;
		else
			chatTab.mouseOverAlpha = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA;
			chatTab.noMouseAlpha = CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA;
		end
	end
	
	-- If this is in the middle of fading, stop it, since we're about to set the alpha
	UIFrameFadeRemoveFrame(chatTab);
	
	if ( chatFrame.hasBeenFaded ) then
		chatTab:SetAlpha(chatTab.mouseOverAlpha);
	else
		chatTab:SetAlpha(chatTab.noMouseAlpha);
	end
end

function FCF_HideOnFadeFinished(frame)
	frame:Hide();
end

function FCF_IsValidChatFrame(chatFrame)
	-- Break out all the cases individually because the logic gets convoluted
	if ( chatFrame == MOVING_CHATFRAME ) then
		return nil;
	end

	if ( not chatFrame:IsShown() and not chatFrame.isDocked ) then
		return nil;
	end
	
	return 1;
end

function FCF_UpdateButtonSide(chatFrame)
	local leftDist =  chatFrame:GetLeft();
	local rightDist = GetScreenWidth() - chatFrame:GetRight();
	local changed = nil;
	if (( leftDist > 0 and leftDist <= rightDist ) or rightDist < 0 ) then
		if ( chatFrame.buttonSide ~= "left" ) then
			FCF_SetButtonSide(chatFrame, "left");
			changed = 1;
		end
	else
		if ( chatFrame.buttonSide ~= "right" or leftDist < 0 ) then
			FCF_SetButtonSide(chatFrame, "right");
			changed = 1;
		end
	end
	return changed;
end

function FCF_SetButtonSide(chatFrame, buttonSide, forceUpdate)
	if ( not forceUpdate and chatFrame.buttonSide == buttonSide  ) then
		return;
	end
	chatFrame.buttonFrame:ClearAllPoints();
	
	local topY = 0;
	if ( IsCombatLog(chatFrame) ) then
		topY = topY + CombatLogQuickButtonFrame_Custom:GetHeight();
	end

	if ( buttonSide == "left" ) then
		chatFrame.buttonFrame:SetPoint("TOPRIGHT", chatFrame, "TOPLEFT", -4, topY);
		chatFrame.buttonFrame:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMLEFT", -4, 0);
	elseif ( buttonSide == "right" ) then
		chatFrame.buttonFrame:SetPoint("TOPLEFT", chatFrame, "TOPRIGHT", 4, topY);
		chatFrame.buttonFrame:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMRIGHT", 4, 0);
	end
	chatFrame.buttonSide = buttonSide;
	
	if ( chatFrame == DEFAULT_CHAT_FRAME ) then
		ChatFrameMenu_UpdateAnchorPoint();
	end
end

function FCF_StartAlertFlash(chatFrame)
	if ( chatFrame.minFrame ) then
		UIFrameFlash(chatFrame.minFrame.glow, 1.0, 1.0, -1, false, 0, 0, "chat");
		
		chatFrame.minFrame.alerting = true;
	end
	
	local chatTab = _G[chatFrame:GetName().."Tab"];
	UIFrameFlash(chatTab.glow, 1.0, 1.0, -1, false, 0, 0, "chat");
	
	chatTab.alerting = true;
	
	FCFTab_UpdateAlpha(chatFrame);
	
	FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton);
end

function FCF_StopAlertFlash(chatFrame)
	if ( chatFrame.minFrame ) then
		UIFrameFlashStop(chatFrame.minFrame.glow);
		
		chatFrame.minFrame.alerting = false;
	end
	
	local chatTab = _G[chatFrame:GetName().."Tab"];
	UIFrameFlashStop(chatTab.glow);
	
	chatTab.alerting = false;
	
	FCFTab_UpdateAlpha(chatFrame);

	FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton);
end

function FCF_GetButtonSide(chatFrame)
	return chatFrame.buttonSide;
end

function FCF_DockUpdate()
	FCFDock_UpdateTabs(GENERAL_CHAT_DOCK, true);
end
--[[
	local numDockedFrames = getn(DOCKED_CHAT_FRAMES);
	local dockRegion, chatTab, previousDockedFrame;
	local dockWidth = 0;
	local previousDockRegion;
	local name;
	for index, value in pairs(DOCKED_CHAT_FRAMES) do
		-- If not the initial chatframe then anchor the frame to the base chatframe
		name = value:GetName();
		if ( index ~= 1 ) then
			value:ClearAllPoints();
			value:SetPoint("TOPLEFT", DEFAULT_CHAT_FRAME, "TOPLEFT", 0, 0);
			value:SetPoint("BOTTOMLEFT", DEFAULT_CHAT_FRAME, "BOTTOMLEFT", 0, 0);
			value:SetPoint("BOTTOMRIGHT", DEFAULT_CHAT_FRAME, "BOTTOMRIGHT", 0, 0);
		end
		
		-- Select or deselect the frame
		chatTab = _G[value:GetName().."Tab"];
		-- chatTab.textWidth is the original width of the text name of the tab
		-- We need to use this as an absolute measure of the text's width is altered when the chat dock gets too small
		-- If the text is shrunken the original width is lost, unless we save it and use it in the following manner
		-- This is a fix for Bug ID: 71180
		PanelTemplates_TabResize(chatTab, 5, nil, nil, chatTab.textWidth);
		if ( value == SELECTED_DOCK_FRAME ) then
			value:Show();
			if ( chatTab:IsShown() ) then
				chatTab:SetAlpha(1.0);
			end
		else
			value:Hide();
			if ( chatTab:IsShown() ) then
				chatTab:SetAlpha(0.5);
			end
		end
		
		-- If there was a frame before this frame then anchor the tab
		
		if ( previousDockedFrame ) then
			chatTab:ClearAllPoints();
			FCF_SetTabPosition(value, dockWidth);
			_G[previousDockedFrame:GetName().."TabDockRegion"]:SetPoint("RIGHT", value:GetName().."Tab", "CENTER", 0, 0);
		end

		-- If this is the last frame in the dock then extend the dockRegion, otherwise shrink it to the default width
		dockRegion = _G[chatTab:GetName().."DockRegion"];
		dockRegion:SetPoint("LEFT", chatTab, "CENTER", 0 , 0);
		if ( numDockedFrames == index ) then
			dockRegion:SetPoint("RIGHT", "ChatFrame"..chatTab:GetID(), "RIGHT", 0, 0);
		end
		dockRegion:Hide();
		
		-- Keep track of the width of the dock for anchoring purposes
		dockWidth = dockWidth + chatTab:GetWidth();
		previousDockedFrame = value;
	end
	
	-- Intelligently resize the chat tabs if dockwidth is greater than the window width
	if ( dockWidth > DEFAULT_CHAT_FRAME:GetWidth() ) then
		DOCK_COPY = {};
		-- Copy the array
		for index, value in pairs(DOCKED_CHAT_FRAMES) do
			DOCK_COPY[index] = DOCKED_CHAT_FRAMES[index];
		end
		sort(DOCK_COPY, FCF_TabCompare);
		local totalWidth = DEFAULT_CHAT_FRAME:GetWidth();
		local avgWidth = totalWidth / numDockedFrames;
		local chatTabWidth;
		-- Resize the tabs
		for index, value in pairs(DOCK_COPY) do
			chatTab = _G[value:GetName().."Tab"];
			chatTabWidth = chatTab:GetWidth();
			if ( chatTabWidth < avgWidth ) then
				-- If tab is smaller than the average then remove it from the list and recalc the average
				totalWidth = totalWidth - chatTabWidth;
				numDockedFrames = numDockedFrames - 1;
				avgWidth = totalWidth / numDockedFrames;
			else
				-- Set the tab to the average width
				PanelTemplates_TabResize(chatTab, 0, avgWidth);
			end
		end

		-- Reanchor the tabs
		previousDockedFrame = nil;
		dockWidth = 0;
		for index, value in pairs(DOCKED_CHAT_FRAMES) do
			-- If there was a frame before this frame then anchor the tab
			if ( previousDockedFrame ) then
				FCF_SetTabPosition(value, dockWidth);
			end
			chatTab = _G[value:GetName().."Tab"];
			dockWidth = dockWidth + chatTab:GetWidth();
			previousDockedFrame = value;
		end
	end
end]]

function FCF_TabCompare(chatFrame1, chatFrame2)
	local tab1 = _G[chatFrame1:GetName().."Tab"];
	local tab2 = _G[chatFrame2:GetName().."Tab"];
	return tab1:GetWidth() < tab2:GetWidth();
end

function FCF_DockFrame(frame, index, selected)
	-- Return if already docked
	if ( frame.isDocked ) then
		return;
	end

	FCFDock_AddChatFrame(GENERAL_CHAT_DOCK, frame, index);
	
	-- Save docked state
	FCF_SaveDock();
	if ( selected ) then
		--FCF_SelectDockFrame(frame);
		FCFDock_SelectWindow(GENERAL_CHAT_DOCK, frame);
	end

	-- Set scroll button side
	if ( frame == DEFAULT_CHAT_FRAME ) then
		FCF_UpdateButtonSide(frame);
	else
		FCF_SetButtonSide(frame, FCF_GetButtonSide(DEFAULT_CHAT_FRAME));
	end
	
	-- Lock frame
	FCF_SetLocked(frame, 1);
	
	--If the frame that is being docked and the frame it is docking to have different interactable settings, make them both interactable.
	if ( frame.isUninteractable ~= DEFAULT_CHAT_FRAME.isUninteractable ) then
		FCF_SetExpandedUninteractable(frame, false)
	end
	
	if ( frame == COMBATLOG ) then
		Blizzard_CombatLog_Update_QuickButtons();
	end
	
	FCF_DockUpdate();
end

function FCF_UnDockFrame(frame)
	if ( frame == DEFAULT_CHAT_FRAME or not frame.isDocked ) then
		return;
	end
	-- Undock frame regardless of whether its docked or not
	SetChatWindowDocked(frame:GetID(), nil);
	FCFDock_RemoveChatFrame(GENERAL_CHAT_DOCK, frame);

	FCF_SaveDock();
	
	-- Set tab to full alpha
	local chatTab = _G[frame:GetName().."Tab"];
	chatTab:SetAlpha(1.0);
end

function FCF_SelectDockFrame(frame)
	SELECTED_DOCK_FRAME = frame;
	-- Stop tab flashing
	local tabFlash;
	if ( frame ) then
		tabFlash = _G["ChatFrame"..frame:GetID().."TabFlash"];
	end
	
	if ( tabFlash ) then
		UIFrameFlashRemoveFrame(tabFlash);
		tabFlash:Hide();
	end
	FCFDock_SelectWindow(GENERAL_CHAT_DOCK, frame);
	FCF_DockUpdate();
end

function FCF_Tab_OnClick(self, button)
	local chatFrame = _G["ChatFrame"..self:GetID()];
	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		chatFrame:StopMovingOrSizing();
		CURRENT_CHAT_FRAME_ID = self:GetID();
		ToggleDropDownMenu(1, nil, _G[self:GetName().."DropDown"], self:GetName(), 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is docked assume that a click is to select a chat window, not drag it
	SELECTED_CHAT_FRAME = chatFrame;
	if ( chatFrame.isDocked and FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ~= chatFrame ) then
		FCF_SelectDockFrame(chatFrame);
		FCF_FadeInChatFrame(chatFrame);
		return;
	else
		if ( GetCVar("chatStyle") ~= "classic" ) then
			ChatEdit_SetLastActiveWindow(chatFrame.editBox);
		end
		FCF_FadeInChatFrame(chatFrame);
	end
	
end

function FCF_SetTabPosition(chatFrame, x)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	chatTab:ClearAllPoints();
	chatTab:SetPoint("BOTTOMLEFT", chatFrame:GetName().."Background", "TOPLEFT", x+2, 0);
end

function FCF_SaveDock()
	for index, value in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
		SetChatWindowDocked(value:GetID(), index);
	end
end

function FCF_LeaveConversation(frame, fallback)
	if ( fallback ) then
		frame=fallback
	end
	if ( not frame ) then
		frame = FCF_GetCurrentChatFrame();
	end
	
	assert(frame.chatType == "BN_CONVERSATION");
	BNLeaveConversation(tonumber(frame.chatTarget));
	
	FCF_Close(frame);
end

function FCF_PopInWindow(frame, fallback)
	if ( fallback ) then
        frame=fallback
    end
	if ( not frame ) then
		frame = FCF_GetCurrentChatFrame();
	end
	if ( frame == DEFAULT_CHAT_FRAME ) then
		return;
	end
	
	--Restore any chats this frame had to the DEFAULT_CHAT_FRAME
	FCF_RestoreChatsToFrame(DEFAULT_CHAT_FRAME, frame);
	
	FCF_Close(frame);
end

function FCF_Close(frame, fallback)
    if ( fallback ) then
        frame=fallback
    end
	if ( not frame ) then
		frame = FCF_GetCurrentChatFrame();
	end
	if ( frame == DEFAULT_CHAT_FRAME ) then
		return;
	end
	FCF_UnDockFrame(frame);
	HideUIPanel(frame);
	_G[frame:GetName().."Tab"]:Hide();
	FCF_FlagMinimizedPositionReset(frame);
	if ( frame.minFrame and frame.minFrame:IsShown() ) then
		frame.minFrame:Hide();
	end
	if ( frame.isTemporary ) then
		FCFManager_UnregisterDedicatedFrame(frame, frame.chatType, frame.chatTarget);
		frame.isRegistered = false;
		frame.inUse = false;
	end
	if ( PENDING_BN_WHISPER_TO_CONVERSATION_FRAME == frame ) then
		PENDING_BN_WHISPER_TO_CONVERSATION_FRAME = nil;
	end
	
	--Reset what this window receives.
	ChatFrame_RemoveAllMessageGroups(frame);
	ChatFrame_RemoveAllChannels(frame);
	ChatFrame_ReceiveAllPrivateMessages(frame);
	ChatFrame_ReceiveAllBNConversations(frame);
end

function FCF_RestoreChatsToFrame(targetFrame, sourceFrame)
	--Restore chat types
	for _, messageType in pairs(sourceFrame.messageTypeList) do
		ChatFrame_AddMessageGroup(targetFrame, messageType);
	end
	
	--Restore channels
	for _, channel in pairs(sourceFrame.channelList) do
		ChatFrame_AddChannel(targetFrame, channel);
	end
	
	--Restore whispers
	if ( sourceFrame.privateMessageList ) then
		for name, value in pairs(sourceFrame.privateMessageList) do
			if ( value ) then
				ChatFrame_RemoveExcludePrivateMessageTarget(targetFrame, name);
			end
		end
	end
	
	if ( sourceFrame.bnConversationList ) then
		for name, value in pairs(sourceFrame.bnConversationList) do
			if ( value ) then
				ChatFrame_RemoveExcludeBNConversationTarget(targetFrame, name);
			end
		end
	end
end

-- Tab flashing functions
function FCF_FlashTab(self)
	local tabFlash = _G[self:GetName().."TabFlash"];
	if ( not self.isDocked or (self == SELECTED_DOCK_FRAME) or UIFrameIsFlashing(tabFlash) ) then
		return;
	end
	tabFlash:Show();
	UIFrameFlash(tabFlash, 0.25, 0.25, 60, nil, 0.5, 0.5);
end

-- Function for repositioning the chat dock depending on if there's a shapeshift bar/stance bar, etc...
function FCF_UpdateDockPosition()
	if ( DEFAULT_CHAT_FRAME:IsUserPlaced() ) then
		return;
	end
	
	local chatOffset = 85;
	if ( GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() ) then
		if ( MultiBarBottomLeft:IsShown() ) then
			chatOffset = chatOffset + 55;
		else
			chatOffset = chatOffset + 15;
		end
	elseif ( MultiBarBottomLeft:IsShown() ) then
		chatOffset = chatOffset + 15;
	end
	DEFAULT_CHAT_FRAME:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, chatOffset);
	FCF_DockUpdate();
end

function FCF_Set_NormalChat()
	ChatFrame2:StartMoving();
	ChatFrame2:StopMovingOrSizing();
	FCF_SetLocked(ChatFrame2, nil);
	-- to fix a bug with the combat log not repositioning its tab properly when coming out of
	-- simple chat, we need to update now
	FCF_DockUpdate();
end

-- Functions to set and remove the chat window show delay on mouseover
function SetChatMouseOverDelay(noDelay)
	if ( noDelay == "1" ) then
		CHAT_TAB_SHOW_DELAY = 0;
		CHAT_FRAME_FADE_TIME = 0;
	else
		CHAT_TAB_SHOW_DELAY = 0.2;
		CHAT_FRAME_FADE_TIME = 0.15;
	end
end

-- Reset the chat windows to default
function FCF_ResetChatWindows()
	ChatFrame1:ClearAllPoints();
	ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 95);
	ChatFrame1:SetWidth(430);
	ChatFrame1:SetHeight(120);
	ChatFrame1.isInitialized = 0;
	FCF_SetButtonSide(ChatFrame1, "left")
	FCF_SetChatWindowFontSize(nil, ChatFrame1, 14);
	FCF_SetWindowName(ChatFrame1, GENERAL);
	FCF_SetWindowColor(ChatFrame1, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
	FCF_SetWindowAlpha(ChatFrame1, DEFAULT_CHATFRAME_ALPHA);
	FCF_UnDockFrame(ChatFrame1);
	ChatFrame_RemoveAllMessageGroups(ChatFrame1);
	ChatFrame_RemoveAllChannels(ChatFrame1);
	ChatFrame_ReceiveAllPrivateMessages(ChatFrame1);
	ChatFrame_ReceiveAllBNConversations(ChatFrame1);
	SELECTED_CHAT_FRAME = ChatFrame1;
	DEFAULT_CHAT_FRAME.chatframe = DEFAULT_CHAT_FRAME;

	FCF_SetChatWindowFontSize(nil, ChatFrame2, 14);
	FCF_SetWindowName(ChatFrame2, COMBAT_LOG);
	FCF_SetWindowColor(ChatFrame2, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
	FCF_SetWindowAlpha(ChatFrame2, DEFAULT_CHATFRAME_ALPHA);
	ChatFrame_RemoveAllMessageGroups(ChatFrame2);
	ChatFrame_RemoveAllChannels(ChatFrame2);
	ChatFrame_ReceiveAllPrivateMessages(ChatFrame2);
	ChatFrame_ReceiveAllBNConversations(ChatFrame2);
	FCF_UnDockFrame(ChatFrame2);
	ChatFrame2.isInitialized = 0;
	for _, chatFrameName in ipairs(CHAT_FRAMES) do
		if ( chatFrameName ~= "ChatFrame1" ) then
			local chatFrame = _G[chatFrameName];
			if ( chatFrame.isTemporary and chatFrame.chatType == "BN_CONVERSATION" and
				BNGetConversationInfo(tonumber(chatFrame.chatTarget)) and GetCVar("conversationMode") == "popout" ) then
				--We're still in this conversation, so we just want to reset the position, not remove the frame.
				FCF_DockFrame(chatFrame, 3);	--Put it after General and Combat Log
			else
				chatFrame.isInitialized = 0;
				FCF_SetTabPosition(chatFrame, 0);
				FCF_Close(chatFrame);
				FCF_UnDockFrame(chatFrame);
				FCF_SetWindowName(chatFrame, "");
				ChatFrame_RemoveAllMessageGroups(chatFrame);
				ChatFrame_RemoveAllChannels(chatFrame);
				ChatFrame_ReceiveAllPrivateMessages(chatFrame);
				ChatFrame_ReceiveAllBNConversations(chatFrame);
			end
			FCF_SetChatWindowFontSize(nil, chatFrame, 14);
			FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
			FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
		end
	end
	ChatFrame1.init = 0;
	FCF_DockFrame(ChatFrame1, 1, true);
	FCF_DockFrame(ChatFrame2, 2);

	-- resets to hard coded defaults
	ResetChatWindows();
	UIParent_ManageFramePositions();
	FCFDock_SelectWindow(GENERAL_CHAT_DOCK, ChatFrame1);
end

function IsCombatLog(frame)
	if ( frame == ChatFrame2 and IsAddOnLoaded("Blizzard_CombatLog") ) then
		return true;
	else
		return false;
	end
end

function FCFClickAnywhereButton_OnLoad(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 1);
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	FCFClickAnywhereButton_UpdateState(self);
end

function FCFClickAnywhereButton_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "VARIABLES_LOADED" or
		(event == "CVAR_UPDATE" and (arg1 == "chatStyle" or arg1 == "CHAT_WHOLE_WINDOW_CLICKABLE")) ) then
		FCFClickAnywhereButton_UpdateState(self);
	end
end

function FCFClickAnywhereButton_UpdateState(self)
	if ( GetCVar("chatStyle") == "im" and GetCVarBool("wholeChatWindowClickable") and
		LAST_ACTIVE_CHAT_EDIT_BOX ~=  self:GetParent().editBox ) then
		self:Show();
	else
		self:Hide();
	end
end

function FCF_MinimizeFrame(chatFrame, side)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	
	local createdFrame = false;
	if ( not chatFrame.minFrame ) then
		chatFrame.minFrame = FCF_CreateMinimizedFrame(chatFrame);
	end
	
	if ( chatFrame.minFrame.resetPosition ) then
		chatFrame.minFrame:ClearAllPoints();
		chatFrame.minFrame:SetPoint("TOP"..side, chatFrame, "TOP"..side, 0, 0);
		chatFrame.minFrame.resetPosition = false;
	end
	
	chatFrame.minimized = true;
	
	chatFrame.minFrame:Show();
	chatFrame:Hide();
	chatTab:Hide();
end

function FCF_MaximizeFrame(chatFrame)
	local minFrame = chatFrame.minFrame;
	local chatTab = _G[chatFrame:GetName().."Tab"];
	
	chatFrame.minimized = false;
	
	minFrame:UnlockHighlight();
	minFrame:Hide();
	chatFrame:Show();
	chatTab:Show();
	
	FCF_FadeInChatFrame(chatFrame);
end

function FCF_CreateMinimizedFrame(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	
	local minFrame = CreateFrame("Button", chatFrame:GetName().."Minimized", UIParent, "FloatingChatFrameMinimizedTemplate");
	minFrame.maxFrame = chatFrame;
	
	minFrame:SetText(chatFrame.name);

	--Copy the colors from the minimized frame.
	minFrame.selectedColorTable = chatTab.selectedColorTable;
	FCFMin_UpdateColors(minFrame);
	
	if ( not chatFrame.isTemporary ) then
		minFrame.conversationIcon:Hide();
	else
		local conversationIcon;
		if ( chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER" ) then
			conversationIcon = "Interface\\ChatFrame\\UI-ChatWhisperIcon";
		else
			conversationIcon = "Interface\\ChatFrame\\UI-ChatConversationIcon";
		end
		
		minFrame.conversationIcon:SetTexture(conversationIcon);
	end
	
	if (chatFrame.isTemporary) then
		minFrame.Text:SetJustifyH("LEFT");
		minFrame.Text:SetPoint("LEFT", minFrame, "LEFT", 30, 0);
	end
	
	--Make sure the position is reset.
	minFrame.resetPosition = true;
	
	return minFrame;
end

function FCFMin_UpdateColors(minFrame)
	--Color it.
	local colorTable = minFrame.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;
	
	if ( minFrame.selectedColorTable ) then
		minFrame:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		minFrame:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	minFrame.leftHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.middleHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.rightHighlightTexture:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	
	minFrame.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
end

--This function just makes the position be reset the next time the minimize frame is shown.
function FCF_FlagMinimizedPositionReset(chatFrame)
	if ( chatFrame.minFrame ) then
		chatFrame.minFrame.resetPosition = true;
	end
end

------Docking related functions for the new docking system
--[[
Since we've been discussing allowing multiple docks, this code is designed to be mostly-OO. Please try not to use global variables.
(Theoretically, all of these functions may be put in a metatable to allow, e.g., "Dock:SelectWindow(chatWindow)".
To keep with this, please ensure that "dock" is the first argument of every function.)
]]

function FCFDock_OnLoad(dock)
	dock.DOCKED_CHAT_FRAMES = {};
	dock.isDirty = true;	--You dirty, dirty frame
end

function FCFDock_OnEvent(dock, event, ...)
	if ( event == "UPDATE_CHAT_WINDOWS" ) then
		--FCFDock_ForceTabSort(dock);
		--FCFDock_ForceReanchoring(dock);
	end
end

function FCFDock_GetChatFrames(dock)
	return dock.DOCKED_CHAT_FRAMES;
end

function FCFDock_SetPrimary(dock, chatFrame)
	dock.primary = chatFrame;
	dock:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT", 0, 6);
	dock:SetPoint("BOTTOMRIGHT", chatFrame, "TOPRIGHT", 0, 6);
	
	chatFrame:SetScript("OnSizeChanged", function(self) FCFDock_OnPrimarySizeChanged(dock) end);
	
	if ( not FCFDock_GetSelectedWindow(dock) ) then
		FCFDock_SelectWindow(dock, chatFrame);
	end
	
	FCFDock_ForceReanchoring(dock);
	
	FCFDock_AddChatFrame(dock, chatFrame, 1);
end

function FCFDock_OnPrimarySizeChanged(dock)
	dock.isDirty = true;
	
	--We have to save off the current leftmost-tab before we resize the tabs.
	dock.leftTab = FCFDockScrollFrame_GetLeftmostTab(dock.scrollFrame);
	
	--We have to do it on the next frame to deal with issues caused by resizing the WoW client (frame positions may not be valid)
	dock:SetScript("OnUpdate", FCFDock_OnUpdate);
end

function FCFDock_OnUpdate(self)
	--These may fail if we're resizing the WoW client
	if ( FCFDock_UpdateTabs(self) and FCFDockScrollFrame_JumpToTab(self.scrollFrame, self.leftTab) ) then
		self.leftTab = nil;
		self:SetScript("OnUpdate", nil);
	end
end

function FCFDock_ForceReanchoring(dock)
	for index, chatFrame in pairs(dock.DOCKED_CHAT_FRAMES) do
		if ( dock.primary ~= chatFrame ) then
			chatFrame:ClearAllPoints();
			chatFrame:SetAllPoints(dock.primary);
		end
	end
end

function FCFDock_AddChatFrame(dock, chatFrame, position)
	if ( not dock.primary ) then
		error("Need a primary window before another can be added.");
	end
	
	if ( FCFDock_HasDockedChatFrame(dock, chatFrame) ) then
		return;	--We're already docked...
	end
	
	dock.isDirty = true;
	chatFrame.isDocked = 1;
	
	if ( position and position <= #dock.DOCKED_CHAT_FRAMES + 1 ) then
		assert(position ~=1 or chatFrame == dock.primary);
		tinsert(dock.DOCKED_CHAT_FRAMES, position, chatFrame);
	else
		tinsert(dock.DOCKED_CHAT_FRAMES, chatFrame);
	end
	
	FCFDock_HideInsertHighlight(dock);
	
	if ( dock.primary ~= chatFrame ) then
		chatFrame:ClearAllPoints();
		chatFrame:SetAllPoints(dock.primary);
		chatFrame:SetMovable(false);
		chatFrame:SetResizable(false);
	end
	
	if ( chatFrame.conversationButton ) then
		BNConversationButton_UpdateAttachmentPoint(chatFrame.conversationButton);
	end
	
	chatFrame.buttonFrame.minimizeButton:Hide();
	chatFrame.buttonFrame:SetAlpha(1.0);
	
	dock.overflowButton.list:Hide();
	FCFDock_UpdateTabs(dock);
end

function FCFDock_RemoveChatFrame(dock, chatFrame)
	assert(chatFrame ~= dock.primary or #dock.DOCKED_CHAT_FRAMES == 1);
	dock.isDirty = true;
	tDeleteItem(dock.DOCKED_CHAT_FRAMES, chatFrame);
	local chatTab = _G[chatFrame:GetName().."Tab"];
	chatFrame.isDocked = nil;
	chatTab:SetParent(UIParent);
	chatTab:SetFrameStrata("LOW");
	chatFrame:SetMovable(true);
	chatFrame:SetResizable(true);
	FCFTab_UpdateColors(chatTab, true);
	PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0, nil, nil, chatTab.textWidth);
	if ( FCFDock_GetSelectedWindow(dock) == chatFrame ) then
		FCFDock_SelectWindow(dock, dock.DOCKED_CHAT_FRAMES[1]);
	end
	
	if ( chatFrame.conversationButton ) then
		BNConversationButton_UpdateAttachmentPoint(chatFrame.conversationButton);
	end
	
	chatFrame.buttonFrame.minimizeButton:Show();
	dock.overflowButton.list:Hide();
	chatFrame:Show();
	FCFDock_UpdateTabs(dock);
end

function FCFDock_HasDockedChatFrame(dock, chatFrame)
	return tContains(dock.DOCKED_CHAT_FRAMES, chatFrame);
end

function FCFDock_SelectWindow(dock, chatFrame)
	assert(chatFrame)
	dock.isDirty = true;
	dock.selected = chatFrame;
	dock.overflowButton.list:Hide();
	FCFDock_UpdateTabs(dock);
	
	if ( ChatFrameMenuButton ) then
		if ( chatFrame.conversationButton and chatFrame.conversationButton:IsShown() ) then
			ChatFrameMenuButton:Hide();
		else
			ChatFrameMenuButton:Show();
		end
	end
end

function FCFDock_GetSelectedWindow(dock)
	return dock.selected;
end

function FCFDock_UpdateTabs(dock, forceUpdate)
	if ( not dock.isDirty and not forceUpdate ) then	--No changes have been made since the last update.
		return;
	end
	
	local scrollChild = dock.scrollFrame:GetScrollChild();
	local lastDockedStaticTab = nil;
	local lastDockedDynamicTab = nil;
	
	local numDynFrames = 0;	--Number of dynamicly sized frames.
	local selectedDynIndex = nil;
	
	for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
		local chatTab = _G[chatFrame:GetName().."Tab"];
		if ( chatFrame == FCFDock_GetSelectedWindow(dock) ) then
			chatFrame:Show();
		else
			chatFrame:Hide();
		end
		FCFTab_UpdateAlpha(chatFrame);
		chatTab:ClearAllPoints();
		chatTab:Show();
		FCFTab_UpdateColors(chatTab, chatFrame == FCFDock_GetSelectedWindow(dock));
		
		if ( chatFrame.isStaticDocked ) then
			chatTab:SetParent(dock);
			PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0);
			if ( lastDockedStaticTab ) then
				chatTab:SetPoint("LEFT", lastDockedStaticTab, "RIGHT", 0, 0);
			else
				chatTab:SetPoint("LEFT", dock, "LEFT", 0, 0);
			end
			lastDockedStaticTab = chatTab;
		else
			chatTab:SetParent(scrollChild);
			numDynFrames = numDynFrames + 1;
			
			if ( FCFDock_GetSelectedWindow(dock) == chatFrame ) then
				selectedDynIndex = numDynFrames;
			end
			
			if ( lastDockedDynamicTab ) then
				chatTab:SetPoint("LEFT", lastDockedDynamicTab, "RIGHT", 0, 0);
			else
				chatTab:SetPoint("LEFT", scrollChild, "LEFT", 0, 0);
			end
			lastDockedDynamicTab = chatTab;
		end
	end
	
	local dynTabSize, hasOverflow = FCFDock_CalculateTabSize(dock, numDynFrames);
	
	for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
		if ( not chatFrame.isStaticDocked ) then
			local chatTab = _G[chatFrame:GetName().."Tab"];
			PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0, dynTabSize);
		end
	end
	
	dock.scrollFrame:SetPoint("LEFT", lastDockedStaticTab, "RIGHT", 0, 0);
	if ( hasOverflow ) then
		dock.overflowButton:Show();
		dock.scrollFrame:SetPoint("BOTTOMRIGHT", dock.overflowButton, "BOTTOMLEFT", 0, 0);
	else
		dock.overflowButton:Hide();
		dock.scrollFrame:SetPoint("BOTTOMRIGHT", dock, "BOTTOMRIGHT", 0, -5);
	end
	
	--Cache some of this data on the scroll frame for animating to the selected tab.
	dock.scrollFrame.dynTabSize = dynTabSize;
	dock.scrollFrame.numDynFrames = numDynFrames;
	dock.scrollFrame.selectedDynIndex = selectedDynIndex;
	
	dock.isDirty = false;
	
	return FCFDock_ScrollToSelectedTab(dock);
end

--Returns dynTabSize, hasOverflow
function FCFDock_CalculateTabSize(dock, numDynFrames)
	local MIN_SIZE, MAX_SIZE = 60, 90;
	local scrollSize = dock.scrollFrame:GetWidth() + (dock.overflowButton:IsShown() and dock.overflowButton.width or 0); --We want the total width assuming no overflow button.
	
	--First, see if we can fit all the tabs at the maximum size
	if ( numDynFrames * MAX_SIZE < scrollSize ) then
		return MAX_SIZE, false;
	end
	
	if ( scrollSize / MIN_SIZE < numDynFrames ) then
		--Not everything fits, so we'll need room for the overflow button.
		scrollSize = scrollSize - dock.overflowButton.width;
	end
	
	--Figure out how many tabs we're going to be able to fit at the minimum size
	local numWholeTabs = min(floor(scrollSize / MIN_SIZE), numDynFrames)
	
	if ( numWholeTabs == 0 ) then
		return scrollSize, true;
	end
	
	--How big each tab should be.
	local tabSize = scrollSize / numWholeTabs;
	
	return tabSize, (numDynFrames > numWholeTabs);
end

function FCFDock_ScrollToSelectedTab(dock)
	if ( FCFDockScrollFrame_GetScrollDistanceNeeded(dock.scrollFrame, dock.scrollFrame.selectedDynIndex) ~= 0) then
		dock.scrollFrame:SetScript("OnUpdate", FCFDockScrollFrame_OnUpdate);
		return true;
	else
		return FCFDockScrollFrame_JumpToTab(dock.scrollFrame, FCFDockScrollFrame_GetLeftmostTab(dock.scrollFrame));	--Make sure we're exactly aligned with the tab.
	end
end

---These functions deal with the scroll frame handling dynamic tabs.
function FCFDockScrollFrame_OnUpdate(self, elapsed)
	local MOVEMENT_SPEED = 10;
	
	local totalDistanceNeeded = FCFDockScrollFrame_GetScrollDistanceNeeded(self, self.selectedDynIndex);
	if ( abs(totalDistanceNeeded) < 1.0 ) then	--Delta chosen through experimentation
		self:SetScript("OnUpdate", nil);
		FCFDockScrollFrame_JumpToTab(self, FCFDockScrollFrame_GetLeftmostTab(self));	--Make sure we're exactly aligned with the tab.
		return;
	end
	
	local currentPosition = self:GetHorizontalScroll();
	
	local distanceNoCap = totalDistanceNeeded * MOVEMENT_SPEED * elapsed;
	local distanceToMove = (totalDistanceNeeded > 0) and min(totalDistanceNeeded, distanceNoCap) or max(totalDistanceNeeded, distanceNoCap);
	
	self:SetHorizontalScroll(max(currentPosition + distanceToMove, 0));
end

function FCFDock_GetInsertIndex(dock, chatFrame, mouseX, mouseY)
	if ( chatFrame.isStaticDocked ) then
		local maxPosition = 0;
		for index, value in ipairs(dock.DOCKED_CHAT_FRAMES) do
			if ( value.isStaticDocked ) then
				local tab = _G[value:GetName().."Tab"];
				if ( mouseX < (tab:GetLeft() + tab:GetRight()) / 2 and	--Find the first tab we're on the left of. (Being on top of the tab, but left of the center counts)
					tab:GetID() ~= dock.primary:GetID()) then	--We never count as being to the left of the primary tab.
					return index;
				end
				maxPosition = index;
			end
		end
		--We aren't to the left of anything, so we're going into the far-right position.
		return maxPosition + 1;
	else
		--Find the dynamic insertion spot
		local maxPosition = 9^9;
		local leftTab = FCFDockScrollFrame_GetLeftmostTab(dock.scrollFrame);
		local numDynTabsDisplayed = dock.scrollFrame:GetWidth() / dock.scrollFrame.dynTabSize;
		
		local currTabNum = 0;
		for index, value in ipairs(dock.DOCKED_CHAT_FRAMES) do
			if ( not value.isStaticDocked ) then
				currTabNum = currTabNum + 1;
				if ( currTabNum >= leftTab and currTabNum < leftTab + numDynTabsDisplayed ) then
					local tab = _G[value:GetName().."Tab"];
					if ( mouseX < (tab:GetLeft() + tab:GetRight())/2 ) then
						return index;
					end
					maxPosition = index;
				end
			end
		end
		return min(#dock.DOCKED_CHAT_FRAMES + 1, maxPosition + 1);
	end
end

function FCFDock_PlaceInsertHighlight(dock, chatFrame, mouseX, mouseY)
	local insert = FCFDock_GetInsertIndex(dock, chatFrame, mouseX, mouseY);
	
	local attachFrame = dock.primary;
	
	local leftDynTab = FCFDockScrollFrame_GetLeftmostTab(dock.scrollFrame);
	local numDynTabsDisplayed = dock.scrollFrame:GetWidth() / dock.scrollFrame.dynTabSize;
	
	local dynamicIndex = 0;
	for index, value in ipairs(dock.DOCKED_CHAT_FRAMES) do
		if ( index < insert ) then
			if ( value.isStaticDocked ) then
				attachFrame = value;
			else
				dynamicIndex = dynamicIndex + 1;
				if ( dynamicIndex >= leftDynTab and dynamicIndex < leftDynTab + numDynTabsDisplayed ) then
					attachFrame = value;
				end
			end
		end
	end
	
	dock.insertHighlight:ClearAllPoints();
	dock.insertHighlight:SetPoint("BOTTOMLEFT", _G[attachFrame:GetName().."Tab"], "BOTTOMRIGHT", -15, -4);
	dock.insertHighlight:Show();
end

function FCFDock_HideInsertHighlight(dock)
	dock.insertHighlight:Hide();
end

function FCFDock_SetDirty(dock)
	dock.isDirty = true;
end

function FCFDockScrollFrame_GetScrollDistanceNeeded(scrollFrame, dynFrameIndex)
	
	local firstIndex = (scrollFrame:GetHorizontalScroll() / scrollFrame.dynTabSize) + 1;
	
	local numDisplayedFrames = scrollFrame:GetWidth() / scrollFrame.dynTabSize;
	local lastIndex = firstIndex + numDisplayedFrames - 1;

	if ( dynFrameIndex and dynFrameIndex < firstIndex ) then	--Need to scroll left to get to the selected button
		return (dynFrameIndex - firstIndex) * scrollFrame.dynTabSize;
	elseif ( dynFrameIndex and dynFrameIndex > lastIndex )	then --Need to scroll right to get to the selected button
		return (dynFrameIndex - lastIndex) * scrollFrame.dynTabSize;
	elseif (  firstIndex > 1 and scrollFrame.numDynFrames < lastIndex ) then --Need to scroll left to fill in empty space at the end.
		return (scrollFrame.numDynFrames - lastIndex) * scrollFrame.dynTabSize;
	else
		return 0;
	end
end

function FCFDockScrollFrame_GetLeftmostTab(scrollFrame)
	return floor((scrollFrame:GetHorizontalScroll() / scrollFrame.dynTabSize) + 0.5) + 1;
end

function FCFDockScrollFrame_JumpToTab(scrollFrame, leftTab)
	--If we have a selected frame, make sure it's still in view.
	local numTabsDisplayed = scrollFrame:GetWidth() / scrollFrame.dynTabSize;
	
	if ( scrollFrame.selectedDynIndex ) then
		if ( scrollFrame.selectedDynIndex >= leftTab + numTabsDisplayed ) then
			leftTab = scrollFrame.selectedDynIndex - numTabsDisplayed + 1;
		elseif ( scrollFrame.selectedDynIndex < leftTab ) then
			leftTab = scrollFrame.selectedDynIndex;
		end
	end
	
	--Make sure, if we can show more frames, we do.
	leftTab = min(leftTab, scrollFrame.numDynFrames - numTabsDisplayed + 1);
	
	--And make sure we never go to the left of 1 (for example, if we have extra space)
	leftTab = max(leftTab, 1);
	
	scrollFrame:SetHorizontalScroll(scrollFrame.dynTabSize * (leftTab - 1));
	
	return FCFDockOverflowButton_UpdatePulseState(scrollFrame:GetParent().overflowButton);
end

--Dock list related functions
function FCFDockOverflow_CloseLists()
	local list = GENERAL_CHAT_DOCK.overflowButton.list;
	if ( list:IsShown() ) then
		list:Hide();
		return true;
	else
		return false;
	end
end

function FCFDockOverflowButton_UpdatePulseState(self)
	local dock = self:GetParent();
	local shouldPulse = false;
	for _, chatFrame in pairs(FCFDock_GetChatFrames(dock)) do
		local chatTab = _G[chatFrame:GetName().."Tab"];
		if ( not chatFrame.isStaticDocked and chatTab.alerting) then
			--Make sure the rects are valid. (Not always the case when resizing the WoW client
			if ( not chatTab:GetRight() or not dock.scrollFrame:GetRight() ) then
				return false;
			end
			--Check if it's off the screen.
			local DELTA = 3;	--Chosen through experimentation
			if ( chatTab:GetRight() < (dock.scrollFrame:GetLeft() + DELTA) or chatTab:GetLeft() > (dock.scrollFrame:GetRight() - DELTA) ) then
				shouldPulse = true;
				break;
			end
		end
	end
	
	if ( shouldPulse ) then
		UIFrameFlash(self:GetHighlightTexture(), 1.0, 1.0, -1, true, 0, 0, "chat");
		self:LockHighlight();
		self.alerting = true;
	else
		UIFrameFlashStop(self:GetHighlightTexture());
		self:UnlockHighlight();
		self:GetHighlightTexture():Show();
		self.alerting = false;
	end
	
	if ( self.list:IsShown() ) then
		FCFDockOverflowList_Update(self.list, dock);
	end
	return true;
end

function FCFDockOverflowButton_OnClick(self, button)
	PlaySound("UChatScrollButton");
	if ( self.list:IsShown() ) then
		self.list:Hide();
	else
		FCFDockOverflowList_Update(self.list, self:GetParent());
		self.list:Show();
	end
end

function FCFDockOverflowButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_CHAT_COLOR" and self.list:IsShown() ) then
		FCFDockOverflowList_Update(self.list, self:GetParent());
	end		
end

function FCFDockOverflowList_Update(list, dock)
	local dockedFrames = FCFDock_GetChatFrames(dock);
	
	list:SetHeight(#dockedFrames *15 + 35);
	
	list.numTabs:SetFormattedText(CHAT_WINDOWS_COUNT, #dockedFrames);
	
	for i = 1, #dockedFrames do
		local button = list.buttons[i];
		if ( not button ) then
			list.buttons[i] = CreateFrame("Button", list:GetName().."Button"..i, list, "DockManagerOverflowListButtonTemplate");
			button = list.buttons[i];
			
			if ( not list.buttons[i-1] ) then
				button:SetPoint("TOPLEFT", list, "TOPLEFT", 5, -19);
			else
				button:SetPoint("TOPLEFT", list.buttons[i-1], "BOTTOMLEFT", 0, -3);
			end
			button:SetWidth(list:GetWidth() - 10);	-- buttons are 5 pixels in on both sides
		end
		
		FCFDockOverflowListButton_SetValue(button, dockedFrames[i]);
	end
	
	for i = #dockedFrames + 1, #list.buttons do
		list.buttons[i]:Hide();
	end
end

function FCFDockOverflowListButton_SetValue(button, chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	button.chatFrame = chatFrame;
	button:SetText(chatFrame.name);
	
	local colorTable = chatTab.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;
	
	if ( chatTab.selectedColorTable ) then
		button:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		button:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	button.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	
	if ( chatTab.conversationIcon ) then
		button.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
		button.conversationIcon:Show();
	else
		button.conversationIcon:Hide();
	end
	
	if ( chatTab.alerting ) then
		button.alerting = true;
		UIFrameFlash(button.glow, 1.0, 1.0, -1, false, 0, 0, "chat");
	else
		button.alerting = false;
		UIFrameFlashStop(button.glow);
	end
	
	button:Show();
end

function FCFDockOverflowListButton_OnClick(self, button)
	FCFDock_SelectWindow(self:GetParent():GetParent():GetParent(), self.chatFrame);
end

---------------------------------------------------
-----------Temp Window Manager-------------
----------------------------------------------------
local dedicatedWindows = {};

local function FCFManager_GetToken(chatType, chatTarget)
	return strlower(chatType)..(chatTarget and ";;"..strlower(chatTarget) or "");
end

function FCFManager_RegisterDedicatedFrame(chatFrame, chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget);
	if ( not dedicatedWindows[token] ) then
		dedicatedWindows[token] = {};
	end
	
	if ( not tContains(dedicatedWindows[token], chatFrame) ) then
		tinsert(dedicatedWindows[token], chatFrame);
	end
end

function FCFManager_UnregisterDedicatedFrame(chatFrame, chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget);
	local windowList = dedicatedWindows[token];
	if ( windowList ) then
		tDeleteItem(windowList, chatFrame);
	end
end

function FCFManager_GetNumDedicatedFrames(chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget);
	local windowList = dedicatedWindows[token];
	return (windowList and #windowList or 0);
end

function FCFManager_ShouldSuppressMessage(chatFrame, chatType, chatTarget)
	--Using GetToken probably isn't the best way to do this due to the string concatenation, but it's the easiest to get in quickly.
	if ( chatFrame.chatType and FCFManager_GetToken(chatType, chatTarget) == FCFManager_GetToken(chatFrame.chatType, chatFrame.chatTarget) ) then
		--This frame is a dedicated frame of this type, so we should always display.
		return false;
	end
	
	if ( chatType == "BN_CONVERSATION" and GetCVar("conversationMode") == "popout" ) then
		return true;
	end
	
	return false;
end

function FloatingChatFrameManager_OnLoad(self)
	--Register for BN_CONVERSATION related messages to be able to spawn off new windows as needed
	for _, event in pairs(ChatTypeGroup["BN_CONVERSATION"]) do
		self:RegisterEvent(event);
	end
end

function FloatingChatFrameManager_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( strsub(event, 1, 9) == "CHAT_MSG_" ) then
		local chatType = strsub(event, 10);
		local chatGroup = Chat_GetChatCategory(chatType);
		
		if ( chatGroup == "BN_CONVERSATION" ) then
			if ( GetCVar("conversationMode") == "popout" ) then
				if( not (event == "CHAT_MSG_BN_CONVERSATION_NOTICE" and arg1 == "YOU_LEFT_CONVERSATION") ) then
					local chatTarget = tostring(select(8, ...));
					if ( FCFManager_GetNumDedicatedFrames(chatGroup, chatTarget) == 0 ) then
						local chatFrame = FCF_OpenTemporaryWindow(chatGroup, chatTarget);
						chatFrame:GetScript("OnEvent")(chatFrame, event, ...);	--Re-fire the event for the frame.
					end
				end
			end
		end
	end
end