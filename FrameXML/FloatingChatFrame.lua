-- CHAT PROTOTYPE STUFF
SELECTED_DOCK_FRAME = nil;
DOCKED_CHAT_FRAMES = {};
DOCK_COPY = {};

MOVING_CHATFRAME = nil;

CHAT_TAB_SHOW_DELAY = 0.2;
CHAT_FRAME_FADE_TIME = 0.15;

DEFAULT_CHATFRAME_ALPHA = 0.25;
DEFAULT_CHATFRAME_COLOR = {r = 0, g = 0, b = 0};

CHAT_FRAME_TEXTURES = {
	"Background",
	"ResizeTopLeftTexture",
	"ResizeTopRightTexture",
	"ResizeBottomLeftTexture",
	"ResizeBottomRightTexture",
	"ResizeTopTexture",
	"ResizeBottomTexture",
	"ResizeLeftTexture",
	"ResizeRightTexture"
}

function FloatingChatFrame_OnLoad(self)
	FCF_SetTabPosition(self, 0);
	FloatingChatFrame_Update(self:GetID());
	if ( ChatFrameEditBox ) then
		self.editBox = ChatFrameEditBox;
	end
end

function FloatingChatFrame_OnEvent(self, event, ...)
	if ( (event == "UPDATE_CHAT_WINDOWS") or (event == "UPDATE_FLOATING_CHAT_WINDOWS") ) then
		FloatingChatFrame_Update(self:GetID(), 1);
		self.isInitialized = 1;
	end
end

function FloatingChatFrame_Update(id, onUpdateEvent)	
	local name, fontSize, r, g, b, a, shown, locked, docked, uninteractable = GetChatWindowInfo(id);
	local chatFrame = _G["ChatFrame"..id];
	local chatTab = _G["ChatFrame"..id.."Tab"];

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
		chatFrame:Show();
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
		else
			FCF_Close(chatFrame);
		end
	end

	FCF_ValidateChatFramePosition(chatFrame);
end

-- Channel Dropdown
function FCFOptionsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, FCFOptionsDropDown_Initialize, "MENU");
	UIDropDownMenu_SetButtonWidth(self, 50);
	UIDropDownMenu_SetWidth(self, 50);
end

