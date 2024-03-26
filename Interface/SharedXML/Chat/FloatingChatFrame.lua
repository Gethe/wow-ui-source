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

CHAT_FRAME_DEFAULT_FONT_SIZE = 14;

CHAT_FONT_HEIGHTS = {
	[1] = 12,
	[2] = 14,
	[3] = 16,
	[4] = 18
};

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

PrimaryChatFrameMixin = {};

function PrimaryChatFrameMixin:OnLoad()
	-- Edit Mode doesn't exist at glues
	if EditModeSystemMixin then
		EditModeSystemMixin.OnSystemLoad(self);
	end

	tinsert(CHAT_FRAMES, self:GetName());
	ChatFrame_OnLoad(self);
	DEFAULT_CHAT_FRAME = ChatFrame1;
	SELECTED_CHAT_FRAME = ChatFrame1;
	SELECTED_DOCK_FRAME = ChatFrame1;

	self.isStaticDocked = true;
	FCFDock_SetPrimary(GENERAL_CHAT_DOCK, self);
	ChatEdit_SetLastActiveWindow(self.editBox);

	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS");

	FloatingChatFrame_SetupScrolling(self);

	-- Default chat tab remains locked and is controlled via edit mode for position and size
	FCF_SetLocked(self, true);
	self.ResizeButton:Hide();
end

function PrimaryChatFrameMixin:OnEvent(event, ...)
	ChatFrame_OnEvent(self, event, ...);
	FloatingChatFrame_OnEvent(self, event, ...);
end

function FloatingChatFrame_OnLoad(self)
	--IMPORTANT NOTE: This function isn't run by ChatFrame1.
	tinsert(CHAT_FRAMES, self:GetName());

	FCF_SetTabPosition(self, 0);
	FloatingChatFrame_Update(self:GetID());

	FCFTab_UpdateColors(_G[self:GetName().."Tab"], true);

	local chatTab = _G[self:GetName().."Tab"];
	chatTab.mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA;
	chatTab.noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA;

	if FRAMELOCK_STATES then
		FRAMELOCK_STATES.COMMENTATOR_SPECTATING_MODE[self:GetName()] = "hidden";
		FRAMELOCK_STATES.COMMENTATOR_SPECTATING_MODE[self:GetName().."Editbox"] = "hidden";
		FRAMELOCK_STATES.COMMENTATOR_SPECTATING_MODE[chatTab:GetName()] = "hidden";
		UpdateFrameLock(self);
		UpdateFrameLock(chatTab);
	end

	self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollToBottomButton, "TOPLEFT", 0, 2);

	FloatingChatFrame_SetupScrolling(self);
end

function FloatingChatFrame_UpdateBackgroundAnchors(self)
	local scrollbarWidth = 0;
	if self.ScrollBar then
		-- Width of MinimalScrollBar. Width fails to be evaluated at runtime, likely to frame rect validation issues.
		scrollbarWidth = 8;
	end

	local quickButtonHeight = 0;
	if self.CombatLogQuickButtonFrame then
		quickButtonHeight = self.CombatLogQuickButtonFrame:GetHeight();
	end

	self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 3 + quickButtonHeight);
	self.Background:SetPoint("TOPRIGHT", self, "TOPRIGHT", 7 + scrollbarWidth, 3 + quickButtonHeight);
	self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -2, -6);
	self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 7 + scrollbarWidth, -6);
end

function FloatingChatFrame_SetupScrolling(self)
	FloatingChatFrame_UpdateBackgroundAnchors(self);

	self:AddOnDisplayRefreshedCallback(function()
		FloatingChatFrame_UpdateScroll(self);
	end);
	FloatingChatFrame_UpdateScroll(self);
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

function FloatingChatFrame_UpdateScroll(self)
	local numMessages = self:GetNumMessages();
	local isShown = numMessages > 1;
	self.ScrollBar:SetShown(isShown);
	if isShown then
		-- If the chat frame was already faded in, and something caused the scrollbar to show
		-- it also needs to update fading in addition to showing.
		if (self.hasBeenFaded) then
			FCF_FadeInScrollbar(self);
		end
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
		local name, size, r, g, b, a, isShown, isLocked, isDocked, isUninteractable = GetChatWindowInfo(id);
		if size == 0 then
			size = CHAT_FRAME_DEFAULT_FONT_SIZE;
		end
		return name, size, r, g, b, a, isShown, isLocked, isDocked, isUninteractable;
	end

	return "", CHAT_FRAME_DEFAULT_FONT_SIZE, 0, 0, 0, 0;
end

