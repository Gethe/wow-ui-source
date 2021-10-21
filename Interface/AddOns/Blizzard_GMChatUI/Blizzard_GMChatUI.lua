local ListOfGMs = {};

function GMChatFrame_IsGM(playerName)
	return ListOfGMs[strlower(playerName)];
end

function GMChatFrame_OnLoad(self)
	self:SetTimeVisible(120.0);
	self:SetMaxLines(128);
	self:SetFontObject(ChatFontNormal);
	self:SetIndentedWordWrap(true);
	self:SetJustifyH("LEFT");

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
		object:SetAlpha(0.6);
	end

	self:RegisterEvent("CHAT_MSG_WHISPER");
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self.flashTimer = 0;
	self.lastGM = {};

	self:SetClampRectInsets(-35, 0, 30, 0);

	self:SetFont(DEFAULT_CHAT_FRAME:GetFont());
	FCF_SetButtonSide(self, "left", true);
	self.buttonFrame:SetAlpha(1);
	self.buttonFrame.minimizeButton:Hide();

	self.editBox:ClearAllPoints();
	self.editBox:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 8, -2);
	self.editBox:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -43, -2);
	self.editBox.isGM = true;
	ChatEdit_DeactivateChat(self.editBox);
end

function GMChatFrame_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...;
	if ( event == "CHAT_MSG_WHISPER" and arg6 == "GM" ) then
		local info = ChatTypeInfo["WHISPER"];

		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:26:0:16|t ";

		-- Search for icon links and replace them with texture links.
		local term;
		for tag in string.gmatch(arg1, "%b{}") do
			term = strlower(string.gsub(tag, "[{}]", ""));
			if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
				arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
			end
		end

		local gmLink = GetGMLink(arg2, ("[%s]"):format(arg2), arg11);
		local body = CHAT_WHISPER_GET:format(pflag..gmLink)..arg1;

		ListOfGMs[strlower(arg2)] = true;
		self:AddMessage(body, info.r, info.g, info.b, info.id);

		if ( self.lastGMForCVar ~= arg2 and GMChatFrame:IsShown() ) then
			SetCVar("lastTalkedToGM", arg2);
		end
		self.lastGMForCVar = arg2;

		if ( not GMChatFrame:IsShown() ) then
			GMChatStatusFrame:Show();
			table.insert(self.lastGM,arg2);
			PlaySound(SOUNDKIT.GM_CHAT_WARNING);

			DEFAULT_CHAT_FRAME:AddMessage(pflag.."|HGMChat|h["..GM_CHAT_STATUS_READY_DESCRIPTION.."]|h", info.r, info.g, info.b, info.id);
			DEFAULT_CHAT_FRAME:SetHyperlinksEnabled(true);
			DEFAULT_CHAT_FRAME.overrideHyperlinksEnabled = true;
		else
			ChatEdit_SetLastTellTarget(arg2, "WHISPER");
		end
	elseif ( event == "CHAT_MSG_WHISPER_INFORM" and GMChatFrame_IsGM(arg2) ) then
		local info = ChatTypeInfo["WHISPER_INFORM"];

		local pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";

		-- Search for icon links and replace them with texture links.
		local term;
		for tag in string.gmatch(arg1, "%b{}") do
			term = strlower(string.gsub(tag, "[{}]", ""));
			if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
				arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
			end
		end

		local gmLink = GetGMLink(arg2, ("[%s]"):format(arg2), arg11);
		local body = CHAT_WHISPER_INFORM_GET:format(pflag..gmLink)..arg1;

		self:AddMessage(body, info.r, info.g, info.b, info.id);
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		local arg1, arg2, arg3, arg4 = ...
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			ChatFrame_UpdateColorByID(self, info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					ChatFrame_UpdateColorByID(self, info.id, info.r, info.g, info.b);
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
	for _,gmName in ipairs(self.lastGM) do
		ChatEdit_SetLastTellTarget(gmName, "WHISPER");
	end
	table.wipe(self.lastGM);
	if ( self.lastGMForCVar ) then
		SetCVar("lastTalkedToGM", self.lastGMForCVar);
		GMChatFrameEditBox:SetAttribute("tellTarget", self.lastGMForCVar);
		GMChatFrameEditBox:SetAttribute("chatType", "WHISPER");
	end

	if ( GetCVarBool("chatMouseScroll") ) then
		GMChatFrame:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll);
		GMChatFrame:EnableMouseWheel(true);
	end

	self:SetScript("OnUpdate", GMChatFrame_OnUpdate);
	self.editBox:Show();
end

function GMChatFrame_OnHide(self)
	SetCVar("lastTalkedToGM", "");
	self.editBox:Hide();

	if ( ChatEdit_GetLastActiveWindow() == self.editBox ) then
		ChatEdit_SetLastActiveWindow(nil);
	end
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

function GMChatStatusFrame_OnLoad(self)
	NineSliceUtil.ApplyUniqueCornersLayout(self.Pulse, "gmglow");
	for index, region in enumerate_regions(self.Pulse) do
		region:SetBlendMode("ADD");
	end
	self.Pulse.Anim:Play();

	self:SetWidth(math.max(self.TitleText:GetWidth(), self.SubtitleText:GetWidth()) + 50);
	self:SetHeight(self.TitleText:GetHeight() + self.SubtitleText:GetHeight() + 20);

	local bgR, bgG, bgB = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB();
	self.NineSlice:SetCenterColor(bgR, bgG, bgB, 1);
end

function GMChatStatusFrame_OnClick()
	GMChatFrame_Show();
end