function FCFOptionsDropDown_Initialize(dropDown)
	-- Window preferences
	local name, fontSize, r, g, b, a, shown = GetChatWindowInfo(FCF_GetCurrentChatFrameID());
	local info;

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
	
	-- Add name button
	info = UIDropDownMenu_CreateInfo();
	info.text = RENAME_CHAT_WINDOW;
	info.func = FCF_RenameChatWindow_Popup;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

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

	-- Close current chat window
	if ( shown and (FCF_GetCurrentChatFrame(dropDown) ~= DEFAULT_CHAT_FRAME) ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = CLOSE_CHAT_WINDOW;
		info.func = FCF_Close;
		info.arg1 = FCF_GetCurrentChatFrame(dropDown);
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
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

function FCF_Resize(self, anchorPoint)
	if ( FCF_Get_ChatLocked() ) then
		return;
	end
	local chatFrame = self:GetParent();
	if ( chatFrame.isLocked) then
		return;
	end
	if ( chatFrame.isDocked and chatFrame ~= DEFAULT_CHAT_FRAME ) then
		return;
	end
	chatFrame.resizing = 1;
	self:GetParent():StartSizing(anchorPoint);
end

function FCF_StopResize(self)
	self:GetParent():StopMovingOrSizing();
	if ( self:GetParent() == DEFAULT_CHAT_FRAME ) then
		FCF_DockUpdate();
	end
	self:GetParent().resizing = nil;
end

function FCF_OpenNewWindow(name)
	local temp, shown;
	local count = 1;
	local chatFrame, chatTab;
	
	for i=1, NUM_CHAT_WINDOWS do
		temp, temp, temp, temp, temp, temp, shown, temp = GetChatWindowInfo(i);
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
			ChatFrame_AddMessageGroup(chatFrame, "SAY");
			ChatFrame_AddMessageGroup(chatFrame, "YELL");
			ChatFrame_AddMessageGroup(chatFrame, "GUILD");
			ChatFrame_AddMessageGroup(chatFrame, "WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY");
			ChatFrame_AddMessageGroup(chatFrame, "CHANNEL");

			-- Show the frame and tab
			chatFrame:Show();
			chatTab:Show();
			SetChatWindowShown(i, 1);
			
			-- Dock the frame by default
			FCF_DockFrame(chatFrame, (#DOCKED_CHAT_FRAMES+1), true);
			break;
		end
		count = count + 1;
	end
end

function FCF_GetNumActiveChatFrames()
	local temp, shown
	local count = 0;
	local chatFrame;
	for i=1, NUM_CHAT_WINDOWS do
		temp, temp, temp, temp, temp, temp, shown, temp = GetChatWindowInfo(i);
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
	end
	frame.name = name;
	local tab = _G[frame:GetName().."Tab"];
	tab:SetText(name);
	PanelTemplates_TabResize(tab, 10);
	-- Save this off so we know how big the tab should always be, even if it gets shrunken on the dock.
	tab.textWidth = _G[tab:GetName().."Text"]:GetWidth();
	if ( not doNotSave ) then
		SetChatWindowName(frame:GetID(), name);
	end
end

function FCF_SetWindowColor(frame, r, g, b, doNotSave)
	local name = frame:GetName();
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		_G[name..value]:SetVertexColor(r,g,b);
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
	return UIDropDownMenu_GetCurrentDropDown():GetParent():GetID();
end

function FCF_GetCurrentChatFrame(child)
	if ( not UIDropDownMenu_GetCurrentDropDown():GetParent() ) then
		return;
	end
	local currentChatFrame = _G["ChatFrame"..UIDropDownMenu_GetCurrentDropDown():GetParent():GetID()];
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
		for _, frame in pairs(DOCKED_CHAT_FRAMES) do
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
	if ( isUninteractable ) then
		_G[chatFrameName.."ResizeTop"]:EnableMouse(false);
		_G[chatFrameName.."ResizeBottom"]:EnableMouse(false);
		_G[chatFrameName.."ResizeLeft"]:EnableMouse(false);
		_G[chatFrameName.."ResizeRight"]:EnableMouse(false);
	else
		_G[chatFrameName.."ResizeTop"]:EnableMouse(true);
		_G[chatFrameName.."ResizeBottom"]:EnableMouse(true);
		_G[chatFrameName.."ResizeLeft"]:EnableMouse(true);
		_G[chatFrameName.."ResizeRight"]:EnableMouse(true);
	end
end

-- Docking handling functions

function FCF_OnUpdate(elapsed)
	-- Need to draw the dock regions for a frame to define their rects
	if ( not ChatFrame1.init ) then
		for i=1, NUM_CHAT_WINDOWS do
			_G["ChatFrame"..i.."TabDockRegion"]:Show();
			FCF_UpdateButtonSide(_G["ChatFrame"..i]);
		end
		ChatFrame1.init = 1;
		return;
	elseif ( ChatFrame1.init == 1  ) then
		for i=1, NUM_CHAT_WINDOWS do
			_G["ChatFrame"..i.."TabDockRegion"]:Hide();
		end
		ChatFrame1.init = 2;
	end

	if ( MOVING_CHATFRAME ) then
		-- Set buttons to the left or right side of the frame
		-- If the the side of the buttons changes and the frame is the default frame, then set every docked frames buttons to the same side
		local updateAllButtons = nil;
		if (FCF_UpdateButtonSide(MOVING_CHATFRAME) and MOVING_CHATFRAME == DEFAULT_CHAT_FRAME ) then
			updateAllButtons = 1;
		end
		local dockRegion;
		for index, value in pairs(DOCKED_CHAT_FRAMES) do
			if ( updateAllButtons ) then
				FCF_UpdateButtonSide(value);
			end
			
			dockRegion = _G[value:GetName().."TabDockRegion"];
			if ( MouseIsOver(dockRegion) and MOVING_CHATFRAME ~= DEFAULT_CHAT_FRAME and not InterfaceOptionsFrame:IsShown() ) then
				dockRegion:Show();
			else
				dockRegion:Hide();
			end
		end
	end

	local isLocked = FCF_Get_ChatLocked();

	-- Detect if mouse is over any chat frames and if so show their tabs, if not hide them
	local chatFrameName, chatTabName;
	local chatFrame, chatTab;
	local activeFrame;

	-- Handle hiding and showing chat tabs
	local showAllDockTabs = nil;
	local hideAnyDockTabs = nil;
	local xPos, yPos = GetCursorPosition();
	for j=1, NUM_CHAT_WINDOWS do
		chatFrameName = "ChatFrame"..j;
		chatTabName = chatFrameName.."Tab";
		chatFrame = _G[chatFrameName];
		chatTab = _G[chatTabName];

		if ( FCF_IsValidChatFrame(chatFrame) ) then
			-- Tab height
			local yOffset = 45;
			local activeYOffset = 45;
			local isCombatLog = IsCombatLog(chatFrame);
			if ( isCombatLog ) then
				if ( isLocked ) then
					CombatLogQuickButtonFrame_Custom:SetParent(chatFrame);
				else
					yOffset = yOffset + CombatLogQuickButtonFrame_Custom:GetHeight();
					CombatLogQuickButtonFrame_Custom:SetParent(chatTab);
					CombatLogQuickButtonFrame_Custom:SetAlpha(1);
					if ( chatFrame:IsShown() ) then
						CombatLogQuickButtonFrame_Custom:Show();
					end
				end
			end

			-- Determine active frame
			if ( chatFrame.isDocked ) then
				activeFrame = SELECTED_DOCK_FRAME;
				if ( IsCombatLog(activeFrame) and not isLocked ) then
					activeYOffset = activeYOffset + CombatLogQuickButtonFrame_Custom:GetHeight();
				end
			else
				activeFrame = chatFrame;
			end

			if ( MouseIsOver(activeFrame, activeYOffset, activeFrame:GetTop()-activeFrame:GetBottom(), -5, 5) or
				((MouseIsOver(chatFrame, yOffset, -10, -5, 5) and not chatFrame.isUninteractable)) or
				chatFrame.resizing or activeFrame.resizing ) then
				-- Try to show the tab

				-- If mouse is hovering don't show the tab until the elapsed time reaches the tab show delay
				if ( chatFrame.hover ) then
					if ( (chatFrame.oldx == xPos and chatFrame.oldy == yPos) or REMOVE_CHAT_DELAY == "1" ) then
						chatFrame.hoverTime = chatFrame.hoverTime + elapsed;
					else
						chatFrame.hoverTime = 0;
						chatFrame.oldx = xPos;
						chatFrame.oldy = yPos;
					end
					-- If the hover delay has been reached or the user is dragging a chat frame over the dock show the tab
					if ( (chatFrame.hoverTime > CHAT_TAB_SHOW_DELAY) or (MOVING_CHATFRAME and (chatFrame == DEFAULT_CHAT_FRAME)) ) then
						-- If the chatframe's alpha is less than the current default, then fade it in 
						if ( not chatFrame.hasBeenFaded and (chatFrame.oldAlpha and chatFrame.oldAlpha < DEFAULT_CHATFRAME_ALPHA) ) then
							if ( isLocked and isCombatLog ) then
								CombatLogQuickButtonFrame_Custom:Show();
							elseif ( not isLocked ) then
								chatTab:Show();
							end

							for index, value in pairs(CHAT_FRAME_TEXTURES) do
								-- Fade in chat frame
								UIFrameFadeIn(_G[chatFrameName..value], CHAT_FRAME_FADE_TIME, chatFrame.oldAlpha, DEFAULT_CHATFRAME_ALPHA);
							end
							if ( isCombatLog ) then
								-- Fade in quick button frame
								UIFrameFadeIn(CombatLogQuickButtonFrame, CHAT_FRAME_FADE_TIME, chatFrame.oldAlpha, 1.0);
							end

							-- Set the fact that the chatFrame has been faded so we don't try to fade it again
							chatFrame.hasBeenFaded = 1;
						end
						-- Fadein to different values depending on the selected tab
						if ( not chatTab.hasBeenFaded ) then
							if ( SELECTED_DOCK_FRAME:GetID() == chatTab:GetID() or not chatFrame.isDocked) then
								if ( isLocked and isCombatLog ) then
									UIFrameFadeIn(CombatLogQuickButtonFrame_Custom, CHAT_FRAME_FADE_TIME);
								elseif ( not isLocked ) then
									UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME);
								end
								chatTab.oldAlpha = 1;
							else
								if ( isLocked and isCombatLog ) then
									UIFrameFadeIn(CombatLogQuickButtonFrame_Custom, CHAT_FRAME_FADE_TIME, 0, 0.5);
								elseif ( not isLocked ) then
									UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, 0, 0.5);
								end
								chatTab.oldAlpha = 0.5;
							end

							chatTab.hasBeenFaded = 1;

							-- If this is the default chat tab fading in then fade in all the docked tabs
							if ( chatFrame == DEFAULT_CHAT_FRAME ) then
								showAllDockTabs = 1;
							end
						end
					end
				else
					-- Start hovering counter
					chatFrame.hover = 1;
					chatFrame.hoverTime = 0;
					chatFrame.hasBeenFaded = nil;
					chatTab.hasBeenFaded = nil;
					CURSOR_OLD_X, CURSOR_OLD_Y = GetCursorPosition();
					-- Remember the oldAlpha so we can return to it later
					if ( not chatFrame.oldAlpha ) then
						chatFrame.oldAlpha = _G[chatFrameName.."Background"]:GetAlpha();
					end
				end
			else
				-- Try to hide the tab

				-- If the chatframe's alpha was less than the current default, then fade it back out to the oldAlpha
				if ( chatFrame.hasBeenFaded and chatFrame.oldAlpha and chatFrame.oldAlpha < DEFAULT_CHATFRAME_ALPHA ) then
					for index, value in pairs(CHAT_FRAME_TEXTURES) do
						-- Fade out chat frame
						UIFrameFadeOut(_G[chatFrameName..value], CHAT_FRAME_FADE_TIME, DEFAULT_CHATFRAME_ALPHA, chatFrame.oldAlpha);
					end
					if ( IsCombatLog(chatFrame) ) then
						-- Fade out quick button frame
						UIFrameFadeOut(CombatLogQuickButtonFrame, CHAT_FRAME_FADE_TIME, DEFAULT_CHATFRAME_ALPHA, chatFrame.oldAlpha);
					end

					chatFrame.hover = nil;
					chatFrame.hasBeenFaded = nil;
				end
				if ( chatTab.hasBeenFaded ) then
					if (chatFrame.isDocked) then
						hideAnyDockTabs = true;
						chatTab.needsHide = true;
					else
						local fadeInfo = {};
						fadeInfo.mode = "OUT";
						fadeInfo.startAlpha = chatTab.oldAlpha;
						fadeInfo.timeToFade = CHAT_FRAME_FADE_TIME;
						fadeInfo.finishedArg1 = chatTab;
						fadeInfo.finishedArg2 = chatFrame;
						fadeInfo.finishedFunc = FCF_ChatTabFadeFinished;

						if ( isLocked and isCombatLog ) then
							UIFrameFade(CombatLogQuickButtonFrame_Custom, fadeInfo);
						elseif ( not isLocked ) then
							UIFrameFade(chatTab, fadeInfo);
						end

						chatFrame.hover = nil;
						chatTab.hasBeenFaded = nil;
					end
				end
				chatFrame.hover = nil;
				chatFrame.hoverTime = 0;
			end	
		end

		-- Show all tabs if any of the tabs are flashing
		if ( UIFrameIsFlashing(_G[chatTabName.."Flash"]) and chatFrame.isDocked ) then
			showAllDockTabs = 1;
		end
	end

	-- If one tab is flashing, show all the docked tabs
	if ( showAllDockTabs ) then
		for index, value in pairs(DOCKED_CHAT_FRAMES) do
			chatFrame = value;
			chatFrameName = chatFrame:GetName();
			chatTab = _G[chatFrameName.."Tab"];
			chatTab.needsHide = nil;
			if ( not chatTab.hasBeenFaded ) then
				local isCombatLog = IsCombatLog(value);
				if ( SELECTED_DOCK_FRAME:GetID() == chatTab:GetID() ) then
					if ( isLocked and isCombatLog ) then
						UIFrameFadeIn(CombatLogQuickButtonFrame_Custom, CHAT_FRAME_FADE_TIME);
					elseif ( not isLocked ) then
						UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME);
					end
					chatTab.oldAlpha = 1;
				else
					if ( isLocked and isCombatLog ) then
						UIFrameFadeIn(CombatLogQuickButtonFrame_Custom, CHAT_FRAME_FADE_TIME, 0, 0.5);
					elseif ( not isLocked ) then
						UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, 0, 0.5);
					end
					chatTab.oldAlpha = 0.5;
				end
				chatTab.hasBeenFaded = 1;
			end
		end
	elseif ( hideAnyDockTabs ) then
		for index, value in pairs(DOCKED_CHAT_FRAMES) do
			chatFrame = value;
			chatFrameName = chatFrame:GetName();
			chatTab = _G[chatFrameName.."Tab"];
			if ( chatTab.needsHide ) then
				local isCombatLog = IsCombatLog(value);
				local fadeInfo = {};
				fadeInfo.mode = "OUT";
				fadeInfo.startAlpha = chatTab.oldAlpha;
				fadeInfo.timeToFade = CHAT_FRAME_FADE_TIME;
				fadeInfo.finishedArg1 = chatTab;
				fadeInfo.finishedArg2 = chatFrame;
				fadeInfo.finishedFunc = FCF_ChatTabFadeFinished;
				if ( isLocked and isCombatLog ) then
					UIFrameFade(CombatLogQuickButtonFrame_Custom, fadeInfo);
				elseif ( not isLocked ) then
					UIFrameFade(chatTab, fadeInfo);
				end

				chatFrame.hover = nil;
				chatTab.hasBeenFaded = nil;
				chatTab.needsHide = nil;
			end 
		end
	end

	-- If the default chat frame is resizing, then resize the dock
	if ( DEFAULT_CHAT_FRAME.resizing ) then
		FCF_DockUpdate();
	end

	if ( ChatFrame2.resizing ) then
		Blizzard_CombatLog_Update_QuickButtons();
	end
