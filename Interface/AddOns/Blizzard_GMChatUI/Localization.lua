local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = function()
			GMChatStatusFrameDescription:SetWidth(190);
			GMChatStatusFrameTitleText:SetPoint("TOPLEFT", GMChatStatusFrameBorderLeft, "TOPRIGHT", 0, -14);
			GMChatStatusFrameDescription:SetPoint("TOPLEFT", GMChatStatusFrameTitleText, "BOTTOMLEFT", 0, 2);
		end,
	},
	zhTW = {
		localize = function()
			GMChatStatusFrameDescription:SetWidth(190);
			GMChatStatusFrameTitleText:SetPoint("TOPLEFT", GMChatStatusFrameBorderLeft, "TOPRIGHT", 0, -15);
			GMChatStatusFrameDescription:SetPoint("TOPLEFT", GMChatStatusFrameTitleText, "BOTTOMLEFT", 0, 2);
		end,
	},
};

SetupLocalization(l10nTable);