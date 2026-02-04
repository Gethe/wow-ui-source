
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

function ChatFrameMenuButtonMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LANGUAGE_LIST_CHANGED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("CAN_PLAYER_SPEAK_LANGUAGE_CHANGED");

	local function SetChatTypeAttribute(chatType)
		local editBox = ChatFrameUtil.OpenChat("");
		editBox:SetChatType(chatType);
		editBox:UpdateHeader();
	end

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

	local function IsLanguageSelected(language)
		return GetSelectedLanguageID() == language[2];
	end

	local function SetLanguageSelected(languageData)
		DEFAULT_CHAT_FRAME.editBox:SetGameLanguage(languageData[1], languageData[2]);
	end

	local function AddSlashInitializer(button, chatShortcut)
		button:AddInitializer(function(button, description, menu)
			local fontString2 = button:AttachFontString();
			local offset = description:HasElements() and -20 or 0;
			fontString2:SetPoint("RIGHT", offset, 0);
			fontString2:SetJustifyH("RIGHT");
			fontString2:SetTextToFit(chatShortcut);

			button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end);
	end

	local function ColorInitializer(button, description, menu)
		button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHAT_SHORTCUTS", block);
		rootDescription:SetMinimumWidth(180);

		local function CreateButtonWithShortcut(chatName, chatShortcut, chatType)
			local button = rootDescription:CreateButton(chatName, function()
				SetChatTypeAttribute(chatType);
			end);

			AddSlashInitializer(button, chatShortcut);
			return button;
		end

		local isOnGlueScreen = C_Glue.IsOnGlueScreen();
		if not isOnGlueScreen then
			CreateButtonWithShortcut(SAY_MESSAGE, SLASH_SAY1, "SAY");
		end

		CreateButtonWithShortcut(PARTY_MESSAGE, SLASH_PARTY1, "PARTY");

		if not isOnGlueScreen then
			CreateButtonWithShortcut(RAID_MESSAGE, SLASH_RAID1, "RAID");
			CreateButtonWithShortcut(INSTANCE_CHAT_MESSAGE, SLASH_INSTANCE_CHAT1, "INSTANCE_CHAT");
			CreateButtonWithShortcut(GUILD_MESSAGE, SLASH_GUILD1, "GUILD");
			CreateButtonWithShortcut(YELL_MESSAGE, SLASH_YELL1, "YELL");
		end

		local whisperButton = rootDescription:CreateButton(WHISPER_MESSAGE, function()
			local editBox = ChatFrameUtil.OpenChat(SLASH_SMART_WHISPER1.." ");
			editBox:SetText(SLASH_SMART_WHISPER1.." "..editBox:GetText());
		end);
		AddSlashInitializer(whisperButton, SLASH_SMART_WHISPER1);

		local replyButton = rootDescription:CreateButton(REPLY_MESSAGE, function()
			ChatFrameUtil.ReplyTell();
		end);
		AddSlashInitializer(replyButton, SLASH_REPLY1);

		if not isOnGlueScreen then
			if not C_GameRules.IsGameRuleActive(Enum.GameRule.MacrosDisabled) then
				local macroButton = rootDescription:CreateButton(MACRO, function()
					ShowMacroFrame();
				end);
				AddSlashInitializer(macroButton, SLASH_MACRO1);
			end

			local emoteSubmenu = CreateButtonWithShortcut(EMOTE_MESSAGE, SLASH_EMOTE1, "EMOTE");
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
				languageSubmenu:CreateRadio(language, IsLanguageSelected, SetLanguageSelected, languageData);
			end
		end
	end);
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

function ChatFrameMenuButtonMixin:ValidateSelectedLanguage()
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
