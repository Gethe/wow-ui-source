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

function FloatingChatFrame_OnLoad()
	FCF_SetTabPosition(this, 0);
	FloatingChatFrame_Update(this:GetID());
	if ( ChatFrameEditBox ) then
		this.editBox = ChatFrameEditBox;
	end
end

function FloatingChatFrame_OnEvent(event)
	if ( event == "UPDATE_CHAT_WINDOWS" ) then
		FloatingChatFrame_Update(this:GetID(), 1);
		this.isInitialized = 1;
	end
end

function FloatingChatFrame_Update(id, onUpdateEvent)	
	local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(id);
	local chatFrame = getglobal("ChatFrame"..id);
	local chatTab = getglobal("ChatFrame"..id.."Tab");

	-- Set Tab Name
	FCF_SetWindowName(chatFrame, name, 1)

	-- Set Frame Color and Alpha
	FCF_SetWindowColor(chatFrame, r, g, b, 1);
	FCF_SetWindowAlpha(chatFrame, a, 1);
	
	-- Locked display stuff
	local init = nil;
	if ( onUpdateEvent and not chatFrame.isInitialized) then
		init = 1;
	end
	FCF_SetLocked(chatFrame, locked, init);

	if ( shown ) then
		chatFrame:Show();
		FCF_SetTabPosition(chatFrame, 0);
	else
		chatFrame:Hide();
		chatTab:Hide();
	end
	
	if ( docked ) then
		FCF_DockFrame(chatFrame, docked);
	else
		if ( shown ) then
			FCF_UnDockFrame(chatFrame);		
		else
			FCF_Close(chatFrame);
		end
	end
end

-- Channel Dropdown
function FCFOptionsDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, FCFOptionsDropDown_Initialize, "MENU");
	UIDropDownMenu_SetButtonWidth(50);
	UIDropDownMenu_SetWidth(50);
end

