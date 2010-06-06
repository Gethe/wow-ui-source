VOICECHAT_DELAY = 1.25;
VOICECHAT_BUTTON_OFFSET = 45;
VOICECHAT_UPDATE_FREQ = 0.05
VOICECHAT_TALKERS_PADDING = 16;
MOVING_FRAME = nil; 

VOICECHAT_TALKERS = {};
local timeSinceLast = 0;

local function AddTalker(name, unit)
	assert(name, "Usage: AddTalker(name, <unitToken>)");
	for index, talker in ipairs(VOICECHAT_TALKERS) do
		if ( name == talker.name ) then
			talker.fadeout = nil;
			return;
		end
	end
	
	local talker = {}
	talker.name = name;
	talker.unit = unit;
	tinsert(VOICECHAT_TALKERS, talker);
	if ( not VoiceChatTalkers:GetScript("OnUpdate") ) then
		VoiceChatTalkers:SetScript("OnUpdate", VoiceChatTalkers_OnUpdate);
	end
end

local function RemoveTalker(name)
	assert(name, "Usage: RemoveTalker(name)");
	for index, talker in next, VOICECHAT_TALKERS do
		if ( name == talker.name ) then
			tremove(VOICECHAT_TALKERS, index);
			return;
		end
	end
end

function VoiceChatTalkers_OnLoad()
	VoiceChatTalkers.buttons = {};
	VoiceChatTalkers.visible = 0;
	local buttonFrame = CreateFrame("FRAME", "VoiceChatTalkersButton1", VoiceChatTalkers, "VoiceChatButtonTemplate");
	tinsert(VoiceChatTalkers.buttons, buttonFrame);
	buttonFrame:SetPoint("TOPLEFT", 0, -8);
	VoiceChatTalkers:RegisterEvent("VOICE_PLATE_START")
	VoiceChatTalkers:RegisterEvent("VOICE_PLATE_STOP")
	VoiceChatTalkers:RegisterEvent("VOICE_LEFT_SESSION")
	VoiceChatTalkers:RegisterEvent("PLAYER_ENTERING_WORLD")
	VoiceChatTalkers:RegisterForDrag("LeftButton");
	VoiceChatTalkers:SetAlpha(0);
end

function VoiceChatTalkers_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "VOICE_PLATE_START" ) then
		if ( arg1 and (not arg2 or not UnitIsUnit(arg2, "player")) ) then
			AddTalker(arg1, arg2);
			VoiceChatTalkers_Update();
		end	
	elseif ( event == "VOICE_PLATE_STOP" ) then
		if ( arg1 and (not arg2 or not UnitIsUnit(arg2, "player")) ) then
			for _, talker in next, VOICECHAT_TALKERS do
				if ( arg1 == talker.name ) then
					talker.fadeout = GetTime() + VOICECHAT_DELAY;
				end
			end
			VoiceChatTalkers_Update();
		end
	end
end

