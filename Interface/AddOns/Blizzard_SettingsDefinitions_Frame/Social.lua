local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(SOCIAL_LABEL);
	Settings.SOCIAL_CATEGORY_ID = category:GetID();
	
	-- Disable Chat
	do
		function InterceptDisableChatChanged(disabled)
			if disabled then
				StaticPopup_Show("CHAT_CONFIG_DISABLE_CHAT");
				return true;
			else
				return false;
			end
		end

		function SetChatDisabled(disabled)
			C_SocialRestrictions.SetChatDisabled(disabled);
			ChatConfigFrame_OnChatDisabledChanged(disabled);
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_DISABLE_CHAT", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, RESTRICT_CHAT_CONFIG_DISABLE, defaultValue, C_SocialRestrictions.IsChatDisabled, SetChatDisabled);
		local initializer = Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_DISABLE_CHAT);
		initializer:SetSettingIntercept(InterceptDisableChatChanged);

		EventRegistry:RegisterFrameEventAndCallback("CHAT_DISABLED_CHANGED", function()
			setting:SetValue(C_SocialRestrictions.IsChatDisabled());
		end);
	end

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[SOCIAL_LABEL]);

	-- Censor Messages
	SocialOverrides.CreateCensorMessagesSetting(category);

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
	
	-- Block Calendar Invites
	Settings.SetupCVarCheckBox(category, "restrictCalendarInvites", RESTRICT_CALENDAR_INVITES, OPTION_TOOLTIP_RESTRICT_CALENDAR_INVITES);
	
	-- Display Only Character Achievements
	if AreAccountAchievementsHidden and ShowAccountAchievements then
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

	if C_CVar.GetCVar("autoAcceptQuickJoinRequests") then
		-- Auto Accept Quick Join Requests
		Settings.SetupCVarCheckBox(category, "autoAcceptQuickJoinRequests", AUTO_ACCEPT_QUICK_JOIN_TEXT, OPTION_TOOLTIP_AUTO_ACCEPT_QUICK_JOIN);
	end

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

		local addSearchTags = true;
		local initializer = CreateSettingsButtonInitializer(RESET_CHAT_POSITION, RESET, OnButtonClick, OPTION_TOOLTIP_RESET_CHAT_POSITION, addSearchTags);
		layout:AddInitializer(initializer);
	end

	SocialOverrides.AdjustSocialSettings(category);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

--[[
	Some setting values cannot be obtained until after PEW. (See PROXY_SHOW_ACCOUNT_ACHIEVEMENTS)
]]--
SettingsRegistrar:AddRegistrant(Register);