function FCFOptionsDropDown_Initialize()
	-- Window preferences
	local name, fontSize, r, g, b, a = GetChatWindowInfo(FCF_GetCurrentChatFrameID());
	local info = {};

	-- If level 3
	if ( UIDROPDOWNMENU_MENU_LEVEL == 3 ) then
		FCF_LoadChatSubTypes();
		return;
	end
	-- If level 2
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		-- If this is the font size menu then create dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == FONT_SIZE ) then
			-- Add the font heights from the font height table
			for index, value in CHAT_FONT_HEIGHTS do
				info = {};
				info.text = format(FONT_SIZE_TEMPLATE, value);
				info.value = value;
				info.func = FCF_SetChatWindowFontSize;

				if ( value == floor(FCF_GetCurrentChatFrame():GetFontHeight()+0.5) ) then
					info.checked = 1;
				end

				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			return;
		end
		
		-- If this is the chat channel menu then show the channel dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == CHANNELS ) then
			-- Channels header
			info = {};
			info.text = CHANNELS;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(ChannelMenuChatTypeGroups);
			FCFDropDown_LoadChannels(GetChannelList());
			return;
		end

		-- If this is the combat messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == COMBAT_MESSAGES ) then
			-- Combat Messages header
			info = {};
			info.text = COMBAT_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(CombatLogMenuChatTypeGroups);
			return;
		end

		-- If this is the spell messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == SPELL_MESSAGES ) then
			-- Other Combat Messages header
			info = {};
			info.text = SPELL_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(SpellLogMenuChatTypeGroups );
			return;
		end

		-- If this is the second spell messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == SPELL_OTHER_MESSAGES ) then
			-- Other Combat Messages header
			info = {};
			info.text = SPELL_OTHER_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(SpellLogOtherMenuChatTypeGroups );
			return;
		end

		-- If this is the periodic messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == PERIODIC_MESSAGES ) then
			-- Other Combat Messages header
			info = {};
			info.text = PERIODIC_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(PeriodicLogMenuChatTypeGroups );
			return;
		end


		-- If this is the system messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == SYSTEM_MESSAGES ) then
			-- System Messages header
			info = {};
			info.text = SYSTEM_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCF_LoadChatSubTypes("SYSTEM");
			return;
		end

		-- If this is the other messages menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == OTHER_MESSAGES ) then
			-- Other Messages header
			info = {};
			info.text = OTHER_MESSAGES;
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadChatTypes(OtherMenuChatTypeGroups);
			return;
		end

		-- If this is the join channel menu then show the message dropdown
		if ( UIDROPDOWNMENU_MENU_VALUE == JOIN_NEW_CHANNEL ) then
			-- Combat Messages header
			info = {};
			info.text = JOIN_NEW_CHANNEL;
			info.func = FCF_JoinNewChannel;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			-- Spacer
			info = {};
			info.disabled = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--Populate list
			FCFDropDown_LoadServerChannels(EnumerateServerChannels());
			return;
		end
		return;
	end
	-- Window options
	info = {};
	if ( FCF_GetCurrentChatFrame() and FCF_GetCurrentChatFrame().isLocked ) then
		info.text = UNLOCK_WINDOW;
	else
		info.text = LOCK_WINDOW;
	end
	info.func = FCF_ToggleLock;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Add name button
	info = {};
	info.text = RENAME_CHAT_WINDOW;
	info.func = FCF_RenameChatWindow_Popup;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Create new chat window
	info = {};
	info.text = NEW_CHAT_WINDOW;
	info.func = FCF_NewChatWindow;
	info.notCheckable = 1;
	if (FCF_GetNumActiveChatFrames() == NUM_CHAT_WINDOWS ) then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info);

	-- Close current chat window
	if ( FCF_GetCurrentChatFrame() ~= DEFAULT_CHAT_FRAME ) then
		info = {};
		info.text = CLOSE_CHAT_WINDOW;
		info.func = FCF_Close;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end

	-- Display header
	info = {};
	info.text = DISPLAY;
	info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Font size
	info = {};
	info.text = FONT_SIZE;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Set Background color
	info = {};
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
	info = {};
	info.text = FILTERS;
	--info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Channel list
	info = {};
	info.text = CHANNELS;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Combat message list
	info = {};
	info.text = COMBAT_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Spell message list
	info = {};
	info.text = SPELL_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Other Spell message list
	info = {};
	info.text = SPELL_OTHER_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Periodic message list
	info = {};
	info.text = PERIODIC_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- System message list
	info = {};
	info.text = SYSTEM_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Other messages list
	info = {};
	info.text = OTHER_MESSAGES;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	-- Spacer
	info = {};
	info.disabled = 1;
	UIDropDownMenu_AddButton(info);

	-- Join channel
	info = {};
	info.text = JOIN_NEW_CHANNEL;
	--info.notClickable = 1;
	info.hasArrow = 1;
	info.func = nil;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
end

function FCFDropDown_LoadServerChannels(...)
	local checked;
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local info;

	-- Server Channels header
	info = {};
	info.text = SERVER_CHANNELS;
	info.notClickable = 1;
	info.isTitle = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	for i=1, arg.n do
		checked = nil;
		if ( channelList ) then
			for index, value in channelList do
				if ( value == arg[i] ) then
					checked = 1;
				end
			end
		end
		if ( zoneChannelList ) then
			for index, value in zoneChannelList do
				if ( value == arg[i] ) then
					checked = 1;
				end
			end
		end
		
		info = {};
		info.text = arg[i];
		info.value = arg[i];
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
		JoinChannelByName(UIDropDownMenuButton_GetName(), nil, FCF_GetCurrentChatFrameID());
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), UIDropDownMenuButton_GetName());
	end
end