function FCF_CopyChatSettings(copyTo, copyFrom)
	local name, fontSize, r, g, b, a, shown, locked, docked, uninteractable = FCF_GetChatWindowInfo(copyFrom:GetID());

	FCF_SetWindowColor(copyTo, r, g, b, true);
	FCF_SetWindowAlpha(copyTo, a, true);
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
	FCF_SetWindowName(chatFrame, name, true)

	if ( onUpdateEvent ) then
		-- Set Frame Color and Alpha
		FCF_SetWindowColor(chatFrame, r, g, b, true);
		FCF_SetWindowAlpha(chatFrame, a, true);

		-- DEFAULT_CHAT_FRAME should remain locked. It is now managed by edit mode
		if (chatFrame ~= DEFAULT_CHAT_FRAME) then
			FCF_SetLocked(chatFrame, locked);
		end

		FCF_SetUninteractable(chatFrame, uninteractable);
	end

	if ( (id == 2) and IsOnGlueScreen() ) then
		docked = false;
		shown = false;
	end

	if ( shown ) then
		if ( not chatFrame.minimized ) then
			FCF_CheckShowChatFrame(chatFrame);
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
				FCF_CheckShowChatFrame(chatTab);
			end
		elseif ( not chatFrame.isTemporary and not IsBuiltinChatWindow(chatFrame) ) then
			FCF_Close(chatFrame);
		end
	end

	if ( not chatFrame.isTemporary and not chatFrame.isDocked) then
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

				local fontFile, fontHeight, fontFlags = chatFrame:GetFont();
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
	local isOnGlueScreen = IsOnGlueScreen();

	if ( not isOnGlueScreen ) then
		local dropDownChatFrame = FCF_GetCurrentChatFrame(dropDown);
		if( dropDownChatFrame ) then
			info = UIDropDownMenu_CreateInfo();
			if ( dropDownChatFrame == DEFAULT_CHAT_FRAME ) then
				-- EditModeManagerFrame is not available at glues.
				if ( EditModeManagerFrame and C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.EditMode) ) then
					-- If you are the default chat frame then show the enter edit mode option
					info.text = HUD_EDIT_MODE_MENU;
					info.func = function() ShowUIPanel(EditModeManagerFrame); end;
					info.disabled =  not EditModeManagerFrame:CanEnterEditMode();
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				end
			else
				-- If you aren't the default chat frame then show lock/unlock option
				if( dropDownChatFrame == GENERAL_CHAT_DOCK.primary ) then
					info.text = dropDownChatFrame.isLocked and UNLOCK_WINDOW or LOCK_WINDOW;
					info.func = FCF_ToggleLockOnDockedFrame;
				else
					if(dropDownChatFrame.isDocked) then
						info.text = UNDOCK_WINDOW;
						info.func = FCF_ToggleLock;
					elseif ( dropDownChatFrame.isLocked ) then
						info.text = UNLOCK_WINDOW;
						info.func = FCF_ToggleLock;
					else
						info.text = LOCK_WINDOW;
						info.func = FCF_ToggleLock;
					end
				end

				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);	
			end

			--Add Uninteractable button
			info = UIDropDownMenu_CreateInfo();
			info.text = dropDownChatFrame.isUninteractable and MAKE_INTERACTABLE or MAKE_UNINTERACTABLE;
			info.func = FCF_ToggleUninteractable;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
		end

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
			if ( not FCF_CanOpenNewWindow() ) then
				info.disabled = 1;
			end
			UIDropDownMenu_AddButton(info);
		end

		-- Close current chat window
		if ( chatFrame and not IsBuiltinChatWindow(chatFrame) ) then
			if ( not chatFrame.isTemporary ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = CLOSE_CHAT_WINDOW;
				info.func = FCF_PopInWindow;
				info.arg1 = dropDownChatFrame;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			else
				if (chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER" ) then
					info = UIDropDownMenu_CreateInfo();
					info.text = CLOSE_CHAT_WHISPER_WINDOW;
					info.func = FCF_PopInWindow;
					info.arg1 = dropDownChatFrame;
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				else
					info = UIDropDownMenu_CreateInfo();
					info.text = CLOSE_CHAT_WINDOW;
					info.func = FCF_Close;
					info.arg1 = dropDownChatFrame;
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				end
			end
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

	if ( not isOnGlueScreen ) then
		-- Set Background color
		info = UIDropDownMenu_CreateInfo();
		info.text = BACKGROUND;
		info.hasColorSwatch = 1;
		info.notCheckable = 1;
		info.r = r;
		info.g = g;
		info.b = b;
		info.opacity = a;
		info.swatchFunc = FCF_SetChatWindowBackGroundColor;
		info.func = UIDropDownMenuButton_OpenColorPicker;
		--info.notCheckable = 1;
		info.hasOpacity = 1;
		info.opacityFunc = FCF_SetChatWindowOpacity;
		info.cancelFunc = FCF_CancelWindowColorSettings;
		UIDropDownMenu_AddButton(info);
	end

	if ( not isOnGlueScreen and not isTemporary ) then
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

function FCF_IsChatWindowIndexReserved(chatWindowIndex)
	return chatWindowIndex <= C_ChatInfo.GetNumReservedChatWindows();
end

function FCF_IsChatWindowIndexActive(chatWindowIndex)
	local shown = select(7, FCF_GetChatWindowInfo(chatWindowIndex));
	if shown then
		return true;
	end

	local chatFrame = _G["ChatFrame"..chatWindowIndex];
	return (chatFrame and chatFrame.isDocked);
end

function FCF_IterateActiveChatWindows(callback)
	for i = 1, NUM_CHAT_WINDOWS do
		if ( FCF_IsChatWindowIndexActive(i) ) then
			local chatFrame = _G["ChatFrame"..i];
			if callback(chatFrame, i) then
				break;
			end
		end
	end
end

function FCF_GetNumActiveChatFrames()
	local count = 0;
	local function IncreaseCount()
		count = count + 1;
	end

	FCF_IterateActiveChatWindows(IncreaseCount);
	return count;
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

function FCF_OpenNewWindow(name, noDefaultChannels)
	local chatFrameIndex = FCF_GetNextOpenChatWindowIndex();
	if chatFrameIndex == nil then
		return;
	end

	local chatFrame = _G["ChatFrame"..chatFrameIndex];
	local chatTab = _G["ChatFrame"..chatFrameIndex.."Tab"];
	if ( not name or name == "" ) then
		name = format(CHAT_NAME_TEMPLATE, chatFrameIndex);
	end

	-- initialize the frame
	FCF_SetWindowName(chatFrame, name);
	FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
	FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
	SetChatWindowLocked(chatFrameIndex, false);

	-- clear stale messages
	chatFrame:Clear();

	-- Listen to the standard messages
	ChatFrame_RemoveAllMessageGroups(chatFrame);
	ChatFrame_RemoveAllChannels(chatFrame);
	ChatFrame_ReceiveAllPrivateMessages(chatFrame);

	if ( not noDefaultChannels ) then
		ChatFrame_AddMessageGroup(chatFrame, "SAY");
		ChatFrame_AddMessageGroup(chatFrame, "YELL");
		ChatFrame_AddMessageGroup(chatFrame, "GUILD");
		ChatFrame_AddMessageGroup(chatFrame, "WHISPER");
		ChatFrame_AddMessageGroup(chatFrame, "BN_WHISPER");
		ChatFrame_AddMessageGroup(chatFrame, "PARTY");
		ChatFrame_AddMessageGroup(chatFrame, "PARTY_LEADER");
		ChatFrame_AddMessageGroup(chatFrame, "CHANNEL");
	end

	--Clear the edit box history.
	chatFrame.editBox:ClearHistory();

	-- Show the frame and tab
	FCF_CheckShowChatFrame(chatFrame);
	FCF_CheckShowChatFrame(chatTab);
	SetChatWindowShown(chatFrameIndex, true);

	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), true);
	FCF_FadeInChatFrame(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));
	ChatEdit_SetLastActiveWindow(chatFrame.editBox);
	return chatFrame, chatFrameIndex;
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
	elseif ( chatType == "PET_BATTLE_COMBAT_LOG" ) then
		name = PET_BATTLE_COMBAT_LOG;
	end
	FCF_SetWindowName(chatFrame, name);


	--Set up the window to receive the message types we want.
	chatFrame.chatType = chatType;
	chatFrame.chatTarget = chatTarget;

	ChatFrame_RemoveAllMessageGroups(chatFrame);
	ChatFrame_RemoveAllChannels(chatFrame);
	ChatFrame_ReceiveAllPrivateMessages(chatFrame);

	ChatFrame_AddMessageGroup(chatFrame, chatType);

	-- This is to display "friend is online"/"friend is offline" messages
	if ( chatType == "BN_WHISPER" ) then
		ChatFrame_AddSingleMessageType(chatFrame, "CHAT_MSG_BN_INLINE_TOAST_ALERT");
		ChatFrame_AddSingleMessageType(chatFrame, "CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE");
	elseif ( chatType == "WHISPER" ) then
		ChatFrame_AddSingleMessageType(chatFrame, "CHAT_MSG_SYSTEM");
	elseif ( chatType == "PET_BATTLE_COMBAT_LOG" ) then
		ChatFrame_AddMessageGroup(chatFrame, "PET_BATTLE_INFO");
	end

	chatFrame.editBox:SetAttribute("chatType", chatType);
	chatFrame.editBox:SetAttribute("stickyType", chatType);

	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		chatFrame.editBox:SetAttribute("tellTarget", chatTarget);
		ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget);
	elseif ( chatType == "PET_BATTLE_COMBAT_LOG" ) then
		chatFrame.editBox:SetAttribute("chatType", "SAY");
		chatFrame.editBox:SetAttribute("stickyType", "SAY");
	end

	-- Set up the colors
	local info = ChatTypeInfo[chatType];
	chatTab.selectedColorTable = { r = info.r, g = info.g, b = info.b };
	FCFTab_UpdateColors(chatTab, not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));

	chatFrame:SetResizeBounds(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT);

	--Set the icon
	local icon;
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		icon = "Interface\\ChatFrame\\UI-ChatWhisperIcon";
	elseif ( chatType == "PET_BATTLE_COMBAT_LOG" ) then
		icon = "Interface\\Icons\\Tracking_WildPet";
	else
		icon = "Interface\\ChatFrame\\UI-ChatConversationIcon";
	end

	chatTab.conversationIcon:SetTexture(icon);
	if ( chatFrame.minFrame ) then
		chatFrame.minFrame.conversationIcon:SetTexture(icon);
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

		chatTab.Text:ClearAllPoints(); 
		chatTab.Text:SetPoint("LEFT", chatTab.Left, "RIGHT", 10, -6);
		chatTab.Text:SetJustifyH("LEFT");
		chatTab.sizePadding = 10;

		chatFrame = CreateFrame("ScrollingMessageFrame", "ChatFrame"..maxTempIndex, UIParent, "FloatingChatFrameTemplate", maxTempIndex);

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
		--Copy over messages
		local accessID = ChatHistory_GetAccessID(chatType, chatTarget);
		for i = 1, sourceChatFrame:GetNumMessages() do
			local text, r, g, b, chatTypeID, messageAccessID, lineID = sourceChatFrame:GetMessageInfo(i);
			if accessID == messageAccessID then
				chatFrame:AddMessage(text, r, g, b, chatTypeID, messageAccessID, lineID);
			end
		end

		--Stop displaying this type of chat in the old chat frame.
		--Remove the messages from the old frame.
		if (not (chatType == "WHISPER" and GetCVar("whisperMode") == "popout_and_inline")
			and not (chatType == "BN_WHISPER" and GetCVar("whisperMode") == "popout_and_inline") ) then

			if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
				ChatFrame_ExcludePrivateMessageTarget(sourceChatFrame, chatTarget);
			end

			sourceChatFrame:RemoveMessagesByPredicate(function(text, r, g, b, chatTypeID, messageAccessID, lineID) return messageAccessID == accessID; end);
		end
	end

	--Close the Editbox
	ChatEdit_DeactivateChat(chatFrame.editBox);

	-- Show the frame and tab
	FCF_CheckShowChatFrame(chatFrame);
	FCF_CheckShowChatFrame(chatTab);

	-- Dock the frame by default
	FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), selectWindow);
	return chatFrame;
