MAX_CHANNEL_BUTTONS = 20;
MAX_DISPLAY_CHANNEL_BUTTONS = 16;
MAX_CHANNEL_MEMBER_BUTTONS = 22;
CHANNEL_ROSTER_HEIGHT = 15;
CHANNEL_FRAME_SCROLLBAR_OFFSET = 25;
CHANNEL_TITLE_WIDTH = 135;
CHANNEL_TITLE_OFFSET= 10;
CHANNEL_HEADER_OFFSET = 5;
CHAT_CHANNEL_TABBING = {};
CHAT_CHANNEL_TABBING[1] = "ChannelFrameDaughterFrameChannelPassword";
CHAT_CHANNEL_TABBING[2] = "ChannelFrameDaughterFrameChannelName";

local rosterFrame;

function ChannelFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("CHANNEL_UI_UPDATE");
	self:RegisterEvent("MUTELIST_UPDATE");
	self:RegisterEvent("IGNORELIST_UPDATE");
	self:RegisterEvent("CHANNEL_FLAGS_UPDATED");
	self:RegisterEvent("CHANNEL_VOICE_UPDATE");
	self:RegisterEvent("CHANNEL_COUNT_UPDATE");
	self:RegisterEvent("CHANNEL_ROSTER_UPDATE");
	FauxScrollFrame_SetOffset(ChannelRosterScrollFrame, 0);
	ChannelFrame_Update();
end

function ChannelFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or event == "CHANNEL_UI_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		ChannelFrame_Update();
	elseif ( event == "CHANNEL_FLAGS_UPDATED" ) then
		if ( arg1 == ChannelListDropDown.clicked ) then
			ChannelList_ShowDropdown(arg1);
		end
	elseif ( event == "CHANNEL_VOICE_UPDATE" ) then
		ChannelList_UpdateVoice(arg1, arg2, arg3);
	elseif ( event == "CHANNEL_COUNT_UPDATE" ) then
		ChannelList_CountUpdate(arg1, arg2);
	elseif ( event == "CHANNEL_ROSTER_UPDATE" ) then
		ChannelRoster_Update(arg1);		
	elseif ( event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" ) then
		ChannelRoster_Update(GetSelectedDisplayChannel());
	end
end

function ChannelFrame_Update()
	local id = GetSelectedDisplayChannel();
	if ( not id ) then
		id = GetActiveVoiceChannel();
	end
	ChannelList_Update();
	ChannelList_UpdateHighlight(id);
	ChannelRoster_Update(id);
	--ChannelFrame_UpdateJoin();
end

function ChannelFrame_OnUpdate(self, elapsed)
	if ( not ChannelFrame.updating ) then
		return;
	else
		ChannelRoster_Update(ChannelFrame.updating);
		ChannelFrame.updating = nil;
	end
end

function ChannelFrame_UpdateJoin()
	local id = GetSelectedDisplayChannel();
	if ( id ) then
		local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(id);
		if ( category == "CHANNEL_CATEGORY_WORLD" and not active ) then
			ChannelFrameJoinButton:Enable();
		end
	else
		ChannelFrameJoinButton:Disable();
	end
end

function ChannelFrame_New_OnClick()
	if ( ChannelFrameDaughterFrame:IsShown() ) then
		ChannelFrameDaughterFrame:Hide();		
	else
		ChannelFrameDaughterFrameChannelNameLabel:SetText(CHANNEL_CHANNEL_NAME);
		ChannelFrameDaughterFrameChannelPasswordLabel:SetText(PASSWORD);
		ChannelFrameDaughterFrameChannelPasswordOptional:Show();
		ChannelFrameDaughterFrameName:SetText(CHANNEL_NEW_CHANNEL);
		--ChannelFrameDaughterFrameVoiceChat:SetChecked(1);
		--ChannelFrameDaughterFrameVoiceChat:Show();
		ChannelFrameDaughterFrame:Show();
		PlaySound("UChatScrollButton");
	end
end

function ChannelFrame_Join_OnClick()
	if ( ChannelFrameDaughterFrame:IsShown() ) then
		ChannelFrameDaughterFrame:Hide();		
	else
		local selected = GetSelectedDisplayChannel();
		local button;
		if ( selected ) then
			button = _G["ChannelButton"..selected];
		end
		if ( button and button.global ) then
			JoinPermanentChannel(button.channel, nil, nil, 1);
		else
			ChannelFrameDaughterFrameChannelNameLabel:SetText(CHANNEL_CHANNEL_NAME);
			ChannelFrameDaughterFrameChannelPasswordLabel:SetText(PASSWORD);
			ChannelFrameDaughterFrameChannelPasswordOptional:Show();
			ChannelFrameDaughterFrameName:SetText(CHANNEL_JOIN_CHANNEL);
			--ChannelFrameDaughterFrameVoiceChat:Hide();
			ChannelFrameDaughterFrame:Show();
		end
	end
end

function ChannelFrameDaughterFrame_Okay()
	local name = ChannelFrameDaughterFrameChannelName:GetText();
	local password = ChannelFrameDaughterFrameChannelPassword:GetText();
	local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
	if ( not zoneChannel ) then
		local info = ChatTypeInfo["CHANNEL"];
		DEFAULT_CHAT_FRAME:AddMessage(CHAT_INVALID_NAME_NOTICE, info.r, info.g, info.b, info.id);
		ChannelFrameDaughterFrame:Hide();
		return;
	end
	if ( channelName ) then
		name = channelName;
	end
	local i = 1;
	while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
		i = i + 1;
	end
	DEFAULT_CHAT_FRAME.channelList[i] = name;
	DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	
	-- Clear Out Values
	ChannelFrameDaughterFrame:Hide();
end

function ChannelFrameDaughterFrame_Cancel(self)
	self:GetParent():Hide();
end

function ChannelFrameDaughterFrame_OnHide()
	ChannelFrameDaughterFrameChannelName:SetText("");
	ChannelFrameDaughterFrameChannelPassword:SetText("");
	PlaySound("UChatScrollButton");
end

--[ Channel List Functions ]--
function ChannelList_Update()
	-- Scroll Bar Handling --
	local frameHeight = ChannelListScrollChildFrame:GetHeight();
	local button, buttonName, buttonLines, buttonCollapsed, buttonSpeaker, hideVoice;
	local name, header, collapsed, channelNumber, active, count, category, voiceEnabled, voiceActive;
	local channelCount = GetNumDisplayChannels();
	for i=1, MAX_CHANNEL_BUTTONS, 1 do
		button = _G["ChannelButton"..i];
		buttonName = _G["ChannelButton"..i.."Text"];
		buttonLines = _G["ChannelButton"..i.."NormalTexture"];
		buttonCollapsed =  _G["ChannelButton"..i.."Collapsed"];
		buttonSpeaker = _G["ChannelButton"..i.."SpeakerFrame"];
		if ( i <= channelCount) then
			name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(i);
			if ( IsVoiceChatEnabled() ) then
				ChannelList_UpdateVoice(i, voiceEnabled, voiceActive);
			else
				ChannelList_UpdateVoice(i, nil, nil);
			end
			button.header = header;
			button.collapsed = collapsed;
			if ( header ) then
				if ( button.channel ) then
					button.channel = nil;
					button.active = nil;
					local point, rTo, rPoint, x, y = buttonName:GetPoint();
					buttonName:SetPoint(point, rTo, rPoint, CHANNEL_HEADER_OFFSET, y);
					buttonName:SetWidth(CHANNEL_TITLE_WIDTH + buttonSpeaker:GetWidth());
				end
				
				-- Set the collapsed Status
				if ( collapsed ) then
					buttonCollapsed:SetText("+");
				else
					buttonCollapsed:SetText("-");
				end
				-- Hide collapsed Status if there are no sub channels
				if ( count ) then
					buttonCollapsed:Show();
					button:Enable();
				else
					buttonCollapsed:Hide();
					button:Disable();
				end
				buttonLines:SetAlpha(1.0);
				buttonName:SetText(NORMAL_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
			else
				local point, rTo, rPoint, x, y = buttonName:GetPoint();
				if ( not button.channel ) then
					buttonName:SetPoint(point, rTo, rPoint, CHANNEL_TITLE_OFFSET, y);				
					buttonName:SetWidth(CHANNEL_TITLE_WIDTH - buttonSpeaker:GetWidth());
				end
				if ( not channelNumber ) then
					channelNumber = "";
				else
					channelNumber = channelNumber..". ";
				end
				if ( active ) then
					if ( count and category == "CHANNEL_CATEGORY_GROUP" ) then
						buttonName:SetText(HIGHLIGHT_FONT_COLOR_CODE..channelNumber..name.." ("..count..")"..FONT_COLOR_CODE_CLOSE);
					else
						buttonName:SetText(HIGHLIGHT_FONT_COLOR_CODE..channelNumber..name..FONT_COLOR_CODE_CLOSE);
					end
					button:Enable();
				else
					buttonName:SetText(GRAY_FONT_COLOR_CODE..channelNumber..name..FONT_COLOR_CODE_CLOSE);
					button:Disable();
				end
				if ( category == "CHANNEL_CATEGORY_WORLD" ) then
					button.global = 1;
					button.group = nil;
					button.custom = nil;
				elseif ( category == "CHANNEL_CATEGORY_GROUP" ) then
					button.group = 1;
					button.global = nil;
					button.custom = nil;
				elseif ( category == "CHANNEL_CATEGORY_CUSTOM" ) then
					button.custom = 1;
					button.group = nil;
					button.global = nil;
				else
					button.custom = nil;
					button.group = nil;
					button.global = nil;
				end
				buttonCollapsed:Hide();
				button.channel = name;
				button.active = active;
				buttonLines:SetAlpha(0.5);
				channelNumber = nil;
			end
			button:Show();
		else
--			button.channel = nil;
			button:Hide();
			button.voiceEnabled = nil;
			button.voiceActive = nil;
			-- Scroll Bar Handling --
			frameHeight = frameHeight - button:GetHeight();
		end
	end	

	-- Scroll Bar Handling --
	ChannelListScrollChildFrame:SetHeight(frameHeight);
	if ((ChannelListScrollFrameScrollBarScrollUpButton:IsEnabled() == 0) and (ChannelListScrollFrameScrollBarScrollDownButton:IsEnabled() == 0) ) then
		ChannelListScrollFrame.scrolling = nil;
	else
		ChannelListScrollFrame.scrolling = 1;
	end
	ChannelList_SetScroll();
end

function ChannelList_CountUpdate(id, count)
	local button = _G["ChannelButton"..id];
	local name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(id);
	if ( category == "CHANNEL_CATEGORY_GROUP" ) then
		if ( count ) then
			button:SetText(HIGHLIGHT_FONT_COLOR_CODE..channelNumber..". "..name.." ("..count..")"..FONT_COLOR_CODE_CLOSE);
		end	
	end
	if ( id == GetSelectedDisplayChannel() ) then
		ChannelRoster_Update(id);
	end
end

function ChannelList_SetScroll()
	local buttonWidth = 130;
	if ( not ChannelListScrollFrame.scrolling ) then
		ChannelMemberButton1:SetPoint("TOPLEFT", ChannelFrame, "TOPLEFT", 186, -75);
		ChannelRoster:SetPoint("TOPLEFT", ChannelFrame, "TOP", 121, -79);
		ChannelListScrollFrameScrollBar:Hide();
		ChannelListScrollFrameTop:Hide();
		ChannelListScrollFrameBottom:Hide();
		buttonWidth = buttonWidth + 10;
	else
		ChannelMemberButton1:SetPoint("TOPLEFT", ChannelFrame, "TOPLEFT", 206, -75);
		ChannelRoster:SetPoint("TOPLEFT", ChannelFrame, "TOP", 97, -77);
		ChannelListScrollFrameScrollBar:Show();
		ChannelListScrollFrameTop:Show();
		ChannelListScrollFrameBottom:Show();
		buttonWidth = buttonWidth - 10;
	end
end

function ChannelRoster_SetScroll()
	local buttonWidth = 145;
	if ( not ChannelRosterScrollFrame.scrolling ) then
		ChannelRosterScrollFrameScrollBar:Hide();
		ChannelRosterScrollFrameTop:Hide();
		ChannelRosterScrollFrameBottom:Hide();
		buttonWidth = buttonWidth + 10;
	else
		ChannelRosterScrollFrameScrollBar:Show();
		ChannelRosterScrollFrameTop:Show();
		ChannelRosterScrollFrameBottom:Show();
		buttonWidth = buttonWidth - 10;
	end
	
	for i=1, MAX_CHANNEL_MEMBER_BUTTONS do
		_G["ChannelMemberButton"..i]:SetWidth(buttonWidth);
	end
end
function ChannelList_UpdateVoice(id, enabled, active)
	local speaker = _G["ChannelButton"..id.."SpeakerFrame"];
	local speakerIcon =  _G["ChannelButton"..id.."SpeakerFrameOn"];
	local speakerFlash = _G["ChannelButton"..id.."SpeakerFrameFlash"];
	local button = _G["ChannelButton" .. id];
	
	if ( enabled ) then
		button.voiceEnabled = true;
		if ( active ) then
			button.voiceActive = true;
			ChannelFrame_Desaturate(speakerIcon, nil, 1, 1, 1, 0.75);
			ChannelFrame_Desaturate(speakerFlash, nil, 1, 1, 1, 0.75);
		else
			button.voiceActive = nil;
			ChannelFrame_Desaturate(speakerIcon, 1, nil, nil, nil, 0.5);
			ChannelFrame_Desaturate(speakerFlash, 1, nil, nil, nil, 0.5);
		end
		speaker:Show()
		speaker:SetFrameLevel(speaker:GetFrameLevel()+5);
		speakerFlash:Show();
	else
		button.voiceEnabled = nil;
		button.voiceActive = nil;
		speaker:Hide();
	end
end

function ChannelList_OnClick(self, button)
	local id = self:GetID();

	PlaySound("igMainMenuOptionCheckBoxOn");

	ChannelListDropDown.clicked = nil;

	if ( button == "LeftButton" ) then
		HideDropDownMenu(1);
		if ( self.header ) then
			if ( self.collapsed ) then
				ExpandChannelHeader(id);
			else
				CollapseChannelHeader(id);
			end
		else
			ChannelList_UpdateHighlight(id);
			if ( self.active ) then
				ChannelFrame.updating = id;
				SetSelectedDisplayChannel(id);
				ChannelRoster_Update(id);
			else
				ChannelRoster_Update(0);
			end
		end
	elseif ( button == "RightButton" ) then
		if ( self.channel ) then
			FauxScrollFrame_SetOffset(ChannelRosterScrollFrame, 0);
			if ( self.global ) then
				ChannelList_UpdateHighlight(id);
				ChannelList_ShowDropdown(id);			
			end
			if ( self.active ) then
				ChannelFrame.updating = id;
				GetNumChannelMembers(id);
				ChannelList_UpdateHighlight(id);
				ChannelListDropDown.clicked = id;
				ChannelList_ShowDropdown(id);			
			end
		end
	end
end

function ChannelList_UpdateHighlight(id)
	local button;
	local channelCount = GetNumDisplayChannels();
	for i=1, MAX_CHANNEL_BUTTONS, 1 do
		button = _G["ChannelButton"..i];
		if ( i <= channelCount ) then
			if ( i == id ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end		
		end
	end
end

local function ChannelListDropDown_StripSelf (self, func1, arg1)
	func1(arg1);
end

--[ DropDown Functions ]--
function ChannelListDropDown_Initialize()
	local count = 0;
	local info;
	if ( not ChannelListDropDown.global ) then
		if ( IsVoiceChatEnabled() ) then
			-- Enable Voice Chat option if Voice Chat is enabled.
			if ( not ChannelListDropDown.voice and IsDisplayChannelOwner() ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = CHAT_VOICE_ON;
				info.notCheckable = 1;
				info.func = ChannelListDropDown_StripSelf
				info.arg1 = DisplayChannelVoiceOn;
				info.arg2 = ChannelListDropDown.id;
				UIDropDownMenu_AddButton(info);
				count = count + 1;
			end
			-- Voice Chat option if Voice Chat is enabled.
			if ( ChannelListDropDown.voice and not ChannelListDropDown.voiceActive ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = CHAT_VOICE;
				info.notCheckable = 1;
				info.func = ChannelListDropDown_StripSelf				
				info.arg1 = SetActiveVoiceChannel;
				info.arg2 = ChannelListDropDown.id;
				UIDropDownMenu_AddButton(info);
				count = count + 1;

			--[[ Disable Voice Chat option if Voice Chat is enabled and not a group channel.
				if ( not ChannelListDropDown.group and IsDisplayChannelOwner() ) then
					info = UIDropDownMenu_CreateInfo();
					info.text = CHAT_VOICE_OFF;
					info.notCheckable = 1;
					info.func = SetActiveVoiceChannel;
					info.arg1 = ChannelListDropDown.id;
					UIDropDownMenu_AddButton(info);
					count = count + 1;
				end]]--
			end
		end

		-- SET PASSWORD if it is a custom Channel and is owner
		if ( ChannelListDropDown.custom and IsDisplayChannelOwner() ) then
			info = UIDropDownMenu_CreateInfo();
			info.text = CHAT_PASSWORD;
			info.notCheckable = 1;
			info.func = ChannelListDropDown_StripSelf			
			info.arg1 = ChannelListDropDown_SetPassword;
			info.arg2 = ChannelListDropDown.channelName;
			UIDropDownMenu_AddButton(info);
			count = count + 1;
		end
		
		-- INVITE if it is a custom Channel and is owner
		if ( ChannelListDropDown.custom and IsDisplayChannelModerator() ) then
			info = UIDropDownMenu_CreateInfo();
			info.text = PARTY_INVITE;
			info.notCheckable = 1;
			info.func = ChannelListDropDown_StripSelf
			info.arg1 = ChannelListDropDown_Invite;
			info.arg2 = ChannelListDropDown.channelName;
			UIDropDownMenu_AddButton(info);
			count = count + 1;
		end

	end
	-- JOIN if it is a Global Channel
	if ( ChannelListDropDown.global and not ChannelListDropDown.active ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = CHAT_JOIN;
		info.notCheckable = 1;
		info.func = ChannelListDropDown_StripSelf
		info.arg1 = JoinPermanentChannel;
		info.arg2 = ChannelListDropDown.channelName;
		UIDropDownMenu_AddButton(info);
		count = count + 1;
	end
	
	-- LEAVE Channel if not a group channel
	if ( not ChannelListDropDown.group and ChannelListDropDown.active ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = CHAT_LEAVE;
		info.notCheckable = 1;
		info.func = ChannelListDropDown_StripSelf
		info.arg1 = LeaveChannelByName;
		info.arg2 = ChannelListDropDown.channelName;
		UIDropDownMenu_AddButton(info);
		count = count + 1;
	end
	
	if ( count > 0 ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = CANCEL;
		info.notCheckable = 1;
		info.func = ChannelListDropDown_HideDropDown;
		UIDropDownMenu_AddButton(info);
	end

end

function ChannelListDropDown_HideDropDown(self)
	self:GetParent():Hide();
end

function ChannelListDropDown_SetPassword(name)
	local dialog = StaticPopup_Show("CHANNEL_PASSWORD", name);
	if ( dialog ) then
		dialog.data = name;
	end
end

function ChannelListDropDown_Invite(name)
	local dialog = StaticPopup_Show("CHANNEL_INVITE", name);
	if ( dialog ) then
		dialog.data = name;
	end
end

function ChannelList_ShowDropdown(id)
	local name, header, collapsed, channelNumber, count, active, category, voice, voiceActive;
	name, header, collapsed, channelNumber, count, active, category, voice, voiceActive = GetChannelDisplayInfo(id);
	HideDropDownMenu(1);
	local button = _G["ChannelButton"..id];
	ChannelListDropDown.global = button.global;
	ChannelListDropDown.group = button.group;
	ChannelListDropDown.custom = button.custom;
	ChannelListDropDown.initialize = ChannelListDropDown_Initialize;
	ChannelListDropDown.displayMode = "MENU";
	ChannelListDropDown.id = id;
	ChannelListDropDown.voice = voice;
	ChannelListDropDown.voiceActive = voiceActive;
	ChannelListDropDown.active = active;
	ChannelListDropDown.channelName = name;
	ToggleDropDownMenu(1, nil, ChannelListDropDown, "cursor");
end

function ChannelListButton_OnDragStart (button)	
	local name, index, spoof = ChannelPulloutRoster_GetActiveSession()
	if ( ( button and button.channel and button.voiceEnabled ) and ( not spoof and name == button.channel ) ) then
		CHANNELPULLOUT_OPTIONS.displayActive = true;
	elseif ( button.channel and button.voiceEnabled ) then
		CHANNELPULLOUT_OPTIONS.displayActive = nil;
		CHANNELPULLOUT_OPTIONS.name = button.channel;
		CHANNELPULLOUT_OPTIONS.session = ChannelPulloutRoster_GetSessionIDByName(button.channel); 
	else
		return;
	end
	
	if ( not ChannelPullout:IsShown() ) then
		ChannelPullout_ToggleDisplay();
	end
	
	ChannelPulloutRoster_OnEvent(rosterFrame or ChannelPulloutRoster);
	 
	ChannelPulloutTab:StartMoving();
	ChannelPulloutTab:ClearAllPoints();
	local x, y = GetCursorPosition();
	x, y = x / UIParent:GetScale(), y / UIParent:GetScale();
	ChannelPulloutTab:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	ChannelPulloutTab.dragging = true;
end

function ChannelListButton_OnDragStop (button)
	ChannelPulloutTab:StopMovingOrSizing();
	ChannelPulloutTab.dragging = nil;
end

--[ Channel Roster Functions ]--
function ChannelRoster_Update(id)
	if ( (not id) or (type(id) ~= "number") ) then
		id = GetSelectedDisplayChannel();
	end
	if ( not id ) then
		id = 0;
	end
	local channel, header, collapsed, channelNumber, count, active, category = GetChannelDisplayInfo(id);
	local button, buttonName, buttonRank, buttonRankTexture, buttonVoice, buttonVoiceMuted, newWidth, nameWidth;

	if ( count ) then
		if ( category == "CHANNEL_CATEGORY_GROUP" ) then
			ChannelRosterChannelCount:SetText("("..count..")");
		else
			ChannelRosterChannelCount:SetText("");
		end
	-- ScrollFrame stuff
		if ( count > MAX_CHANNEL_MEMBER_BUTTONS ) then
			ChannelRosterScrollFrame.scrolling = 1;
		else
			ChannelRosterScrollFrame.scrolling = nil;
		end
		if ( channel ) then
			ChannelRosterHiddenText:SetText(channel);
			ChannelRosterChannelName:SetText(channel);
			--Set the width of the title bar.
			nameWidth = ChannelRosterHiddenText:GetWidth();
			if ( ChannelListScrollFrame.scrolling ) then
				newWidth = CHANNEL_TITLE_WIDTH - CHANNEL_FRAME_SCROLLBAR_OFFSET;
			else
				newWidth = CHANNEL_TITLE_WIDTH;
			end
			if ( nameWidth > newWidth) then
				nameWidth = newWidth;
			end

			ChannelRosterChannelName:SetHeight(13);
			ChannelRosterChannelName:SetWidth(nameWidth);
		end
	else
		ChannelRosterScrollFrame.scrolling = nil;
		ChannelRosterChannelName:SetText("");
		ChannelRosterChannelCount:SetText("");		
		count = 0;
	end
	local rosterOffset = FauxScrollFrame_GetOffset(ChannelRosterScrollFrame);
	local name, owner, moderator, muted, active, enabled;
	local rosterIndex;
	for i=1, MAX_CHANNEL_MEMBER_BUTTONS do
		rosterIndex = rosterOffset + i;
		button = _G["ChannelMemberButton"..i];
		if ( rosterIndex <= count ) then
			buttonName = _G["ChannelMemberButton"..i.."Name"];
			buttonRank =  _G["ChannelMemberButton"..i.."Rank"];
			buttonRankTexture =  _G["ChannelMemberButton"..i.."RankTexture"];
			buttonVoice = _G["ChannelMemberButton"..i.."SpeakerFrame"];
			buttonVoiceMuted = _G["ChannelMemberButton"..i.."SpeakerFrameMuted"];
			name, owner, moderator, muted, active, enabled = GetChannelRosterInfo(id, rosterIndex);
			buttonName:SetText(name);
			button.name = name;
			if ( owner  or moderator ) then
				-- Sets the Leader/Assistant Icon
				if ( owner ) then
					buttonRankTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				elseif ( moderator ) then
					buttonRankTexture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				end
				buttonRank:Show();
			else
				buttonRank:Hide();
			end
			if ( IsVoiceChatEnabled() ) then
				ChannelRoster_UpdateVoice(i, enabled, active, muted);
			else
				ChannelRoster_UpdateVoice(i, nil, nil, nil);			
			end

			button:SetID(rosterIndex);
			button:Show();
		else		
			button:Hide();
		end
	end
	ChannelRoster_SetScroll();
	FauxScrollFrame_Update(ChannelRosterScrollFrame, count, MAX_CHANNEL_MEMBER_BUTTONS, CHANNEL_ROSTER_HEIGHT );
end

function ChannelRoster_UpdateVoice(id, enabled, active, muted)
	local speaker = _G["ChannelMemberButton"..id.."SpeakerFrame"];
	local speakerIcon =  _G["ChannelMemberButton"..id.."SpeakerFrameOn"];
	local speakerFlash = _G["ChannelMemberButton"..id.."SpeakerFrameFlash"];
	local speakerMuted = _G["ChannelMemberButton"..id.."SpeakerFrameMuted"];

	if ( enabled ) then
		if ( active ) then
			ChannelFrame_Desaturate(speakerIcon, nil, 1, 1, 1, 0.75);
			ChannelFrame_Desaturate(speakerFlash, nil, 1, 1, 1, 0.75);
		else
			ChannelFrame_Desaturate(speakerIcon, 1, nil, nil, nil, 0.25);
			ChannelFrame_Desaturate(speakerFlash, 1, nil, nil, nil, 0.25);
		end
		if ( muted ) then
			speakerMuted:Show();
		else
			speakerMuted:Hide();
		end
		speaker:Show()
		speakerFlash:Show();
	else
		speaker:Hide();
	end
end

function ChannelRoster_OnClick(self, button)
	if ( button == "RightButton" ) then
		ChannelRosterFrame_ShowDropdown(self:GetID());
	end
end

--[ DropDown Functions ]--
function ChannelRosterDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "CHAT_ROSTER", nil, ChannelRosterDropDown.name);
end

function ChannelRosterFrame_ShowDropdown(id)
	HideDropDownMenu(1);
	local channelID = GetSelectedDisplayChannel();
	local channelName, header, collapsed, channelNumber, count, active, category;
	local name, owner, moderator, muted, voiceEnabled;
	channelName, header, collapsed, channelNumber, count, active, category = GetChannelDisplayInfo(channelID);
	name, owner, moderator, muted, voiceEnabled = GetChannelRosterInfo(channelID, id);
	ChannelRosterDropDown.initialize = ChannelRosterDropDown_Initialize;
	ChannelRosterDropDown.displayMode = "MENU";
	ChannelRosterDropDown.name = name;
	ChannelRosterDropDown.owner = owner;
	ChannelRosterDropDown.moderator = moderator;
	ChannelRosterDropDown.channelName = channelName;
	ChannelRosterDropDown.category = category;
	ToggleDropDownMenu(1, nil, ChannelRosterDropDown, "cursor");
end

--[ Utility Functions ]--
function ChannelFrame_Desaturate(texture, desaturate, r, g, b, a)
	local shaderSupported = texture:SetDesaturated(desaturate);
	if ( not desaturate ) then
		r = 1.0;
		g = 1.0;
		b = 1.0;
	elseif ( not r and not shaderSupported ) then
		r = 0.5;
		g = 0.5;
		b = 0.5;
	end
	texture:SetVertexColor(r, g, b);
	if ( a ) then
		texture:SetAlpha(a);
	end
end

--[[ Functions for the Channel Pullout window ]]--

CHANNELPULLOUT_TAB_SHOW_DELAY = 0.2;
CHANNELPULLOUT_TAB_FADE_TIME = 0.15;
DEFAULT_CHANNELPULLOUT_TAB_ALPHA = 0.75;
DEFAULT_CHANNELPULLOUT_ALPHA = 1;

CHANNELPULLOUT_OPTIONS = {};
CHANNELPULLOUT_MINSIZE = 5;
CHANNELPULLOUT_MAXSIZE = 25;
CHANNELPULLOUT_ROSTERFRAME_OFFSETY = 4;
CHANNELPULLOUT_ROSTERPARENT_YPADDING = 14;

CHANNELPULLOUT_FADEFRAMES = { "ChannelPulloutBackground", "ChannelPulloutCloseButton", "ChannelPulloutRosterScroll" };

function ChannelPullout_OnLoad (self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:SetScript("OnEvent", ChannelPullout_OnEvent);
	RegisterForSave("CHANNELPULLOUT_OPTIONS");
end

function ChannelPullout_OnEvent (self)
	if ( CHANNELPULLOUT_OPTIONS.display ) then
		self:Show();
	end
end

function ChannelPullout_OnUpdate (self, elapsed)
	local ChannelPulloutTab = ChannelPulloutTab;
	if ( self:IsMouseOver(45, -10, -5, 5) ) then
		local xPos, yPos = GetCursorPosition();
		-- If mouse is hovering don't show the tab until the elapsed time reaches the tab show delay
		if ( self.hover ) then
			if ( (self.oldX == xPos and self.oldy == yPos) ) then
				self.hoverTime = self.hoverTime + elapsed;
			else
				self.hoverTime = 0;
				self.oldX = xPos;
				self.oldy = yPos;
			end
			if ( self.hoverTime > CHANNELPULLOUT_TAB_SHOW_DELAY or ChannelPulloutTab.dragging ) then
				-- If the tab's alpha is less than the current default, then fade it in 
				if ( not self.hasBeenFaded and (ChannelPulloutTab.oldAlpha and ChannelPulloutTab.oldAlpha < DEFAULT_CHANNELPULLOUT_TAB_ALPHA) ) then
					UIFrameFadeIn(ChannelPulloutTab, CHANNELPULLOUT_TAB_FADE_TIME, ChannelPulloutTab.oldAlpha, DEFAULT_CHANNELPULLOUT_TAB_ALPHA);
					local frame;
					for _, name in next, CHANNELPULLOUT_FADEFRAMES do
						frame = _G[name];
						if ( frame:IsShown() ) then
							UIFrameFadeIn(frame, CHANNELPULLOUT_TAB_FADE_TIME, self.oldAlpha, DEFAULT_CHANNELPULLOUT_ALPHA);
						end
					end
					-- Set the fact that the chatFrame has been faded so we don't try to fade it again
					self.hasBeenFaded = 1;
				end
			end
		else
			-- Start hovering counter
			self.hover = 1;
			self.hoverTime = 0;
			self.hasBeenFaded = nil;
			CURSOR_OLD_X, CURSOR_OLD_Y = GetCursorPosition();
			-- Remember the oldAlpha so we can return to it later
			if ( not ChannelPulloutTab.oldAlpha ) then
				ChannelPulloutTab.oldAlpha = ChannelPulloutTab:GetAlpha();
			end
			
			self.oldAlpha = ChannelPulloutBackground:GetAlpha();
		end
	else
		-- If the tab's alpha was less than the current default, then fade it back out to the oldAlpha
		if ( self.hasBeenFaded and ChannelPulloutTab.oldAlpha and ChannelPulloutTab.oldAlpha < DEFAULT_CHANNELPULLOUT_TAB_ALPHA ) then
			UIFrameFadeOut(ChannelPulloutTab, CHANNELPULLOUT_TAB_FADE_TIME, DEFAULT_CHANNELPULLOUT_TAB_ALPHA, ChannelPulloutTab.oldAlpha);
			local frame;
			for _, name in next, CHANNELPULLOUT_FADEFRAMES do
				frame = _G[name];
				if ( frame:IsShown() ) then
					UIFrameFadeOut(frame, CHANNELPULLOUT_TAB_FADE_TIME, DEFAULT_CHANNELPULLOUT_ALPHA, self.oldAlpha);
				end
			end
			self.hover = nil;
			self.hasBeenFaded = nil;
		end
		self.hoverTime = 0;
	end	
end

function ChannelPullout_ShowOpacity ()
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPRIGHT", "ChannelPullout", "TOPLEFT", 0, 7);
	OpacityFrame.opacityFunc = ChannelPullout_SetOpacity;
	OpacityFrame.saveOpacityFunc = ChannelPullout_SaveOpacity;
	OpacityFrame:Show();
	OpacityFrameSlider:SetValue(CHANNELPULLOUT_OPTIONS.opacity or 0);
end

function ChannelPullout_SetOpacity(value)
	local alpha = 1.0 - (value or OpacityFrameSlider:GetValue());
	ChannelPulloutBackground:SetAlpha(alpha);
	ChannelPulloutCloseButton:SetAlpha(alpha);
end

function ChannelPullout_SaveOpacity()
	CHANNELPULLOUT_OPTIONS.opacity = OpacityFrameSlider:GetValue();
	OpacityFrame.saveOpacityFunc = nil;
end

function ChannelPullout_ToggleDisplay ()
	if ( ChannelPullout:IsShown() ) then
		ChannelPullout:Hide();
		ChannelPulloutTab:Hide();
		CHANNELPULLOUT_OPTIONS.display = nil;
	else
		ChannelPullout:Show();
		ChannelPulloutTab:Show();
		CHANNELPULLOUT_OPTIONS.display = true;
	end
end

function ChannelPulloutTab_OnClick (tab, button)
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, ChannelPulloutTabDropDown, tab:GetName(), 0, 0);
		return;
	end

	CloseDropDownMenus();
	
	if ( tab:GetButtonState() == "PUSHED" ) then
		tab:StopMovingOrSizing();
	elseif ( CHANNELPULLOUT_OPTIONS.locked ) then
		return;
	else
		tab:StartMoving();
	end
	
	ValidateFramePosition(tab);
end

function ChannelPulloutTab_ReanchorLeft ()
	-- Make sure that we're always anchoring the left side of the tab, otherwise resizing the tab moves the roster
	local point = { ChannelPulloutTab:GetPoint() };
	if ( string.match(point[1], "RIGHT") ) then
		point[1] = string.gsub(point[1], "RIGHT", "LEFT");
		point[4] = point[4] - ChannelPulloutTab:GetWidth();
		ChannelPulloutTab:ClearAllPoints();
		ChannelPulloutTab:SetPoint(unpack(point));
	end
end

function ChannelPulloutTab_UpdateText (text)
	ChannelPulloutTab_ReanchorLeft();
	ChannelPulloutTabText:SetText(text or CHANNEL_ROSTER);
	PanelTemplates_TabResize(ChannelPulloutTab, 0);
end

function ChannelPulloutTabDropDown_Initialize ()
	local checked, name, index;
	local info = UIDropDownMenu_CreateInfo();

	if ( not rosterFrame ) then
		return;
	end
	
	info.text = CHANNELS;
	info.notCheckable = true;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info, 1);
	
	info = UIDropDownMenu_CreateInfo();
	
	info.text = DISPLAY_ACTIVE_CHANNEL;
	info.func = function ()
			CHANNELPULLOUT_OPTIONS.displayActive = not CHANNELPULLOUT_OPTIONS.displayActive;
			CHANNELPULLOUT_OPTIONS.name = nil;
			CHANNELPULLOUT_OPTIONS.session = nil;
			ChannelPulloutRoster_OnEvent(rosterFrame);
		end
	info.checked = CHANNELPULLOUT_OPTIONS.displayActive;
	UIDropDownMenu_AddButton(info, 1);
	
	for i = 1, GetNumVoiceSessions() do
		name = GetVoiceSessionInfo(i);
		info.text = name;
		info.func = function (self)
				CHANNELPULLOUT_OPTIONS.name = self.value;
				CHANNELPULLOUT_OPTIONS.displayActive = nil;
				ChannelPulloutRoster_OnEvent(rosterFrame);
			end
		info.checked = ( function () if ( ( not CHANNELPULLOUT_OPTIONS.displayActive ) and CHANNELPULLOUT_OPTIONS.name == name ) then return true end return false end )();
		UIDropDownMenu_AddButton(info, 1);
	end
	
	info.checked = nil;
	info.text = DISPLAY_OPTIONS;
	info.notCheckable = true;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info, 1);
	
	info = UIDropDownMenu_CreateInfo();
	
	info.text = LOCK_CHANNELPULLOUT_LABEL;
	info.func = function() CHANNELPULLOUT_OPTIONS.locked = not CHANNELPULLOUT_OPTIONS.locked end;
	info.checked = CHANNELPULLOUT_OPTIONS.locked
	UIDropDownMenu_AddButton(info, 1);
	
	info.text = CHANNELPULLOUT_OPACITY_LABEL;
	info.func = ChannelPullout_ShowOpacity;
	info.checked = nil;
	UIDropDownMenu_AddButton(info, 1);
end

function ChannelPulloutRoster_OnLoad (self)
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VOICE_SESSIONS_UPDATE");
	self:RegisterEvent("CHANNEL_ROSTER_UPDATE");
	self:RegisterEvent("VOICE_CHANNEL_STATUS_UPDATE");
	self:SetScript("OnEvent", ChannelPulloutRoster_OnEvent);
	self.members = {};
	self.scroll = _G[self:GetName() .. "Scroll"];
	if ( self.scroll ) then
		self.upBtn = _G[self.scroll:GetName() .. "UpBtn"];
		self.downBtn = _G[self.scroll:GetName() .. "DownBtn"];
		self.topBtn = _G[self.scroll:GetName() .. "TopBtn"];
		self.bottomBtn = _G[self.scroll:GetName() .. "BottomBtn"];
	end
end

function ChannelPulloutRoster_OnEvent (rosterFrame, event, ...)
	ChannelPulloutRoster_GetSessionInfo(rosterFrame)
	ChannelPulloutRoster_Populate(rosterFrame, "ChannelPulloutRosterButtonTemplate", #rosterFrame.members)
	ChannelPulloutRoster_Update(rosterFrame);
	ChannelPulloutRoster_UpdateScrollControls(rosterFrame);
	ChannelPullout_SetOpacity(CHANNELPULLOUT_OPTIONS.opacity or 0);
	if ( CHANNELPULLOUT_OPTIONS.display and not ChannelPullout:IsShown() ) then
		ChannelPullout_ToggleDisplay();
	end
end

function ChannelPulloutRoster_GetActiveSession ()
	local name, active;
	for i = 1, GetNumVoiceSessions() do
		name, active = GetVoiceSessionInfo(i);
		if ( active ) then
			return name, i;
		end
	end

	name = GetVoiceSessionInfo(1);
	if ( name ) then
		return name, 1, true;
	end
	
	return false;
end

function ChannelPulloutRoster_GetSessionIDByName (name)
	for i = 1, GetNumVoiceSessions() do
		if ( GetVoiceSessionInfo(i) == name ) then
			return i;
		end
	end
	
	return nil;
end

function ChannelPulloutRoster_GetSessionInfo (roster)
	rosterFrame = roster or rosterFrame;
	
	local index, name;	
	if ( CHANNELPULLOUT_OPTIONS.displayActive or ( not CHANNELPULLOUT_OPTIONS.session and not CHANNELPULLOUT_OPTIONS.name ) ) then
		CHANNELPULLOUT_OPTIONS.displayActive = true;
		name, index = ChannelPulloutRoster_GetActiveSession();
		if ( index ) then
			CHANNELPULLOUT_OPTIONS.session = index;
			CHANNELPULLOUT_OPTIONS.name = name;
		else
			CHANNELPULLOUT_OPTIONS.name = CHANNEL_ROSTER;
			CHANNELPULLOUT_OPTIONS.session = nil;
		end
	elseif ( CHANNELPULLOUT_OPTIONS.name ) then
		CHANNELPULLOUT_OPTIONS.session = ChannelPulloutRoster_GetSessionIDByName(CHANNELPULLOUT_OPTIONS.name);
		if ( not CHANNELPULLOUT_OPTIONS.session ) then
			CHANNELPULLOUT_OPTIONS.name = CHANNEL_ROSTER;
		end
	end
	
	ChannelPulloutTab_UpdateText(CHANNELPULLOUT_OPTIONS.name);
		
	local numMembers = GetNumVoiceSessionMembersBySessionID(CHANNELPULLOUT_OPTIONS.session) or 0;
	for i = 1, numMembers do
		rosterFrame.members[i] = { GetVoiceSessionMemberInfoBySessionID(CHANNELPULLOUT_OPTIONS.session, i) };
	end
		
	if ( numMembers < #rosterFrame.members ) then
		for i = #rosterFrame.members, numMembers + 1, -1 do
			rosterFrame.members[i] = nil;
		end
	end
	
	table.sort(rosterFrame.members, ChannelPulloutRoster_Sort);
end

function ChannelPulloutRoster_Populate (roster, templateName, maxButtons)
	rosterFrame = roster or rosterFrame;	
	local button;
	if ( not rosterFrame.buttons ) then
		rosterFrame.buttons = {}
		rosterFrame.freeButtons = {};
		button = CreateFrame("BUTTON", rosterFrame:GetName() .. "Button1", rosterFrame, templateName);
		button:SetPoint("TOPLEFT", rosterFrame);
		button:SetPoint("TOPRIGHT", rosterFrame);
		rosterFrame.buttonWidth = button:GetWidth();
		rosterFrame.buttonHeight = button:GetHeight();
		tinsert(rosterFrame.buttons, button);
	end
	
	maxButtons = maxButtons or math.floor(rosterFrame:GetHeight() / rosterFrame.buttonHeight);
	
	if ( maxButtons > CHANNELPULLOUT_MAXSIZE ) then
		maxButtons = CHANNELPULLOUT_MAXSIZE;
	elseif ( maxButtons < CHANNELPULLOUT_MINSIZE ) then
		maxButtons = CHANNELPULLOUT_MINSIZE;
	end
	
	if ( #rosterFrame.buttons > maxButtons ) then
		for i = #rosterFrame.buttons, maxButtons + 1, -1 do
			rosterFrame.buttons[i]:Hide();
			tinsert(rosterFrame.freeButtons, 1, rosterFrame.buttons[i]);
			rosterFrame.buttons[i] = nil;
		end
	elseif ( maxButtons > #rosterFrame.buttons and #rosterFrame.freeButtons > 0 ) then
		for i = 1, #rosterFrame.freeButtons do
			tinsert(rosterFrame.buttons, rosterFrame.freeButtons[1]);
			tremove(rosterFrame.freeButtons, 1);
			if ( maxButtons <= #rosterFrame.buttons ) then
				break;
			end
		end
	end
	
	for i = #rosterFrame.buttons + 1, maxButtons do
		button = CreateFrame("BUTTON", rosterFrame:GetName() .. "Button" .. i, rosterFrame, templateName);
		button:SetPoint("TOP", rosterFrame.buttons[#rosterFrame.buttons], "BOTTOM");
		button:SetPoint("LEFT", rosterFrame, "LEFT");
		button:SetPoint("RIGHT", rosterFrame, "RIGHT");
		tinsert(rosterFrame.buttons, button);
	end

	rosterFrame.buttonHeight = rosterFrame.buttons[1]:GetHeight();
	rosterFrame:SetHeight((rosterFrame.buttonHeight * #rosterFrame.buttons) + CHANNELPULLOUT_ROSTERFRAME_OFFSETY)
	rosterFrame:GetParent():SetHeight(rosterFrame:GetHeight() + CHANNELPULLOUT_ROSTERPARENT_YPADDING);
	rosterFrame.offset = 0;
end

function ChannelPulloutRoster_Sort (memberOne, memberTwo)	
	local name, voiceActive, sessionActive, muted, squelched = 1, 2, 3, 4, 5
	
	if ( memberOne[voiceActive] and memberTwo[voiceActive] ) then
		--If they both have voice chat enabled...
		if ( memberOne[sessionActive] and memberTwo[sessionActive] ) then
			---And they're both active in this session....
			if ( ( memberOne[muted] or memberOne[squelched] ) and not ( memberTwo[muted] or memberTwo[squelched] ) ) then
				--If memberOne is squelched or muted and memberTwo isn't, put memberTwo first.
				return false;
			elseif ( ( memberTwo[muted] or memberTwo[squelched] ) and not ( memberOne[muted] or memberOne[squelched] ) ) then
				--If memberTwo is squelched or muted and memberOne isn't, then memberOne first.
				return true;
			else
				---And niether of them are muted or squelched, sort alphabetically.
				return memberOne[name] < memberTwo[name];
			end
		elseif ( memberOne[sessionActive] and not memberTwo[sessionActive] ) then
			--If memberOne is active in the session and memberTwo isn't, display memberOne first.
			return true;
		elseif ( memberTwo[sessionActive] and not memberOne[sessionActive] ) then
			--Otherwise if memberTwo is active and memberOne isn't, display memberTwo first.
			return false;
		else
			--If niether are active, sort alphabetically.
			return memberOne[name] < memberTwo[name];
		end
	elseif ( memberOne[voiceActive] and not memberTwo[voiceActive] ) then
		--If memberOne has voice chat on and memberTwo doesn't, display memberOne first.
		return true;
	elseif ( memberTwo[voiceActive] and not memberOne[voiceActive] ) then
		--If memberTwo has voice chat on and memberOne doesn't, memberTwo first.
		return false;
	end
	
	--Otherwise, sort alphabetically.
	return memberOne[name] < memberTwo[name];
end

local CHANNEL_EMPTY_DATA = { UnitName("player"), false, false, false };
function ChannelPulloutRoster_Update (roster)
	rosterFrame = roster or rosterFrame;
	if ( not rosterFrame or not rosterFrame.members or not rosterFrame.buttons ) then
		return;
	end
	
	local name = 1;
	
	if ( not CHANNELPULLOUT_OPTIONS.session ) then
		CHANNEL_EMPTY_DATA[name] = GRAY_FONT_COLOR_CODE .. NO_VOICE_SESSIONS;
		ChannelPulloutRoster_DrawButton(rosterFrame.buttons[1], CHANNEL_EMPTY_DATA);
		for i = 2, #rosterFrame.buttons do
			ChannelPulloutRoster_DrawButton(rosterFrame.buttons[i], nil);
		end
		return;
	elseif ( #rosterFrame.members == 0 ) then
		CHANNEL_EMPTY_DATA[name] = UnitName("player");
		ChannelPulloutRoster_DrawButton(rosterFrame.buttons[1], CHANNEL_EMPTY_DATA);
		for i = 2, #rosterFrame.buttons do
			ChannelPulloutRoster_DrawButton(rosterFrame.buttons[i], nil);
		end
		return;
	end
	
	for i = 1, #rosterFrame.buttons do
		ChannelPulloutRoster_DrawButton(rosterFrame.buttons[i], rosterFrame.members[i + (rosterFrame.offset or 0)]);
	end
end

function ChannelPulloutRosterButton_OnEvent (button, event, arg1)
	if ( event == "VOICE_PLATE_START" and arg1 == button.name:GetText() and CHANNELPULLOUT_OPTIONS.name == ChannelPulloutRoster_GetActiveSession() ) then
		UIFrameFlash(_G[button:GetName().."SpeakerFlash"], 0.35, 0.35, -1);
	elseif ( arg1 == button.name:GetText() ) then
		UIFrameFlashStop(_G[button:GetName().."SpeakerFlash"]);
	end
end

function ChannelPulloutRoster_DrawButton (button, data)
	if ( not button ) then
		return;
	elseif ( not data ) then
		button:Hide();
		return;
	end
	
	local name, voiceActive, sessionActive, muted, squelched = 1, 2, 3, 4, 5

	button.name:SetText(data[name]);

	if ( data[voiceActive] ) then
		button.speaker:Show();
	else
		button.speaker:Hide();
	end
	
	if ( data[sessionActive] ) then			
		ChannelFrame_Desaturate(_G[button.speaker:GetName().."On"], nil, 1, 1, 1, 0.75);
		ChannelFrame_Desaturate(_G[button.speaker:GetName().."Flash"], nil, 1, 1, 1, 0.75);
		_G[button.speaker:GetName().."Muted"]:SetVertexColor(1, 1, 1, 1);
	else
		ChannelFrame_Desaturate(_G[button.speaker:GetName().."On"], 1, nil, nil, nil, 0.25);
		ChannelFrame_Desaturate(_G[button.speaker:GetName().."Flash"], 1, nil, nil, nil, 0.25);
		_G[button.speaker:GetName().."Muted"]:SetVertexColor(1, 1, 1, .35);
	end
	
	if ( data[muted] or data[squelched] ) then	
		_G[button.speaker:GetName().."Muted"]:Show();
	else
		_G[button.speaker:GetName().."Muted"]:Hide();
	end
	
	button:Show();
end

function ChannelPulloutRoster_ScrollToTop (roster)
	rosterFrame = roster or rosterFrame;
	if ( not rosterFrame ) then
		return;
	end
	
	rosterFrame.offset = 0;
	ChannelPulloutRoster_Update(rosterFrame);
	ChannelPulloutRoster_UpdateScrollControls(rosterFrame);
end

function ChannelPulloutRoster_ScrollToBottom (roster)
	rosterFrame = roster or rosterFrame;
	if ( not rosterFrame ) then
		return;
	end
	
	rosterFrame.offset = #rosterFrame.members - #rosterFrame.buttons;
	ChannelPulloutRoster_Update(rosterFrame);
	ChannelPulloutRoster_UpdateScrollControls(rosterFrame);
end

function ChannelPulloutRoster_Scroll (roster, dir)
	rosterFrame = roster or rosterFrame;
	if ( not rosterFrame or not dir ) then
		return;
	end
	
	-- We need to invert the delta we receive from mousewheels, and this function is designed to be used by ChannelPulloutRoster's OnMouseWheel, so we're doing this here!
	dir = -dir
	
	if ( ( rosterFrame.offset + dir ) >= 0 and ( rosterFrame.offset + dir ) <= ( #rosterFrame.members - #rosterFrame.buttons ) ) then
		rosterFrame.offset = rosterFrame.offset + dir;
	elseif ( rosterFrame.offset < 0 ) then
		rosterFrame.offset = 0;
	elseif ( rosterFrame.offset > ( #rosterFrame.members - #rosterFrame.buttons ) and ( #rosterFrame.members - #rosterFrame.buttons >= 0 ) ) then
		rosterFrame.offset = #rosterFrame.members - #rosterFrame.buttons;
	end
	
	ChannelPulloutRoster_Update(rosterFrame);
	ChannelPulloutRoster_UpdateScrollControls(rosterFrame);
end

function ChannelPulloutRoster_UpdateScrollControls (roster)
	rosterFrame = roster or rosterFrame;
	if (rosterFrame.offset <= 0) then
		rosterFrame.upBtn:Disable();
	else
		rosterFrame.upBtn:Enable();
	end
	
	if ( rosterFrame.offset >= #rosterFrame.members - #rosterFrame.buttons ) then
		rosterFrame.downBtn:Disable();
	elseif ( ( rosterFrame.offset < #rosterFrame.members - #rosterFrame.buttons ) and #rosterFrame.members > #rosterFrame.buttons ) then
		rosterFrame.downBtn:Enable();
	end
	
	if ( not ( rosterFrame.downBtn:IsEnabled() == 1 or rosterFrame.upBtn:IsEnabled() == 1 ) ) then
		rosterFrame.scroll:Hide();
	else
		rosterFrame.scroll:Show();
	end
end