function FCFDropDown_LoadChannels(...)
	local checked;
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local info;
	--local channelIndex = 1;
	for i=1, arg.n, 2 do
		checked = nil;
		if ( channelList ) then
			for index, value in channelList do
				if ( value == arg[i+1] ) then
					checked = 1;
				end
			end
		end
		if ( zoneChannelList ) then
			for index, value in zoneChannelList do
				if ( value == arg[i+1] ) then
					checked = 1;
				end
			end
		end
		info = {};
		info.text = arg[i+1];
		info.value = "CHANNEL"..arg[i];
		info.func = FCFChannelDropDown_OnClick;
		info.checked = checked;
		info.keepShownOnClick = 1;
		-- Color the chat channel
		local color = ChatTypeInfo["CHANNEL"..arg[i]];
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
	for index, value in menuChatTypeGroups do
		checked = nil;
		if ( messageTypeList ) then
			for joinedIndex, joinedValue in messageTypeList do
				if ( value == joinedValue ) then
					checked = 1;
				end
			end
		end
		info = {};
		info.value = value;
		info.func = FCFMessageTypeDropDown_OnClick;
		info.checked = checked;
		-- Set to keep shown on button click
		info.keepShownOnClick = 1;
		
		-- If more than one message type in a Chat Type Group need to show an expand arrow
		group = ChatTypeGroup[value];
		if ( getn(group) > 1 ) then
			info.text = getglobal(value);
			info.hasArrow = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		else
			info.text = getglobal(group[1]);
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
		for index, value in chatGroup do
			info = {};
			info.text = getglobal(value);
			info.value = FCF_StripChatMsg(value);
			chatTypeInfo = ChatTypeInfo[FCF_StripChatMsg(value)];
			-- If no color assigned then make it white
			if ( chatTypeInfo ) then
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

function FCFMessageTypeDropDown_OnClick()
	if ( UIDropDownMenuButton_GetChecked() ) then
		ChatFrame_RemoveMessageGroup(FCF_GetCurrentChatFrame(), this.value);
	else
		ChatFrame_AddMessageGroup(FCF_GetCurrentChatFrame(), this.value);
	end
end