end

function FCF_RemoveAllMessagesFromChanSender(chatFrame, chanSender)
	local ids = ChatHistory_GetAllAccessIDsByChanSender(chanSender);
	if #ids > 0 then
		chatFrame:RemoveMessagesByPredicate(function(text, r, g, b, chatTypeID, messageAccessID, lineID)
			for i, id in ipairs(ids) do
				if lineID == id then
					return true;
				end
			end
			return false;
		end);
	end
end

function FCF_RenameChatWindow_Popup()
	local dialog = StaticPopup_Show("NAME_CHAT");
	dialog.data = FCF_GetCurrentChatFrameID();
end

function FCF_NewChatWindow()
	StaticPopup_Show("NAME_CHAT");
end

function FCF_RedockAllWindows()
	StaticPopup_Show("CONFIRM_REDOCK_CHAT");
end

function FCF_ResetAllWindows()
	StaticPopup_Show("RESET_CHAT");
end

function FCF_SetWindowName(frame, name, doNotSave)
	if ( not name or name == "") then
		-- Hack to initialize the chat window names, since globalstrings are not available on init
		if ( frame:GetID() == 1 ) then
			name = GENERAL;
			doNotSave = nil;
		elseif ( frame:GetID() == 2 ) then
			name = COMBAT_LOG;
			doNotSave = nil;
		elseif ( frame:GetID() == 3 ) then
			name = VOICE;
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
	tab.textWidth = tab.Text:GetWidth();
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
	frame.oldAlpha = alpha or DEFAULT_CHATFRAME_ALPHA;
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
	local alpha = ColorPickerFrame:GetColorAlpha();
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
	if ( chatFrame == DEFAULT_CHAT_FRAME ) then
		if ( GMChatFrame ) then
			GMChatFrame:SetFont(fontFile, fontSize, fontFlags);
		end

		if ( CommunitiesFrame ) then
			CommunitiesFrame.Chat.MessageFrame:SetFont(fontFile, fontSize, fontFlags);
		end
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
	if ( previousValues.a ) then
		FCF_SetWindowAlpha(FCF_GetCurrentChatFrame(), previousValues.a);
	end
