local ListOfGMs = {};

function GMChatFrame_IsGM(playerName)
	return ListOfGMs[strlower(playerName)];
end

function GMChatFrame_OnLoad(self)
	local name = self:GetName();
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		local object = _G[name..value];
		local objectType = object:GetObjectType();
		if ( objectType == "Button" ) then
			object:GetNormalTexture():SetVertexColor(0, 0, 0);
			object:GetHighlightTexture():SetVertexColor(0, 0, 0);
			object:GetPushedTexture():SetVertexColor(0, 0, 0);
		elseif ( objectType == "Texture" ) then
			_G[name..value]:SetVertexColor(0,0,0);
		else
			--error("Unhandled object type");
		end
		object:SetAlpha(0.4);
	end
	
	self:RegisterEvent("CHAT_MSG_WHISPER");
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self.flashTimer = 0;
	self.lastGM = {};
	
	GMChatOpenLog:Enable();
	
	self:SetClampRectInsets(-35, 0, 30, 0);
	
	self:SetFont(DEFAULT_CHAT_FRAME:GetFont());
	FCF_SetButtonSide(self, "left", true);
	self.buttonFrame:SetAlpha(1);
	self.buttonFrame.minimizeButton:Hide();
end

function GMChatFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;
	if ( event == "CHAT_MSG_WHISPER" and arg6 == "GM" ) then
		local info = ChatTypeInfo["WHISPER"];
		
		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
		
		-- Search for icon links and replace them with texture links.
		local term;
		for tag in string.gmatch(arg1, "%b{}") do
			term = strlower(string.gsub(tag, "[{}]", ""));
			if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
				arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
			end
		end
		
		local body = format(CHAT_WHISPER_GET, pflag.."|HplayerGM:"..arg2..":"..arg11.."|h".."["..arg2.."]".."|h")..arg1;
		
		ListOfGMs[strlower(arg2)] = true;
		self:AddMessage(body, info.r, info.g, info.b, info.id);
		
		if ( self.lastGMForCVar ~= arg2 and GMChatFrame:IsShown() ) then
			SetCVar("lastTalkedToGM", arg2);
		end
		self.lastGMForCVar = arg2;
		
		if ( not GMChatFrame:IsShown() ) then
			GMChatStatusFrame:Show();
			GMChatStatusFrame_Pulse();
			table.insert(self.lastGM,arg2);
			PlaySound("GM_ChatWarning");
			
			DEFAULT_CHAT_FRAME:AddMessage(pflag.."|HGMChat|h["..GM_CHAT_STATUS_READY_DESCRIPTION.."]|h", info.r, info.g, info.b, info.id);
			DEFAULT_CHAT_FRAME:SetHyperlinksEnabled(true);
			DEFAULT_CHAT_FRAME.overrideHyperlinksEnabled = true;
			MicroButtonPulse(HelpMicroButton, 3600);
			SetButtonPulse(GMChatOpenLog, 3600, 1.0);
		else
			ChatEdit_SetLastTellTarget(arg2);
		end
	elseif ( event == "CHAT_MSG_WHISPER_INFORM" and GMChatFrame_IsGM(arg2) ) then
		local info = ChatTypeInfo["WHISPER_INFORM"];
		
		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
		
		-- Search for icon links and replace them with texture links.
		local term;
		for tag in string.gmatch(arg1, "%b{}") do
			term = strlower(string.gsub(tag, "[{}]", ""));
			if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
				arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
			end
		end
		
		local body = format(CHAT_WHISPER_INFORM_GET, pflag.."|HplayerGM:"..arg2..":"..arg11.."|h".."["..arg2.."]".."|h")..arg1;
		
		self:AddMessage(body, info.r, info.g, info.b, info.id);
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		local arg1, arg2, arg3, arg4 = ...
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			self:UpdateColorByID(info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					self:UpdateColorByID(info.id, info.r, info.g, info.b);
				end
			end
		end
	elseif ( event == "UPDATE_CHAT_WINDOWS" ) then
		local _, fontSize= FCF_GetChatWindowInfo(1);
		if ( fontSize > 0 ) then
			local fontFile, unused, fontFlags = DEFAULT_CHAT_FRAME:GetFont();
			self:SetFont(fontFile, fontSize, fontFlags);
		end
	end
end

function GMChatFrame_OnShow(self)
	GMChatStatusFrame:Hide();
	GMChatOpenLog:Disable();
	for _,gmName in ipairs(self.lastGM) do
		ChatEdit_SetLastTellTarget(gmName);
	end
	table.wipe(self.lastGM);
	if ( self.lastGMForCVar ) then
		SetCVar("lastTalkedToGM", self.lastGMForCVar);
	end
	
	MicroButtonPulseStop(HelpMicroButton);	--Stop the buttons from pulsing.
	SetButtonPulse(GMChatOpenLog, 0, 1);
	
	self:SetScript("OnUpdate", GMChatFrame_OnUpdate);
end

function GMChatFrame_OnHide(self)
	GMChatOpenLog:Enable();
	SetCVar("lastTalkedToGM", "");
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