function FCF_Resize(anchorPoint)
	if ( FCF_Get_ChatLocked() ) then
		return;
	end
	local chatFrame = this:GetParent();
	if ( chatFrame.isLocked) then
		return;
	end
	if ( chatFrame.isDocked and chatFrame ~= DEFAULT_CHAT_FRAME ) then
		return;
	end
	chatFrame.resizing = 1;
	--[[
	if ( chatFrame == DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME.resizing = 1;
	end
	]]
	this:GetParent():StartSizing(anchorPoint);
end

function FCF_StopResize()
	this:GetParent():StopMovingOrSizing();
	if ( this:GetParent() == DEFAULT_CHAT_FRAME ) then
		FCF_DockUpdate();
	end
	this:GetParent().resizing = nil;
end

function FCF_OpenNewWindow(name)
	local temp, shown;
	local count = 1;
	local chatFrame;
	
	for i=1, NUM_CHAT_WINDOWS do
		temp, temp, temp, temp, temp, temp, shown, temp = GetChatWindowInfo(i);
		chatFrame = getglobal("ChatFrame"..i);
		chatTab = getglobal("ChatFrame"..i.."Tab");
		if ( (not shown and not chatFrame.isDocked) or (count == NUM_CHAT_WINDOWS) ) then
			if ( not name or name == "" ) then
				name = format(CHAT_NAME_TEMPLATE, i);			
			end
			
			-- initialize the frame
			FCF_SetWindowName(chatFrame, name);
			FCF_SetWindowColor(chatFrame, DEFAULT_CHATFRAME_COLOR.r, DEFAULT_CHATFRAME_COLOR.g, DEFAULT_CHATFRAME_COLOR.b);
			FCF_SetWindowAlpha(chatFrame, DEFAULT_CHATFRAME_ALPHA);
			SetChatWindowLocked(i, nil);

			-- Listen to the standard messages
			ChatFrame_RemoveAllMessageGroups(chatFrame);
			ChatFrame_AddMessageGroup(chatFrame, "SAY");
			ChatFrame_AddMessageGroup(chatFrame, "YELL");
			ChatFrame_AddMessageGroup(chatFrame, "GUILD");
			ChatFrame_AddMessageGroup(chatFrame, "WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY");

			-- Show the frame and tab
			chatFrame:Show();
			chatTab:Show();
			SetChatWindowShown(i, 1);
			
			-- Dock the frame by default
			FCF_DockFrame(chatFrame);
			break;
		end
		count = count + 1;
	end
end

function FCF_GetNumActiveChatFrames()
	local count = 0;
	for i=1, NUM_CHAT_WINDOWS do
		temp, temp, temp, temp, temp, temp, shown, temp = GetChatWindowInfo(i);
		chatFrame = getglobal("ChatFrame"..i);
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

function FCF_JoinNewChannel()
	StaticPopup_Show("JOIN_CHANNEL");
end

function FCF_SetWindowName(frame, name, doNotSave)
	if ( not name or name == "") then
		-- Hack to initialize the chat window names, since globalstrings are not available on init
		if ( frame:GetID() == 1 ) then
			name = GENERAL;
		elseif ( frame:GetID() == 2 ) then
			name = COMBAT_LOG;
		else
			name = format(CHAT_NAME_TEMPLATE, frame:GetID());
		end
	end
	local tab = getglobal(frame:GetName().."Tab");
	tab:SetText(name);
	PanelTemplates_TabResize(10, tab);
	if ( not doNotSave ) then
		SetChatWindowName(frame:GetID(), name);
	end
end

function FCF_SetWindowColor(frame, r, g, b, doNotSave)
	local name = frame:GetName();
	for index, value in CHAT_FRAME_TEXTURES do
		getglobal(name..value):SetVertexColor(r,g,b);
	end
	if ( not doNotSave ) then
		SetChatWindowColor(frame:GetID(), r, g, b);
	end
end

function FCF_SetWindowAlpha(frame, alpha, doNotSave)
	local name = frame:GetName();
	for index, value in CHAT_FRAME_TEXTURES do
		getglobal(name..value):SetAlpha(alpha);
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

function FCF_GetCurrentChatFrame()
	local currentChatFrame = getglobal("ChatFrame"..UIDropDownMenu_GetCurrentDropDown():GetParent():GetID());
	if ( not currentChatFrame ) then
		currentChatFrame = getglobal("ChatFrame"..this:GetParent():GetID());
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

function FCF_SetChatWindowFontSize(chatFrame, fontSize)
	if ( not chatFrame ) then
		chatFrame = FCF_GetCurrentChatFrame();
	end
	if ( not fontSize ) then
		fontSize = this.value;
	end
	chatFrame:SetFontHeight(fontSize);
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

function FCF_SetLocked(chatFrame, isLocked, init)
	if ( not chatFrame.isInitialized and not init) then
		return;
	end

	chatFrame.isLocked = isLocked;
	SetChatWindowLocked(chatFrame:GetID(), isLocked);
end

-- Docking handling functions

function FCF_OnUpdate(elapsed)
	-- Need to draw the dock regions for a frame to define their rects
	if ( not ChatFrame1.init ) then
		for i=1, NUM_CHAT_WINDOWS do
			getglobal("ChatFrame"..i.."TabDockRegion"):Show();
			FCF_UpdateButtonSide(getglobal("ChatFrame"..i));
		end
		ChatFrame1.init = 1;
		return;
	elseif ( ChatFrame1.init == 1  ) then
		for i=1, NUM_CHAT_WINDOWS do
			getglobal("ChatFrame"..i.."TabDockRegion"):Hide();
		end
		ChatFrame1.init = 2;
	end

	-- Detect if mouse is over any chat frames and if so show their tabs, if not hide them
	local chatFrame, chatTab;

	if ( MOVING_CHATFRAME ) then
		-- Set buttons to the left or right side of the frame
		-- If the the side of the buttons changes and the frame is the default frame, then set every docked frames buttons to the same side
		local updateAllButtons = nil;
		if (FCF_UpdateButtonSide(MOVING_CHATFRAME) and MOVING_CHATFRAME == DEFAULT_CHAT_FRAME ) then
			updateAllButtons = 1;
		end
		local dockRegion;
		for index, value in DOCKED_CHAT_FRAMES do
			if ( updateAllButtons ) then
				FCF_UpdateButtonSide(value);
			end
			
			dockRegion = getglobal(value:GetName().."TabDockRegion");
			if ( MouseIsOver(dockRegion) and MOVING_CHATFRAME ~= DEFAULT_CHAT_FRAME ) then
				dockRegion:Show();
			else
				dockRegion:Hide();
			end
		end
	end
	
	-- Handle hiding and showing chat tabs
	local showAllDockTabs = nil;
	local xPos, yPos = GetCursorPosition();
	for j=1, NUM_CHAT_WINDOWS do
		chatFrame = getglobal("ChatFrame"..j);
		chatTab = getglobal("ChatFrame"..j.."Tab");
		
		-- New version of the crazy function
		if ( FCF_IsValidChatFrame(chatFrame) ) then
			if ( MouseIsOver(chatFrame, 45, -10, -5, 5) or chatFrame.resizing ) then
				-- If mouse is hovering don't show the tab until the elapsed time reaches the tab show delay
				if ( chatFrame.hover ) then
					if ( (chatFrame.oldX == xPos and chatFrame.oldy == yPos) or REMOVE_CHAT_DELAY == "1" ) then
						chatFrame.hoverTime = chatFrame.hoverTime + elapsed;
					else
						chatFrame.hoverTime = 0;
						chatFrame.oldX = xPos;
						chatFrame.oldy = yPos;
					end
					-- If the hover delay has been reached or the user is dragging a chat frame over the dock show the tab
					if ( (chatFrame.hoverTime > CHAT_TAB_SHOW_DELAY) or (MOVING_CHATFRAME and (chatFrame == DEFAULT_CHAT_FRAME)) ) then
						-- If the chatframe's alpha is less than the current default, then fade it in 
						if ( not chatFrame.hasBeenFaded and (chatFrame.oldAlpha and chatFrame.oldAlpha < DEFAULT_CHATFRAME_ALPHA) ) then
							chatTab:Show();
							for index, value in CHAT_FRAME_TEXTURES do
								UIFrameFadeIn(getglobal(chatFrame:GetName()..value), CHAT_FRAME_FADE_TIME, chatFrame.oldAlpha, DEFAULT_CHATFRAME_ALPHA);
							end
							-- Set the fact that the chatFrame has been faded so we don't try to fade it again
							chatFrame.hasBeenFaded = 1;
						end
						-- Fadein to different values depending on the selected tab
						if ( not chatTab.hasBeenFaded ) then
							if ( SELECTED_DOCK_FRAME:GetID() == chatTab:GetID() or not chatFrame.isDocked) then
								UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME);
								chatTab.oldAlpha = 1;
							else
								UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, 0, 0.5);
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
						chatFrame.oldAlpha = getglobal(chatFrame:GetName().."Background"):GetAlpha();
					end
				end
			else
				-- If the chatframe's alpha was less than the current default, then fade it back out to the oldAlpha
				if ( chatFrame.hasBeenFaded and chatFrame.oldAlpha and chatFrame.oldAlpha < DEFAULT_CHATFRAME_ALPHA ) then
					for index, value in CHAT_FRAME_TEXTURES do
						UIFrameFadeOut(getglobal(chatFrame:GetName()..value), CHAT_FRAME_FADE_TIME, DEFAULT_CHATFRAME_ALPHA, chatFrame.oldAlpha);
					end
					chatFrame.hover = nil;
					chatFrame.hasBeenFaded = nil;
				end
				if ( chatTab.hasBeenFaded ) then					
					local fadeInfo = {};
					fadeInfo.mode = "OUT";
					fadeInfo.startAlpha = chatTab.oldAlpha;
					fadeInfo.timeToFade = CHAT_FRAME_FADE_TIME;
					fadeInfo.finishedArg1 = chatTab;
					fadeInfo.finishedArg2 = getglobal("ChatFrame"..chatTab:GetID());
					fadeInfo.finishedFunc = FCF_ChatTabFadeFinished;
					UIFrameFade(chatTab, fadeInfo);

					chatFrame.hover = nil;
					chatTab.hasBeenFaded = nil;
				end
				chatFrame.hoverTime = 0;
			end	
		end
		
		-- See if any of the tabs are flashing
		if ( UIFrameIsFlashing(getglobal("ChatFrame"..j.."TabFlash")) and chatFrame.isDocked ) then
			showAllDockTabs = 1;
		end
	end
	-- If one tab is flashing, show all the docked tabs
	if ( showAllDockTabs ) then
		for index, value in DOCKED_CHAT_FRAMES do
			chatTab = getglobal(value:GetName().."Tab");
			if ( not chatTab.hasBeenFaded ) then
				if ( SELECTED_DOCK_FRAME:GetID() == chatTab:GetID() ) then
					UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME);
					chatTab.oldAlpha = 1;
				else
					UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, 0, 0.5);
					chatTab.oldAlpha = 0.5;
				end
				chatTab.hasBeenFaded = 1;
			end
		end
	end
		
	-- If the default chat frame is resizing, then resize the dock
	if ( DEFAULT_CHAT_FRAME.resizing ) then
		FCF_DockUpdate();
	end