end

function FCF_StopDragging(chatFrame)
	if ( not chatFrame ) then
		return;
	end

	chatFrame:StopMovingOrSizing();

	local activeDockRegion = FCF_GetActiveDockRegion();
	if ( activeDockRegion ) then
		FCF_DockFrame(chatFrame, activeDockRegion, true);
	else
		FCF_SetTabPosition(chatFrame, 0);
		FCF_ValidateChatFramePosition(chatFrame);
		FCF_SelectDockFrame(DOCKED_CHAT_FRAMES[1]);
	end

	MOVING_CHATFRAME = nil;
end

function FCF_ChatTabFadeFinished(chatTab, chatFrame)
	chatTab:Hide();
	if ( chatFrame.hasBeenFaded ) then
		chatFrame.oldAlpha = nil;
	end
end

function FCF_IsValidChatFrame(chatFrame)
	-- Break out all the cases individually because the logic gets convoluted
	if ( chatFrame == MOVING_CHATFRAME ) then
		return nil;
	end

	if ( not chatFrame:IsShown() and not chatFrame.isDocked ) then
		return nil;
	end
	
	if ( SIMPLE_CHAT == "1" ) then
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

function FCF_SetButtonSide(chatFrame, buttonSide)
	if ( chatFrame.buttonSide == buttonSide  ) then
		return;
	end
	if ( buttonSide == "left" ) then
		_G[chatFrame:GetName().."BottomButton"]:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMLEFT", -32, -4);
	elseif ( buttonSide == "right" ) then
		_G[chatFrame:GetName().."BottomButton"]:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMRIGHT", 0, -4);
	end
	chatFrame.buttonSide = buttonSide;
