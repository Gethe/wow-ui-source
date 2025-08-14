TimerunningUtil = {};

function TimerunningUtil.AddTinyIcon(text)
	return CreateAtlasMarkup("timerunning-glues-icon-small", 9, 12)..text;
end

function TimerunningUtil.AddSmallIcon(text)
	return CreateAtlasMarkup("timerunning-glues-icon", 12, 12)..text;
end

function TimerunningUtil.AddLargeIcon(text)
	return ("%s %s"):format(CreateAtlasMarkup("timerunning-glues-icon", 12, 12), text);
end

function TimerunningUtil.TimerunningEnabledForPlayer()
	return PlayerIsTimerunning();
end

function TimerunningUtil.GetActiveTimerunningSeasonID()
	-- Because of the way the timerunning season id is stored when it's character independent, we need differing functionality between in-game and glues.
	-- One value is sent down on ClientFeatureSystemStatus, and the other is sent down on ClientFeatureSystemStatusGlueScreen.
	local getActiveTimerunningSeasonID = C_Glue.IsOnGlueScreen() and GetActiveTimerunningSeasonID or C_TimerunningUI.GetActiveTimerunningSeasonID;
	return getActiveTimerunningSeasonID();
end

local TIMERUNNING_SEASON_CONFIGS = {
	-- Default empty values
	[Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE] = {
		expansion = LE_EXPANSION_CLASSIC,
		gluesTimerunningChoiceDesc = "";
		gluesTimerunningBannerHeaderText = "";
	},

	[Constants.TimerunningConsts.TIMERUNNING_SEASON_PANDARIA] = {
		expansion = LE_EXPANSION_MISTS_OF_PANDARIA,
		gluesTimerunningChoiceDesc = TIMERUNNING_CHOICE_PANDARIA_DESCRIPTION;
		gluesTimerunningBannerHeaderText = TIMERUNNING_BANNER_PANDARIA_HEADER;
	},

	[Constants.TimerunningConsts.TIMERUNNING_SEASON_LEGION] = {
		expansion = LE_EXPANSION_LEGION,
		gluesTimerunningChoiceDesc = TIMERUNNING_CHOICE_LEGION_DESCRIPTION;
		gluesTimerunningBannerHeaderText = TIMERUNNING_BANNER_LEGION_HEADER;
	},
};

local function GetCurrTimerunningSeasonConfig()
	local timerunningSeasonID = TimerunningUtil.GetActiveTimerunningSeasonID();
	if not timerunningSeasonID then
		return TIMERUNNING_SEASON_CONFIGS[Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE];
	end

	-- Fills in any missing fields with empty defaults
	return setmetatable(TIMERUNNING_SEASON_CONFIGS[timerunningSeasonID] or {}, {__index = TIMERUNNING_SEASON_CONFIGS[Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE]});
end

function TimerunningUtil.GetTimerunningExpansion()
	local config = GetCurrTimerunningSeasonConfig();
	return config.expansion;
end

function TimerunningUtil.GetTimerunningChoiceDesc()
	local config = GetCurrTimerunningSeasonConfig();
	return config.gluesTimerunningChoiceDesc;
end

function TimerunningUtil.GetTimerunningBannerHeaderText()
	local config = GetCurrTimerunningSeasonConfig();
	return config.gluesTimerunningBannerHeaderText;
end
