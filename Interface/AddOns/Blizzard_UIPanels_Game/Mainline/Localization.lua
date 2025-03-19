-- luacheck: ignore 111 (setting non-standard global variable)

local function LocalizeCharacterFrame_zh()
	for i=1, (CharacterFrame.numTabs or 0) do
		local tabName = "CharacterFrameTab"..i;
		_G[tabName].Text:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end
end

local l10nTable = {
	deDE = {
		localizeFrames = function()
			SideDressUpFrame.ResetButton:SetWidth(105);
		end,
	},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {
		localizeFrames = function()
			QuestInfoDescriptionHeader:SetHeight(30);
			QuestInfoRewardsFrame.Header:SetHeight(25);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {
		localizeFrames = function()
			-- In Quest Log, TrackQuest button is too small for "Untrack Quest" text, so make Abandon Quest a little smaller and Track Quest a little bigger.
			QuestMapFrame.DetailsFrame.TrackButton:SetWidth(QuestMapFrame.DetailsFrame.TrackButton:GetWidth() + 15);
			QuestMapFrame.DetailsFrame.AbandonButton:SetWidth(QuestMapFrame.DetailsFrame.AbandonButton:GetWidth() - 15);
		end,
	},
	zhCN = {
        localize = function()
			STATFRAME_STATTEXT_FONT_OVERRIDE = TextStatusBarText;
        end,

        localizeFrames = function()
			LocalizeCharacterFrame_zh();
			TradeFramePlayerEnchantText:SetPoint("TOPLEFT", TradeFrame, 15, -357);
			GearManagerPopupFrame.BorderBox.EditBoxHeaderText:SetPoint("TOPLEFT", 24, -18);
		end,
	},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
			LocalizeCharacterFrame_zh();
			TradeFramePlayerEnchantText:SetPoint("TOPLEFT", TradeFrame, 26, -371);
			GearManagerPopupFrame.BorderBox.EditBoxHeaderText:SetPoint("TOPLEFT", 24, -18);
		end,
    },
};

SetupLocalization(l10nTable);