end

function FCF_ChatTabFadeFinished(chatTab, chatFrame)
	chatTab:Hide();
	chatFrame.oldAlpha = nil;
end

function FCF_IsValidChatFrame(chatFrame)
	-- Break out all the cases individually because the logic gets convoluted
	if ( chatFrame == MOVING_CHATFRAME ) then
		return nil;
	end

	if ( not chatFrame:IsVisible() and not chatFrame.isDocked ) then
		return nil;
	end
	
	if ( SIMPLE_CHAT == "1" ) then
		return nil;
	end

	if ( FCF_Get_ChatLocked() ) then
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
		getglobal(chatFrame:GetName().."BottomButton"):SetPoint("BOTTOMLEFT", chatFrame:GetName(), "BOTTOMLEFT", -32, -4);
	elseif ( buttonSide == "right" ) then
		getglobal(chatFrame:GetName().."BottomButton"):SetPoint("BOTTOMLEFT", chatFrame:GetName(), "BOTTOMRIGHT", 0, -4);
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
	for index, value in DOCKED_CHAT_FRAMES do
		-- If not the initial chatframe then anchor the frame to the base chatframe
		name = value:GetName();
		if ( index ~= 1 ) then
			value:ClearAllPoints();
			value:SetPoint("TOPLEFT", DEFAULT_CHAT_FRAME:GetName(), "TOPLEFT", 0, 0);
			value:SetPoint("BOTTOMLEFT", DEFAULT_CHAT_FRAME:GetName(), "BOTTOMLEFT", 0, 0);
			value:SetPoint("BOTTOMRIGHT", DEFAULT_CHAT_FRAME:GetName(), "BOTTOMRIGHT", 0, 0);
		end
		
		-- Select or deselect the frame
		chatTab = getglobal(value:GetName().."Tab");
		PanelTemplates_TabResize(5, chatTab);
		if ( value == SELECTED_DOCK_FRAME ) then
			value:Show();
			if ( chatTab:IsVisible() ) then
				chatTab:SetAlpha(1.0);
			end
			
		else
			value:Hide();
			if ( chatTab:IsVisible() ) then
				chatTab:SetAlpha(0.5);
			end
		end
		
		-- If there was a frame before this frame then anchor the tab
		
		if ( previousDockedFrame ) then
			chatTab:ClearAllPoints();
			FCF_SetTabPosition(value, dockWidth);
			getglobal(previousDockedFrame:GetName().."TabDockRegion"):SetPoint("RIGHT", value:GetName().."Tab", "CENTER", 0, 0);
		end

		-- If this is the last frame in the dock then extend the dockRegion, otherwise shrink it to the default width
		dockRegion = getglobal(chatTab:GetName().."DockRegion");
		dockRegion:SetPoint("LEFT", chatTab:GetName(), "CENTER", 0 , 0);
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
		for index, value in DOCKED_CHAT_FRAMES do
			DOCK_COPY[index] = DOCKED_CHAT_FRAMES[index];
		end
		sort(DOCK_COPY, FCF_TabCompare);
		local totalWidth = DEFAULT_CHAT_FRAME:GetWidth();
		local avgWidth = totalWidth / numDockedFrames;
		local chatTabWidth;
		-- Resize the tabs
		for index, value in DOCK_COPY do
			chatTab = getglobal(value:GetName().."Tab");
			chatTabWidth = chatTab:GetWidth();
			if ( chatTabWidth < avgWidth ) then
				-- If tab is smaller than the average then remove it from the list and recalc the average
				totalWidth = totalWidth - chatTabWidth;
				tremove(DOCK_COPY, index);
				avgWidth = totalWidth / getn(DOCK_COPY);
			else
				-- Set the tab to the average width
				PanelTemplates_TabResize(0, chatTab, avgWidth);
			end
		end
		-- Reanchor the tabs
		previousDockedFrame = nil;
		dockWidth = 0;
		for index, value in DOCKED_CHAT_FRAMES do
			-- If there was a frame before this frame then anchor the tab
			if ( previousDockedFrame ) then
				FCF_SetTabPosition(value, dockWidth);
			end
			chatTab = getglobal(value:GetName().."Tab");
			dockWidth = dockWidth + chatTab:GetWidth();
			previousDockedFrame = value;
		end
	end