function VoiceChatTalkers_OnUpdate(self, elapsed)
	timeSinceLast = timeSinceLast + elapsed;
	if ( timeSinceLast > VOICECHAT_UPDATE_FREQ ) then
		local update = false;
		for _, talker in next, VOICECHAT_TALKERS do
			if ( talker.fadeout and talker.fadeout <= GetTime() ) then
				RemoveTalker(talker.name);
				update = true;
			end
		end
		
		if ( update ) then
			VoiceChatTalkers_Update();
		end
		
		if ( #VOICECHAT_TALKERS == 0 ) then
			VoiceChatTalkers:SetScript("OnUpdate", nil);
		end
		timeSinceLast = 0;
	end
end

function VoiceChatTalkers_FadeOut()
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = .35;
	fadeInfo.startAlpha = 1;
	fadeInfo.endAlpha = 0;
	fadeInfo.finishedFunc = function() if ( #VOICECHAT_TALKERS > 0 ) then return end VoiceChatTalkers.buttons[1].button:SetAttribute("name", nil); VoiceChatTalkers.buttons[1]:Hide() VoiceChatTalkersSpeaker:Show() end;
	UIFrameFade(VoiceChatTalkers, fadeInfo);
	VoiceChatTalkers.visible = 0;
end

function VoiceChatTalkers_CanHide()
	return (#VOICECHAT_TALKERS == 0) and (not VoiceChatTalkers.speakerLock) and (not VoiceChatTalkers.optionsLock) and (not VoiceChatTalkers.mouseoverLock);
end

function VoiceChatTalkers_Update()
	local visibleButtons = 0;

	if ( #VOICECHAT_TALKERS > #VoiceChatTalkers.buttons ) then
		VoiceChatTalkers_CreateButtons(#VOICECHAT_TALKERS);
	elseif ( #VOICECHAT_TALKERS == 0 ) then
		for i = 2, #VoiceChatTalkers.buttons do
			VoiceChatTalkers.buttons[i].button:SetAttribute("name", nil);
			VoiceChatTalkers.buttons[i]:Hide();
		end
		VoiceChatTalkers_ResizeFrame(1);
		VoiceChatTalkers.speakerLock = nil;
		
		if ( VoiceChatTalkers.visible > 0 and VoiceChatTalkers_CanHide() ) then
			--Only run this if we're actually changing from a number of talkers greater than zero to zero.
			VoiceChatTalkers_FadeOut();
		end
		return;
	end

	for i = 1, #VoiceChatTalkers.buttons do
		if ( VOICECHAT_TALKERS[i] ) then
			VoiceChatTalkers.buttons[i].button:SetAttribute("name", VOICECHAT_TALKERS[i].name);
			VoiceChatTalkers.buttons[i].text:SetText(VOICECHAT_TALKERS[i].name);
			VoiceChatTalkers.buttons[i]:Show();
			visibleButtons = visibleButtons + 1;
		else
			VoiceChatTalkers.buttons[i].button:SetAttribute("name", nil);
			VoiceChatTalkers.buttons[i]:Hide();
		end
	end
	
	VoiceChatTalkersSpeaker:Hide();
	VoiceChatTalkers.speakerLock = true;
	VoiceChatTalkers:SetAlpha(1);
	VoiceChatTalkers.visible = visibleButtons;
	VoiceChatTalkers_ResizeFrame(visibleButtons);
end

function VoiceChatTalkers_CreateButtons (maxButtons)
	assert(maxButtons)
	
	local buttonFrame;
	for i = #VoiceChatTalkers.buttons + 1, maxButtons do
		buttonFrame = CreateFrame("FRAME", VoiceChatTalkers:GetName() .. "Button" .. i, VoiceChatTalkers, "VoiceChatButtonTemplate");
		buttonFrame:SetPoint("TOPLEFT", VoiceChatTalkers.buttons[#VoiceChatTalkers.buttons], "BOTTOMLEFT");
		tinsert(VoiceChatTalkers.buttons, buttonFrame);
	end

	VoiceChatTalkers_ResizeFrame(maxButtons);
end

function VoiceChatTalkers_ResizeFrame(visible)
	local visibleButtons = visible;
	
	if ( not visibleButtons ) then
		for i = 1, #VoiceChatTalkers.buttons do
			if ( VoiceChatTalkers.buttons[i]:IsShown() ) then
				visibleButtons = visibleButtons + 1;
			end
		end
	end
	
	if ( visibleButtons > 0 ) then
		VoiceChatTalkers:SetHeight(visibleButtons * VoiceChatTalkers.buttons[1]:GetHeight() + VOICECHAT_TALKERS_PADDING);
	else
		VoiceChatTalkers:SetHeight(VoiceChatTalkers.buttons[1]:GetHeight() + VOICECHAT_TALKERS_PADDING);
	end
end

function VoiceChat_OnUpdate(self, elapsed)
	if ( not self.show ) then
		if ( self.unit ) then
			if ( self.name == UnitName("player") ) then
				return;
			elseif ( self.timer ) then
				if ( self.timer < 0 ) then
					UIFrameFadeOut(self, 0.35); 
					self.timer = nil;
					self.unit = nil;
					self.name = nil;
				else
					self.timer = self.timer - elapsed;
				end
			end
		end
	end
end

function VoiceChat_Animate(frame, animate)
	local frameName = frame:GetName();
	if ( animate ) then
		UIFrameFlash(_G[frameName.."Flash"], 0.35, 0.35, -1);
	else
		UIFrameFlashStop(_G[frameName.."Flash"]);
		frame:Hide();
	end
end


function MiniMapVoiceChat_Update()
	local count = GetNumVoiceSessions();
	if ( IsVoiceChatEnabled() ) then
		if ( GetNumVoiceSessions() ) then
			MiniMapVoiceChatFrame:Show();
			if ( count ~= MiniMapVoiceChatFrame.count ) then
				VoiceChatShineFadeIn();
			end
			MiniMapVoiceChatFrame.count = count;
		end
	else
		MiniMapVoiceChatFrame:Hide();
	end
end

--- Global Voice Chat Switch
function VoiceChat_Toggle()
	if ( IsVoiceChatEnabled() ) then
		-- Options Frame Enable
		GameMenuButtonSoundOptions:SetText(SOUNDOPTIONS_MENU);
		ChannelFrameAutoJoin:Show();
		VoiceChatTalkers:Show();
	else
		if ( IsVoiceChatAllowedByServer() ) then
			-- Options Frame Enable
			GameMenuButtonSoundOptions:SetText(SOUNDOPTIONS_MENU);
		else
			-- Options Frame Disable
			GameMenuButtonSoundOptions:SetText(VOICE_SOUND);
		end
		ChannelFrameAutoJoin:Hide();
		VoiceChatTalkers:Hide();
	end
end

--[ Minimap DropDown Functions ]--

function MiniMapVoiceChatDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MiniMapVoiceChatDropDown_Initialize, "MENU");
end

function MiniMapVoiceChatDropDown_Initialize()
	local name, active, checked;
	local count = GetNumVoiceSessions();
	local info;
	for id=1, count do
		name, active = GetVoiceSessionInfo(id);

		info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.checked = active;
		info.func = function (self, id) SetActiveVoiceChannelBySessionID(id) end;
		info.arg1 = id;
		UIDropDownMenu_AddButton(info);
	end

	if ( not GetVoiceCurrentSessionID() ) then
		checked = 1;
	else
		checked = nil;
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = NONE;
	info.checked = checked;
	info.func = function (self, id) SetActiveVoiceChannelBySessionID(id) end;
	info.arg1 = 0;
	UIDropDownMenu_AddButton(info);

end

function VoiceChatShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = VoiceChatShineFadeOut;
	UIFrameFade(VoiceChatShine, fadeInfo);
end

function VoiceChatShineFadeOut()
	UIFrameFadeOut(VoiceChatShine, 0.5);
end

function SetSelfMuteState()
	if ( (GetCVar("VoiceChatSelfMute") == "1") and (GetCVar("VoiceChatMode") == "1") ) then
		MiniMapVoiceChatFrameIconMuted:Show();
	else
		MiniMapVoiceChatFrameIconMuted:Hide();
	end
end
