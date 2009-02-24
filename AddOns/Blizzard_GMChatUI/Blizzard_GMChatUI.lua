local ListOfGMs = {};

function GMChatFrame_IsGM(playerName)
	return ListOfGMs[strlower(playerName)];
end

function GMChatFrame_OnLoad(self)
	local name = self:GetName();
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		getglobal(name..value):SetAlpha(0.4);
		getglobal(name..value):SetVertexColor(0,0,0);
	end
	
	self:RegisterEvent("CHAT_MSG_WHISPER");
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM");
	self.flashTimer = 0;
	self.lastGM = {};
	
	GMChatOpenLog:Enable();
end

function GMChatFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = ...;
	if ( event == "CHAT_MSG_WHISPER" and arg6 == "GM" ) then
		local info = ChatTypeInfo["WHISPER"];
		
		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
		
		-- Search for icon links and replace them with texture links.
		if ( arg7 < 1 or ( arg7 >= 1 and CHAT_SHOW_ICONS ~= "0" ) ) then
			local term;
			for tag in string.gmatch(arg1, "%b{}") do
				term = strlower(string.gsub(tag, "[{}]", ""));
				if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
					arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
				end
			end
		end
		
		local body = format(CHAT_WHISPER_GET..arg1, pflag.."|Hplayer:"..arg2..":"..arg11.."|h".."["..arg2.."]".."|h");
		
		ListOfGMs[strlower(arg2)] = true;
		self:AddMessage(body, info.r, info.g, info.b, info.id);
		
		if ( not GMChatFrame:IsShown() ) then
			GMChatStatusFrame:Show();
			GMChatStatusFrame_Pulse();
			table.insert(self.lastGM,arg2);
			
			DEFAULT_CHAT_FRAME:AddMessage(pflag.."|HGMChat|h["..GM_CHAT_STATUS_READY_DESCRIPTION.."]|h", info.r, info.g, info.b);
			DEFAULT_CHAT_FRAME:SetHyperlinksEnabled(true);
			DEFAULT_CHAT_FRAME.overrideHyperlinksEnabled = true;
			SetButtonPulse(HelpMicroButton, 3600, 0.2);
			SetButtonPulse(GMChatOpenLog, 3600, 0.2);
		else
			ChatEdit_SetLastTellTarget(arg2);
		end
	elseif ( event == "CHAT_MSG_WHISPER_INFORM" and GMChatFrame_IsGM(arg2) ) then
		local info = ChatTypeInfo["WHISPER_INFORM"];
		
		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
		
		-- Search for icon links and replace them with texture links.
		if ( arg7 < 1 or ( arg7 >= 1 and CHAT_SHOW_ICONS ~= "0" ) ) then
			local term;
			for tag in string.gmatch(arg1, "%b{}") do
				term = strlower(string.gsub(tag, "[{}]", ""));
				if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
					arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
				end
			end
		end
		
		local body = format(CHAT_WHISPER_INFORM_GET..arg1, pflag.."|Hplayer:"..arg2..":"..arg11.."|h".."["..arg2.."]".."|h");
		
		self:AddMessage(body, info.r, info.g, info.b, info.id);
	end
end

function GMChatFrame_OnShow(self)
	GMChatStatusFrame:Hide();
	GMChatOpenLog:Disable();
	for _,gmName in pairs(self.lastGM) do
		ChatEdit_SetLastTellTarget(gmName);
	end
	table.wipe(self.lastGM);
	
	SetButtonPulse(HelpMicroButton, 0, 1);	--Stop the buttons from pulsing.
	SetButtonPulse(GMChatOpenLog, 0, 1);
	
	self:SetScript("OnUpdate", GMChatFrame_OnUpdate);
end

function GMChatFrame_OnUpdate(self, elapsed)
	if ( DEFAULT_CHAT_FRAME.isUninteractable ) then
		DEFAULT_CHAT_FRAME:SetHyperlinksEnabled(false);
	end
	DEFAULT_CHAT_FRAME.overrideHyperlinksEnabled = false;
	
	self:SetScript("OnUpdate", nil);
end

function GMChatFrame_Show()
	GMChatFrame:Show();
end

function GMChatFrame_Close()
	GMChatFrame:Hide();
end

function GMChatStatusFrame_OnClick()
	GMChatFrame_Show();
end

local function GMChatStatusFrame_PulseFunc(self, elapsed)
	return abs(sin(elapsed*180*450--[[<--Number of times to pulse here]]));
end

local GMChatStatusFrame_PulseTable = {
	totalTime = 900,
	updateFunc = "SetAlpha",
	getPosFunc = GMChatStatusFrame_PulseFunc,
}

function GMChatStatusFrame_Pulse()
	local pulse = GMChatStatusFramePulse;
	pulse:Show();
	pulse:SetAlpha(0);
	SetUpAnimation(pulse, GMChatStatusFrame_PulseTable, pulse.Hide);
end