end

function FCF_StripChatMsg(string)
	if ( strsub(string,1,8) == "CHAT_MSG" ) then
		return strsub(string,10);
	else
		return string;
	end
end

function FCF_ToggleLockOnDockedFrame()
	local chatFrame = FCF_GetCurrentChatFrame();
	local newLockValue = not chatFrame.isLocked;

	for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
		FCF_SetLocked(frame, newLockValue);
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
			FCF_CheckShowChatFrame(chatFrame);
		end
		FCF_SetLocked(chatFrame, false);
	else
		FCF_SetLocked(chatFrame, true);
	end
end

function FCF_UpdateScrollbarAnchors(chatFrame)
	if chatFrame.ScrollBar then
		chatFrame.ScrollBar:ClearAllPoints();
		chatFrame.ScrollBar:SetPoint("TOPLEFT", chatFrame, "TOPRIGHT", 0, 0);
	
		if chatFrame.ScrollToBottomButton:IsShown() then
			chatFrame.ScrollBar:SetPoint("BOTTOMLEFT", chatFrame.ScrollToBottomButton, "TOPLEFT", 0, 2);
		elseif chatFrame.ResizeButton:IsShown() then
			chatFrame.ScrollBar:SetPoint("BOTTOM", chatFrame.ResizeButton, "TOP", 0, 0);
		else
			chatFrame.ScrollBar:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMRIGHT", 0, 0);
		end
	end
end

function FCF_UpdateResizeButton(chatFrame)
	local showResize = chatFrame ~= DEFAULT_CHAT_FRAME and not (chatFrame.isUninteractable or chatFrame.isLocked);
	chatFrame.ResizeButton:SetShown(showResize);
	FCF_UpdateScrollbarAnchors(chatFrame);
end

function FCF_SetLocked(chatFrame, isLocked)
	chatFrame.isLocked = isLocked;
	SetChatWindowLocked(chatFrame:GetID(), isLocked);

	FCF_UpdateResizeButton(chatFrame);
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

function FCF_SetUninteractable(chatFrame, isUninteractable)
	chatFrame.isUninteractable = isUninteractable;
	SetChatWindowUninteractable(chatFrame:GetID(), isUninteractable);
	if ( not chatFrame.overrideHyperlinksEnabled ) then
		chatFrame:SetHyperlinksEnabled(not isUninteractable);
	end

	FCF_UpdateResizeButton(chatFrame);
end

function FCF_FadeInScrollbar(chatFrame)
	if chatFrame.ScrollBar and chatFrame.ScrollBar:IsShown() then
		UIFrameFadeIn(chatFrame.ScrollBar, CHAT_FRAME_FADE_TIME, chatFrame.ScrollBar:GetAlpha(), .6);
	
		if chatFrame.ScrollToBottomButton then
			UIFrameFadeIn(chatFrame.ScrollToBottomButton, .1, chatFrame.ScrollToBottomButton:GetAlpha(), .65);
		end
	end