end

function FCF_TabCompare(chatFrame1, chatFrame2)
	local tab1 = getglobal(chatFrame1:GetName().."Tab");
	local tab2 = getglobal(chatFrame2:GetName().."Tab");
	return tab1:GetWidth() < tab2:GetWidth();
end

function FCF_DockFrame(frame, index)
	-- Return if already docked
	if ( frame.isDocked ) then
		return;
	end

	frame.isDocked = 1;

	-- Set index to n+1 if no index explicitly sent
	if ( not index ) then
		index = (getn(DOCKED_CHAT_FRAMES) + 1);
	end
	tinsert(DOCKED_CHAT_FRAMES, index, frame);
	
	-- Save docked state
	FCF_SaveDock();
	--SetChatWindowDocked(frame:GetID(), index);
	FCF_SelectDockFrame(frame);

	-- Set scroll button side
	if ( frame == DEFAULT_CHAT_FRAME ) then
		FCF_UpdateButtonSide(frame);
	else
		FCF_SetButtonSide(frame, FCF_GetButtonSide(DEFAULT_CHAT_FRAME));
	end
	
	-- Lock frame
	FCF_SetLocked(frame, 1);
end

function FCF_UnDockFrame(frame)
	if ( frame == DEFAULT_CHAT_FRAME ) then
		return;
	end
	-- Undock frame regardless of whether its docked or not
	SetChatWindowDocked(frame:GetID(), nil);
	for index, value in DOCKED_CHAT_FRAMES do
		if ( value == frame ) then
			tremove(DOCKED_CHAT_FRAMES, index);
		end
	end
	
	frame.isDocked = nil;

	-- Set tab to full alpha
	local chatTab = getglobal(frame:GetName().."Tab");
	chatTab:SetAlpha(1.0);
	
	-- Reset dockregion anchors
	dockRegion = getglobal(frame:GetName().."TabDockRegion");
	dockRegion:SetPoint("RIGHT", frame:GetName(), "RIGHT", 0, 0);
	dockRegion:Hide();
	
	-- Select first docked frame
	FCF_SelectDockFrame(DOCKED_CHAT_FRAMES[1]);