end

function FCF_GetButtonSide(chatFrame)
	return chatFrame.buttonSide;
end

function FCF_DockUpdate()
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

	frame.isDocked = 1;
	tinsert(DOCKED_CHAT_FRAMES, index, frame);
	
	-- Save docked state
	FCF_SaveDock();
	if ( selected ) then
		FCF_SelectDockFrame(frame);
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
end

function FCF_UnDockFrame(frame)
	if ( frame == DEFAULT_CHAT_FRAME or not frame.isDocked ) then
		return;
	end
	-- Undock frame regardless of whether its docked or not
	SetChatWindowDocked(frame:GetID(), nil);
	for index, value in pairs(DOCKED_CHAT_FRAMES) do
		if ( value == frame ) then
			tremove(DOCKED_CHAT_FRAMES, index);
		end
	end
	
	frame.isDocked = nil;

	-- Set tab to full alpha
	local chatTab = _G[frame:GetName().."Tab"];
	chatTab:SetAlpha(1.0);
	
	-- Reset dockregion anchors
	local dockRegion = _G[frame:GetName().."TabDockRegion"];
	dockRegion:SetPoint("RIGHT", frame, "RIGHT", 0, 0);
	dockRegion:Hide();
	
	-- Select first docked frame
	FCF_SelectDockFrame(DOCKED_CHAT_FRAMES[1]);
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
	FCF_DockUpdate();