end

function FCF_FadeOutScrollbar(chatFrame)
	if chatFrame.ScrollBar and chatFrame.ScrollBar:IsShown() then
		UIFrameFadeOut(chatFrame.ScrollBar, CHAT_FRAME_FADE_OUT_TIME, chatFrame.ScrollBar:GetAlpha(), 0);
	
		if chatFrame.ScrollToBottomButton then
			if UIFrameIsFlashing(chatFrame.ScrollToBottomButton.Flash) then
				UIFrameFadeRemoveFrame(chatFrame.ScrollToBottomButton);
				chatFrame.ScrollToBottomButton:SetAlpha(1);
			else
				UIFrameFadeOut(chatFrame.ScrollToBottomButton, CHAT_FRAME_FADE_OUT_TIME, chatFrame.ScrollToBottomButton:GetAlpha(), 0);
			end
		end
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

	FCF_FadeInScrollbar(chatFrame);
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

	FCF_FadeOutScrollbar(chatFrame);
end

local LAST_CURSOR_X, LAST_CURSOR_Y;
function FCF_OnUpdate(elapsed)
	local cursorX, cursorY = GetCursorPosition();

	for _, frameName in pairs(CHAT_FRAMES) do
		local chatFrame = _G[frameName];
		if ( chatFrame:IsShown() ) then
			local topOffset = 28;
			if ( IsCombatLog(chatFrame) ) then
				topOffset = topOffset + CombatLogQuickButtonFrame_Custom:GetHeight();
			end
			--Items that will always cause the frame to fade in.
			if ( MOVING_CHATFRAME or chatFrame.ResizeButton:GetButtonState() == "PUSHED" or
				(chatFrame.isDocked and GENERAL_CHAT_DOCK.overflowButton.list:IsShown()) or
				(chatFrame.ScrollBar and chatFrame.ScrollBar:IsThumbMouseDown())) then
				chatFrame.mouseOutTime = 0;
				if ( not chatFrame.hasBeenFaded ) then
					FCF_FadeInChatFrame(chatFrame);
				end
			--Things that will cause the frame to fade in if the mouse is stationary.
			elseif (chatFrame:IsMouseOver(topOffset, -2, -2, 2) or	--This should be slightly larger than the hit rect insets to give us some wiggle room.
				(chatFrame.isDocked and QuickJoinToastButton:IsMouseOver()) or
				(chatFrame.ScrollBar and (chatFrame.ScrollBar:IsThumbMouseDown() or chatFrame.ScrollBar:IsMouseOver())) or
				(chatFrame.ScrollToBottomButton and chatFrame.ScrollToBottomButton:IsMouseOver()) or
				(chatFrame.buttonFrame:IsMouseOver())) then
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
	if (chatFrame == DEFAULT_CHAT_FRAME) then
		-- Default chat frame is now controlled via edit mode
		return;
	end

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
	if ( chatFrame == GENERAL_CHAT_DOCK.primary or not chatFrame.isLocked ) then
		for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
			FCF_SetButtonSide(frame, FCF_GetButtonSide(GENERAL_CHAT_DOCK.primary));
		end
	end

	if ( not IsMouseButtonDown(self.dragButton) ) then
		FCFTab_OnDragStop(self, self.dragButton);
		self.dragButton = nil;
		self:SetScript("OnUpdate", nil);
	end

	-- TODO: Update ChatAlertFrame justifications, removed bnet toast update from here
end

function FCFTab_OnDragStop(self, button)
	FCF_StopDragging(_G["ChatFrame"..self:GetID()]);
end

DEFAULT_TAB_SELECTED_COLOR_TABLE = { r = 1, g = 0.5, b = 0.25 };