end

function FCF_SelectDockFrame(frame)
	SELECTED_DOCK_FRAME = frame;
	-- Stop tab flashing
	local tabFlash;
	if ( frame ) then
		tabFlash = getglobal("ChatFrame"..frame:GetID().."TabFlash");
	end
	
	if ( tabFlash ) then
		UIFrameFlashRemoveFrame(tabFlash);
		tabFlash:Hide();
	end
	FCF_DockUpdate();
end

function FCF_Tab_OnClick(button)
	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, getglobal(this:GetName().."DropDown"), this:GetName(), 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is docked assume that a click is to select a chat window, not drag it
	local chatFrame = getglobal("ChatFrame"..this:GetID());
	SELECTED_CHAT_FRAME = chatFrame;
	if ( chatFrame.isDocked ) then
		FCF_SelectDockFrame(chatFrame);
		return;
	end
	-- If frame is not docked then allow the frame to be dragged or dropped
	if ( this:GetButtonState() == "PUSHED" ) then
		chatFrame:StopMovingOrSizing();
		local activeDockRegion = FCF_GetActiveDockRegion();
		if ( activeDockRegion ) then
			FCF_DockFrame(chatFrame, activeDockRegion);
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
	local chatTab = getglobal(chatFrame:GetName().."Tab");
	chatTab:SetPoint("BOTTOMLEFT", chatFrame:GetName().."Background", "TOPLEFT", x+2, 0);
end

function FCF_GetActiveDockRegion()
	for index, value in DOCKED_CHAT_FRAMES do
		dockRegion = getglobal(value:GetName().."TabDockRegion");
		if ( dockRegion:IsVisible() ) then
			return index + 1;
		end
	end
	return nil;
end

function FCF_SaveDock()
	local count = 1;
	local tempDock = DOCKED_CHAT_FRAMES;
	DOCKED_CHAT_FRAMES = {};
	for index, value in tempDock do
		DOCKED_CHAT_FRAMES[count] = value;
		SetChatWindowDocked(value:GetID(), count);
		count = count + 1;
	end
