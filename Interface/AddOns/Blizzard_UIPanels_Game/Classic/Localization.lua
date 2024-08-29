-- luacheck: ignore 111 (setting non-standard global variable)

local function LocalizeTradeFrame_zh()
	TradeFramePlayerEnchantText:SetPoint("TOPLEFT", TradeFrame, 15, -357);
end

local function LocalizeFriendsFrame_zh()
	ADDFRIENDFRAME_WOWHEIGHT = 232;
	ADDFRIENDFRAME_BNETHEIGHT = 310;
	AddFriendNameEditBox:SetPoint("TOP", 0, -144);
	AddFriendNoteFrame:SetPoint("TOP", -2, -178);
end

local function LocalizeWhoFrame_zh()
	for i = 1, WHOS_TO_DISPLAY do
		--Who tab
		_G["WhoFrameButton" .. i .. "Name"]:SetPoint("TOPLEFT", 10, -2);
	end

	WhoFrameDropdown:SetPoint("TOPLEFT", WhoFrameColumnHeader2, "TOPLEFT", -15, 1);
end

local function LocalizeGuildFrame_zh()
	-- Guild Member Detail Window Custom Sizing
	GUILD_DETAIL_NORM_HEIGHT = 222;
	GUILD_DETAIL_OFFICER_HEIGHT = 285;
end

local l10nTable = {
	koKR = {
		localizeFrames = function()
			QuestInfoDescriptionHeader:SetHeight(30);
			QuestInfoRewardsFrame.Header:SetHeight(25);
		end,
	},
	zhCN = {
		localize = function()
			LootFrame_AdjustTextLocation = function(nextFrame, prevFrame)
				if (nextFrame:IsShown()) then
					nextFrame:SetPoint("BOTTOMRIGHT", LootFrame, "BOTTOMLEFT", 133, 18);
				end

				if (prevFrame:IsShown()) then
					prevFrame:SetPoint("BOTTOMLEFT", LootFrame, "BOTTOMLEFT", 36, 18);
				end
			end
		end,

		localizeFrames = function()
			FRIENDS_BUTTON_NORMAL_HEIGHT = 38;
			FRIENDS_BUTTON_LARGE_HEIGHT = 52;

			LocalizeTradeFrame_zh();
			LocalizeFriendsFrame_zh();
			LocalizeWhoFrame_zh();
			LocalizeGuildFrame_zh();
		end,
	},

	zhTW = {
		localize = function()
		end,

		localizeFrames = function()
			LocalizeTradeFrame_zh();
			LocalizeFriendsFrame_zh();
			LocalizeWhoFrame_zh();
			LocalizeGuildFrame_zh();
		end,
	},
};

SetupLocalization(l10nTable);