function FCFTab_UpdateColors(self, selected)
	if ( selected ) then
		self.ActiveLeft:Show();
		self.ActiveMiddle:Show();
		self.ActiveRight:Show();
	else
		self.ActiveLeft:Hide();
		self.ActiveMiddle:Hide();
		self.ActiveRight:Hide();
	end

	local colorTable = self.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;

	if ( self.selectedColorTable ) then
		self:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
	else
		self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	self.ActiveLeft:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.ActiveMiddle:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.ActiveRight:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);

	self.HighlightLeft:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.HighlightMiddle:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	self.HighlightRight:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
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
	local leftDist =  chatFrame:GetLeft() or 0;
	local rightDist = GetScreenWidth() - (chatFrame:GetRight() or 0);
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

	if ( buttonSide == "left" ) then
		chatFrame.buttonFrame:SetPoint("TOPRIGHT", chatFrame.Background, "TOPLEFT", -3, -3);
		chatFrame.buttonFrame:SetPoint("BOTTOMRIGHT", chatFrame.Background, "BOTTOMLEFT", -3, 6);
	elseif ( buttonSide == "right" ) then
		chatFrame.buttonFrame:SetPoint("TOPLEFT", chatFrame.Background, "TOPRIGHT", 3, -3);
		chatFrame.buttonFrame:SetPoint("BOTTOMLEFT", chatFrame.Background, "BOTTOMRIGHT", 3, 6);
	end
	chatFrame.buttonSide = buttonSide;

	if ( chatFrame == DEFAULT_CHAT_FRAME ) then
		ChatFrameMenu_UpdateAnchorPoint();

		if ChatAlertFrame then
			ChatAlertFrame:SetChatButtonSide(buttonSide);
		end

		if ( QuickJoinToastButton ) then
			QuickJoinToastButton:SetToastDirection(buttonSide == "right");
		end
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
	FCF_SetLocked(frame, true);

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
		UIFrameFlashStop(tabFlash);
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

	if (button == "MiddleButton") then
		if ( chatFrame and not IsBuiltinChatWindow(chatFrame) ) then
			if ( not chatFrame.isTemporary ) then
				FCF_PopInWindow(self, chatFrame);
				return;
			elseif ( chatFrame.isTemporary and (chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER") ) then
				FCF_PopInWindow(self, chatFrame);
				return;
			elseif ( chatFrame.isTemporary and ( chatFrame.chatType == "PET_BATTLE_COMBAT_LOG" ) ) then
				FCF_Close(chatFrame);
			else
				GMError(format("Unhandled temporary window type. chatType: %s, chatTarget %s", tostring(chatFrame.chatType), tostring(chatFrame.chatTarget)));
			end
		end
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is docked assume that a click is to select a chat window, not drag it
	SELECTED_CHAT_FRAME = chatFrame;
	if ( chatFrame.isDocked and FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ~= chatFrame ) then
		FCF_SelectDockFrame(chatFrame);
	end
	if ( GetCVar("chatStyle") ~= "classic" ) then
		ChatEdit_SetLastActiveWindow(chatFrame.editBox);
	end
	chatFrame:ResetAllFadeTimes();
	FCF_FadeInChatFrame(chatFrame);
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
	if ( GetCVar("chatStyle") == "im" and LAST_ACTIVE_CHAT_EDIT_BOX == frame.editBox ) then
		ChatEdit_SetLastActiveWindow(DEFAULT_CHAT_FRAME.editBox);
	end
	FCF_FlagMinimizedPositionReset(frame);
	if ( frame.minFrame and frame.minFrame:IsShown() ) then
		frame.minFrame:Hide();
	end
	if ( frame.isTemporary ) then
		FCFManager_UnregisterDedicatedFrame(frame, frame.chatType, frame.chatTarget);
		frame.isRegistered = false;
		frame.inUse = false;
	end

	--Reset what this window receives.
	ChatFrame_RemoveAllMessageGroups(frame);
	ChatFrame_RemoveAllChannels(frame);
	ChatFrame_ReceiveAllPrivateMessages(frame);
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

function FCF_Set_NormalChat()
	ChatFrame2:StartMoving();
	ChatFrame2:StopMovingOrSizing();
	FCF_SetLocked(ChatFrame2, false);
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

function FCF_ResetChatWindow(windowFrame, windowName)
	FCF_SetChatWindowFontSize(nil, windowFrame, CHAT_FRAME_DEFAULT_FONT_SIZE);
	FCF_SetWindowName(windowFrame, windowName);
	FCF_SetWindowColor(windowFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
	FCF_SetWindowAlpha(windowFrame, DEFAULT_CHATFRAME_ALPHA);
	ChatFrame_RemoveAllMessageGroups(windowFrame);
	ChatFrame_RemoveAllChannels(windowFrame);
	ChatFrame_ReceiveAllPrivateMessages(windowFrame);
	FCF_UnDockFrame(windowFrame);
	windowFrame.isInitialized = 0;
end

-- Reset the chat windows to default
function FCF_ResetChatWindows()
	FCF_SetButtonSide(ChatFrame1, "left");
	FCF_ResetChatWindow(ChatFrame1, GENERAL);
	SELECTED_CHAT_FRAME = ChatFrame1;
	DEFAULT_CHAT_FRAME.chatframe = DEFAULT_CHAT_FRAME;

	FCF_ResetChatWindow(ChatFrame2, COMBAT_LOG);

	local showingVoiceTab = (GetCVarBool("speechToText") and C_VoiceChat.IsTranscribing()) or C_VoiceChat.IsSpeakForMeActive();
	if(showingVoiceTab) then
		FCF_ResetChatWindow(ChatFrame3, VOICE);
	end

	for _, chatFrameName in ipairs(CHAT_FRAMES) do
		if ( chatFrameName ~= "ChatFrame1" ) then
			local chatFrame = _G[chatFrameName];
			chatFrame.isInitialized = 0;
			FCF_SetTabPosition(chatFrame, 0);
			FCF_Close(chatFrame);
			FCF_UnDockFrame(chatFrame);
			FCF_SetWindowName(chatFrame, "");
			ChatFrame_RemoveAllMessageGroups(chatFrame);
			ChatFrame_RemoveAllChannels(chatFrame);
			ChatFrame_ReceiveAllPrivateMessages(chatFrame);
			FCF_SetChatWindowFontSize(nil, chatFrame, CHAT_FRAME_DEFAULT_FONT_SIZE);
			FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
			FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
		end
	end
	ChatFrame1.init = 0;
	FCF_DockFrame(ChatFrame1, 1, true);
	FCF_DockFrame(ChatFrame2, 2);

	if(showingVoiceTab) then
		FCF_DockFrame(ChatFrame3, 3);
	end

	-- resets to hard coded defaults
	ResetChatWindows(CHAT_FRAME_DEFAULT_FONT_SIZE);
	FCFDock_SelectWindow(GENERAL_CHAT_DOCK, ChatFrame1);
end

function IsCombatLog(frame)
	return ( frame == ChatFrame2 and C_AddOns.IsAddOnLoaded("Blizzard_CombatLog") );
end

function IsVoiceTranscription(frame)
	return ( frame == ChatFrame3 );
end

function IsBuiltinChatWindow(frame)
	return ( frame == DEFAULT_CHAT_FRAME ) or IsCombatLog(frame) or IsVoiceTranscription(frame);
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
		(event == "CVAR_UPDATE" and arg1 == "chatStyle") ) then
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
	chatFrame.editBox:Hide();
	chatFrame:Hide();
	chatTab:Hide();
end

function FCF_MaximizeFrame(chatFrame)
	local minFrame = chatFrame.minFrame;
	local chatTab = _G[chatFrame:GetName().."Tab"];

	chatFrame.minimized = false;

	minFrame:UnlockHighlight();
	minFrame:Hide();
	FCF_CheckShowChatFrame(chatFrame);
	FCF_CheckShowChatFrame(chatTab);

	FCF_FadeInChatFrame(chatFrame);

	if ( GetCVar("chatStyle") == "im" ) then
		ChatEdit_SetLastActiveWindow(chatFrame.editBox);
	end
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
		elseif ( chatFrame.chatType == "PET_BATTLE_COMBAT_LOG" ) then
			conversationIcon = "Interface\\Icons\\Tracking_WildPet";
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

	minFrame.HighlightLeft:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.HighlightMiddle:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.HighlightRight:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
	minFrame.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);

	minFrame.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
end

--This function just makes the position be reset the next time the minimize frame is shown.
function FCF_FlagMinimizedPositionReset(chatFrame)
	if ( chatFrame.minFrame ) then
		chatFrame.minFrame.resetPosition = true;
	end
end

function FCF_CheckShowChatFrame(frame)
	frame:SetShown(AllowChatFramesToShow(frame));
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
	dock:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT", 0, 3);
	dock:SetPoint("BOTTOMRIGHT", chatFrame, "TOPRIGHT", 0, 3);

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
		assert(position ~= 1 or chatFrame == dock.primary);
		tinsert(dock.DOCKED_CHAT_FRAMES, position, chatFrame);
	else
		tinsert(dock.DOCKED_CHAT_FRAMES, chatFrame);
	end

	FCFDock_HideInsertHighlight(dock);

	if ( dock.primary ~= chatFrame ) then
		chatFrame:ClearAllPoints();
		chatFrame:SetAllPoints(dock.primary);
		chatFrame:SetMovable(false);
		if(dock.primary.isLocked) then
			chatFrame:SetResizable(false);
		else
			chatFrame:SetResizable(true);
		end
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
	PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0, nil, nil, nil, chatTab.textWidth);
	if ( FCFDock_GetSelectedWindow(dock) == chatFrame ) then
		FCFDock_SelectWindow(dock, dock.DOCKED_CHAT_FRAMES[1]);
	end

	chatFrame.buttonFrame.minimizeButton:Show();
	dock.overflowButton.list:Hide();
	FCF_CheckShowChatFrame(chatFrame);
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
end