end

function FCF_Tab_OnClick(self, button)
	local chatFrame = _G["ChatFrame"..self:GetID()];
	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		chatFrame:StopMovingOrSizing();
		ToggleDropDownMenu(1, nil, _G[self:GetName().."DropDown"], self:GetName(), 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is docked assume that a click is to select a chat window, not drag it
	SELECTED_CHAT_FRAME = chatFrame;
	if ( chatFrame.isDocked ) then
		FCF_SelectDockFrame(chatFrame);
		return;
	end
	-- If frame is not docked then allow the frame to be dragged or dropped
	if ( self:GetButtonState() == "PUSHED" ) then
		chatFrame:StopMovingOrSizing();
		local activeDockRegion = FCF_GetActiveDockRegion();
		if ( activeDockRegion ) then
			FCF_DockFrame(chatFrame, activeDockRegion, true);
		else
			-- Move chat frame if out of bounds
			FCF_ValidateChatFramePosition(chatFrame);
		end
		
		MOVING_CHATFRAME = nil;
	else
		-- If locked don't allow any movement
		if ( not chatFrame.isDocked and chatFrame.isLocked ) then
			return;
		else
			chatFrame:StartMoving();
			MOVING_CHATFRAME = chatFrame;
		end
	end
	
end

function FCF_SetTabPosition(chatFrame, x)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	chatTab:SetPoint("BOTTOMLEFT", chatFrame:GetName().."Background", "TOPLEFT", x+2, 0);
end

function FCF_GetActiveDockRegion()
	local dockRegion
	for index, value in pairs(DOCKED_CHAT_FRAMES) do
		dockRegion = _G[value:GetName().."TabDockRegion"];
		if ( dockRegion:IsShown() ) then
			return index + 1;
		end
	end
	return nil;
end

function FCF_SaveDock()
	local count = 1;
	local tempDock = DOCKED_CHAT_FRAMES;
	DOCKED_CHAT_FRAMES = {};
	for index, value in pairs(tempDock) do
		DOCKED_CHAT_FRAMES[count] = value;
		SetChatWindowDocked(value:GetID(), count);
		count = count + 1;
	end
end

function FCF_Close(frame, fallback)
    if ( fallback ) then
        frame=fallback
    end
	if ( not frame ) then
		frame = FCF_GetCurrentChatFrame();
	end
	if ( not frame:IsShown() ) then
		FCF_DockUpdate();
		return;
	end
	if ( frame == DEFAULT_CHAT_FRAME ) then
		return;
	end
	HideUIPanel(frame);
	_G[frame:GetName().."Tab"]:Hide();
	FCF_UnDockFrame(frame);
end

-- Moves a ChatFrame to a valid position if the user moves it off the screen
function FCF_ValidateChatFramePosition(chatFrame)
	-- Determine if the dragging tab is offscreen.  If so move the frame
	local chatTab = _G[chatFrame:GetName().."Tab"];
	local left = chatTab:GetLeft();
	local right = chatTab:GetRight();
	local top = chatTab:GetTop();
	local bottom = chatTab:GetBottom();
	local newAnchorX, newAnchorY;
	local offscreenPadding = 15;
	
	if ( not left or not right or not top or not bottom ) then
		return
	end

	if ( bottom < MainMenuBar:GetHeight()) then
		-- Off the bottom of the screen
		newAnchorY = MainMenuBar:GetHeight() + chatTab:GetHeight() - GetScreenHeight(); 
	elseif ( top > GetScreenHeight() ) then
		-- Off the top of the screen
		newAnchorY =  -chatTab:GetHeight();
	end
	if ( right < 0 ) then
		-- Off the left of the screen
		newAnchorX = 0;
	elseif ( left > GetScreenWidth() ) then
		-- Off the right of the screen
		newAnchorX = GetScreenWidth() - chatTab:GetWidth();
	end
	if ( newAnchorX or newAnchorY ) then
		if ( not newAnchorX ) then
			newAnchorX = left;
		elseif ( not newAnchorY ) then
			newAnchorY = bottom - GetScreenHeight();
		end
		chatFrame:ClearAllPoints();
		chatFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", newAnchorX, newAnchorY);
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
		if ( SIMPLE_CHAT ~= "1" ) then
			return;
		end
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

function FCF_UpdateCombatLogPosition()
	if ( SIMPLE_CHAT == "1" ) then
		local xOffset = -32;
		local yOffset = 75;
		if ( MultiBarBottomRight:IsShown() ) then
			yOffset = yOffset + 40;
		end
		if ( MultiBarLeft:IsShown() ) then
			xOffset = xOffset - 88;
		elseif ( MultiBarRight:IsShown() ) then
			xOffset = xOffset - 43;
		end
		ChatFrame2:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", xOffset, yOffset);
	end
end

function FCF_Set_SimpleChat()
	-- Main chat window
	ChatFrame1:ClearAllPoints();
	ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 85);
	ChatFrame1:SetWidth(518);
	ChatFrame1:SetHeight(120);
	ChatFrame1Tab:Hide();
	FCF_SetButtonSide(ChatFrame1, "left")
	FCF_SetLocked(ChatFrame1, 1);
	FCF_SetChatWindowFontSize(nil, ChatFrame1, 14);
	FCF_SetWindowName(ChatFrame1, GENERAL);
	FCF_SetWindowAlpha(ChatFrame1, 0);

	FCF_UnDockFrame(ChatFrame2);
	ChatFrame2:ClearAllPoints();
	ChatFrame2:SetWidth(320);
	ChatFrame2:SetHeight(120);
	FCF_SetTabPosition(ChatFrame2, 0);
	ChatFrame2Tab:Hide();
	FCF_SetLocked(ChatFrame2, 1);
	FCF_SetChatWindowFontSize(nil, ChatFrame2, 14);
	FCF_SetWindowName(ChatFrame2, COMBAT_LOG);
	FCF_SetWindowAlpha(ChatFrame2, 0);
	ChatFrame2:Show();
	FCF_SetButtonSide(ChatFrame2, "right")
	ChatFrame_RemoveAllChannels(ChatFrame2);
	ChatFrame_RemoveAllMessageGroups(ChatFrame2);
	ChatFrame_ActivateCombatMessages(ChatFrame2);
	for i=3, NUM_CHAT_WINDOWS do
		FCF_Close(_G["ChatFrame"..i]);
	end

	-- Update all the anchors
	UIParent_ManageFramePositions();
