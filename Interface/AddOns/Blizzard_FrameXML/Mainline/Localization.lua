local function LocalizeGuildInviteFrame_zh()
	GuildInviteFrameInviterName:SetPoint("TOP", GuildInviteFrame, 0, -22);
	GuildInviteFrameInviteText:SetPoint("TOP", GuildInviteFrameInviterName, 0, -16);
	GuildInviteFrameGuildName:SetPoint("TOP", GuildInviteFrameInviteText, 0, -10);
end

local l10nTable = {
	deDE = {
		localizeFrames = function()
			StackSplitFrame.OkayButton:SetNormalFontObject(SystemFont_Small);
			StackSplitFrame.OkayButton:SetDisabledFontObject(SystemFont_Small);
			StackSplitFrame.OkayButton:SetHighlightFontObject(SystemFont_Small);
			StackSplitFrame.CancelButton:SetNormalFontObject(SystemFont_Small);
			StackSplitFrame.CancelButton:SetDisabledFontObject(SystemFont_Small);
			StackSplitFrame.CancelButton:SetHighlightFontObject(SystemFont_Small);
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
			GuildInviteFrameInviterName:SetPoint("TOP", GuildInviteFrame, 0, -24);
			GuildInviteFrameInviteText:SetPoint("TOP", GuildInviteFrameInviterName, 0, -14);
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localizeFrames = function()
			LocalizeGuildInviteFrame_zh();
		end,
	},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
			LocalizeGuildInviteFrame_zh();
        end,
    },
};

SetupLocalization(l10nTable);