function FCFDock_GetSelectedWindow(dock)
	return dock.selected;
end

function FCFDock_GetNewTabAnchor(dock)
	return _G[dock.DOCKED_CHAT_FRAMES[#dock.DOCKED_CHAT_FRAMES]:GetName().."Tab"];
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
			FCF_CheckShowChatFrame(chatFrame);
		else
			chatFrame:Hide();
		end
		FCFTab_UpdateAlpha(chatFrame);
		chatTab:ClearAllPoints();
		FCF_CheckShowChatFrame(chatTab);
		FCFTab_UpdateColors(chatTab, chatFrame == FCFDock_GetSelectedWindow(dock));

		if ( chatFrame.isStaticDocked ) then
			chatTab:SetParent(dock);
			PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0);
			if ( lastDockedStaticTab ) then
				chatTab:SetPoint("LEFT", lastDockedStaticTab, "RIGHT", 1, 0);
			else
				chatTab:SetPoint("BOTTOMLEFT", dock, "BOTTOMLEFT", 0, 0);
			end
			lastDockedStaticTab = chatTab;
		else
			chatTab:SetParent(scrollChild);
			numDynFrames = numDynFrames + 1;

			if ( FCFDock_GetSelectedWindow(dock) == chatFrame ) then
				selectedDynIndex = numDynFrames;
			end

			if ( lastDockedDynamicTab ) then
				chatTab:SetPoint("LEFT", lastDockedDynamicTab, "RIGHT", 1, 0);
			else
				chatTab:SetPoint("LEFT", scrollChild, "LEFT", 0, -1);
			end
			lastDockedDynamicTab = chatTab;
		end
	end

	dock.scrollFrame:SetPoint("LEFT", lastDockedStaticTab, "RIGHT", 0, 0);
	dock.scrollFrame:SetPoint("BOTTOMRIGHT", dock, "BOTTOMRIGHT", 0, -1);

	local dynTabSize, hasOverflow = FCFDock_CalculateTabSize(dock, numDynFrames);

	for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
		if ( not chatFrame.isStaticDocked ) then
			local chatTab = _G[chatFrame:GetName().."Tab"];
			PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0, dynTabSize);
		end
	end

	if ( hasOverflow ) then
		dock.overflowButton:Show();
		dock.scrollFrame:SetPoint("BOTTOMRIGHT", dock.overflowButton, "BOTTOMLEFT", -5, 0);
	else
		dock.overflowButton:Hide();
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
	local scrollSize = dock.scrollFrame:GetWidth();

	--First, see if we can fit all the tabs at the maximum size
	if ( numDynFrames * MAX_SIZE < scrollSize ) then
		return MAX_SIZE, false;
	end

	if ( scrollSize / MIN_SIZE < numDynFrames ) then
		--Not everything fits, so we'll need room for the overflow button.
		scrollSize = scrollSize - dock.overflowButton.width - 5;
	end

	--Figure out how many tabs we're going to be able to fit at the minimum size
	local numWholeTabs = min(floor(scrollSize / MIN_SIZE), numDynFrames)
	if ( scrollSize == 0 ) then
		return 1, (numDynFrames > 0);
	end
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
		local maxPosition = 387420489; -- 9^9
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
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
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

	local totalHeight = 25;

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

		totalHeight = totalHeight + button:GetHeight() + 3;
	end

	list:SetHeight(totalHeight);

	for i = #dockedFrames + 1, #list.buttons do
		list.buttons[i]:Hide();
	end
