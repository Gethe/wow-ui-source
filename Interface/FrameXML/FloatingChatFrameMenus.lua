
function EmoteMenu_Click(self)
	DoEmote(EmoteList[self:GetID()]);
	ChatMenu:Hide();
end

function TextEmoteSort(token1, token2)
	local i = 1;
	local string1, string2;
	local token = _G["EMOTE"..i.."_TOKEN"];
	while ( i <= MAXEMOTEINDEX ) do
		if ( token == token1 ) then
			string1 = _G["EMOTE"..i.."_CMD1"];
			if ( string2 ) then
				break;
			end
		end
		if ( token == token2 ) then
			string2 = _G["EMOTE"..i.."_CMD1"];
			if ( string1 ) then
				break;
			end
		end
		i = i + 1;
		token = _G["EMOTE"..i.."_TOKEN"];
	end
	return string1 < string2;
end

function OnMenuLoad(self,list,func)
	sort(list, TextEmoteSort);
	UIMenu_Initialize(self);
	self.parentMenu = "ChatMenu";
	for index, value in pairs(list) do
		local i = 1;
		local token = _G["EMOTE"..i.."_TOKEN"];
		while ( i < MAXEMOTEINDEX ) do
			if ( token == value ) then
				break;
			end
			i = i + 1;
			token = _G["EMOTE"..i.."_TOKEN"];
		end
		local label = _G["EMOTE"..i.."_CMD1"];
		if ( not label ) then
			label = value;
		end
		UIMenu_AddButton(self, label, nil, func);
	end
	UIMenu_AutoSize(self);
end

function EmoteMenu_OnLoad(self)
	OnMenuLoad(self, EmoteList, EmoteMenu_Click);
end

function VoiceMacroMenu_Click(self)
	local emote = TextEmoteSpeechList[self:GetID()];
	if (emote == EMOTE454_TOKEN or emote == EMOTE455_TOKEN) then
		local faction = UnitFactionGroup("player", true);
		if (faction == "Alliance") then
			emote = EMOTE454_TOKEN;
		elseif (faction == "Horde") then
			emote = EMOTE455_TOKEN;
		end
	end

	DoEmote(emote);
	ChatMenu:Hide();
end

function VoiceMacroMenu_OnLoad(self)
	OnMenuLoad(self, TextEmoteSpeechList, VoiceMacroMenu_Click);
end

LanguageMenuMixin = {};

function LanguageMenuMixin:OnLoad()
	self.parentMenu = "ChatMenu";
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LANGUAGE_LIST_CHANGED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("CAN_PLAYER_SPEAK_LANGUAGE_CHANGED");
end

function LanguageMenuMixin:OnEvent(event, ...)
	self:ValidateSelectedLanguage();

	if self:IsShown() then
		self:SetupLanguageButtons();
	end
end

function LanguageMenuMixin:OnShow()
	self:ValidateSelectedLanguage();
	self:SetupLanguageButtons();
end

function LanguageMenuMixin:GetSelectedLanguageId()
	return self:GetParent().chatFrame.editBox.languageID;
end

function LanguageMenuMixin:SetLanguage(language, languageId)
	ChatEdit_SetGameLanguage(self:GetParent().chatFrame.editBox, language, languageId);
end

function LanguageMenuMixin:ValidateSelectedLanguage()
	local editBoxLanguageId = self:GetSelectedLanguageId();
	if not editBoxLanguageId or not C_ChatInfo.CanPlayerSpeakLanguage(editBoxLanguageId) then
		local defaultLanguage, defaultLanguageId = GetDefaultLanguage();
		self:SetLanguage(defaultLanguage, defaultLanguageId);
	end
end

function LanguageMenuMixin:SetupLanguageButtons()
	UIMenu_Initialize(self);

	local editBoxLanguageId = self:GetSelectedLanguageId();
	for i = 1, GetNumLanguages() do
		local language, languageId = GetLanguageByIndex(i);
		local button = UIMenu_AddButton(self, language, nil, LanguageMenuButton_OnClick);
		button:SetNormalFontObject(languageId == editBoxLanguageId and button.initialHighlightFont or button.initialNormalFont);
	end

	UIMenu_AutoSize(self);
end

function LanguageMenuButton_OnClick(self)
	LanguageMenu:SetLanguage(GetLanguageByIndex(self:GetID()));
	ChatMenu:Hide();
end