end

function FCF_Set_NormalChat()
	ChatFrame2:StartMoving();
	ChatFrame2:StopMovingOrSizing();
	FCF_SetLocked(ChatFrame2, nil);
	-- to fix a bug with the combat log not repositioning its tab properly when coming out of
	-- simple chat, we need to update now
	FCF_DockUpdate();
end

-- Lockout all chatframes from being movable/editable
function FCF_Set_ChatLocked(isLocked)
	if ( isLocked ) then
		CHAT_LOCKED = "1";
	else
		CHAT_LOCKED = "0";
	end
end

function FCF_Get_ChatLocked()
	if ( CHAT_LOCKED == "1" ) then
		return 1;
	else
		return nil;
	end
end

-- Function to toggle the combat log if in simple chat mode
function ToggleCombatLog()
	if ( SIMPLE_CHAT == "1" ) then
		if ( ChatFrame2:IsShown() ) then
			ChatFrame2:Hide();
		else
			ChatFrame2:Show();
		end
	end
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
	FCF_ValidateChatFramePosition(ChatFrame1);
	ChatFrame_RemoveAllChannels(ChatFrame1);
	ChatFrame_RemoveAllMessageGroups(ChatFrame1);
	SELECTED_CHAT_FRAME = ChatFrame1;
	ChatFrameEditBox.chatFrame = DEFAULT_CHAT_FRAME;
	DEFAULT_CHAT_FRAME.editBox = ChatFrameEditBox;
	DEFAULT_CHAT_FRAME.chatframe = DEFAULT_CHAT_FRAME;

	FCF_SetChatWindowFontSize(nil, ChatFrame2, 14);
	FCF_SetWindowName(ChatFrame2, COMBAT_LOG);
	FCF_SetWindowColor(ChatFrame2, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
	FCF_SetWindowAlpha(ChatFrame2, DEFAULT_CHATFRAME_ALPHA);
	ChatFrame_RemoveAllChannels(ChatFrame2);
	ChatFrame_RemoveAllMessageGroups(ChatFrame2);
	FCF_UnDockFrame(ChatFrame2);
	ChatFrame2.isInitialized = 0;
	for i=2, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame"..i];
		chatFrame.isInitialized = 0;
		FCF_SetTabPosition(chatFrame, 0);
		FCF_Close(chatFrame);
		FCF_UnDockFrame(chatFrame);
		FCF_SetChatWindowFontSize(nil, chatFrame, 14);
		FCF_SetWindowName(chatFrame, "");
		FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
		FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
		ChatFrame_RemoveAllChannels(chatFrame);
		ChatFrame_RemoveAllMessageGroups(chatFrame);
	end
	ChatFrame1.init = 0;
	FCF_DockFrame(ChatFrame1, 1);
	FCF_DockFrame(ChatFrame2, 2);

	-- resets to hard coded defaults
	ResetChatWindows();
	UIParent_ManageFramePositions();
end

function IsCombatLog(frame)
	if ( frame == ChatFrame2 and IsAddOnLoaded("Blizzard_CombatLog") ) then
		return true;
	else
		return false;
	end
end
