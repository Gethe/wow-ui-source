
local NewLanguageHelpTipInfo = {
	text = NEW_SPOKEN_LANGUAGE_HELPTIP,
	buttonStyle = HelpTip.ButtonStyle.Close,
	offsetX = 0, offsetY = 0,
	targetPoint = HelpTip.Point.RightEdgeCenter,
};

local function GetSelectedLanguageID()
	return DEFAULT_CHAT_FRAME.editBox.languageID;
end

ChatFrameMenuButtonMixin = {};

ChatFrameMenuButtonMixin.CHAT_TYPES =
{
	SAY = "SAY",
	PARTY = "PARTY",
	RAID = "RAID",
	INSTANCE_CHAT = "INSTANCE_CHAT",
	GUILD = "GUILD",
	YELL = "YELL",
	EMOTE = "EMOTE"
}

function ChatFrameMenuButtonMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LANGUAGE_LIST_CHANGED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("CAN_PLAYER_SPEAK_LANGUAGE_CHANGED");

	local function AddEmotes(description, list, func)
		for index, value in ipairs(list) do
			local i = 1;
			local token = _G["EMOTE"..i.."_TOKEN"];
			while ( i < MAXEMOTEINDEX ) do
				if ( token == value ) then
					break;
				end
				i = i + 1;
				token = _G["EMOTE"..i.."_TOKEN"];
			end

			local label = _G["EMOTE"..i.."_CMD1"] or value;
			description:CreateButton(label, function(...)
				func(index);
			end);
		end
	end

	local function ColorInitializer(button, description, menu)
		button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHAT_SHORTCUTS", block);
		rootDescription:SetMinimumWidth(180);

		local isOnGlueScreen = C_Glue.IsOnGlueScreen();
		if not isOnGlueScreen then
			self.CreateButtonWithShortcut(rootDescription, SAY_MESSAGE, SLASH_SAY1, self.CHAT_TYPES.SAY);
		end

		self.CreateButtonWithShortcut(rootDescription, PARTY_MESSAGE, SLASH_PARTY1, self.CHAT_TYPES.PARTY);

		if not isOnGlueScreen then
			self.CreateButtonWithShortcut(rootDescription, RAID_MESSAGE, SLASH_RAID1, self.CHAT_TYPES.RAID);
			self.CreateButtonWithShortcut(rootDescription, INSTANCE_CHAT_MESSAGE, SLASH_INSTANCE_CHAT1, self.CHAT_TYPES.INSTANCE_CHAT);
			self.CreateButtonWithShortcut(rootDescription, GUILD_MESSAGE, SLASH_GUILD1, self.CHAT_TYPES.GUILD);
			self.CreateButtonWithShortcut(rootDescription, YELL_MESSAGE, SLASH_YELL1, self.CHAT_TYPES.YELL);
		end

		local whisperButton = rootDescription:CreateButton(WHISPER_MESSAGE, function()
			local editBox = ChatFrameUtil.OpenChat(SLASH_SMART_WHISPER1.." ");
			editBox:SetText(SLASH_SMART_WHISPER1.." "..editBox:GetText());
		end);
		self.AddSlashInitializer(whisperButton, SLASH_SMART_WHISPER1);

		local replyButton = rootDescription:CreateButton(REPLY_MESSAGE, function()
			ChatFrameUtil.ReplyTell();
		end);
		self.AddSlashInitializer(replyButton, SLASH_REPLY1);

		if not isOnGlueScreen then
			if not C_GameRules.IsGameRuleActive(Enum.GameRule.MacrosDisabled) then
				local macroButton = rootDescription:CreateButton(MACRO, function()
					if Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING then
						return;
					end

					ShowMacroFrame();
				end);
				self.AddSlashInitializer(macroButton, SLASH_MACRO1);
			end

			local emoteSubmenu = self.CreateButtonWithShortcut(rootDescription, EMOTE_MESSAGE, SLASH_EMOTE1, self.CHAT_TYPES.EMOTE);
			AddEmotes(emoteSubmenu, EmoteList, function(index)
				C_ChatInfo.PerformEmote(EmoteList[index]);
			end);

			local voiceEmoteSubmenu = rootDescription:CreateButton(VOICEMACRO_LABEL);
			voiceEmoteSubmenu:AddInitializer(ColorInitializer);

			AddEmotes(voiceEmoteSubmenu, TextEmoteSpeechList, function(index)
				local emote = TextEmoteSpeechList[index];
				if (emote == EMOTE454_TOKEN) or (emote == EMOTE455_TOKEN) then
					local faction = UnitFactionGroup("player", true);
					if faction == "Alliance" then
						emote = EMOTE454_TOKEN;
					elseif faction == "Horde" then
						emote = EMOTE455_TOKEN;
					end
				end
				C_ChatInfo.PerformEmote(emote);
			end);

			local languageSubmenu = rootDescription:CreateButton(LANGUAGE);
			languageSubmenu:AddInitializer(ColorInitializer);

			for i = 1, GetNumLanguages() do
				local language, languageID = GetLanguageByIndex(i);
				local languageData = {language, languageID};
				languageSubmenu:CreateRadio(language, self.IsLanguageSelected, self.SetLanguageSelected, languageData);
			end
		end
	end);
