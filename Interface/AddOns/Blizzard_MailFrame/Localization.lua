local function LocalizeMailFrame_zh()
	for i=1, (MailFrame.numTabs or 0) do
		local tabName = "MailFrameTab"..i;
		_G[tabName].Text:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end

	SendMailNameEditBox:SetPoint("TOPLEFT", SendMailFrame, "TOPLEFT", 125, -30);
	SendMailNameEditBox:SetWidth(185);
	SendMailSubjectEditBoxMiddle:SetWidth(186);
end

local function LocalizeMailFrame_es()
	SendMailNameEditBox:SetPoint("TOPLEFT", SendMailFrame, "TOPLEFT", 100, -30);
	SendMailNameEditBox:SetWidth(210);
	SendMailSubjectEditBoxMiddle:SetWidth(211);
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {
		localizeFrames = LocalizeMailFrame_es,
	},
	esMX = {
		localizeFrames = LocalizeMailFrame_es,
	},
	frFR = {},
	itIT = {},
	koKR = {
		localizeFrames = function()
			SendMailNameEditBox:SetPoint("TOPLEFT", SendMailFrame, "TOPLEFT", 107, -30);
			SendMailNameEditBox:SetWidth(203);
			SendMailSubjectEditBoxMiddle:SetWidth(204);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localizeFrames = LocalizeMailFrame_zh,
	},
	zhTW = {
        localizeFrames = LocalizeMailFrame_zh,
    },
};

SetupLocalization(l10nTable);