end

function FCFDockOverflowListButton_SetValue(button, chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	button.chatFrame = chatFrame;
	button:SetText(chatFrame.name);
	button:SetHeight(button:GetTextHeight());

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

function FCFManager_GetChatTarget(chatGroup, playerTarget, channelTarget)
	local chatTarget;
	if ( chatGroup == "CHANNEL" ) then
		chatTarget = tostring(channelTarget);
	elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
		if(not(strsub(playerTarget, 1, 2) == "|K")) then
			chatTarget = strupper(playerTarget);
		else
			chatTarget = playerTarget;
		end
	end
	return chatTarget;
end

function FCFManager_ShouldSuppressMessage(chatFrame, chatType, chatTarget)
	--Using GetToken probably isn't the best way to do this due to the string concatenation, but it's the easiest to get in quickly.
	if ( chatFrame.chatType and FCFManager_GetToken(chatType, chatTarget) == FCFManager_GetToken(chatFrame.chatType, chatFrame.chatTarget) ) then
		--This frame is a dedicated frame of this type, so we should always display.
		return false;
	end

	if ( (chatType == "BN_WHISPER" and GetCVar("whisperMode") == "popout")
		or (chatType == "WHISPER" and GetCVar("whisperMode") == "popout") ) then
		return true;
	end

	return false;
end

function FCFManager_ShouldSuppressMessageFlash(chatFrame, chatType, chatTarget)
	--Using GetToken probably isn't the best way to do this due to the string concatenation, but it's the easiest to get in quickly.
	if ( chatFrame.chatType and FCFManager_GetToken(chatType, chatTarget) == FCFManager_GetToken(chatFrame.chatType, chatFrame.chatTarget) ) then
		--This frame is a dedicated frame of this type, so we should always display.
		return false;
	end

	if ( (chatType == "BN_WHISPER" and GetCVar("whisperMode") == "popout_and_inline")
		or (chatType == "WHISPER" and GetCVar("whisperMode") == "popout_and_inline") ) then
		return true;
	end

	return false;
end

function FCFManager_StopFlashOnDedicatedWindows(chatType, chatTarget)
	local token = FCFManager_GetToken(chatType, chatTarget);
	local windowList = dedicatedWindows[token];
	if (windowList) then
		for i, frame in pairs(windowList) do
			FCF_StopAlertFlash(frame);
		end
	end
end

function FloatingChatFrameManager_OnLoad(self)
	for _, event in pairs(ChatTypeGroup["BN_WHISPER"]) do
		self:RegisterEvent(event);
	end
	for _, event in pairs(ChatTypeGroup["WHISPER"]) do
		self:RegisterEvent(event);
	end
end

function FloatingChatFrameManager_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( strsub(event, 1, 9) == "CHAT_MSG_" ) then
		local chatType = strsub(event, 10);
		local chatGroup = Chat_GetChatCategory(chatType);
		local isGM = (select(6, ...) == "GM");

		if ( isGM ) then
			-- GM messages are handled by the GMChatUI addon
			return;
		end

		if ( (chatGroup == "BN_WHISPER" and (GetCVar("whisperMode") == "popout" or GetCVar("whisperMode") == "popout_and_inline"))
			or (chatGroup == "WHISPER" and (GetCVar("whisperMode") == "popout" or GetCVar("whisperMode") == "popout_and_inline"))) then
			local chatTarget = tostring(select(2, ...));

			if ( FCFManager_GetNumDedicatedFrames(chatGroup, chatTarget) == 0 ) then
				local chatFrame = FCF_OpenTemporaryWindow(chatGroup, chatTarget);
				chatFrame:GetScript("OnEvent")(chatFrame, event, ...);	--Re-fire the event for the frame.

				-- If you started the whisper, immediately select the tab
				if ((event == "CHAT_MSG_WHISPER_INFORM" and GetCVar("whisperMode") == "popout")
					or (event == "CHAT_MSG_BN_WHISPER_INFORM" and GetCVar("whisperMode") == "popout") ) then
					FCF_SelectDockFrame(chatFrame);
					FCF_FadeInChatFrame(chatFrame);
				end
			else
				-- While in "Both" mode, if you reply to a whisper, stop the flash on that dedicated whisper tab
				if ( (chatType == "WHISPER_INFORM" and GetCVar("whisperMode") == "popout_and_inline")
				or (chatType == "BN_WHISPER_INFORM" and GetCVar("whisperMode") == "popout_and_inline")) then
					FCFManager_StopFlashOnDedicatedWindows(chatGroup, chatTarget);
				end
			end
		end
	end
end