end

function FCF_Close(frame)
	if ( not frame ) then
		frame = FCF_GetCurrentChatFrame();
	end
	if ( frame == DEFAULT_CHAT_FRAME ) then
		return;
	end
	HideUIPanel(frame);
	getglobal(frame:GetName().."Tab"):Hide();
	FCF_UnDockFrame(frame);
end

-- Moves a ChatFrame to a valid position if the user moves it off the screen
function FCF_ValidateChatFramePosition(chatFrame)
	-- Determine if the dragging tab is offscreen.  If so move the frame
	local chatTab = getglobal(chatFrame:GetName().."Tab");
	local left = chatTab:GetLeft();
	local right = chatTab:GetRight();
	local top = chatTab:GetTop();
	local bottom = chatTab:GetBottom();
	local newAnchorX, newAnchorY;
	local offscreenPadding = 15;
	if ( top < (0 + MainMenuBar:GetHeight() + offscreenPadding)) then
		-- Off the bottom of the screen
		newAnchorY = MainMenuBar:GetHeight() + chatTab:GetHeight() - GetScreenHeight(); 
	elseif ( bottom > GetScreenHeight() ) then
		-- Off the top of the screen
		newAnchorY =  -chatTab:GetHeight();
	end
	if ( right < 0 ) then
		-- Off the left of the screen
		newAnchorX = chatTab:GetWidth();
	elseif ( left > GetScreenWidth() ) then
		-- Off the right of the screen
		newAnchorX = GetScreenWidth() - chatTab:GetWidth();
	end
	if ( newAnchorX or newAnchorY ) then
		if ( not newAnchorX ) then
			newAnchorX = left;
		elseif ( not newAnchorY ) then
			newAnchorY = top - GetScreenHeight();
		end
		chatFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", newAnchorX, newAnchorY);
	end
end

-- Tab flashing functions
function FCF_FlashTab()
	local tabFlash = getglobal(this:GetName().."TabFlash");
	if ( not this.isDocked or (this == SELECTED_DOCK_FRAME) or UIFrameIsFlashing(tabFlash) ) then
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
	
	if ( GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() ) then
		DEFAULT_CHAT_FRAME:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 100);
	else
		DEFAULT_CHAT_FRAME:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 85);
	end
end

function FCF_Set_SimpleChat()
	-- Main chat window
	ChatFrame1:ClearAllPoints();
	ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 85);
	ChatFrame1:SetWidth(608);
	ChatFrame1:SetHeight(120);
	FCF_UpdateDockPosition();
	ChatFrame1Tab:Hide();
	FCF_SetButtonSide(ChatFrame1, "left")
	FCF_SetLocked(ChatFrame1, 1);
	FCF_SetChatWindowFontSize(ChatFrame1, 14);
	FCF_SetWindowName(ChatFrame1, GENERAL);
	FCF_SetWindowAlpha(ChatFrame1, 0);

	FCF_UnDockFrame(ChatFrame2);
	ChatFrame2:ClearAllPoints();
	ChatFrame2:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -32, 75);
	ChatFrame2:SetWidth(320);
	ChatFrame2:SetHeight(120);
	FCF_SetTabPosition(ChatFrame2, 0);
	ChatFrame2Tab:Hide();
	FCF_SetLocked(ChatFrame2, 1);
	FCF_SetChatWindowFontSize(ChatFrame2, 14);
	FCF_SetWindowName(ChatFrame2, COMBAT_LOG);
	FCF_SetWindowAlpha(ChatFrame2, 0);
	ChatFrame2:Show();
	FCF_SetButtonSide(ChatFrame2, "right")
	ChatFrame_RemoveAllChannels(ChatFrame2);
	ChatFrame_RemoveAllMessageGroups(ChatFrame2);
	ChatFrame_ActivateCombatMessages(ChatFrame2);
	for i=3, NUM_CHAT_WINDOWS do
		FCF_Close(getglobal("ChatFrame"..i));
	end
end

function FCF_Set_NormalChat()
	ChatFrame2:StartMoving();
	ChatFrame2:StopMovingOrSizing();
	FCF_SetLocked(ChatFrame2, nil);
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
		if ( ChatFrame2:IsVisible() ) then
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
