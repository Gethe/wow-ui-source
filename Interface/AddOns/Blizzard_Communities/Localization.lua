local function Localize_zh()
	COMMUNITIES_GUILD_DETAIL_NORM_HEIGHT = 206;
	COMMUNITIES_GUILD_DETAIL_OFFICER_HEIGHT = 264;

	-- smaller icon for rewards list because of larger font
	COMMUNITIES_GUILD_REWARDS_ACHIEVEMENT_ICON = " |TInterface\\AchievementFrame\\UI-Achievement-Guild:12:11:0:1:512:512:324:344:67:85|t ";

	COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT = 57;
	CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox:GetView():SetElementExtent(COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT);

	CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Label:SetPoint("BOTTOMLEFT", 0, 1);
end

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
		localize = Localize_zh,
	},
	zhTW = {
        localize = Localize_zh,
    },
};

SetupLocalization(l10nTable);