end

function ChatFrameMenuButtonMixin.SetChatTypeAttribute(chatType, chatFrame)
	local existingText = "";
	if (chatFrame) then
		local chatFrameEditBox = ChatFrameUtil.ChooseBoxForSend(chatFrame);
		if (chatFrameEditBox) then
			existingText = chatFrameEditBox:GetText();
		end
	end

	local editBox = ChatFrameUtil.OpenChat(existingText, chatFrame);
	editBox:SetChatType(chatType);
	editBox:UpdateHeader();
end

function ChatFrameMenuButtonMixin.AddSlashInitializer(button, chatShortcut)
	button:AddInitializer(function(button, description)
		local fontString2 = button:AttachFontString();
		local offset = description:HasElements() and -20 or 0;
		fontString2:SetPoint("RIGHT", offset, 0);
		fontString2:SetJustifyH("RIGHT");
		fontString2:SetTextToFit(chatShortcut);

		button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end);
end

function ChatFrameMenuButtonMixin.CreateButtonWithShortcut(description, chatName, chatShortcut, chatType, chatFrame)
	local button = description:CreateButton(chatName, function()
		ChatFrameMenuButtonMixin.SetChatTypeAttribute(chatType, chatFrame);
	end);

	ChatFrameMenuButtonMixin.AddSlashInitializer(button, chatShortcut);
	return button;
end

function ChatFrameMenuButtonMixin.IsLanguageSelected(language)
	return GetSelectedLanguageID() == language[2];
end

function ChatFrameMenuButtonMixin.SetLanguageSelected(languageData)
	DEFAULT_CHAT_FRAME.editBox:SetGameLanguage(languageData[1], languageData[2]);
end

function ChatFrameMenuButtonMixin:Reinitialize()
	self:ValidateSelectedLanguage();
	self:GenerateMenu();
end

function ChatFrameMenuButtonMixin:OnEvent(event, ...)
	if event == "CAN_PLAYER_SPEAK_LANGUAGE_CHANGED" then
		local languageId, canPlayerSpeakLanguage = ...;
		if canPlayerSpeakLanguage and not self:IsMenuOpen() then
			HelpTip:Show(self, NewLanguageHelpTipInfo, self);
		end
	end

	self:Reinitialize();
end

function ChatFrameMenuButtonMixin:OnShow()
	self:Reinitialize();
end

function ChatFrameMenuButtonMixin.ValidateSelectedLanguage()
	local editBoxLanguageID = GetSelectedLanguageID();
	if not editBoxLanguageID or not C_ChatInfo.CanPlayerSpeakLanguage(editBoxLanguageID) then
		local defaultLanguage, defaultLanguageId = GetDefaultLanguage();
		DEFAULT_CHAT_FRAME.editBox:SetGameLanguage(defaultLanguage, defaultLanguageId);
	end
end

function ChatFrameMenuButtonMixin:OnClick()
	if self:IsMenuOpen() and HelpTip:IsShowingAny(self) then
		HelpTip:HideAll(self);
	end
end
