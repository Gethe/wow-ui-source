local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(SOCIAL_LABEL);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[SOCIAL_LABEL]);

	--do
	--	local cvar = "excludedCensorSources";
	--	local friendsAndGuild = bit.bor(Enum.ExcludedCensorSources.Friends, Enum.ExcludedCensorSources.Guild);
	--
	--	local EVERYONE = 1;
	--	local EVERYONE_EXCEPT_FRIEND = 2;
	--	local EVERYONE_EXCEPT_FRIEND_AND_GUILD = 3;
	--	local NO_ONE = 4;
	--
	--	local function GetValue()
	--		local censoredMessageSources = tonumber(C_CVar.GetCVar(cvar));
	--		if censoredMessageSources == 0 then
	--			return EVERYONE;
	--		elseif censoredMessageSources == Enum.ExcludedCensorSources.Friends then
	--			return EVERYONE_EXCEPT_FRIEND;
	--		elseif censoredMessageSources == friendsAndGuild then
	--			return EVERYONE_EXCEPT_FRIEND_AND_GUILD;
	--		else
	--			return NO_ONE;
	--		end
	--	end
	--	
	--	local function SetValue(value)
	--		if value == EVERYONE then
	--			SetCVar(cvar, 0);
	--		elseif value == EVERYONE_EXCEPT_FRIEND then
	--			SetCVar(cvar, Enum.ExcludedCensorSources.Friends);
	--		elseif value == EVERYONE_EXCEPT_FRIEND_AND_GUILD then
	--			SetCVar(cvar, friendsAndGuild);
	--		else
	--			SetCVar(cvar, 255);
	--		end
	--	end
	--
	--	local function GetOptions()
	--		local container = Settings.CreateControlTextContainer();
	--		container:Add(EVERYONE, CENSOR_SOURCE_EVERYONE);
	--		container:Add(EVERYONE_EXCEPT_FRIEND, CENSOR_SOURCE_EXCLUDE_FRIENDS);
	--		container:Add(EVERYONE_EXCEPT_FRIEND_AND_GUILD, CENSOR_SOURCE_EXCLUDE_FRIENDS_AND_GUILD);
	--		container:Add(NO_ONE, CENSOR_SOURCE_NO_ONE);
	--		return container:GetData();
	--	end
	--
	--	local defaultValue = EVERYONE_EXCEPT_FRIEND;
	--	local setting = Settings.RegisterProxySetting(category, "PROXY_CENSOR_MESSAGES", Settings.DefaultVarLocation,
	--		Settings.VarType.Number, CENSOR_SOURCE_EXCLUDE, defaultValue, GetValue, SetValue);
	--	Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_CENTER_SOURCE_EXCLUDE);
	--end

	-- Mature Language
	do
		local setting, initializer = Settings.SetupCVarCheckBox(category, "profanityFilter", PROFANITY_FILTER, OPTION_TOOLTIP_PROFANITY_FILTER);
		initializer:AddModifyPredicate(function()
			return GetCVar("textLocale") ~= "zhCN";
		end);
	end

	-- Guild Member Alert
	Settings.SetupCVarCheckBox(category, "guildMemberNotify", GUILDMEMBER_ALERT, OPTION_TOOLTIP_GUILDMEMBER_ALERT);

	-- Block Trades
	Settings.SetupCVarCheckBox(category, "blockTrades", BLOCK_TRADES, OPTION_TOOLTIP_BLOCK_TRADES);

	-- Block Guild Invites
	do
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_BLOCK_GUILD_INVITES", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, BLOCK_GUILD_INVITES, defaultValue, GetAutoDeclineGuildInvites, SetAutoDeclineGuildInvites);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_BLOCK_GUILD_INVITES);
	end
	
	-- Display Only Character Achievements
	do
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_ACCOUNT_ACHIEVEMENTS", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, SHOW_ACCOUNT_ACHIEVEMENTS, defaultValue, AreAccountAchievementsHidden, ShowAccountAchievements);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_ACCOUNT_ACHIEVEMENTS);
	end

	-- Block Channel Invites
	Settings.SetupCVarCheckBox(category, "blockChannelInvites", BLOCK_CHAT_CHANNEL_INVITE, OPTION_TOOLTIP_BLOCK_CHAT_CHANNEL_INVITE);

	-- Online Friends
	Settings.SetupCVarCheckBox(category, "showToastOnline", SHOW_TOAST_ONLINE_TEXT, OPTION_TOOLTIP_SHOW_TOAST_ONLINE);

	--Offline Friends
	Settings.SetupCVarCheckBox(category, "showToastOffline", SHOW_TOAST_OFFLINE_TEXT, OPTION_TOOLTIP_SHOW_TOAST_OFFLINE);

	-- Broadcast Updates
	Settings.SetupCVarCheckBox(category, "showToastBroadcast", SHOW_TOAST_BROADCAST_TEXT, OPTION_TOOLTIP_SHOW_TOAST_BROADCAST);

	-- Real ID and BattleTag Friend Requests
	Settings.SetupCVarCheckBox(category, "showToastFriendRequest", SHOW_TOAST_FRIEND_REQUEST_TEXT, OPTION_TOOLTIP_SHOW_TOAST_FRIEND_REQUEST);

	-- Show Toast Window
	Settings.SetupCVarCheckBox(category, "showToastWindow", SHOW_TOAST_WINDOW_TEXT, OPTION_TOOLTIP_SHOW_TOAST_WINDOW);

	-- Auto Accept Quick Join Requests
	Settings.SetupCVarCheckBox(category, "autoAcceptQuickJoinRequests", AUTO_ACCEPT_QUICK_JOIN_TEXT, OPTION_TOOLTIP_AUTO_ACCEPT_QUICK_JOIN);

	--Chat Style
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("im", IM_STYLE, OPTION_CHAT_STYLE_IM);
			container:Add("classic", CLASSIC_STYLE, OPTION_CHAT_STYLE_CLASSIC);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "chatStyle", Settings.VarType.String, GetOptions, CHAT_STYLE, OPTION_TOOLTIP_CHAT_STYLE);
	end

	-- New Whispers
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("popout", CONVERSATION_MODE_POPOUT, OPTION_WHISPER_MODE_POPOUT);
			container:Add("inline", CONVERSATION_MODE_INLINE, OPTION_WHISPER_MODE_INLINE);
			container:Add("popout_and_inline", CONVERSATION_MODE_POPOUT_AND_INLINE, OPTION_WHISPER_MODE_POPOUT_AND_INLINE);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "whisperMode", Settings.VarType.String, GetOptions, WHISPER_MODE, OPTION_TOOLTIP_WHISPER_MODE);
	end

	-- Chat Timestamps
	do
		local exampleTime = 
		{
			year = 2010,
			month = 12,
			day = 15,
			hour = 15,
			min = 27,
			sec = 32,
		};

		local function CreateTimeStampOption(container, format)
			local label = BetterDate(format, time(exampleTime));
			container:Add(format, label);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", TIMESTAMP_FORMAT_NONE);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM_AMPM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS_AMPM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM_24HR);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS_24HR);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "showTimestamps", Settings.VarType.String, GetOptions, TIMESTAMPS_LABEL, OPTION_TOOLTIP_TIMESTAMPS);
	end

	-- Reset Chat Positions
	do
		local function OnButtonClick()
			FCF_RedockAllWindows();
		end

		local initializer = CreateSettingsButtonInitializer(RESET_CHAT_POSITION, RESET, OnButtonClick, OPTION_TOOLTIP_RESET_CHAT_POSITION);
		layout:AddInitializer(initializer);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

--[[
	Some setting values cannot be obtained until after PEW. (See PROXY_SHOW_ACCOUNT_ACHIEVEMENTS)
]]--
SettingsRegistrar:AddRegistrant(Register);
